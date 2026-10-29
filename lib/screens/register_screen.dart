import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/errors/api_exception.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/validators.dart';
import '../routing/app_routes.dart';
import '../state/auth_controller.dart';
import '../widgets/auth_layout.dart';
import '../widgets/common.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, this.nextRoute});

  final String? nextRoute;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    FocusScope.of(context).unfocus();
    setState(() => _error = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _submitting = true);
    try {
      await context.read<AuthController>().register(
        nombre: _nameController.text.trim(),
        email: _emailController.text.trim(),
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
      setState(() => _error = _friendlyError(error));
    } catch (_) {
      if (!mounted) return;
      setState(
        () => _error =
            'No pudimos crear tu cuenta. Inténtalo de nuevo en unos momentos.',
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _friendlyError(ApiException error) {
    if (error.hasFieldErrors) {
      final labels = <String, String>{
        'nombre': 'Nombre',
        'email': 'Correo',
        'password': 'Contraseña',
        'contraseña': 'Contraseña',
      };
      final parts = <String>[];
      error.fieldErrors.forEach((field, messages) {
        final label = labels[field] ?? field;
        if (messages.isNotEmpty) parts.add('$label: ${messages.first}');
      });
      if (parts.isNotEmpty) return parts.join('\n');
    }
    return error.message;
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      eyebrow: 'Membresía ReserVa',
      title: 'Crear una Cuenta',
      subtitle: 'Únete a ReserVa y gestiona tus reservas con elegancia.',
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
                label: 'Nombre completo',
                child: TextFormField(
                  controller: _nameController,
                  enabled: !_submitting,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  autofillHints: const [AutofillHints.name],
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14.5,
                    color: AppColors.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Ej. Bryan Penagos',
                  ),
                  validator: Validators.name,
                  onFieldSubmitted: (_) => _emailFocus.requestFocus(),
                ),
              ),
              const SizedBox(height: 18),
              LabeledField(
                label: 'Correo electrónico',
                child: TextFormField(
                  controller: _emailController,
                  focusNode: _emailFocus,
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
                  decoration: const InputDecoration(
                    hintText: 'correo@ejemplo.com',
                  ),
                  validator: Validators.email,
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
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.newPassword],
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14.5,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Mínimo 8 caracteres',
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
                  validator: (value) =>
                      Validators.password(value, registering: true),
                  onFieldSubmitted: (_) => _confirmFocus.requestFocus(),
                ),
              ),
              const SizedBox(height: 18),
              LabeledField(
                label: 'Confirmar contraseña',
                child: TextFormField(
                  controller: _confirmController,
                  focusNode: _confirmFocus,
                  enabled: !_submitting,
                  obscureText: _obscureConfirm,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.newPassword],
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14.5,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Repite tu contraseña',
                    suffixIcon: IconButton(
                      tooltip: _obscureConfirm
                          ? 'Mostrar contraseña'
                          : 'Ocultar contraseña',
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 19,
                      ),
                    ),
                  ),
                  validator: (value) => Validators.confirmPassword(
                    value,
                    _passwordController.text,
                  ),
                  onFieldSubmitted: (_) => _submit(),
                ),
              ),
              const SizedBox(height: 26),
              PrimaryButton(
                label: 'Registrarme',
                expand: true,
                height: 52,
                loading: _submitting,
                onPressed: _submit,
              ),
              const SizedBox(height: 16),
              Text(
                'Al crear tu cuenta aceptas el uso de tus datos para gestionar reservas en ReserVa. No compartimos tu contraseña.',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontSize: 10.5, height: 1.6),
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
            '¿Ya tienes cuenta?',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontSize: 12),
          ),
          TextButton(
            onPressed: _submitting
                ? null
                : () => Navigator.of(context).pushReplacementNamed(
                    AppRoutes.login,
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
            child: const Text('INICIAR SESIÓN'),
          ),
        ],
      ),
    );
  }
}
