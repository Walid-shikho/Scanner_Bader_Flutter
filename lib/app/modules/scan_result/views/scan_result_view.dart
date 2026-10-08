import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../widgets/foundation_feature_view.dart';
import '../controllers/scan_result_controller.dart';

class ScanResultView extends GetView<ScanResultController> {
  const ScanResultView({super.key});

  @override
  Widget build(BuildContext context) {
    return FoundationFeatureView(
      titleKey: controller.titleKey,
      messageKey: controller.messageKey,
    );
  }
}
