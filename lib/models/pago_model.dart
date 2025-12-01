import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de datos para la colección 'pagos' de Firestore.
/// Representa un pago realizado por un cliente.
class Pago {
  final String id;
  final String clienteId;
  final String? membresiaId;
  final double monto;
  final DateTime fechaPago;
  final String metodoPago; // 'efectivo', 'tarjeta', 'transferencia'
  final String concepto;
  final String? referencia;
  final String? notas;

  Pago({
    required this.id,
    required this.clienteId,
    this.membresiaId,
    required this.monto,
    required this.fechaPago,
    required this.metodoPago,
    required this.concepto,
    this.referencia,
    this.notas,
  });

  /// Constructor factory para crear una instancia desde un documento de Firestore.
  factory Pago.fromJson(Map<String, dynamic> json, String docId) {
    return Pago(
      id: docId,
      clienteId: json['clienteId'] ?? '',
      membresiaId: json['membresiaId'],
      monto: (json['monto'] ?? 0).toDouble(),
      fechaPago: json['fechaPago'] is Timestamp
          ? (json['fechaPago'] as Timestamp).toDate()
          : DateTime.now(),
      metodoPago: json['metodoPago'] ?? 'efectivo',
      concepto: json['concepto'] ?? '',
      referencia: json['referencia'],
      notas: json['notas'],
    );
  }

  /// Convierte la instancia a un Map para guardar en Firestore.
  Map<String, dynamic> toJson() {
    return {
      'clienteId': clienteId,
      if (membresiaId != null) 'membresiaId': membresiaId,
      'monto': monto,
      'fechaPago': Timestamp.fromDate(fechaPago),
      'metodoPago': metodoPago,
      'concepto': concepto,
      if (referencia != null) 'referencia': referencia,
      if (notas != null) 'notas': notas,
    };
  }

  /// Crea una copia con los campos especificados modificados.
  Pago copyWith({
    String? id,
    String? clienteId,
    String? membresiaId,
    double? monto,
    DateTime? fechaPago,
    String? metodoPago,
    String? concepto,
    String? referencia,
    String? notas,
  }) {
    return Pago(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      membresiaId: membresiaId ?? this.membresiaId,
      monto: monto ?? this.monto,
      fechaPago: fechaPago ?? this.fechaPago,
      metodoPago: metodoPago ?? this.metodoPago,
      concepto: concepto ?? this.concepto,
      referencia: referencia ?? this.referencia,
      notas: notas ?? this.notas,
    );
  }

  /// Validación: monto debe ser mayor a 0
  bool get esMontoValido {
    return monto > 0;
  }

  /// Obtener el mes del pago
  String get mesAnio {
    final meses = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return '${meses[fechaPago.month - 1]} ${fechaPago.year}';
  }

  @override
  String toString() {
    return 'Pago(id: $id, clienteId: $clienteId, monto: \$$monto, metodoPago: $metodoPago)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Pago && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
