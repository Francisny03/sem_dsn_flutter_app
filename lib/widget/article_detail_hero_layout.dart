import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sem_dsn/core/constants/app_border_radius.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';
import 'package:sem_dsn/widget/article_detail_args.dart';
import 'package:sem_dsn/widget/article_content_card.dart';
import 'package:sem_dsn/widget/article_video_player.dart'
    show ArticleVideoPlayer, ArticleVideoPlayerState, kYoutubeTestUrl;
import 'package:sem_dsn/widget/image_from_path.dart';
import 'package:sem_dsn/services/selection_service.dart';
import 'package:sem_dsn/widget/detail_app_bar_star.dart';
import 'package:sem_dsn/widget/other_news_section.dart';

/// Layout Hero / À la une : image pleine avec gradient, tag/titre/date sur l'image,
/// carte de lecture avec bord arrondi en haut qui monte au scroll.
/// Tap sur play = lecture dans la page ; fullscreen = via l’icône du lecteur.
class ArticleDetailHeroLayout extends StatefulWidget {
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
  State<ArticleDetailHeroLayout> createState() =>
      _ArticleDetailHeroLayoutState();
}

class _ArticleDetailHeroLayoutState extends State<ArticleDetailHeroLayout> {
  /// true = afficher le lecteur vidéo dans la page (après tap sur play).
  bool _showVideoPlayer = false;

  /// true = retour en cours : on cache le lecteur pour éviter le rectangle YouTube pendant la transition.
  bool _isPopping = false;

  final GlobalKey<ArticleVideoPlayerState> _videoPlayerKey =
      GlobalKey<ArticleVideoPlayerState>();

  static const double _videoHeight = 280;

  @override
  Widget build(BuildContext context) {
    final args = widget.args;

    // Quand la vidéo joue : même UI que le layout presse (header blanc, vidéo en dessous).
    if (_showVideoPlayer && args.isVideo) {
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
                _videoPlayerKey.currentState?.pause();
                setState(() => _isPopping = true);
                Navigator.of(context).pop();
              },
              style: IconButton.styleFrom(
                padding: const EdgeInsets.all(8),
                minimumSize: const Size(40, 40),
              ),
            ),
            title: Padding(
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
            ),
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
                child: _isPopping
                    ? Container(
                        height: _videoHeight,
                        width: double.infinity,
                        color: AppColors.bg,
                      )
                    : ArticleVideoPlayer(
                        key: _videoPlayerKey,
                        videoPath: args.videoPath ?? kYoutubeTestUrl,
                        height: _videoHeight,
                        autoPlay: true,
                        heroTagForPlay: args.heroTagVideoPlay,
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
                  heroCapDrawnAbove: false,
                  contentTopPadding: 0,
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

    final isOverImage = !widget.showTitleInAppBar;
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
          controller: widget.scrollController,
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
                        isSelected: widget.isStarSelected,
                        onTap: widget.onStarTap,
                        iconColor: iconColor,
                      ),
                      const SizedBox(width: 4),
                      Builder(
                        builder: (buttonContext) => IconButton(
                          icon: Icon(Icons.share, color: iconColor, size: 22),
                          onPressed: () => widget.onShare(buttonContext),
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
              title: widget.showTitleInAppBar
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
                    if (_showVideoPlayer && args.isVideo) {
                      return SizedBox(
                        height: constraints.maxHeight,
                        width: double.infinity,
                        child: ArticleVideoPlayer(
                          videoPath: args.videoPath ?? kYoutubeTestUrl,
                          height: constraints.maxHeight,
                          heroTagForPlay: args.heroTagVideoPlay,
                        ),
                      );
                    }
                    final topP = MediaQuery.paddingOf(context).top;
                    final isCollapsed =
                        constraints.maxHeight <= topP + kToolbarHeight + 10;
                    return Stack(
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
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _showVideoPlayer = true),
                              child: Hero(
                                tag: args.heroTagVideoPlay,
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black.withValues(alpha: 0.5),
                                  ),
                                  child: const Icon(
                                    Icons.play_arrow,
                                    color: AppColors.whiteTextColor,
                                    size: 40,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        IgnorePointer(
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Color.fromARGB(118, 0, 0, 0),
                                  Color.fromARGB(207, 0, 0, 0),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 30,
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
                                maxLines: 5,
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
                bodyHtml: args.bodyHtml,
                showTagTitleDate: false,
                heroCapDrawnAbove: false,
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
