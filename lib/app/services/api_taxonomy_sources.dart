import '../../core/network/api_headers.dart';
import '../../core/network/api_transport.dart';
import '../../core/network/request_id_factory.dart';
import '../models/scanner_partner_models.dart';
import 'partner_card_type_taxonomy_repository.dart';
import 'partner_location_taxonomy_source.dart';
import 'partner_type_taxonomy_source.dart';
import 'scanner_partner_repository.dart';

class _PublicTaxonomyClient {
  const _PublicTaxonomyClient({
    required this.transport,
    required this.requestIds,
    required this.acceptLanguage,
  });

  final ApiTransport transport;
  final RequestIdFactory requestIds;
  final String Function() acceptLanguage;

  Future<List<_TaxonomyItem>> get(String path) async {
    final response = await transport.send<List<_TaxonomyItem>>(
      ApiRequest(
        method: 'GET',
        path: path,
        headers: <String, String>{
          ApiHeaderNames.accept: 'application/json',
          ApiHeaderNames.acceptLanguage: acceptLanguage(),
          ApiHeaderNames.requestId: requestIds.create(),
        },
      ),
      decodeData: (raw) {
        final envelope = Map<String, dynamic>.from(raw as Map);
        final data = envelope['data'];
        final rawItems = data is List
            ? data
            : data is Map && data['items'] is List
                ? data['items'] as List
                : const <dynamic>[];
        return rawItems
            .whereType<Map>()
            .map((e) => _TaxonomyItem.fromJson(Map<String, dynamic>.from(e)))
            .toList(growable: false);
      },
    );
    return response.data;
  }
}

class _TaxonomyItem {
  const _TaxonomyItem({
    required this.ref,
    this.provincePublicId,
  });

  factory _TaxonomyItem.fromJson(Map<String, dynamic> json) {
    final nameRaw = json['name'];
    final nameMap = nameRaw is Map
        ? Map<String, dynamic>.from(nameRaw)
        : <String, dynamic>{
            'ar': json['name_ar'] ?? json['label_ar'] ?? json['name'] ?? '',
            'en': json['name_en'] ?? json['label_en'],
            'de': json['name_de'] ?? json['label_de'],
          };
    return _TaxonomyItem(
      ref: TaxonomyRef(
        publicId: (json['public_id'] ?? json['id']) as String,
        code: (json['code'] ?? '') as String,
        name: LocalizedMessage(
          ar: (nameMap['ar'] ?? '') as String,
          en: nameMap['en'] as String?,
          de: nameMap['de'] as String?,
        ),
      ),
      provincePublicId: (json['province_public_id'] ??
          (json['province'] is Map
              ? (json['province'] as Map)['public_id']
              : null)) as String?,
    );
  }

  final TaxonomyRef ref;
  final String? provincePublicId;
}

class ApiPartnerTypeTaxonomySource implements PartnerTypeTaxonomySource {
  ApiPartnerTypeTaxonomySource({
    required ApiTransport transport,
    required RequestIdFactory requestIds,
    required String Function() acceptLanguage,
  }) : _client = _PublicTaxonomyClient(
          transport: transport,
          requestIds: requestIds,
          acceptLanguage: acceptLanguage,
        );

  final _PublicTaxonomyClient _client;

  @override
  bool get productionReady => true;

  @override
  String get integrationStatus => 'READY_API_0234_PARTNER_TYPES';

  @override
  Future<List<TaxonomyRef>> getPartnerTypes() async =>
      (await _client.get('/api/v1/taxonomies/partner-types'))
          .map((e) => e.ref)
          .toList(growable: false);
}

class ApiPartnerLocationTaxonomySource
    implements PartnerLocationTaxonomySource {
  ApiPartnerLocationTaxonomySource({
    required ApiTransport transport,
    required RequestIdFactory requestIds,
    required String Function() acceptLanguage,
  }) : _client = _PublicTaxonomyClient(
          transport: transport,
          requestIds: requestIds,
          acceptLanguage: acceptLanguage,
        );

  final _PublicTaxonomyClient _client;

  @override
  bool get productionReady => true;

  @override
  String? get productionBlocker => null;

  @override
  Future<List<TaxonomyRef>> getProvinces() async =>
      (await _client.get('/api/v1/taxonomies/provinces'))
          .map((e) => e.ref)
          .toList(growable: false);

  @override
  Future<List<TaxonomyRef>> getCities({required String provincePublicId}) async {
    final items = await _client.get('/api/v1/taxonomies/cities');
    final explicitlyScoped = items
        .where((e) => e.provincePublicId == provincePublicId)
        .map((e) => e.ref)
        .toList(growable: false);
    // Do not invent an undocumented query parameter. If the shared response
    // does not expose province linkage, fail rather than presenting wrong IDs.
    if (explicitlyScoped.isEmpty &&
        items.any((item) => item.provincePublicId == null)) {
      throw const ScannerContractGapException(
        'BLOCKED_BY_CITY_PROVINCE_RELATION_IN_TAXONOMY_RESPONSE',
      );
    }
    return explicitlyScoped;
  }
}

/// The latest Partner/Scanner handoff omits card-types from its shared API
/// inventory, while an older platform inventory mentions that route. Production
/// must not silently bind a stale/conflicting contract.
class BlockedPartnerCardTypeTaxonomyRepository
    implements PartnerCardTypeTaxonomyRepository {
  const BlockedPartnerCardTypeTaxonomyRepository();

  @override
  bool get productionReady => false;

  @override
  String? get productionBlocker => ScannerPartnerContractGaps.cardTypeTaxonomy;

  @override
  Future<List<TaxonomyRef>> getCardTypes() {
    throw const ScannerContractGapException(
      ScannerPartnerContractGaps.cardTypeTaxonomy,
    );
  }
}
