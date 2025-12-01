import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de datos para la colección 'membresias' de Firestore.
/// Representa una membresía activa de un cliente con fechas de inicio y fin.
class Membresia {
  final String id;
  final String clienteId;
  final String planId;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String estado; // 'activa', 'vencida', 'suspendida'
  final double montoTotal;
  final DateTime? fechaPago;
  final String? metodoPago;

  // Campos de sincronización
  final DateTime? ultimaModificacion;
  final int version;

  Membresia({
    required this.id,
    required this.clienteId,
    required this.planId,
    required this.fechaInicio,
    required this.fechaFin,
    required this.estado,
    required this.montoTotal,
    this.fechaPago,
    this.metodoPago,
    this.ultimaModificacion,
    this.version = 1,
  });

  /// Constructor factory para crear una instancia desde un documento de Firestore.
  factory Membresia.fromJson(Map<String, dynamic> json, String docId) {
    return Membresia(
      id: docId,
      clienteId: json['clienteId'] ?? '',
      planId: json['planId'] ?? '',
      fechaInicio: json['fechaInicio'] is Timestamp
          ? (json['fechaInicio'] as Timestamp).toDate()
          : DateTime.now(),
      fechaFin: json['fechaFin'] is Timestamp
          ? (json['fechaFin'] as Timestamp).toDate()
          : DateTime.now(),
      estado: json['estado'] ?? 'activa',
      montoTotal: (json['montoTotal'] ?? 0).toDouble(),
      fechaPago: json['fechaPago'] is Timestamp
          ? (json['fechaPago'] as Timestamp).toDate()
          : null,
      metodoPago: json['metodoPago'],
      ultimaModificacion: json['ultimaModificacion'] is Timestamp
          ? (json['ultimaModificacion'] as Timestamp).toDate()
          : null,
      version: json['version'] ?? 1,
    );
  }

  /// Convierte la instancia a un Map para guardar en Firestore.
  Map<String, dynamic> toJson() {
    return {
      'clienteId': clienteId,
      'planId': planId,
      'fechaInicio': Timestamp.fromDate(fechaInicio),
      'fechaFin': Timestamp.fromDate(fechaFin),
      'estado': estado,
      'montoTotal': montoTotal,
      if (fechaPago != null) 'fechaPago': Timestamp.fromDate(fechaPago!),
      if (metodoPago != null) 'metodoPago': metodoPago,
      if (ultimaModificacion != null)
        'ultimaModificacion': Timestamp.fromDate(ultimaModificacion!),
      'version': version,
    };
  }

  /// Crea una copia con los campos especificados modificados.
  Membresia copyWith({
    String? id,
    String? clienteId,
    String? planId,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    String? estado,
    double? montoTotal,
    DateTime? fechaPago,
    String? metodoPago,
    DateTime? ultimaModificacion,
    int? version,
  }) {
    return Membresia(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      planId: planId ?? this.planId,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      estado: estado ?? this.estado,
      montoTotal: montoTotal ?? this.montoTotal,
      fechaPago: fechaPago ?? this.fechaPago,
      metodoPago: metodoPago ?? this.metodoPago,
      ultimaModificacion: ultimaModificacion ?? this.ultimaModificacion,
      version: version ?? this.version,
    );
  }

  /// Lógica de negocio: verificar si la membresía está activa
  bool get estaActiva {
    final ahora = DateTime.now();
    return estado == 'activa' &&
        ahora.isAfter(fechaInicio) &&
        ahora.isBefore(fechaFin);
  }

  /// Lógica de negocio: verificar si la membresía está vencida
  bool get estaVencida {
    return DateTime.now().isAfter(fechaFin);
  }

  /// Días restantes de la membresía
  int get diasRestantes {
    final diferencia = fechaFin.difference(DateTime.now());
    return diferencia.inDays > 0 ? diferencia.inDays : 0;
  }

  /// Verificar si la membresía está por vencer (menos de 7 días)
  bool get estaPorVencer {
    return diasRestantes > 0 && diasRestantes <= 7;
  }

  @override
  String toString() {
    return 'Membresia(id: $id, clienteId: $clienteId, estado: $estado, diasRestantes: $diasRestantes)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Membresia && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
