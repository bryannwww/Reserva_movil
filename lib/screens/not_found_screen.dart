import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/responsive.dart';
import '../routing/app_routes.dart';
import '../widgets/common.dart';
import '../widgets/ornaments.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key, this.routeName});

  final String? routeName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(
            child: CustomPaint(
              painter: OrnamentPainter(opacity: 0.1, rings: 8),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(Breakpoints.pagePadding(context)),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const BrandMark(size: 46),
                      const SizedBox(height: 36),
                      Text(
                        '404',
                        style: Theme.of(context).textTheme.displayLarge
                            ?.copyWith(
                              fontSize: 84,
                              color: AppColors.goldLight,
                              height: 1,
                            ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Esta mesa no existe',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        routeName == null || routeName!.isEmpty
                            ? 'La página que buscas no está disponible en ReserVa.'
                            : 'La página “$routeName” no está disponible en ReserVa.',
                        textAlign: TextAlign.center,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(height: 1.6),
                      ),
                      const SizedBox(height: 28),
                      PrimaryButton(
                        label: 'Volver al inicio',
                        icon: Icons.home_outlined,
                        onPressed: () =>
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              AppRoutes.home,
                              (route) => false,
                            ),
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
}
