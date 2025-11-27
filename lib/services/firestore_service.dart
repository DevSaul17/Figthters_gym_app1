import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_security_service.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Generic helpers
  CollectionReference collectionRef(String path) => _db.collection(path);

  Future<DocumentReference> addDocument(
    String collectionPath,
    Map<String, dynamic> data,
  ) {
    return collectionRef(collectionPath).add(data);
  }

  Future<void> setDocument(
    String collectionPath,
    String docId,
    Map<String, dynamic> data, {
    bool merge = false,
  }) {
    return collectionRef(
      collectionPath,
    ).doc(docId).set(data, SetOptions(merge: merge));
  }

  Future<void> updateDocument(
    String collectionPath,
    String docId,
    Map<String, dynamic> data,
  ) {
    return collectionRef(collectionPath).doc(docId).update(data);
  }

  Future<void> deleteDocument(String collectionPath, String docId) {
    return collectionRef(collectionPath).doc(docId).delete();
  }

  Future<DocumentSnapshot> getDocument(String collectionPath, String docId) {
    return collectionRef(collectionPath).doc(docId).get();
  }

  Stream<QuerySnapshot> streamCollection(
    String collectionPath, {
    Query Function(Query q)? queryBuilder,
  }) {
    Query q = collectionRef(collectionPath);
    if (queryBuilder != null) q = queryBuilder(q);
    return q.snapshots();
  }

  Future<QuerySnapshot> getCollection(
    String collectionPath, {
    Query Function(Query q)? queryBuilder,
  }) {
    Query q = collectionRef(collectionPath);
    if (queryBuilder != null) q = queryBuilder(q);
    return q.get();
  }

  // Example domain helpers
  Future<DocumentReference> addCliente(Map<String, dynamic> clienteData) =>
      addDocument('clientes', clienteData);
  Future<DocumentReference> addPago(Map<String, dynamic> pagoData) =>
      addDocument('pagos', pagoData);
  Future<DocumentReference> addPlan(Map<String, dynamic> planData) =>
      addDocument('planes', planData);

  Stream<QuerySnapshot> streamPlanes() => streamCollection('planes');
  Stream<QuerySnapshot> streamClientes() => streamCollection('clientes');

  // Registrar actividad de seguridad
  Future<void> _registrarActividadSeguridad({
    required String evento,
    required String dni,
    required bool exitoso,
    String? detalles,
  }) async {
    try {
      await addDocument('logs_seguridad', {
        'evento': evento,
        'dni': dni,
        'exitoso': exitoso,
        'timestamp': FieldValue.serverTimestamp(),
        'detalles': detalles,
        'ip': 'mobile_app',
      });
    } catch (e) {
      // Error silencioso para no afectar el flujo principal
    }
  }

  // Autenticación de empleados con seguridad mejorada
  Future<Map<String, dynamic>?> autenticarEmpleado(
    String dni,
    String contrasena,
  ) async {
    try {
      // Validaciones de entrada
      if (dni.trim().isEmpty || contrasena.isEmpty) {
        await _registrarActividadSeguridad(
          evento: 'intento_login',
          dni: dni,
          exitoso: false,
          detalles: 'Datos vacíos',
        );
        return null;
      }

      // Normalizar DNI
      final dniLimpio = dni.trim();

      // Validar formato de DNI
      if (!AuthSecurityService.validarDNI(dniLimpio)) {
        await _registrarActividadSeguridad(
          evento: 'intento_login',
          dni: dniLimpio,
          exitoso: false,
          detalles: 'DNI con formato inválido',
        );
        return null;
      }

      // Verificar rate limiting
      final puedeIntentar = await AuthSecurityService.verificarRateLimit(
        dniLimpio,
      );
      if (!puedeIntentar) {
        await _registrarActividadSeguridad(
          evento: 'bloqueo_rate_limit',
          dni: dniLimpio,
          exitoso: false,
          detalles: 'Demasiados intentos fallidos',
        );
        throw Exception('RATE_LIMIT_EXCEEDED');
      }

      // Timeout para la consulta
      final querySnapshot = await getCollection(
        'entrenadores',
        queryBuilder: (q) => q.where('dni', isEqualTo: dniLimpio),
      ).timeout(AuthSecurityService.timeoutAutenticacion);

      if (querySnapshot.docs.isEmpty) {
        await AuthSecurityService.registrarIntentoFallido(dniLimpio);
        await _registrarActividadSeguridad(
          evento: 'intento_login',
          dni: dniLimpio,
          exitoso: false,
          detalles: 'Usuario no encontrado',
        );
        return null;
      }

      final empleadoDoc = querySnapshot.docs.first;
      final empleadoData = empleadoDoc.data() as Map<String, dynamic>;

      // Verificar si la cuenta está activa
      if (empleadoData['activo'] != null && !empleadoData['activo']) {
        await _registrarActividadSeguridad(
          evento: 'intento_login',
          dni: dniLimpio,
          exitoso: false,
          detalles: 'Cuenta desactivada',
        );
        throw Exception('ACCOUNT_DISABLED');
      }

      // Verificar contraseña hasheada
      final salt = AuthSecurityService.generateSalt(dniLimpio);
      final passwordHash = AuthSecurityService.hashPassword(contrasena, salt);

      // Si no existe hash, usar contraseña plana (migración gradual)
      final contrasenaBD =
          empleadoData['password_hash'] ?? empleadoData['contrasena'];
      bool passwordValida = false;

      if (empleadoData['password_hash'] != null) {
        // Verificar con hash
        passwordValida = contrasenaBD == passwordHash;
      } else {
        // Verificar contraseña plana y actualizar a hash
        passwordValida = contrasenaBD == contrasena;
        if (passwordValida) {
          // Migrar a contraseña hasheada
          await updateDocument('entrenadores', empleadoDoc.id, {
            'password_hash': passwordHash,
            'password_updated_at': FieldValue.serverTimestamp(),
          });
        }
      }

      if (passwordValida) {
        // Autenticación exitosa
        await AuthSecurityService.limpiarIntentos(dniLimpio);
        await _registrarActividadSeguridad(
          evento: 'login_exitoso',
          dni: dniLimpio,
          exitoso: true,
          detalles: 'Login correcto',
        );

        // Actualizar último login
        await updateDocument('entrenadores', empleadoDoc.id, {
          'ultimo_login': FieldValue.serverTimestamp(),
        });

        return {
          'id': empleadoDoc.id,
          'dni': empleadoData['dni'],
          'nombre': empleadoData['nombre'],
          'apellido': empleadoData['apellido'],
          'telefono': empleadoData['telefono'],
          'email': empleadoData['email'],
          'rol': empleadoData['rol'] ?? 'empleado',
        };
      } else {
        // Contraseña incorrecta
        await AuthSecurityService.registrarIntentoFallido(dniLimpio);
        await _registrarActividadSeguridad(
          evento: 'intento_login',
          dni: dniLimpio,
          exitoso: false,
          detalles: 'Contraseña incorrecta',
        );
        return null;
      }
    } catch (e) {
      if (e.toString().contains('RATE_LIMIT_EXCEEDED')) {
        rethrow;
      }
      if (e.toString().contains('ACCOUNT_DISABLED')) {
        rethrow;
      }

      await _registrarActividadSeguridad(
        evento: 'error_login',
        dni: dni,
        exitoso: false,
        detalles: 'Error técnico: ${e.toString()}',
      );
      return null;
    }
  }
}
