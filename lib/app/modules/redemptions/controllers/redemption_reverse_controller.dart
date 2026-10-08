import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/redemption_flow_models.dart';
import '../../../models/scanner_partner_models.dart';
import '../../../routes/app_routes.dart';
import '../../../security/scanner_session_state.dart';
import '../../../services/idempotency_key_factory.dart';
import '../../../services/scanner_auth_session_gateway.dart';
import '../../../services/scanner_repository.dart';
import '../../../services/step_up_auth_service.dart';

enum RedemptionReverseState {
  ready,
  submitting,
  permissionDenied,
  stepUpBlocked,
  stepUpDenied,
  error,
}

class RedemptionReverseController extends GetxController {
  RedemptionReverseController(
    this.repository,
    this.sessionGateway,
    this.stepUpAuthService,
    this.idempotencyKeyFactory, {
    required this.redemptionPublicId,
  });

  final ScannerRepository repository;
  final ScannerAuthSessionGateway sessionGateway;
  final StepUpAuthService stepUpAuthService;
  final IdempotencyKeyFactory idempotencyKeyFactory;
  final String redemptionPublicId;

  final reasonController = TextEditingController();
  final state = RedemptionReverseState.ready.obs;
  final validationMessageKey = RxnString();
  String? _idempotencyKey;

  bool get hasReversePermission {
    final session = sessionGateway.current;
    return session.status == ScannerSessionStatus.authenticated &&
        session.principal == ScannerPrincipalType.partnerEmployee &&
        session.permissions.contains(ScannerPermission.redemptionsReverse);
  }

  @override
  void onInit() {
    super.onInit();
    if (!hasReversePermission) {
      state.value = RedemptionReverseState.permissionDenied;
    }
  }

  bool validate() {
    final reason = reasonController.text.trim();
    if (reason.isEmpty) {
      validationMessageKey.value = 'reverse_reason_required';
      return false;
    }
    if (reason.length > 1000) {
      validationMessageKey.value = 'reverse_reason_too_long';
      return false;
    }
    validationMessageKey.value = null;
    return true;
  }

  Future<void> execute() async {
    if (!hasReversePermission || !validate() || redemptionPublicId.isEmpty) {
      return;
    }

    state.value = RedemptionReverseState.submitting;

    try {
      final receipt = await repository.reverseRedemption(
        redemptionPublicId,
        ReverseRedemptionRequest(reason: reasonController.text.trim()),
        idempotencyKey: _idempotencyKey ??= idempotencyKeyFactory.create(),
      );
      _idempotencyKey = null;
      Get.offNamed<void>(
        AppRoutes.redemptionReceipt,
        arguments: RedemptionReceiptArgs(receipt: receipt),
      );
    } catch (_) {
      state.value = RedemptionReverseState.error;
    }
  }

  @override
  void onClose() {
    reasonController.clear();
    reasonController.dispose();
    super.onClose();
  }
}
