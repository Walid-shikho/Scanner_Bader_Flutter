import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../responsive/app_responsive.dart';
import '../responsive/responsive_content.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

abstract final class BaderBottomNav {
  static const itemCount = 2;

  static AdaptiveBottomNavigationBar config({
    required BuildContext context,
    required int currentIndex,
    int? displayedIndex,
    required ValueChanged<int> onChanged,
  }) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final visibleIndex = displayedIndex ?? currentIndex;

    return AdaptiveBottomNavigationBar(
      useNativeBottomBar: true,
      selectedIndex: visibleIndex,
      onTap: onChanged,
      selectedItemColor: AppColors.primary,
      unselectedItemColor:
          dark ? AppColors.darkTextSecondary : AppColors.textSecondary,
      items: [
        AdaptiveNavigationDestination(
          icon: const AssetImage('assets/icons/home.png'),
          selectedIcon: const AssetImage('assets/icons/home-bold.png'),
          label: 'home'.tr,
        ),
        AdaptiveNavigationDestination(
          icon: const AssetImage('assets/icons/settings.png'),
          selectedIcon: const AssetImage('assets/icons/settings.png'),
          label: 'settings'.tr,
        ),
      ],
      bottomNavigationBar: _MaterialBaderNavigationBar(
        currentIndex: currentIndex,
        onChanged: onChanged,
      ),
    );
  }
}

/// Passive pointer observer for iOS tab-bar scrubbing.
///
/// Unlike the previous transparent overlay, this widget is an ancestor of the
/// native tab bar and never becomes a competing hit-test surface. Normal taps,
/// UIKit haptics and Liquid Glass interactions remain owned by UITabBar. Only
/// a real cross-item drag previews/commits Bader's existing scrubbing behavior.
class BaderBottomNavGestureObserver extends StatefulWidget {
  const BaderBottomNavGestureObserver({
    super.key,
    required this.child,
    required this.activeHeight,
    required this.onPreview,
    required this.onCommit,
    required this.onCancel,
  });

  final Widget child;
  final double activeHeight;
  final ValueChanged<int> onPreview;
  final ValueChanged<int> onCommit;
  final VoidCallback onCancel;

  @override
  State<BaderBottomNavGestureObserver> createState() =>
      _BaderBottomNavGestureObserverState();
}

class _BaderBottomNavGestureObserverState
    extends State<BaderBottomNavGestureObserver> {
  int? _pointer;
  int? _initialIndex;
  int? _candidate;
  bool _scrubbing = false;

  int _logicalIndexFor(BuildContext context, Offset position) {
    final width = MediaQuery.sizeOf(context).width;
    final safeWidth = width <= 0 ? 1.0 : width;
    final visual = ((position.dx.clamp(0.0, safeWidth - .001) / safeWidth) *
            BaderBottomNav.itemCount)
        .floor()
        .clamp(0, BaderBottomNav.itemCount - 1)
        .toInt();
    return Directionality.of(context) == TextDirection.rtl
        ? BaderBottomNav.itemCount - 1 - visual
        : visual;
  }

  bool _insideActiveBand(BuildContext context, Offset position) {
    final height = MediaQuery.sizeOf(context).height;
    return position.dy >= height - widget.activeHeight &&
        position.dy <= height;
  }

  void _reset({required bool cancel}) {
    _pointer = null;
    _initialIndex = null;
    _candidate = null;
    final wasScrubbing = _scrubbing;
    _scrubbing = false;
    if (cancel && wasScrubbing) widget.onCancel();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.deferToChild,
      onPointerDown: (event) {
        if (_pointer != null || !_insideActiveBand(context, event.position)) {
          return;
        }
        _pointer = event.pointer;
        _initialIndex = _logicalIndexFor(context, event.position);
        _candidate = _initialIndex;
      },
      onPointerMove: (event) {
        if (_pointer != event.pointer) return;
        if (!_insideActiveBand(context, event.position)) {
          _reset(cancel: true);
          return;
        }
        final target = _logicalIndexFor(context, event.position);
        if (!_scrubbing && target != _initialIndex) {
          _scrubbing = true;
        }
        if (!_scrubbing || target == _candidate) return;
        _candidate = target;
        widget.onPreview(target);
      },
      onPointerUp: (event) {
        if (_pointer != event.pointer) return;
        if (!_scrubbing || !_insideActiveBand(context, event.position)) {
          _reset(cancel: true);
          return;
        }
        final target = _logicalIndexFor(context, event.position);
        _reset(cancel: false);
        widget.onCommit(target);
      },
      onPointerCancel: (event) {
        if (_pointer == event.pointer) _reset(cancel: true);
      },
      child: widget.child,
    );
  }
}

class _MaterialBaderNavigationBar extends StatefulWidget {
  const _MaterialBaderNavigationBar({
    required this.currentIndex,
    required this.onChanged,
  });

  final int currentIndex;
  final ValueChanged<int> onChanged;

  @override
  State<_MaterialBaderNavigationBar> createState() =>
      _MaterialBaderNavigationBarState();
}

class _MaterialBaderNavigationBarState
    extends State<_MaterialBaderNavigationBar> {
  static const _items = <_NavItemData>[
    _NavItemData(
      outlined: 'assets/icons/home.png',
      filled: 'assets/icons/home-bold.png',
      labelKey: 'home',
    ),
    _NavItemData(
      outlined: 'assets/icons/settings.png',
      filled: 'assets/icons/settings.png',
      labelKey: 'settings',
    ),
  ];

  int? _pointer;
  int? _previewIndex;
  double? _indicatorCenterX;
  bool _dragging = false;

  int _logicalIndexFor(double dx, double width, bool rtl) {
    final safeWidth = width <= 0 ? 1.0 : width;
    final visual = ((dx.clamp(0.0, safeWidth - .001) / safeWidth) *
            _items.length)
        .floor()
        .clamp(0, _items.length - 1)
        .toInt();
    return rtl ? _items.length - 1 - visual : visual;
  }

  double _centerForLogical(int logicalIndex, double width, bool rtl) {
    final visualIndex = rtl ? _items.length - 1 - logicalIndex : logicalIndex;
    final slot = width / _items.length;
    return slot * (visualIndex + .5);
  }

  bool _containsPointer(PointerEvent event, double width, double height) {
    final position = event.localPosition;
    return position.dx >= 0 &&
        position.dx <= width &&
        position.dy >= 0 &&
        position.dy <= height;
  }

  void _handlePointer(PointerEvent event, double width, bool rtl) {
    final candidate = _logicalIndexFor(event.localPosition.dx, width, rtl);
    setState(() {
      _previewIndex = candidate;
      _indicatorCenterX =
          event.localPosition.dx.clamp(0.0, width).toDouble();
    });
  }

  void _cancelDragPreview() {
    setState(() {
      _previewIndex = null;
      _indicatorCenterX = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final surface = dark ? AppColors.darkSurface : AppColors.surface;
    final border = dark ? AppColors.darkBorderStrong : AppColors.border;
    final selectedSurface =
        dark ? AppColors.primarySoftDark : AppColors.primarySoft;
    final info = context.responsive;
    final bottomInset = info.padding.bottom;
    final navHeight = info.veryLargeText
        ? 86.0
        : info.largeText
            ? 74.0
            : 62.0;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final selected = _previewIndex ?? widget.currentIndex;

    return SafeArea(
      top: false,
      minimum: EdgeInsets.only(bottom: bottomInset > 0 ? 0 : AppSpacing.sm),
      child: ResponsiveContent(
        maxWidth: 250,
        padding: EdgeInsetsDirectional.fromSTEB(
          info.isNarrow ? AppSpacing.md : AppSpacing.xl,
          0,
          info.isNarrow ? AppSpacing.md : AppSpacing.xl,
          info.isNarrow ? AppSpacing.md : AppSpacing.xl,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final slotWidth = width / _items.length;
            final restingCenter =
                _centerForLogical(selected, width, rtl);
            final center = _indicatorCenterX ?? restingCenter;
            final left = (center - (slotWidth / 2) + AppSpacing.xs)
                .clamp(AppSpacing.xs, width - slotWidth + AppSpacing.xs)
                .toDouble();

            return Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: (event) {
                if (_pointer != null) return;
                _pointer = event.pointer;
                _dragging = true;
                _handlePointer(event, width, rtl);
              },
              onPointerMove: (event) {
                if (_pointer != event.pointer) return;
                if (!_containsPointer(event, width, navHeight)) {
                  if (_previewIndex != null) _cancelDragPreview();
                  return;
                }
                _handlePointer(event, width, rtl);
              },
              onPointerCancel: (event) {
                if (_pointer != event.pointer) return;
                setState(() {
                  _pointer = null;
                  _previewIndex = null;
                  _indicatorCenterX = null;
                  _dragging = false;
                });
              },
              onPointerUp: (event) {
                if (_pointer != event.pointer) return;
                final inside = _containsPointer(event, width, navHeight);
                if (inside) _handlePointer(event, width, rtl);
                final target = inside ? _previewIndex : null;
                setState(() {
                  _pointer = null;
                  _previewIndex = null;
                  _indicatorCenterX = null;
                  _dragging = false;
                });
                if (target != null) widget.onChanged(target);
              },
              child: Container(
                height: navHeight,
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(AppRadius.xxl),
                  border: Border.all(color: border),
                  boxShadow: AppShadows.nav,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.xxl),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AnimatedPositioned(
                        duration: _dragging
                            ? Duration.zero
                            : const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        left: left,
                        top: AppSpacing.xs,
                        bottom: AppSpacing.xs,
                        width: slotWidth - (AppSpacing.xs * 2),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: selectedSurface,
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                          ),
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var i = 0; i < _items.length; i++)
                            Expanded(
                              child: _NavItem(
                                data: _items[i],
                                selected: selected == i,
                                dark: dark,
                                onSemanticTap: () => widget.onChanged(i),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NavItemData {
  const _NavItemData({
    required this.outlined,
    required this.filled,
    required this.labelKey,
  });

  final String outlined;
  final String filled;
  final String labelKey;
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.data,
    required this.selected,
    required this.dark,
    required this.onSemanticTap,
  });

  final _NavItemData data;
  final bool selected;
  final bool dark;
  final VoidCallback onSemanticTap;

  @override
  Widget build(BuildContext context) {
    final info = context.responsive;
    final activeColor = AppColors.primaryDark;
    final inactiveColor =
        dark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final iconSize = info.largeText ? 24.0 : 23.0;

    return Semantics(
      button: true,
      selected: selected,
      label: data.labelKey.tr,
      onTap: onSemanticTap,
      child: Padding(
        padding: EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.xs,
          vertical: info.largeText ? AppSpacing.sm : AppSpacing.xs,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: iconSize + 2,
              height: iconSize + 2,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 140),
                    curve: Curves.easeOutCubic,
                    opacity: selected ? 0 : 1,
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 160),
                      curve: Curves.easeOutCubic,
                      scale: selected ? .88 : 1,
                      child: Image.asset(
                        data.outlined,
                        width: iconSize,
                        color: inactiveColor,
                      ),
                    ),
                  ),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 140),
                    curve: Curves.easeOutCubic,
                    opacity: selected ? 1 : 0,
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 160),
                      curve: Curves.easeOutCubic,
                      scale: selected ? 1 : .88,
                      child: Image.asset(
                        data.filled,
                        width: iconSize,
                        color: activeColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              data.labelKey.tr,
              maxLines: info.largeText ? 2 : 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: (info.veryLargeText
                      ? AppTextStyles.micro
                      : info.largeText
                          ? AppTextStyles.caption
                          : AppTextStyles.navigationLabel)
                  .copyWith(
                color: selected ? activeColor : inactiveColor,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
