import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de datos para la colección 'asistencias' de Firestore.
/// Representa el registro de entrada de un cliente al gimnasio.
class Asistencia {
  final String id;
  final String clienteId;
  final DateTime fechaHoraEntrada;
  final DateTime? fechaHoraSalida;
  final String? notas;

  Asistencia({
    required this.id,
    required this.clienteId,
    required this.fechaHoraEntrada,
    this.fechaHoraSalida,
    this.notas,
  });

  /// Constructor factory para crear una instancia desde un documento de Firestore.
  factory Asistencia.fromJson(Map<String, dynamic> json, String docId) {
    return Asistencia(
      id: docId,
      clienteId: json['clienteId'] ?? '',
      fechaHoraEntrada: json['fechaHoraEntrada'] is Timestamp
          ? (json['fechaHoraEntrada'] as Timestamp).toDate()
          : DateTime.now(),
      fechaHoraSalida: json['fechaHoraSalida'] is Timestamp
          ? (json['fechaHoraSalida'] as Timestamp).toDate()
          : null,
      notas: json['notas'],
    );
  }

  /// Convierte la instancia a un Map para guardar en Firestore.
  Map<String, dynamic> toJson() {
    return {
      'clienteId': clienteId,
      'fechaHoraEntrada': Timestamp.fromDate(fechaHoraEntrada),
      if (fechaHoraSalida != null)
        'fechaHoraSalida': Timestamp.fromDate(fechaHoraSalida!),
      if (notas != null) 'notas': notas,
    };
  }

  /// Crea una copia con los campos especificados modificados.
  Asistencia copyWith({
    String? id,
    String? clienteId,
    DateTime? fechaHoraEntrada,
    DateTime? fechaHoraSalida,
    String? notas,
  }) {
    return Asistencia(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      fechaHoraEntrada: fechaHoraEntrada ?? this.fechaHoraEntrada,
      fechaHoraSalida: fechaHoraSalida ?? this.fechaHoraSalida,
      notas: notas ?? this.notas,
    );
  }

  /// Obtener solo la fecha (sin hora) de la entrada
  DateTime get soloFecha {
    return DateTime(
      fechaHoraEntrada.year,
      fechaHoraEntrada.month,
      fechaHoraEntrada.day,
    );
  }

  /// Obtener hora de entrada formateada (HH:MM)
  String get horaEntrada {
    final hora = fechaHoraEntrada.hour.toString().padLeft(2, '0');
    final minuto = fechaHoraEntrada.minute.toString().padLeft(2, '0');
    return '$hora:$minuto';
  }

  /// Obtener hora de salida formateada (HH:MM)
  String? get horaSalida {
    if (fechaHoraSalida == null) return null;
    final hora = fechaHoraSalida!.hour.toString().padLeft(2, '0');
    final minuto = fechaHoraSalida!.minute.toString().padLeft(2, '0');
    return '$hora:$minuto';
  }

  /// Calcular duración de la visita (si ya salió)
  Duration? get duracionVisita {
    if (fechaHoraSalida == null) return null;
    return fechaHoraSalida!.difference(fechaHoraEntrada);
  }

  /// Duración formateada en horas y minutos
  String? get duracionFormateada {
    final duracion = duracionVisita;
    if (duracion == null) return null;
    final horas = duracion.inHours;
    final minutos = duracion.inMinutes.remainder(60);
    return '${horas}h ${minutos}min';
  }

  /// Verificar si el cliente sigue en el gimnasio
  bool get enGimnasio {
    return fechaHoraSalida == null;
  }

  @override
  String toString() {
    return 'Asistencia(id: $id, clienteId: $clienteId, entrada: $horaEntrada, enGimnasio: $enGimnasio)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Asistencia && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
