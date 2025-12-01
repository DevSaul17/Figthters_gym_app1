# Estrategia de Sincronización Local-Remota

## 📋 Resumen de Implementación

Se ha implementado un sistema completo de sincronización local-remota para la aplicación Fighters Gym con las siguientes características:

### ✅ Componentes Implementados

#### 1. **SyncService** (`lib/services/sync_service.dart`)
Servicio centralizado que gestiona:
- ✅ Timestamps `ultimaModificacion` en todos los documentos
- ✅ Campo `version` para detectar conflictos
- ✅ Validación de conectividad antes de operaciones críticas
- ✅ Gestión de cola de operaciones pendientes
- ✅ Auto-sincronización al recuperar conexión

**Métodos principales:**
```dart
// Agregar campos de sincronización a datos
final datosSync = syncService.addSyncFields(datos);

// Validar conectividad antes de operación
final isOnline = await syncService.validateConnectivity(
  operationName: 'Operación X',
);

// Guardar con control de versión
final success = await syncService.saveWithVersionControl(
  collection: 'clientes',
  documentId: 'abc123',
  data: datosCliente,
  expectedVersion: 2,
);

// Ejecutar operación con validación
await syncService.executeWithConnectivityCheck(
  operationName: 'Registrar pago',
  operation: () => guardarPago(),
);
```

#### 2. **Modelos Actualizados**
Todos los modelos ahora incluyen campos de sincronización:
- ✅ `Cliente` - version + ultimaModificacion
- ✅ `Membresia` - version + ultimaModificacion  
- ✅ `Pago` - version + ultimaModificacion
- ✅ `Entrenamiento` - version + ultimaModificacion
- ✅ `Asistencia` - version + ultimaModificacion
- ✅ `Plan` - version + ultimaModificacion
- ✅ `Empleado` - version + ultimaModificacion

**Ejemplo de uso:**
```dart
final cliente = Cliente(
  id: 'abc123',
  nombre: 'Juan Pérez',
  email: 'juan@example.com',
  // ... otros campos
  ultimaModificacion: DateTime.now(), // Auto-gestionado por SyncService
  version: 3, // Incrementa automáticamente
);
```

#### 3. **UI de Operaciones Pendientes** (`lib/widgets/pending_operations_widget.dart`)

##### PendingOperationsBadge
Badge minimalista para AppBar:
```dart
// En AppBar
actions: const [
  Padding(
    padding: EdgeInsets.only(right: 16),
    child: PendingOperationsBadge(),
  ),
]
```

##### PendingOperationsWidget
Widget expandible con lista detallada (para uso futuro si se requiere panel completo).

#### 4. **Operaciones Críticas Envueltas**
Las siguientes pantallas ahora validan conectividad:
- ✅ **PagosScreen** - Procesar pagos de membresía
  - Muestra advertencia si está offline
  - Agrega operación a cola de pendientes
  - Firestore sincroniza automáticamente al reconectar
  
- ✅ **RegistroClienteScreen** - Registro de nuevos clientes
  - Validación previa de conectividad
  - Notificación visual de modo offline
  - Campos de sincronización agregados automáticamente
  
- ✅ **AsistenciaScreen** - Registro de asistencias
  - Operación continua offline
  - Sincronización transparente
  - Feedback visual al usuario

**Ejemplo de implementación:**
```dart
// En _procesarPago()
final syncService = SyncService();
final isOnline = await syncService.validateConnectivity(
  operationName: 'Procesar pago de membresía',
);

if (!isOnline && mounted) {
  _mostrarMensaje(
    '⚠️ Sin conexión. El pago se sincronizará automáticamente al reconectar.',
    Colors.orange,
  );
}

// Agregar campos de sincronización
final datosPagoSync = syncService.addSyncFields(datosPago);

// Guardar en Firestore (funcionará offline)
await FirebaseFirestore.instance.collection('pagos').add(datosPagoSync);
```

---

## 🔄 Flujo de Sincronización

### Escenario 1: Usuario Online
1. Usuario realiza operación (ej: registrar pago)
2. `SyncService.validateConnectivity()` → `true`
3. Datos se guardan con `ultimaModificacion` y `version`
4. Firestore sincroniza inmediatamente
5. ✅ Operación completada

### Escenario 2: Usuario Offline
1. Usuario realiza operación sin conexión
2. `SyncService.validateConnectivity()` → `false`
3. Se muestra advertencia: "⚠️ Sin conexión. Se sincronizará automáticamente"
4. Datos se guardan localmente en caché de Firestore
5. Firestore detecta reconexión automáticamente
6. ✅ Sincronización transparente

### Escenario 3: Conflicto de Versión
1. Usuario A edita documento (version: 2)
2. Usuario B edita mismo documento offline (version: 2)
3. Usuario B reconecta y intenta sincronizar
4. `saveWithVersionControl()` detecta: expected v2, actual v3
5. ❌ Retorna `false` - conflicto detectado
6. App puede mostrar UI de resolución de conflictos

---

## 📊 Estados de Operaciones Pendientes

```dart
enum PendingOperationStatus {
  waiting,   // Esperando conexión (usuario offline)
  pending,   // En cola de sincronización (Firestore procesando)
  synced,    // Sincronizada exitosamente
}
```

### Visualización en UI
- **Badge en AppBar**: Muestra contador de operaciones pendientes
- **Color naranja**: Indica operaciones en espera
- **Desaparece automáticamente**: Al completar sincronización

---

## 🛡️ Manejo de Conflictos

### Estrategia Actual: Last-Write-Wins
Por defecto, Firestore usa "el último que escribe gana". Esto significa:
- ✅ Simple de implementar
- ✅ Sin intervención del usuario
- ⚠️ Posible pérdida de datos en ediciones concurrentes

### Estrategia Mejorada: Control de Versión
Con `saveWithVersionControl()`:
```dart
final success = await syncService.saveWithVersionControl(
  collection: 'clientes',
  documentId: clienteId,
  data: datosCliente,
  expectedVersion: 2, // Versión que el usuario tenía al editar
);

if (!success) {
  // Mostrar UI: "Otro usuario editó este registro. ¿Sobrescribir o fusionar?"
}
```

---

## 📈 Métricas de Sincronización

### Información Disponible
```dart
// Obtener info de última sincronización
final syncInfo = await syncService.getDocumentSyncInfo('clientes', clienteId);

print('Última modificación: ${syncInfo.ultimaModificacionFormateada}');
// Output: "Hace 5 min"

print('Versión actual: ${syncInfo.version}');
// Output: 3
```

### Contador de Operaciones Pendientes
```dart
// Escuchar cambios en operaciones pendientes
syncService.pendingOperationsCount.addListener(() {
  final count = syncService.pendingOperationsCount.value;
  print('Operaciones pendientes: $count');
});
```

---

## 🎯 Mejoras Futuras (Opcional)

### 1. Resolución Manual de Conflictos
```dart
// Pantalla de conflictos
class ConflictResolutionScreen extends StatelessWidget {
  final Map<String, dynamic> localData;
  final Map<String, dynamic> remoteData;
  
  // UI para que usuario elija qué datos mantener
}
```

### 2. Sincronización Selectiva
```dart
// Solo sincronizar ciertos documentos
syncService.syncCollection('pagos', 
  where: (doc) => doc['estado'] == 'pendiente'
);
```

### 3. Timestamps de Última Sincronización Global
```dart
// Guardar en SharedPreferences
final lastSync = await syncService.getLastGlobalSync();
print('Última sincronización completa: $lastSync');
```

### 4. Priorización de Sincronización
```dart
// Sincronizar pagos antes que asistencias
syncService.setPriority('pagos', priority: SyncPriority.high);
syncService.setPriority('asistencias', priority: SyncPriority.low);
```

---

## 🧪 Testing de Sincronización

### Simular Modo Offline
1. Activar "Modo Avión" en dispositivo
2. Realizar operaciones (registro de pago, cliente, asistencia)
3. Verificar mensaje: "⚠️ Sin conexión..."
4. Desactivar "Modo Avión"
5. ✅ Verificar que datos se sincronizaron automáticamente

### Verificar Timestamps en Firestore
```javascript
// En Firestore Console
{
  "nombre": "Juan Pérez",
  "email": "juan@example.com",
  "ultimaModificacion": Timestamp(2024-12-01 15:30:00),
  "version": 3
}
```

---

## 📝 Notas Importantes

### Compatibilidad con Datos Existentes
- ✅ Documentos sin `version` se tratan como versión 1
- ✅ Documentos sin `ultimaModificacion` se marcan como "Sin sincronizar"
- ✅ Enfoque híbrido: modelos + Maps para compatibilidad

### Limitaciones Actuales
- ❌ No hay UI para resolución manual de conflictos
- ❌ No hay priorización de sincronización
- ❌ No hay sincronización incremental (envía documentos completos)
- ❌ No hay expiración de caché

### Ventajas de Firestore Offline
- ✅ Persistencia automática habilitada
- ✅ Cache ilimitado (`CACHE_SIZE_UNLIMITED`)
- ✅ Sincronización transparente
- ✅ Queries funcionan offline con datos cacheados
- ✅ Detección automática de reconexión

---

## 🚀 Uso en Producción

### Configuración Actual
```dart
// lib/main.dart
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

### Recomendaciones
1. **Monitorear tamaño de caché**: En dispositivos con poco almacenamiento
2. **Implementar resolución de conflictos**: Para documentos críticos (pagos)
3. **Agregar timestamps de última sync**: Para mostrar al usuario
4. **Testing exhaustivo**: Probar con mala conexión, intermitente, etc.

---

## 📚 Archivos Modificados/Creados

### Nuevos Archivos
- ✅ `lib/services/sync_service.dart` - Servicio de sincronización
- ✅ `lib/widgets/pending_operations_widget.dart` - UI de operaciones pendientes
- ✅ `SINCRONIZACION.md` - Esta documentación

### Archivos Modificados
- ✅ `lib/models/cliente_model.dart` - Agregados campos sync
- ✅ `lib/models/membresia_model.dart` - Agregados campos sync
- ✅ `lib/models/pago_model.dart` - Agregados campos sync
- ✅ `lib/models/entrenamiento_model.dart` - Agregados campos sync
- ✅ `lib/models/asistencia_model.dart` - Agregados campos sync
- ✅ `lib/models/plan_model.dart` - Agregados campos sync
- ✅ `lib/models/empleado_model.dart` - Agregados campos sync
- ✅ `lib/screens/empleado/pagos_screen.dart` - Validación de conectividad
- ✅ `lib/screens/empleado/registro_cliente_screen.dart` - Validación de conectividad
- ✅ `lib/screens/empleado/asistencia_screen.dart` - Validación de conectividad
- ✅ `lib/home_screen.dart` - Badge de operaciones pendientes
- ✅ `lib/main.dart` - Inicialización de SyncService

---

**Implementado por:** GitHub Copilot + Claude Sonnet 4.5  
**Fecha:** 1 de Diciembre, 2025  
**Versión:** 1.0.0
