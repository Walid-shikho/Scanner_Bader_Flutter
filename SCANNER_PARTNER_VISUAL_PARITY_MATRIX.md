# SCANNER PARTNER VISUAL PARITY MATRIX

**Reference:** supplied `Bader_final36` + `Card_final1_Phase14_FinalQA`  
**Functional baseline:** `Scanner_Partner_Offline_Final_Phase15_1`  
**Allowed statuses:** `PARITY_COMPLETE`, `PARITY_ACCEPTABLE`, `INTENTIONALLY_DIFFERENT`  
**UNREVIEWED screens:** **0**

| Screen / surface | Initial quality issue | Bader / Card reference | Remediation / review result | Status |
|---|---|---|---|---|
| Splash | Already simple and branded | Bader splash/brand treatment | Kept logo-first composition; verified immediate `SplashController` binding is already `Get.put` | PARITY_COMPLETE |
| Mode Selection | Two-mode entry felt functional/generic | Bader entry hierarchy + Card compact product identity | Rebuilt as branded logo header + two semantic mode cards with cyan/orange accents and directional chevrons | PARITY_COMPLETE |
| Login | Form lacked sibling-app hierarchy | Bader integrated header + Card form surfaces | Rebuilt with integrated header, logo, mode badge, Bader fields, canonical loading button and human-facing Offline notice | PARITY_COMPLETE |
| Scanner Shell | Needed semantic/FAB/iOS audit | Bader/Card shell + bottom nav | Verified Home/Settings semantics, center Scan, iOS FAB shift, RTL direction and extend-body behavior; no geometry rewrite required | PARITY_COMPLETE |
| Scanner Home | Dense operational blocks; Scan not dominant enough | Bader/Card Home hero + primary action hierarchy | Added branded context hero, moved Scan immediately below hero, grouped branch/device context, stats and recent activity | PARITY_COMPLETE |
| Scanner Context route | Foundation/debug-style placeholder route | Bader branded empty-state pattern | Converted shared foundation presentation to Bader scaffold/header/empty state; core context remains intentionally surfaced on Home | INTENTIONALLY_DIFFERENT |
| Scanner Branches route | Foundation/debug-style placeholder route | Bader branded empty-state pattern | Converted to family presentation; active branch selection remains in Scanner flow/Home rather than duplicated | INTENTIONALLY_DIFFERENT |
| Scanner Devices | Functional list with weak hierarchy | Bader list/card surfaces | Device card now uses family icon/status hierarchy and humanized trust/status labels; no IDs exposed | PARITY_COMPLETE |
| QR Challenge / Scan entry | Offline scenario selector looked like a dev tool | Bader sheets/forms + Card focused action surfaces | Kept scenarios explicitly Demo-only but wrapped in polished Bader surface; branch rows show user location/address rather than branch code | PARITY_COMPLETE |
| QR Verification route | Foundation route is not the actual finished scan surface | Bader branded empty-state pattern | Shared placeholder presentation upgraded; live verification remains embedded in the main QR journey | INTENTIONALLY_DIFFERENT |
| Scan Result route | Foundation route duplicated flow responsibility | Bader branded empty-state pattern | Shared placeholder presentation upgraded; finished result remains in QR journey to avoid duplicate product flows | INTENTIONALLY_DIFFERENT |
| Eligible Offers | Already used family scaffold/empty-state patterns | Card offer hierarchy + Bader detail pages | Reviewed; retained functional selection semantics and existing Bader surfaces | PARITY_ACCEPTABLE |
| Redemption Confirmation | Needed stronger safety/content review | Bader dialog/form hierarchy | Existing Bader surfaces retained; user-facing contract/debug copy removed; selected offer/cardholder/invoice/PIN semantics preserved | PARITY_COMPLETE |
| Redemption Receipt | Felt like raw result fields | Card receipt/invoice concepts | Rebuilt receipt surface with branded success/result top treatment and structured facts; raw failure code removed | PARITY_COMPLETE |
| Redemption Details | Depends on receipt visual quality | Bader detail structure | Reuses remediated receipt information hierarchy and family page shell | PARITY_COMPLETE |
| Redemption Reverse | Technical authorization wording | Bader confirmation pattern | Existing flow preserved; copy changed to human-facing additional authorization wording; Bader form/button retained | PARITY_COMPLETE |
| Redemption History | Existing family shell but dense utility list | Bader list surfaces | Reviewed; existing responsive Bader list/empty/loading behavior retained | PARITY_ACCEPTABLE |
| Statistics | Metrics read as disconnected numeric surfaces | Bader dashboard summary hierarchy | Period selector grouped in a Bader surface; metric dark/light treatment corrected; no chart-library clutter added | PARITY_COMPLETE |
| Partner Home | Looked like a generic management menu | Bader Home + Card compact sibling app | Rebuilt with fading header, branded Partner Manager hero, canonical section header and responsive management action surfaces | PARITY_COMPLETE |
| Partner Profile | Plain information/settings list | Bader/Card Profile | Rebuilt top identity hero, contact surface, quick actions, management section; protected vs operational edit behavior preserved | PARITY_COMPLETE |
| Partner Operational Edit | Form already structurally aligned | Bader form/details | Reviewed; canonical header/form/button retained and business behavior unchanged | PARITY_ACCEPTABLE |
| Protected Profile Change | Form already aligned but copy was contract-heavy | Bader form/details | Retained request-only behavior; copy now explains review flow without API identifiers | PARITY_COMPLETE |
| Partner Branches | Branch rows exposed technical code / weak hierarchy | Bader cards + Card management lists | Rebuilt branch card with name/address/phone/status, edit affordance and no technical branch code | PARITY_COMPLETE |
| Create Branch | Form used Bader controls but showed taxonomy/debug language | Bader forms | Kept form behavior; visible copy changed to Offline-local option wording; no business changes | PARITY_COMPLETE |
| Edit Branch | Concurrency copy exposed ETag/If-Match | Bader forms | Retained concurrency behavior; user copy now says reload latest version before saving | PARITY_COMPLETE |
| Memberships | Role code looked backend-oriented | Bader people/member cards | Role codes mapped to localized role names; avatar/name/role/branch/status hierarchy retained | PARITY_COMPLETE |
| Partner Offers list | Cards visually uniform; type/value weak | Card offer cards | Offer card rebuilt with accent rail, semantic icon, immediate type/value, status chip, description, usage/exclusive chips | PARITY_COMPLETE |
| Create Offer | Bader form but contract/mock jargon visible | Bader/Card form language | Kept full logic; changed visible helper text to user-facing Offline/local and optional-field wording | PARITY_COMPLETE |
| Offer Details | Contract scope jargon | Card offer details | Existing family form surfaces retained; visible details copy humanized | PARITY_COMPLETE |
| Edit Offer | API/ETag/raw field wording | Bader form/edit hierarchy | Preserved concurrency/edit rules; copy humanized; no targeting/business behavior changed | PARITY_COMPLETE |
| Activate Offer | Functional confirmation | Bader confirmation surfaces | Existing Bader page/button retained; message rewritten around user consequence rather than endpoint/idempotency terminology | PARITY_COMPLETE |
| Disable Offer | Functional confirmation | Bader danger/confirmation hierarchy | Existing Bader surface retained with localized status treatment | PARITY_ACCEPTABLE |
| Partner Notifications | Flat list / weak read-state distinction | Bader settings/list patterns | Rebuilt preference surface, empty state, mark-all action and unread/read notification cards | PARITY_COMPLETE |
| Settings | Weaker than Card Settings | Card Settings direct reference | Rebuilt with section hierarchy, theme controls, Bader-family SettingsTile, mode switch and app info/version | PARITY_COMPLETE |

## Matrix conclusion

- `UNREVIEWED=0`
- Critical user journeys (auth, Scanner Home, QR, redemption, Partner Home/Profile, offers, branches, notifications, settings) are `PARITY_COMPLETE`.
- `PARITY_ACCEPTABLE` is used only where the existing implementation already used canonical Bader primitives and no visual/business rewrite was justified.
- `INTENTIONALLY_DIFFERENT` is limited to registered foundation routes whose actual product experience is intentionally embedded in the main Scanner flow; their visible presentation is nevertheless Bader-branded and no longer developer-looking.
