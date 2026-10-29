import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/responsive.dart';
import '../routing/app_routes.dart';
import 'common.dart';

/// Estructura compartida por inicio de sesión y registro: formulario centrado,
/// marca discreta, antetítulo dorado y tipografía editorial.
class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.form,
    this.footer,
    this.onBack,
    this.backLabel = 'Volver al inicio',
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final Widget form;
  final Widget? footer;
  final VoidCallback? onBack;
  final String backLabel;

  void _back(BuildContext context) {
    if (onBack != null) {
      onBack!();
      return;
    }
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      navigator.pushReplacementNamed(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            Breakpoints.pagePadding(context),
            16,
            Breakpoints.pagePadding(context),
            32,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (wide) ...[
                    Center(
                      child: BrandMark(
                        size: 38,
                        onTap: () =>
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              AppRoutes.home,
                              (route) => false,
                            ),
                      ),
                    ),
                    const SizedBox(height: 22),
                  ],
                  Center(
                    child: TextButton.icon(
                      onPressed: () => _back(context),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        minimumSize: const Size(0, 44),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        textStyle: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                        ),
                      ),
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        size: 13,
                        color: AppColors.gold,
                      ),
                      label: Text(backLabel.toUpperCase()),
                    ),
                  ),
                  const SizedBox(height: 26),
                  Center(child: Eyebrow(eyebrow, center: true)),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontSize: wide ? 46 : 38,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 380),
                      child: Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          height: 1.7,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  form,
                  if (footer != null) ...[const SizedBox(height: 24), footer!],
                  const SizedBox(height: 26),
                  Text(
                    'ReserVa · Medellín, Colombia',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      letterSpacing: 1,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
