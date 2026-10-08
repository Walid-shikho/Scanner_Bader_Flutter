import 'package:get/get.dart';

import 'scanner_partner_repository.dart';

/// A reference to a file that already exists in the shared file system.
///
/// This is intentionally not an upload DTO. The Scanner contract only accepts
/// `file_public_id`; it does not define how a file is uploaded or created.
class UploadedFileReference {
  const UploadedFileReference({
    required this.publicId,
    required this.displayName,
  });

  final String publicId;
  final String displayName;
}

enum UploadedFilePurpose {
  partnerLogo,
}

/// Abstraction over already-uploaded files available for selection.
///
/// Production file upload/presign behavior is explicitly outside this
/// interface until the shared file contract is supplied.
abstract interface class UploadedFileReferenceRepository {
  Future<List<UploadedFileReference>> getAvailableFiles({
    required UploadedFilePurpose purpose,
  });

  bool get productionReady;
  String get integrationStatus;
}

class MockUploadedFileReferenceRepository extends GetxService
    implements UploadedFileReferenceRepository {
  static const blockedStatus = 'BLOCKED_BY_SHARED_FILE_UPLOAD_CONTRACT';

  static const _logoFiles = <UploadedFileReference>[
    UploadedFileReference(
      publicId: '0198c201-7b8c-7a12-9abc-1234567890ab',
      displayName: 'partner-logo.png',
    ),
  ];


  @override
  bool get productionReady => false;

  @override
  String get integrationStatus => blockedStatus;

  @override
  Future<List<UploadedFileReference>> getAvailableFiles({
    required UploadedFilePurpose purpose,
  }) async {
    final values = switch (purpose) {
      UploadedFilePurpose.partnerLogo => _logoFiles,
    };
    return List<UploadedFileReference>.unmodifiable(values);
  }
}

class BlockedUploadedFileReferenceRepository
    implements UploadedFileReferenceRepository {
  const BlockedUploadedFileReferenceRepository();

  @override
  bool get productionReady => false;

  @override
  String get integrationStatus =>
      'BLOCKED_BY_FILE_UPLOAD_PARTNER_PRINCIPAL_CONTRACT';

  @override
  Future<List<UploadedFileReference>> getAvailableFiles({
    required UploadedFilePurpose purpose,
  }) {
    throw const ScannerContractGapException(
      'BLOCKED_BY_FILE_UPLOAD_PARTNER_PRINCIPAL_CONTRACT',
    );
  }
}
