# BADER FAMILY VISUAL AUDIT

**Project:** Scanner Partner Offline Demo  
**Audit date:** 2026-10-06  
**Primary supplied reference:** `Bader_final36`  
**Secondary supplied reference:** `Card_final1_Phase14_FinalQA`  
**Functional source of truth:** `Scanner_Partner_Offline_Final_Phase15_1`

> The brief names `Bader_final35`, but the uploaded Bader archive is `Bader_final36`. This audit uses the supplied v36 archive as the current canonical Bader-family source rather than inventing an audit of an unavailable archive.

## Executive finding

Scanner Partner already contained the canonical Bader theme/responsive foundation. Hash comparison showed the same source in Bader, Card, and Scanner for the main theme scale (`AppColors`, `AppSpacing`, `AppRadius`, `AppShadows`, `AppTextStyles`, `AppTheme`), responsive helpers, page safe area, integrated header, fading header, page background, adaptive tap surface, form surface, asset icon, and filter chip. The largest gap was therefore **page composition, hierarchy, card semantics, user-facing copy, and home/profile/auth presentation**, not the base design tokens.

The remediation reuses that foundation and changes presentation only. Production architecture and Offline business repositories remain untouched.

## 1. Theme

- Canonical source: `lib/core/theme/app_theme.dart`.
- Bader, Card, and Scanner use the same theme contract.
- Light/dark behavior is centralized; screen-local theme invention should be avoided.
- Scanner remediation continues to use `Theme.of(context).brightness` only for semantic surface/text variants.

**Parity:** COMPLETE.

## 2. Colors

Canonical brand colors found in all three supplied projects:

- Primary cyan: `#0093AD` (`AppColors.primary`).
- Primary deep: `#005867`.
- Secondary orange: `#E6792F` (`AppColors.secondary`).
- Light page background: `#F6F8FA`.
- Dark page background: `#0A1014`.
- Semantic success/warning/danger remain centralized.
- Existing liquid-glass tokens are preserved.

Scanner now uses cyan for primary Bader identity and orange only as a deliberate secondary emphasis, especially Scanner actions / points / protected changes where appropriate.

**Parity:** COMPLETE.

## 3. Typography

- Canonical semantic scale: `AppTextStyles`.
- Family fonts remain Tajawal / Manrope through the existing app theme and pubspec.
- Page title: 22; section title: 18; body: 14; small: 13; labels/captions are kept on the shared scale.
- Remediated screens use semantic styles rather than arbitrary new font sizes.

**Parity:** COMPLETE.

## 4. Page backgrounds

- Canonical family background is provided by `BaderAdaptiveScaffold(usePageBackground: true)` + `BaderPageBackground`.
- Auth, settings, profile, forms, Scanner flows and placeholder routes now consistently sit on the family page background.
- No plain default Material `Scaffold` remains in module views/widgets.

**Parity:** COMPLETE.

## 5. Header patterns

Two family patterns are used intentionally:

- `AppFadingHeaderSliver` for scrolling Home / Partner dashboard surfaces.
- `BaderIntegratedPageHeader` for pushed/detail/form screens.

Scanner Home and Partner Home use fading headers; detail flows keep the integrated family header.

**Parity:** COMPLETE.

## 6. Safe-area treatment

- Canonical component: `BaderPageSafeArea`.
- Detail/auth/splash screens retain explicit top/bottom safe-area behavior.
- Shell keeps bottom-navigation ownership of the lower safe area.
- No manual status-bar spacing was introduced in remediation.

**Parity:** COMPLETE.

## 7. Integrated app bars

`BaderIntegratedPageHeader` remains the standard for login, offers, branches, profile management, QR, redemptions, notifications, statistics, etc. No default `AppBar` remains in user-facing module presentation.

**Parity:** COMPLETE.

## 8. Fading headers

Bader/Card establish the fading-header behavior. Scanner Home and Partner Home use `AppFadingHeaderSliver`, with responsive fade distances and family typography.

**Parity:** COMPLETE.

## 9. Card surfaces

- Canonical generic grouped surface: `BaderFormSurface`.
- Interactive surfaces use `BaderAdaptiveTapSurface`.
- Business-specific cards remain allowed but now use family spacing/radius/surface treatment.
- Cards are differentiated by importance instead of giving every row an identical outlined box.

**Parity:** COMPLETE.

## 10. Shadows

- `AppShadows.subtle`, `card`, `floating`, `primaryGlow`, and `nav` are the source of truth.
- Hero/profile surfaces use existing family shadow tokens in light mode and avoid unnecessary glow in dark mode.

**Parity:** COMPLETE.

## 11. Radius

Canonical scale is preserved:

- input/button: 14
- card: 18
- large surfaces: 24
- sheet: 30
- pill: 999

No new competing radius scale was introduced.

**Parity:** COMPLETE.

## 12. Button styles

- Primary actions use `AppPrimaryButton`.
- Existing Bader adaptive/tap abstractions are retained.
- Login uses the canonical button loading state rather than a separate generic loading button.
- Protected profile changes use the brand secondary color while retaining the canonical component.

**Parity:** COMPLETE.

## 13. Input fields

- Scanner already uses the Bader field language (`BaderTextField` / Bader form components and theme `InputDecoration`).
- Branch / offer / profile forms retain these controls.
- No form was converted to default Material field styling.

**Parity:** COMPLETE.

## 14. Chips / tags

- Reusable filter chips continue through `BaderFilterChip`.
- Offer/status chips are business-specific but now map states to Bader semantic colors and localized human labels.
- Raw enum-like status values are no longer preferred for normal presentation.

**Parity:** COMPLETE.

## 15. Section titles

A canonical `AppSectionHeader` was brought into Scanner from the supplied Bader family implementation. It is now used in Partner Home, Partner Profile, Notifications and Settings-style composition where section hierarchy matters.

**Parity:** COMPLETE.

## 16. List tiles

Card’s Settings pattern was used as the sibling reference. Scanner now has a Bader-family `SettingsTile` with:

- icon container
- semantic title/subtitle/value hierarchy
- directional chevron
- adaptive tap behavior
- no default `ListTile`

**Parity:** COMPLETE.

## 17. Dialogs

- Existing `BaderAdaptiveDialog` is retained.
- Hash/source comparison shows Scanner’s dialog implementation is the Bader implementation with package-path adaptation.
- Confirmation business semantics were not changed.

**Parity:** COMPLETE.

## 18. Bottom sheets

Existing Bader-family modal/sheet primitives and form surfaces remain the basis. QR Offline Demo selection is visually presented as an explicit branded demo surface and is not made indistinguishable from a real camera flow.

**Parity:** ACCEPTABLE / product-specific.

## 19. Bottom navigation

Scanner keeps its product-specific `BaderBottomNav` because tab semantics differ from Bader/Card. Audit confirmed:

- Scanner pages are `HomeView` and `SettingsView`.
- Center action remains Scan.
- Partner mode does not reuse Scanner tabs.
- The old semantic mismatch (Partner label opening Settings) is not present.
- Shell still uses the Bader adaptive scaffold/minimize behavior.

**Parity:** COMPLETE, intentionally product-specific semantics.

## 20. FAB

- Scan remains the central Scanner action.
- Android uses the bottom-nav center action.
- iOS keeps the established floating placement logic from the completed Scanner shell.
- RTL/LTR horizontal shift remains direction-aware.
- No shell geometry was rewritten during this visual phase.

**Parity:** COMPLETE.

## 21. Profile presentation

Bader/Card profile composition was used as the reference for:

- intentional branded top surface
- centered identity hierarchy
- clear section separation
- management quick actions
- profile-edit actions separated from identity facts

Scanner Partner Profile was rebuilt around these principles while preserving operational edit vs protected request behavior.

**Parity:** COMPLETE.

## 22. Home / dashboard composition

Bader/Card establish a strong top area followed by clear action/summary/content hierarchy.

Scanner Home now follows:

1. branded current-context hero
2. primary **Scan** CTA
3. branch/device context
4. statistics summary
5. recent redemption/activity
6. secondary quick actions

Partner Home now follows:

1. fading Bader header
2. branded Partner Manager hero
3. clear management section
4. responsive business-action surfaces

**Parity:** COMPLETE.

## 23. Settings presentation

Card/Bader Settings is the direct sibling reference. Scanner Settings now uses:

- canonical sections
- settings cards
- theme options
- family `SettingsTile`
- localized mode status
- branded mode switching
- app information/version hierarchy

**Parity:** COMPLETE.

## 24. Empty / error / loading states

- Existing `AppEmptyState` is source-equivalent to Bader except package import paths.
- Placeholder routes were converted from developer/foundation presentation to branded family empty-state presentation.
- Existing adaptive progress states remain.
- Technical error/contract strings visible to users were rewritten to human-facing text without changing internal keys or logic.

**Parity:** COMPLETE.

## 25. Android / iOS visual differences

The family approach is **adaptive behavior without surrendering Bader branding**. Scanner retains:

- `adaptive_platform_ui`
- `BaderAdaptiveScaffold`
- platform-aware bottom navigation/FAB behavior
- adaptive progress indicators/dialog behavior
- branded surfaces on both platforms

No new Cupertino-only redesign was forced onto iOS.

**Parity:** COMPLETE by source audit; runtime build was unavailable in this environment.

## 26. RTL / LTR behavior

Audited for Arabic RTL and English/German LTR:

- Directional padding/alignment is preferred.
- New action/settings/offer chevrons switch left/right by `Directionality`.
- The canonical `chevron-left.png` asset was copied from supplied Bader because Scanner did not contain it.
- FAB shell logic remains direction-aware.
- No technical IDs were added to RTL cards.

**Parity:** COMPLETE by source audit.

## 27. Motion / animation patterns

- Existing `BaderAdaptiveTapSurface` keeps the family’s subtle press interaction.
- Fading headers are retained.
- No excessive animation package or playful business-screen motion was added.
- Existing QR/scanner state transitions were preserved rather than rewritten.

**Parity:** COMPLETE.

## Shared component conclusion

The remediation deliberately **did not invent** `ScannerCard`, `ScannerButton`, or `ScannerHeader` abstractions. It reused or aligned to the Bader family components already present, added the missing canonical `AppSectionHeader`, and added the Card-style Settings tile as a family-level presentation pattern inside the Scanner app.

## Audit decision

`BADER_FINAL36_VISUAL_REFERENCE_AUDITED=YES`  
`CARD_FINAL1_VISUAL_REFERENCE_AUDITED=YES`  
`SCANNER_FUNCTIONAL_SOURCE_AUDITED=YES`  
`BASE_DESIGN_TOKENS_ALREADY_FAMILY_ALIGNED=YES`  
`PRIMARY_GAP_WAS_PAGE_COMPOSITION_AND_CONTENT_HIERARCHY=YES`
