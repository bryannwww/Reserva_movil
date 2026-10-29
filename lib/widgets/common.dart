import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';
import '../core/utils/responsive.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({
    super.key,
    this.size = 44,
    this.showWordmark = true,
    this.onTap,
  });

  final double size;
  final bool showWordmark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (!showWordmark) {
      return Semantics(
        label: 'ReserVa',
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.6)),
          ),
          alignment: Alignment.center,
          child: Text(
            'R',
            style: TextStyle(
              fontFamily: 'CormorantGaramond',
              fontSize: size * 0.6,
              height: 0.9,
              fontWeight: FontWeight.w600,
              color: AppColors.gold,
            ),
          ),
        ),
      );
    }

    return Semantics(
      button: onTap != null,
      label: 'ReserVa, ir al inicio',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Center(
              widthFactor: 1,
              child: Text(
                'ReserVa',
                style: TextStyle(
                  fontFamily: 'CormorantGaramond',
                  fontSize: size * 0.72,
                  height: 1,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                  color: AppColors.gold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PageFrame extends StatelessWidget {
  const PageFrame({
    super.key,
    required this.child,
    this.maxWidth = 1180,
    this.applyBottomPadding = true,
  });

  final Widget child;
  final double maxWidth;
  final bool applyBottomPadding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            Breakpoints.pagePadding(context),
            Breakpoints.pagePadding(context),
            Breakpoints.pagePadding(context),
            applyBottomPadding ? Breakpoints.pagePadding(context) + 12 : 0,
          ),
          child: child,
        ),
      ),
    );
  }
}

class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.color, this.center = false});

  final String text;
  final Color? color;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: color ?? AppColors.gold,
      letterSpacing: center ? 2.6 : 2.4,
      fontWeight: FontWeight.w700,
    );

    if (center) {
      return Text(
        text.toUpperCase(),
        textAlign: TextAlign.center,
        style: style,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 26,
          height: 1,
          color: (color ?? AppColors.gold).withValues(alpha: 0.7),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            text.toUpperCase(),
            textAlign: TextAlign.start,
            style: style,
          ),
        ),
      ],
    );
  }
}

class SectionHeading extends StatelessWidget {
  const SectionHeading({
    super.key,
    required this.eyebrow,
    required this.title,
    this.subtitle,
    this.trailing,
    this.center = false,
  });

  final String eyebrow;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final align = center ? CrossAxisAlignment.center : CrossAxisAlignment.start;
    final textAlign = center ? TextAlign.center : TextAlign.start;
    final text = Column(
      crossAxisAlignment: align,
      children: [
        if (center) Eyebrow(eyebrow, center: true) else Eyebrow(eyebrow),
        const SizedBox(height: 14),
        Text(
          title,
          textAlign: textAlign,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Text(
              subtitle!,
              textAlign: textAlign,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.65,
              ),
            ),
          ),
        ],
      ],
    );

    if (trailing == null) return text;
    if (Breakpoints.isMobile(context) || center) {
      return Column(
        crossAxisAlignment: align,
        children: [
          text,
          const SizedBox(height: 18),
          if (center) Center(child: trailing!) else trailing!,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: text),
        const SizedBox(width: 24),
        trailing!,
      ],
    );
  }
}

/// Encabezado editorial centrado usado por las pantallas principales.
class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
  });

  final String eyebrow;
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final wide = !Breakpoints.isMobile(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (leading != null) ...[
          Center(child: leading!),
          const SizedBox(height: 22),
        ],
        Center(child: Eyebrow(eyebrow, center: true)),
        const SizedBox(height: 14),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontSize: wide ? 46 : 38,
            height: 1.05,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 14),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.65,
                ),
              ),
            ),
          ),
        ],
        if (trailing != null) ...[
          const SizedBox(height: 16),
          Center(child: trailing!),
        ],
      ],
    );
  }
}

/// Píldora de categoría / filtro con el lenguaje visual de las referencias.
class CategoryPill extends StatelessWidget {
  const CategoryPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.height = 44,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.gold : AppColors.surface,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: selected ? AppColors.gold : AppColors.borderSubtle,
            ),
          ),
          child: Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: selected ? AppColors.black : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Etiqueta pequeña sobre un campo de formulario.
class LabeledField extends StatelessWidget {
  const LabeledField({
    super.key,
    required this.label,
    required this.child,
    this.optional = false,
  });

  final String label;
  final Widget child;
  final bool optional;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FieldLabel(label, optional: optional),
        child,
      ],
    );
  }
}

class GoldRule extends StatelessWidget {
  const GoldRule({super.key, this.width = 42, this.height = 1});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.goldDark, AppColors.goldLight],
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.expand = false,
    this.height = 50,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final bool expand;
  final double height;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: SizedBox(
        height: height,
        width: expand ? double.infinity : null,
        child: FilledButton(
          onPressed: enabled ? onPressed : null,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: AppColors.black,
            disabledBackgroundColor: AppColors.surfaceSecondary,
            disabledForegroundColor: AppColors.textMuted,
            padding: const EdgeInsets.symmetric(horizontal: 26),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            textStyle: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.3,
            ),
          ),
          child: Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (loading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.8,
                    color: AppColors.black,
                  ),
                )
              else if (icon != null)
                Icon(icon, size: 17),
              if (loading || icon != null) const SizedBox(width: 9),
              Flexible(
                child: Text(
                  loading ? 'Procesando…' : label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = false,
    this.height = 50,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;
  final double height;

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[Icon(icon, size: 17), const SizedBox(width: 9)],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );

    return SizedBox(
      height: height,
      width: expand ? double.infinity : null,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          backgroundColor: AppColors.surface,
          side: const BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          textStyle: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.3,
          ),
        ),
        child: content,
      ),
    );
  }
}

class AppCard extends StatefulWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(22),
    this.onTap,
    this.selected = false,
    this.hoverable = true,
    this.backgroundColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool selected;
  final bool hoverable;
  final Color? backgroundColor;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final highlight = widget.selected || (_hovered && widget.hoverable);
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? AppColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: highlight
              ? AppColors.gold.withValues(alpha: widget.selected ? 0.8 : 0.4)
              : AppColors.borderSubtle,
        ),
      ),
      child: widget.onTap == null
          ? Padding(padding: widget.padding, child: widget.child)
          : Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(4),
                splashColor: AppColors.gold.withValues(alpha: 0.05),
                highlightColor: AppColors.gold.withValues(alpha: 0.03),
                child: Padding(padding: widget.padding, child: widget.child),
              ),
            ),
    );

    if (!widget.hoverable) return card;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: card,
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status, this.compact = false});

  final String status;
  final bool compact;

  Color get _color {
    switch (status.toLowerCase()) {
      case 'confirmada':
        return AppColors.success;
      case 'pendiente':
        return AppColors.gold;
      case 'asistio':
        return AppColors.info;
      case 'cancelada':
      case 'no_asistio':
        return AppColors.danger;
      case 'completada':
        return AppColors.textMuted;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 9 : 11,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            statusLabel(status).toUpperCase(),
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: compact ? 9.5 : 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(icon, color: AppColors.gold, size: 26),
          ),
          const SizedBox(height: 22),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 22),
            PrimaryButton(label: actionLabel!, onPressed: onAction),
          ],
        ],
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedHeight) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: content,
            ),
          );
        }
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 460,
              minHeight: constraints.maxHeight,
            ),
            child: Center(child: content),
          ),
        );
      },
    );
  }
}

class ErrorPanel extends StatelessWidget {
  const ErrorPanel({
    super.key,
    required this.message,
    this.onRetry,
    this.retryLabel = 'Reintentar',
  });

  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: AppColors.danger,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    height: 1.5,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 14),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(retryLabel),
            ),
          ],
        ],
      ),
    );
  }
}

class LoadingPanel extends StatelessWidget {
  const LoadingPanel({super.key, this.message = 'Cargando…'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(height: 18),
          Text(message, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class InlineBanner extends StatelessWidget {
  const InlineBanner({
    super.key,
    required this.message,
    this.type = InlineBannerType.error,
  });

  final String message;
  final InlineBannerType type;

  Color get _color => switch (type) {
    InlineBannerType.error => AppColors.danger,
    InlineBannerType.success => AppColors.success,
    InlineBannerType.info => AppColors.info,
  };

  IconData get _icon => switch (type) {
    InlineBannerType.error => Icons.error_outline_rounded,
    InlineBannerType.success => Icons.check_circle_outline_rounded,
    InlineBannerType.info => Icons.info_outline_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_icon, color: _color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 13,
                height: 1.45,
                color: _color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum InlineBannerType { error, success, info }

class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key, this.optional = false});

  final String text;
  final bool optional;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            text,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 1.5,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (optional) ...[
            const SizedBox(width: 6),
            Text('· opcional', style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: AppColors.gold),
          const SizedBox(width: 12),
          SizedBox(
            width: 108,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

void showAppSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 4),
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: isError ? AppColors.danger : AppColors.success,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
}

Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirmar',
  String cancelLabel = 'Volver',
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(cancelLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: destructive
                ? FilledButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    foregroundColor: AppColors.black,
                  )
                : null,
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return result ?? false;
}

/// Envuelve una pantalla pública que requiere sesión y muestra una invitación
/// elegante a iniciar sesión en lugar de un error técnico.
class SignInRequired extends StatelessWidget {
  const SignInRequired({
    super.key,
    required this.title,
    required this.message,
    required this.nextRoute,
  });

  final String title;
  final String message;
  final String nextRoute;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.lock_outline_rounded,
      title: title,
      message: message,
      actionLabel: 'Iniciar sesión',
      onAction: () {
        Navigator.of(context).pushNamed('/login', arguments: nextRoute);
      },
    );
  }
}
