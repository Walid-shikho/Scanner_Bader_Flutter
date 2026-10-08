import 'package:get/get.dart';

enum StepUpAuthOutcome {
  granted,
  denied,
  blockedByMissingContract,
}

class StepUpAuthResult {
  const StepUpAuthResult(this.outcome);

  final StepUpAuthOutcome outcome;

  bool get isGranted => outcome == StepUpAuthOutcome.granted;
}

/// Boundary for the external Step-Up mechanism required by API-0203.
///
/// The Scanner/Partner PDF marks reversal as Step-Up=true, but it does not
/// define how a client acquires or transports that proof. This abstraction
/// intentionally does not invent an endpoint, token field, or header.
abstract interface class StepUpAuthService {
  Future<StepUpAuthResult> authorizeRedemptionReverse();
}

class UnconfiguredStepUpAuthService extends GetxService
    implements StepUpAuthService {
  @override
  Future<StepUpAuthResult> authorizeRedemptionReverse() async {
    return const StepUpAuthResult(
      StepUpAuthOutcome.blockedByMissingContract,
    );
  }
}

class OfflineStepUpAuthService extends GetxService implements StepUpAuthService {
  @override
  Future<StepUpAuthResult> authorizeRedemptionReverse() async =>
      const StepUpAuthResult(StepUpAuthOutcome.granted);
}
