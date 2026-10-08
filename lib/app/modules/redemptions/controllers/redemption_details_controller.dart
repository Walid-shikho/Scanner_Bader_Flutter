import 'package:get/get.dart';

import '../../../../core/network/api_error.dart';
import '../../../models/scanner_partner_models.dart';
import '../../../routes/app_routes.dart';
import '../../../security/scanner_session_state.dart';
import '../../../services/scanner_auth_session_gateway.dart';
import '../../../services/scanner_repository.dart';

enum RedemptionDetailsState { loading, loaded, permissionDenied, notFound, error }

class RedemptionDetailsController extends GetxController {
  RedemptionDetailsController(
    this.repository,
    this.sessionGateway, {
    required this.redemptionPublicId,
  });

  final ScannerRepository repository;
  final ScannerAuthSessionGateway sessionGateway;
  final String redemptionPublicId;

  final state = RedemptionDetailsState.loading.obs;
  final receipt = Rxn<RedemptionReceipt>();

  bool get canShowReverse {
    final session = sessionGateway.current;
    return session.status == ScannerSessionStatus.authenticated &&
        session.principal == ScannerPrincipalType.partnerEmployee &&
        session.permissions.contains(ScannerPermission.redemptionsReverse);
  }

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    if (redemptionPublicId.isEmpty) {
      state.value = RedemptionDetailsState.notFound;
      return;
    }
    state.value = RedemptionDetailsState.loading;
    try {
      receipt.value = await repository.getRedemption(redemptionPublicId);
      state.value = RedemptionDetailsState.loaded;
    } on NormalizedApiError catch (error) {
      state.value = switch (error.statusCode) {
        403 => RedemptionDetailsState.permissionDenied,
        404 => RedemptionDetailsState.notFound,
        _ => RedemptionDetailsState.error,
      };
    } catch (_) {
      state.value = RedemptionDetailsState.error;
    }
  }

  void openReverse() {
    if (!canShowReverse) return;
    Get.toNamed<void>(AppRoutes.redemptionReverseFor(redemptionPublicId));
  }
}
