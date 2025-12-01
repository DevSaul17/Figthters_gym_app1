import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de datos para la colección 'planes' de Firestore.
/// Representa un plan de membresía disponible en el gimnasio.
class Plan {
  final String id;
  final String nombre;
  final String descripcion;
  final int duracionDias;
  final double precio;
  final List<String> beneficios;
  final bool activo;
  final DateTime? fechaCreacion;

  // Campos de sincronización
  final DateTime? ultimaModificacion;
  final int version;

  Plan({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.duracionDias,
    required this.precio,
    required this.beneficios,
    this.activo = true,
    this.fechaCreacion,
    this.ultimaModificacion,
    this.version = 1,
  });

  /// Constructor factory para crear una instancia desde un documento de Firestore.
  factory Plan.fromJson(Map<String, dynamic> json, String docId) {
    return Plan(
      id: docId,
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      duracionDias: json['duracionDias'] ?? 30,
      precio: (json['precio'] ?? 0).toDouble(),
      beneficios: json['beneficios'] != null
          ? List<String>.from(json['beneficios'] as List)
          : [],
      activo: json['activo'] ?? true,
      fechaCreacion: json['fechaCreacion'] is Timestamp
          ? (json['fechaCreacion'] as Timestamp).toDate()
          : null,
      ultimaModificacion: json['ultimaModificacion'] is Timestamp
          ? (json['ultimaModificacion'] as Timestamp).toDate()
          : null,
      version: json['version'] ?? 1,
    );
  }

  /// Convierte la instancia a un Map para guardar en Firestore.
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'duracionDias': duracionDias,
      'precio': precio,
      'beneficios': beneficios,
      'activo': activo,
      if (fechaCreacion != null)
        'fechaCreacion': Timestamp.fromDate(fechaCreacion!),
      if (ultimaModificacion != null)
        'ultimaModificacion': Timestamp.fromDate(ultimaModificacion!),
      'version': version,
    };
  }

  /// Crea una copia con los campos especificados modificados.
  Plan copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    int? duracionDias,
    double? precio,
    List<String>? beneficios,
    bool? activo,
    DateTime? fechaCreacion,
  }) {
    return Plan(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      duracionDias: duracionDias ?? this.duracionDias,
      precio: precio ?? this.precio,
      beneficios: beneficios ?? this.beneficios,
      activo: activo ?? this.activo,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }

  /// Obtener duración en meses (aproximado)
  int get duracionMeses {
    return (duracionDias / 30).ceil();
  }

  /// Obtener precio por día
  double get precioPorDia {
    return duracionDias > 0 ? precio / duracionDias : 0;
  }

  /// Formatear precio como moneda
  String get precioFormateado {
    return '\$${precio.toStringAsFixed(2)}';
  }

  /// Validar que el plan tenga datos válidos
  bool get esValido {
    return nombre.isNotEmpty && duracionDias > 0 && precio > 0;
  }

  @override
  String toString() {
    return 'Plan(id: $id, nombre: $nombre, duracionDias: $duracionDias, precio: \$$precio)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Plan && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
