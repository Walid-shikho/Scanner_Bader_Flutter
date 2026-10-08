import 'package:get/get.dart';

import '../models/scanner_partner_models.dart';

/// Injectable source for the province/city taxonomy required by API-0212.
///
/// The Scanner/Partner contract references province_public_id/city_public_id
/// but does not define the canonical taxonomy discovery API. The mock source is
/// deterministic for UI development only. Production wiring remains blocked by
/// the shared taxonomy contract.
abstract interface class PartnerLocationTaxonomySource {
  Future<List<TaxonomyRef>> getProvinces();

  Future<List<TaxonomyRef>> getCities({required String provincePublicId});

  bool get productionReady;

  String? get productionBlocker;
}

abstract final class MockPartnerLocationTaxonomyCatalog {
  static const damascus = TaxonomyRef(
    publicId: '0298a6f0-7b8c-7a12-9abc-1234567890ab',
    code: 'damascus',
    name: LocalizedMessage(
      ar: 'دمشق',
      en: 'Damascus',
      de: 'Damaskus',
    ),
  );

  static const aleppo = TaxonomyRef(
    publicId: '0298a6f1-7b8c-7a12-9abc-1234567890ab',
    code: 'aleppo',
    name: LocalizedMessage(
      ar: 'حلب',
      en: 'Aleppo',
      de: 'Aleppo',
    ),
  );

  static const damascusCity = TaxonomyRef(
    publicId: '0398a6f0-7b8c-7a12-9abc-1234567890ab',
    code: 'damascus-city',
    name: LocalizedMessage(
      ar: 'مدينة دمشق',
      en: 'Damascus City',
      de: 'Stadt Damaskus',
    ),
  );

  static const oldDamascus = TaxonomyRef(
    publicId: '0398a6f1-7b8c-7a12-9abc-1234567890ab',
    code: 'old-damascus',
    name: LocalizedMessage(
      ar: 'دمشق القديمة',
      en: 'Old Damascus',
      de: 'Alt-Damaskus',
    ),
  );

  static const aleppoCity = TaxonomyRef(
    publicId: '0398a6f2-7b8c-7a12-9abc-1234567890ab',
    code: 'aleppo-city',
    name: LocalizedMessage(
      ar: 'مدينة حلب',
      en: 'Aleppo City',
      de: 'Stadt Aleppo',
    ),
  );
}

class MockPartnerLocationTaxonomySource extends GetxService
    implements PartnerLocationTaxonomySource {
  @override
  bool get productionReady => false;

  @override
  String get productionBlocker =>
      'BLOCKED_BY_SHARED_PROVINCE_CITY_TAXONOMY_CONTRACT';

  @override
  Future<List<TaxonomyRef>> getProvinces() async {
    return const <TaxonomyRef>[
      MockPartnerLocationTaxonomyCatalog.damascus,
      MockPartnerLocationTaxonomyCatalog.aleppo,
    ];
  }

  @override
  Future<List<TaxonomyRef>> getCities({
    required String provincePublicId,
  }) async {
    if (provincePublicId ==
        MockPartnerLocationTaxonomyCatalog.damascus.publicId) {
      return const <TaxonomyRef>[
        MockPartnerLocationTaxonomyCatalog.damascusCity,
        MockPartnerLocationTaxonomyCatalog.oldDamascus,
      ];
    }
    if (provincePublicId == MockPartnerLocationTaxonomyCatalog.aleppo.publicId) {
      return const <TaxonomyRef>[
        MockPartnerLocationTaxonomyCatalog.aleppoCity,
      ];
    }
    return const <TaxonomyRef>[];
  }
}

class OfflinePartnerLocationTaxonomySource extends GetxService
    implements PartnerLocationTaxonomySource {
  @override
  bool get productionReady => true;

  @override
  String? get productionBlocker => null;

  @override
  Future<List<TaxonomyRef>> getProvinces() async => const <TaxonomyRef>[
        MockPartnerLocationTaxonomyCatalog.damascus,
        MockPartnerLocationTaxonomyCatalog.aleppo,
      ];

  @override
  Future<List<TaxonomyRef>> getCities({required String provincePublicId}) async {
    if (provincePublicId == MockPartnerLocationTaxonomyCatalog.damascus.publicId) {
      return const <TaxonomyRef>[
        MockPartnerLocationTaxonomyCatalog.damascusCity,
        MockPartnerLocationTaxonomyCatalog.oldDamascus,
      ];
    }
    if (provincePublicId == MockPartnerLocationTaxonomyCatalog.aleppo.publicId) {
      return const <TaxonomyRef>[MockPartnerLocationTaxonomyCatalog.aleppoCity];
    }
    return const <TaxonomyRef>[];
  }
}
