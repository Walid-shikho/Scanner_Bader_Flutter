import 'scanner_partner_models.dart';

typedef JsonMap = Map<String, dynamic>;

JsonMap _map(Object? value) => Map<String, dynamic>.from(value as Map);
List<dynamic> _list(Object? value) => List<dynamic>.from(value as List);
String _string(JsonMap json, String key) => json[key] as String;
String? _nullableString(JsonMap json, String key) => json[key] as String?;
int _int(JsonMap json, String key) => (json[key] as num).toInt();
int? _nullableInt(JsonMap json, String key) => (json[key] as num?)?.toInt();
double? _nullableDouble(JsonMap json, String key) =>
    (json[key] as num?)?.toDouble();
String? _asString(Object? value) => value == null ? null : value.toString();
JsonMap? _nullableMap(Object? value) => value is Map ? Map<String, dynamic>.from(value) : null;
String _localizedAr(Object? value, {String fallback = ''}) {
  if (value is String) return value;
  if (value is Map) {
    final map = Map<String, dynamic>.from(value);
    return (map['ar'] ?? map['en'] ?? map['de'] ?? fallback).toString();
  }
  return fallback;
}
String? _localizedEn(Object? value) {
  if (value is Map) {
    final map = Map<String, dynamic>.from(value);
    return (map['en'] ?? map['de'])?.toString();
  }
  return null;
}
DateTime _dateTime(JsonMap json, String key) => DateTime.parse(_string(json, key));
DateTime? _nullableDateTime(JsonMap json, String key) {
  final value = _nullableString(json, key);
  return value == null ? null : DateTime.parse(value);
}

abstract final class LocalizedMessageCodec {
  static LocalizedMessage fromJson(Object? value) {
    final json = _map(value);
    return LocalizedMessage(
      ar: _string(json, 'ar'),
      en: _nullableString(json, 'en'),
      de: _nullableString(json, 'de'),
    );
  }
}

extension LocalizedMessageJson on LocalizedMessage {
  JsonMap toJson() => <String, dynamic>{
        'ar': ar,
        if (en != null) 'en': en,
        if (de != null) 'de': de,
      };
}

abstract final class TaxonomyRefCodec {
  static TaxonomyRef fromJson(Object? value) {
    final json = _map(value);
    return TaxonomyRef(
      publicId: _string(json, 'public_id'),
      code: _string(json, 'code'),
      name: LocalizedMessageCodec.fromJson(json['name']),
    );
  }
}

abstract final class MediaRefCodec {
  static MediaRef fromJson(Object? value) {
    final json = _map(value);
    return MediaRef(
      publicId: _string(json, 'public_id'),
      url: _string(json, 'url'),
      mimeType: _string(json, 'mime_type'),
      width: _nullableInt(json, 'width'),
      height: _nullableInt(json, 'height'),
    );
  }
}

abstract final class LocationSummaryCodec {
  static LocationSummary fromJson(Object? value) {
    final json = _map(value);
    return LocationSummary(
      latitude: _nullableDouble(json, 'latitude'),
      longitude: _nullableDouble(json, 'longitude'),
      address: (json['address'] ?? json['address_line']) as String?,
    );
  }
}

abstract final class WorkingHoursEntryCodec {
  static WorkingHoursEntry fromJson(Object? value) {
    final json = _map(value);
    return WorkingHoursEntry(
      day: WorkingDay.values.firstWhere(
        (day) => day.wireValue == _string(json, 'day'),
      ),
      opensAt: _nullableString(json, 'opens_at'),
      closesAt: _nullableString(json, 'closes_at'),
      closed: json['closed'] as bool,
    );
  }
}

abstract final class PartnerBranchDataCodec {
  static PartnerBranchData fromJson(Object? value) {
    final json = _map(value);
    final name = json['name'];
    final location = _nullableMap(json['location']);
    final address = (location?['address'] ?? json['address']) as String?;
    final latitude = (location?['latitude'] ?? json['latitude'] as num?)?.toDouble();
    final longitude = (location?['longitude'] ?? json['longitude'] as num?)?.toDouble();
    final workingHours = json['working_hours'];
    return PartnerBranchData(
      publicId: (json['public_id'] ?? json['branch_public_id']) as String,
      code: (json['code'] ?? '').toString(),
      nameAr: json['name_ar'] as String? ?? _localizedAr(name),
      nameEn: json['name_en'] as String? ?? _localizedEn(name),
      phone: _nullableString(json, 'phone'),
      location: (address == null && latitude == null && longitude == null)
          ? null
          : LocationSummary(latitude: latitude, longitude: longitude, address: address),
      workingHours: workingHours is List
          ? List<dynamic>.from(workingHours).map(WorkingHoursEntryCodec.fromJson).toList(growable: false)
          : const <WorkingHoursEntry>[],
      status: _string(json, 'status'),
      createdAt: json['created_at'] is String ? DateTime.parse(json['created_at'] as String) : DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      updatedAt: json['updated_at'] is String ? DateTime.parse(json['updated_at'] as String) : DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }
}

abstract final class ScannerDeviceDataCodec {
  static ScannerDeviceData fromJson(Object? value) {
    final json = _map(value);
    return ScannerDeviceData(
      publicId: (json['public_id'] ?? json['scanner_device_public_id']) as String,
      status: _string(json, 'status'),
      trustLevel: (json['trust_level'] ?? (json['trusted'] == true ? 'trusted' : 'standard')).toString(),
      attestationProvider: _nullableString(json, 'attestation_provider'),
      attestationStatus: _nullableString(json, 'attestation_status'),
      registeredAt: _nullableDateTime(json, 'registered_at'),
      activatedAt: _nullableDateTime(json, 'activated_at'),
      revokedAt: _nullableDateTime(json, 'revoked_at'),
    );
  }
}

abstract final class ScannerContextDataCodec {
  static ScannerContextData fromJson(Object? value) {
    final json = _map(value);
    final partner = _map(json['partner']);
    final membership = _map(json['membership']);
    final branch = json['branch'] ?? json['selected_branch'];
    final device = json['scanner_device'];
    return ScannerContextData(
      partner: PartnerContextData(
        publicId: _string(partner, 'public_id'),
        displayName: (partner['display_name'] ?? partner['name']).toString(),
        status: _string(partner, 'status'),
      ),
      membership: MembershipContextData(
        publicId: _string(membership, 'public_id'),
        roleCode: (membership['role_code'] ?? membership['role'] ?? 'scanner').toString(),
        status: (membership['status'] ?? 'active').toString(),
      ),
      branch: branch == null ? null : PartnerBranchDataCodec.fromJson(branch),
      scannerDevice: device == null ? null : ScannerDeviceDataCodec.fromJson(device),
    );
  }
}

abstract final class SessionDetailCodec {
  static SessionDetail fromJson(Object? value) {
    final json = _map(value);
    return SessionDetail(
      publicId: _string(json, 'public_id'),
      status: _string(json, 'status'),
      startedAt: _dateTime(json, 'started_at'),
      lastSeenAt: _dateTime(json, 'last_seen_at'),
      expiresAt: _dateTime(json, 'expires_at'),
      revokedAt: _nullableDateTime(json, 'revoked_at'),
    );
  }
}

abstract final class ScannerChallengeDataCodec {
  static ScannerChallengeData fromJson(Object? value) {
    final json = _map(value);
    return ScannerChallengeData(
      challengePublicId: json['challenge_public_id'] as String?,
      challengeToken: (json['scanner_challenge'] ?? json['challenge_token']) as String,
      expiresAt: _dateTime(json, 'expires_at'),
    );
  }
}

ScanResultValue _scanResult(String value) {
  if (value == 'valid') return ScanResultValue.eligible;
  return ScanResultValue.values.firstWhere((item) => item.wireValue == value, orElse: () => ScanResultValue.invalid);
}

ScannerQrType _qrType(String value) => ScannerQrType.values.firstWhere(
      (item) => item.wireValue == value,
    );

abstract final class ScanVerificationDataCodec {
  static ScanVerificationData fromJson(Object? value) {
    final json = _map(value);
    final card = _map(json['card']);
    final cardholder = _nullableMap(json['cardholder']);
    final photo = cardholder?['photo'];
    final rawCardType = card['card_type'];
    final qrType = _qrType(_string(json, 'qr_type'));
    final scanResult = _scanResult(_string(json, 'scan_result'));
    return ScanVerificationData(
      scanPublicId: (json['scan_public_id'] ?? json['public_id']) as String,
      scanResult: scanResult,
      failureReasonCode: _nullableString(json, 'failure_reason_code'),
      card: VerifiedCardData(
        publicId: (card['public_id'] ?? card['card_public_id']) as String,
        status: _string(card, 'status'),
        cardType: rawCardType == null ? null : TaxonomyRefCodec.fromJson(rawCardType),
        cardTypePublicId: (card['card_type_public_id'] ?? _nullableMap(rawCardType)?['public_id']) as String?,
        expiresAt: _nullableDateTime(card, 'expires_at'),
      ),
      cardholder: cardholder == null ? null : CardholderSummary(
        displayName: (cardholder['display_name'] ?? cardholder['name'] ?? '').toString(),
        photo: photo == null ? null : MediaRefCodec.fromJson(photo),
      ),
      baderLinked: json['bader_linked'] as bool? ?? true,
      eligibleOfferCount: (json['eligible_offer_count'] as num?)?.toInt() ?? 0,
      verifiedAt: json['verified_at'] is String
          ? DateTime.parse(json['verified_at'] as String)
          : _dateTime(json, 'scanned_at'),
      qrType: qrType,
      pinRequired: json['pin_required'] as bool? ?? qrType == ScannerQrType.staticQr,
      sensitiveRedemptionAllowed: json['sensitive_redemption_allowed'] as bool? ?? scanResult == ScanResultValue.eligible,
    );
  }
}

abstract final class OfferDetailsCodec {
  static OfferDetails fromJson(Object? value) {
    final json = _map(value);
    final name = json['name'];
    final description = json['description'];
    return OfferDetails(
      publicId: (json['public_id'] ?? json['offer_public_id']) as String,
      discountType: (json['offer_type'] ?? json['discount_type']).toString(),
      titleAr: json['title_ar'] as String? ?? _localizedAr(name),
      titleEn: json['title_en'] as String? ?? _localizedEn(name),
      descriptionAr: json['description_ar'] as String? ?? (description == null ? null : _localizedAr(description)),
      descriptionEn: json['description_en'] as String? ?? _localizedEn(description),
      discountValue: (json['value'] ?? json['discount_value']) as num?,
      currencyCode: _nullableString(json, 'currency_code'),
      termsText: _nullableString(json, 'terms_text'),
      startsAt: json['starts_at'] is String ? DateTime.parse(json['starts_at'] as String) : DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      endsAt: json['ends_at'] is String ? DateTime.parse(json['ends_at'] as String) : DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      status: _string(json, 'status'),
      isExclusive: json['is_exclusive'] as bool? ?? false,
      pointsCost: _nullableInt(json, 'points_cost'),
      maxUsesPerCard: _nullableInt(json, 'max_uses_per_card'),
      maxUsesTotal: _nullableInt(json, 'max_uses_total'),
      maxUsesPerDay: _nullableInt(json, 'max_uses_per_day'),
      successfulUsageCount: (json['successful_usage_count'] as num?)?.toInt() ?? 0,
      approvedAt: _nullableDateTime(json, 'approved_at'),
      createdAt: json['created_at'] is String ? DateTime.parse(json['created_at'] as String) : DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      updatedAt: json['updated_at'] is String ? DateTime.parse(json['updated_at'] as String) : DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }
}

abstract final class RedemptionReceiptCodec {
  static RedemptionReceipt fromJson(Object? value) {
    final json = _map(value);
    return RedemptionReceipt(
      publicId: _string(json, 'public_id'),
      entryType: _string(json, 'entry_type'),
      result: _string(json, 'result'),
      failureReasonCode: _nullableString(json, 'failure_reason_code'),
      quantity: _int(json, 'quantity'),
      invoiceAmount: _asString(json['invoice_amount']),
      discountAmount: _asString(json['discount_amount']),
      currencyCode: _nullableString(json, 'currency_code'),
      pointsCostSnapshot: _nullableInt(json, 'points_cost_snapshot'),
      externalReference: _nullableString(json, 'external_reference'),
      reversalReason: _nullableString(json, 'reversal_reason'),
      occurredAt: _dateTime(json, 'occurred_at'),
    );
  }
}

abstract final class PartnerDailyStatisticsDataCodec {
  static PartnerDailyStatisticsData fromJson(Object? value) {
    final json = _map(value);
    return PartnerDailyStatisticsData(
      date: _string(json, 'date'),
      successfulRedemptions: _int(json, 'successful_redemptions'),
      failedRedemptions: _int(json, 'failed_redemptions'),
      totalDiscountAmount: _asString(json['total_discount_amount']) ?? '0.00',
      pointsSpent: _int(json, 'points_spent'),
    );
  }
}

abstract final class PartnerApplicationDataCodec {
  static PartnerApplicationData fromJson(Object? value) {
    final json = _map(value);
    final location = json['location'];
    final logo = json['logo'];
    return PartnerApplicationData(
      publicId: _string(json, 'public_id'),
      partnerType: TaxonomyRefCodec.fromJson(json['partner_type']),
      legalName: _string(json, 'legal_name'),
      activityDescription: _string(json, 'activity_description'),
      commercialRegisterPresent: json['commercial_register_present'] as bool,
      contactName: _string(json, 'contact_name'),
      contactPhoneMasked: _string(json, 'contact_phone_masked'),
      contactEmailMasked: _string(json, 'contact_email_masked'),
      location: location == null ? null : LocationSummaryCodec.fromJson(location),
      logo: logo == null ? null : MediaRefCodec.fromJson(logo),
      status: _string(json, 'status'),
      reviewedAt: _nullableDateTime(json, 'reviewed_at'),
      decisionReason: _nullableString(json, 'decision_reason'),
      approvedPartnerPublicId:
          _nullableString(json, 'approved_partner_public_id'),
      createdAt: _dateTime(json, 'created_at'),
      updatedAt: _dateTime(json, 'updated_at'),
    );
  }
}

abstract final class PartnerDetailCodec {
  static PartnerDetail fromJson(Object? value) {
    final json = _map(value);
    return PartnerDetail(
      publicId: (json['public_id'] ?? json['partner_public_id']) as String,
      legalName: (json['legal_name'] ?? json['name'] ?? '').toString(),
      displayName: (json['display_name'] ?? json['name'] ?? '').toString(),
      description: _nullableString(json, 'description'),
      businessRegistration: _nullableString(json, 'business_registration'),
      logoFilePublicId: _nullableString(json, 'logo_file_public_id'),
      contactEmail: _nullableString(json, 'contact_email'),
      contactPhone: _nullableString(json, 'contact_phone'),
      addressLine: (json['address_line'] ?? json['address']) as String?,
      latitude: _nullableDouble(json, 'latitude'),
      longitude: _nullableDouble(json, 'longitude'),
      status: _string(json, 'status'),
      approvedAt: json['approved_at'] is String ? DateTime.parse(json['approved_at'] as String) : (json['created_at'] is String ? DateTime.parse(json['created_at'] as String) : DateTime.fromMillisecondsSinceEpoch(0, isUtc: true)),
      createdAt: json['created_at'] is String ? DateTime.parse(json['created_at'] as String) : DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      updatedAt: json['updated_at'] is String ? DateTime.parse(json['updated_at'] as String) : (json['created_at'] is String ? DateTime.parse(json['created_at'] as String) : DateTime.fromMillisecondsSinceEpoch(0, isUtc: true)),
    );
  }
}

abstract final class PartnerMemberUserDataCodec {
  static PartnerMemberUserData fromJson(Object? value) {
    final json = _map(value);
    final avatar = json['avatar'];
    return PartnerMemberUserData(
      publicId: _string(json, 'public_id'),
      displayName: _string(json, 'display_name'),
      avatar: avatar == null ? null : MediaRefCodec.fromJson(avatar),
      verifiedBadge: json['verified_badge'] as bool,
    );
  }
}

abstract final class PartnerMembershipDataCodec {
  static PartnerMembershipData fromJson(Object? value) {
    final json = _map(value);
    final branch = json['branch'];
    final userRaw = _nullableMap(json['user']);
    final userPublicId = (userRaw?['public_id'] ?? json['user_public_id'] ?? '').toString();
    final branchId = json['branch_public_id'] as String?;
    return PartnerMembershipData(
      publicId: (json['public_id'] ?? json['membership_public_id']) as String,
      user: userRaw == null
          ? PartnerMemberUserData(publicId: userPublicId, displayName: userPublicId, verifiedBadge: false)
          : PartnerMemberUserDataCodec.fromJson(userRaw),
      branch: branch == null ? null : PartnerBranchDataCodec.fromJson(branch),
      roleCode: (json['role_code'] ?? json['role']).toString(),
      status: _string(json, 'status'),
      startedAt: _nullableDateTime(json, 'started_at'),
      endedAt: _nullableDateTime(json, 'ended_at'),
      createdAt: json['created_at'] is String ? DateTime.parse(json['created_at'] as String) : DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      updatedAt: json['updated_at'] is String ? DateTime.parse(json['updated_at'] as String) : DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }
}

extension ListQueryCodec on ListQuery {
  Map<String, String> toQueryParameters() => <String, String>{
        if (cursor != null) 'cursor': cursor!,
        'limit': limit.toString(),
        if (sort != null) 'sort': sort!,
        if (q != null) 'q': q!,
      };
}

extension SelectScannerBranchRequestCodec on SelectScannerBranchRequest {
  JsonMap toJson() => <String, dynamic>{'branch_public_id': branchPublicId};
}

extension ScannerChallengeRequestCodec on ScannerChallengeRequest {
  JsonMap toJson() => <String, dynamic>{'branch_public_id': branchPublicId};
}

extension VerifyQrRequestCodec on VerifyQrRequest {
  JsonMap toJson() => <String, dynamic>{
        'signed_qr_token': signedQrToken,
        'scanner_challenge': scannerChallenge.wireValue,
        'branch_public_id': branchPublicId,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      };
}

extension RedemptionRequestCodec on RedemptionRequest {
  JsonMap toJson() => <String, dynamic>{
        'scan_public_id': scanPublicId,
        'offer_public_id': offerPublicId,
        if (invoiceAmount != null) 'invoice_amount': invoiceAmount,
        'branch_public_id': branchPublicId,
        if (staticQrPin != null) 'static_qr_pin': staticQrPin,
      };
}

extension ReverseRedemptionRequestCodec on ReverseRedemptionRequest {
  JsonMap toJson() => <String, dynamic>{'reason': reason};
}

extension CreatePartnerApplicationRequestCodec on CreatePartnerApplicationRequest {
  JsonMap toJson() => <String, dynamic>{
        'partner_type_public_id': partnerTypePublicId,
        'name': name,
        if (businessRegistration != null)
          'business_registration': businessRegistration,
        'contact_name': contactName,
        'phone': phone,
        'email': email,
        'address': address,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        'description': description,
        if (logoFilePublicId != null) 'logo_file_public_id': logoFilePublicId,
      };
}

extension AddPartnerApplicationDocumentRequestCodec
    on AddPartnerApplicationDocumentRequest {
  JsonMap toJson() => <String, dynamic>{
        'file_public_id': filePublicId,
        'document_type': documentType,
      };
}

void _putPatch<T>(
  JsonMap target,
  String key,
  ContractPatchField<T> field, {
  Object? Function(T value)? encode,
}) {
  if (!field.isPresent) return;
  final value = field.value;
  target[key] = value == null ? null : (encode == null ? value : encode(value));
}

extension PartnerProfileChangesCodec on PartnerProfileChanges {
  JsonMap toJson() {
    final json = <String, dynamic>{};
    _putPatch(json, 'name', name);
    _putPatch(json, 'display_name', displayName);
    _putPatch(json, 'legal_name', legalName);
    _putPatch(json, 'business_registration', businessRegistration);
    _putPatch(json, 'latitude', latitude);
    _putPatch(json, 'longitude', longitude);
    return json;
  }
}

extension RequestPartnerProfileChangeRequestCodec
    on RequestPartnerProfileChangeRequest {
  JsonMap toJson() => <String, dynamic>{
        'changes': changes.toJson(),
        'reason': reason,
      };
}

extension CreatePartnerBranchRequestCodec on CreatePartnerBranchRequest {
  JsonMap toJson() => <String, dynamic>{
        'name': name,
        'address': address,
        'province_public_id': provincePublicId,
        'city_public_id': cityPublicId,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (phone != null) 'phone': phone,
      };
}

extension UpdatePartnerBranchRequestCodec on UpdatePartnerBranchRequest {
  JsonMap toJson() {
    final json = <String, dynamic>{};
    _putPatch(json, 'name', name);
    _putPatch(json, 'address', address);
    _putPatch(json, 'phone', phone);
    _putPatch(json, 'latitude', latitude);
    _putPatch(json, 'longitude', longitude);
    return json;
  }
}

extension CreatePartnerOfferRequestCodec on CreatePartnerOfferRequest {
  JsonMap toJson() => <String, dynamic>{
        'name': name.ar,
        'description': description.ar,
        'offer_type': offerType.wireValue,
        if (value != null) 'value': value,
        if (pointsCost != null) 'points_cost': pointsCost,
        if (startsAt != null) 'starts_at': startsAt!.toUtc().toIso8601String(),
        if (endsAt != null) 'ends_at': endsAt!.toUtc().toIso8601String(),
        'branch_public_ids': branchPublicIds,
        'card_type_public_ids': cardTypePublicIds,
      };
}

extension UpdatePartnerOfferRequestCodec on UpdatePartnerOfferRequest {
  JsonMap toJson() {
    final json = <String, dynamic>{
      if (name != null) 'name': name!.ar,
      if (description != null) 'description': description!.ar,
    };
    _putPatch(json, 'value', value);
    _putPatch<DateTime>(
      json,
      'ends_at',
      endsAt,
      encode: (value) => value.toUtc().toIso8601String(),
    );
    return json;
  }
}

extension DisablePartnerOfferRequestCodec on DisablePartnerOfferRequest {
  JsonMap toJson() => <String, dynamic>{'reason': reason};
}
