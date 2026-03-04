import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';
import 'package:sem_dsn/widget/article_video_controls.dart';

/// Lecteur vidéo pour les articles avec contrôles style capture :
/// bouton play central, avance/retour rapide, barre de progression jaune, temps, volume, plein écran.
class ArticleVideoPlayer extends StatefulWidget {
  const ArticleVideoPlayer({
    super.key,
    required this.videoPath,
    this.height = 280,
    this.autoPlay = false,
    this.heroTagForPlay,
  });

  /// Chemin asset (ex. assets/videos/videotest.mp4) ou URL.
  final String videoPath;
  final double height;
  final bool autoPlay;

  /// Si défini, le bouton play initial est enveloppé dans un Hero avec ce tag (animation vers la page détail).
  final Object? heroTagForPlay;

  @override
  State<ArticleVideoPlayer> createState() => _ArticleVideoPlayerState();
}

class _ArticleVideoPlayerState extends State<ArticleVideoPlayer> {
  late final VideoPlayerController _videoController;
  ChewieController? _chewieController;

  /// Affiche le gros bouton play central jusqu'au premier tap (sauf si autoPlay).
  bool _showInitialPlayButton = true;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    final isAsset = widget.videoPath.startsWith('assets/');
    _videoController = isAsset
        ? VideoPlayerController.asset(widget.videoPath)
        : VideoPlayerController.networkUrl(Uri.parse(widget.videoPath));

    await _videoController.initialize();

    if (!mounted) return;
    _chewieController = ChewieController(
      videoPlayerController: _videoController,
      autoPlay: widget.autoPlay,
      looping: false,
      allowFullScreen: true,
      allowMuting: true,
      customControls: const ArticleVideoControls(),
      materialProgressColors: ChewieProgressColors(
        playedColor: AppColors.heroSelectionTag,
        bufferedColor: AppColors.heroSelectionTag.withValues(alpha: 0.4),
        handleColor: AppColors.heroSelectionTag,
        backgroundColor: const Color(0xFF6B6B6B),
      ),
      placeholder: Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.heroSelectionTag),
        ),
      ),
      errorBuilder: (context, errorMessage) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            errorMessage,
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
    if (widget.autoPlay) _showInitialPlayButton = false;
    setState(() {});
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_chewieController == null ||
        !_chewieController!.videoPlayerController.value.isInitialized) {
      // Hero présent dès la 1re frame pour que l’animation home → détail s’affiche.
      return SizedBox(
        height: widget.height,
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.heroSelectionTag),
              ),
            ),
            if (widget.heroTagForPlay != null)
              Material(
                color: Colors.transparent,
                child: Hero(
                  tag: widget.heroTagForPlay!,
                  child: Icon(
                    Icons.play_circle_fill,
                    color: Colors.white.withValues(alpha: 0.9),
                    size: 120,
                  ),
                ),
              ),
          ],
        ),
      );
    }

    final size = _videoController.value.size;
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: ClipRect(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Chewie(controller: _chewieController!),
                if (_showInitialPlayButton)
                  Material(
                    color: Colors.black54,
                    child: Center(
                      child: widget.heroTagForPlay != null
                          ? Hero(
                              tag: widget.heroTagForPlay!,
                              child: IconButton(
                                iconSize: 180,
                                icon: const Icon(
                                  Icons.play_circle_fill,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  _videoController.play();
                                  setState(
                                    () => _showInitialPlayButton = false,
                                  );
                                },
                              ),
                            )
                          : IconButton(
                              iconSize: 180,
                              icon: const Icon(
                                Icons.play_circle_fill,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                _videoController.play();
                                setState(() => _showInitialPlayButton = false);
                              },
                            ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
