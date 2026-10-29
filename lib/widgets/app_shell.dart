import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';
import '../core/utils/responsive.dart';
import '../routing/app_routes.dart';
import '../state/auth_controller.dart';
import 'common.dart';

/// Estructura común de todas las pantallas: cabecera editorial superior con la
/// marca centrada y navegación en mayúsculas. En escritorio los enlaces se
/// reparten en una sola línea y se añade el acceso a la cuenta.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.currentIndex, required this.child});

  final int currentIndex;
  final Widget child;

  static const List<_NavDefinition> _memberItems = [
    _NavDefinition(label: 'Inicio', route: AppRoutes.home),
    _NavDefinition(label: 'Menú', route: AppRoutes.menu),
    _NavDefinition(label: 'Reservar mesa', route: AppRoutes.reservation),
    _NavDefinition(label: 'Mis reservas', route: AppRoutes.myReservations),
    _NavDefinition(label: 'Cuenta', route: AppRoutes.account),
  ];

  static const List<_NavDefinition> _guestItems = [
    _NavDefinition(label: 'Inicio', route: AppRoutes.home),
    _NavDefinition(label: 'Menú', route: AppRoutes.menu),
    _NavDefinition(label: 'Reservar mesa', route: AppRoutes.reservation),
    _NavDefinition(label: 'Entrar', route: AppRoutes.login),
    _NavDefinition(label: 'Registro', route: AppRoutes.register),
  ];

  void _select(BuildContext context, List<_NavDefinition> items, int index) {
    if (index == currentIndex) return;
    final route = items[index].route;
    if (route == AppRoutes.login || route == AppRoutes.register) {
      Navigator.of(context).pushNamed(route);
    } else {
      Navigator.of(context).pushReplacementNamed(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final items = auth.isAuthenticated ? _memberItems : _guestItems;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TopBar(
              currentIndex: currentIndex,
              items: items,
              onSelect: (index) => _select(context, items, index),
            ),
            const Divider(height: 1),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.currentIndex,
    required this.items,
    required this.onSelect,
  });

  final int currentIndex;
  final List<_NavDefinition> items;
  final ValueChanged<int> onSelect;

  void _goHome(BuildContext context) {
    if (currentIndex != 0) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final desktop = Breakpoints.isDesktop(context);
    final brand = BrandMark(
      size: desktop ? 40 : 36,
      onTap: () => _goHome(context),
    );

    if (!desktop) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        child: Column(
          children: [
            Center(child: brand),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 18,
              runSpacing: 8,
              children: [
                for (var i = 0; i < items.length; i++)
                  _NavLink(
                    label: items[i].label,
                    active: i == currentIndex,
                    onTap: () => onSelect(i),
                  ),
              ],
            ),
          ],
        ),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1180),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 52, vertical: 16),
          child: Row(
            children: [
              brand,
              const SizedBox(width: 40),
              Expanded(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 30,
                  runSpacing: 8,
                  children: [
                    for (var i = 0; i < items.length; i++)
                      _NavLink(
                        label: items[i].label,
                        active: i == currentIndex,
                        onTap: () => onSelect(i),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              const _SessionAction(),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  const _NavLink({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: active,
      button: true,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: active ? AppColors.gold : AppColors.textSecondary,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          minimumSize: const Size(0, 40),
          tapTargetSize: MaterialTapTargetSize.padded,
          textStyle: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.6,
          ),
        ),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.6,
            color: active ? AppColors.gold : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _SessionAction extends StatelessWidget {
  const _SessionAction();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    if (!auth.isAuthenticated) {
      return TextButton(
        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.login),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.gold,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          minimumSize: const Size(0, 40),
          textStyle: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.6,
          ),
        ),
        child: const Text('ENTRAR'),
      );
    }

    final user = auth.user!;
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.account),
      borderRadius: BorderRadius.circular(30),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceSecondary,
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.45),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                initials(user.nombre),
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gold,
                ),
              ),
            ),
            const SizedBox(width: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 140),
              child: Text(
                user.nombre.trim().isEmpty ? 'Mi cuenta' : user.nombre.trim(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavDefinition {
  const _NavDefinition({required this.label, required this.route});

  final String label;
  final String route;
}
