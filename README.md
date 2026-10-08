# Scanner Partner

Third Flutter application in the Bader product family.

## Phase 2 scope

This phase normalizes the Scanner Partner visual/platform foundation against
`Bader_final36` and builds the two-tab Scanner shell:

- Home
- Partner
- central primary **Scan QR** action

The shared Bader theme, responsive system, page background, safe-area policy,
adaptive scaffold, integrated headers/back behavior, fading root headers,
adaptive controls, empty/loading presentation primitives, RTL/LTR behavior and
light/dark behavior are retained. The shell preserves lazy tab visitation and
keeps body content edge-to-edge behind the floating navigation treatment.

Scanner challenge, QR verification, redemption, authentication, device
enrollment/attestation, Step-Up, file upload and other Scanner/Partner business
flows are intentionally **not implemented** in Phase 2.

## Identity

- Dart package: `scanner_partner`
- Android/iOS application id: `com.aevum.scannerpartner`
- `AppConfig.appType`: `scanner`
- Languages: Arabic, English, German
- Fonts: Tajawal (Arabic), Manrope (English/German)
- Orientation: portrait

## Phase 3 — Application Foundation

Phase 3 adds contract-shaped models, a 29-method `ScannerPartnerRepository`, a deterministic network-free mock, typed `user` / `partner_employee` session and permission state, declarative route requirements, and GetX route/binding foundations for all Scanner Partner feature groups.

No production HTTP client, authentication endpoint, scanner enrollment flow, Step-Up proof mechanism, upload endpoint, taxonomy lookup endpoint, or full business screen is implemented in this phase. QR verification remains separate from redemption, and mock verification does not create a redemption.

## Phase 4 — API Contract Models and Transport Foundation

Phase 4 freezes strongly typed request/response aliases for all 29 Scanner /
Partner endpoints, adds JSON codecs for contract DTOs, corrects nullable fields
that are explicit in the PDF, and introduces a network transport boundary that
preserves HTTP status and response headers for future repository processing.

The transport foundation supports Authorization, locale/app/device metadata,
idempotency keys, endpoint-specific headers, If-Match, response ETag,
Retry-After and rate-limit metadata. `X-App-Type` is always sourced from
`AppConfig.appType` (`scanner`). No concrete HTTP adapter or production
repository is connected to UI in this phase; `MockScannerPartnerRepository`
remains the active implementation.

Sensitive authorization values, signed QR tokens, scanner challenges and Static
QR PINs are intentionally excluded from diagnostic string output and no logging
facility was added.

## Phase 5 — Partner Application UX

Phase 5 implements the user-principal partner application experience for API-0205 through API-0208: application list, create form, application details, and document attachment using an already-uploaded `file_public_id`.

The canonical partner-type taxonomy API is still not supplied. `MockPartnerTypeTaxonomySource` is deterministic and explicitly reports `BLOCKED_BY_SHARED_TAXONOMY_CONTRACT`. The Scanner contract also does not define file upload/presign behavior, so `MockUploadedFileReferenceRepository` only supplies existing file references and reports `BLOCKED_BY_SHARED_FILE_UPLOAD_CONTRACT`. No upload endpoint is invented.

`PartnerApplicationData` does not expose an attached-document collection. The documents screen therefore confirms API-0208 attachment but does not invent a local authoritative document history. Production document-history integration is explicitly `BLOCKED_BY_APPLICATION_DOCUMENT_LIST_CONTRACT`.


## Phase 6 — Scanner Home Dashboard

Phase 6 replaces the Home placeholder with the authenticated Scanner Partner
operational dashboard backed by the injected `ScannerPartnerRepository`.
The dashboard consumes the Scanner contract abstractions for context, available
scanner branches/devices, daily redemption statistics and redemption history.

The current branch is intentionally prominent because scanner challenge and
redemption flows operate within scanner-session branch context. Branch changes
use the existing API-0192/API-0193 repository operations; the UI does not
invent a separate branch-selection endpoint.

The Home root retains the canonical Bader safe-area and fading-header behavior,
uses Bader surfaces/adaptive controls rather than generic dashboard cards, and
supports loading, loaded, no-selected-branch, unavailable-device,
permission-denied, server-error and empty-redemption presentation states.
Neither raw public IDs nor attestation/provider details are rendered.

The repository remains the deterministic mock implementation. Authentication
and production route guarding are still external contract gaps; Phase 6 does
not create a fake role picker or client-authoritative authorization layer.

## Phase 7 — QR Scanner and Verification Flow

Phase 7 implements the Scanner verification flow for API-0195 through API-0198
without combining verification with redemption. The flow resolves Scanner
Context first, requires an explicit current branch, creates a short-lived
scanner challenge, captures an opaque signed QR payload through the injected
`QrScannerAdapter`, verifies the QR, reads the canonical safe scan result, and
loads eligible offers only when the verified result is `eligible` and the
contract reports a positive `eligible_offer_count`.

No camera package was added because no production QR camera dependency has been
approved. `MockQrScannerAdapter` is deterministic and network-free; the adapter
boundary is replaceable without changing controllers or views. Optional
verification location is also behind `ScannerLocationProvider`; the default mock
returns no location, while tests cover the permission-granted path.

The client never sends `qr_type`. Signed QR payloads and scanner challenge
values remain transient controller state only, are redacted from diagnostic
string output, and are cleared after verification, when restarting the flow,
and when leaving the flow. Verification uses API-0196 only; no redemption
method is invoked by Phase 7.

## Phase 8 — Redemption Execution and Receipt

Phase 8 adds the explicit post-verification redemption workflow for API-0199 through API-0204: eligible offer selection, user confirmation, optional invoice amount, conditional static QR PIN, receipt, searchable/cursor-paginated history, details, daily statistics, and permission-gated reversal. `free` maps only to API-0199 and `points` only to API-0200; `percentage` and `fixed` remain explicitly unresolved. Reverse is protected by an injected `StepUpAuthService`; the default implementation blocks because the shared Step-Up contract has not been supplied. All runtime data remains mock-backed and no production network endpoint is connected to UI.

## Phase 9 — Partner Management

Phase 9 implements partner management for API-0209 through API-0213 and the
read-only Scanner Device experience from API-0194. The Partner tab now links to
a current-partner profile, protected profile-change request flow, partner
branches, scanner devices, and existing partner applications.

Protected partner fields are never edited directly. API-0210 is represented by
a dedicated request form using only `display_name`, `description`,
`contact_email`, `contact_phone`, `address_line`, optional existing
`logo_file_public_id`, and the required `reason`.

Branch creation uses an injected `PartnerLocationTaxonomySource`. The current
mock is deterministic and explicitly reports
`BLOCKED_BY_SHARED_PROVINCE_CITY_TAXONOMY_CONTRACT`; no production province or
city IDs are hardcoded into controllers. Branch editing retains an ETag and
sends it as `If-Match`; stale updates are surfaced as HTTP 412 and the UI offers
an explicit reload/review/retry flow without automatically overwriting newer
server data.

The Scanner contract requires `If-Match` for API-0213 and conditionally returns
an ETag after update, but API-0211 does not define an ETag-bearing branch fetch.
The app therefore exposes a mock-backed editable snapshot abstraction and marks
production acquisition of the initial branch ETag as
`BLOCKED_BY_BRANCH_ETAG_ACQUISITION_CONTRACT` rather than inventing an endpoint.

Scanner Devices are read-only and display only user-facing status/trust
information; no device-management endpoint or raw public identifier is exposed.

## Phase 10 — Partner Memberships

Phase 10 replaces the membership foundation placeholder with the read-only
partner membership view defined by API-0214. The screen lists the returned
member identity summary, `role_code`, membership `status`, and branch assignment
when present. It uses the canonical Bader page structure, integrated header,
form surfaces, empty/error states, RTL/LTR behavior, and adaptive controls.

API-0214 supports `q`, signed cursor pagination, `limit`, and a server-defined
`sort` allowlist. Phase 10 implements search plus cursor pagination. No sort UI
is exposed because the contract does not enumerate client-safe sort values.

The Scanner contract exposes membership listing only. The application therefore
does not implement invitation, member creation/removal, role changes, or member
suspension, and it does not render disabled fake controls for those operations.
The Partner tab links directly to this read-only management view.

`MockScannerPartnerRepository` remains deterministic and network-free. It now
provides multiple membership fixtures, including returned branch data and a
nullable branch case, so search and cursor pagination can be developed without
inventing production mutation endpoints.

## Phase 11 — Partner Offer Management

Phase 11 implements partner-owned offer management for API-0215 through
API-0219: searchable/cursor-paginated owned offers, management-oriented offer
details, draft creation, optimistic-concurrency draft editing, explicit
activation, and explicit disable with a required reason. No delete flow is
present because the Scanner contract does not define one.

Draft creation follows the contract shape exactly: localized `name` and
`description` require Arabic while English and German are optional, offer type
is limited to `free`, `percentage`, `fixed`, or `points`, and targeting uses
partner branches plus card-type public IDs. Branch options come from the
existing API-0211 repository path. Card-type taxonomy is behind the injected
`PartnerCardTypeTaxonomyRepository`; the deterministic mock reports
`BLOCKED_BY_SHARED_CARD_TYPE_TAXONOMY_CONTRACT` because no canonical production
card-type taxonomy endpoint is supplied by the Scanner contract.

API-0217 editing sends `If-Match`, retains the editable snapshot ETag, and
surfaces HTTP 412 as an explicit reload/review/retry state without automatic
resubmission. Because API-0215 does not document an item ETag and the supplied
Scanner contract has no single-offer GET endpoint, production acquisition of
the initial edit ETag remains `BLOCKED_BY_OFFER_ETAG_ACQUISITION_CONTRACT`;
the current editable-snapshot repository operation is a mock/application
abstraction, not an invented API endpoint.

API-0218 activation and API-0219 disable use idempotency keys. Disable collects
the required reason and enforces the contract maximum of 1000 characters.
Offer details are populated from the owned-offer list response rather than a
fabricated details endpoint. The contract's `OfferDetails` response also does
not return German localized fields or branch/card-type targeting assignments,
so the UI explicitly avoids pretending those values can be round-tripped from
server responses.

## Phase 12 — Settings and Product Family Parity

Phase 12 replaces the original Scanner settings placeholder with the finalized
Bader/Cards family settings language while keeping Scanner Partner's contract
surface intentionally smaller. Appearance supports System, Light and Dark via
the existing `ThemeService`; language uses the canonical Bader
`LanguageSelectorButton` for Arabic, English and German; and the app-information
section exposes only product identity and `AppConfig.appVersion`.

No logout/account mutation is exposed because the supplied Scanner/Partner API
contract does not define authentication/logout operations. No Scanner
notification settings or additional security settings are invented.

The root parity audit confirms canonical safe-area, page-background,
responsive-padding, RTL/LTR, Android/iOS, and dark/light behavior. Home and
Partner retain the finalized Bader fading headers. Partner's root title was
normalized for large-text parity with Home. Splash is non-scroll/transient and
Settings is a secondary adaptive-app-bar route, so fading headers are not
applicable to those screens.

## Phase 14 — Production API Integration

The runtime bootstrap now uses `ApiScannerPartnerRepository` over a production
HTTP transport instead of `MockScannerPartnerRepository`. Authentication tokens
are stored with `flutter_secure_storage` in separate scanner/partner/user realms;
scanner and partner login/refresh/logout contracts are represented without
placing HTTP calls in widgets/controllers.

The original API-0191..API-0219 Scanner/Partner matrix remains frozen at 29/29.
The later canonical backend handoff additionally resolves percentage/fixed
redemption through `/api/v1/scanner/redemptions/discount`; both types now route
to that command and require `invoice_amount`.

Production integration intentionally fails closed for unresolved external
contracts: Step-Up proof for API-0203, request-signature canonicalization for
`device.signed:sensitive`, current card-type taxonomy, file-upload authorization
for the required principal, user-principal authentication for API-0205..0208,
and initial ETag acquisition for API-0213/API-0217. See
`PHASE14_CONTRACT_RESOLUTION.md` and
`PHASE14_PRODUCTION_API_INTEGRATION_REPORT.md`.
