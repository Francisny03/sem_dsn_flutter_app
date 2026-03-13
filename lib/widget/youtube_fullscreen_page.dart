import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sem_dsn/core/constants/live_config.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';
import 'package:sem_dsn/widget/youtube_seek_buttons.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// Page plein écran : uniquement la vidéo YouTube (paysage ou portrait), sans barre ni texte.
/// À ouvrir via [Navigator.push] ; restaure l’orientation et la UI système au pop.
class YoutubeFullscreenPage extends StatefulWidget {
  const YoutubeFullscreenPage({
    super.key,
    required this.videoId,
    this.startAtSeconds = 0,
    this.isRecap = false,
    this.isVertical = false,
  });

  final String videoId;
  final int startAtSeconds;

  /// true = recap (bouton X, quitter = retour home). false = depuis article (fullscreen_exit, quitter = retour article, lecture en réduit).
  final bool isRecap;

  /// true = vidéo verticale → plein écran portrait (9/16).
  final bool isVertical;

  @override
  State<YoutubeFullscreenPage> createState() => _YoutubeFullscreenPageState();
}

class _YoutubeFullscreenPageState extends State<YoutubeFullscreenPage> {
  late YoutubePlayerController _controller;
  bool _isEnded = false;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        startAt: widget.startAtSeconds,
        forceHD: true,
        hideControls: false,
      ),
    )..addListener(_onControllerUpdate);
    _enterFullscreen();
  }

  void _onControllerUpdate() {
    if (!mounted) return;
    final endedNow = _controller.value.playerState == PlayerState.ended;
    if (endedNow != _isEnded) {
      setState(() => _isEnded = endedNow);
    } else {
      setState(() {});
    }
  }

  void _enterFullscreen() {
    if (widget.isVertical ||
        (widget.isRecap && LiveConfig.recapVideoIsVertical)) {
      // Plein écran portrait (Shorts / vidéo verticale).
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else {
      // Plein écran paysage classique.
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations(const [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  void _exitFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  /// Recap : coupe la vidéo et retour à la page lecteur.
  Future<void> _closeAndPop() async {
    _exitFullscreen();
    _controller.pause();
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  /// Article : ferme le fullscreen, retour article avec position + play state pour continuer en lecteur réduit.
  /// Délai après _exitFullscreen pour laisser l’orientation se stabiliser (surtout en paysage).
  Future<void> _exitFullscreenAndPop() async {
    _exitFullscreen();
    final position = _controller.value.position;
    final isPlaying = _controller.value.playerState == PlayerState.playing;
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    Navigator.of(context).pop(<String, dynamic>{
      'position': position.inSeconds,
      'isPlaying': isPlaying,
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _exitFullscreen();
    _controller.dispose();
    super.dispose();
  }

  double get _aspectRatio {
    if (widget.isVertical) return 9 / 16;
    if (widget.isRecap && LiveConfig.recapVideoIsVertical) return 9 / 16;
    return 16 / 9;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: _aspectRatio,
              child: YoutubePlayer(
                controller: _controller,
                showVideoProgressIndicator: true,
                progressIndicatorColor: AppColors.heroSelectionTag,
                bottomActions: [
                  const SizedBox(width: 50),
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
                  const SizedBox(width: 50),
                ],
              ),
            ),
          ),
          if (_isEnded)
            Positioned.fill(
              child: Container(
                color: Colors.black45,
                child: Center(
                  child: IconButton(
                    iconSize: 96,
                    icon: const Icon(
                      Icons.play_circle_fill,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      _controller.seekTo(Duration.zero);
                      _controller.play();
                    },
                  ),
                ),
              ),
            ),
          // Même ligne que le bouton play, uniquement quand les contrôles sont visibles (tap écran)
          Positioned.fill(
            child: IgnorePointer(
              ignoring: !_controller.value.isControlsVisible,
              child: AnimatedOpacity(
                opacity: _controller.value.isControlsVisible ? 1 : 0,
                duration: const Duration(milliseconds: 300),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      YoutubeSeekBackButton(controller: _controller),
                      IgnorePointer(child: SizedBox(width: 100, height: 80)),
                      YoutubeSeekForwardButton(controller: _controller),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: IconButton(
                  icon: Icon(
                    widget.isRecap ? Icons.close : Icons.fullscreen_exit,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: widget.isRecap
                      ? _closeAndPop
                      : _exitFullscreenAndPop,
                  style: IconButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
