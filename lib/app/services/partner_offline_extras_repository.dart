import 'package:get/get.dart';

import '../models/scanner_partner_models.dart';
import 'offline_repositories.dart';

class PartnerOperationalProfileUpdate {
  const PartnerOperationalProfileUpdate({
    required this.contactEmail,
    required this.contactPhone,
    required this.address,
    required this.description,
  });

  final String contactEmail;
  final String contactPhone;
  final String address;
  final String description;
}

class OfflinePartnerNotification {
  const OfflinePartnerNotification({
    required this.publicId,
    required this.titleAr,
    required this.titleEn,
    required this.titleDe,
    required this.bodyAr,
    required this.bodyEn,
    required this.bodyDe,
    required this.createdAt,
    this.read = false,
  });

  final String publicId;
  final String titleAr;
  final String titleEn;
  final String titleDe;
  final String bodyAr;
  final String bodyEn;
  final String bodyDe;
  final DateTime createdAt;
  final bool read;

  OfflinePartnerNotification copyWith({bool? read}) => OfflinePartnerNotification(
        publicId: publicId,
        titleAr: titleAr,
        titleEn: titleEn,
        titleDe: titleDe,
        bodyAr: bodyAr,
        bodyEn: bodyEn,
        bodyDe: bodyDe,
        createdAt: createdAt,
        read: read ?? this.read,
      );
}

class OfflineNotificationPreferences {
  const OfflineNotificationPreferences({
    required this.inAppEnabled,
    required this.pushEnabled,
  });

  final bool inAppEnabled;
  final bool pushEnabled;

  OfflineNotificationPreferences copyWith({
    bool? inAppEnabled,
    bool? pushEnabled,
  }) => OfflineNotificationPreferences(
        inAppEnabled: inAppEnabled ?? this.inAppEnabled,
        pushEnabled: pushEnabled ?? this.pushEnabled,
      );
}

abstract interface class PartnerExtrasRepository {
  Future<PartnerDetail> updateOperationalProfile(
    PartnerOperationalProfileUpdate update,
  );
  Future<List<OfflinePartnerNotification>> getNotifications();
  Future<void> markNotificationRead(String publicId);
  Future<void> markAllNotificationsRead();
  Future<OfflineNotificationPreferences> getNotificationPreferences();
  Future<OfflineNotificationPreferences> updateNotificationPreferences(
    OfflineNotificationPreferences preferences,
  );
}

class OfflinePartnerExtrasRepository extends GetxService
    implements PartnerExtrasRepository {
  OfflinePartnerExtrasRepository(this.state);

  final OfflineDemoState state;

  final List<OfflinePartnerNotification> _notifications = <OfflinePartnerNotification>[
    OfflinePartnerNotification(
      publicId: 'offline-notification-1',
      titleAr: 'تم تنفيذ عملية استرداد',
      titleEn: 'Redemption completed',
      titleDe: 'Einlösung abgeschlossen',
      bodyAr: 'تمت إضافة عملية استرداد تجريبية جديدة إلى سجل الفرع الرئيسي.',
      bodyEn: 'A new demo redemption was added to the main branch history.',
      bodyDe: 'Eine neue Demo-Einlösung wurde zum Verlauf der Hauptfiliale hinzugefügt.',
      createdAt: DateTime.utc(2026, 10, 6, 8, 30),
    ),
    OfflinePartnerNotification(
      publicId: 'offline-notification-2',
      titleAr: 'العرض جاهز للتجربة',
      titleEn: 'Offer ready for demo',
      titleDe: 'Angebot für Demo bereit',
      bodyAr: 'يمكنك تعديل العرض أو تفعيله أو تعطيله محلياً.',
      bodyEn: 'You can edit, activate, or disable the offer locally.',
      bodyDe: 'Sie können das Angebot lokal bearbeiten, aktivieren oder deaktivieren.',
      createdAt: DateTime.utc(2026, 10, 5, 15, 0),
      read: true,
    ),
    OfflinePartnerNotification(
      publicId: 'offline-notification-3',
      titleAr: 'تذكير بإعدادات الفرع',
      titleEn: 'Branch settings reminder',
      titleDe: 'Erinnerung an Filialeinstellungen',
      bodyAr: 'جرّب إنشاء فرع جديد وتعديل بياناته ضمن Offline Demo.',
      bodyEn: 'Try creating a new branch and editing it in Offline Demo.',
      bodyDe: 'Erstellen und bearbeiten Sie testweise eine Filiale im Offline-Demo.',
      createdAt: DateTime.utc(2026, 10, 4, 10, 0),
    ),
  ];

  OfflineNotificationPreferences _preferences = const OfflineNotificationPreferences(
    inAppEnabled: true,
    pushEnabled: true,
  );

  @override
  Future<PartnerDetail> updateOperationalProfile(
    PartnerOperationalProfileUpdate update,
  ) => state.engine.offlineUpdateOperationalProfile(
        contactEmail: update.contactEmail,
        contactPhone: update.contactPhone,
        address: update.address,
        description: update.description,
      );

  @override
  Future<List<OfflinePartnerNotification>> getNotifications() async =>
      List<OfflinePartnerNotification>.unmodifiable(_notifications);

  @override
  Future<void> markNotificationRead(String publicId) async {
    final index = _notifications.indexWhere((item) => item.publicId == publicId);
    if (index >= 0) _notifications[index] = _notifications[index].copyWith(read: true);
  }

  @override
  Future<void> markAllNotificationsRead() async {
    for (var index = 0; index < _notifications.length; index += 1) {
      _notifications[index] = _notifications[index].copyWith(read: true);
    }
  }

  @override
  Future<OfflineNotificationPreferences> getNotificationPreferences() async =>
      _preferences;

  @override
  Future<OfflineNotificationPreferences> updateNotificationPreferences(
    OfflineNotificationPreferences preferences,
  ) async {
    _preferences = preferences;
    return _preferences;
  }
}

class UnconfiguredPartnerExtrasRepository implements PartnerExtrasRepository {
  const UnconfiguredPartnerExtrasRepository();

  Never _blocked() => throw StateError('PARTNER_EXTRAS_PRODUCTION_NOT_WIRED_HERE');

  @override
  Future<List<OfflinePartnerNotification>> getNotifications() async => _blocked();
  @override
  Future<OfflineNotificationPreferences> getNotificationPreferences() async => _blocked();
  @override
  Future<void> markAllNotificationsRead() async => _blocked();
  @override
  Future<void> markNotificationRead(String publicId) async => _blocked();
  @override
  Future<OfflineNotificationPreferences> updateNotificationPreferences(
    OfflineNotificationPreferences preferences,
  ) async => _blocked();
  @override
  Future<PartnerDetail> updateOperationalProfile(
    PartnerOperationalProfileUpdate update,
  ) async => _blocked();
}
