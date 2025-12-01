import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de datos para la colección 'entrenadores' de Firestore.
/// Representa un empleado del gimnasio (entrenador, recepcionista, administrador).
class Empleado {
  final String id;
  final String nombre;
  final String email;
  final String telefono;
  final String rol; // 'entrenador', 'recepcionista', 'administrador'
  final DateTime fechaContratacion;
  final bool activo;
  final String? especialidad;
  final List<String>? horariosDisponibles;
  final String? notas;

  Empleado({
    required this.id,
    required this.nombre,
    required this.email,
    required this.telefono,
    required this.rol,
    required this.fechaContratacion,
    this.activo = true,
    this.especialidad,
    this.horariosDisponibles,
    this.notas,
  });

  /// Constructor factory para crear una instancia desde un documento de Firestore.
  factory Empleado.fromJson(Map<String, dynamic> json, String docId) {
    return Empleado(
      id: docId,
      nombre: json['nombre'] ?? '',
      email: json['email'] ?? '',
      telefono: json['telefono'] ?? '',
      rol: json['rol'] ?? 'entrenador',
      fechaContratacion: json['fechaContratacion'] is Timestamp
          ? (json['fechaContratacion'] as Timestamp).toDate()
          : DateTime.now(),
      activo: json['activo'] ?? true,
      especialidad: json['especialidad'],
      horariosDisponibles: json['horariosDisponibles'] != null
          ? List<String>.from(json['horariosDisponibles'] as List)
          : null,
      notas: json['notas'],
    );
  }

  /// Convierte la instancia a un Map para guardar en Firestore.
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'email': email,
      'telefono': telefono,
      'rol': rol,
      'fechaContratacion': Timestamp.fromDate(fechaContratacion),
      'activo': activo,
      if (especialidad != null) 'especialidad': especialidad,
      if (horariosDisponibles != null)
        'horariosDisponibles': horariosDisponibles,
      if (notas != null) 'notas': notas,
    };
  }

  /// Crea una copia con los campos especificados modificados.
  Empleado copyWith({
    String? id,
    String? nombre,
    String? email,
    String? telefono,
    String? rol,
    DateTime? fechaContratacion,
    bool? activo,
    String? especialidad,
    List<String>? horariosDisponibles,
    String? notas,
  }) {
    return Empleado(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      rol: rol ?? this.rol,
      fechaContratacion: fechaContratacion ?? this.fechaContratacion,
      activo: activo ?? this.activo,
      especialidad: especialidad ?? this.especialidad,
      horariosDisponibles: horariosDisponibles ?? this.horariosDisponibles,
      notas: notas ?? this.notas,
    );
  }

  /// Calcular años de antigüedad
  int get aniosAntiguedad {
    final diferencia = DateTime.now().difference(fechaContratacion);
    return (diferencia.inDays / 365).floor();
  }

  /// Verificar si es administrador
  bool get esAdministrador {
    return rol.toLowerCase() == 'administrador';
  }

  /// Verificar si es entrenador
  bool get esEntrenador {
    return rol.toLowerCase() == 'entrenador';
  }

  /// Verificar si es recepcionista
  bool get esRecepcionista {
    return rol.toLowerCase() == 'recepcionista';
  }

  /// Obtener rol formateado
  String get rolFormateado {
    return rol[0].toUpperCase() + rol.substring(1).toLowerCase();
  }

  @override
  String toString() {
    return 'Empleado(id: $id, nombre: $nombre, rol: $rol, activo: $activo)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Empleado && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
