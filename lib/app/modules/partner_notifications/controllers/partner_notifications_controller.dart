import 'package:get/get.dart';

import '../../../services/partner_offline_extras_repository.dart';

class PartnerNotificationsController extends GetxController {
  PartnerNotificationsController(this.repository);

  final PartnerExtrasRepository repository;
  final notifications = <OfflinePartnerNotification>[].obs;
  final preferences = Rxn<OfflineNotificationPreferences>();
  final loading = true.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    notifications.assignAll(await repository.getNotifications());
    preferences.value = await repository.getNotificationPreferences();
    loading.value = false;
  }

  Future<void> markRead(OfflinePartnerNotification notification) async {
    await repository.markNotificationRead(notification.publicId);
    await load();
  }

  Future<void> markAllRead() async {
    await repository.markAllNotificationsRead();
    await load();
  }

  Future<void> toggleInApp(bool value) async {
    final current = preferences.value;
    if (current == null) return;
    preferences.value = await repository.updateNotificationPreferences(
      current.copyWith(inAppEnabled: value),
    );
  }

  Future<void> togglePush(bool value) async {
    final current = preferences.value;
    if (current == null) return;
    preferences.value = await repository.updateNotificationPreferences(
      current.copyWith(pushEnabled: value),
    );
  }
}
