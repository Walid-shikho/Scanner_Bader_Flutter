/// UI/domain models adapted to the final Partner/Scanner Flutter handoff.
/// Transport request DTOs remain endpoint-specific and must not serialize these
/// response/domain models back to the backend.


class ContractPatchField<T> {
  const ContractPatchField.absent()
      : isPresent = false,
        value = null;

  const ContractPatchField.present(this.value) : isPresent = true;

  final bool isPresent;
  final T? value;
}

class LocalizedMessage {
  const LocalizedMessage({
    required this.ar,
    this.en,
    this.de,
  });

  final String ar;
  final String? en;
  final String? de;
}

class TaxonomyRef {
  const TaxonomyRef({
    required this.publicId,
    required this.code,
    required this.name,
  });

  final String publicId;
  final String code;
  final LocalizedMessage name;
}

class MediaRef {
  const MediaRef({
    required this.publicId,
    required this.url,
    required this.mimeType,
    this.width,
    this.height,
  });

  final String publicId;
  final String url;
  final String mimeType;
  final int? width;
  final int? height;
}

class LocationSummary {
  const LocationSummary({
    this.latitude,
    this.longitude,
    this.address,
  });

  final double? latitude;
  final double? longitude;
  final String? address;
}

enum WorkingDay {
  mon('mon'),
  tue('tue'),
  wed('wed'),
  thu('thu'),
  fri('fri'),
  sat('sat'),
  sun('sun');

  const WorkingDay(this.wireValue);
  final String wireValue;
}

class WorkingHoursEntry {
  const WorkingHoursEntry({
    required this.day,
    required this.closed,
    this.opensAt,
    this.closesAt,
  });

  final WorkingDay day;
  final String? opensAt;
  final String? closesAt;
  final bool closed;
}

class PartnerBranchData {
  const PartnerBranchData({
    required this.publicId,
    required this.code,
    required this.nameAr,
    required this.workingHours,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.nameEn,
    this.phone,
    this.location,
  });

  final String publicId;
  final String code;
  final String nameAr;
  final String? nameEn;
  final String? phone;
  final LocationSummary? location;
  final List<WorkingHoursEntry> workingHours;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class ScannerDeviceData {
  const ScannerDeviceData({
    required this.publicId,
    required this.status,
    required this.trustLevel,
    this.attestationStatus,
    this.registeredAt,
    this.attestationProvider,
    this.activatedAt,
    this.revokedAt,
  });

  final String publicId;
  final String status;
  final String trustLevel;
  final String? attestationProvider;
  final String? attestationStatus;
  final DateTime? registeredAt;
  final DateTime? activatedAt;
  final DateTime? revokedAt;
}

class PartnerContextData {
  const PartnerContextData({
    required this.publicId,
    required this.displayName,
    required this.status,
  });

  final String publicId;
  final String displayName;
  final String status;
}

class MembershipContextData {
  const MembershipContextData({
    required this.publicId,
    required this.roleCode,
    required this.status,
  });

  final String publicId;
  final String roleCode;
  final String status;
}

class ScannerContextData {
  const ScannerContextData({
    required this.partner,
    required this.membership,
    this.branch,
    this.scannerDevice,
  });

  final PartnerContextData partner;
  final MembershipContextData membership;
  final PartnerBranchData? branch;
  final ScannerDeviceData? scannerDevice;
}

class SessionDetail {
  const SessionDetail({
    required this.publicId,
    required this.status,
    required this.startedAt,
    required this.lastSeenAt,
    required this.expiresAt,
    this.revokedAt,
  });

  final String publicId;
  final String status;
  final DateTime startedAt;
  final DateTime lastSeenAt;
  final DateTime expiresAt;
  final DateTime? revokedAt;
}

class ScannerChallengeData {
  const ScannerChallengeData({
    this.challengePublicId,
    required this.challengeToken,
    required this.expiresAt,
  });

  final String? challengePublicId;
  final String challengeToken;
  final DateTime expiresAt;

  @override
  String toString() =>
      'ScannerChallengeData(challengePublicId: $challengePublicId, challengeToken: <redacted>, expiresAt: $expiresAt)';
}

enum ScanResultValue {
  eligible('eligible'),
  ineligible('ineligible'),
  expired('expired'),
  replayed('replayed'),
  invalid('invalid');

  const ScanResultValue(this.wireValue);
  final String wireValue;
}

enum ScannerQrType {
  dynamicQr('dynamic'),
  staticQr('static');

  const ScannerQrType(this.wireValue);
  final String wireValue;
}

class VerifiedCardData {
  const VerifiedCardData({
    required this.publicId,
    required this.status,
    this.cardType,
    this.cardTypePublicId,
    this.expiresAt,
  });

  final String publicId;
  final String status;
  final TaxonomyRef? cardType;
  final String? cardTypePublicId;
  final DateTime? expiresAt;
}

class CardholderSummary {
  const CardholderSummary({
    required this.displayName,
    this.photo,
  });

  final String displayName;
  final MediaRef? photo;
}

class ScanVerificationData {
  const ScanVerificationData({
    required this.scanPublicId,
    required this.scanResult,
    required this.card,
    this.cardholder,
    required this.baderLinked,
    required this.eligibleOfferCount,
    required this.verifiedAt,
    required this.qrType,
    required this.pinRequired,
    required this.sensitiveRedemptionAllowed,
    this.failureReasonCode,
  });

  final String scanPublicId;
  final ScanResultValue scanResult;
  final String? failureReasonCode;
  final VerifiedCardData card;
  final CardholderSummary? cardholder;
  final bool baderLinked;
  final int eligibleOfferCount;
  final DateTime verifiedAt;
  final ScannerQrType qrType;
  final bool pinRequired;
  final bool sensitiveRedemptionAllowed;
}

class OfferDetails {
  const OfferDetails({
    required this.publicId,
    required this.discountType,
    required this.titleAr,
    required this.startsAt,
    required this.endsAt,
    required this.status,
    required this.isExclusive,
    required this.successfulUsageCount,
    required this.createdAt,
    required this.updatedAt,
    this.titleEn,
    this.descriptionAr,
    this.descriptionEn,
    this.discountValue,
    this.currencyCode,
    this.termsText,
    this.pointsCost,
    this.maxUsesPerCard,
    this.maxUsesTotal,
    this.maxUsesPerDay,
    this.approvedAt,
  });

  final String publicId;
  final String discountType;
  final String titleAr;
  final String? titleEn;
  final String? descriptionAr;
  final String? descriptionEn;
  final num? discountValue;
  final String? currencyCode;
  final String? termsText;
  final DateTime startsAt;
  final DateTime endsAt;
  final String status;
  final bool isExclusive;
  final int? pointsCost;
  final int? maxUsesPerCard;
  final int? maxUsesTotal;
  final int? maxUsesPerDay;
  final int successfulUsageCount;
  final DateTime? approvedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class RedemptionReceipt {
  const RedemptionReceipt({
    required this.publicId,
    required this.entryType,
    required this.result,
    required this.quantity,
    required this.occurredAt,
    this.failureReasonCode,
    this.invoiceAmount,
    this.discountAmount,
    this.currencyCode,
    this.pointsCostSnapshot,
    this.externalReference,
    this.reversalReason,
  });

  final String publicId;
  final String entryType;
  final String result;
  final String? failureReasonCode;
  final int quantity;
  final String? invoiceAmount;
  final String? discountAmount;
  final String? currencyCode;
  final int? pointsCostSnapshot;
  final String? externalReference;
  final String? reversalReason;
  final DateTime occurredAt;
}

class PartnerDailyStatisticsData {
  const PartnerDailyStatisticsData({
    required this.date,
    required this.successfulRedemptions,
    required this.failedRedemptions,
    required this.totalDiscountAmount,
    required this.pointsSpent,
  });

  final String date;
  final int successfulRedemptions;
  final int failedRedemptions;
  final String totalDiscountAmount;
  final int pointsSpent;
}

class PartnerApplicationData {
  const PartnerApplicationData({
    required this.publicId,
    required this.partnerType,
    required this.legalName,
    required this.activityDescription,
    required this.commercialRegisterPresent,
    required this.contactName,
    required this.contactPhoneMasked,
    required this.contactEmailMasked,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.location,
    this.logo,
    this.reviewedAt,
    this.decisionReason,
    this.approvedPartnerPublicId,
  });

  final String publicId;
  final TaxonomyRef partnerType;
  final String legalName;
  final String activityDescription;
  final bool commercialRegisterPresent;
  final String contactName;
  final String contactPhoneMasked;
  final String contactEmailMasked;
  final LocationSummary? location;
  final MediaRef? logo;
  final String status;
  final DateTime? reviewedAt;
  final String? decisionReason;
  final String? approvedPartnerPublicId;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class PartnerDetail {
  const PartnerDetail({
    required this.publicId,
    required this.legalName,
    required this.displayName,
    required this.status,
    required this.approvedAt,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.businessRegistration,
    this.logoFilePublicId,
    this.contactEmail,
    this.contactPhone,
    this.addressLine,
    this.latitude,
    this.longitude,
  });

  final String publicId;
  final String legalName;
  final String displayName;
  final String? description;
  final String? businessRegistration;
  final String? logoFilePublicId;
  final String? contactEmail;
  final String? contactPhone;
  final String? addressLine;
  final double? latitude;
  final double? longitude;
  final String status;
  final DateTime approvedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class PartnerMemberUserData {
  const PartnerMemberUserData({
    required this.publicId,
    required this.displayName,
    required this.verifiedBadge,
    this.avatar,
  });

  final String publicId;
  final String displayName;
  final MediaRef? avatar;
  final bool verifiedBadge;
}

class PartnerMembershipData {
  const PartnerMembershipData({
    required this.publicId,
    required this.user,
    required this.roleCode,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.branch,
    this.startedAt,
    this.endedAt,
  });

  final String publicId;
  final PartnerMemberUserData user;
  final PartnerBranchData? branch;
  final String roleCode;
  final String status;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class PaginationState {
  const PaginationState({
    this.nextCursor,
    this.previousCursor,
    required this.hasMore,
    required this.limit,
  });

  final String? nextCursor;
  final String? previousCursor;
  final bool hasMore;
  final int limit;
}

class PagedResult<T> {
  const PagedResult({
    required this.items,
    required this.pagination,
  });

  final List<T> items;
  final PaginationState pagination;
}

class VersionedResource<T> {
  const VersionedResource({
    required this.data,
    required this.etag,
  });

  final T data;
  final String etag;
}

class ListQuery {
  const ListQuery({
    this.cursor,
    this.limit = 20,
    this.sort,
    this.q,
  });

  final String? cursor;
  final int limit;
  final String? sort;
  final String? q;
}

class SelectScannerBranchRequest {
  const SelectScannerBranchRequest({required this.branchPublicId});
  final String branchPublicId;
}

class ScannerChallengeRequest {
  const ScannerChallengeRequest({required this.branchPublicId});
  final String branchPublicId;
}

sealed class ScannerChallengeValue {
  const ScannerChallengeValue();
  Object? get wireValue;

  @override
  String toString() => '<redacted-scanner-challenge>';
}

final class ScannerChallengeText extends ScannerChallengeValue {
  const ScannerChallengeText(this.value);
  final String value;
  @override
  String get wireValue => value;
}

final class ScannerChallengeNumber extends ScannerChallengeValue {
  const ScannerChallengeNumber(this.value);
  final num value;
  @override
  num get wireValue => value;
}

final class ScannerChallengeBoolean extends ScannerChallengeValue {
  const ScannerChallengeBoolean(this.value);
  final bool value;
  @override
  bool get wireValue => value;
}

final class ScannerChallengeNull extends ScannerChallengeValue {
  const ScannerChallengeNull();
  @override
  Null get wireValue => null;
}

class VerifyQrRequest {
  const VerifyQrRequest({
    required this.signedQrToken,
    required this.scannerChallenge,
    required this.branchPublicId,
    this.latitude,
    this.longitude,
  });

  final String signedQrToken;
  final ScannerChallengeValue scannerChallenge;
  final String branchPublicId;
  final double? latitude;
  final double? longitude;

  @override
  String toString() =>
      'VerifyQrRequest(signedQrToken: <redacted>, scannerChallenge: <redacted>, branchPublicId: $branchPublicId)';
}

class RedemptionRequest {
  const RedemptionRequest({
    required this.scanPublicId,
    required this.offerPublicId,
    required this.branchPublicId,
    this.invoiceAmount,
    this.staticQrPin,
  });

  final String scanPublicId;
  final String offerPublicId;
  final String? invoiceAmount;
  final String branchPublicId;
  final String? staticQrPin;

  @override
  String toString() =>
      'RedemptionRequest(scanPublicId: $scanPublicId, offerPublicId: $offerPublicId, branchPublicId: $branchPublicId, staticQrPin: <redacted>)';
}

class ReverseRedemptionRequest {
  const ReverseRedemptionRequest({required this.reason});
  final String reason;
}

class CreatePartnerApplicationRequest {
  const CreatePartnerApplicationRequest({
    required this.partnerTypePublicId,
    required this.name,
    required this.contactName,
    required this.phone,
    required this.email,
    required this.address,
    required this.description,
    this.businessRegistration,
    this.latitude,
    this.longitude,
    this.logoFilePublicId,
  });

  final String partnerTypePublicId;
  final String name;
  final String? businessRegistration;
  final String contactName;
  final String phone;
  final String email;
  final String address;
  final double? latitude;
  final double? longitude;
  final String description;
  final String? logoFilePublicId;
}

class AddPartnerApplicationDocumentRequest {
  const AddPartnerApplicationDocumentRequest({
    required this.filePublicId,
    required this.documentType,
  });

  final String filePublicId;
  final String documentType;
}

class PartnerProfileChanges {
  const PartnerProfileChanges({
    this.name = const ContractPatchField<String>.absent(),
    this.displayName = const ContractPatchField<String>.absent(),
    this.legalName = const ContractPatchField<String>.absent(),
    this.businessRegistration = const ContractPatchField<String>.absent(),
    this.latitude = const ContractPatchField<double>.absent(),
    this.longitude = const ContractPatchField<double>.absent(),
  });

  final ContractPatchField<String> name;
  final ContractPatchField<String> displayName;
  final ContractPatchField<String> legalName;
  final ContractPatchField<String> businessRegistration;
  final ContractPatchField<double> latitude;
  final ContractPatchField<double> longitude;
}

class RequestPartnerProfileChangeRequest {
  const RequestPartnerProfileChangeRequest({
    required this.changes,
    required this.reason,
  });

  final PartnerProfileChanges changes;
  final String reason;
}

class CreatePartnerBranchRequest {
  const CreatePartnerBranchRequest({
    required this.name,
    required this.address,
    required this.provincePublicId,
    required this.cityPublicId,
    this.latitude,
    this.longitude,
    this.phone,
  });

  final String name;
  final String address;
  final String provincePublicId;
  final String cityPublicId;
  final double? latitude;
  final double? longitude;
  final String? phone;
}

class UpdatePartnerBranchRequest {
  const UpdatePartnerBranchRequest({
    this.name = const ContractPatchField<String>.absent(),
    this.address = const ContractPatchField<String>.absent(),
    this.phone = const ContractPatchField<String>.absent(),
    this.latitude = const ContractPatchField<double>.absent(),
    this.longitude = const ContractPatchField<double>.absent(),
  });

  final ContractPatchField<String> name;
  final ContractPatchField<String> address;
  final ContractPatchField<String> phone;
  final ContractPatchField<double> latitude;
  final ContractPatchField<double> longitude;
}

enum PartnerOfferType {
  free('free'),
  percentage('percentage'),
  fixed('fixed'),
  points('points');

  const PartnerOfferType(this.wireValue);
  final String wireValue;
}

class CreatePartnerOfferRequest {
  const CreatePartnerOfferRequest({
    required this.name,
    required this.description,
    required this.offerType,
    required this.branchPublicIds,
    required this.cardTypePublicIds,
    this.value,
    this.pointsCost,
    this.startsAt,
    this.endsAt,
  });

  final LocalizedMessage name;
  final LocalizedMessage description;
  final PartnerOfferType offerType;
  final String? value;
  final int? pointsCost;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final List<String> branchPublicIds;
  final List<String> cardTypePublicIds;
}

class UpdatePartnerOfferRequest {
  const UpdatePartnerOfferRequest({
    this.name,
    this.description,
    this.value = const ContractPatchField<String>.absent(),
    this.pointsCost = const ContractPatchField<int>.absent(),
    this.startsAt = const ContractPatchField<DateTime>.absent(),
    this.endsAt = const ContractPatchField<DateTime>.absent(),
  });

  final LocalizedMessage? name;
  final LocalizedMessage? description;
  final ContractPatchField<String> value;
  final ContractPatchField<int> pointsCost;
  final ContractPatchField<DateTime> startsAt;
  final ContractPatchField<DateTime> endsAt;
}

class DisablePartnerOfferRequest {
  const DisablePartnerOfferRequest({required this.reason});
  final String reason;
}
