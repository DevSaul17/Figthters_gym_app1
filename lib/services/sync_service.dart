import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'connectivity_service.dart';

/// Modelo de operación pendiente
class PendingOperation {
  final String id;
  final String name;
  final DateTime timestamp;
  final PendingOperationStatus status;

  PendingOperation({
    required this.id,
    required this.name,
    required this.timestamp,
    required this.status,
  });

  String get timeAgo {
    final difference = DateTime.now().difference(timestamp);
    if (difference.inSeconds < 60) return 'Hace ${difference.inSeconds}s';
    if (difference.inMinutes < 60) return 'Hace ${difference.inMinutes}m';
    if (difference.inHours < 24) return 'Hace ${difference.inHours}h';
    return 'Hace ${difference.inDays}d';
  }
}

enum PendingOperationStatus {
  waiting, // Esperando conexión
  pending, // En cola de sincronización
  synced, // Sincronizada
}

/// Información de sincronización de un documento
class SyncInfo {
  final DateTime? ultimaModificacion;
  final int version;
  final String documentId;
  final String collection;

  SyncInfo({
    this.ultimaModificacion,
    required this.version,
    required this.documentId,
    required this.collection,
  });

  String get ultimaModificacionFormateada {
    if (ultimaModificacion == null) return 'Sin sincronizar';

    final difference = DateTime.now().difference(ultimaModificacion!);
    if (difference.inMinutes < 1) return 'Hace un momento';
    if (difference.inMinutes < 60) return 'Hace ${difference.inMinutes} min';
    if (difference.inHours < 24) return 'Hace ${difference.inHours} horas';
    return 'Hace ${difference.inDays} días';
  }
}

/// Servicio centralizado para gestión de sincronización local-remota
///
/// Funcionalidades:
/// - Timestamps de última modificación
/// - Versionado de documentos para detectar conflictos
/// - Validación de conectividad antes de operaciones críticas
/// - Gestión de cola de operaciones pendientes
class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final ConnectivityService _connectivityService = ConnectivityService();
  // ignore: unused_field
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Notificador de operaciones pendientes (para UI reactiva)
  final ValueNotifier<int> pendingOperationsCount = ValueNotifier<int>(0);
  final ValueNotifier<List<PendingOperation>> pendingOperations =
      ValueNotifier<List<PendingOperation>>([]);

  /// Verifica si hay conexión a internet
  Future<bool> isOnline() async {
    return await _connectivityService.isConnected();
  }

  /// Agrega campos de sincronización a un Map de datos
  ///
  /// Agrega:
  /// - ultimaModificacion: Timestamp actual
  /// - version: Incrementa la versión o inicia en 1
  Map<String, dynamic> addSyncFields(
    Map<String, dynamic> data, {
    int? currentVersion,
  }) {
    final now = FieldValue.serverTimestamp();
    final newVersion = (currentVersion ?? 0) + 1;

    return {...data, 'ultimaModificacion': now, 'version': newVersion};
  }

  /// Valida conectividad antes de operación crítica
  ///
  /// Retorna:
  /// - true: Hay conexión, proceder con operación
  /// - false: Sin conexión, operación quedará pendiente
  Future<bool> validateConnectivity({String? operationName}) async {
    final online = await isOnline();

    if (!online && operationName != null) {
      debugPrint(
        '⚠️ SyncService: Operación "$operationName" sin conexión - se ejecutará en modo offline',
      );
    }

    return online;
  }

  /// Agrega operación a la cola de pendientes
  ///
  /// Útil para operaciones que requieren conexión y están en espera
  void addPendingOperation(PendingOperation operation) {
    final currentList = List<PendingOperation>.from(pendingOperations.value);
    currentList.add(operation);
    pendingOperations.value = currentList;
    pendingOperationsCount.value = currentList.length;

    debugPrint(
      '📋 SyncService: Operación pendiente agregada - Total: ${currentList.length}',
    );
  }

  /// Remueve operación de la cola de pendientes
  void removePendingOperation(String operationId) {
    final currentList = List<PendingOperation>.from(pendingOperations.value);
    currentList.removeWhere((op) => op.id == operationId);
    pendingOperations.value = currentList;
    pendingOperationsCount.value = currentList.length;

    debugPrint(
      '✅ SyncService: Operación completada - Pendientes: ${currentList.length}',
    );
  }

  /// Limpia todas las operaciones pendientes
  void clearPendingOperations() {
    pendingOperations.value = [];
    pendingOperationsCount.value = 0;
    debugPrint('🧹 SyncService: Cola de operaciones limpiada');
  }

  /// Guarda documento con validación de versión para detectar conflictos
  ///
  /// Retorna:
  /// - true: Guardado exitoso
  /// - false: Conflicto de versión detectado
  Future<bool> saveWithVersionControl({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
    int? expectedVersion,
  }) async {
    try {
      final docRef = _firestore.collection(collection).doc(documentId);

      // Obtener versión actual del documento
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists && expectedVersion != null) {
        final currentVersion = docSnapshot.data()?['version'] as int?;

        // Detectar conflicto de versión
        if (currentVersion != null && currentVersion != expectedVersion) {
          debugPrint(
            '⚠️ CONFLICTO DE VERSIÓN detectado en $collection/$documentId',
          );
          debugPrint(
            '   Versión esperada: $expectedVersion, Versión actual: $currentVersion',
          );
          return false;
        }
      }

      // Agregar campos de sincronización
      final dataWithSync = addSyncFields(data, currentVersion: expectedVersion);

      // Guardar con la nueva versión
      await docRef.set(dataWithSync, SetOptions(merge: true));

      debugPrint(
        '✅ Documento guardado con versión ${dataWithSync['version']} en $collection/$documentId',
      );
      return true;
    } catch (e) {
      debugPrint('❌ Error al guardar con control de versión: $e');
      return false;
    }
  }

  /// Ejecuta operación crítica con validación previa de conectividad
  ///
  /// Si hay conexión: ejecuta inmediatamente
  /// Si no hay conexión: agrega a cola de pendientes (Firestore maneja offline automáticamente)
  Future<T?> executeWithConnectivityCheck<T>({
    required String operationName,
    required Future<T> Function() operation,
    bool requiresOnline = false,
  }) async {
    final online = await validateConnectivity(operationName: operationName);

    if (requiresOnline && !online) {
      // Operación crítica que requiere conexión
      debugPrint(
        '🚫 Operación "$operationName" cancelada - requiere conexión online',
      );
      addPendingOperation(
        PendingOperation(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: operationName,
          timestamp: DateTime.now(),
          status: PendingOperationStatus.waiting,
        ),
      );
      return null;
    }

    // Ejecutar operación (Firestore maneja offline automáticamente)
    try {
      final result = await operation();

      if (!online) {
        // Marcar como pendiente de sincronización
        addPendingOperation(
          PendingOperation(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: operationName,
            timestamp: DateTime.now(),
            status: PendingOperationStatus.pending,
          ),
        );
      }

      return result;
    } catch (e) {
      debugPrint('❌ Error en operación "$operationName": $e');
      return null;
    }
  }

  /// Obtiene información de última sincronización de un documento
  Future<SyncInfo?> getDocumentSyncInfo(
    String collection,
    String documentId,
  ) async {
    try {
      final doc = await _firestore.collection(collection).doc(documentId).get();

      if (!doc.exists) return null;

      final data = doc.data();
      final ultimaModificacion = data?['ultimaModificacion'] as Timestamp?;
      final version = data?['version'] as int?;

      return SyncInfo(
        ultimaModificacion: ultimaModificacion?.toDate(),
        version: version ?? 0,
        documentId: documentId,
        collection: collection,
      );
    } catch (e) {
      debugPrint('Error al obtener info de sincronización: $e');
      return null;
    }
  }
}
