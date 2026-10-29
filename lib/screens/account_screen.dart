import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/errors/api_exception.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';
import '../core/utils/responsive.dart';
import '../models/user.dart';
import '../routing/app_routes.dart';
import '../state/auth_controller.dart';
import '../widgets/app_shell.dart';
import '../widgets/common.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _refreshing = false;

  Future<void> _refresh() async {
    if (_refreshing) return;
    setState(() => _refreshing = true);
    try {
      await context.read<AuthController>().refreshProfile();
      if (!mounted) return;
      showAppSnackBar(context, 'Perfil actualizado.');
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.isUnauthorized) {
        await context.read<AuthController>().expireSession();
        if (!mounted) return;
      }
      showAppSnackBar(context, error.message, isError: true);
    } catch (_) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        'No pudimos actualizar tu perfil. Inténtalo de nuevo.',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  Future<void> _logout() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Cerrar sesión',
      message:
          'Tu sesión se cerrará en este dispositivo. Podrás volver a entrar cuando quieras.',
      confirmLabel: 'Cerrar sesión',
      cancelLabel: 'Volver',
    );
    if (!confirmed || !mounted) return;
    await context.read<AuthController>().logout();
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.user;

    return AppShell(
      currentIndex: 4,
      child: auth.isAuthenticated && user != null
          ? _buildBody(context, user)
          : PageFrame(
              child: SignInRequired(
                title: 'Tu cuenta ReserVa',
                message:
                    'Inicia sesión para consultar tus datos y gestionar tu sesión en este dispositivo.',
                nextRoute: AppRoutes.account,
              ),
            ),
    );
  }

  Widget _buildBody(BuildContext context, User user) {
    final desktop = Breakpoints.isDesktop(context);

    final profile = AppCard(
      padding: const EdgeInsets.all(26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'PERFIL',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.gold,
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              StatusChip(status: user.estado ? 'activa' : 'inactiva'),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: Container(
              width: 84,
              height: 84,
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
                  fontFamily: 'CormorantGaramond',
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: Text(
              user.nombre,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              user.email,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(3),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.25),
                ),
              ),
              child: Text(
                user.roleLabel.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: AppColors.gold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 26),
          const Divider(),
          const SizedBox(height: 14),
          Text(
            'Tus datos provienen directamente de ReserVa. La contraseña nunca se guarda en este dispositivo.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontSize: 11),
          ),
        ],
      ),
    );

    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'DATOS DE LA CUENTA',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.gold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Actualizar perfil',
                    onPressed: _refreshing ? null : _refresh,
                    icon: _refreshing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh_rounded, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              InfoRow(
                icon: Icons.person_outline_rounded,
                label: 'Nombre',
                value: user.nombre,
              ),
              InfoRow(
                icon: Icons.mail_outline_rounded,
                label: 'Correo',
                value: user.email,
              ),
              InfoRow(
                icon: Icons.badge_outlined,
                label: 'Rol',
                value: user.roleLabel,
              ),
              InfoRow(
                icon: Icons.verified_user_outlined,
                label: 'Cuenta',
                value: user.statusLabel,
              ),
              InfoRow(
                icon: Icons.confirmation_number_outlined,
                label: 'Cliente',
                value: '#${user.id}',
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SESIÓN Y SEGURIDAD',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.gold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Tu sesión se conserva en este navegador para que no tengas que iniciar sesión cada vez. Si usas un equipo compartido, cierra sesión al terminar.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(height: 1.6),
              ),
              const SizedBox(height: 20),
              SecondaryButton(
                label: 'Actualizar perfil',
                expand: true,
                icon: Icons.refresh_rounded,
                onPressed: _refreshing ? null : _refresh,
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _logout,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: BorderSide(
                      color: AppColors.danger.withValues(alpha: 0.45),
                    ),
                  ),
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: const Text('Cerrar sesión'),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return SingleChildScrollView(
      child: PageFrame(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const PageHeader(
              eyebrow: 'Mi cuenta',
              title: 'Tu espacio personal',
              subtitle:
                  'Consulta tus datos y administra la sesión de ReserVa en este dispositivo.',
            ),
            const SizedBox(height: 26),
            if (desktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: profile),
                  const SizedBox(width: 20),
                  Expanded(flex: 6, child: details),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [profile, const SizedBox(height: 16), details],
              ),
          ],
        ),
      ),
    );
  }
}
