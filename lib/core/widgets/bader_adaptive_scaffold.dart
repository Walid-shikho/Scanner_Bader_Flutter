import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../responsive/app_responsive.dart';
import '../theme/app_colors.dart';
import 'bader_adaptive_back_button.dart';
import 'bader_integrated_app_bar.dart';
import 'bader_page_background.dart';
import 'bader_page_safe_area.dart';

/// Shared platform shell for Bader screens.
///
/// Modern iOS keeps the Bader page background edge-to-edge and renders only
/// the actual navigation/action controls as native Liquid Glass buttons. This
/// avoids a full-width milky native toolbar surface while preserving UIKit
/// interaction for the controls themselves.
///
/// Android and legacy iOS continue through adaptive_platform_ui's normal
/// Material/Cupertino app-bar paths. Bottom navigation follows Bader_final36:
/// native adaptive on iOS and branded Material overlay on Android.
class BaderAdaptiveScaffold extends StatelessWidget {
  const BaderAdaptiveScaffold({
    super.key,
    required this.body,
    this.title,
    this.subtitle,
    this.actions,
    this.leading,
    this.backgroundColor,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.resizeToAvoidBottomInset,
    this.extendBodyBehindAppBar = false,
    this.useNativeToolbar = true,
    this.enableBlur = true,
    this.minimizeBehavior = TabBarMinimizeBehavior.automatic,
    this.tabBarHidden = false,
    this.usePageBackground = true,
    this.pageBackgroundAccentScale = 1,
  });

  final Widget body;
  final String? title;
  final String? subtitle;
  final List<AdaptiveAppBarAction>? actions;
  final Widget? leading;
  final Color? backgroundColor;
  final AdaptiveBottomNavigationBar? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool? resizeToAvoidBottomInset;
  final bool extendBodyBehindAppBar;
  final bool useNativeToolbar;
  final bool enableBlur;
  final TabBarMinimizeBehavior minimizeBehavior;
  final bool tabBarHidden;
  final bool usePageBackground;
  final double pageBackgroundAccentScale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final resolvedBackground =
        backgroundColor ?? theme.scaffoldBackgroundColor;

    final hasAppBar = title != null ||
        subtitle != null ||
        leading != null ||
        (actions?.isNotEmpty ?? false);
    final resolvedLeading = leading ??
        (hasAppBar && Navigator.of(context).canPop()
            ? const BaderAdaptiveBackButton()
            : null);


    // Keep page chrome visually integrated with the branded background on all
    // platforms. iOS 26 still renders the controls with native Liquid Glass
    // through BaderIntegratedAdaptiveAppBar, while Android/legacy iOS use the
    // existing adaptive fallbacks without introducing a separate toolbar band.
    final useIntegratedAppBar = hasAppBar && usePageBackground;

    final isIOS = PlatformInfo.isIOS;
    final androidNavOverlay =
        !isIOS ? bottomNavigationBar?.bottomNavigationBar : null;
    final keyboardVisible = context.responsive.keyboardVisible;
    final effectiveTabBarHidden = tabBarHidden || keyboardVisible;

    Widget pageContent = BaderPageChromeScope(
      integratedAppBar: useIntegratedAppBar,
      child: body,
    );

    if (useIntegratedAppBar) {
      pageContent = Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(child: pageContent),
          PositionedDirectional(
            top: 0,
            start: 0,
            end: 0,
            child: BaderIntegratedAdaptiveAppBar(
              title: title,
              subtitle: subtitle,
              leading: resolvedLeading,
              actions: actions,
            ),
          ),
        ],
      );
    }

    final resolvedBody = usePageBackground
        ? BaderPageBackground(
            accentScale: pageBackgroundAccentScale,
            child: pageContent,
          )
        : pageContent;

    final overlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
      statusBarBrightness: dark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness:
          dark ? Brightness.light : Brightness.dark,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: AdaptiveScaffold(
        appBar: hasAppBar && !useIntegratedAppBar
            ? AdaptiveAppBar(
                title: title,
                subtitle: subtitle,
                actions: actions,
                leading: resolvedLeading,
                useNativeToolbar: useNativeToolbar,
                tintColor: AppColors.primary,
              )
            : null,
        // Match Bader_final36 exactly: native adaptive tab bar on iOS,
        // custom Material navigation surface on Android.
        bottomNavigationBar: isIOS ? bottomNavigationBar : null,
        floatingActionButton: floatingActionButton,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        extendBodyBehindAppBar:
            useIntegratedAppBar ? false : extendBodyBehindAppBar,
        enableBlur: enableBlur,
        enableToolbarGradient: false,
        minimizeBehavior: minimizeBehavior,
        tabBarHidden: effectiveTabBarHidden,
        body: Material(
          color: resolvedBackground,
          child: Stack(
            children: [
              Positioned.fill(child: resolvedBody),
              if (androidNavOverlay != null && !effectiveTabBarHidden)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: androidNavOverlay,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
