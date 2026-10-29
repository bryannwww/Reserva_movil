import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/errors/api_exception.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';
import '../models/reservation.dart';
import '../routing/app_routes.dart';
import '../services/reservation_service.dart';
import '../state/auth_controller.dart';
import '../widgets/app_shell.dart';
import '../widgets/common.dart';
import '../widgets/reservation_card.dart';

class MyReservationsScreen extends StatefulWidget {
  const MyReservationsScreen({super.key});

  @override
  State<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen> {
  static const List<_FilterOption> _filters = [
    _FilterOption(value: 'todas', label: 'Todas'),
    _FilterOption(value: 'pendiente', label: 'Pendientes'),
    _FilterOption(value: 'confirmada', label: 'Confirmadas'),
    _FilterOption(value: 'asistio', label: 'Asistió'),
    _FilterOption(value: 'completada', label: 'Completadas'),
    _FilterOption(value: 'cancelada', label: 'Canceladas'),
  ];

  String _filter = 'todas';
  List<Reservation> _reservations = const <Reservation>[];
  bool _loading = false;
  String? _error;
  int? _cancellingId;

  @override
  void initState() {
    super.initState();
    if (context.read<AuthController>().isAuthenticated) {
      _load();
    }
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final reservations = await context.read<ReservationService>().fetchMine(
        estado: _filter == 'todas' ? null : _filter,
      );
      if (!mounted) return;
      setState(() {
        _reservations = reservations;
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.isUnauthorized) {
        await context.read<AuthController>().expireSession();
        if (!mounted) return;
      }
      setState(() {
        _error = error.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error =
            'No pudimos cargar tus reservas. Revisa tu conexión e inténtalo de nuevo.';
        _loading = false;
      });
    }
  }

  void _selectFilter(String value) {
    if (_filter == value) return;
    setState(() => _filter = value);
    _load();
  }

  Future<void> _openDetail(Reservation reservation) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (dialogContext) =>
          _ReservationDetailDialog(reservation: reservation),
    );
    if (shouldCancel != true || !mounted) return;

    final confirmed = await showConfirmDialog(
      context,
      title: 'Cancelar reserva',
      message:
          '¿Seguro que deseas cancelar tu reserva del ${formatLongDate(reservation.fecha)} a las ${reservation.horaLabel}? Esta acción no se puede deshacer.',
      confirmLabel: 'Sí, cancelar',
      cancelLabel: 'Mantener',
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    await _cancel(reservation);
  }

  Future<void> _cancel(Reservation reservation) async {
    setState(() => _cancellingId = reservation.id);
    try {
      final updated = await context.read<ReservationService>().cancel(
        reservation.id,
      );
      if (!mounted) return;
      setState(() {
        _reservations = _reservations
            .map((item) => item.id == updated.id ? updated : item)
            .where(
              (item) =>
                  _filter == 'todas' ||
                  item.estado.toLowerCase() == _filter.toLowerCase(),
            )
            .toList(growable: false);
        _cancellingId = null;
      });
      if (!mounted) return;
      showAppSnackBar(context, 'Tu reserva fue cancelada.');
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.isUnauthorized) {
        await context.read<AuthController>().expireSession();
        if (!mounted) return;
      }
      setState(() => _cancellingId = null);
      showAppSnackBar(context, error.message, isError: true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _cancellingId = null);
      showAppSnackBar(
        context,
        'No pudimos cancelar la reserva. Inténtalo de nuevo.',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authenticated = context.watch<AuthController>().isAuthenticated;

    return AppShell(
      currentIndex: 3,
      child: authenticated
          ? _buildBody(context)
          : PageFrame(
              child: SignInRequired(
                title: 'Tu historial de reservas',
                message:
                    'Inicia sesión para consultar tus reservas, revisar su estado y cancelarlas cuando lo necesites.',
                nextRoute: AppRoutes.myReservations,
              ),
            ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: PageFrame(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageHeader(
              eyebrow: 'Tu historial',
              title: 'Mis reservas',
              subtitle:
                  'Consulta el estado de cada visita y cancela las que ya no puedas disfrutar.',
              trailing: TextButton.icon(
                onPressed: _loading ? null : _load,
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 40),
                  foregroundColor: AppColors.gold,
                  textStyle: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.6,
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 14),
                label: const Text('ACTUALIZAR'),
              ),
            ),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final columns = width < 520 ? 2 : (width < 900 ? 3 : 6);
                const gap = 8.0;
                final itemWidth = (width - gap * (columns - 1)) / columns;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (final option in _filters)
                      SizedBox(
                        width: itemWidth,
                        child: CategoryPill(
                          label: option.label,
                          selected: option.value == _filter,
                          onTap: () => _selectFilter(option.value),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            if (_cancellingId != null)
              const Padding(
                padding: EdgeInsets.only(bottom: 14),
                child: LinearProgressIndicator(minHeight: 2),
              ),
            if (_loading)
              const LoadingPanel(message: 'Consultando tus reservas…')
            else if (_error != null)
              ErrorPanel(message: _error!, onRetry: _load)
            else if (_reservations.isEmpty)
              _buildEmpty(context)
            else ...[
              Text(
                '${_reservations.length} ${_reservations.length == 1 ? 'reserva' : 'reservas'}'
                    .toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.6,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 12),
              for (final reservation in _reservations) ...[
                Opacity(
                  opacity: _cancellingId == null ? 1 : 0.6,
                  child: ReservationCard(
                    reservation: reservation,
                    onTap: _cancellingId == null
                        ? () => _openDetail(reservation)
                        : () {},
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final filtered = _filter != 'todas';
    return EmptyState(
      icon: filtered
          ? Icons.filter_alt_off_outlined
          : Icons.event_note_outlined,
      title: filtered
          ? 'Sin reservas en este estado'
          : 'Aún no tienes reservas',
      message: filtered
          ? 'No encontramos reservas con el estado seleccionado. Prueba con otro filtro.'
          : 'Cuando reserves una mesa, aparecerá aquí con su estado y todos los detalles de tu visita.',
      actionLabel: filtered ? 'Ver todas' : 'Reservar una mesa',
      onAction: filtered
          ? () => _selectFilter('todas')
          : () => Navigator.of(
              context,
            ).pushReplacementNamed(AppRoutes.reservation),
    );
  }
}

class _ReservationDetailDialog extends StatelessWidget {
  const _ReservationDetailDialog({required this.reservation});

  final Reservation reservation;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 720),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  StatusChip(status: reservation.estado),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Cerrar',
                    onPressed: () => Navigator.of(context).pop(false),
                    icon: const Icon(Icons.close_rounded, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Reserva #${reservation.id}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                relativeDay(reservation.fecha),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
              InfoRow(
                icon: Icons.calendar_today_outlined,
                label: 'Fecha',
                value: formatLongDate(reservation.fecha),
              ),
              InfoRow(
                icon: Icons.schedule_rounded,
                label: 'Hora',
                value: reservation.horaLabel,
              ),
              InfoRow(
                icon: Icons.groups_outlined,
                label: 'Personas',
                value:
                    '${reservation.cantidadPersonas} ${reservation.cantidadPersonas == 1 ? 'persona' : 'personas'}',
              ),
              InfoRow(
                icon: Icons.table_restaurant_outlined,
                label: 'Mesa',
                value: reservation.mesaLabel,
              ),
              InfoRow(
                icon: Icons.flag_outlined,
                label: 'Estado',
                value: reservation.estadoLabel,
              ),
              if (reservation.notas != null)
                InfoRow(
                  icon: Icons.sticky_note_2_outlined,
                  label: 'Notas',
                  value: reservation.notas!,
                ),
              const SizedBox(height: 18),
              const Divider(),
              const SizedBox(height: 18),
              if (reservation.isCancelable) ...[
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: BorderSide(
                      color: AppColors.danger.withValues(alpha: 0.5),
                    ),
                    minimumSize: const Size(0, 48),
                  ),
                  icon: const Icon(Icons.cancel_outlined, size: 18),
                  label: const Text('Cancelar reserva'),
                ),
                const SizedBox(height: 10),
                Text(
                  'Solo puedes cancelar reservas pendientes o confirmadas.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ] else ...[
                Text(
                  'Esta reserva ya no se puede cancelar desde la aplicación.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Volver'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterOption {
  const _FilterOption({required this.value, required this.label});

  final String value;
  final String label;
}
