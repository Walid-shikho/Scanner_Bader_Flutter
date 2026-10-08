import 'package:get/get.dart';

import '../../../../core/network/api_error.dart';
import '../../../models/scanner_partner_models.dart';
import '../../../services/scanner_repository.dart';

enum ScannerDevicesState { loading, loaded, permissionDenied, error }

class ScannerDevicesController extends GetxController {
  ScannerDevicesController(this.repository);

  final ScannerRepository repository;

  final state = ScannerDevicesState.loading.obs;
  final devices = <ScannerDeviceData>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    state.value = ScannerDevicesState.loading;
    try {
      devices.assignAll(await repository.getScannerDevices());
      state.value = ScannerDevicesState.loaded;
    } on NormalizedApiError catch (error) {
      state.value = error.statusCode == 403
          ? ScannerDevicesState.permissionDenied
          : ScannerDevicesState.error;
    } catch (_) {
      state.value = ScannerDevicesState.error;
    }
  }
}
