import 'package:get/get.dart';

import '../models/scanner_partner_models.dart';
import '../modules/eligible_offers/controllers/eligible_offers_controller.dart';
import '../modules/memberships/controllers/memberships_controller.dart';
import '../modules/partner_branches/controllers/partner_branch_create_controller.dart';
import '../modules/partner_branches/controllers/partner_branch_edit_controller.dart';
import '../modules/partner_branches/controllers/partner_branches_controller.dart';
import '../modules/partner_offers/controllers/partner_offer_activate_controller.dart';
import '../modules/partner_offers/controllers/partner_offer_create_controller.dart';
import '../modules/partner_offers/controllers/partner_offer_details_controller.dart';
import '../modules/partner_offers/controllers/partner_offer_disable_controller.dart';
import '../modules/partner_offers/controllers/partner_offer_edit_controller.dart';
import '../modules/partner_offers/controllers/partner_offers_controller.dart';
import '../modules/partner_profile/controllers/partner_profile_change_controller.dart';
import '../modules/partner_profile/controllers/partner_profile_operational_edit_controller.dart';
import '../modules/partner_notifications/controllers/partner_notifications_controller.dart';
import '../modules/partner_profile/controllers/partner_profile_controller.dart';
import '../modules/qr_challenge/controllers/qr_challenge_controller.dart';
import '../modules/qr_verification/controllers/qr_verification_controller.dart';
import '../modules/redemptions/controllers/redemption_confirmation_controller.dart';
import '../modules/redemptions/controllers/redemption_details_controller.dart';
import '../modules/redemptions/controllers/redemption_receipt_controller.dart';
import '../modules/redemptions/controllers/redemption_reverse_controller.dart';
import '../modules/redemptions/controllers/redemptions_controller.dart';
import '../modules/scan_result/controllers/scan_result_controller.dart';
import '../modules/scanner_branches/controllers/scanner_branches_controller.dart';
import '../modules/scanner_context/controllers/scanner_context_controller.dart';
import '../modules/scanner_devices/controllers/scanner_devices_controller.dart';
import '../modules/statistics/controllers/statistics_controller.dart';
import '../services/idempotency_key_factory.dart';
import '../services/partner_card_type_taxonomy_repository.dart';
import '../services/partner_location_taxonomy_source.dart';
import '../services/qr_scanner_adapter.dart';
import '../services/scanner_auth_session_gateway.dart';
import '../services/scanner_location_provider.dart';
import '../services/partner_manager_repository.dart';
import '../services/partner_offline_extras_repository.dart';
import '../services/scanner_repository.dart';
import '../services/step_up_auth_service.dart';
import '../services/uploaded_file_reference_repository.dart';

ScannerRepository _scannerRepository() => Get.find<ScannerRepository>();
PartnerManagerRepository _partnerRepository() => Get.find<PartnerManagerRepository>();
UploadedFileReferenceRepository _fileRepository() =>
    Get.find<UploadedFileReferenceRepository>();
IdempotencyKeyFactory _idempotencyKeyFactory() =>
    Get.find<IdempotencyKeyFactory>();

class ScannerContextBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ScannerContextController>(
      () => ScannerContextController(_scannerRepository()),
    );
  }
}

class ScannerBranchesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ScannerBranchesController>(
      () => ScannerBranchesController(_scannerRepository()),
    );
  }
}

class ScannerDevicesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ScannerDevicesController>(
      () => ScannerDevicesController(_scannerRepository()),
    );
  }
}

class QrChallengeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QrChallengeController>(
      () => QrChallengeController(
        _scannerRepository(),
        Get.find<QrScannerAdapter>(),
        Get.find<ScannerLocationProvider>(),
      ),
    );
  }
}

class QrVerificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QrVerificationController>(
      () => QrVerificationController(_scannerRepository()),
    );
  }
}

class ScanResultBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ScanResultController>(
      () => ScanResultController(_scannerRepository()),
    );
  }
}

class EligibleOffersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EligibleOffersController>(
      () => EligibleOffersController(_scannerRepository()),
    );
  }
}

class RedemptionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RedemptionsController>(
      () => RedemptionsController(_scannerRepository()),
    );
  }
}

class RedemptionConfirmationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RedemptionConfirmationController>(
      () => RedemptionConfirmationController(
        _scannerRepository(),
        Get.find<IdempotencyKeyFactory>(),
      ),
    );
  }
}

class RedemptionReceiptBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RedemptionReceiptController>(
      RedemptionReceiptController.new,
    );
  }
}

class RedemptionDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RedemptionDetailsController>(
      () => RedemptionDetailsController(
        _scannerRepository(),
        Get.find<ScannerAuthSessionGateway>(),
        redemptionPublicId: Get.parameters['redemption_public_id'] ?? '',
      ),
    );
  }
}

class RedemptionReverseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RedemptionReverseController>(
      () => RedemptionReverseController(
        _scannerRepository(),
        Get.find<ScannerAuthSessionGateway>(),
        Get.find<StepUpAuthService>(),
        Get.find<IdempotencyKeyFactory>(),
        redemptionPublicId: Get.parameters['redemption_public_id'] ?? '',
      ),
    );
  }
}

class StatisticsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StatisticsController>(
      () => StatisticsController(_scannerRepository()),
    );
  }
}

class PartnerProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PartnerProfileController>(
      () => PartnerProfileController(_partnerRepository()),
    );
  }
}

class PartnerProfileChangeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PartnerProfileChangeController>(
      () => PartnerProfileChangeController(
        _partnerRepository(),
        Get.find<IdempotencyKeyFactory>(),
        _fileRepository(),
      ),
    );
  }
}


class PartnerProfileOperationalEditBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PartnerProfileOperationalEditController>(
      () => PartnerProfileOperationalEditController(
        _partnerRepository(),
        Get.find<PartnerExtrasRepository>(),
      ),
    );
  }
}

class PartnerNotificationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PartnerNotificationsController>(
      () => PartnerNotificationsController(Get.find<PartnerExtrasRepository>()),
    );
  }
}

class PartnerBranchesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PartnerBranchesController>(
      () => PartnerBranchesController(_partnerRepository()),
    );
  }
}

class PartnerBranchCreateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PartnerBranchCreateController>(
      () => PartnerBranchCreateController(
        _partnerRepository(),
        Get.find<PartnerLocationTaxonomySource>(),
        Get.find<IdempotencyKeyFactory>(),
      ),
    );
  }
}

class PartnerBranchEditBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PartnerBranchEditController>(
      () => PartnerBranchEditController(
        _partnerRepository(),
        branchPublicId: Get.parameters['branch_public_id'] ?? '',
      ),
    );
  }
}

class MembershipsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MembershipsController>(
      () => MembershipsController(_partnerRepository()),
    );
  }
}

class PartnerOffersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PartnerOffersController>(
      () => PartnerOffersController(_partnerRepository()),
    );
  }
}

class PartnerOfferCreateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PartnerOfferCreateController>(
      () => PartnerOfferCreateController(
        _partnerRepository(),
        Get.find<PartnerCardTypeTaxonomyRepository>(),
        Get.find<IdempotencyKeyFactory>(),
      ),
    );
  }
}

class PartnerOfferDetailsBinding extends Bindings {
  @override
  void dependencies() {
    final argument = Get.arguments;
    Get.lazyPut<PartnerOfferDetailsController>(
      () => PartnerOfferDetailsController(
        offerPublicId: Get.parameters['offer_public_id'] ?? '',
        initialOffer: argument is OfferDetails ? argument : null,
      ),
    );
  }
}

class PartnerOfferEditBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PartnerOfferEditController>(
      () => PartnerOfferEditController(
        _partnerRepository(),
        offerPublicId: Get.parameters['offer_public_id'] ?? '',
      ),
    );
  }
}

class PartnerOfferActivateBinding extends Bindings {
  @override
  void dependencies() {
    final argument = Get.arguments;
    Get.lazyPut<PartnerOfferActivateController>(
      () => PartnerOfferActivateController(
        _partnerRepository(),
        Get.find<IdempotencyKeyFactory>(),
        offerPublicId: Get.parameters['offer_public_id'] ?? '',
        initialOffer: argument is OfferDetails ? argument : null,
      ),
    );
  }
}

class PartnerOfferDisableBinding extends Bindings {
  @override
  void dependencies() {
    final argument = Get.arguments;
    Get.lazyPut<PartnerOfferDisableController>(
      () => PartnerOfferDisableController(
        _partnerRepository(),
        Get.find<IdempotencyKeyFactory>(),
        offerPublicId: Get.parameters['offer_public_id'] ?? '',
        initialOffer: argument is OfferDetails ? argument : null,
      ),
    );
  }
}
