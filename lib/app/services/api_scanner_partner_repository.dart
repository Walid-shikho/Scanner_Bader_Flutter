import '../../core/config/app_config.dart';
import '../../core/network/api_error.dart';
import '../../core/network/api_headers.dart';
import '../../core/network/api_response.dart';
import '../../core/network/api_transport.dart';
import '../../core/network/request_id_factory.dart';
import '../models/scanner_partner_endpoint_models.dart';
import '../models/scanner_partner_model_codecs.dart';
import '../models/scanner_partner_models.dart';
import '../network/scanner_partner_endpoints.dart';
import 'production_security_services.dart';
import 'production_session_store.dart';
import 'scanner_auth_session_gateway.dart';
import 'scanner_partner_repository.dart';

/// Production implementation used by the final 64-endpoint Partner/Scanner contract.
///
/// It preserves the repository contract consumed by existing GetX controllers.
/// Views/controllers never depend on the HTTP implementation directly.
class ApiScannerPartnerRepository implements ScannerPartnerRepository {
  ApiScannerPartnerRepository({
    required this.transport,
    required this.sessionStore,
    required this.requestIds,
    required this.acceptLanguage,
    required this.sensitiveSecurity,
    required this.authGateway,
  });

  final ApiTransport transport;
  final ProductionSessionStore sessionStore;
  final RequestIdFactory requestIds;
  final String Function() acceptLanguage;
  final SensitiveRequestSecurityProvider sensitiveSecurity;
  final ScannerAuthSessionGateway authGateway;

  static const _json = 'application/json';

  ProductionSessionRealm _realmForPath(String path) {
    if (path.startsWith('/api/v1/scanner/')) {
      return ProductionSessionRealm.scanner;
    }
    return ProductionSessionRealm.partner;
  }

  Future<Map<String, String>> _headers({
    required String method,
    required String path,
    Object? body,
    String? idempotencyKey,
    String? ifMatch,
    bool sensitive = false,
    bool requireScannerDevice = false,
  }) async {
    final session = await sessionStore.read(_realmForPath(path));
    final token = session.accessToken;
    if (token == null || token.isEmpty) {
      throw StateError('Authenticated ${session.realm.name} session is required.');
    }
    final devicePublicId =
        session.scannerDevicePublicId ?? session.devicePublicId;
    if (requireScannerDevice &&
        (devicePublicId == null || devicePublicId.isEmpty)) {
      throw StateError('Registered scanner device context is required.');
    }

    final endpointHeaders = sensitive
        ? await sensitiveSecurity.headersFor(
            method: method,
            path: path,
            body: body,
          )
        : const <String, String>{};

    return ApiRequestHeaderContext(
      authorizationToken: token,
      acceptLanguage: acceptLanguage(),
      requestId: requestIds.create(),
      devicePublicId: devicePublicId,
      idempotencyKey: idempotencyKey,
      ifMatch: ifMatch,
      contentType: method == 'GET' ? null : _json,
      endpointHeaders: endpointHeaders,
    ).build();
  }

  Future<ApiResponse<T>> _send<T>({
    required String method,
    required String path,
    required T Function(Object?) decoder,
    Map<String, String> query = const <String, String>{},
    Object? body,
    String? idempotencyKey,
    String? ifMatch,
    bool sensitive = false,
    bool requireScannerDevice = false,
    bool allowRefreshRetry = true,
  }) async {
    Future<ApiResponse<T>> attempt() async => transport.send<T>(
          ApiRequest(
            method: method,
            path: path,
            queryParameters: query,
            headers: await _headers(
              method: method,
              path: path,
              body: body,
              idempotencyKey: idempotencyKey,
              ifMatch: ifMatch,
              sensitive: sensitive,
              requireScannerDevice: requireScannerDevice,
            ),
            body: body,
          ),
          decodeData: decoder,
        );

    try {
      return await attempt();
    } on NormalizedApiError catch (error) {
      if (error.statusCode != 401 || !allowRefreshRetry) rethrow;
      await authGateway.refresh(_realmForPath(path));
      return attempt();
    }
  }

  PaginationState _pagination(ApiMeta meta, {int fallbackLimit = 20}) =>
      meta.pagination ??
      PaginationState(hasMore: false, limit: fallbackLimit);

  @override
  Future<ScannerContextData> getScannerContext() async {
    final response = await _send<Api0191Response>(
      method: 'GET',
      path: ScannerPartnerEndpoints.scannerContext,
      decoder: ScannerPartnerEndpointDecoders.api0191,
      requireScannerDevice: true,
    );
    return response.data.data;
  }

  @override
  Future<List<PartnerBranchData>> getScannerBranches({String? query}) async {
    final response = await _send<Api0192Response>(
      method: 'GET',
      path: ScannerPartnerEndpoints.scannerBranches,
      query: <String, String>{if (query != null && query.isNotEmpty) 'q': query},
      decoder: ScannerPartnerEndpointDecoders.api0192,
      requireScannerDevice: true,
    );
    return response.data.data;
  }

  @override
  Future<SessionDetail> selectScannerBranch(
    SelectScannerBranchRequest request,
  ) async {
    final body = request.toJson();
    final response = await _send<Api0193Response>(
      method: 'POST',
      path: ScannerPartnerEndpoints.scannerContextBranch,
      body: body,
      decoder: ScannerPartnerEndpointDecoders.api0193,
      sensitive: true,
      requireScannerDevice: true,
    );
    return response.data.data;
  }

  @override
  Future<List<ScannerDeviceData>> getScannerDevices({String? query}) async {
    final response = await _send<Api0194Response>(
      method: 'GET',
      path: ScannerPartnerEndpoints.scannerDevices,
      query: <String, String>{if (query != null && query.isNotEmpty) 'q': query},
      decoder: ScannerPartnerEndpointDecoders.api0194,
      requireScannerDevice: true,
    );
    return response.data.data;
  }

  @override
  Future<ScannerChallengeData> createQrChallenge(
    ScannerChallengeRequest request,
  ) async {
    final response = await _send<Api0195Response>(
      method: 'POST',
      path: ScannerPartnerEndpoints.scannerQrChallenge,
      body: request.toJson(),
      decoder: ScannerPartnerEndpointDecoders.api0195,
      requireScannerDevice: true,
    );
    return response.data.data;
  }

  @override
  Future<ScanVerificationData> verifyQr(VerifyQrRequest request) async {
    final body = request.toJson();
    final response = await _send<Api0196Response>(
      method: 'POST',
      path: ScannerPartnerEndpoints.scannerQrVerify,
      body: body,
      decoder: ScannerPartnerEndpointDecoders.api0196,
      sensitive: true,
      requireScannerDevice: true,
    );
    return response.data.data;
  }

  @override
  Future<ScanVerificationData> getScanResult(String scanPublicId) async {
    final response = await _send<Api0197Response>(
      method: 'GET',
      path: ScannerPartnerEndpoints.scannerScan(scanPublicId),
      decoder: ScannerPartnerEndpointDecoders.api0197,
      requireScannerDevice: true,
    );
    return response.data.data;
  }

  @override
  Future<List<OfferDetails>> getEligibleOffers(String scanPublicId) async {
    final response = await _send<Api0198Response>(
      method: 'GET',
      path: ScannerPartnerEndpoints.scannerEligibleOffers(scanPublicId),
      decoder: ScannerPartnerEndpointDecoders.api0198,
      requireScannerDevice: true,
    );
    return response.data.data;
  }

  @override
  Future<RedemptionReceipt> executeFreeRedemption(
    RedemptionRequest request, {
    required String idempotencyKey,
  }) async {
    final body = request.toJson();
    final response = await _send<Api0199Response>(
      method: 'POST',
      path: ScannerPartnerEndpoints.scannerRedemptionsFree,
      body: body,
      idempotencyKey: idempotencyKey,
      decoder: ScannerPartnerEndpointDecoders.api0199,
      sensitive: true,
      requireScannerDevice: true,
    );
    return response.data.data;
  }

  @override
  Future<RedemptionReceipt> executePointsRedemption(
    RedemptionRequest request, {
    required String idempotencyKey,
  }) async {
    final body = request.toJson();
    final response = await _send<Api0200Response>(
      method: 'POST',
      path: ScannerPartnerEndpoints.scannerRedemptionsPoints,
      body: body,
      idempotencyKey: idempotencyKey,
      decoder: ScannerPartnerEndpointDecoders.api0200,
      sensitive: true,
      requireScannerDevice: true,
    );
    return response.data.data;
  }

  @override
  Future<RedemptionReceipt> executeDiscountRedemption(
    RedemptionRequest request, {
    required String idempotencyKey,
  }) async {
    if (request.invoiceAmount == null || request.invoiceAmount!.isEmpty) {
      throw ArgumentError('invoice_amount is required for discount redemption.');
    }
    final body = request.toJson();
    final response = await _send<ApiEnvelope<RedemptionReceipt>>(
      method: 'POST',
      path: ScannerPartnerEndpoints.scannerRedemptionsDiscount,
      body: body,
      idempotencyKey: idempotencyKey,
      decoder: (json) => ApiEnvelope.fromJson(
        json,
        RedemptionReceiptCodec.fromJson,
      ),
      sensitive: true,
      requireScannerDevice: true,
    );
    return response.data.data;
  }

  @override
  Future<PagedResult<RedemptionReceipt>> getRedemptions({
    ListQuery query = const ListQuery(),
  }) async {
    final response = await _send<Api0201Response>(
      method: 'GET',
      path: ScannerPartnerEndpoints.scannerRedemptions,
      query: query.toQueryParameters(),
      decoder: ScannerPartnerEndpointDecoders.api0201,
      requireScannerDevice: true,
    );
    return PagedResult(
      items: response.data.data,
      pagination: _pagination(response.data.meta, fallbackLimit: query.limit),
    );
  }

  @override
  Future<RedemptionReceipt> getRedemption(String redemptionPublicId) async {
    final response = await _send<Api0202Response>(
      method: 'GET',
      path: ScannerPartnerEndpoints.scannerRedemption(redemptionPublicId),
      decoder: ScannerPartnerEndpointDecoders.api0202,
      requireScannerDevice: true,
    );
    return response.data.data;
  }

  @override
  Future<RedemptionReceipt> reverseRedemption(
    String redemptionPublicId,
    ReverseRedemptionRequest request, {
    required String idempotencyKey,
  }) async {
    final response = await _send<Api0203Response>(
      method: 'POST',
      path: ScannerPartnerEndpoints.scannerRedemptionReverse(redemptionPublicId),
      body: request.toJson(),
      idempotencyKey: idempotencyKey,
      decoder: ScannerPartnerEndpointDecoders.api0203,
      sensitive: true,
      requireScannerDevice: true,
    );
    return response.data.data;
  }

  @override
  Future<PartnerDailyStatisticsData> getDailyStatistics() async {
    final response = await _send<Api0204Response>(
      method: 'GET',
      path: ScannerPartnerEndpoints.scannerStatisticsDaily,
      decoder: ScannerPartnerEndpointDecoders.api0204,
      requireScannerDevice: true,
    );
    return response.data.data;
  }

  @override
  Future<PartnerDailyStatisticsData> getStatistics({required String period}) async {
    final response = await _send<Api0204Response>(
      method: 'GET',
      path: ScannerPartnerEndpoints.scannerStatistics,
      query: <String, String>{'period': period},
      decoder: ScannerPartnerEndpointDecoders.api0204,
      requireScannerDevice: true,
    );
    return response.data.data;
  }

  @override
  Future<PartnerDetail> getPartnerProfile() async {
    final response = await _send<Api0209Response>(
      method: 'GET',
      path: ScannerPartnerEndpoints.partnerMe,
      decoder: ScannerPartnerEndpointDecoders.api0209,
    );
    return response.data.data;
  }

  @override
  Future<PartnerDetail> requestPartnerProfileChange(
    RequestPartnerProfileChangeRequest request, {
    required String idempotencyKey,
  }) async {
    final body = request.toJson();
    final response = await _send<Api0210Response>(
      method: 'POST',
      path: ScannerPartnerEndpoints.partnerProfileChangeRequests,
      body: body,
      idempotencyKey: idempotencyKey,
      decoder: ScannerPartnerEndpointDecoders.api0210,
      sensitive: true,
    );
    return response.data.data;
  }

  @override
  Future<PagedResult<PartnerBranchData>> getPartnerBranches({
    ListQuery query = const ListQuery(),
  }) async {
    final response = await _send<Api0211Response>(
      method: 'GET',
      path: ScannerPartnerEndpoints.partnerBranches,
      query: query.toQueryParameters(),
      decoder: ScannerPartnerEndpointDecoders.api0211,
    );
    return PagedResult(
      items: response.data.data,
      pagination: _pagination(response.data.meta, fallbackLimit: query.limit),
    );
  }

  @override
  Future<PartnerBranchData> createPartnerBranch(
    CreatePartnerBranchRequest request, {
    required String idempotencyKey,
  }) async {
    final body = request.toJson();
    final response = await _send<Api0212Response>(
      method: 'POST',
      path: ScannerPartnerEndpoints.partnerBranches,
      body: body,
      idempotencyKey: idempotencyKey,
      decoder: ScannerPartnerEndpointDecoders.api0212,
      sensitive: true,
    );
    return response.data.data;
  }

  @override
  Future<VersionedResource<PartnerBranchData>> getPartnerBranchForEdit(
    String branchPublicId,
  ) async {
    final page = await getPartnerBranches(query: const ListQuery(limit: 100));
    final data = page.items.singleWhere((branch) => branch.publicId == branchPublicId);
    return VersionedResource(data: data, etag: 'not-required-final-contract');
  }

  @override
  Future<VersionedResource<PartnerBranchData>> updatePartnerBranch(
    String branchPublicId,
    UpdatePartnerBranchRequest request,
  ) async {
    final response = await _send<Api0213Response>(
      method: 'PATCH',
      path: ScannerPartnerEndpoints.partnerBranch(branchPublicId),
      body: request.toJson(),
      decoder: ScannerPartnerEndpointDecoders.api0213,
      sensitive: true,
    );
    return VersionedResource(data: response.data.data, etag: 'not-required-final-contract');
  }

  @override
  Future<PagedResult<PartnerMembershipData>> getPartnerMemberships({
    ListQuery query = const ListQuery(),
  }) async {
    final response = await _send<Api0214Response>(
      method: 'GET',
      path: ScannerPartnerEndpoints.partnerMemberships,
      query: query.toQueryParameters(),
      decoder: ScannerPartnerEndpointDecoders.api0214,
    );
    return PagedResult(
      items: response.data.data,
      pagination: _pagination(response.data.meta, fallbackLimit: query.limit),
    );
  }

  @override
  Future<PagedResult<OfferDetails>> getPartnerOffers({
    ListQuery query = const ListQuery(),
  }) async {
    final response = await _send<Api0215Response>(
      method: 'GET',
      path: ScannerPartnerEndpoints.partnerOffers,
      query: query.toQueryParameters(),
      decoder: ScannerPartnerEndpointDecoders.api0215,
    );
    return PagedResult(
      items: response.data.data,
      pagination: _pagination(response.data.meta, fallbackLimit: query.limit),
    );
  }

  @override
  Future<OfferDetails> createPartnerOffer(
    CreatePartnerOfferRequest request, {
    required String idempotencyKey,
  }) async {
    final body = request.toJson();
    final response = await _send<Api0216Response>(
      method: 'POST',
      path: ScannerPartnerEndpoints.partnerOffers,
      body: body,
      idempotencyKey: idempotencyKey,
      decoder: ScannerPartnerEndpointDecoders.api0216,
      sensitive: true,
    );
    return response.data.data;
  }

  @override
  Future<VersionedResource<OfferDetails>> getPartnerOfferForEdit(
    String offerPublicId,
  ) async {
    final page = await getPartnerOffers(query: const ListQuery(limit: 100));
    final data = page.items.singleWhere((offer) => offer.publicId == offerPublicId);
    return VersionedResource(data: data, etag: 'not-required-final-contract');
  }

  @override
  Future<VersionedResource<OfferDetails>> updatePartnerOffer(
    String offerPublicId,
    UpdatePartnerOfferRequest request,
  ) async {
    final response = await _send<Api0217Response>(
      method: 'PATCH',
      path: ScannerPartnerEndpoints.partnerOffer(offerPublicId),
      body: request.toJson(),
      decoder: ScannerPartnerEndpointDecoders.api0217,
      sensitive: true,
    );
    return VersionedResource(data: response.data.data, etag: 'not-required-final-contract');
  }

  @override
  Future<OfferDetails> activatePartnerOffer(
    String offerPublicId, {
    required String idempotencyKey,
  }) async {
    final response = await _send<Api0218Response>(
      method: 'POST',
      path: ScannerPartnerEndpoints.partnerOfferActivate(offerPublicId),
      body: const <String, dynamic>{},
      idempotencyKey: idempotencyKey,
      decoder: ScannerPartnerEndpointDecoders.api0218,
      sensitive: true,
    );
    return response.data.data;
  }

  @override
  Future<OfferDetails> disablePartnerOffer(
    String offerPublicId,
    DisablePartnerOfferRequest request, {
    required String idempotencyKey,
  }) async {
    final body = request.toJson();
    final response = await _send<Api0219Response>(
      method: 'POST',
      path: ScannerPartnerEndpoints.partnerOfferDisable(offerPublicId),
      body: body,
      idempotencyKey: idempotencyKey,
      decoder: ScannerPartnerEndpointDecoders.api0219,
      sensitive: true,
    );
    return response.data.data;
  }
}
