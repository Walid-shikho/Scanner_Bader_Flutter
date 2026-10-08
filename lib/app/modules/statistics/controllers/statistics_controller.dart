import 'package:get/get.dart';

import '../../../../core/network/api_error.dart';
import '../../../models/scanner_partner_models.dart';
import '../../../services/scanner_repository.dart';

enum StatisticsState { loading, loaded, permissionDenied, error }

class StatisticsController extends GetxController {
  StatisticsController(this.repository);

  final ScannerRepository repository;
  final state = StatisticsState.loading.obs;
  final statistics = Rxn<PartnerDailyStatisticsData>();
  final period = 'daily'.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    state.value = StatisticsState.loading;
    try {
      statistics.value = period.value == 'daily'
          ? await repository.getDailyStatistics()
          : await repository.getStatistics(period: period.value);
      state.value = StatisticsState.loaded;
    } on NormalizedApiError catch (error) {
      state.value = error.statusCode == 403
          ? StatisticsState.permissionDenied
          : StatisticsState.error;
    } catch (_) {
      state.value = StatisticsState.error;
    }
  }

  Future<void> setPeriod(String value) async {
    if (value == period.value) return;
    period.value = value;
    await load();
  }

}
