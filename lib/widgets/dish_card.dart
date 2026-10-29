import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';
import '../models/dish.dart';
import 'common.dart';
import 'dish_image.dart';

class DishCard extends StatefulWidget {
  const DishCard({super.key, required this.dish, required this.onTap});

  final Dish dish;
  final VoidCallback onTap;

  @override
  State<DishCard> createState() => _DishCardState();
}

class _DishCardState extends State<DishCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final dish = widget.dish;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: _hovered ? AppColors.gold : AppColors.borderSubtle,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 4 / 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: 'dish-image-${dish.id}',
                      child: DishImage(url: dish.imagen),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.black.withValues(alpha: 0.28),
                              Colors.transparent,
                              AppColors.black.withValues(alpha: 0.22),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 12,
                      top: 12,
                      child: _OverlayBadge(
                        child: Text(
                          formatCurrency(dish.precio),
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                            color: AppColors.gold,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 12,
                      top: 12,
                      child: _OverlayBadge(
                        child: Text(
                          dish.categoriaDisplay.toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 8.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    if (dish.destacado)
                      Positioned(
                        left: 12,
                        bottom: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.gold,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: const Text(
                            'DESTACADO',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.4,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                      ),
                    if (!dish.disponible)
                      Positioned(
                        right: 12,
                        bottom: 12,
                        child: _OverlayBadge(
                          child: Text(
                            'NO DISPONIBLE',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.9,
                              ),
                            ),
                          ),
                        ),
                      )
                    else if (dish.isLowStock)
                      Positioned(
                        right: 12,
                        bottom: 12,
                        child: _OverlayBadge(
                          child: Text(
                            'ÚLTIMAS ${dish.stock}',
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: AppColors.goldLight,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dish.nombre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'CormorantGaramond',
                        fontSize: 23,
                        height: 1.12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (dish.descripcion.trim().isNotEmpty) ...[
                      const SizedBox(height: 7),
                      Text(
                        dish.descripcion,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 12.5,
                          height: 1.55,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Text(
                          'VER DETALLE',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            color: AppColors.gold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 12,
                          color: AppColors.gold,
                        ),
                        const Spacer(),
                        Text(
                          formatCurrency(dish.precio),
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverlayBadge extends StatelessWidget {
  const _OverlayBadge({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.black.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: child,
    );
  }
}

Future<void> showDishDetail(
  BuildContext context,
  Dish dish, {
  VoidCallback? onReserve,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return Dialog(
        clipBehavior: Clip.antiAlias,
        insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540, maxHeight: 720),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 240,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: 'dish-image-${dish.id}',
                        child: DishImage(url: dish.imagen),
                      ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.black.withValues(alpha: 0.25),
                                Colors.transparent,
                                AppColors.surface.withValues(alpha: 0.9),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16,
                        top: 16,
                        child: _OverlayBadge(
                          child: Text(
                            formatCurrency(dish.precio),
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.gold,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Material(
                          color: AppColors.black.withValues(alpha: 0.55),
                          shape: const CircleBorder(),
                          child: IconButton(
                            tooltip: 'Cerrar',
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 19,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 6, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dish.categoriaDisplay.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.gold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        dish.nombre,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        dish.descripcion.isEmpty
                            ? 'Una creación de nuestra cocina, preparada al momento.'
                            : dish.descripcion,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(height: 1.65),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Text(
                            formatCurrency(dish.precio),
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.gold,
                            ),
                          ),
                          const Spacer(),
                          if (dish.disponible)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(
                                  alpha: 0.08,
                                ),
                                borderRadius: BorderRadius.circular(2),
                                border: Border.all(
                                  color: AppColors.success.withValues(
                                    alpha: 0.35,
                                  ),
                                ),
                              ),
                              child: const Text(
                                'DISPONIBLE',
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                  color: AppColors.success,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (dish.isLowStock) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Quedan ${dish.stock} porciones disponibles.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.warning),
                        ),
                      ],
                      const SizedBox(height: 24),
                      PrimaryButton(
                        label: 'Reservar una mesa',
                        expand: true,
                        icon: Icons.calendar_month_outlined,
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          if (onReserve != null) {
                            onReserve();
                          } else {
                            Navigator.of(
                              context,
                            ).pushReplacementNamed('/reservar');
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Precio y disponibilidad tomados en tiempo real desde ReserVa.',
                        textAlign: TextAlign.center,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(fontSize: 10.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
