import 'package:get/get.dart';

import '../../../models/redemption_flow_models.dart';

class RedemptionReceiptController extends GetxController {
  RedemptionReceiptArgs? receiptArgs;

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments;
    if (arguments is RedemptionReceiptArgs) {
      receiptArgs = arguments;
    }
  }
}
