import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sem_dsn/core/constants/app_assets.dart';
import 'package:sem_dsn/core/constants/app_strings.dart';
import 'package:sem_dsn/core/constants/live_config.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';
import 'package:sem_dsn/widget/youtube_seek_buttons.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/// Page intermédiaire Live / Replay : barre (retour, partage), indicateur "En direct" ou "Replay" pulsé,
/// lecteur avec contrôles + bouton plein écran (paysage).
class LiveReplayPlayerPage extends StatefulWidget {
  const LiveReplayPlayerPage({
    super.key,
    required this.isLive,
    this.streamUrl,
    this.videoId,
    this.startAtSeconds = 0,
  });

  final bool isLive;
  final String? streamUrl;
  final String? videoId;
  final int startAtSeconds;

  @override
  State<LiveReplayPlayerPage> createState() => _LiveReplayPlayerPageState();
}

class _LiveReplayPlayerPageState extends State<LiveReplayPlayerPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  bool _isFullscreen = false;

  /// true = entré en fullscreen par rotation (Case 2) → sortie auto au retour portrait. false = par bouton (Case 3) → sortie uniquement par X.
  bool _enteredFullscreenByRotation = false;

  /// Retour en cours : on cache le lecteur pour éviter le rectangle pendant la transition (live et replay).
  bool _isPopping = false;
  BetterPlayerController? _betterPlayerController;
  YoutubePlayerController? _youtubeController;

  bool get _isVertical => widget.isLive
      ? LiveConfig.liveStreamIsVertical
      : LiveConfig.recapVideoIsVertical;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.isLive &&
        widget.streamUrl != null &&
        widget.streamUrl!.isNotEmpty) {
      final ratio = LiveConfig.liveStreamIsVertical ? 9 / 16 : 16 / 9;
      _betterPlayerController = BetterPlayerController(
        BetterPlayerConfiguration(
          autoPlay: true,
          aspectRatio: ratio,
          fit: BoxFit.contain,
          controlsConfiguration: BetterPlayerControlsConfiguration(
            showControls: true,
            showControlsOnInitialize: true,
          ),
        ),
      );
      _betterPlayerController!.setupDataSource(
        BetterPlayerDataSource.network(widget.streamUrl!, liveStream: true),
      );
    } else if (widget.videoId != null && widget.videoId!.isNotEmpty) {
      _youtubeController = YoutubePlayerController(
        initialVideoId: widget.videoId!,
        flags: YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          startAt: widget.startAtSeconds,
        ),
      )..addListener(_onYoutubeUpdate);
    }
  }

  void _onYoutubeUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (_isVertical) return;
    final views = WidgetsBinding.instance.platformDispatcher.views;
    if (views.isEmpty) return;
    final bounds = views.first.physicalSize;
    final ratio = views.first.devicePixelRatio;
    final w = bounds.width / ratio;
    final h = bounds.height / ratio;
    if (!mounted) return;
    if (w > h) {
      if (!_isFullscreen) _openFullscreen(byRotation: true);
    } else {
      if (_isFullscreen && _enteredFullscreenByRotation) _closeFullscreen();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_isFullscreen) _exitFullscreen();
    _pulseController.dispose();
    _betterPlayerController?.dispose();
    _youtubeController?.removeListener(_onYoutubeUpdate);
    _youtubeController?.dispose();
    super.dispose();
  }

  void _share() {
    if (widget.isLive && widget.streamUrl != null) {
      Share.share(widget.streamUrl!, subject: AppStrings.liveTitle);
    } else if (widget.videoId != null) {
      Share.share(
        'https://www.youtube.com/watch?v=${widget.videoId}',
        subject: 'Replay',
      );
    }
  }

  /// Fullscreen en verrouillant le paysage (Cas 3 : bouton) → sortie uniquement par X.
  void _enterFullscreenLockLandscape() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  /// Fullscreen sans verrouiller l’orientation (Cas 2 : rotation) → sortie auto au retour portrait.
  void _enterFullscreenAllowRotation() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _exitFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _openFullscreen({bool byRotation = false}) {
    if (widget.isLive &&
        widget.streamUrl != null &&
        widget.streamUrl!.isNotEmpty) {
      setState(() {
        _isFullscreen = true;
        _enteredFullscreenByRotation = byRotation;
      });
      if (byRotation) {
        _enterFullscreenAllowRotation();
      } else {
        _enterFullscreenLockLandscape();
      }
    } else if (widget.videoId != null) {
      setState(() {
        _isFullscreen = true;
        _enteredFullscreenByRotation = byRotation;
      });
      if (byRotation) {
        _enterFullscreenAllowRotation();
      } else {
        _enterFullscreenLockLandscape();
      }
    }
  }

  void _closeFullscreen() {
    if (!mounted) return;
    setState(() {
      _isFullscreen = false;
      _enteredFullscreenByRotation = false;
    });
    _exitFullscreen();
  }

  void _onBack() {
    if (_isFullscreen) _exitFullscreen();
    _betterPlayerController?.pause();
    _youtubeController?.pause();
    setState(() => _isPopping = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ratio = widget.isLive
        ? (LiveConfig.liveStreamIsVertical ? 9 / 16 : 16 / 9)
        : (LiveConfig.recapVideoIsVertical ? 9 / 16 : 16 / 9);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onBack();
      },
      child: Scaffold(
        backgroundColor: _isFullscreen ? Colors.black : AppColors.bg,
        appBar: _isFullscreen
            ? null
            : AppBar(
                backgroundColor: AppColors.bg,
                elevation: 0,
                scrolledUnderElevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 22),
                  color: AppColors.blackIcon,
                  onPressed: _onBack,
                ),
                title: _PulsingLiveLabel(
                  isLive: widget.isLive,
                  pulseAnimation: _pulseAnimation,
                ),
                centerTitle: true,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share, size: 22),
                    color: AppColors.blackIcon,
                    onPressed: _share,
                  ),
                ],
              ),
        body: _isPopping
            ? Container(color: _isFullscreen ? Colors.black : AppColors.bg)
            : Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: _isFullscreen ? Colors.black : AppColors.bg),
                  SafeArea(
                    top: !_isFullscreen,
                    left: true,
                    right: true,
                    bottom: true,
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: ratio,
                        child: _buildPlayer(),
                      ),
                    ),
                  ),
                  if (_isFullscreen)
                    SafeArea(
                      child: Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: _closeFullscreen,
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildPlayer() {
    if (_betterPlayerController != null) {
      return BetterPlayer(controller: _betterPlayerController!);
    }
    if (_youtubeController != null) {
      return ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            YoutubePlayer(
              controller: _youtubeController!,
              showVideoProgressIndicator: true,
              progressIndicatorColor: AppColors.heroSelectionTag,
              bottomActions: [
                const SizedBox(width: 8),
                if (!widget.isLive) CurrentPosition(),
                if (!widget.isLive) const SizedBox(width: 8),
                ProgressBar(
                  isExpanded: true,
                  colors: ProgressBarColors(
                    playedColor: AppColors.heroSelectionTag,
                    handleColor: AppColors.heroSelectionTag,
                  ),
                ),
                if (!widget.isLive) const SizedBox(width: 8),
                if (!widget.isLive) RemainingDuration(),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(
                    Icons.fullscreen,
                    color: Colors.white,
                    size: 22,
                  ),
                  onPressed: _openFullscreen,
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            Positioned.fill(
              child: IgnorePointer(
                ignoring: !_youtubeController!.value.isControlsVisible,
                child: AnimatedOpacity(
                  opacity: _youtubeController!.value.isControlsVisible ? 1 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        YoutubeSeekBackButton(controller: _youtubeController!),
                        const IgnorePointer(
                          child: SizedBox(width: 100, height: 80),
                        ),
                        YoutubeSeekForwardButton(
                          controller: _youtubeController!,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return const Center(child: CircularProgressIndicator());
  }
}

class _PulsingLiveLabel extends StatelessWidget {
  const _PulsingLiveLabel({required this.isLive, required this.pulseAnimation});

  final bool isLive;
  final Animation<double> pulseAnimation;

  @override
  Widget build(BuildContext context) {
    final label = isLive ? AppStrings.liveTitle : 'Replay';
    final color = isLive ? Colors.red : AppColors.newsTitle;

    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (context, _) {
        return Opacity(
          opacity: isLive ? pulseAnimation.value : 1,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                AppAssets.livecustom,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
