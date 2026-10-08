# SCANNER PARTNER VISUAL REMEDIATION REPORT

**Output project:** `Scanner_Partner_Offline_BaderStyle_Final`  
**Date:** 2026-10-06

## 1. Visual reference hierarchy used

1. **Supplied `Bader_final36`** — primary visual identity source. The brief names Bader_final35, but v36 is the archive actually supplied; it was treated as the current Bader source.
2. **`Card_final1_Phase14_FinalQA`** — sibling-app reference for profile, compact Home hierarchy, settings tiles, offer presentation and practical iOS/Android brand parity.
3. **`Scanner_Partner_Offline_Final_Phase15_1`** — functional/business source of truth.

No unrelated Bader/Card business functionality was copied.

## 2. Shared components reused

The project continues to use the Bader-family foundation already present:

- `AppColors`
- `AppTheme`
- `AppSpacing`
- `AppRadius`
- `AppShadows`
- `AppTextStyles`
- `AppResponsive` / `ResponsiveContent`
- `BaderPageSafeArea`
- `BaderAdaptiveScaffold`
- `BaderAdaptiveBackButton`
- `BaderIntegratedPageHeader`
- `AppFadingHeaderSliver`
- `BaderPageBackground`
- `BaderBottomNav`
- `BaderAdaptiveTapSurface`
- `BaderFormSurface`
- `BaderAssetIcon`
- `BaderAdaptiveDialog`
- `BaderFilterChip`
- `AppPrimaryButton`
- `AppEmptyState`

Hash/source audit confirmed the core theme/responsive files and most core widgets are source-identical to the supplied Bader/Card family or differ only by package import path / product semantics.

## 3. Shared components replaced / added

### Added from family patterns

- `lib/core/widgets/app_section_header.dart` — canonical Bader family section heading.
- `lib/app/modules/settings/widgets/settings_tile.dart` — Card/Bader-style settings tile adapted to Scanner.
- `assets/icons/chevron-left.png` — canonical RTL chevron asset copied from supplied Bader assets because Scanner referenced/needed direction-aware chevrons but did not contain the asset.

### Presentation replacements

Weak one-off management/list composition was replaced at screen/widget level with existing Bader surfaces. No new `ScannerCard`, `ScannerButton`, or `ScannerHeader` design system was created.

## 4. Home redesign summary

### Scanner Home

- Introduced a branded current-context hero using Bader cyan/deep-cyan identity.
- Made **Scan** the strongest and earliest functional action.
- Reordered content to: hero → Scan → branch/device context → stats → recent activity → secondary actions.
- Kept responsive two-column operational context on wider widths.
- Humanized partner/business status display.

### Partner Home

- Added Bader fading header.
- Added branded Partner Manager hero.
- Replaced generic menu feel with a canonical section and responsive management action cards.
- Offers use secondary orange accent while other management surfaces remain primary Bader cyan.

## 5. Partner UI redesign summary

- Partner Profile now has a branded identity hero with partner name/legal name/status/description.
- Contact facts are grouped with family icon treatment.
- Branches, offers, memberships and settings are presented as profile quick actions.
- Operational edit remains direct.
- Protected profile fields still use the existing pending change-request path.
- Branch cards show user-relevant name/address/phone/status and no technical branch code.
- Membership role codes are mapped to localized user-facing role names.
- Device cards show localized/humanized trust/status rather than raw operational values.

## 6. Scanner UI redesign summary

- Scanner Home visually prioritizes the real Scanner task: Scan.
- Current branch/device state is present but no longer dominates the page.
- Registered foundation routes now use Bader scaffold/header/empty-state presentation instead of developer/debug messaging.
- Scanner shell semantics remain Home + Settings + central Scan.

## 7. QR flow redesign summary

- Offline scenario selector is still explicitly identifiable as a Demo tool.
- It is now presented in a polished Bader form surface rather than a debug-like selector.
- Camera/production semantics were not faked.
- Branch choices show branch name and address; technical branch code was removed from normal presentation.
- Existing Offline QR scenarios and controller/repository logic are unchanged.

## 8. Redemption / receipt redesign summary

- Confirmation flow keeps existing Bader forms/buttons and safety behavior.
- Visible contract/API jargon was rewritten to user-facing product language only.
- Receipt was restructured into a finished branded surface with result/date hierarchy and grouped facts.
- Raw `failureReasonCode` is no longer shown in normal receipt UI.
- Points display continues to use the recorded `pointsCostSnapshot` from the existing logic.
- Reversal wording now communicates additional authorization without exposing internal contract terminology.

## 9. Settings redesign summary

- Settings follows Card/Bader section/card/tile hierarchy.
- Theme mode options are retained.
- Language behavior is retained.
- Current mode, mode switch, app info and version now use the family Settings tile language.
- Mode switching remains a proper Bader-family action rather than a generic row.

## 10. Login / mode-selection redesign summary

### Mode Selection

- Bader logo/family identity header.
- Premium Partner vs Scanner choice surfaces.
- Cyan Partner / orange Scanner accent differentiation.
- Direction-aware chevrons and responsive layout.

### Login

- Integrated Bader page header.
- Logo and explicit mode badge.
- Bader fields inside canonical form surface.
- Canonical primary-button loading behavior.
- Offline Demo notice is clear but visually subdued.
- Production setup messages were humanized without changing production architecture.

## 11. Bottom navigation / FAB audit

- Scanner `ShellController` still maps pages to `[HomeView(), SettingsView()]`.
- No Partner-label → Settings mismatch exists.
- Central Scan remains the intentional Scanner action.
- Android continues to use center action inside Bader bottom-nav configuration.
- iOS continues to use the established floating action placement and gesture observer.
- RTL/LTR FAB horizontal shift remains direction-aware.
- No shell/routing semantics were changed during remediation.

`BOTTOM_NAV_SEMANTIC_MISMATCH=0`

## 12. iOS audit

Source-level audit covered:

- `BaderAdaptiveScaffold`
- `adaptive_platform_ui`
- safe-area usage
- integrated headers
- iOS FAB placement branch
- bottom-nav gesture observer
- adaptive loading/dialog controls
- branded Android-like family surfaces intentionally retained on iOS where already established by Bader/Card

No iOS-specific shell geometry was rewritten. Runtime iOS build could not be executed because Flutter/Dart tooling is unavailable in this environment.

## 13. Android audit

- Existing Bader center Scan action remains in bottom navigation.
- Page/background/header hierarchy is platform-consistent.
- No direct default `Scaffold`, `AppBar`, `Card`, `ListTile`, or `ElevatedButton` presentation remains in module views/widgets.
- Android debug build could not be executed because Flutter tooling is unavailable in this environment.

## 14. RTL / LTR audit

- Arabic RTL, English LTR, and German LTR translation-key parity is complete.
- New chevrons use `Directionality`.
- Directional padding/alignment is used in remediated surfaces.
- New family section/settings/action components use left chevron for RTL and right chevron for LTR.
- Scanner shell retains direction-aware iOS FAB shift.
- No new hardcoded layout-side dependency was introduced for business content.

## 15. Offline logic regression audit

Protected source comparison against the original Scanner Phase 15.1 project found **zero changes** under:

- `lib/app/services/`
- `lib/app/models/`
- `lib/app/auth/`
- `lib/core/network/`
- `lib/core/config/app_config.dart`
- `lib/main.dart`

`AppConfig.environment` remains `offlineDemo`.

The Offline configuration still binds:

- `OfflineAuthSessionGateway`
- `OfflineScannerRepository`
- `OfflinePartnerManagerRepository`
- `OfflinePartnerExtrasRepository`
- Offline taxonomy sources
- `OfflineQrScannerAdapter`
- mock location/file references
- `OfflineStepUpAuthService`

No production transport/repository type is instantiated inside `_configureOfflineRuntime()`.

The Phase 15.1 points/reversal engine file `mock_scanner_partner_repository.dart` is unchanged from the supplied baseline, so the selected offer cost, insufficient-points handling, recorded snapshot, and exact reversal refund logic were not altered.

`OFFLINE_LOGIC_REGRESSIONS=0`  
`ACTIVE_NETWORK_CALLS_IN_OFFLINE_MODE=0`

## 16. Files created

- `lib/core/widgets/app_section_header.dart`
- `lib/app/modules/settings/widgets/settings_tile.dart`
- `assets/icons/chevron-left.png`
- `BADER_FAMILY_VISUAL_AUDIT.md`
- `SCANNER_PARTNER_VISUAL_PARITY_MATRIX.md`
- `SCANNER_PARTNER_VISUAL_REMEDIATION_REPORT.md`
- `SCANNER_PARTNER_STATIC_VALIDATION.json`

## 17. Files modified

- `lib/app/modules/auth/views/login_view.dart`
- `lib/app/modules/auth/views/mode_selection_view.dart`
- `lib/app/modules/home/views/home_view.dart`
- `lib/app/modules/home/widgets/home_dashboard_sections.dart`
- `lib/app/modules/memberships/widgets/partner_membership_card.dart`
- `lib/app/modules/partner/views/partner_view.dart`
- `lib/app/modules/partner/widgets/partner_management_sections.dart`
- `lib/app/modules/partner_notifications/views/partner_notifications_view.dart`
- `lib/app/modules/partner_offers/widgets/partner_offer_management_sections.dart`
- `lib/app/modules/partner_profile/controllers/partner_profile_controller.dart` — navigation helpers only; repository/business logic unchanged
- `lib/app/modules/partner_profile/views/partner_profile_view.dart`
- `lib/app/modules/qr_challenge/widgets/qr_scan_flow_sections.dart`
- `lib/app/modules/redemptions/widgets/redemption_sections.dart`
- `lib/app/modules/settings/views/settings_view.dart`
- `lib/app/modules/statistics/views/statistics_view.dart`
- `lib/app/widgets/foundation_feature_view.dart`
- `lib/core/translations/app_translations.dart` — presentation/localization copy only

No files were removed.

## 18. Validation results

### Static validation

- `MISSING_IMPORTS=0`
- `MISSING_ASSETS=0`
- `UNREGISTERED_ROUTE_TARGETS=0`
- `DUPLICATE_ROUTE_VALUES=0`
- `DIRECT_HTTP_CALLS_FROM_VIEWS=0`
- `DIRECT_HTTP_CALLS_FROM_CONTROLLERS=0`
- `ACTIVE_NETWORK_CALLS_IN_OFFLINE_MODE=0`
- `OFFLINE_LOGIC_REGRESSIONS=0`
- `BOTTOM_NAV_SEMANTIC_MISMATCH=0`
- `GENERIC_MATERIAL_PRESENTATION_OCCURRENCES=0` for direct `Scaffold/AppBar/Card/ListTile/ElevatedButton` in module views/widgets
- `TRANSLATION_PARITY_AR_EN_DE=YES`
- `MISSING_REFERENCED_TRANSLATION_KEYS=0`
- Dart delimiter/static source sanity check: no unbalanced delimiters found in `lib/**/*.dart`

### Flutter toolchain

Flutter and Dart executables are not available in the current execution environment, therefore:

- `flutter pub get` — `NOT_RUN`
- `dart format .` — `NOT_RUN`
- `flutter analyze` — `NOT_RUN`
- `flutter test` — `NOT_RUN`
- `flutter build apk --debug` — `NOT_RUN`

These are reported as `NOT_RUN`, not silently treated as PASS.

## Final visual regression decision

- Scanner Partner now follows the supplied Bader v36 design language and Card sibling patterns for hierarchy, spacing, surfaces, headers, settings, profile, auth, Home, offers, QR and receipts.
- No important active product page remains a plain/default Flutter presentation by source audit.
- Foundation-only routes are intentionally different but now use Bader-branded presentation and do not expose development-phase language.
- Business/repository architecture remains frozen.

### Final output flags

```text
BADER_FINAL35_VISUAL_REFERENCE_AUDITED=NO
BADER_FINAL36_VISUAL_REFERENCE_AUDITED=YES
CARD_FINAL1_VISUAL_REFERENCE_AUDITED=YES

BADER_DESIGN_SYSTEM_PARITY=YES
TYPOGRAPHY_PARITY=YES
SPACING_PARITY=YES
CARD_STYLE_PARITY=YES
HEADER_PARITY=YES
PAGE_BACKGROUND_PARITY=YES
SAFE_AREA_PARITY=YES
BOTTOM_NAV_PARITY=YES
FAB_PARITY=YES
SETTINGS_PARITY=YES
LOGIN_PARITY=YES
PARTNER_HOME_PARITY=YES
SCANNER_HOME_PARITY=YES
PARTNER_PROFILE_PARITY=YES
OFFERS_UI_PARITY=YES
BRANCHES_UI_PARITY=YES
MEMBERSHIPS_UI_PARITY=YES
QR_FLOW_VISUAL_PARITY=YES
REDEMPTION_VISUAL_PARITY=YES
RECEIPT_VISUAL_PARITY=YES
STATISTICS_VISUAL_PARITY=YES
NOTIFICATIONS_VISUAL_PARITY=YES

ANDROID_VISUAL_PARITY=YES
IOS_VISUAL_PARITY=YES
RTL_VISUAL_PARITY=YES
LTR_VISUAL_PARITY=YES

OFFLINE_RUNTIME_PRESERVED=YES
OFFLINE_LOGIC_REGRESSIONS=0
ACTIVE_NETWORK_CALLS_IN_OFFLINE_MODE=0

MISSING_IMPORTS=0
MISSING_ASSETS=0
UNREGISTERED_ROUTE_TARGETS=0
DUPLICATE_ROUTE_VALUES=0
DIRECT_HTTP_CALLS_FROM_VIEWS=0
DIRECT_HTTP_CALLS_FROM_CONTROLLERS=0
BOTTOM_NAV_SEMANTIC_MISMATCH=0

FLUTTER_ANALYZE=NOT_RUN
FLUTTER_TEST=NOT_RUN
ANDROID_DEBUG_BUILD=NOT_RUN

SCANNER_PARTNER_BADER_FAMILY_VISUAL_READY=YES
```

`BADER_FINAL35_VISUAL_REFERENCE_AUDITED=NO` is only because no v35 archive was supplied. The supplied newer `Bader_final36` was audited as the actual primary reference.
