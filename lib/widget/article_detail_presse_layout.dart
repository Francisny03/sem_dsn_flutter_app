import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';
import 'package:sem_dsn/widget/article_detail_args.dart';
import 'package:sem_dsn/widget/article_content_card.dart';
import 'package:sem_dsn/widget/article_video_player.dart'
    show ArticleVideoPlayer, ArticleVideoPlayerState, kYoutubeTestUrl;
import 'package:sem_dsn/widget/image_from_path.dart';
import 'package:sem_dsn/services/selection_service.dart';
import 'package:sem_dsn/widget/detail_app_bar_star.dart';
import 'package:sem_dsn/widget/other_news_section.dart';

/// Layout Presse / Campagne / Réalisation : AppBar avec bg, image + play,
/// puis tag / titre / date / description. Au scroll, titre dans l'app bar.
/// Tap sur play = lecture dans la page ; fullscreen = via l’icône du lecteur.
class ArticleDetailPresseLayout extends StatefulWidget {
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

  @override
  State<ArticleDetailPresseLayout> createState() =>
      _ArticleDetailPresseLayoutState();
}

class _ArticleDetailPresseLayoutState extends State<ArticleDetailPresseLayout> {
  static const double _imageHeight = 280;

  final GlobalKey<ArticleVideoPlayerState> _videoPlayerKey =
      GlobalKey<ArticleVideoPlayerState>();

  /// true = retour en cours : on cache le lecteur pour éviter le rectangle YouTube pendant la transition.
  bool _isPopping = false;

  /// true = afficher le lecteur vidéo dans la page (après tap sur play).
  bool _showVideoPlayer = false;

  @override
  Widget build(BuildContext context) {
    final args = widget.args;
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
            onPressed: () {
              if (_showVideoPlayer) {
                _videoPlayerKey.currentState?.pause();
                setState(() => _isPopping = true);
              }
              Navigator.of(context).pop();
            },
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(8),
              minimumSize: const Size(40, 40),
            ),
          ),
          title: widget.showTitleInAppBar
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
              isSelected: widget.isStarSelected,
              onTap: widget.onStarTap,
              iconColor: AppColors.blackIcon,
            ),
            Builder(
              builder: (buttonContext) => IconButton(
                icon: const Icon(Icons.share, size: 22),
                color: AppColors.blackIcon,
                onPressed: () => widget.onShare(buttonContext),
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(8),
                  minimumSize: const Size(40, 40),
                ),
              ),
            ),
          ],
        ),
        body: CustomScrollView(
          controller: widget.scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: _showVideoPlayer && args.isVideo
                  ? (_isPopping
                      ? Container(
                          height: _imageHeight,
                          width: double.infinity,
                          color: AppColors.bg,
                        )
                      : ArticleVideoPlayer(
                          key: _videoPlayerKey,
                          videoPath: args.videoPath ?? kYoutubeTestUrl,
                          height: _imageHeight,
                          autoPlay: true,
                          heroTagForPlay: args.heroTagVideoPlay,
                        ))
                  : GestureDetector(
                      onTap: args.isVideo && args.videoPath != null
                          ? () => setState(() => _showVideoPlayer = true)
                          : null,
                      child: SizedBox(
                        height: _imageHeight,
                        width: double.infinity,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Hero(
                              tag: args.heroTag,
                              child: ImageFromPath(
                                path: args.imagePath,
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
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.black.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.play_arrow,
                                      color: AppColors.whiteTextColor,
                                      size: 40,
                                    ),
                                  ),
                                ),
                              ),
                          ],
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
                sources: args.sources,
              ),
            ),
            if (args.showOtherNews)
              ...buildOtherNewsSlivers(
                context,
                selectionService: context.read<SelectionService>(),
                onArticleTap: widget.onOtherNewsArticleTap,
              ),
            if (!args.showOtherNews)
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}
