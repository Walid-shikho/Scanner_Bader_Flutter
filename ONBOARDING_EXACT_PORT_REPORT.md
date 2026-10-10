# Scanner Onboarding — Exact Bader/Card Port

The Scanner onboarding UI/animation was replaced with the supplied onboarding module.

Preserved exactly from the supplied reference:
- Animated onboarding page timing and sequencing.
- Illustration fade/assembly presentation.
- Typewriter title and description animation.
- Bottom controls geometry.
- Progressive-width steps indicator.
- Image-based next-arrow button and press-scale animation.
- Fixed LTR page swipe direction across locales.
- Language selector + Skip header layout.
- Responsive compact/large-height behavior.

Scanner-only integration adaptations:
- `Routes.login` -> `AppRoutes.login`.
- Scanner `StorageKeys.onboardingSeen` remains the completion flag.
- Package imports normalized to `scanner_partner` project structure.
- Scanner-specific onboarding copy remains in Arabic/English/German via generic onboarding translation aliases.
- Added the reference `next_arrow.png`, `AppAssets`, and `AppImageDecodeSize` dependencies required by the exact implementation.
