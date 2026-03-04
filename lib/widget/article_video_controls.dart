import 'dart:async';

import 'package:chewie/chewie.dart';
// ignore: implementation_imports
import 'package:chewie/src/notifiers/index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';

/// Contrôles vidéo personnalisés style capture :
/// centre = [Retour 10s] [Play/Pause] [Avance 10s], bas = barre jaune + temps + volume + plein écran.
/// Tap sur l'écran affiche/masque les contrôles (pas d'AbsorbPointer qui bloque le tap).
class ArticleVideoControls extends StatefulWidget {
  const ArticleVideoControls({super.key});

  @override
  State<ArticleVideoControls> createState() => _ArticleVideoControlsState();
}

class _ArticleVideoControlsState extends State<ArticleVideoControls> {
  PlayerNotifier? _notifier;
  ChewieController? _chewieController;
  VideoPlayerController? _controller;
  Timer? _hideTimer;
  double? _latestVolume;

  static const _hideDelay = Duration(seconds: 3);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final chewieController = ChewieController.of(context);
    if (_chewieController != chewieController) {
      _hideTimer?.cancel();
      _controller?.removeListener(_updateState);
      _chewieController = chewieController;
      _controller = chewieController.videoPlayerController;
      _notifier = Provider.of<PlayerNotifier>(context, listen: false);
      _controller!.addListener(_updateState);
      _updateState();
      if (_controller!.value.isPlaying) _startHideTimer();
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _controller?.removeListener(_updateState);
    super.dispose();
  }

  void _updateState() {
    if (!mounted) return;
    setState(() {});
  }

  void _cancelAndRestartTimer() {
    _hideTimer?.cancel();
    if (_notifier != null) _notifier!.hideStuff = false;
    _startHideTimer();
    if (mounted) setState(() {});
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    final delay = (_chewieController?.hideControlsTimer.isNegative ?? true)
        ? _hideDelay
        : _chewieController!.hideControlsTimer;
    _hideTimer = Timer(delay, () {
      if (!mounted) return;
      if (_notifier != null) _notifier!.hideStuff = true;
      setState(() {});
    });
  }

  void _playPause() {
    if (_controller == null) return;
    final isPlaying = _controller!.value.isPlaying;
    final isFinished =
        _controller!.value.position >= _controller!.value.duration &&
        _controller!.value.duration.inSeconds > 0;
    if (isPlaying) {
      _notifier?.hideStuff = false;
      _hideTimer?.cancel();
      _controller!.pause();
    } else {
      _cancelAndRestartTimer();
      if (isFinished) _controller!.seekTo(Duration.zero);
      _controller!.play();
    }
    if (mounted) setState(() {});
  }

  void _seekBackward() {
    if (_controller == null) return;
    _cancelAndRestartTimer();
    final pos = _controller!.value.position - const Duration(seconds: 10);
    _controller!.seekTo(pos.isNegative ? Duration.zero : pos);
  }

  void _seekForward() {
    if (_controller == null) return;
    _cancelAndRestartTimer();
    final pos = _controller!.value.position + const Duration(seconds: 10);
    final dur = _controller!.value.duration;
    _controller!.seekTo(pos > dur ? dur : pos);
  }

  void _onVolumeTap() {
    if (_controller == null) return;
    _cancelAndRestartTimer();
    if (_controller!.value.volume > 0) {
      _latestVolume = _controller!.value.volume;
      _controller!.setVolume(0);
    } else {
      _controller!.setVolume(_latestVolume ?? 0.5);
    }
    if (mounted) setState(() {});
  }

  void _onFullScreenTap() {
    _chewieController?.toggleFullScreen();
    if (mounted) setState(() {});
  }

  static String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (h > 0) {
      final hStr = h.toString().padLeft(2, '0');
      return '$hStr:$m:$s';
    }
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || _notifier == null || _chewieController == null) {
      return const SizedBox.expand();
    }

    final value = _controller!.value;
    final position = value.position;
    final duration = value.duration;
    final hideStuff = _notifier!.hideStuff;
    final progress = duration.inMilliseconds > 0
        ? position.inMilliseconds / duration.inMilliseconds
        : 0.0;

    return SizedBox.expand(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (value.isPlaying) {
            _cancelAndRestartTimer();
          } else {
            _cancelAndRestartTimer();
          }
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (!hideStuff) ...[
              // Centre : Retour 10s | Play/Pause | Avance 10s
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _roundButton(icon: Icons.replay_10, onTap: _seekBackward),
                  const SizedBox(width: 36),
                  _roundButton(
                    icon: value.isPlaying ? Icons.pause : Icons.play_arrow,
                    onTap: _playPause,
                  ),
                  const SizedBox(width: 36),
                  _roundButton(icon: Icons.forward_10, onTap: _seekForward),
                ],
              ),
              // Bas : barre + temps + volume + plein écran
              Positioned(
                left: 80,
                right: 80,
                bottom: -30,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: AppColors.heroSelectionTag,
                              inactiveTrackColor: const Color(0xFF6B6B6B),
                              thumbColor: AppColors.heroSelectionTag,
                              overlayColor: AppColors.heroSelectionTag
                                  .withValues(alpha: 0.2),
                              trackHeight: 6,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 5,
                              ),
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 10,
                              ),
                            ),
                            child: Slider(
                              value: progress.clamp(0.0, 1.0),
                              onChanged: (v) {
                                _cancelAndRestartTimer();
                                final ms = (v * duration.inMilliseconds)
                                    .round();
                                _controller!.seekTo(Duration(milliseconds: ms));
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_formatDuration(position)} / ${_formatDuration(duration)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                        if (_chewieController!.allowMuting)
                          IconButton(
                            icon: Icon(
                              value.volume > 0
                                  ? Icons.volume_up
                                  : Icons.volume_off,
                              color: Colors.white,
                              size: 30,
                            ),
                            onPressed: _onVolumeTap,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                          ),
                        if (_chewieController!.allowFullScreen)
                          IconButton(
                            icon: Icon(
                              _chewieController!.isFullScreen
                                  ? Icons.fullscreen_exit
                                  : Icons.fullscreen,
                              color: Colors.white,
                              size: 36,
                            ),
                            onPressed: _onFullScreenTap,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _roundButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.black54,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          onTap();
          _cancelAndRestartTimer();
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: Colors.white, size: 50),
        ),
      ),
    );
  }
}
