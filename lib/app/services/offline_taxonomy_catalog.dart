import '../models/scanner_partner_models.dart';
import 'partner_card_type_taxonomy_repository.dart';
import 'partner_location_taxonomy_source.dart';
import 'partner_type_taxonomy_source.dart';

/// Explicit fixture catalog for Phase 15 Offline Demo only.
/// These identifiers are deterministic demo values and are never production IDs.
abstract final class OfflineTaxonomyCatalog {
  static const provinces = <TaxonomyRef>[
    MockPartnerLocationTaxonomyCatalog.damascus,
    MockPartnerLocationTaxonomyCatalog.aleppo,
  ];

  static const cities = <TaxonomyRef>[
    MockPartnerLocationTaxonomyCatalog.damascusCity,
    MockPartnerLocationTaxonomyCatalog.oldDamascus,
    MockPartnerLocationTaxonomyCatalog.aleppoCity,
  ];

  static const areas = <TaxonomyRef>[
    TaxonomyRef(
      publicId: '0498a6f0-7b8c-7a12-9abc-1234567890ab',
      code: 'mazzeh',
      name: LocalizedMessage(ar: 'المزة', en: 'Mazzeh', de: 'Mazzeh'),
    ),
    TaxonomyRef(
      publicId: '0498a6f1-7b8c-7a12-9abc-1234567890ab',
      code: 'old-city',
      name: LocalizedMessage(ar: 'المدينة القديمة', en: 'Old City', de: 'Altstadt'),
    ),
    TaxonomyRef(
      publicId: '0498a6f2-7b8c-7a12-9abc-1234567890ab',
      code: 'al-aziziyah',
      name: LocalizedMessage(ar: 'العزيزية', en: 'Al-Aziziyah', de: 'Al-Aziziyah'),
    ),
  ];

  static const partnerTypes = MockPartnerTypeTaxonomyCatalog.values;
  static const cardTypes = MockPartnerCardTypeTaxonomyCatalog.values;
}
