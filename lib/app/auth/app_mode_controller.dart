import 'package:get/get.dart';
import 'app_mode.dart';
import 'app_mode_store.dart';
import '../services/scanner_auth_session_gateway.dart';

class AppModeController extends GetxService {
  AppModeController(this.store, this.auth);
  final AppModeStore store;
  final ScannerAuthSessionGateway auth;
  final activeMode = Rxn<AppMode>();

  Future<AppMode?> bootstrap() async {
    final mode = await auth.init();
    activeMode.value = mode;
    return mode;
  }

  Future<void> activate(AppMode mode) async {
    await auth.switchMode(mode);
    activeMode.value = mode;
  }

  Future<void> markAuthenticated(AppMode mode) async {
    await store.writeActiveMode(mode);
    activeMode.value = mode;
  }

  Future<void> clearActive() async {
    await store.clearActiveMode();
    activeMode.value = null;
  }
}
