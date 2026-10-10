import 'package:get/get.dart';

import '../../../../core/storage/local_storage_service.dart';
import '../../../auth/app_mode_controller.dart';
import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  SplashController(this.modeController, this.storage);

  final AppModeController modeController;
  final LocalStorageService storage;

  Future<String> resolveDestination() async {
    final mode = await modeController.bootstrap();
    if (mode != null) return AppRoutes.shell;
    return storage.getBool(StorageKeys.onboardingSeen)
        ? AppRoutes.login
        : AppRoutes.onboarding;
  }
}
