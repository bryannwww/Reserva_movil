import 'package:flutter/material.dart';

import '../core/config/app_config.dart';
import '../core/theme/app_colors.dart';

class DishImage extends StatelessWidget {
  const DishImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.borderRadius = 0,
  });

  final String? url;
  final BoxFit fit;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final resolved = AppConfig.resolveMediaUrl(url);
    final child = resolved.isEmpty
        ? const _DishImagePlaceholder()
        : Image.network(
            resolved,
            fit: fit,
            width: double.infinity,
            height: double.infinity,
            filterQuality: FilterQuality.medium,
            errorBuilder: (_, _, _) => const _DishImagePlaceholder(),
            loadingBuilder: (context, image, progress) {
              if (progress == null) return image;
              return const _DishImageLoading();
            },
          );

    if (borderRadius <= 0) return child;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: child,
    );
  }
}

class _DishImagePlaceholder extends StatelessWidget {
  const _DishImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B1813), Color(0xFF111111)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.restaurant_rounded,
              color: AppColors.gold.withValues(alpha: 0.45),
              size: 30,
            ),
            const SizedBox(height: 8),
            Text(
              'Sin imagen',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 10.5,
                letterSpacing: 1.2,
                color: AppColors.textMuted.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DishImageLoading extends StatelessWidget {
  const _DishImageLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceSecondary,
      alignment: Alignment.center,
      child: const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 1.6,
          color: AppColors.gold,
        ),
      ),
    );
  }
}
