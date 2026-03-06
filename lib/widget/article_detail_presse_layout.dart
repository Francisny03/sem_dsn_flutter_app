import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';
import 'package:sem_dsn/widget/article_detail_args.dart';
import 'package:sem_dsn/widget/article_content_card.dart';
import 'package:sem_dsn/widget/article_sources_section.dart';
import 'package:sem_dsn/widget/article_video_player.dart';
import 'package:sem_dsn/widget/image_from_path.dart';
import 'package:sem_dsn/services/selection_service.dart';
import 'package:sem_dsn/widget/detail_app_bar_star.dart';
import 'package:sem_dsn/widget/other_news_section.dart';

/// Layout Presse / Campagne / Réalisation : AppBar avec bg, image + play,
/// puis tag / titre / date / description. Au scroll, titre dans l'app bar.
class ArticleDetailPresseLayout extends StatelessWidget {
  const ArticleDetailPresseLayout({
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

  static const double _imageHeight = 280;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          backgroundColor: AppColors.bg,
          elevation: 0,
          scrolledUnderElevation: 0,
          toolbarHeight: kToolbarHeight,
          leadingWidth: 48,
          titleSpacing: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 22),
            color: AppColors.blackIcon,
            onPressed: () => Navigator.of(context).pop(),
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(8),
              minimumSize: const Size(40, 40),
            ),
          ),
          title: showTitleInAppBar
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
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
                )
              : null,
          centerTitle: true,
          actions: [
            DetailAppBarStar(
              isSelected: isStarSelected,
              onTap: onStarTap,
              iconColor: AppColors.blackIcon,
            ),
            Builder(
              builder: (buttonContext) => IconButton(
                icon: const Icon(Icons.share, size: 22),
                color: AppColors.blackIcon,
                onPressed: () => onShare(buttonContext),
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(8),
                  minimumSize: const Size(40, 40),
                ),
              ),
            ),
          ],
        ),
        body: CustomScrollView(
          controller: scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: args.isVideo
                  ? ArticleVideoPlayer(
                      videoPath: args.videoPath ?? kYoutubeTestUrl,
                      height: _imageHeight,
                      heroTagForPlay: args.heroTagVideoPlay,
                    )
                  : SizedBox(
                      height: _imageHeight,
                      width: double.infinity,
                        child: Hero(
                        tag: args.heroTag,
                        child: ImageFromPath(
                          path: args.imagePath,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    ),
            ),
            SliverToBoxAdapter(
              child: ArticleContentCard(
                title: args.title,
                date: args.date,
                tag: args.tag,
                body: args.body,
                bodyHtml: args.bodyHtml,
                showTagTitleDate: true,
              ),
            ),
            if (args.sources != null && args.sources!.isNotEmpty)
              SliverToBoxAdapter(
                child: ArticleSourcesSection(sources: args.sources!),
              ),
            if (args.showOtherNews)
              ...buildOtherNewsSlivers(
                context,
                selectionService: context.read<SelectionService>(),
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
