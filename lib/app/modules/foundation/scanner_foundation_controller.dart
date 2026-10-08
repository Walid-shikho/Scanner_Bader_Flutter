import 'package:get/get.dart';

import '../../services/scanner_repository.dart';

abstract class ScannerFoundationController extends GetxController {
  ScannerFoundationController(
    this.repository, {
    required this.titleKey,
    required this.messageKey,
  });

  final ScannerRepository repository;
  final String titleKey;
  final String messageKey;
}
