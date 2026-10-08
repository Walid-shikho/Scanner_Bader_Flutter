import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../auth/app_mode.dart';
import '../auth/app_mode_controller.dart';
import '../routes/app_routes.dart';

class ShellModeMiddleware extends GetMiddleware {
  ShellModeMiddleware({super.priority = -10});

  @override
  RouteSettings? redirect(String? route) {
    final controller = Get.find<AppModeController>();
    return controller.activeMode.value == null
        ? const RouteSettings(name: AppRoutes.login)
        : null;
  }
}

class AppModeMiddleware extends GetMiddleware {
  AppModeMiddleware(this.requiredMode, {super.priority = 0});

  final AppMode requiredMode;

  @override
  RouteSettings? redirect(String? route) {
    final controller = Get.find<AppModeController>();
    if (controller.activeMode.value == requiredMode) return null;
    return RouteSettings(name: AppRoutes.login, arguments: requiredMode);
  }
}
