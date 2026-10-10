# Scanner Partner UX Remediation

Implemented on the supplied `Scanner_Partner_Offline_BaderParity_Final(3)` project.

## Completed

1. Partner branch location uses an OpenStreetMap picker instead of manual latitude/longitude entry (create + edit).
2. Offer start/end date-times are read-only picker fields using date + time pickers (create + edit); manual datetime typing removed.
3. Scanner branch selection dialog now uses a wider, taller Bader dialog surface.
4. Scanner Home quick actions are centered when the three actions fit; phone sizing was adjusted so the normal three-action layout centers cleanly.
5. Page chrome now extends to the bottom (`BaderPageSafeArea` no longer reserves a default bottom SafeArea), while scrollable page content uses a standard 80px end spacing.
6. Added Bader/Card-family splash video and first-launch onboarding using the same reference splash/onboarding assets and three-language copy.

## Dependencies added

- `flutter_map: ^8.3.2`
- `latlong2: ^0.10.1`
- `video_player: 2.10.0`

Run `flutter pub get` before building.

## Static validation

- Local relative imports: 0 missing
- Referenced local assets: 0 missing
- Manual `TextInputType.datetime`: 0 remaining
- Branch latitude/longitude text fields: removed from create/edit UI
- Basic delimiter/bracket scan: PASS

Flutter/Dart SDK is not installed in the execution environment, so `flutter analyze`, tests, and device build were not run here.
