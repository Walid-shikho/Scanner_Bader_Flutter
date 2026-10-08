import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../widgets/foundation_feature_view.dart';
import '../controllers/scanner_branches_controller.dart';

class ScannerBranchesView extends GetView<ScannerBranchesController> {
  const ScannerBranchesView({super.key});

  @override
  Widget build(BuildContext context) {
    return FoundationFeatureView(
      titleKey: controller.titleKey,
      messageKey: controller.messageKey,
    );
  }
}
