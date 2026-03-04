import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// Bouton -10 s (retour rapide). [controller] requis (utilisé en overlay / fullscreen).
class YoutubeSeekBackButton extends StatefulWidget {
  const YoutubeSeekBackButton({super.key, required this.controller});

  final YoutubePlayerController controller;

  @override
  State<YoutubeSeekBackButton> createState() => _YoutubeSeekBackButtonState();
}

class _YoutubeSeekBackButtonState extends State<YoutubeSeekBackButton> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_listener);
  }

  @override
  void didUpdateWidget(covariant YoutubeSeekBackButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_listener);
      widget.controller.addListener(_listener);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_listener);
    super.dispose();
  }

  void _listener() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final pos = widget.controller.value.position.inSeconds;
    final dur = widget.controller.metadata.duration.inSeconds;
    return IconButton(
      icon: const Icon(Icons.replay_10, color: Colors.white, size: 28),
      onPressed: pos <= 0
          ? null
          : () {
              final to = (pos - 10).clamp(0, dur);
              widget.controller.seekTo(Duration(seconds: to));
            },
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
    );
  }
}

/// Bouton +10 s (avance rapide). [controller] requis (utilisé en overlay / fullscreen).
class YoutubeSeekForwardButton extends StatefulWidget {
  const YoutubeSeekForwardButton({super.key, required this.controller});

  final YoutubePlayerController controller;

  @override
  State<YoutubeSeekForwardButton> createState() =>
      _YoutubeSeekForwardButtonState();
}

class _YoutubeSeekForwardButtonState extends State<YoutubeSeekForwardButton> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_listener);
  }

  @override
  void didUpdateWidget(covariant YoutubeSeekForwardButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_listener);
      widget.controller.addListener(_listener);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_listener);
    super.dispose();
  }

  void _listener() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final pos = widget.controller.value.position.inSeconds;
    final dur = widget.controller.metadata.duration.inSeconds;
    return IconButton(
      icon: const Icon(Icons.forward_10, color: Colors.white, size: 28),
      onPressed: dur <= 0 || pos >= dur
          ? null
          : () {
              final to = (pos + 10).clamp(0, dur);
              widget.controller.seekTo(Duration(seconds: to));
            },
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
    );
  }
}
