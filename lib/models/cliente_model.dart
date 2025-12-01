import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de datos para la colección 'clientes' de Firestore.
/// Representa un cliente del gimnasio con su información personal y de contacto.
class Cliente {
  final String id;
  final String nombre;
  final String email;
  final String telefono;
  final DateTime fechaRegistro;
  final String? direccion;
  final String? notas;

  // Campos de sincronización
  final DateTime? ultimaModificacion;
  final int version;

  Cliente({
    required this.id,
    required this.nombre,
    required this.email,
    required this.telefono,
    required this.fechaRegistro,
    this.direccion,
    this.notas,
    this.ultimaModificacion,
    this.version = 1,
  });

  /// Constructor factory para crear una instancia de Cliente desde un documento de Firestore.
  ///
  /// [json] - Map con los datos del documento
  /// [docId] - ID del documento en Firestore
  factory Cliente.fromJson(Map<String, dynamic> json, String docId) {
    return Cliente(
      id: docId,
      nombre: json['nombre'] ?? '',
      email: json['email'] ?? '',
      telefono: json['telefono'] ?? '',
      fechaRegistro: json['fechaRegistro'] is Timestamp
          ? (json['fechaRegistro'] as Timestamp).toDate()
          : DateTime.now(),
      direccion: json['direccion'],
      notas: json['notas'],
      ultimaModificacion: json['ultimaModificacion'] is Timestamp
          ? (json['ultimaModificacion'] as Timestamp).toDate()
          : null,
      version: json['version'] ?? 1,
    );
  }

  /// Convierte la instancia de Cliente a un Map para guardar en Firestore.
  /// No incluye el ID porque Firestore lo maneja automáticamente.
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'email': email,
      'telefono': telefono,
      'fechaRegistro': Timestamp.fromDate(fechaRegistro),
      if (direccion != null) 'direccion': direccion,
      if (notas != null) 'notas': notas,
      if (ultimaModificacion != null)
        'ultimaModificacion': Timestamp.fromDate(ultimaModificacion!),
      'version': version,
    };
  }

  /// Crea una copia del cliente con los campos especificados modificados.
  /// Útil para actualizaciones inmutables.
  Cliente copyWith({
    String? id,
    String? nombre,
    String? email,
    String? telefono,
    DateTime? fechaRegistro,
    String? direccion,
    String? notas,
    DateTime? ultimaModificacion,
    int? version,
  }) {
    return Cliente(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      direccion: direccion ?? this.direccion,
      notas: notas ?? this.notas,
      ultimaModificacion: ultimaModificacion ?? this.ultimaModificacion,
      version: version ?? this.version,
    );
  }

  /// Validaciones de negocio
  bool get esEmailValido {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  bool get esTelefonoValido {
    final regex = RegExp(r'^\d{10}$');
    return regex.hasMatch(telefono);
  }

  bool get esNombreValido {
    return nombre.trim().length >= 3;
  }

  @override
  String toString() {
    return 'Cliente(id: $id, nombre: $nombre, email: $email, telefono: $telefono)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Cliente && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
