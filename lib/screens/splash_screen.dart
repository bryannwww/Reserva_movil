import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../widgets/common.dart';
import '../widgets/ornaments.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: const OrnamentPainter(opacity: 0.1, rings: 9),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const MonogramSeal(size: 132),
                const SizedBox(height: 22),
                Text(
                  'ReserVa',
                  style: Theme.of(
                    context,
                  ).textTheme.displaySmall?.copyWith(letterSpacing: 2),
                ),
                const SizedBox(height: 8),
                const GoldRule(width: 54),
                const SizedBox(height: 28),
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.8,
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Preparando tu experiencia',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
