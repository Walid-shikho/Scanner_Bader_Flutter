import 'scanner_partner_model_codecs.dart';
import 'scanner_partner_models.dart';

class ApiMeta {
  const ApiMeta({
    required this.requestId,
    required this.timestamp,
    this.pagination,
  });

  factory ApiMeta.fromJson(Object? value) {
    final json = Map<String, dynamic>.from(value as Map);
    final rawPagination = json['pagination'];
    final pagination = rawPagination == null
        ? null
        : Map<String, dynamic>.from(rawPagination as Map);
    return ApiMeta(
      requestId: json['request_id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      pagination: pagination == null
          ? null
          : PaginationState(
              nextCursor: pagination['next_cursor'] as String?,
              previousCursor: pagination['previous_cursor'] as String?,
              hasMore: pagination['has_more'] as bool,
              limit: (pagination['limit'] as num).toInt(),
            ),
    );
  }

  final String requestId;
  final DateTime timestamp;
  final PaginationState? pagination;
}

class ApiEnvelope<T> {
  const ApiEnvelope({
    required this.success,
    required this.message,
    required this.data,
    required this.meta,
  });

  factory ApiEnvelope.fromJson(
    Object? value,
    T Function(Object? value) decodeData,
  ) {
    final json = Map<String, dynamic>.from(value as Map);
    return ApiEnvelope<T>(
      success: json['success'] as bool,
      message: LocalizedMessageCodec.fromJson(json['message']),
      data: decodeData(json['data']),
      meta: ApiMeta.fromJson(json['meta']),
    );
  }

  final bool success;
  final LocalizedMessage message;
  final T data;
  final ApiMeta meta;
}

class NoRequestBody {
  const NoRequestBody();
}

class ScannerSearchQuery {
  const ScannerSearchQuery({this.q});
  final String? q;

  Map<String, String> toQueryParameters() => <String, String>{
        if (q != null) 'q': q!,
      };
}

// API-0191
// GET /api/v1/scanner/context
typedef Api0191Request = NoRequestBody;
typedef Api0191Response = ApiEnvelope<ScannerContextData>;

// API-0192
// GET /api/v1/scanner/branches
typedef Api0192Request = ScannerSearchQuery;
typedef Api0192Response = ApiEnvelope<List<PartnerBranchData>>;

// API-0193
// POST /api/v1/scanner/context/branch
typedef Api0193Request = SelectScannerBranchRequest;
typedef Api0193Response = ApiEnvelope<SessionDetail>;

// API-0194
// GET /api/v1/scanner/devices
typedef Api0194Request = ScannerSearchQuery;
typedef Api0194Response = ApiEnvelope<List<ScannerDeviceData>>;

// API-0195
// POST /api/v1/scanner/qr/challenge
typedef Api0195Request = ScannerChallengeRequest;
typedef Api0195Response = ApiEnvelope<ScannerChallengeData>;

// API-0196
// POST /api/v1/scanner/qr/verify
typedef Api0196Request = VerifyQrRequest;
typedef Api0196Response = ApiEnvelope<ScanVerificationData>;

// API-0197
// GET /api/v1/scanner/scans/{scan_public_id}
typedef Api0197Request = NoRequestBody;
typedef Api0197Response = ApiEnvelope<ScanVerificationData>;

// API-0198
// GET /api/v1/scanner/scans/{scan_public_id}/eligible-offers
typedef Api0198Request = NoRequestBody;
typedef Api0198Response = ApiEnvelope<List<OfferDetails>>;

// API-0199
// POST /api/v1/scanner/redemptions/free
typedef Api0199Request = RedemptionRequest;
typedef Api0199Response = ApiEnvelope<RedemptionReceipt>;

// API-0200
// POST /api/v1/scanner/redemptions/points
typedef Api0200Request = RedemptionRequest;
typedef Api0200Response = ApiEnvelope<RedemptionReceipt>;

// API-0201
// GET /api/v1/scanner/redemptions
typedef Api0201Request = ListQuery;
typedef Api0201Response = ApiEnvelope<List<RedemptionReceipt>>;

// API-0202
// GET /api/v1/scanner/redemptions/{redemption_public_id}
typedef Api0202Request = NoRequestBody;
typedef Api0202Response = ApiEnvelope<RedemptionReceipt>;

// API-0203
// POST /api/v1/scanner/redemptions/{redemption_public_id}/reverse
typedef Api0203Request = ReverseRedemptionRequest;
typedef Api0203Response = ApiEnvelope<RedemptionReceipt>;

// API-0204
// GET /api/v1/scanner/statistics/daily
typedef Api0204Request = NoRequestBody;
typedef Api0204Response = ApiEnvelope<PartnerDailyStatisticsData>;

// API-0209
// GET /api/v1/partner/me
typedef Api0209Request = NoRequestBody;
typedef Api0209Response = ApiEnvelope<PartnerDetail>;

// API-0210
// POST /api/v1/partner/me/profile-change-requests
typedef Api0210Request = RequestPartnerProfileChangeRequest;
typedef Api0210Response = ApiEnvelope<PartnerDetail>;

// API-0211
// GET /api/v1/partner/me/branches
typedef Api0211Request = ListQuery;
typedef Api0211Response = ApiEnvelope<List<PartnerBranchData>>;

// API-0212
// POST /api/v1/partner/me/branches
typedef Api0212Request = CreatePartnerBranchRequest;
typedef Api0212Response = ApiEnvelope<PartnerBranchData>;

// API-0213
// PATCH /api/v1/partner/me/branches/{branch_public_id}
typedef Api0213Request = UpdatePartnerBranchRequest;
typedef Api0213Response = ApiEnvelope<PartnerBranchData>;

// API-0214
// GET /api/v1/partner/me/memberships
typedef Api0214Request = ListQuery;
typedef Api0214Response = ApiEnvelope<List<PartnerMembershipData>>;

// API-0215
// GET /api/v1/partner/me/offers
typedef Api0215Request = ListQuery;
typedef Api0215Response = ApiEnvelope<List<OfferDetails>>;

// API-0216
// POST /api/v1/partner/me/offers
typedef Api0216Request = CreatePartnerOfferRequest;
typedef Api0216Response = ApiEnvelope<OfferDetails>;

// API-0217
// PATCH /api/v1/partner/me/offers/{offer_public_id}
typedef Api0217Request = UpdatePartnerOfferRequest;
typedef Api0217Response = ApiEnvelope<OfferDetails>;

// API-0218
// POST /api/v1/partner/me/offers/{offer_public_id}/activate
typedef Api0218Request = NoRequestBody;
typedef Api0218Response = ApiEnvelope<OfferDetails>;

// API-0219
// POST /api/v1/partner/me/offers/{offer_public_id}/disable
typedef Api0219Request = DisablePartnerOfferRequest;
typedef Api0219Response = ApiEnvelope<OfferDetails>;

abstract final class ScannerPartnerEndpointDecoders {
  static Api0191Response api0191(Object? json) => ApiEnvelope.fromJson(
        json,
        ScannerContextDataCodec.fromJson,
      );

  static Api0192Response api0192(Object? json) => ApiEnvelope.fromJson(
        json,
        (value) => List<dynamic>.from(value as List)
            .map(PartnerBranchDataCodec.fromJson)
            .toList(growable: false),
      );

  static Api0193Response api0193(Object? json) => ApiEnvelope.fromJson(
        json,
        SessionDetailCodec.fromJson,
      );

  static Api0194Response api0194(Object? json) => ApiEnvelope.fromJson(
        json,
        (value) => List<dynamic>.from(value as List)
            .map(ScannerDeviceDataCodec.fromJson)
            .toList(growable: false),
      );

  static Api0195Response api0195(Object? json) => ApiEnvelope.fromJson(
        json,
        ScannerChallengeDataCodec.fromJson,
      );

  static Api0196Response api0196(Object? json) => ApiEnvelope.fromJson(
        json,
        ScanVerificationDataCodec.fromJson,
      );

  static Api0197Response api0197(Object? json) => ApiEnvelope.fromJson(
        json,
        ScanVerificationDataCodec.fromJson,
      );

  static Api0198Response api0198(Object? json) => ApiEnvelope.fromJson(
        json,
        (value) => List<dynamic>.from(value as List)
            .map(OfferDetailsCodec.fromJson)
            .toList(growable: false),
      );

  static Api0199Response api0199(Object? json) => ApiEnvelope.fromJson(
        json,
        RedemptionReceiptCodec.fromJson,
      );

  static Api0200Response api0200(Object? json) => ApiEnvelope.fromJson(
        json,
        RedemptionReceiptCodec.fromJson,
      );

  static Api0201Response api0201(Object? json) => ApiEnvelope.fromJson(
        json,
        (value) => List<dynamic>.from(value as List)
            .map(RedemptionReceiptCodec.fromJson)
            .toList(growable: false),
      );

  static Api0202Response api0202(Object? json) => ApiEnvelope.fromJson(
        json,
        RedemptionReceiptCodec.fromJson,
      );

  static Api0203Response api0203(Object? json) => ApiEnvelope.fromJson(
        json,
        RedemptionReceiptCodec.fromJson,
      );

  static Api0204Response api0204(Object? json) => ApiEnvelope.fromJson(
        json,
        PartnerDailyStatisticsDataCodec.fromJson,
      );

  static Api0209Response api0209(Object? json) => ApiEnvelope.fromJson(
        json,
        PartnerDetailCodec.fromJson,
      );

  static Api0210Response api0210(Object? json) => ApiEnvelope.fromJson(
        json,
        PartnerDetailCodec.fromJson,
      );

  static Api0211Response api0211(Object? json) => ApiEnvelope.fromJson(
        json,
        (value) => List<dynamic>.from(value as List)
            .map(PartnerBranchDataCodec.fromJson)
            .toList(growable: false),
      );

  static Api0212Response api0212(Object? json) => ApiEnvelope.fromJson(
        json,
        PartnerBranchDataCodec.fromJson,
      );

  static Api0213Response api0213(Object? json) => ApiEnvelope.fromJson(
        json,
        PartnerBranchDataCodec.fromJson,
      );

  static Api0214Response api0214(Object? json) => ApiEnvelope.fromJson(
        json,
        (value) => List<dynamic>.from(value as List)
            .map(PartnerMembershipDataCodec.fromJson)
            .toList(growable: false),
      );

  static Api0215Response api0215(Object? json) => ApiEnvelope.fromJson(
        json,
        (value) => List<dynamic>.from(value as List)
            .map(OfferDetailsCodec.fromJson)
            .toList(growable: false),
      );

  static Api0216Response api0216(Object? json) => ApiEnvelope.fromJson(
        json,
        OfferDetailsCodec.fromJson,
      );

  static Api0217Response api0217(Object? json) => ApiEnvelope.fromJson(
        json,
        OfferDetailsCodec.fromJson,
      );

  static Api0218Response api0218(Object? json) => ApiEnvelope.fromJson(
        json,
        OfferDetailsCodec.fromJson,
      );

  static Api0219Response api0219(Object? json) => ApiEnvelope.fromJson(
        json,
        OfferDetailsCodec.fromJson,
      );
}
