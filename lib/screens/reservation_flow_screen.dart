import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/errors/api_exception.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';
import '../core/utils/responsive.dart';
import '../models/reservation.dart';
import '../models/restaurant_table.dart';
import '../models/zone.dart';
import '../routing/app_routes.dart';
import '../services/menu_service.dart';
import '../services/reservation_service.dart';
import '../state/auth_controller.dart';
import '../widgets/app_shell.dart';
import '../widgets/common.dart';

class ReservationFlowScreen extends StatefulWidget {
  const ReservationFlowScreen({super.key});

  @override
  State<ReservationFlowScreen> createState() => _ReservationFlowScreenState();
}

class _ReservationFlowScreenState extends State<ReservationFlowScreen> {
  late DateTime _date;
  late TimeOfDay _time;
  int _personas = 2;
  int _step = 0;

  List<Zone> _zones = const <Zone>[];
  bool _loadingZones = false;
  String? _zonesError;
  int? _zonaId;

  List<RestaurantTable> _tables = const <RestaurantTable>[];
  bool _loadingTables = false;
  String? _tablesError;
  RestaurantTable? _selectedTable;

  String? _timeError;
  final TextEditingController _notes = TextEditingController();

  bool _submitting = false;
  String? _submitError;
  Reservation? _created;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (now.hour >= 21) {
      _date = today.add(const Duration(days: 1));
      _time = const TimeOfDay(hour: 19, minute: 0);
    } else if (now.hour >= 19) {
      _date = today;
      _time = TimeOfDay(hour: now.hour + 2, minute: 0);
    } else {
      _date = today;
      _time = const TimeOfDay(hour: 19, minute: 0);
    }
    if (context.read<AuthController>().isAuthenticated) {
      _loadZones();
    }
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _loadZones() async {
    setState(() {
      _loadingZones = true;
      _zonesError = null;
    });
    try {
      final zones = await context.read<MenuService>().fetchZones();
      if (!mounted) return;
      setState(() {
        _zones = zones;
        _loadingZones = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.isUnauthorized) {
        await context.read<AuthController>().expireSession();
        if (!mounted) return;
      }
      setState(() {
        _zonesError =
            'No pudimos cargar las zonas. Puedes reservar sin filtrar por zona.';
        _loadingZones = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _zonesError =
            'No pudimos cargar las zonas. Puedes reservar sin filtrar por zona.';
        _loadingZones = false;
      });
    }
  }

  void _invalidateTables() {
    _tables = const <RestaurantTable>[];
    _selectedTable = null;
    _tablesError = null;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _date.isBefore(today) ? today : _date,
      firstDate: today,
      lastDate: today.add(const Duration(days: 90)),
      helpText: 'Selecciona la fecha',
      cancelText: 'Cancelar',
      confirmText: 'Elegir',
    );
    if (picked == null || !mounted) return;
    setState(() {
      _date = picked;
      _timeError = null;
      _invalidateTables();
      _step = 0;
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
      helpText: 'Selecciona la hora',
      cancelText: 'Cancelar',
      confirmText: 'Elegir',
    );
    if (picked == null || !mounted) return;
    setState(() {
      _time = picked;
      _timeError = null;
      _invalidateTables();
      _step = 0;
    });
  }

  void _changePeople(int delta) {
    final next = (_personas + delta).clamp(1, 20);
    if (next == _personas) return;
    setState(() {
      _personas = next;
      _invalidateTables();
      _step = 0;
    });
  }

  void _selectZone(int? id) {
    if (_zonaId == id) return;
    setState(() {
      _zonaId = id;
      _invalidateTables();
      _step = 0;
    });
  }

  Future<void> _searchTables() async {
    final now = DateTime.now();
    final selected = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _time.hour,
      _time.minute,
    );
    if (selected.isBefore(now)) {
      setState(() {
        _timeError = 'Esa hora ya pasó. Elige un horario posterior.';
        _step = 0;
      });
      return;
    }

    setState(() {
      _step = 1;
      _loadingTables = true;
      _tablesError = null;
    });

    try {
      final tables = await context.read<MenuService>().fetchAvailableTables(
        fecha: _date,
        hora: _time,
        personas: _personas,
        zonaId: _zonaId,
      );
      if (!mounted) return;
      setState(() {
        _tables = tables;
        _loadingTables = false;
        if (_selectedTable != null &&
            !tables.any((table) => table.id == _selectedTable!.id)) {
          _selectedTable = null;
        }
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.isUnauthorized) {
        await context.read<AuthController>().expireSession();
        if (!mounted) return;
      }
      setState(() {
        _tablesError = error.message;
        _loadingTables = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _tablesError =
            'No pudimos consultar la disponibilidad. Revisa tu conexión e inténtalo de nuevo.';
        _loadingTables = false;
      });
    }
  }

  Future<void> _submit() async {
    if (_submitting) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _submitting = true;
      _submitError = null;
    });
    try {
      final reservation = await context.read<ReservationService>().create(
        fecha: _date,
        hora: _time,
        cantidadPersonas: _personas,
        mesa: _selectedTable,
        notas: _notes.text,
      );
      if (!mounted) return;
      setState(() {
        _created = reservation;
        _submitting = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.isUnauthorized) {
        await context.read<AuthController>().expireSession();
        if (!mounted) return;
      }
      setState(() {
        _submitError = _friendlyError(error);
        _submitting = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _submitError =
            'No pudimos registrar la reserva. Revisa tu conexión e inténtalo de nuevo.';
        _submitting = false;
      });
    }
  }

  String _friendlyError(ApiException error) {
    if (!error.hasFieldErrors) return error.message;
    const labels = {
      'fecha': 'Fecha',
      'hora': 'Hora',
      'cantidad_personas': 'Personas',
      'mesa': 'Mesa',
      'notas': 'Notas',
    };
    final parts = <String>[];
    error.fieldErrors.forEach((field, messages) {
      if (messages.isEmpty) return;
      parts.add('${labels[field] ?? field}: ${messages.first}');
    });
    return parts.isEmpty ? error.message : parts.join('\n');
  }

  void _reset() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    setState(() {
      _date = now.hour >= 21 ? today.add(const Duration(days: 1)) : today;
      _time = now.hour >= 21
          ? const TimeOfDay(hour: 19, minute: 0)
          : (now.hour >= 19
                ? TimeOfDay(hour: now.hour + 2, minute: 0)
                : const TimeOfDay(hour: 19, minute: 0));
      _personas = 2;
      _zonaId = null;
      _step = 0;
      _notes.clear();
      _submitError = null;
      _timeError = null;
      _created = null;
      _invalidateTables();
    });
  }

  String get _zonaNombre {
    for (final zone in _zones) {
      if (zone.id == _zonaId) return zone.nombre;
    }
    return 'Cualquier zona';
  }

  @override
  Widget build(BuildContext context) {
    final authenticated = context.watch<AuthController>().isAuthenticated;

    return AppShell(
      currentIndex: 2,
      child: authenticated
          ? (_created != null ? _buildSuccess(context) : _buildForm(context))
          : PageFrame(
              child: SignInRequired(
                title: 'Reserva tu mesa',
                message:
                    'Inicia sesión para consultar la disponibilidad real y registrar tu reserva.',
                nextRoute: AppRoutes.reservation,
              ),
            ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final desktop = Breakpoints.isDesktop(context);
    final summary = _SummaryCard(
      date: _date,
      time: _time,
      personas: _personas,
      zona: _zonaNombre,
      mesa: _selectedTable,
      step: _step,
    );

    return SingleChildScrollView(
      child: PageFrame(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const PageHeader(
              eyebrow: 'Nueva reserva',
              title: 'Diseña tu visita',
              subtitle:
                  'Elige cuándo vienes y con quién. La disponibilidad se consulta en el restaurante al instante.',
            ),
            const SizedBox(height: 24),
            _StepIndicator(current: _step),
            const SizedBox(height: 22),
            if (desktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildStep(context)),
                  const SizedBox(width: 24),
                  SizedBox(width: 330, child: summary),
                ],
              )
            else ...[
              summary,
              const SizedBox(height: 18),
              _buildStep(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context) {
    return switch (_step) {
      0 => _buildDateTimeStep(context),
      1 => _buildTableStep(context),
      _ => _buildConfirmStep(context),
    };
  }

  Widget _buildDateTimeStep(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _StepTitle(
            number: '01',
            title: 'Fecha y hora',
            description: 'Selecciona el momento de tu visita.',
          ),
          const SizedBox(height: 22),
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 420;
              final dateTile = _PickerTile(
                icon: Icons.calendar_today_outlined,
                label: 'Fecha',
                value: formatLongDate(_date),
                onTap: _pickDate,
              );
              final timeTile = _PickerTile(
                icon: Icons.schedule_rounded,
                label: 'Hora',
                value: formatTimeOfDay(_time),
                onTap: _pickTime,
              );
              if (stacked) {
                return Column(
                  children: [dateTile, const SizedBox(height: 12), timeTile],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: dateTile),
                  const SizedBox(width: 12),
                  Expanded(flex: 2, child: timeTile),
                ],
              );
            },
          ),
          if (_timeError != null) ...[
            const SizedBox(height: 10),
            Text(
              _timeError!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.danger),
            ),
          ],
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 22),
          Row(
            children: [
              const Expanded(
                child: _FieldHeading(
                  title: 'Personas',
                  description: 'Entre 1 y 20 comensales.',
                ),
              ),
              _PeopleStepper(
                value: _personas,
                onDecrease: _personas > 1 ? () => _changePeople(-1) : null,
                onIncrease: _personas < 20 ? () => _changePeople(1) : null,
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 22),
          const _FieldHeading(
            title: 'Zona',
            description: 'Opcional. Filtra las mesas por ambiente.',
          ),
          const SizedBox(height: 14),
          if (_loadingZones)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: LinearProgressIndicator(minHeight: 2),
            )
          else if (_zones.isEmpty)
            Text(
              _zonesError ??
                  'El restaurante no tiene zonas configuradas. Puedes reservar sin preferencia.',
              style: Theme.of(context).textTheme.bodySmall,
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth < 560 ? 2 : 3;
                const gap = 8.0;
                final itemWidth =
                    (constraints.maxWidth - gap * (columns - 1)) / columns;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    SizedBox(
                      width: itemWidth,
                      child: CategoryPill(
                        label: 'Todas',
                        selected: _zonaId == null,
                        onTap: () => _selectZone(null),
                      ),
                    ),
                    for (final zone in _zones)
                      SizedBox(
                        width: itemWidth,
                        child: CategoryPill(
                          label: zone.nombre,
                          selected: _zonaId == zone.id,
                          onTap: () => _selectZone(zone.id),
                        ),
                      ),
                  ],
                );
              },
            ),
          const SizedBox(height: 28),
          PrimaryButton(
            label: 'Ver mesas disponibles',
            expand: true,
            icon: Icons.table_restaurant_outlined,
            onPressed: _searchTables,
          ),
          const SizedBox(height: 10),
          Text(
            'Consultamos solo las mesas libres para tu fecha, hora y número de personas.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildTableStep(BuildContext context) {
    final columns = MediaQuery.sizeOf(context).width >= 1120 ? 2 : 1;

    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: _StepTitle(
                  number: '02',
                  title: 'Elige tu mesa',
                  description: 'Solo mostramos mesas libres en ese horario.',
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _step = 0),
                child: const Text('Cambiar'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _SelectionPills(
            date: _date,
            time: _time,
            personas: _personas,
            mesa: _selectedTable,
          ),
          const SizedBox(height: 18),
          if (_loadingTables)
            const LoadingPanel(message: 'Consultando disponibilidad…')
          else if (_tablesError != null)
            ErrorPanel(message: _tablesError!, onRetry: _searchTables)
          else ...[
            LayoutBuilder(
              builder: (context, constraints) {
                const spacing = 12.0;
                final width = columns == 1
                    ? constraints.maxWidth
                    : (constraints.maxWidth - spacing) / 2;
                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    SizedBox(
                      width: width,
                      child: _ChoiceCard(
                        icon: Icons.auto_awesome_outlined,
                        title: 'Sin preferencia',
                        subtitle:
                            'El restaurante asignará la mejor mesa disponible.',
                        selected: _selectedTable == null,
                        onTap: () => setState(() => _selectedTable = null),
                      ),
                    ),
                    for (final table in _tables)
                      SizedBox(
                        width: width,
                        child: _ChoiceCard(
                          icon: Icons.table_restaurant_outlined,
                          title: 'Mesa ${table.numero}',
                          subtitle:
                              '${table.capacidad} personas · ${table.zonaNombre ?? 'Sin zona'} · ${table.formaLabel}',
                          selected: _selectedTable?.id == table.id,
                          onTap: () => setState(() => _selectedTable = table),
                        ),
                      ),
                  ],
                );
              },
            ),
            if (_tables.isEmpty) ...[
              const SizedBox(height: 16),
              InlineBanner(
                message:
                    'No hay mesas libres para este horario. Puedes continuar sin preferencia y el restaurante gestionará la asignación.',
                type: InlineBannerType.info,
              ),
            ],
          ],
          const SizedBox(height: 24),
          PrimaryButton(
            label: _selectedTable == null
                ? 'Continuar sin preferencia'
                : 'Continuar con ${_selectedTable!.displayName}',
            expand: true,
            icon: Icons.arrow_forward_rounded,
            onPressed: _loadingTables ? null : () => setState(() => _step = 2),
          ),
          if (_tables.isNotEmpty && !_loadingTables) ...[
            const SizedBox(height: 10),
            Text(
              'Estas mesas están libres ahora. La asignación definitiva la confirma el restaurante.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConfirmStep(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: _StepTitle(
                  number: '03',
                  title: 'Revisa y confirma',
                  description:
                      'Verifica los datos antes de enviar tu solicitud.',
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _step = 1),
                child: const Text('Cambiar mesa'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Column(
              children: [
                InfoRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Fecha',
                  value: formatLongDate(_date),
                ),
                InfoRow(
                  icon: Icons.schedule_rounded,
                  label: 'Hora',
                  value: formatTimeOfDay(_time),
                ),
                InfoRow(
                  icon: Icons.groups_outlined,
                  label: 'Personas',
                  value:
                      '$_personas ${_personas == 1 ? 'persona' : 'personas'}',
                ),
                InfoRow(
                  icon: Icons.location_on_outlined,
                  label: 'Zona',
                  value: _zonaNombre,
                ),
                InfoRow(
                  icon: Icons.table_restaurant_outlined,
                  label: 'Mesa',
                  value: _selectedTable?.displayName ?? 'Sin preferencia',
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const FieldLabel('Notas para el restaurante', optional: true),
          TextField(
            controller: _notes,
            enabled: !_submitting,
            maxLines: 4,
            maxLength: 500,
            textInputAction: TextInputAction.newline,
            decoration: const InputDecoration(
              hintText:
                  'Alergias, celebraciones, silla para bebé, preferencias de ubicación…',
              alignLabelWithHint: true,
            ),
          ),
          if (_submitError != null) ...[
            const SizedBox(height: 14),
            InlineBanner(message: _submitError!),
          ],
          const SizedBox(height: 14),
          const InlineBanner(
            message:
                'Tu reserva quedará en estado pendiente hasta que el restaurante la confirme.',
            type: InlineBannerType.info,
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Solicitar reserva',
            expand: true,
            loading: _submitting,
            icon: Icons.check_rounded,
            onPressed: _submitting ? null : _submit,
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: _submitting ? null : () => setState(() => _step = 1),
            child: const Text('Volver a las mesas'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess(BuildContext context) {
    final reservation = _created!;
    final desktop = Breakpoints.isDesktop(context);

    return SingleChildScrollView(
      child: PageFrame(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 660),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.border),
              ),
              padding: EdgeInsets.all(desktop ? 38 : 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.gold.withValues(alpha: 0.12),
                        border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.5),
                        ),
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: AppColors.goldLight,
                        size: 34,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Reserva solicitada',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Guardamos tu solicitud. El restaurante revisará la disponibilidad y confirmará tu visita.',
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(height: 1.6),
                  ),
                  const SizedBox(height: 18),
                  Center(child: StatusChip(status: reservation.estado)),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Column(
                      children: [
                        InfoRow(
                          icon: Icons.confirmation_number_outlined,
                          label: 'Reserva',
                          value: '#${reservation.id}',
                        ),
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
                        if (reservation.notas != null)
                          InfoRow(
                            icon: Icons.sticky_note_2_outlined,
                            label: 'Notas',
                            value: reservation.notas!,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  PrimaryButton(
                    label: 'Ver mis reservas',
                    expand: true,
                    icon: Icons.event_note_outlined,
                    onPressed: () =>
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          AppRoutes.myReservations,
                          (route) => false,
                        ),
                  ),
                  const SizedBox(height: 10),
                  SecondaryButton(
                    label: 'Hacer otra reserva',
                    expand: true,
                    icon: Icons.add_rounded,
                    onPressed: _reset,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Si necesitas cambiar o cancelar, puedes hacerlo desde Mis reservas.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
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

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.current});

  final int current;

  static const List<String> _labels = ['Fecha y hora', 'Mesa', 'Confirmación'];

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Paso ${current + 1} de ${_labels.length}',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < _labels.length; i++)
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < _labels.length - 1 ? 9 : 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '0${i + 1}',
                          style: TextStyle(
                            fontFamily: 'CormorantGaramond',
                            fontSize: 21,
                            height: 1,
                            fontWeight: FontWeight.w600,
                            color: i <= current
                                ? AppColors.gold
                                : AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(width: 7),
                        if (i < current)
                          const Icon(
                            Icons.check_rounded,
                            size: 13,
                            color: AppColors.gold,
                          )
                        else if (i == current)
                          Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.gold,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 9),
                    Text(
                      _labels[i].toUpperCase(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 8.5,
                        height: 1.35,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                        color: i == current
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 10),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 1.5,
                      color: i <= current
                          ? AppColors.gold
                          : AppColors.borderSubtle,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StepTitle extends StatelessWidget {
  const _StepTitle({
    required this.number,
    required this.title,
    required this.description,
  });

  final String number;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              number,
              style: const TextStyle(
                fontFamily: 'CormorantGaramond',
                fontSize: 26,
                height: 1,
                fontWeight: FontWeight.w600,
                color: AppColors.gold,
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(title, style: Theme.of(context).textTheme.titleLarge),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(description, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _FieldHeading extends StatelessWidget {
  const _FieldHeading({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        Text(description, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppColors.gold),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 9.5,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      value,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.expand_more_rounded,
                size: 18,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PeopleStepper extends StatelessWidget {
  const _PeopleStepper({
    required this.value,
    required this.onDecrease,
    required this.onIncrease,
  });

  final int value;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Quitar una persona',
            onPressed: onDecrease,
            icon: const Icon(Icons.remove_rounded, size: 18),
          ),
          SizedBox(
            width: 34,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Agregar una persona',
            onPressed: onIncrease,
            icon: const Icon(Icons.add_rounded, size: 18),
          ),
        ],
      ),
    );
  }
}

class _SelectionPills extends StatelessWidget {
  const _SelectionPills({
    required this.date,
    required this.time,
    required this.personas,
    required this.mesa,
  });

  final DateTime date;
  final TimeOfDay time;
  final int personas;
  final RestaurantTable? mesa;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _Pill(
          icon: Icons.calendar_today_outlined,
          label: formatShortDate(date),
        ),
        _Pill(icon: Icons.schedule_rounded, label: formatTimeOfDay(time)),
        _Pill(icon: Icons.groups_outlined, label: '$personas'),
        if (mesa != null)
          _Pill(
            icon: Icons.table_restaurant_outlined,
            label: mesa!.displayName,
          ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.gold),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.goldLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      selected: selected,
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.gold.withValues(alpha: 0.16)
                  : AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: selected
                    ? AppColors.gold.withValues(alpha: 0.5)
                    : AppColors.border,
              ),
            ),
            child: Icon(icon, size: 18, color: AppColors.gold),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            selected
                ? Icons.radio_button_checked_rounded
                : Icons.radio_button_unchecked_rounded,
            size: 20,
            color: selected ? AppColors.gold : AppColors.textMuted,
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.date,
    required this.time,
    required this.personas,
    required this.zona,
    required this.mesa,
    required this.step,
  });

  final DateTime date;
  final TimeOfDay time;
  final int personas;
  final String zona;
  final RestaurantTable? mesa;
  final int step;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      hoverable: false,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'TU RESERVA',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.gold,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Paso ${step + 1} de 3',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 18),
          InfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Fecha',
            value: formatLongDate(date),
          ),
          InfoRow(
            icon: Icons.schedule_rounded,
            label: 'Hora',
            value: formatTimeOfDay(time),
          ),
          InfoRow(
            icon: Icons.groups_outlined,
            label: 'Personas',
            value: '$personas ${personas == 1 ? 'persona' : 'personas'}',
          ),
          InfoRow(icon: Icons.location_on_outlined, label: 'Zona', value: zona),
          InfoRow(
            icon: Icons.table_restaurant_outlined,
            label: 'Mesa',
            value: mesa?.displayName ?? 'Sin preferencia',
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          _SummaryStep(
            number: '01',
            label: 'Fecha y hora',
            done: step > 0,
            active: step == 0,
          ),
          _SummaryStep(
            number: '02',
            label: 'Mesa',
            done: step > 1,
            active: step == 1,
          ),
          _SummaryStep(
            number: '03',
            label: 'Confirmación',
            done: false,
            active: step == 2,
            last: true,
          ),
          const SizedBox(height: 14),
          Text(
            'Podrás ajustar estos datos antes de solicitar la reserva.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _SummaryStep extends StatelessWidget {
  const _SummaryStep({
    required this.number,
    required this.label,
    required this.done,
    required this.active,
    this.last = false,
  });

  final String number;
  final String label;
  final bool done;
  final bool active;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final color = done || active ? AppColors.gold : AppColors.textMuted;
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 10),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done ? AppColors.gold : Colors.transparent,
              border: Border.all(color: color, width: 1),
            ),
            child: done
                ? const Icon(
                    Icons.check_rounded,
                    size: 12,
                    color: AppColors.black,
                  )
                : Text(
                    number,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 12,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: active ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
