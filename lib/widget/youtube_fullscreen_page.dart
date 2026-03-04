import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';
import 'package:sem_dsn/widget/youtube_seek_buttons.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// Page plein écran : uniquement la vidéo YouTube en paysage, sans barre ni texte.
/// À ouvrir via [Navigator.push] ; restaure l’orientation et la UI système au pop.
class YoutubeFullscreenPage extends StatefulWidget {
  const YoutubeFullscreenPage({
    super.key,
    required this.videoId,
    this.startAtSeconds = 0,
  });

  final String videoId;
  final int startAtSeconds;

  @override
  State<YoutubeFullscreenPage> createState() => _YoutubeFullscreenPageState();
}

class _YoutubeFullscreenPageState extends State<YoutubeFullscreenPage> {
  late YoutubePlayerController _controller;

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
    if (mounted) setState(() {});
  }

  void _enterFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _exitFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _exitFullscreen();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Center(
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
                      IgnorePointer(
                        child: SizedBox(width: 100, height: 80),
                      ),
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
              child: IconButton(
                icon: const Icon(Icons.fullscreen_exit, color: Colors.white, size: 28),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
