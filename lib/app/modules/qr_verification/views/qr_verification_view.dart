import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../widgets/foundation_feature_view.dart';
import '../controllers/qr_verification_controller.dart';

class QrVerificationView extends GetView<QrVerificationController> {
  const QrVerificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return FoundationFeatureView(
      titleKey: controller.titleKey,
      messageKey: controller.messageKey,
    );
  }
}
