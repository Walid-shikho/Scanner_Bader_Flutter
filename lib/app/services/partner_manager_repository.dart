import '../models/scanner_partner_models.dart';

/// Partner-manager-only repository boundary. Partner controllers depend on
/// this interface so Scanner APIs cannot leak into the Partner surface.
abstract interface class PartnerManagerRepository {
  Future<PartnerDetail> getPartnerProfile();
  Future<PartnerDetail> requestPartnerProfileChange(
    RequestPartnerProfileChangeRequest request, {
    required String idempotencyKey,
  });
  Future<PagedResult<PartnerBranchData>> getPartnerBranches({
    ListQuery query = const ListQuery(),
  });
  Future<PartnerBranchData> createPartnerBranch(
    CreatePartnerBranchRequest request, {
    required String idempotencyKey,
  });
  Future<VersionedResource<PartnerBranchData>> getPartnerBranchForEdit(
    String branchPublicId,
  );
  Future<VersionedResource<PartnerBranchData>> updatePartnerBranch(
    String branchPublicId,
    UpdatePartnerBranchRequest request,
  );
  Future<PagedResult<PartnerMembershipData>> getPartnerMemberships({
    ListQuery query = const ListQuery(),
  });
  Future<PagedResult<OfferDetails>> getPartnerOffers({
    ListQuery query = const ListQuery(),
  });
  Future<OfferDetails> createPartnerOffer(
    CreatePartnerOfferRequest request, {
    required String idempotencyKey,
  });
  Future<VersionedResource<OfferDetails>> getPartnerOfferForEdit(
    String offerPublicId,
  );
  Future<VersionedResource<OfferDetails>> updatePartnerOffer(
    String offerPublicId,
    UpdatePartnerOfferRequest request,
  );
  Future<OfferDetails> activatePartnerOffer(
    String offerPublicId, {
    required String idempotencyKey,
  });
  Future<OfferDetails> disablePartnerOffer(
    String offerPublicId,
    DisablePartnerOfferRequest request, {
    required String idempotencyKey,
  });
}
