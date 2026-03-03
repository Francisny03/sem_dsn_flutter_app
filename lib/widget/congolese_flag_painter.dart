import 'package:flutter/material.dart';
import 'package:sem_dsn/core/theme/app_colors.dart';

/// Peint la barre aux couleurs du drapeau congolais (vert, jaune diagonal, rouge).
class CongoleseFlagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    const double slope = 4; // décalage diagonal (vert/jaune et jaune/rouge)
    final double third = w / 3;

    // Vert : bord droit en diagonale (haut droit → bas gauche)
    final pathGreen = Path()
      ..moveTo(0, 0)
      ..lineTo(0, h)
      ..lineTo(third, h)
      ..lineTo(third + slope, 0)
      ..close();
    canvas.drawPath(pathGreen, Paint()..color = AppColors.flagColor1);

    // Jaune : bande en parallélogramme (diagonale haut droit → bas gauche)
    final pathYellow = Path()
      ..moveTo(third + slope, 0)
      ..lineTo(third, h)
      ..lineTo(third * 2, h)
      ..lineTo(third * 2 + slope, 0)
      ..close();
    canvas.drawPath(pathYellow, Paint()..color = AppColors.flagColor2);

    // Rouge : bord gauche en diagonale (haut droit → bas gauche)
    final pathRed = Path()
      ..moveTo(third * 2 + slope, 0)
      ..lineTo(third * 2, h)
      ..lineTo(w, h)
      ..lineTo(w, 0)
      ..close();
    canvas.drawPath(pathRed, Paint()..color = AppColors.flagColor3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
