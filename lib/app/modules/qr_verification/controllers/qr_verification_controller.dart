import '../../foundation/scanner_foundation_controller.dart';
import '../../../services/scanner_repository.dart';

class QrVerificationController extends ScannerFoundationController {
  QrVerificationController(ScannerRepository repository)
      : super(
          repository,
          titleKey: 'qr_verification',
          messageKey: 'phase3_qr_verification_message',
        );
}
