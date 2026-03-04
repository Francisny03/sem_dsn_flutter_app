import 'package:flutter/material.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';
import 'package:sem_dsn/widget/youtube_fullscreen_page.dart';
import 'package:sem_dsn/widget/youtube_seek_buttons.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// Lien YouTube de test (le dashboard fournira le lien en production).
const String kYoutubeTestUrl =
    'https://www.youtube.com/watch?v=6RLheM5AZmc&t=26s';

/// Indique si [path] est une URL YouTube.
bool isYoutubeUrl(String path) => getYoutubeVideoId(path) != null;

/// Extrait l’ID vidéo d’une URL YouTube (youtube.com/watch?v=xxx ou youtu.be/xxx).
String? getYoutubeVideoId(String path) {
  final uri = Uri.tryParse(path);
  if (uri == null) return null;
  if (uri.host.contains('youtube.com') && uri.path == '/watch') {
    final id = uri.queryParameters['v'];
    return (id != null && id.isNotEmpty) ? id : null;
  }
  if (uri.host == 'youtu.be' && uri.pathSegments.isNotEmpty) {
    return uri.pathSegments.first;
  }
  return null;
}

/// Extrait le temps de début en secondes (paramètre &t= dans l’URL, ex. 26 ou 26s).
int? getYoutubeStartSeconds(String path) {
  final uri = Uri.tryParse(path);
  if (uri == null) return null;
  final t = uri.queryParameters['t'];
  if (t == null || t.isEmpty) return null;
  final sec = int.tryParse(t.replaceFirst(RegExp(r's$'), ''));
  return sec;
}

/// Lecteur vidéo pour les articles : lit le lien vidéo (YouTube ou autre).
/// Si [videoPath] est une URL YouTube, utilise le lecteur YouTube ; sinon affiche un placeholder.
/// L’ancien code Chewie + contrôles custom est conservé en commentaire en bas du fichier.
class ArticleVideoPlayer extends StatefulWidget {
  const ArticleVideoPlayer({
    super.key,
    required this.videoPath,
    this.height = 280,
    this.autoPlay = false,
    this.heroTagForPlay,
  });

  /// Lien vidéo : URL YouTube (ex. https://www.youtube.com/watch?v=xxx) ou chemin asset/URL directe.
  final String videoPath;
  final double height;
  final bool autoPlay;

  /// Si défini, le bouton play initial est enveloppé dans un Hero (animation vers la page détail).
  final Object? heroTagForPlay;

  @override
  State<ArticleVideoPlayer> createState() => _ArticleVideoPlayerState();
}

class _ArticleVideoPlayerState extends State<ArticleVideoPlayer> {
  YoutubePlayerController? _youtubeController;

  @override
  void initState() {
    super.initState();
    final videoId = getYoutubeVideoId(widget.videoPath);
    if (videoId != null) {
      final startAt = getYoutubeStartSeconds(widget.videoPath);
      _youtubeController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: YoutubePlayerFlags(
          autoPlay: widget.autoPlay,
          mute: false,
          startAt: startAt ?? 0,
        ),
      )..addListener(_onControllerUpdate);
    }
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _youtubeController?.removeListener(_onControllerUpdate);
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videoId = getYoutubeVideoId(widget.videoPath);
    if (videoId == null || _youtubeController == null) {
      return SizedBox(
        height: widget.height,
        width: double.infinity,
        child: Container(
          color: Colors.black,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.videocam_off, color: Colors.white54, size: 48),
                const SizedBox(height: 12),
                Text(
                  'Lien vidéo non supporté',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final c = _youtubeController!;
    final controlsVisible = c.value.isControlsVisible;

    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Zone vidéo 16:9 pour aligner les seek sur le bouton play
          final videoHeight = constraints.maxWidth * 9 / 16;
          final h = videoHeight.clamp(0.0, constraints.maxHeight);
          return Stack(
            clipBehavior: Clip.none,
            children: [
              YoutubePlayer(
                controller: c,
                showVideoProgressIndicator: true,
                progressIndicatorColor: AppColors.heroSelectionTag,
                bottomActions: [
                  CurrentPosition(),
                  const SizedBox(width: 8),
                  ProgressBar(
                    isExpanded: true,
                    colors: ProgressBarColors(
                      playedColor: AppColors.heroSelectionTag,
                      handleColor: AppColors.heroSelectionTag,
                    ),
                  ),
                  const SizedBox(width: 8),
                  RemainingDuration(),
                  const _YoutubeFullscreenVideoButton(),
                ],
              ),
              // Même ligne que le bouton play, uniquement quand les contrôles sont visibles (tap écran)
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: h,
                child: IgnorePointer(
                  ignoring: !controlsVisible,
                  child: AnimatedOpacity(
                    opacity: controlsVisible ? 1 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          YoutubeSeekBackButton(controller: c),
                          IgnorePointer(
                            child: SizedBox(width: 100, height: 80),
                          ),
                          YoutubeSeekForwardButton(controller: c),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Bouton plein écran : ouvre une page dédiée avec uniquement la vidéo en paysage.
class _YoutubeFullscreenVideoButton extends StatefulWidget {
  const _YoutubeFullscreenVideoButton();

  @override
  State<_YoutubeFullscreenVideoButton> createState() =>
      _YoutubeFullscreenVideoButtonState();
}

class _YoutubeFullscreenVideoButtonState
    extends State<_YoutubeFullscreenVideoButton> {
  @override
  Widget build(BuildContext context) {
    final controller = YoutubePlayerController.of(context);
    if (controller == null) return const SizedBox.shrink();
    final videoId = controller.metadata.videoId.isNotEmpty
        ? controller.metadata.videoId
        : controller.initialVideoId;
    return IconButton(
      icon: const Icon(Icons.fullscreen, color: Colors.white, size: 22),
      onPressed: () {
        final startAt = controller.value.position.inSeconds;
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            fullscreenDialog: true,
            builder: (context) => YoutubeFullscreenPage(
              videoId: videoId,
              startAtSeconds: startAt,
            ),
          ),
        );
      },
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
    );
  }
}

// =============================================================================
// ANCIEN CODE : lecteur Chewie + contrôles custom (barre jaune, play central, etc.)
// Conservé en commentaire pour référence. Ne pas effacer.
// =============================================================================
//
// import 'package:chewie/chewie.dart';
// import 'package:video_player/video_player.dart';
// import 'package:sem_dsn/widget/article_video_controls.dart';
//
// class _ArticleVideoPlayerState extends State<ArticleVideoPlayer> {
//   late final VideoPlayerController _videoController;
//   ChewieController? _chewieController;
//   bool _showInitialPlayButton = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _initPlayer();
//   }
//
//   Future<void> _initPlayer() async {
//     final isAsset = widget.videoPath.startsWith('assets/');
//     _videoController = isAsset
//         ? VideoPlayerController.asset(widget.videoPath)
//         : VideoPlayerController.networkUrl(Uri.parse(widget.videoPath));
//     await _videoController.initialize();
//     if (!mounted) return;
//     _chewieController = ChewieController(
//       videoPlayerController: _videoController,
//       autoPlay: widget.autoPlay,
//       looping: false,
//       allowFullScreen: true,
//       allowMuting: true,
//       customControls: const ArticleVideoControls(),
//       materialProgressColors: ChewieProgressColors(
//         playedColor: AppColors.heroSelectionTag,
//         bufferedColor: AppColors.heroSelectionTag.withValues(alpha: 0.4),
//         handleColor: AppColors.heroSelectionTag,
//         backgroundColor: const Color(0xFF6B6B6B),
//       ),
//       placeholder: Container(
//         color: Colors.black,
//         child: const Center(
//           child: CircularProgressIndicator(color: AppColors.heroSelectionTag),
//         ),
//       ),
//       errorBuilder: (context, errorMessage) => Center(
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Text(errorMessage, style: const TextStyle(color: Colors.white)),
//         ),
//       ),
//     );
//     if (widget.autoPlay) _showInitialPlayButton = false;
//     setState(() {});
//   }
//
//   @override
//   void dispose() {
//     _chewieController?.dispose();
//     _videoController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_chewieController == null || !_chewieController!.videoPlayerController.value.isInitialized) {
//       return SizedBox(
//         height: widget.height,
//         width: double.infinity,
//         child: Stack(
//           alignment: Alignment.center,
//           children: [
//             Container(
//               color: Colors.black,
//               child: const Center(
//                 child: CircularProgressIndicator(color: AppColors.heroSelectionTag),
//               ),
//             ),
//             if (widget.heroTagForPlay != null)
//               Material(
//                 color: Colors.transparent,
//                 child: Hero(
//                   tag: widget.heroTagForPlay!,
//                   child: Icon(Icons.play_circle_fill, color: Colors.white.withValues(alpha: 0.9), size: 120),
//                 ),
//               ),
//           ],
//         ),
//       );
//     }
//     final size = _videoController.value.size;
//     return SizedBox(
//       height: widget.height,
//       width: double.infinity,
//       child: ClipRect(
//         child: FittedBox(
//           fit: BoxFit.cover,
//           child: SizedBox(
//             width: size.width,
//             height: size.height,
//             child: Stack(
//               fit: StackFit.expand,
//               children: [
//                 Chewie(controller: _chewieController!),
//                 if (_showInitialPlayButton)
//                   Material(
//                     color: Colors.black54,
//                     child: Center(
//                       child: widget.heroTagForPlay != null
//                           ? Hero(
//                               tag: widget.heroTagForPlay!,
//                               child: IconButton(
//                                 iconSize: 180,
//                                 icon: const Icon(Icons.play_circle_fill, color: Colors.white),
//                                 onPressed: () {
//                                   _videoController.play();
//                                   setState(() => _showInitialPlayButton = false);
//                                 },
//                               ),
//                             )
//                           : IconButton(
//                               iconSize: 180,
//                               icon: const Icon(Icons.play_circle_fill, color: Colors.white),
//                               onPressed: () {
//                                 _videoController.play();
//                                 setState(() => _showInitialPlayButton = false);
//                               },
//                             ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
