import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/errors/api_exception.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/responsive.dart';
import '../models/dish.dart';
import '../routing/app_routes.dart';
import '../services/menu_service.dart';
import '../state/auth_controller.dart';
import '../widgets/app_shell.dart';
import '../widgets/common.dart';
import '../widgets/dish_card.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final TextEditingController _search = TextEditingController();
  Timer? _debounce;

  String _category = 'todos';
  List<Dish> _dishes = const <Dish>[];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (context.read<AuthController>().isAuthenticated) {
      _load();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onSearchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 420), _load);
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final dishes = await context.read<MenuService>().fetchDishes(
        categoria: _category,
        buscar: _search.text,
      );
      if (!mounted) return;
      setState(() {
        _dishes = dishes;
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
            'No pudimos cargar la carta. Revisa tu conexión e inténtalo de nuevo.';
        _loading = false;
      });
    }
  }

  void _selectCategory(String value) {
    if (_category == value) return;
    setState(() => _category = value);
    _load();
  }

  void _clearFilters() {
    _search.clear();
    setState(() => _category = 'todos');
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final authenticated = context.watch<AuthController>().isAuthenticated;

    return AppShell(
      currentIndex: 1,
      child: authenticated
          ? _MenuBody(
              search: _search,
              category: _category,
              dishes: _dishes,
              loading: _loading,
              error: _error,
              onSearchChanged: _onSearchChanged,
              onCategorySelected: _selectCategory,
              onRetry: _load,
              onClearFilters: _clearFilters,
            )
          : PageFrame(
              child: SignInRequired(
                title: 'La carta te espera',
                message:
                    'Inicia sesión para descubrir los platos, precios y disponibilidad reales del restaurante.',
                nextRoute: AppRoutes.menu,
              ),
            ),
    );
  }
}

class _MenuBody extends StatelessWidget {
  const _MenuBody({
    required this.search,
    required this.category,
    required this.dishes,
    required this.loading,
    required this.error,
    required this.onSearchChanged,
    required this.onCategorySelected,
    required this.onRetry,
    required this.onClearFilters,
  });

  final TextEditingController search;
  final String category;
  final List<Dish> dishes;
  final bool loading;
  final String? error;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onCategorySelected;
  final VoidCallback onRetry;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    final showFullLoader = loading && dishes.isEmpty;
    final showError = error != null && dishes.isEmpty;

    return SingleChildScrollView(
      child: PageFrame(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageHeader(
              eyebrow: 'Gastronomía de autor',
              title: 'Menú del Restaurante',
              subtitle:
                  'Platos preparados con los mejores ingredientes de la ciudad.',
              trailing: TextButton.icon(
                onPressed: loading ? null : onRetry,
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
            _SearchField(
              controller: search,
              onChanged: onSearchChanged,
              onClear: () {
                search.clear();
                onSearchChanged('');
              },
            ),
            const SizedBox(height: 16),
            _CategoryGrid(category: category, onSelected: onCategorySelected),
            const SizedBox(height: 24),
            if (loading && !showFullLoader)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: LinearProgressIndicator(minHeight: 2),
              ),
            if (showFullLoader)
              const LoadingPanel(message: 'Consultando la carta…')
            else if (showError)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: ErrorPanel(message: error!, onRetry: onRetry),
              )
            else if (dishes.isEmpty)
              EmptyState(
                icon: Icons.search_off_rounded,
                title: 'Sin resultados',
                message:
                    'No encontramos platos con estos filtros. Prueba otra categoría o una búsqueda diferente.',
                actionLabel: 'Limpiar filtros',
                onAction: onClearFilters,
              )
            else ...[
              Row(
                children: [
                  Text(
                    '${dishes.length} ${dishes.length == 1 ? 'PLATO' : 'PLATOS'}',
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.6,
                      color: AppColors.textMuted,
                    ),
                  ),
                  if (search.text.trim().isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '· “${search.text.trim()}”',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 14),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = Breakpoints.gridColumns(context);
                  const spacing = 16.0;
                  final width =
                      (constraints.maxWidth - spacing * (columns - 1)) /
                      columns;
                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: [
                      for (final dish in dishes)
                        SizedBox(
                          width: width,
                          child: DishCard(
                            dish: dish,
                            onTap: () => showDishDetail(
                              context,
                              dish,
                              onReserve: () => Navigator.of(
                                context,
                              ).pushNamed(AppRoutes.reservation),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.category, required this.onSelected});

  final String category;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width < 520 ? 2 : (width < 900 ? 3 : 6);
        const gap = 10.0;
        final itemWidth = (width - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final item in dishCategories)
              SizedBox(
                width: itemWidth,
                child: CategoryPill(
                  label: item['label']!,
                  selected: item['value'] == category,
                  onTap: () => onSelected(item['value']!),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        return TextField(
          controller: controller,
          onChanged: onChanged,
          textInputAction: TextInputAction.search,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'Buscar un plato o un sabor…',
            prefixIcon: const Icon(Icons.search_rounded, size: 19),
            suffixIcon: value.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Borrar búsqueda',
                    onPressed: onClear,
                    icon: const Icon(Icons.close_rounded, size: 17),
                  ),
          ),
        );
      },
    );
  }
}
