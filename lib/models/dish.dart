import 'json_utils.dart';

class Dish {
  const Dish({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.categoria,
    required this.categoriaDisplay,
    required this.disponible,
    required this.destacado,
    required this.imagen,
    required this.stock,
  });

  final int id;
  final String nombre;
  final String descripcion;
  final double precio;
  final String categoria;
  final String categoriaDisplay;
  final bool disponible;
  final bool destacado;
  final String? imagen;
  final int stock;

  bool get hasStock => stock > 0;

  bool get isLowStock => stock > 0 && stock <= 3;

  factory Dish.fromJson(Map<String, dynamic> json) {
    return Dish(
      id: asInt(json['id']),
      nombre: asString(json['nombre'], fallback: 'Plato sin nombre'),
      descripcion: asString(json['descripcion']),
      precio: asDouble(json['precio']),
      categoria: asString(json['categoria'], fallback: 'otros'),
      categoriaDisplay: asString(json['categoria_display'], fallback: 'Otros'),
      disponible: asBool(json['disponible']),
      destacado: asBool(json['destacado']),
      imagen: asNullableString(json['imagen']),
      stock: asInt(json['stock']),
    );
  }
}

/// Categorías reales del modelo `Plato` en el backend.
const List<Map<String, String>> dishCategories = [
  {'value': 'todos', 'label': 'Todas'},
  {'value': 'entradas', 'label': 'Entradas'},
  {'value': 'platos_fuertes', 'label': 'Platos fuertes'},
  {'value': 'bebidas', 'label': 'Bebidas'},
  {'value': 'postres', 'label': 'Postres'},
  {'value': 'otros', 'label': 'Otros'},
];
