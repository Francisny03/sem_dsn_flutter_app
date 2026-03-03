import 'package:flutter/material.dart';

/// Durée de l'animation au clic sur l'étoile de sélection.
const Duration kSelectionStarAnimationDuration = Duration(milliseconds: 280);

/// Courbe de l'animation (léger rebond).
const Curve kSelectionStarAnimationCurve = Curves.easeOutBack;

/// Widget étoile de sélection avec animation de scale au clic.
class AnimatedSelectionStar extends StatefulWidget {
  const AnimatedSelectionStar({
    super.key,
    required this.isSelected,
    required this.onTap,
    required this.selectedColor,
    required this.unselectedColor,
    this.size = 24,
  });

  final bool isSelected;
  final VoidCallback onTap;
  final Color selectedColor;
  final Color unselectedColor;
  final double size;

  @override
  State<AnimatedSelectionStar> createState() => _AnimatedSelectionStarState();
}

class _AnimatedSelectionStarState extends State<AnimatedSelectionStar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: kSelectionStarAnimationDuration,
      vsync: this,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.25,
        ).chain(CurveTween(curve: kSelectionStarAnimationCurve)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.25,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    widget.onTap();
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Icon(
          widget.isSelected ? Icons.star : Icons.star_border,
          color: widget.isSelected
              ? widget.selectedColor
              : widget.unselectedColor,
          size: widget.size,
        ),
      ),
    );
  }
}
