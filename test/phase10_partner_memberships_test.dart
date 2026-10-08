import 'package:flutter_test/flutter_test.dart';
import 'package:scanner_partner/app/models/scanner_partner_models.dart';
import 'package:scanner_partner/app/services/mock_scanner_partner_repository.dart';

void main() {
  test('API-0214 mock supports cursor pagination without mutation semantics', () async {
    final repository = MockScannerPartnerRepository();

    final first = await repository.getPartnerMemberships(
      query: const ListQuery(limit: 1),
    );

    expect(first.items, hasLength(1));
    expect(first.pagination.hasMore, isTrue);
    expect(first.pagination.nextCursor, isNotNull);

    final second = await repository.getPartnerMemberships(
      query: ListQuery(
        limit: 1,
        cursor: first.pagination.nextCursor,
      ),
    );

    expect(second.items, hasLength(1));
    expect(second.items.first.publicId, isNot(first.items.first.publicId));
  });

  test('API-0214 mock supports q search and returns branch data when present', () async {
    final repository = MockScannerPartnerRepository();

    final page = await repository.getPartnerMemberships(
      query: const ListQuery(q: 'Second Branch'),
    );

    expect(page.items, hasLength(1));
    expect(page.items.single.branch, isNotNull);
    expect(page.items.single.branch!.nameEn, 'Second Branch');
    expect(page.items.single.roleCode, 'scanner');
    expect(page.items.single.status, 'active');
  });

  test('API-0214 membership branch remains nullable', () async {
    final repository = MockScannerPartnerRepository();

    final page = await repository.getPartnerMemberships();

    expect(page.items.any((item) => item.branch == null), isTrue);
  });
}
