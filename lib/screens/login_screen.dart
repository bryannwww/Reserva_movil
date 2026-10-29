import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/errors/api_exception.dart';
import '../core/theme/app_colors.dart';
import '../routing/app_routes.dart';
import '../state/auth_controller.dart';
import '../widgets/auth_layout.dart';
import '../widgets/common.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.nextRoute});

  final String? nextRoute;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocus = FocusNode();

  bool _obscurePassword = true;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    FocusScope.of(context).unfocus();
    setState(() => _error = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _submitting = true);
    try {
      await context.read<AuthController>().login(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      final destination =
          (widget.nextRoute == null || widget.nextRoute!.trim().isEmpty)
          ? AppRoutes.home
          : widget.nextRoute!;
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(destination, (route) => false);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _error =
            'No pudimos iniciar sesión. Inténtalo de nuevo en unos momentos.',
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      eyebrow: 'Bienvenido de nuevo',
      title: 'Tu mesa, a un paso.',
      subtitle:
          'Inicia sesión para reservar, consultar la carta y gestionar tus reservas en ReserVa.',
      form: Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_error != null) ...[
                InlineBanner(message: _error!),
                const SizedBox(height: 18),
              ],
              LabeledField(
                label: 'Correo electrónico',
                child: TextFormField(
                  controller: _emailController,
                  enabled: !_submitting,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  autocorrect: false,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14.5,
                    color: AppColors.textPrimary,
                  ),
                  decoration: const InputDecoration(hintText: 'tu@correo.com'),
                  validator: (value) => _validateEmail(value),
                  onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                ),
              ),
              const SizedBox(height: 18),
              LabeledField(
                label: 'Contraseña',
                child: TextFormField(
                  controller: _passwordController,
                  focusNode: _passwordFocus,
                  enabled: !_submitting,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14.5,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Tu contraseña',
                    suffixIcon: IconButton(
                      tooltip: _obscurePassword
                          ? 'Mostrar contraseña'
                          : 'Ocultar contraseña',
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 19,
                      ),
                    ),
                  ),
                  validator: (value) => _validatePassword(value),
                  onFieldSubmitted: (_) => _submit(),
                ),
              ),
              const SizedBox(height: 26),
              PrimaryButton(
                label: 'Iniciar sesión',
                expand: true,
                height: 52,
                loading: _submitting,
                onPressed: _submit,
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'La carta y las reservas requieren una cuenta.',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontSize: 11),
                ),
              ),
              const SizedBox(height: 18),
              SecondaryButton(
                label: 'Continuar como invitado',
                expand: true,
                icon: Icons.explore_outlined,
                onPressed: _submitting
                    ? null
                    : () => Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRoutes.home,
                        (route) => false,
                      ),
              ),
            ],
          ),
        ),
      ),
      footer: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 2,
        children: [
          Text(
            '¿Aún no tienes cuenta?',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontSize: 12),
          ),
          TextButton(
            onPressed: _submitting
                ? null
                : () => Navigator.of(context).pushReplacementNamed(
                    AppRoutes.register,
                    arguments: widget.nextRoute,
                  ),
            style: TextButton.styleFrom(
              minimumSize: const Size(0, 44),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              textStyle: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
              ),
            ),
            child: const Text('CREAR CUENTA'),
          ),
        ],
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa tu correo electrónico.';
    }
    final pattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!pattern.hasMatch(value.trim())) {
      return 'Ingresa un correo electrónico válido.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Ingresa tu contraseña.';
    return null;
  }
}
