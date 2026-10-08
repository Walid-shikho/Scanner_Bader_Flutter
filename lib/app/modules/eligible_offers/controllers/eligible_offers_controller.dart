import 'package:get/get.dart';

import '../../../models/redemption_flow_models.dart';
import '../../../models/scanner_partner_models.dart';
import '../../../routes/app_routes.dart';
import '../../../services/scanner_repository.dart';

enum EligibleOffersState { loading, loaded, missingContext, error }

class EligibleOffersController extends GetxController {
  EligibleOffersController(this.repository);

  final ScannerRepository repository;

  final state = EligibleOffersState.loading.obs;
  final offers = <OfferDetails>[].obs;
  RedemptionFlowContext? flow;

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments;
    if (arguments is! RedemptionFlowContext ||
        arguments.verification.scanResult != ScanResultValue.eligible) {
      state.value = EligibleOffersState.missingContext;
      return;
    }
    flow = arguments;
    _load();
  }

  Future<void> _load() async {
    final current = flow;
    if (current == null) return;

    state.value = EligibleOffersState.loading;
    try {
      if (current.offers.isNotEmpty) {
        offers.assignAll(current.offers);
      } else if (current.verification.eligibleOfferCount > 0) {
        offers.assignAll(
          await repository.getEligibleOffers(current.verification.scanPublicId),
        );
      }
      state.value = EligibleOffersState.loaded;
    } catch (_) {
      state.value = EligibleOffersState.error;
    }
  }

  Future<void> retry() => _load();

  RedemptionCommandKind commandFor(OfferDetails offer) =>
      redemptionCommandForOffer(offer);

  bool canSelect(OfferDetails offer) {
    final kind = commandFor(offer);
    return kind == RedemptionCommandKind.free ||
        kind == RedemptionCommandKind.points ||
        kind == RedemptionCommandKind.discount;
  }

  void selectOffer(OfferDetails offer) {
    final current = flow;
    if (current == null || !canSelect(offer)) return;

    Get.toNamed<void>(
      AppRoutes.redemptionConfirm,
      arguments: RedemptionConfirmationArgs(
        verification: current.verification,
        branch: current.branch,
        offer: offer,
      ),
    );
  }
}
