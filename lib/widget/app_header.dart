import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sem_dsn/core/constants/app_assets.dart';
import 'package:sem_dsn/core/constants/app_strings.dart';
import 'package:sem_dsn/core/constants/live_config.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';
import 'package:sem_dsn/widget/header_menu.dart';

/// En-tête de l'application : logo DSN (Hero) + texte animé gauche→droite + icônes.
class AppHeader extends StatefulWidget implements PreferredSizeWidget {
  const AppHeader({
    super.key,
    this.onSearchPressed,
    this.onNotificationsPressed,
    this.onLivePressed,
  });

  /// Appelé au tap sur l'icône recherche (ex: ouvre la page recherche Photothèque).
  final VoidCallback? onSearchPressed;

  /// Appelé au tap sur l'icône cloche (ex: ouvre la page Notifications).
  final VoidCallback? onNotificationsPressed;

  /// Appelé au tap sur l'icône live (ouvre live HLS ou recap YouTube selon config).
  final VoidCallback? onLivePressed;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> with TickerProviderStateMixin {
  late final AnimationController _textController;
  late final Animation<Offset> _textSlide;
  late final AnimationController _liveBlinkController;
  late final Animation<double> _liveBlinkAnimation;

  static bool get _showLiveIcon =>
      LiveConfig.liveStreamUrl.isNotEmpty ||
      LiveConfig.recapVideoUrl.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _textSlide = Tween<Offset>(begin: const Offset(-100, 0), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
        );
    _liveBlinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _liveBlinkAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _liveBlinkController, curve: Curves.easeInOut),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) _textController.forward();
      });
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _liveBlinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.bg,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: 0,
      leadingWidth: 0,
      title: Padding(
        padding: const EdgeInsets.only(left: 20, right: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Hero(
                  tag: 'app_logo',
                  child: SvgPicture.asset(
                    AppAssets.logoApp,
                    width: 32,
                    height: 32,
                    colorFilter: const ColorFilter.mode(
                      AppColors.primaryColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(-4, 10),
                  child: SlideTransition(
                    position: _textSlide,
                    child: SvgPicture.asset(
                      AppAssets.dsn,
                      width: 12,
                      height: 12,
                      colorFilter: const ColorFilter.mode(
                        AppColors.onSurfaceLight,
                        BlendMode.srcIn,
                      ),
                    ),
                    //   AppStrings.headerTitle,
                    //   style: TextStyle(
                    //     color: AppColors.onSurfaceLight,
                    //     fontWeight: FontWeight.w900,
                    //     fontSize: 20,
                    //     shadows: [
                    //       const Shadow(
                    //         color: Colors.black,
                    //         offset: Offset(-1, -1),
                    //         blurRadius: 0,
                    //       ),
                    //       const Shadow(
                    //         color: Colors.black,
                    //         offset: Offset(1, -1),
                    //         blurRadius: 0,
                    //       ),
                    //       const Shadow(
                    //         color: Colors.black,
                    //         offset: Offset(-1, 1),
                    //         blurRadius: 0,
                    //       ),
                    //       const Shadow(
                    //         color: Colors.black,
                    //         offset: Offset(1, 1),
                    //         blurRadius: 0,
                    //       ),
                    //       // Shadow(
                    //       //   color: Colors.black.withValues(alpha: 0.3),
                    //       //   offset: const Offset(0, 2),
                    //       //   blurRadius: 4,
                    //       // ),
                    //     ],
                    //   ),
                    // ),
                  ),
                ),
              ],
            ),

            _HeaderActionsRow(
              children: [
                if (_showLiveIcon && widget.onLivePressed != null)
                  _LiveHeaderIcon(
                    isLiveInProgress: LiveConfig.isLiveInProgress,
                    blinkAnimation: LiveConfig.isLiveInProgress
                        ? _liveBlinkAnimation
                        : null,
                    onPressed: widget.onLivePressed!,
                  ),
                _HeaderIcon(
                  icon: Icons.notifications_outlined,
                  onPressed: widget.onNotificationsPressed ?? () {},
                ),
                _HeaderIcon(
                  icon: Icons.search,
                  onPressed: widget.onSearchPressed ?? () {},
                ),
                _HeaderIcon(
                  icon: Icons.more_vert,
                  onPressed: () => showHeaderMenu(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Ligne d’icônes à droite du header : même hauteur, centrées.
class _HeaderActionsRow extends StatelessWidget {
  const _HeaderActionsRow({required this.children});

  final List<Widget> children;

  static const double _cellSize = 34;
  static const double _rowHeight = 44;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _rowHeight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children
            .map(
              (c) => c is _LiveHeaderIcon
                  ? c
                  : SizedBox(
                      width: _cellSize,
                      height: _cellSize,
                      child: Center(child: c),
                    ),
            )
            .toList(),
      ),
    );
  }
}

class _LiveHeaderIcon extends StatelessWidget {
  const _LiveHeaderIcon({
    required this.isLiveInProgress,
    required this.onPressed,
    this.blinkAnimation,
  });

  final bool isLiveInProgress;
  final VoidCallback onPressed;
  final Animation<double>? blinkAnimation;

  @override
  Widget build(BuildContext context) {
    if (!isLiveInProgress) {
      return IconButton(
        icon: SvgPicture.asset(
          AppAssets.livecustom,
          width: 24,
          height: 24,
          colorFilter: const ColorFilter.mode(
            AppColors.blackIcon,
            BlendMode.srcIn,
          ),
        ),
        onPressed: onPressed,
        style: IconButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: const Size(36, 36),
          maximumSize: const Size(36, 36),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      );
    }

    return GestureDetector(
      onTap: onPressed,
      child: SizedBox(
        height: 36,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: blinkAnimation!,
              builder: (context, child) {
                return Opacity(
                  opacity: blinkAnimation!.value,
                  child: SvgPicture.asset(
                    AppAssets.livecustom,
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(
                      Colors.red,
                      BlendMode.srcIn,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 4),
            const Text(
              AppStrings.liveTitle,
              style: TextStyle(
                color: Colors.red,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  static const double _iconSize = 24;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: AppColors.blackIcon, size: _iconSize),
      onPressed: onPressed,
      style: IconButton.styleFrom(
        padding: const EdgeInsets.all(0),
        minimumSize: const Size(36, 36),
        maximumSize: const Size(36, 36),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
