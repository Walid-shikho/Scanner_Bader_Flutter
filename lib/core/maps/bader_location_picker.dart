import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../responsive/app_responsive.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_primary_button.dart';
import '../widgets/bader_adaptive_tap_surface.dart';
import '../widgets/bader_icon_button.dart';
import 'bader_map.dart';

typedef BaderLocationChanged = void Function(double latitude, double longitude);

class _BaderLocationSelection {
  const _BaderLocationSelection({
    required this.point,
    this.label,
  });

  final LatLng point;
  final String? label;
}

/// Compact field that replaces manual latitude/longitude entry with a map pick.
///
/// Coordinates stay internal for the backend contract. The user-facing field
/// resolves and displays a readable place name instead of raw coordinates.
class BaderLocationPicker extends StatefulWidget {
  const BaderLocationPicker({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.onChanged,
  });

  final double? latitude;
  final double? longitude;
  final BaderLocationChanged onChanged;

  @override
  State<BaderLocationPicker> createState() => _BaderLocationPickerState();
}

class _BaderLocationPickerState extends State<BaderLocationPicker> {
  String? _locationLabel;
  bool _isResolving = false;
  int _lookupGeneration = 0;
  double? _labelLatitude;
  double? _labelLongitude;

  bool get _hasSelection =>
      widget.latitude != null &&
      widget.longitude != null &&
      widget.latitude! >= -90 &&
      widget.latitude! <= 90 &&
      widget.longitude! >= -180 &&
      widget.longitude! <= 180;

  @override
  void initState() {
    super.initState();
    if (_hasSelection) {
      _resolveCurrentLocationName();
    }
  }

  @override
  void didUpdateWidget(covariant BaderLocationPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    final coordinatesChanged =
        oldWidget.latitude != widget.latitude ||
        oldWidget.longitude != widget.longitude;
    if (coordinatesChanged) {
      if (_hasSelection) {
        _resolveCurrentLocationName();
      } else {
        _lookupGeneration++;
        _locationLabel = null;
        _labelLatitude = null;
        _labelLongitude = null;
        _isResolving = false;
      }
    }
  }

  bool _labelMatches(double latitude, double longitude) {
    return _labelLatitude == latitude &&
        _labelLongitude == longitude &&
        _locationLabel != null;
  }

  Future<void> _resolveCurrentLocationName() async {
    if (!_hasSelection) return;

    final latitude = widget.latitude!;
    final longitude = widget.longitude!;
    if (_labelMatches(latitude, longitude)) return;

    final generation = ++_lookupGeneration;
    if (mounted) {
      setState(() {
        _isResolving = true;
        _locationLabel = null;
      });
    }

    final label = await _reverseGeocodeLocation(latitude, longitude);
    if (!mounted || generation != _lookupGeneration) return;

    setState(() {
      _isResolving = false;
      _locationLabel = label;
      _labelLatitude = latitude;
      _labelLongitude = longitude;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final border = dark ? AppColors.darkBorder : AppColors.border;
    final surface = dark ? AppColors.darkSurface2 : AppColors.surfaceElevated;
    final textColor = dark ? AppColors.darkText : AppColors.textPrimary;
    final secondary =
        dark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    final locationSubtitle = !_hasSelection
        ? 'map_location_helper'.tr
        : _locationLabel ??
            (_isResolving
                ? 'resolving_location_name'.tr
                : 'selected_location_on_map'.tr);

    return BaderAdaptiveTapSurface(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      onTap: () => _openPicker(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Image.asset(
              'assets/icons/map-pin.png',
              width: 22,
              height: 22,
              color: AppColors.primary,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _hasSelection
                        ? 'selected_location'.tr
                        : 'choose_map_location'.tr,
                    style: AppTextStyles.label.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    locationSubtitle,
                    maxLines: context.responsive.largeText ? 3 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.helper.copyWith(color: secondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Image.asset(
              Directionality.of(context) == TextDirection.rtl
                  ? 'assets/icons/chevron-left.png'
                  : 'assets/icons/chevron-right.png',
              width: 20,
              height: 20,
              color: secondary,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openPicker(BuildContext context) async {
    final result = await showModalBottomSheet<_BaderLocationSelection>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BaderLocationPickerSheet(
        initialPoint: _hasSelection
            ? LatLng(widget.latitude!, widget.longitude!)
            : null,
        initialLabel: _locationLabel,
      ),
    );

    if (result == null || !mounted) return;

    setState(() {
      _locationLabel = result.label;
      _labelLatitude = result.point.latitude;
      _labelLongitude = result.point.longitude;
      _isResolving = false;
    });

    widget.onChanged(result.point.latitude, result.point.longitude);
  }
}

class _BaderLocationPickerSheet extends StatefulWidget {
  const _BaderLocationPickerSheet({
    this.initialPoint,
    this.initialLabel,
  });

  final LatLng? initialPoint;
  final String? initialLabel;

  @override
  State<_BaderLocationPickerSheet> createState() =>
      _BaderLocationPickerSheetState();
}

class _BaderLocationPickerSheetState extends State<_BaderLocationPickerSheet> {
  static const _fallbackCenter = LatLng(34.8021, 38.9968);

  final MapController _mapController = MapController();
  LatLng? _selectedPoint;
  String? _selectedLabel;
  bool _isResolving = false;
  int _lookupGeneration = 0;

  @override
  void initState() {
    super.initState();
    _selectedPoint = widget.initialPoint;
    _selectedLabel = widget.initialLabel;
    if (_selectedPoint != null && _selectedLabel == null) {
      _resolveSelectedLocationName(_selectedPoint!);
    }
  }

  @override
  void dispose() {
    _lookupGeneration++;
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _selectPoint(LatLng point) async {
    setState(() {
      _selectedPoint = point;
      _selectedLabel = null;
    });
    await _resolveSelectedLocationName(point);
  }

  Future<void> _resolveSelectedLocationName(LatLng point) async {
    final generation = ++_lookupGeneration;
    if (mounted) {
      setState(() => _isResolving = true);
    }

    final label = await _reverseGeocodeLocation(
      point.latitude,
      point.longitude,
    );
    if (!mounted || generation != _lookupGeneration) return;

    setState(() {
      _isResolving = false;
      _selectedLabel = label;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final selected = _selectedPoint;
    final surface = dark ? AppColors.darkSurface : AppColors.surface;
    final textColor = dark ? AppColors.darkText : AppColors.textPrimary;
    final secondary =
        dark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    final selectedSubtitle = selected == null
        ? null
        : _selectedLabel ??
            (_isResolving
                ? 'resolving_location_name'.tr
                : 'selected_location_on_map'.tr);

    return FractionallySizedBox(
      heightFactor: context.responsive.isNarrow ? .90 : .84,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.xxl),
          ),
          boxShadow: AppShadows.floating,
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              context.responsive.horizontalPagePadding,
              AppSpacing.md,
              context.responsive.horizontalPagePadding,
              AppSpacing.md,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'select_location'.tr,
                        style: AppTextStyles.pageTitle.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    BaderIconButton(
                      icon: 'assets/icons/x.png',
                      size: 40,
                      iconSize: 18,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: BaderMap(
                    mapController: _mapController,
                    initialCenter: selected ?? _fallbackCenter,
                    initialZoom: selected == null ? 7 : 15,
                    markers: selected == null
                        ? const []
                        : [
                            BaderMapMarkerData(
                              id: 'selected-location',
                              point: selected,
                              selected: true,
                            ),
                          ],
                    onTap: _selectPoint,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: dark
                        ? AppColors.darkSurface2
                        : AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: dark ? AppColors.darkBorder : AppColors.border,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selected == null
                            ? 'tap_map_to_select'.tr
                            : 'selected_location'.tr,
                        style: AppTextStyles.label.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (selectedSubtitle != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          selectedSubtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.helper.copyWith(color: secondary),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                AppPrimaryButton(
                  label: 'confirm_location'.tr,
                  icon: 'assets/icons/map-pin.png',
                  onPressed: selected == null
                      ? null
                      : () => Navigator.of(context).pop(
                            _BaderLocationSelection(
                              point: selected,
                              label: _selectedLabel,
                            ),
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<String?> _reverseGeocodeLocation(
  double latitude,
  double longitude,
) async {
  try {
    final languageCode = Get.locale?.languageCode ?? 'ar';
    final uri = Uri.https(
      'nominatim.openstreetmap.org',
      '/reverse',
      <String, String>{
        'format': 'jsonv2',
        'lat': latitude.toString(),
        'lon': longitude.toString(),
        'zoom': '18',
        'addressdetails': '1',
        'accept-language': languageCode,
      },
    );

    final response = await http.get(
      uri,
      headers: <String, String>{
        'User-Agent': 'com.aevum.scannerpartner/1.0',
        'Accept-Language': languageCode,
      },
    ).timeout(const Duration(seconds: 6));

    if (response.statusCode != 200) return null;
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) return null;

    final addressValue = decoded['address'];
    final address = addressValue is Map
        ? addressValue.map(
            (key, value) => MapEntry(key.toString(), value?.toString()),
          )
        : <String, String?>{};

    String? firstAddressValue(List<String> keys) {
      for (final key in keys) {
        final value = address[key]?.trim();
        if (value != null && value.isNotEmpty) return value;
      }
      return null;
    }

    final values = <String?>[
      decoded['name']?.toString().trim(),
      firstAddressValue(<String>[
        'road',
        'pedestrian',
        'footway',
        'neighbourhood',
        'suburb',
        'quarter',
      ]),
      firstAddressValue(<String>[
        'city',
        'town',
        'village',
        'municipality',
        'county',
      ]),
      firstAddressValue(<String>['state', 'region']),
    ];

    final parts = <String>[];
    for (final raw in values) {
      final value = raw?.trim();
      if (value == null || value.isEmpty) continue;
      if (!parts.contains(value)) parts.add(value);
      if (parts.length == 3) break;
    }

    if (parts.isNotEmpty) {
      return parts.join(languageCode == 'ar' ? '، ' : ', ');
    }

    final displayName = decoded['display_name']?.toString().trim();
    if (displayName == null || displayName.isEmpty) return null;

    return displayName
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .take(3)
        .join(languageCode == 'ar' ? '، ' : ', ');
  } catch (_) {
    return null;
  }
}
