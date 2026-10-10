import 'package:flutter/material.dart';

import '../../responsive/app_responsive.dart';
import '../../theme/app_aspect_ratio.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import 'bader_skeleton_box.dart';
import 'bader_skeleton_circle.dart';

class BaderInitiativeCardSkeleton extends StatelessWidget {
  const BaderInitiativeCardSkeleton({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isCompact = compact || width < 380;
        final radius = width < 380 ? AppRadius.xl : AppRadius.xxl;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: AppAspectRatio.contentMedia,
              child: BaderSkeletonBox(height: 1, radius: radius),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                isCompact ? AppSpacing.md : AppSpacing.lg,
                isCompact ? AppSpacing.sm : AppSpacing.md,
                isCompact ? AppSpacing.md : AppSpacing.lg,
                isCompact ? AppSpacing.md : AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BaderSkeletonBox(
                    width: isCompact ? 72 : 86,
                    height: isCompact ? 18 : 20,
                    radius: AppRadius.pill,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const FractionallySizedBox(
                    widthFactor: .78,
                    alignment: AlignmentDirectional.centerStart,
                    child: BaderSkeletonTextLine(height: 15),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  const FractionallySizedBox(
                    widthFactor: .56,
                    alignment: AlignmentDirectional.centerStart,
                    child: BaderSkeletonTextLine(height: 15),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      const BaderSkeletonCircle(diameter: 22),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            FractionallySizedBox(
                              widthFactor: .45,
                              alignment: AlignmentDirectional.centerStart,
                              child: BaderSkeletonTextLine(height: 10),
                            ),
                            SizedBox(height: AppSpacing.xs),
                            FractionallySizedBox(
                              widthFactor: .32,
                              alignment: AlignmentDirectional.centerStart,
                              child: BaderSkeletonTextLine(height: 9),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class BaderPostSkeleton extends StatelessWidget {
  const BaderPostSkeleton({
    super.key,
    required this.width,
    required this.height,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final mediaHeight = (height - 150).clamp(120.0, 900.0).toDouble();
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
            ),
            child: Row(
              children: [
                BaderSkeletonCircle(diameter: 38),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FractionallySizedBox(
                        widthFactor: .38,
                        alignment: AlignmentDirectional.centerStart,
                        child: BaderSkeletonTextLine(height: 11),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      FractionallySizedBox(
                        widthFactor: .22,
                        alignment: AlignmentDirectional.centerStart,
                        child: BaderSkeletonTextLine(height: 8),
                      ),
                    ],
                  ),
                ),
                BaderSkeletonCircle(diameter: 28),
              ],
            ),
          ),
          BaderSkeletonBox(
            height: mediaHeight,
            radius: 0,
            opacity: .28,
          ),
          const Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.xs,
            ),
            child: Row(
              children: [
                BaderSkeletonCircle(diameter: 26),
                SizedBox(width: AppSpacing.md),
                BaderSkeletonCircle(diameter: 26),
                SizedBox(width: AppSpacing.md),
                BaderSkeletonCircle(diameter: 26),
                Spacer(),
                BaderSkeletonCircle(diameter: 26),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FractionallySizedBox(
                  widthFactor: .68,
                  alignment: AlignmentDirectional.centerStart,
                  child: BaderSkeletonTextLine(height: 10),
                ),
                SizedBox(height: AppSpacing.xs),
                FractionallySizedBox(
                  widthFactor: .45,
                  alignment: AlignmentDirectional.centerStart,
                  child: BaderSkeletonTextLine(height: 9),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BaderAccountRowSkeleton extends StatelessWidget {
  const BaderAccountRowSkeleton({super.key, this.avatarSize = 50});

  final double avatarSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          BaderSkeletonCircle(diameter: avatarSize),
          const SizedBox(width: AppSpacing.md),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FractionallySizedBox(
                  widthFactor: .48,
                  alignment: AlignmentDirectional.centerStart,
                  child: BaderSkeletonTextLine(height: 12),
                ),
                SizedBox(height: AppSpacing.sm),
                FractionallySizedBox(
                  widthFactor: .66,
                  alignment: AlignmentDirectional.centerStart,
                  child: BaderSkeletonTextLine(height: 9),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BaderNotificationRowSkeleton extends StatelessWidget {
  const BaderNotificationRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return BaderSkeletonPanel(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BaderSkeletonCircle(diameter: 40),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Row(
                  children: [
                    Expanded(
                      child: FractionallySizedBox(
                        widthFactor: .64,
                        alignment: AlignmentDirectional.centerStart,
                        child: BaderSkeletonTextLine(height: 12),
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    BaderSkeletonTextLine(width: 44, height: 8),
                  ],
                ),
                SizedBox(height: AppSpacing.sm),
                FractionallySizedBox(
                  widthFactor: .88,
                  alignment: AlignmentDirectional.centerStart,
                  child: BaderSkeletonTextLine(height: 9),
                ),
                SizedBox(height: AppSpacing.xs),
                FractionallySizedBox(
                  widthFactor: .62,
                  alignment: AlignmentDirectional.centerStart,
                  child: BaderSkeletonTextLine(height: 9),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BaderCompactInitiativeRowSkeleton extends StatelessWidget {
  const BaderCompactInitiativeRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: const [
          SizedBox(
            width: 108,
            height: 60.75,
            child: BaderSkeletonBox(height: 60.75, radius: AppRadius.sm),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FractionallySizedBox(
                  widthFactor: .76,
                  alignment: AlignmentDirectional.centerStart,
                  child: BaderSkeletonTextLine(height: 12),
                ),
                SizedBox(height: AppSpacing.xs),
                FractionallySizedBox(
                  widthFactor: .54,
                  alignment: AlignmentDirectional.centerStart,
                  child: BaderSkeletonTextLine(height: 9),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BaderCompactPostRowSkeleton extends StatelessWidget {
  const BaderCompactPostRowSkeleton({super.key, this.withMedia = true});

  final bool withMedia;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BaderSkeletonCircle(diameter: 44),
          const SizedBox(width: AppSpacing.md),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FractionallySizedBox(
                  widthFactor: .48,
                  alignment: AlignmentDirectional.centerStart,
                  child: BaderSkeletonTextLine(height: 11),
                ),
                SizedBox(height: AppSpacing.sm),
                FractionallySizedBox(
                  widthFactor: .92,
                  alignment: AlignmentDirectional.centerStart,
                  child: BaderSkeletonTextLine(height: 9),
                ),
                SizedBox(height: AppSpacing.xs),
                FractionallySizedBox(
                  widthFactor: .65,
                  alignment: AlignmentDirectional.centerStart,
                  child: BaderSkeletonTextLine(height: 9),
                ),
              ],
            ),
          ),
          if (withMedia) ...[
            const SizedBox(width: AppSpacing.md),
            const BaderSkeletonBox(width: 78, height: 43.875, radius: AppRadius.sm),
          ],
        ],
      ),
    );
  }
}

class BaderSquareGridSkeleton extends StatelessWidget {
  const BaderSquareGridSkeleton({super.key, this.count = 6});

  final int count;

  @override
  Widget build(BuildContext context) {
    final columns = context.responsive.width >= 680 ? 4 : 3;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 3,
        mainAxisSpacing: 3,
      ),
      itemCount: count,
      itemBuilder: (_, __) => const AspectRatio(
        aspectRatio: 1,
        child: BaderSkeletonBox(height: 1, radius: AppRadius.xs),
      ),
    );
  }
}

class BaderProfileHeaderSkeleton extends StatelessWidget {
  const BaderProfileHeaderSkeleton({super.key, this.community = false});

  final bool community;

  @override
  Widget build(BuildContext context) {
    final pagePadding = context.responsive.horizontalPagePadding;
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        pagePadding,
        AppSpacing.xl,
        pagePadding,
        0,
      ),
      child: Column(
        children: [
          BaderSkeletonCircle(diameter: community ? 92 : 96),
          const SizedBox(height: AppSpacing.md),
          const FractionallySizedBox(
            widthFactor: .42,
            child: BaderSkeletonTextLine(height: 16),
          ),
          const SizedBox(height: AppSpacing.sm),
          const FractionallySizedBox(
            widthFactor: .30,
            child: BaderSkeletonTextLine(height: 10),
          ),
          const SizedBox(height: AppSpacing.md),
          const FractionallySizedBox(
            widthFactor: .72,
            child: BaderSkeletonTextLine(height: 10),
          ),
          const SizedBox(height: AppSpacing.xl),
          const Row(
            children: [
              Expanded(child: _StatSkeleton()),
              SizedBox(width: AppSpacing.md),
              Expanded(child: _StatSkeleton()),
              SizedBox(width: AppSpacing.md),
              Expanded(child: _StatSkeleton()),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          const BaderSkeletonBox(height: 50, radius: AppRadius.lg),
          const SizedBox(height: AppSpacing.xxl),
          const Row(
            children: [
              Expanded(child: BaderSkeletonTextLine(height: 12)),
              SizedBox(width: AppSpacing.xxl),
              Expanded(child: BaderSkeletonTextLine(height: 12)),
              SizedBox(width: AppSpacing.xxl),
              Expanded(child: BaderSkeletonTextLine(height: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatSkeleton extends StatelessWidget {
  const _StatSkeleton();

  @override
  Widget build(BuildContext context) => const Column(
        children: [
          FractionallySizedBox(
            widthFactor: .45,
            child: BaderSkeletonTextLine(height: 13),
          ),
          SizedBox(height: AppSpacing.xs),
          FractionallySizedBox(
            widthFactor: .65,
            child: BaderSkeletonTextLine(height: 9),
          ),
        ],
      );
}

class BaderApplicantRowSkeleton extends StatelessWidget {
  const BaderApplicantRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return BaderSkeletonPanel(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          const Row(
            children: [
              BaderSkeletonCircle(diameter: 44),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FractionallySizedBox(
                      widthFactor: .48,
                      alignment: AlignmentDirectional.centerStart,
                      child: BaderSkeletonTextLine(height: 12),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    FractionallySizedBox(
                      widthFactor: .26,
                      alignment: AlignmentDirectional.centerStart,
                      child: BaderSkeletonTextLine(height: 9),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              for (var i = 0; i < 3; i++) ...[
                const Expanded(
                  child: BaderSkeletonBox(height: 36, radius: AppRadius.pill),
                ),
                if (i != 2) const SizedBox(width: AppSpacing.sm),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class BaderScoreHistoryEntrySkeleton extends StatelessWidget {
  const BaderScoreHistoryEntrySkeleton({super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: BaderSkeletonPanel(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: const [
              BaderSkeletonCircle(diameter: 44),
              SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FractionallySizedBox(
                      widthFactor: .58,
                      alignment: AlignmentDirectional.centerStart,
                      child: BaderSkeletonTextLine(height: 11),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    FractionallySizedBox(
                      widthFactor: .74,
                      alignment: AlignmentDirectional.centerStart,
                      child: BaderSkeletonTextLine(height: 9),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    FractionallySizedBox(
                      widthFactor: .46,
                      alignment: AlignmentDirectional.centerStart,
                      child: BaderSkeletonTextLine(height: 8),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.md),
              BaderSkeletonTextLine(width: 54, height: 14),
            ],
          ),
        ),
      );
}

class BaderFormSkeleton extends StatelessWidget {
  const BaderFormSkeleton({
    super.key,
    this.showAvatar = false,
    this.showIntro = false,
    this.fieldCount = 5,
    this.showDocuments = false,
    this.showBottomAction = true,
  });

  final bool showAvatar;
  final bool showIntro;
  final int fieldCount;
  final bool showDocuments;
  final bool showBottomAction;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: context.responsive.pageInsets(top: 0, bottom: AppSpacing.pageBottom),
      children: [
        if (showAvatar) ...[
          const Center(child: BaderSkeletonCircle(diameter: 96)),
          const SizedBox(height: AppSpacing.xxl),
        ],
        if (showIntro) ...[
          const BaderSkeletonBox(height: 72, radius: AppRadius.lg),
          const SizedBox(height: AppSpacing.xl),
        ],
        for (var i = 0; i < fieldCount; i++) ...[
          const BaderSkeletonTextLine(width: 92, height: 9),
          const SizedBox(height: AppSpacing.sm),
          BaderSkeletonBox(
            height: i == fieldCount - 1 ? 96 : 54,
            radius: AppRadius.input,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        if (showDocuments) ...[
          const BaderSkeletonTextLine(width: 138, height: 13),
          const SizedBox(height: AppSpacing.sm),
          const FractionallySizedBox(
            widthFactor: .70,
            alignment: AlignmentDirectional.centerStart,
            child: BaderSkeletonTextLine(height: 9),
          ),
          const SizedBox(height: AppSpacing.md),
          const BaderSkeletonBox(height: 46, radius: AppRadius.md),
          const SizedBox(height: AppSpacing.xxl),
        ],
        if (showBottomAction) ...[
          const SizedBox(height: AppSpacing.sm),
          const BaderSkeletonBox(height: 52, radius: AppRadius.button),
        ],
      ],
    );
  }
}

class BaderInitiativeDetailsSkeleton extends StatelessWidget {
  const BaderInitiativeDetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final pagePadding = context.responsive.horizontalPagePadding;
    return Stack(
      children: [
        SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AspectRatio(
                    aspectRatio: AppAspectRatio.contentMedia,
                    child: BaderSkeletonBox(height: 1, radius: AppRadius.xxl),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                      pagePadding,
                      AppSpacing.xl,
                      pagePadding,
                      110,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        BaderSkeletonBox(width: 82, height: 20, radius: AppRadius.pill),
                        SizedBox(height: AppSpacing.md),
                        FractionallySizedBox(
                          widthFactor: .82,
                          alignment: AlignmentDirectional.centerStart,
                          child: BaderSkeletonTextLine(height: 18),
                        ),
                        SizedBox(height: AppSpacing.sm),
                        FractionallySizedBox(
                          widthFactor: .58,
                          alignment: AlignmentDirectional.centerStart,
                          child: BaderSkeletonTextLine(height: 12),
                        ),
                        SizedBox(height: AppSpacing.xxl),
                        Row(
                          children: [
                            BaderSkeletonCircle(diameter: 48),
                            SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FractionallySizedBox(
                                    widthFactor: .46,
                                    alignment: AlignmentDirectional.centerStart,
                                    child: BaderSkeletonTextLine(height: 12),
                                  ),
                                  SizedBox(height: AppSpacing.sm),
                                  FractionallySizedBox(
                                    widthFactor: .30,
                                    alignment: AlignmentDirectional.centerStart,
                                    child: BaderSkeletonTextLine(height: 9),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSpacing.xxl),
                        FractionallySizedBox(
                          widthFactor: .32,
                          alignment: AlignmentDirectional.centerStart,
                          child: BaderSkeletonTextLine(height: 14),
                        ),
                        SizedBox(height: AppSpacing.md),
                        FractionallySizedBox(
                          widthFactor: 1,
                          alignment: AlignmentDirectional.centerStart,
                          child: BaderSkeletonTextLine(height: 10),
                        ),
                        SizedBox(height: AppSpacing.sm),
                        FractionallySizedBox(
                          widthFactor: .92,
                          alignment: AlignmentDirectional.centerStart,
                          child: BaderSkeletonTextLine(height: 10),
                        ),
                        SizedBox(height: AppSpacing.sm),
                        FractionallySizedBox(
                          widthFactor: .70,
                          alignment: AlignmentDirectional.centerStart,
                          child: BaderSkeletonTextLine(height: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        PositionedDirectional(
          start: pagePadding,
          end: pagePadding,
          bottom: MediaQuery.paddingOf(context).bottom + AppSpacing.sm,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: const BaderSkeletonBox(height: 56, radius: AppRadius.xxl),
            ),
          ),
        ),
      ],
    );
  }
}

class BaderCommentsListSkeleton extends StatelessWidget {
  const BaderCommentsListSkeleton({super.key, this.count = 4});

  final int count;

  @override
  Widget build(BuildContext context) => ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: count,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.lg),
        itemBuilder: (_, index) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BaderSkeletonCircle(diameter: 36),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FractionallySizedBox(
                    widthFactor: index.isEven ? .42 : .34,
                    alignment: AlignmentDirectional.centerStart,
                    child: const BaderSkeletonTextLine(height: 10),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const BaderSkeletonBox(height: 54, radius: AppRadius.lg),
                ],
              ),
            ),
          ],
        ),
      );
}

class BaderFeaturedAccountsRailSkeleton extends StatelessWidget {
  const BaderFeaturedAccountsRailSkeleton({
    super.key,
    required this.height,
    required this.viewportFraction,
  });

  final double height;
  final double viewportFraction;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = (constraints.maxWidth * viewportFraction)
              .clamp(150.0, 250.0)
              .toDouble();
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            clipBehavior: Clip.hardEdge,
            padding: EdgeInsets.zero,
            itemCount: 3,
            separatorBuilder: (_, _) =>
            const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              return SizedBox(
                width: cardWidth,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    BaderSkeletonCircle(diameter: 78),
                    SizedBox(height: AppSpacing.md),
                    FractionallySizedBox(
                      widthFactor: .64,
                      child: BaderSkeletonTextLine(height: 12),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    FractionallySizedBox(
                      widthFactor: .46,
                      child: BaderSkeletonTextLine(height: 9),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class BaderFavoritePostRowSkeleton extends StatelessWidget {
  const BaderFavoritePostRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            BaderSkeletonBox(width: 46, height: 46, radius: AppRadius.md),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FractionallySizedBox(
                    widthFactor: .42,
                    alignment: AlignmentDirectional.centerStart,
                    child: BaderSkeletonTextLine(height: 10),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  FractionallySizedBox(
                    widthFactor: .92,
                    alignment: AlignmentDirectional.centerStart,
                    child: BaderSkeletonTextLine(height: 9),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  FractionallySizedBox(
                    widthFactor: .66,
                    alignment: AlignmentDirectional.centerStart,
                    child: BaderSkeletonTextLine(height: 9),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSpacing.md),
            BaderSkeletonBox(width: 18, height: 18, radius: AppRadius.xs),
          ],
        ),
      );
}

class BaderVolunteeringRowSkeleton extends StatelessWidget {
  const BaderVolunteeringRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: const [
            BaderSkeletonBox(width: 72, height: 72, radius: AppRadius.md),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FractionallySizedBox(
                    widthFactor: .72,
                    alignment: AlignmentDirectional.centerStart,
                    child: BaderSkeletonTextLine(height: 12),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  FractionallySizedBox(
                    widthFactor: .40,
                    alignment: AlignmentDirectional.centerStart,
                    child: BaderSkeletonTextLine(height: 9),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  BaderSkeletonBox(width: 68, height: 18, radius: AppRadius.pill),
                ],
              ),
            ),
          ],
        ),
      );
}

class BaderSearchSectionHeaderSkeleton extends StatelessWidget {
  const BaderSearchSectionHeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.sm),
        child: FractionallySizedBox(
          widthFactor: .34,
          alignment: AlignmentDirectional.centerStart,
          child: BaderSkeletonTextLine(height: 14),
        ),
      );
}

class BaderVolunteerFormSkeleton extends StatelessWidget {
  const BaderVolunteerFormSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    return Column(
      children: [
        Expanded(
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            padding: responsive.pageInsets(top: 0, bottom: AppSpacing.pageBottom),
            children: const [
              BaderSkeletonBox(height: 8, radius: AppRadius.pill),
              SizedBox(height: AppSpacing.xxl),
              FractionallySizedBox(
                widthFactor: .58,
                alignment: AlignmentDirectional.centerStart,
                child: BaderSkeletonTextLine(height: 18),
              ),
              SizedBox(height: AppSpacing.sm),
              FractionallySizedBox(
                widthFactor: .82,
                alignment: AlignmentDirectional.centerStart,
                child: BaderSkeletonTextLine(height: 10),
              ),
              SizedBox(height: AppSpacing.lg),
              BaderSkeletonBox(height: 72, radius: AppRadius.lg),
              SizedBox(height: AppSpacing.xxl),
              FractionallySizedBox(
                widthFactor: .46,
                alignment: AlignmentDirectional.centerStart,
                child: BaderSkeletonTextLine(height: 12),
              ),
              SizedBox(height: AppSpacing.sm),
              BaderSkeletonBox(height: 54, radius: AppRadius.input),
              SizedBox(height: AppSpacing.xl),
              FractionallySizedBox(
                widthFactor: .52,
                alignment: AlignmentDirectional.centerStart,
                child: BaderSkeletonTextLine(height: 12),
              ),
              SizedBox(height: AppSpacing.sm),
              BaderSkeletonBox(height: 54, radius: AppRadius.input),
              SizedBox(height: AppSpacing.xl),
              FractionallySizedBox(
                widthFactor: .34,
                alignment: AlignmentDirectional.centerStart,
                child: BaderSkeletonTextLine(height: 12),
              ),
              SizedBox(height: AppSpacing.sm),
              BaderSkeletonBox(height: 96, radius: AppRadius.input),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: BaderSkeletonBox(height: 52, radius: AppRadius.button),
        ),
      ],
    );
  }
}
