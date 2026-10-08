import 'package:get/get.dart';

import '../../../models/scanner_partner_models.dart';
import '../../../routes/app_routes.dart';

enum PartnerOfferDetailsState { ready, missingContext }

class PartnerOfferDetailsController extends GetxController {
  PartnerOfferDetailsController({
    required this.offerPublicId,
    required OfferDetails? initialOffer,
  }) : offer = Rxn<OfferDetails>(initialOffer);

  final String offerPublicId;
  final Rxn<OfferDetails> offer;

  PartnerOfferDetailsState get state => offer.value == null
      ? PartnerOfferDetailsState.missingContext
      : PartnerOfferDetailsState.ready;

  Future<void> openEdit() async {
    final current = offer.value;
    if (current == null) return;
    final result = await Get.toNamed<dynamic>(
      AppRoutes.partnerOfferEditFor(offerPublicId),
      arguments: current,
    );
    if (result is OfferDetails) offer.value = result;
  }

  Future<void> openActivate() async {
    final current = offer.value;
    if (current == null) return;
    final result = await Get.toNamed<dynamic>(
      AppRoutes.partnerOfferActivateFor(offerPublicId),
      arguments: current,
    );
    if (result is OfferDetails) offer.value = result;
  }

  Future<void> openDisable() async {
    final current = offer.value;
    if (current == null) return;
    final result = await Get.toNamed<dynamic>(
      AppRoutes.partnerOfferDisableFor(offerPublicId),
      arguments: current,
    );
    if (result is OfferDetails) offer.value = result;
  }

  void close() => Get.back(result: offer.value);
}
