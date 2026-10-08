# FINAL BADER PARITY REMEDIATION REPORT

## Scope

This remediation was performed only on `Scanner_Partner_Offline_BaderStyle_Final`, with `Bader_final36` as the primary visual/geometry reference and `Card_final1_Phase14_FinalQA` as the sibling reference. The existing Offline Demo runtime and Phase 15 / Phase 15.1 business implementation were treated as frozen.

The production API architecture remains in source, while the delivered runtime still selects `AppEnvironment.offlineDemo` and `_configureOfflineRuntime()`.

## 1. Unified Login redesign

- Rebuilt Login around the same Bader-family composition used by the sibling applications: product logo/language control, centered bounded authentication surface, Bader typography, family surfaces, adaptive spacing and RTL/LTR handling.
- Added the account/mode choice directly inside Login.
- Partner is rendered with the canonical Bader cyan treatment; Scanner uses the family orange accent.
- Password visibility and error presentation use Bader-family icon/surface language.
- No Offline login identifier fields were reintroduced. Offline login remains email + password only.

## 2. Mode-selection integration

- `LoginController` now owns a reactive `selectedMode` rather than receiving a fixed mode that requires a separate selection page.
- `SplashController` now restores a valid saved Offline session and enters Shell directly; if no valid session exists it enters Unified Login.
- Settings mode switching preserves the existing independent local sessions: a valid destination session opens directly, otherwise Unified Login opens with the destination mode preselected.
- The old `/mode-selection` route remains registered only as a compatibility redirect to Unified Login. Static audit found **0 normal-flow references** to `AppRoutes.modeSelection` outside route registration.
- Shell/mode middleware redirects to Unified Login rather than showing Mode Selection.

## 3. Partner Profile parity work

- Replaced the previous management-first / large-gradient composition with a profile-first hierarchy.
- Added a Bader-family fading/integrated profile header, circular partner avatar/logo fallback surface, display name, legal name, status and description hierarchy.
- Contact information is grouped into a restrained family surface rather than a settings form.
- Operational edit and protected change request remain separate and are intentionally secondary to the profile content.
- Quick management actions use the same Partner/Card family action-card language and do not expose backend identifiers.

## 4. Partner Home header parity

- Replaced the simple/custom top area with `AppFadingHeaderSliver` and the same page-safe-area/responsive header language used by Bader/Card.
- Header hierarchy is Partner Manager context -> partner display name, with notification/settings actions.
- Header stacks safely for narrow widths / very large text and respects RTL/LTR directional spacing.

## 5. Partner Home grid redesign

- Replaced long management rows with a lightweight grid for Profile, Branches, Offers, Memberships, Notifications and Settings.
- Default phone layout is 2 columns, wider layouts use 3 columns, and very-large accessibility text can fall back to 1 column on narrow widths to avoid clipping/overflow.
- Tiles use Bader family icon surfaces, radius, shadows, typography, directional chevrons and press feedback.

## 6. Partner Offers crash root cause and fix

### Root cause

The Offers subtree contained unsafe nullable access in reactive builds, including a pattern equivalent to checking `controller.searchErrorKey.value != null` and then reading `controller.searchErrorKey.value!` again. The second reactive read was not guaranteed to be the same value. Optional offer/taxonomy fields also had postfix null assertions even though the data contract permits missing optional values.

### Fix

- Nullable reactive values are captured once per build (`searchErrorKey`, pagination/loading state) and then used from the local snapshot.
- Removed postfix null assertions from the complete `partner_offers` subtree.
- Title/description/localization, discount value, points cost, currency and taxonomy display now use deterministic fallbacks.
- Offer create/details display paths were hardened as well.
- Static result: `UNSAFE_NULL_ASSERTIONS_IN_PARTNER_OFFERS=0`.

## 7. Scanner Bottom Nav overflow root cause and fix

### Root cause

The Scanner-specific Material bottom nav reserved a central action gap inside the same horizontal layout that also had to size the two navigation destinations. On narrow/RTL layouts this could reduce an item slot to approximately the reported ~54 px width and the icon/label column overflowed.

### Fix

- Replaced the Scanner-specific center-gap layout math with the proven two-item `Card_final1` BaderBottomNav geometry.
- The Scan FAB is now shell-level and does not consume navigation item width.
- Both Material and native iOS paths retain logical RTL/LTR index handling.
- Very-large text nav height is aligned with the Shell calculations to avoid vertical compression.
- Static result: no old center-action/center-gap layout pattern remains.

## 8. Scanner Home redesign

Scanner Home now follows the requested priority:

1. Primary Scan action.
2. Compact current work context (branch + scanner state).
3. Premium daily summary surface.
4. Recent redemption activity.
5. Secondary quick actions.

It now uses a Bader/Card fading home header instead of a utility/dashboard-style hero, and reduces device/backend-looking information to compact context presentation.

## 9. Scanner full visual remediation

- QR flow kept the existing Bader-family scanner viewport/result composition but nullable UI state was hardened to avoid force-unwrapping context/result values during reactive transitions.
- Card type, expiry, branch location and Offline QR demo scenarios now render safely from local nullable snapshots/fallbacks.
- Redemption confirmation/details/reversal UI now snapshots nullable reactive errors/receipts instead of force-unwrapping values.
- Statistics loaded state safely handles a missing statistics object.
- Eligible offers, receipt/history/details/statistics remain on the existing family scaffold/integrated-header system.
- Settings retains the Bader/Card Settings structure; its current-mode rendering was also made reactive-null-safe.

No redemption calculation/repository behavior was changed.

## 10. FAB parity work

- Scanner Scan FAB retains the same 56 px Bader/Card family control, orange family accent, 27 px QR asset, elevation and Liquid Glass treatment already used by the sibling app.
- Shell positioning was changed to the same geometry model used by Card: the FAB is independent from bottom-nav item sizing.

## 11. Android audit

Source-level audit completed for:

- Material BaderBottomNav with two equal logical items and no center gap.
- Shell-level `PositionedDirectional` FAB with responsive end/bottom geometry.
- No bottom-nav label slot is reduced by FAB reservation.
- `extendBody`/family scaffold behavior remains handled by the shared scaffold rather than manual white-gap padding.
- Narrow-width and large-text code paths were explicitly retained/adapted.

Runtime device execution could not be performed because Flutter/Dart are not installed in the execution environment.

## 12. iOS audit

Source-level audit completed for:

- Native adaptive bottom bar path remains enabled.
- Scan FAB uses the same iOS 26+ `BaderLiquidGlassControl` family implementation as Card.
- RTL horizontal mirroring and the sibling-app vertical translation are preserved in Shell.
- FAB is not part of the nav item width calculation.
- Safe-area/home-indicator calculations remain in the shared scaffold/nav implementation.

Runtime iPhone execution could not be performed because Flutter/Dart are not installed in the execution environment.

## 13. RTL / LTR / responsive audit

Code paths were reviewed for the requested widths and directionality model:

- Phone grid default: 2 columns; tablet/wider: 3 columns.
- Very-large text receives additional vertical nav space and a safe one-column Partner grid fallback when necessary.
- Header action placement uses directional spacing/alignment.
- Bottom-nav logical index mapping explicitly reverses for RTL.
- Added/ported assets are physical family icons and do not depend on text direction except for dedicated login left/right arrow assets.
- Translation keys used by the remediated surfaces are present in Arabic, English and German.

A runtime pixel/layout matrix at 320/360/390/412/448/tablet was **NOT_RUN** because Flutter is unavailable here.

## 14. Files created

- `assets/icons/bell-ringing-2.png` — ported from the Bader family reference assets.
- `assets/icons/eye-off.png` — ported from the Bader family reference assets.
- `assets/icons/eye.png` — ported from the Bader family reference assets.
- `assets/icons/login-left.png` — ported from the Bader family reference assets.
- `assets/icons/login-right.png` — ported from the Bader family reference assets.
- `assets/images/bader_logo_white.png` — ported from the Bader family reference assets.
- `FINAL_BADER_PARITY_REMEDIATION_REPORT.md`

## 15. Files modified

- `lib/app/bindings/partner_binding.dart`
- `lib/app/middleware/app_mode_middleware.dart`
- `lib/app/modules/auth/controllers/login_controller.dart`
- `lib/app/modules/auth/views/login_view.dart`
- `lib/app/modules/auth/views/mode_selection_view.dart`
- `lib/app/modules/home/views/home_view.dart`
- `lib/app/modules/home/widgets/home_dashboard_sections.dart`
- `lib/app/modules/partner/controllers/partner_controller.dart`
- `lib/app/modules/partner/views/partner_view.dart`
- `lib/app/modules/partner_offers/views/partner_offer_create_view.dart`
- `lib/app/modules/partner_offers/views/partner_offer_details_view.dart`
- `lib/app/modules/partner_offers/views/partner_offers_view.dart`
- `lib/app/modules/partner_offers/widgets/partner_offer_management_sections.dart`
- `lib/app/modules/partner_profile/views/partner_profile_view.dart`
- `lib/app/modules/qr_challenge/views/qr_challenge_view.dart`
- `lib/app/modules/qr_challenge/widgets/qr_scan_flow_sections.dart`
- `lib/app/modules/redemptions/views/redemption_confirmation_view.dart`
- `lib/app/modules/redemptions/views/redemption_details_view.dart`
- `lib/app/modules/redemptions/views/redemption_reverse_view.dart`
- `lib/app/modules/redemptions/widgets/redemption_sections.dart`
- `lib/app/modules/settings/views/settings_view.dart`
- `lib/app/modules/shell/views/shell_view.dart`
- `lib/app/modules/shell/widgets/shell_scan_fab.dart`
- `lib/app/modules/splash/controllers/splash_controller.dart`
- `lib/app/modules/statistics/views/statistics_view.dart`
- `lib/core/widgets/bader_bottom_nav.dart`

## 16. Validation results

### Static validation performed

```text
MISSING_IMPORTS=0
MISSING_ASSETS=0
UNREGISTERED_ROUTE_TARGETS=0
DUPLICATE_ROUTE_VALUES=0
UNSAFE_NULL_ASSERTIONS_IN_PARTNER_OFFERS=0
DELIMITER_SANITY_ERRORS=0
ACTIVE_NETWORK_CALLS_IN_OFFLINE_MODE=0
NORMAL_FLOW_MODE_SELECTION_REFS=0
KNOWN_BOTTOM_NAV_CENTER_GAP_PATTERNS=0
FROZEN_BUSINESS_FILES_CHANGED=0
```

Frozen-business hash comparison included the Offline repositories/auth gateway, QR challenge controller, redemption execution/reversal controllers and the Phase 15.1 offline logic test. They are unchanged from the supplied project.

### Flutter toolchain validation

The environment does not contain `flutter` or `dart`, therefore these commands could not be truthfully executed:

```text
flutter pub get = NOT_RUN
dart format . = NOT_RUN
flutter analyze = NOT_RUN
flutter test = NOT_RUN
flutter build apk --debug = NOT_RUN
```

The previously reported Partner Offers crash and Scanner bottom-nav overflow root causes were removed at source level, but their device/runtime reproduction cannot be claimed as executed in this environment.

## Final output flags

```text
UNIFIED_LOGIN_MODE_SELECTOR_READY=YES
STANDALONE_MODE_SELECTION_REMOVED_FROM_NORMAL_FLOW=YES

LOGIN_BADER_CARD_PARITY=YES

PARTNER_PROFILE_BADER_CARD_PARITY=YES
PARTNER_HOME_HEADER_PARITY=YES
PARTNER_HOME_GRID_READY=YES

PARTNER_OFFERS_CRASH_FIXED=YES
PARTNER_OFFERS_NULL_SAFE=YES

SCANNER_BOTTOM_NAV_OVERFLOW_FIXED=YES
SCANNER_RTL_BOTTOM_NAV_READY=YES
SCANNER_LTR_BOTTOM_NAV_READY=YES

SCANNER_FULL_VISUAL_REMEDIATION_READY=YES

SCANNER_FAB_BADER_CARD_PARITY=YES
ANDROID_FAB_PARITY=YES
IOS_FAB_PARITY=YES

OFFLINE_RUNTIME_PRESERVED=YES
OFFLINE_LOGIC_REGRESSIONS=0
ACTIVE_NETWORK_CALLS_IN_OFFLINE_MODE=0

MISSING_IMPORTS=0
MISSING_ASSETS=0
UNREGISTERED_ROUTE_TARGETS=0
KNOWN_RENDER_OVERFLOWS=0

FLUTTER_ANALYZE=NOT_RUN
FLUTTER_TEST=NOT_RUN
ANDROID_DEBUG_BUILD=NOT_RUN

SCANNER_PARTNER_FINAL_BADER_PARITY_READY=NO
```

### Why the final gate is NO

No known source-level visual/runtime issue remains from the requested remediation, and the two reported root causes have been removed. However, the acceptance contract only permits the final global `YES` after the affected screens are actually opened and the runtime/build checks confirm there is no render exception. Flutter/Dart are unavailable in this environment, so that final runtime confirmation would be dishonest to claim.

Exact remaining acceptance item:

- Run `flutter analyze`, `flutter test`, `flutter build apk --debug`, then reproduce Partner Offers and Scanner Bottom Nav (Arabic RTL + English/German LTR, narrow/large-text layouts) on a Flutter-capable machine. If those pass with no runtime/render exception, the final global gate can be changed to `SCANNER_PARTNER_FINAL_BADER_PARITY_READY=YES` without another functional phase.
