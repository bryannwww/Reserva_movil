import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Arcadas concéntricas doradas usadas como ornamento de fondo.
class OrnamentPainter extends CustomPainter {
  const OrnamentPainter({
    this.color = AppColors.gold,
    this.opacity = 0.14,
    this.rings = 7,
  });

  final Color color;
  final double opacity;
  final int rings;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.72, size.height * 0.38);
    final maxRadius = math.max(size.width, size.height) * 0.68;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = color.withValues(alpha: opacity);

    for (var i = 1; i <= rings; i++) {
      final radius = maxRadius * (i / rings);
      canvas.drawCircle(center, radius, paint);
    }

    final dotPaint = Paint()..color = color.withValues(alpha: opacity * 2.2);
    for (var i = 0; i < 24; i++) {
      final angle = (i / 24) * math.pi * 2;
      final radius = maxRadius * 0.52;
      final offset = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      canvas.drawCircle(offset, i % 3 == 0 ? 2 : 1, dotPaint);
    }

    final linePaint = Paint()
      ..color = color.withValues(alpha: opacity * 1.4)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(size.width * 0.08, size.height * 0.88),
      Offset(size.width * 0.5, size.height * 0.88),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant OrnamentPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.opacity != opacity ||
        oldDelegate.rings != rings;
  }
}

/// Fondo con degradado cálido + ornamento. Nunca usa imágenes inventadas.
class OrnamentBackground extends StatelessWidget {
  const OrnamentBackground({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.intense = false,
  });

  final Widget child;
  final double borderRadius;
  final bool intense;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: intense
                ? const [
                    Color(0xFF1B1710),
                    Color(0xFF11100D),
                    AppColors.surface,
                  ]
                : const [Color(0xFF15120C), AppColors.surface],
          ),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.16)),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: const OrnamentPainter(opacity: 0.16)),
            ),
            Positioned(
              top: -60,
              right: -40,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.gold.withValues(alpha: 0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

class MonogramSeal extends StatelessWidget {
  const MonogramSeal({super.key, this.size = 180});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (var i = 0; i < 3; i++)
            Container(
              width: size - (i * 22),
              height: size - (i * 22),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.22 - i * 0.05),
                ),
              ),
            ),
          Container(
            width: size * 0.52,
            height: size * 0.52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.black.withValues(alpha: 0.35),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.55)),
            ),
            alignment: Alignment.center,
            child: Text(
              'R',
              style: TextStyle(
                fontFamily: 'CormorantGaramond',
                fontSize: size * 0.3,
                height: 0.9,
                fontWeight: FontWeight.w600,
                color: AppColors.goldLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
