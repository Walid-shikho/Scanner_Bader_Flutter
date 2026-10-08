import 'package:get/get.dart';

import '../models/scanner_partner_models.dart';
import 'scanner_partner_repository.dart';

abstract interface class PartnerCardTypeTaxonomyRepository {
  bool get productionReady;
  String? get productionBlocker;

  Future<List<TaxonomyRef>> getCardTypes();
}

abstract final class MockPartnerCardTypeTaxonomyCatalog {
  static const values = <TaxonomyRef>[
    TaxonomyRef(
      publicId: '0198c101-7b8c-7a12-9abc-1234567890ab',
      code: 'standard',
      name: LocalizedMessage(
        ar: 'البطاقة القياسية',
        en: 'Standard Card',
        de: 'Standardkarte',
      ),
    ),
    TaxonomyRef(
      publicId: '0198c102-7b8c-7a12-9abc-1234567890ab',
      code: 'premium',
      name: LocalizedMessage(
        ar: 'البطاقة المميزة',
        en: 'Premium Card',
        de: 'Premiumkarte',
      ),
    ),
  ];
}

class MockPartnerCardTypeTaxonomyRepository extends GetxService
    implements PartnerCardTypeTaxonomyRepository {
  @override
  bool get productionReady => false;

  @override
  String? get productionBlocker => ScannerPartnerContractGaps.cardTypeTaxonomy;

  @override
  Future<List<TaxonomyRef>> getCardTypes() async =>
      List<TaxonomyRef>.unmodifiable(MockPartnerCardTypeTaxonomyCatalog.values);
}

class OfflinePartnerCardTypeTaxonomyRepository extends GetxService
    implements PartnerCardTypeTaxonomyRepository {
  @override
  bool get productionReady => true;

  @override
  String? get productionBlocker => null;

  @override
  Future<List<TaxonomyRef>> getCardTypes() async =>
      List<TaxonomyRef>.unmodifiable(MockPartnerCardTypeTaxonomyCatalog.values);
}
