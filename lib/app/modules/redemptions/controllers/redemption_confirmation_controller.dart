import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/network/api_error.dart';
import '../../../models/redemption_flow_models.dart';
import '../../../models/scanner_partner_models.dart';
import '../../../routes/app_routes.dart';
import '../../../services/idempotency_key_factory.dart';
import '../../../services/scanner_partner_repository.dart';
import '../../../services/scanner_repository.dart';

enum RedemptionConfirmationState { ready, submitting, error, completed }

class RedemptionConfirmationController extends GetxController {
  RedemptionConfirmationController(
    this.repository,
    this.idempotencyKeyFactory,
  );

  final ScannerRepository repository;
  final IdempotencyKeyFactory idempotencyKeyFactory;

  final invoiceAmountController = TextEditingController();
  final staticPinController = TextEditingController();
  final includeInvoiceAmount = false.obs;
  final state = RedemptionConfirmationState.ready.obs;
  final validationMessageKey = RxnString();
  final executionErrorKey = RxnString();
  String? _idempotencyKey;

  RedemptionConfirmationArgs? args;

  static final RegExp _invoicePattern =
      RegExp(r'^-?[0-9]+(\.[0-9]{1,4})?$');
  static final RegExp _pinPattern = RegExp(r'^[0-9]{6}$');

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments;
    if (arguments is RedemptionConfirmationArgs) {
      args = arguments;
      if (redemptionCommandForOffer(arguments.offer) ==
          RedemptionCommandKind.discount) {
        includeInvoiceAmount.value = true;
      }
    } else {
      executionErrorKey.value = 'redemption_context_missing';
      state.value = RedemptionConfirmationState.error;
    }
  }

  RedemptionCommandKind get commandKind => args == null
      ? RedemptionCommandKind.unsupported
      : redemptionCommandForOffer(args!.offer);

  bool get requiresPin => args?.verification.pinRequired ?? false;

  bool get staticPinContractCompatible =>
      !requiresPin || args?.verification.qrType == ScannerQrType.staticQr;

  bool get sensitiveRedemptionAllowed =>
      args?.verification.sensitiveRedemptionAllowed ?? false;

  bool get hasSupportedCommand =>
      commandKind == RedemptionCommandKind.free ||
      commandKind == RedemptionCommandKind.points ||
      commandKind == RedemptionCommandKind.discount;

  bool get canExecute =>
      args != null &&
      hasSupportedCommand &&
      staticPinContractCompatible &&
      state.value != RedemptionConfirmationState.submitting;

  void setIncludeInvoiceAmount(bool value) {
    includeInvoiceAmount.value = value;
    validationMessageKey.value = null;
    if (!value) invoiceAmountController.clear();
  }

  void clearStaticPin() => staticPinController.clear();

  bool validate() {
    validationMessageKey.value = null;

    if (!hasSupportedCommand) {
      validationMessageKey.value = 'redemption_mapping_unresolved';
      return false;
    }
    if (!staticPinContractCompatible) {
      validationMessageKey.value = 'static_pin_contract_mismatch';
      return false;
    }

    if (commandKind == RedemptionCommandKind.discount &&
        !includeInvoiceAmount.value) {
      validationMessageKey.value = 'invoice_amount_invalid';
      return false;
    }

    if (includeInvoiceAmount.value) {
      final invoice = invoiceAmountController.text.trim();
      if (invoice.isEmpty || !_invoicePattern.hasMatch(invoice)) {
        validationMessageKey.value = 'invoice_amount_invalid';
        return false;
      }
    }

    if (requiresPin) {
      final pin = staticPinController.text;
      if (!_pinPattern.hasMatch(pin)) {
        validationMessageKey.value = 'static_qr_pin_invalid_format';
        return false;
      }
    }

    return true;
  }

  Future<void> execute() async {
    final current = args;
    if (current == null || !canExecute || !validate()) return;

    state.value = RedemptionConfirmationState.submitting;
    executionErrorKey.value = null;

    // API-0199 and API-0200 require X-Idempotency-Key. The same key is kept
    // for the duration of this explicit mutation attempt.
    final idempotencyKey = _idempotencyKey ??= idempotencyKeyFactory.create();
    final request = RedemptionRequest(
      scanPublicId: current.verification.scanPublicId,
      offerPublicId: current.offer.publicId,
      invoiceAmount: includeInvoiceAmount.value
          ? invoiceAmountController.text.trim()
          : null,
      branchPublicId: current.branch.publicId,
      staticQrPin: requiresPin ? staticPinController.text : null,
    );

    try {
      final receipt = switch (commandKind) {
        RedemptionCommandKind.free => repository.executeFreeRedemption(
            request,
            idempotencyKey: idempotencyKey,
          ),
        RedemptionCommandKind.points => repository.executePointsRedemption(
            request,
            idempotencyKey: idempotencyKey,
          ),
        RedemptionCommandKind.discount => repository.executeDiscountRedemption(
            request,
            idempotencyKey: idempotencyKey,
          ),
        _ => throw const ScannerContractGapException(
            'unsupported_redemption_type',
          ),
      };

      final resolvedReceipt = await receipt;
      _idempotencyKey = null;
      state.value = RedemptionConfirmationState.completed;
      Get.offNamed<void>(
        AppRoutes.redemptionReceipt,
        arguments: RedemptionReceiptArgs(
          receipt: resolvedReceipt,
          offer: current.offer,
        ),
      );
    } on NormalizedApiError catch (error) {
      executionErrorKey.value = _errorKeyFor(error);
      state.value = RedemptionConfirmationState.error;
    } on ScannerContractGapException {
      executionErrorKey.value = 'redemption_mapping_unresolved';
      state.value = RedemptionConfirmationState.error;
    } catch (_) {
      executionErrorKey.value = 'redemption_execute_error';
      state.value = RedemptionConfirmationState.error;
    } finally {
      // static_qr_pin is write-only sensitive input. Never retain it after the
      // request completes, regardless of outcome.
      staticPinController.clear();
      if (state.value != RedemptionConfirmationState.completed) {
        state.value = RedemptionConfirmationState.ready;
      }
    }
  }

  String _errorKeyFor(NormalizedApiError error) {
    final codes = error.errors.map((item) => item.code).toSet();
    if (codes.contains('CARD_STATIC_QR_PIN_INVALID')) {
      return 'static_qr_pin_server_invalid';
    }
    if (codes.contains('CARD_STATIC_QR_PIN_LOCKED')) {
      return 'static_qr_pin_locked';
    }
    if (codes.contains('CARD_STATIC_QR_REVOKED')) {
      return 'static_qr_revoked';
    }
    return 'redemption_execute_error';
  }

  @override
  void onClose() {
    staticPinController.clear();
    invoiceAmountController.dispose();
    staticPinController.dispose();
    super.onClose();
  }
}
