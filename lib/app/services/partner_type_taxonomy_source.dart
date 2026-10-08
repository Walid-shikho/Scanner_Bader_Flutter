import 'package:get/get.dart';

import '../models/scanner_partner_models.dart';

/// External dependency used by the partner-application form.
///
/// The Scanner/Partner contract references `partner_type_public_id` but does
/// not define the canonical taxonomy endpoint. Production integration must be
/// supplied by the shared taxonomy contract rather than invented here.
abstract interface class PartnerTypeTaxonomySource {
  Future<List<TaxonomyRef>> getPartnerTypes();

  bool get productionReady;
  String get integrationStatus;
}

abstract final class MockPartnerTypeTaxonomyCatalog {
  static const retailId = '0198c101-7b8c-7a12-9abc-1234567890ab';
  static const servicesId = '0198c102-7b8c-7a12-9abc-1234567890ab';
  static const hospitalityId = '0198c103-7b8c-7a12-9abc-1234567890ab';

  static const values = <TaxonomyRef>[
    TaxonomyRef(
      publicId: retailId,
      code: 'retail',
      name: LocalizedMessage(
        ar: 'تجزئة',
        en: 'Retail',
        de: 'Einzelhandel',
      ),
    ),
    TaxonomyRef(
      publicId: servicesId,
      code: 'services',
      name: LocalizedMessage(
        ar: 'خدمات',
        en: 'Services',
        de: 'Dienstleistungen',
      ),
    ),
    TaxonomyRef(
      publicId: hospitalityId,
      code: 'hospitality',
      name: LocalizedMessage(
        ar: 'ضيافة',
        en: 'Hospitality',
        de: 'Gastgewerbe',
      ),
    ),
  ];

  static TaxonomyRef resolve(String publicId) {
    return values.firstWhere((item) => item.publicId == publicId);
  }
}

class MockPartnerTypeTaxonomySource extends GetxService
    implements PartnerTypeTaxonomySource {
  static const blockedStatus =
      'BLOCKED_BY_SHARED_TAXONOMY_CONTRACT';

  @override
  bool get productionReady => false;

  @override
  String get integrationStatus => blockedStatus;

  @override
  Future<List<TaxonomyRef>> getPartnerTypes() async {
    return List<TaxonomyRef>.unmodifiable(MockPartnerTypeTaxonomyCatalog.values);
  }
}

class OfflinePartnerTypeTaxonomySource extends GetxService
    implements PartnerTypeTaxonomySource {
  @override
  bool get productionReady => true;

  @override
  String get integrationStatus => 'OFFLINE_DEMO_LOCAL_FIXTURE';

  @override
  Future<List<TaxonomyRef>> getPartnerTypes() async =>
      List<TaxonomyRef>.unmodifiable(MockPartnerTypeTaxonomyCatalog.values);
}
