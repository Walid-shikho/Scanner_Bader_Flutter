import '../models/scanner_partner_models.dart';
import 'partner_manager_repository.dart';
import 'scanner_repository.dart';

abstract final class ScannerPartnerContractGaps {
  static const cardTypeTaxonomy =
      'BLOCKED_BY_SHARED_CARD_TYPE_TAXONOMY_CONTRACT';
}

abstract interface class ScannerPartnerRepository
    implements ScannerRepository, PartnerManagerRepository {}

class ScannerContractGapException implements Exception {
  const ScannerContractGapException(this.gap);

  final String gap;

  @override
  String toString() => 'ScannerContractGapException($gap)';
}
