import 'package:flutter_test/flutter_test.dart';
import 'package:scanner_partner/app/models/scanner_partner_model_codecs.dart';
import 'package:scanner_partner/app/models/scanner_partner_models.dart';
import 'package:scanner_partner/app/services/mock_scanner_partner_repository.dart';
import 'package:scanner_partner/app/services/partner_location_taxonomy_source.dart';
import 'package:scanner_partner/core/network/api_error.dart';

void main() {
  test('protected profile change uses API-0210 request shape only', () {
    const request = RequestPartnerProfileChangeRequest(
      changes: PartnerProfileChanges(
        displayName: ContractPatchField<String>.present('Updated Partner'),
        contactPhone: ContractPatchField<String>.present('+963900000000'),
      ),
      reason: 'Business contact changed',
    );

    expect(request.toJson(), <String, dynamic>{
      'changes': <String, dynamic>{
        'display_name': 'Updated Partner',
        'contact_phone': '+963900000000',
      },
      'reason': 'Business contact changed',
    });
  });

  test('province/city taxonomy is deterministic and production-blocked', () async {
    final source = MockPartnerLocationTaxonomySource();
    final provinces = await source.getProvinces();
    final cities = await source.getCities(
      provincePublicId: provinces.first.publicId,
    );

    expect(source.productionReady, isFalse);
    expect(
      source.productionBlocker,
      'BLOCKED_BY_SHARED_PROVINCE_CITY_TAXONOMY_CONTRACT',
    );
    expect(provinces, isNotEmpty);
    expect(cities, isNotEmpty);
  });

  test('branch creation persists in deterministic mock list', () async {
    final repository = MockScannerPartnerRepository();
    final before = await repository.getPartnerBranches();

    final created = await repository.createPartnerBranch(
      const CreatePartnerBranchRequest(
        name: 'New Branch',
        address: 'Damascus',
        provincePublicId: 'province-id',
        cityPublicId: 'city-id',
      ),
      idempotencyKey: 'phase9-create-branch',
    );

    final after = await repository.getPartnerBranches();
    expect(after.items.length, before.items.length + 1);
    expect(after.items.any((item) => item.publicId == created.publicId), isTrue);
  });

  test('branch edit retains ETag and stale If-Match yields 412', () async {
    final repository = MockScannerPartnerRepository();
    final branches = await repository.getPartnerBranches();
    final id = branches.items.first.publicId;
    final snapshot = await repository.getPartnerBranchForEdit(id);

    final updated = await repository.updatePartnerBranch(
      id,
      const UpdatePartnerBranchRequest(
        name: ContractPatchField<String>.present('Updated Branch'),
      ),
    );

    expect(updated.data.nameAr, 'Updated Branch');
    expect(updated.etag, isNot(snapshot.etag));

    try {
      await repository.updatePartnerBranch(
        id,
        const UpdatePartnerBranchRequest(
          phone: ContractPatchField<String>.present('+963900000001'),
        ),
      );
      fail('Expected stale If-Match to be rejected');
    } on NormalizedApiError catch (error) {
      expect(error.statusCode, 412);
      expect(error.errors.first.code, 'FAILED_PRECONDITION');
    }
  });

  test('scanner devices remain read-only data from API-0194 abstraction', () async {
    final repository = MockScannerPartnerRepository();
    final devices = await repository.getScannerDevices();

    expect(devices, isNotEmpty);
    expect(devices.first.status, isNotEmpty);
    expect(devices.first.trustLevel, isNotEmpty);
  });
}
