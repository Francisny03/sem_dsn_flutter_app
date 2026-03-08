import 'package:flutter/material.dart';

/// Bande de gradient pour l'effet shimmer (transparent → lumineux → transparent).
const double _kShimmerWidth = 120;

/// Entoure [child] d'un effet shimmer type Netflix : vague lumineuse qui balaie de gauche à droite.
class NetflixShimmer extends StatefulWidget {
  const NetflixShimmer({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<NetflixShimmer> createState() => _NetflixShimmerState();
}

class _NetflixShimmerState extends State<NetflixShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        widget.child,
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _animation,
                builder: (context, _) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  final h = constraints.maxHeight.isFinite
                      ? constraints.maxHeight
                      : 200.0;
                  final x = -_kShimmerWidth +
                      _animation.value * (w + _kShimmerWidth * 2);
                  return ClipRect(
                    child: Transform.translate(
                      offset: Offset(x, 0),
                      child: SizedBox(
                        width: _kShimmerWidth,
                        height: h,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.transparent,
                                Colors.white.withValues(alpha: 0.12),
                                Colors.white.withValues(alpha: 0.18),
                                Colors.white.withValues(alpha: 0.12),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
