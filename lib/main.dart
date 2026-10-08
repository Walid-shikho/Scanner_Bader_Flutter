  import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

import 'app/auth/app_mode_controller.dart';
import 'app/auth/app_mode_store.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/services/api_scanner_partner_repository.dart';
import 'app/services/api_taxonomy_sources.dart';
import 'app/services/final_contract_api_service.dart';
import 'app/services/idempotency_key_factory.dart';
import 'app/services/offline_auth_session_gateway.dart';
import 'app/services/offline_repositories.dart';
import 'app/services/partner_card_type_taxonomy_repository.dart';
import 'app/services/partner_location_taxonomy_source.dart';
import 'app/services/partner_manager_repository.dart';
import 'app/services/partner_offline_extras_repository.dart';
import 'app/services/partner_type_taxonomy_source.dart';
import 'app/services/prelogin_identifier_provider.dart';
import 'app/services/production_security_services.dart';
import 'app/services/production_session_store.dart';
import 'app/services/production_repository_adapters.dart';
import 'app/services/qr_scanner_adapter.dart';
import 'app/services/scanner_auth_session_gateway.dart';
import 'app/services/scanner_location_provider.dart';
import 'app/services/scanner_partner_repository.dart';
import 'app/services/scanner_repository.dart';
import 'app/services/step_up_auth_service.dart';
import 'app/services/uploaded_file_reference_repository.dart';
import 'core/config/app_config.dart';
import 'core/config/app_environment.dart';
import 'core/localization/app_locale_service.dart';
import 'core/network/http_api_transport.dart';
import 'core/network/request_id_factory.dart';
import 'core/storage/local_storage_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_service.dart';
import 'core/translations/app_translations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(
    const [DeviceOrientation.portraitUp],
  );
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  final storage = await Get.putAsync<LocalStorageService>(
    () => LocalStorageService().init(),
    permanent: true,
  );
  final localeService = await Get.putAsync<AppLocaleService>(
    () => AppLocaleService(storage).init(),
    permanent: true,
  );
  final themeService = await Get.putAsync<ThemeService>(
    () => ThemeService(storage).init(),
    permanent: true,
  );

  if (AppConfig.environment == AppEnvironment.offlineDemo) {
    await _configureOfflineRuntime();
  } else {
    await _configureProductionRuntime(localeService);
  }

  runApp(
    ScannerPartnerApp(
      initialLocale: localeService.locale.value,
      initialThemeMode: themeService.themeMode.value,
    ),
  );
}

Future<void> _configureOfflineRuntime() async {
  final modeStore = SharedPreferencesAppModeStore();
  final authGateway = OfflineAuthSessionGateway(modeStore);
  final state = OfflineDemoState();
  final scannerRepository = OfflineScannerRepository(state);
  final partnerRepository = OfflinePartnerManagerRepository(state);

  Get.put<AppModeStore>(modeStore, permanent: true);
  Get.put<ScannerAuthSessionGateway>(authGateway, permanent: true);
  Get.put<AppModeController>(AppModeController(modeStore, authGateway), permanent: true);
  Get.put<OfflineDemoState>(state, permanent: true);
  Get.put<ScannerRepository>(scannerRepository, permanent: true);
  Get.put<PartnerManagerRepository>(partnerRepository, permanent: true);
  Get.put<PartnerExtrasRepository>(OfflinePartnerExtrasRepository(state), permanent: true);
  Get.put<PartnerTypeTaxonomySource>(OfflinePartnerTypeTaxonomySource(), permanent: true);
  Get.put<PartnerLocationTaxonomySource>(OfflinePartnerLocationTaxonomySource(), permanent: true);
  Get.put<PartnerCardTypeTaxonomyRepository>(OfflinePartnerCardTypeTaxonomyRepository(), permanent: true);
  Get.put<UploadedFileReferenceRepository>(MockUploadedFileReferenceRepository(), permanent: true);
  Get.put<QrScannerAdapter>(OfflineQrScannerAdapter(), permanent: true);
  Get.put<ScannerLocationProvider>(MockScannerLocationProvider(), permanent: true);
  Get.put<IdempotencyKeyFactory>(DefaultIdempotencyKeyFactory(), permanent: true);
  Get.put<StepUpAuthService>(OfflineStepUpAuthService(), permanent: true);
}

/// Production wiring is deliberately preserved for the future production build.
/// Phase 15 does not invoke this function while AppConfig.environment is offlineDemo.
Future<void> _configureProductionRuntime(AppLocaleService localeService) async {
  final requestIds = SecureRequestIdFactory();
  final apiTransport = HttpApiTransport(origin: Uri.parse(AppConfig.apiOrigin));
  final sessionStore = SecureProductionSessionStore();
  final modeStore = SharedPreferencesAppModeStore();
  final authGateway = ApiScannerAuthSessionGateway(
    transport: apiTransport,
    store: sessionStore,
    modeStore: modeStore,
    requestIds: requestIds,
    acceptLanguage: () => localeService.locale.value.languageCode,
  );
  const sensitiveSecurity = FailClosedSensitiveRequestSecurityProvider();
  final apiRepository = ApiScannerPartnerRepository(
    transport: apiTransport,
    sessionStore: sessionStore,
    requestIds: requestIds,
    acceptLanguage: () => localeService.locale.value.languageCode,
    sensitiveSecurity: sensitiveSecurity,
    authGateway: authGateway,
  );

  Get.put<AppModeStore>(modeStore, permanent: true);
  Get.put<ProductionSessionStore>(sessionStore, permanent: true);
  Get.put<ScannerAuthSessionGateway>(authGateway, permanent: true);
  Get.put<AppModeController>(AppModeController(modeStore, authGateway), permanent: true);
  Get.put<FinalContractApiService>(
    FinalContractApiService(
      transport: apiTransport,
      sessions: sessionStore,
      auth: authGateway,
      requestIds: requestIds,
      acceptLanguage: () => localeService.locale.value.languageCode,
      security: sensitiveSecurity,
      idempotency: DefaultIdempotencyKeyFactory(),
    ),
    permanent: true,
  );
  Get.put<ScannerPartnerRepository>(apiRepository, permanent: true);
  Get.put<ScannerRepository>(ApiScannerRepository(apiRepository), permanent: true);
  Get.put<PartnerManagerRepository>(ApiPartnerManagerRepository(apiRepository), permanent: true);
  Get.put<PartnerExtrasRepository>(const UnconfiguredPartnerExtrasRepository(), permanent: true);
  Get.put<PreLoginIdentifierProvider>(const UnconfiguredPreLoginIdentifierProvider(), permanent: true);
  Get.put<PartnerTypeTaxonomySource>(
    ApiPartnerTypeTaxonomySource(
      transport: apiTransport,
      requestIds: requestIds,
      acceptLanguage: () => localeService.locale.value.languageCode,
    ),
    permanent: true,
  );
  Get.put<PartnerLocationTaxonomySource>(
    ApiPartnerLocationTaxonomySource(
      transport: apiTransport,
      requestIds: requestIds,
      acceptLanguage: () => localeService.locale.value.languageCode,
    ),
    permanent: true,
  );
  Get.put<PartnerCardTypeTaxonomyRepository>(const BlockedPartnerCardTypeTaxonomyRepository(), permanent: true);
  Get.put<UploadedFileReferenceRepository>(const BlockedUploadedFileReferenceRepository(), permanent: true);
  Get.put<QrScannerAdapter>(UnavailableQrScannerAdapter(), permanent: true);
  Get.put<ScannerLocationProvider>(NoLocationScannerLocationProvider(), permanent: true);
  Get.put<IdempotencyKeyFactory>(DefaultIdempotencyKeyFactory(), permanent: true);
  Get.put<StepUpAuthService>(UnconfiguredStepUpAuthService(), permanent: true);
}

class ScannerPartnerApp extends StatelessWidget {
  const ScannerPartnerApp({
    super.key,
    required this.initialLocale,
    required this.initialThemeMode,
  });

  final Locale initialLocale;
  final ThemeMode initialThemeMode;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Scanner Partner',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
      translations: AppTranslations(),
      locale: initialLocale,
      fallbackLocale: const Locale('ar'),
      supportedLocales: AppLocaleService.supported,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: initialThemeMode,
      defaultTransition:
          GetPlatform.isIOS ? Transition.cupertino : Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 220),
      builder: (context, child) {
        final locale = Localizations.maybeLocaleOf(context) ?? initialLocale;
        final baseTheme = Theme.of(context);
        return Theme(
          data: AppTheme.withLocaleFont(baseTheme, locale),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
