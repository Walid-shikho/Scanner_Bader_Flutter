import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../widgets/foundation_feature_view.dart';
import '../controllers/scanner_context_controller.dart';

class ScannerContextView extends GetView<ScannerContextController> {
  const ScannerContextView({super.key});

  @override
  Widget build(BuildContext context) {
    return FoundationFeatureView(
      titleKey: controller.titleKey,
      messageKey: controller.messageKey,
    );
  }
}
