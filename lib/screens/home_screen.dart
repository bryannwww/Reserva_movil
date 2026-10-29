import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/responsive.dart';
import '../models/dish.dart';
import '../routing/app_routes.dart';
import '../state/auth_controller.dart';
import '../widgets/app_shell.dart';
import '../widgets/common.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openProtected(BuildContext context, String route) {
    final auth = context.read<AuthController>();
    if (auth.isAuthenticated) {
      Navigator.of(context).pushNamed(route);
    } else {
      Navigator.of(context).pushNamed(AppRoutes.login, arguments: route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    return AppShell(
      currentIndex: 0,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 30),
            PageFrame(
              applyBottomPadding: false,
              child: _Hero(
                authenticated: auth.isAuthenticated,
                displayName: auth.displayName,
                onReserve: () => _openProtected(context, AppRoutes.reservation),
                onMenu: () => _openProtected(context, AppRoutes.menu),
              ),
            ),
            SizedBox(height: Breakpoints.sectionSpacing(context) + 12),
            PageFrame(
              applyBottomPadding: false,
              child: _QuickActions(
                authenticated: auth.isAuthenticated,
                onOpen: (route) => _openProtected(context, route),
              ),
            ),
            SizedBox(height: Breakpoints.sectionSpacing(context) + 12),
            const PageFrame(
              applyBottomPadding: false,
              child: _ExperienceSection(),
            ),
            SizedBox(height: Breakpoints.sectionSpacing(context) + 12),
            const PageFrame(applyBottomPadding: false, child: _HowItWorks()),
            SizedBox(height: Breakpoints.sectionSpacing(context)),
            const _Footer(),
          ],
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({
    required this.authenticated,
    required this.displayName,
    required this.onReserve,
    required this.onMenu,
  });

  final bool authenticated;
  final String displayName;
  final VoidCallback onReserve;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final mobile = Breakpoints.isMobile(context);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 16),
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (authenticated) ...[
            Center(
              child: Text(
                'Hola, $displayName',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  color: AppColors.gold,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
          const Center(
            child: Eyebrow('Disfruta. Vive la experiencia.', center: true),
          ),
          const SizedBox(height: 22),
          Text(
            'Tu mesa te espera,\nnosotros la preparamos',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: mobile ? 40 : 66,
              height: 1.04,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.4,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 22),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Text(
                'Experiencias gastronómicas exclusivas en Medellín. Reserva tu mesa ideal en segundos y asegura una noche inolvidable.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  height: 1.75,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 34),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 290),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PrimaryButton(
                    label: 'Reservar mesa ahora',
                    expand: true,
                    onPressed: onReserve,
                  ),
                  const SizedBox(height: 12),
                  SecondaryButton(
                    label: 'Ver menú',
                    expand: true,
                    icon: Icons.restaurant_menu_outlined,
                    onPressed: onMenu,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: Text(
              'Disponibilidad y confirmación sujetas al restaurante.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.authenticated, required this.onOpen});

  final bool authenticated;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _QuickActionData(
        number: '01',
        title: 'La carta',
        description:
            'Descubre entradas, platos fuertes, bebidas y postres de temporada.',
        route: AppRoutes.menu,
        meta: authenticated ? 'Disponible ahora' : 'Requiere cuenta',
      ),
      _QuickActionData(
        number: '02',
        title: 'Nueva reserva',
        description:
            'Selecciona fecha, hora, personas y la mesa que prefieras.',
        route: AppRoutes.reservation,
        meta: 'Paso a paso',
      ),
      _QuickActionData(
        number: '03',
        title: 'Mis reservas',
        description:
            'Consulta el estado de tus visitas y cancela cuando lo necesites.',
        route: AppRoutes.myReservations,
        meta: authenticated ? 'Tu historial' : 'Requiere cuenta',
      ),
    ];

    final columns = Breakpoints.isMobile(context) ? 1 : 3;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeading(
          eyebrow: 'Todo a tu alcance',
          title: 'Diseñado para tu visita',
          subtitle: 'Una experiencia sencilla para elegir, reservar y volver.',
          center: true,
        ),
        const SizedBox(height: 30),
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 14.0;
            final width =
                (constraints.maxWidth - spacing * (columns - 1)) / columns;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (final card in cards)
                  SizedBox(
                    width: width,
                    child: AppCard(
                      onTap: () => onOpen(card.route),
                      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                card.number,
                                style: const TextStyle(
                                  fontFamily: 'CormorantGaramond',
                                  fontSize: 30,
                                  height: 1,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.gold,
                                ),
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.arrow_outward_rounded,
                                size: 16,
                                color: AppColors.textMuted,
                              ),
                            ],
                          ),
                          const SizedBox(height: 26),
                          Text(
                            card.title,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 9),
                          Text(
                            card.description,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  height: 1.6,
                                  color: AppColors.textSecondary,
                                ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            card.meta.toUpperCase(),
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                              color: AppColors.gold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _QuickActionData {
  const _QuickActionData({
    required this.number,
    required this.title,
    required this.description,
    required this.route,
    required this.meta,
  });

  final String number;
  final String title;
  final String description;
  final String route;
  final String meta;
}

class _ExperienceSection extends StatelessWidget {
  const _ExperienceSection();

  @override
  Widget build(BuildContext context) {
    final desktop = Breakpoints.isDesktop(context);
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(
          eyebrow: 'La experiencia',
          title: 'Una carta que se vive',
          subtitle:
              'Cada plato de la carta de ReserVa se consulta directamente desde el restaurante: precio, categoría y disponibilidad sin datos de ejemplo.',
        ),
        const SizedBox(height: 26),
        const _Bullet(
          icon: Icons.check_circle_outline_rounded,
          text: 'Disponibilidad real de mesas por fecha, hora y personas.',
        ),
        const _Bullet(
          icon: Icons.check_circle_outline_rounded,
          text:
              'Reserva con o sin mesa asignada, respetando las reglas del restaurante.',
        ),
        const _Bullet(
          icon: Icons.check_circle_outline_rounded,
          text: 'Estados de reserva visibles y cancelación con confirmación.',
        ),
      ],
    );

    final panel = AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'NUESTRA CARTA',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.gold,
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.restaurant_menu_rounded,
                size: 17,
                color: AppColors.textMuted,
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < dishCategories.length - 1; i++) ...[
            _CategoryRow(
              icon: _categoryIcon(dishCategories[i + 1]['value']!),
              label: dishCategories[i + 1]['label']!,
            ),
            if (i < dishCategories.length - 2)
              const Divider(height: 1, color: AppColors.borderSubtle),
          ],
          const SizedBox(height: 18),
          Row(
            children: [
              const Icon(
                Icons.verified_outlined,
                size: 15,
                color: AppColors.gold,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Datos en vivo desde la API de ReserVa.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (desktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 6, child: text),
          const SizedBox(width: 48),
          Expanded(flex: 4, child: panel),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [text, const SizedBox(height: 26), panel],
    );
  }

  IconData _categoryIcon(String value) {
    switch (value) {
      case 'entradas':
        return Icons.eco_outlined;
      case 'platos_fuertes':
        return Icons.local_dining_outlined;
      case 'bebidas':
        return Icons.wine_bar_outlined;
      case 'postres':
        return Icons.cake_outlined;
      default:
        return Icons.restaurant_outlined;
    }
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        children: [
          Icon(icon, size: 17, color: AppColors.gold),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.titleSmall),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            size: 17,
            color: AppColors.textMuted,
          ),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.gold),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _HowItWorks extends StatelessWidget {
  const _HowItWorks();

  @override
  Widget build(BuildContext context) {
    const steps = [
      (
        number: '01',
        title: 'Elige el momento',
        description:
            'Fecha, hora y cantidad de personas. Consultamos la disponibilidad real del restaurante.',
      ),
      (
        number: '02',
        title: 'Encuentra tu mesa',
        description:
            'Filtra por zona y selecciona una mesa libre, o deja que la reserva quede sin asignación.',
      ),
      (
        number: '03',
        title: 'Confirma y listo',
        description:
            'Revisa los datos y envía tu solicitud. El estado quedará siempre a la vista en Mis reservas.',
      ),
    ];

    final columns = Breakpoints.isMobile(context) ? 1 : 3;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeading(
          eyebrow: 'Cómo funciona',
          title: 'Reservar toma minutos',
          subtitle:
              'Sin llamadas ni formularios interminables. Un flujo claro, paso a paso.',
          center: true,
        ),
        const SizedBox(height: 30),
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 14.0;
            final width =
                (constraints.maxWidth - spacing * (columns - 1)) / columns;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (final step in steps)
                  SizedBox(
                    width: width,
                    child: AppCard(
                      hoverable: false,
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step.number,
                            style: const TextStyle(
                              fontFamily: 'CormorantGaramond',
                              fontSize: 32,
                              height: 1,
                              fontWeight: FontWeight.w600,
                              color: AppColors.gold,
                            ),
                          ),
                          const SizedBox(height: 22),
                          Text(
                            step.title,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 9),
                          Text(
                            step.description,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  height: 1.6,
                                  color: AppColors.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.borderSubtle)),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: Breakpoints.pagePadding(context),
        vertical: 40,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            children: [
              const BrandMark(size: 32),
              const SizedBox(height: 16),
              Text(
                'Reservas de alta cocina en Medellín.',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 18),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 6,
                runSpacing: 4,
                children: [
                  _FooterLink(
                    label: 'La carta',
                    onTap: () =>
                        Navigator.of(context).pushNamed(AppRoutes.menu),
                  ),
                  _FooterLink(
                    label: 'Reservar',
                    onTap: () =>
                        Navigator.of(context).pushNamed(AppRoutes.reservation),
                  ),
                  _FooterLink(
                    label: 'Mis reservas',
                    onTap: () => Navigator.of(
                      context,
                    ).pushNamed(AppRoutes.myReservations),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Divider(color: AppColors.borderSubtle),
              const SizedBox(height: 18),
              Text(
                '© 2026 ReserVa · Todos los derechos reservados.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 10.5,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 36),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        foregroundColor: AppColors.textSecondary,
        textStyle: const TextStyle(
          fontFamily: 'Manrope',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
      child: Text(label),
    );
  }
}
