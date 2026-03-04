import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sem_dsn/core/constants/app_border_radius.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';
import 'package:sem_dsn/widget/article_detail_args.dart';
import 'package:sem_dsn/widget/article_content_card.dart';
import 'package:sem_dsn/services/selection_service.dart';
import 'package:sem_dsn/widget/detail_app_bar_star.dart';
import 'package:sem_dsn/widget/other_news_section.dart';

/// Layout Hero / À la une : image pleine avec gradient, tag/titre/date sur l'image,
/// carte de lecture avec bord arrondi en haut qui monte au scroll.
class ArticleDetailHeroLayout extends StatelessWidget {
  const ArticleDetailHeroLayout({
    super.key,
    required this.args,
    required this.scrollController,
    required this.showTitleInAppBar,
    required this.isStarSelected,
    required this.onStarTap,
    required this.onShare,
    this.onOtherNewsArticleTap,
  });

  final ArticleDetailArgs args;
  final ScrollController scrollController;
  final bool showTitleInAppBar;
  final bool isStarSelected;
  final VoidCallback onStarTap;
  final void Function(BuildContext buttonContext) onShare;
  final void Function(ArticleDetailArgs args)? onOtherNewsArticleTap;

  @override
  Widget build(BuildContext context) {
    final isOverImage = !showTitleInAppBar;
    final iconColor = isOverImage ? Colors.white : AppColors.blackIcon;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isOverImage
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: AppColors.bg,
        body: CustomScrollView(
          clipBehavior: Clip.none,
          controller: scrollController,
          slivers: [
            SliverAppBar(
              expandedHeight: 400,
              pinned: true,
              stretch: true,
              backgroundColor: AppColors.bg,
              surfaceTintColor: Colors.transparent,
              toolbarHeight: kToolbarHeight,
              collapsedHeight: kToolbarHeight,
              leading: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      color: iconColor,
                      size: 22,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(8),
                      minimumSize: const Size(40, 40),
                    ),
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DetailAppBarStar(
                        isSelected: isStarSelected,
                        onTap: onStarTap,
                        iconColor: iconColor,
                      ),
                      const SizedBox(width: 4),
                      Builder(
                        builder: (buttonContext) => IconButton(
                          icon: Icon(Icons.share, color: iconColor, size: 22),
                          onPressed: () => onShare(buttonContext),
                          style: IconButton.styleFrom(
                            padding: const EdgeInsets.all(8),
                            minimumSize: const Size(40, 40),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              titleSpacing: 0,
              centerTitle: true,
              title: showTitleInAppBar
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: Center(
                        child: Text(
                          args.title,
                          style: const TextStyle(
                            color: AppColors.onSurfaceLight,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                  : null,
              flexibleSpace: FlexibleSpaceBar(
                background: LayoutBuilder(
                  builder: (context, constraints) {
                    final topP = MediaQuery.paddingOf(context).top;
                    final isCollapsed =
                        constraints.maxHeight <= topP + kToolbarHeight + 10;
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        Hero(
                          tag: args.heroTag,
                          child: Image.asset(
                            args.imagePath,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                        if (args.isVideo)
                          Center(
                            child: Hero(
                              tag: args.heroTagVideoPlay,
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withValues(alpha: 0.5),
                                ),
                                child: const Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                  size: 48,
                                ),
                              ),
                            ),
                          ),
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0x66000000),
                                Colors.transparent,
                                Color(0x99000000),
                              ],
                              stops: [0.0, 0.25, 1.0],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 74,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.heroTag,
                                  borderRadius: AppBorderRadius.rtotal,
                                ),
                                child: Text(
                                  args.tag,
                                  style: const TextStyle(
                                    color: AppColors.whiteTextColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                args.title,
                                style: const TextStyle(
                                  color: AppColors.whiteTextColor,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (args.date.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  args.date,
                                  style: TextStyle(
                                    color: AppColors.whiteTextColor.withValues(
                                      alpha: 0.9,
                                    ),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (isCollapsed)
                          Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: AppColors.bg,
                          ),
                      ],
                    );
                  },
                ),
                stretchModes: const [
                  StretchMode.zoomBackground,
                  StretchMode.blurBackground,
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: ArticleContentCard(
                title: args.title,
                date: args.date,
                tag: args.tag,
                body: args.body,
                showTagTitleDate: false,
                heroCapDrawnAbove: false,
              ),
            ),
            if (args.showOtherNews)
              ...buildOtherNewsSlivers(
                selectionService: SelectionService.instance,
                onArticleTap: onOtherNewsArticleTap,
              ),
            if (!args.showOtherNews)
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}
