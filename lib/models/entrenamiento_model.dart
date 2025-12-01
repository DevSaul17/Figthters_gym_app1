import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de datos para la colección 'entrenamientos' de Firestore.
/// Representa una rutina de entrenamiento personalizada de un cliente.
class Entrenamiento {
  final String id;
  final String clienteId;
  final String nombreRutina;
  final Map<String, List<String>> rutinasPorDia;
  final DateTime fechaCreacion;
  final DateTime? fechaActualizacion;
  final String? observaciones;

  Entrenamiento({
    required this.id,
    required this.clienteId,
    required this.nombreRutina,
    required this.rutinasPorDia,
    required this.fechaCreacion,
    this.fechaActualizacion,
    this.observaciones,
  });

  /// Constructor factory para crear una instancia desde un documento de Firestore.
  factory Entrenamiento.fromJson(Map<String, dynamic> json, String docId) {
    // Convertir el mapa de rutinas por día
    Map<String, List<String>> rutinas = {};
    final dias = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];

    for (String dia in dias) {
      if (json[dia] != null) {
        rutinas[dia] = List<String>.from(json[dia] as List);
      }
    }

    return Entrenamiento(
      id: docId,
      clienteId: json['clienteId'] ?? '',
      nombreRutina: json['nombreRutina'] ?? 'Rutina personalizada',
      rutinasPorDia: rutinas,
      fechaCreacion: json['fechaCreacion'] is Timestamp
          ? (json['fechaCreacion'] as Timestamp).toDate()
          : DateTime.now(),
      fechaActualizacion: json['fechaActualizacion'] is Timestamp
          ? (json['fechaActualizacion'] as Timestamp).toDate()
          : null,
      observaciones: json['observaciones'],
    );
  }

  /// Convierte la instancia a un Map para guardar en Firestore.
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'clienteId': clienteId,
      'nombreRutina': nombreRutina,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      if (fechaActualizacion != null)
        'fechaActualizacion': Timestamp.fromDate(fechaActualizacion!),
      if (observaciones != null) 'observaciones': observaciones,
    };

    // Agregar rutinas por día
    rutinasPorDia.forEach((dia, ejercicios) {
      json[dia] = ejercicios;
    });

    return json;
  }

  /// Crea una copia con los campos especificados modificados.
  Entrenamiento copyWith({
    String? id,
    String? clienteId,
    String? nombreRutina,
    Map<String, List<String>>? rutinasPorDia,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
    String? observaciones,
  }) {
    return Entrenamiento(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      nombreRutina: nombreRutina ?? this.nombreRutina,
      rutinasPorDia: rutinasPorDia ?? this.rutinasPorDia,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
      observaciones: observaciones ?? this.observaciones,
    );
  }

  /// Obtener ejercicios de un día específico
  List<String> ejerciciosPorDia(String dia) {
    return rutinasPorDia[dia] ?? [];
  }

  /// Verificar si hay ejercicios asignados para un día
  bool tienEjerciciosEnDia(String dia) {
    return rutinasPorDia[dia]?.isNotEmpty ?? false;
  }

  /// Contar total de ejercicios en la rutina
  int get totalEjercicios {
    int total = 0;
    rutinasPorDia.forEach((dia, ejercicios) {
      total += ejercicios.length;
    });
    return total;
  }

  /// Días con ejercicios asignados
  List<String> get diasConEjercicios {
    return rutinasPorDia.keys
        .where((dia) => rutinasPorDia[dia]!.isNotEmpty)
        .toList();
  }

  @override
  String toString() {
    return 'Entrenamiento(id: $id, clienteId: $clienteId, nombreRutina: $nombreRutina, totalEjercicios: $totalEjercicios)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Entrenamiento && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
