import 'scanner_partner_models.dart';

enum RedemptionCommandKind {
  free,
  points,
  discount,
  unsupported,
}

RedemptionCommandKind redemptionCommandForOffer(OfferDetails offer) {
  return switch (offer.discountType) {
    'free' => RedemptionCommandKind.free,
    'points' => RedemptionCommandKind.points,
    'percentage' => RedemptionCommandKind.discount,
    'fixed' => RedemptionCommandKind.discount,
    _ => RedemptionCommandKind.unsupported,
  };
}

class RedemptionFlowContext {
  const RedemptionFlowContext({
    required this.verification,
    required this.branch,
    required this.offers,
  });

  final ScanVerificationData verification;
  final PartnerBranchData branch;
  final List<OfferDetails> offers;
}

class RedemptionConfirmationArgs {
  const RedemptionConfirmationArgs({
    required this.verification,
    required this.branch,
    required this.offer,
  });

  final ScanVerificationData verification;
  final PartnerBranchData branch;
  final OfferDetails offer;
}

class RedemptionReceiptArgs {
  const RedemptionReceiptArgs({
    required this.receipt,
    this.offer,
  });

  final RedemptionReceipt receipt;
  final OfferDetails? offer;
}
