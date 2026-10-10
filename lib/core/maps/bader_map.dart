import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

class BaderMapMarkerData {
  const BaderMapMarkerData({
    required this.id,
    required this.point,
    this.selected = false,
  });

  final String id;
  final LatLng point;
  final bool selected;
}

/// Shared Bader-family OpenStreetMap renderer.
class BaderMap extends StatelessWidget {
  const BaderMap({
    super.key,
    required this.mapController,
    required this.initialCenter,
    this.initialZoom = 12,
    this.markers = const [],
    this.onTap,
    this.interactive = true,
    this.borderRadius,
  });

  static const tileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const userAgentPackageName = 'com.aevum.scannerpartner';

  final MapController mapController;
  final LatLng initialCenter;
  final double initialZoom;
  final List<BaderMapMarkerData> markers;
  final ValueChanged<LatLng>? onTap;
  final bool interactive;
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.lg),
      child: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: initialCenter,
          initialZoom: initialZoom,
          minZoom: 3,
          maxZoom: 18,
          interactionOptions: InteractionOptions(
            flags: interactive
                ? InteractiveFlag.all & ~InteractiveFlag.rotate
                : InteractiveFlag.none,
          ),
          onTap: onTap == null ? null : (_, point) => onTap!(point),
        ),
        children: [
          TileLayer(
            urlTemplate: tileUrl,
            userAgentPackageName: userAgentPackageName,
            maxZoom: 19,
          ),
          if (markers.isNotEmpty)
            MarkerLayer(
              markers: [
                for (final marker in markers)
                  Marker(
                    key: ValueKey('bader-map-marker-${marker.id}'),
                    point: marker.point,
                    width: marker.selected ? 46 : 40,
                    height: marker.selected ? 46 : 40,
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: Image.asset(
                        'assets/icons/map-pin.png',
                        color: marker.selected
                            ? AppColors.secondary
                            : AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
          RichAttributionWidget(
            showFlutterMapAttribution: false,
            attributions: [
              TextSourceAttribution('OpenStreetMap contributors'),
            ],
          ),
        ],
      ),
    );
  }
}
