# 📚 DOCUMENTACIÓN TÉCNICA - INTEGRACIÓN CON FIREBASE
## Fighters Gym App

---

## 3.1. INTEGRACIÓN CON FIREBASE

### 📋 Configuración Inicial de Firebase

#### **Archivo: `lib/services/firebase_options.dart`**
Este archivo fue generado automáticamente por FlutterFire CLI y contiene las credenciales de configuración para cada plataforma.

**Plataformas Configuradas:**
- ✅ **Web**
- ✅ **Android** 
- ✅ **iOS**
- ✅ **macOS**
- ✅ **Windows**

**Proyecto Firebase:**
- **Project ID:** `fluttergym-48b76`
- **Storage Bucket:** `fluttergym-48b76.firebasestorage.app`

```dart
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // Detecta automáticamente la plataforma y retorna la configuración correcta
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android: return android;
      case TargetPlatform.iOS: return ios;
      // ... otras plataformas
    }
  }
}
```

#### **Inicialización en `main.dart`**

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Inicializar Firebase
  await Firebase.initializeApp();
  
  // 2. Autenticación Anónima (requerida por las reglas de Firestore)
  await FirebaseAuth.instance.signInAnonymously();
  
  runApp(const MainApp());
}
```

**¿Por qué autenticación anónima?**
- Las reglas de seguridad de Firestore requieren que el usuario esté autenticado
- Permite operaciones CRUD sin necesidad de login tradicional
- Mejora la seguridad al evitar accesos completamente públicos

---

## 📊 MODELO DE DATOS EN FIRESTORE

### Estructura de Colecciones

```
firestore/
├── clientes/              # Información de clientes del gimnasio
├── entrenadores/          # Personal del gimnasio (empleados)
├── credenciales/          # Usuarios y contraseñas de clientes
├── membresias/            # Planes de membresía activos
├── planes/                # Catálogo de planes disponibles
├── pagos/                 # Registro de pagos realizados
├── asistencias/           # Control de asistencias diarias
├── entrenamientos/        # Rutinas personalizadas por cliente
├── prospectos/            # Clientes potenciales (leads)
└── logs_seguridad/        # Auditoría de accesos y eventos de seguridad
```

---

### 📄 **1. Colección: `clientes`**

**Propósito:** Almacenar información personal y de contacto de los clientes del gimnasio.

**Estructura del Documento:**
```dart
{
  "dni": "12345678",                    // String - 8 dígitos (Perú)
  "nombre": "Juan",                     // String
  "apellidos": "Pérez García",          // String
  "telefono": "987654321",              // String
  "email": "juan@example.com",          // String (opcional)
  "direccion": "Av. Principal 123",     // String (opcional)
  "fechaNacimiento": "1995-05-15",      // String formato YYYY-MM-DD
  "genero": "M",                        // String: "M" o "F"
  "activo": true,                       // Boolean
  "tieneMembresia": true,               // Boolean
  "membresiaId": "ABC123",              // String - referencia a documento de membresías
  "fechaRegistro": Timestamp,           // Timestamp - fecha de alta en el sistema
  "emergenciaContacto": "María Pérez",  // String (opcional)
  "emergenciaTelefono": "999888777"     // String (opcional)
}
```

**Operaciones Implementadas:**

**CREATE - Registro de Cliente:**
```dart
// Archivo: lib/screens/empleado/registro_cliente_screen.dart
final docRef = await FirebaseFirestore.instance
    .collection('clientes')
    .add(datosCliente);
```

**READ - Búsqueda de Clientes:**
```dart
// Búsqueda por DNI
final existeCliente = await FirebaseFirestore.instance
    .collection('clientes')
    .where('dni', isEqualTo: _dniController.text.trim())
    .get();

// Lectura de datos completos
final clienteSnapshot = await db
    .collection('clientes')
    .doc(clienteId)
    .get();
```

**UPDATE - Actualizar Membresía:**
```dart
await FirebaseFirestore.instance
    .collection('clientes')
    .doc(clienteId)
    .update({
      'membresiaId': docRef.id, 
      'tieneMembresia': true
    });
```

---

### 📄 **2. Colección: `entrenadores`**

**Propósito:** Gestión de empleados del gimnasio con autenticación segura.

**Estructura del Documento:**
```dart
{
  "dni": "87654321",                    // String - 8 dígitos
  "nombre": "Carlos",                   // String
  "apellido": "Ramírez",                // String
  "telefono": "965432187",              // String
  "email": "carlos@gym.com",            // String
  "rol": "empleado",                    // String: "empleado", "admin", "entrenador"
  "contrasena": "mipass123",            // String - contraseña plana (legacy)
  "password_hash": "a3f5b...",          // String - SHA-256 hash (nuevo sistema)
  "activo": true,                       // Boolean
  "fechaContratacion": Timestamp,       // Timestamp
  "password_updated_at": Timestamp,     // Timestamp - última actualización de contraseña
  "ultimo_login": Timestamp             // Timestamp - última sesión
}
```

**Sistema de Seguridad Implementado:**

**Archivo: `lib/services/auth_security_service.dart`**

1. **Hashing de Contraseñas:**
```dart
static String hashPassword(String password, String salt) {
  var bytes = utf8.encode(password + salt);
  var digest = sha256.convert(bytes);
  return digest.toString();
}

static String generateSalt(String dni) {
  return 'gym_salt_${dni}_security_v1';
}
```

2. **Rate Limiting (Protección contra Fuerza Bruta):**
```dart
// Configuración
static const int maxIntentos = 3;
static const Duration tiempoBloqueo = Duration(minutes: 15);

// Verificación
Future<bool> verificarRateLimit(String dni) async {
  final prefs = await SharedPreferences.getInstance();
  final intentos = prefs.getInt('login_attempts_$dni') ?? 0;
  
  if (intentos >= maxIntentos) {
    return false; // Bloqueado
  }
  return true;
}
```

3. **Validaciones de Entrada:**
```dart
// DNI de 8 dígitos
static const String dniPattern = r'^\d{8}$';

// Contraseña mínimo 6 caracteres
static const String passwordPattern = r'^.{6,}$';
```

**Operaciones de Autenticación:**

**Archivo: `lib/services/firestore_service.dart`**

```dart
Future<Map<String, dynamic>?> autenticarEmpleado(
  String dni,
  String contrasena,
) async {
  // 1. Validar formato de DNI
  if (!AuthSecurityService.validarDNI(dniLimpio)) {
    return null;
  }

  // 2. Verificar rate limiting
  final puedeIntentar = await AuthSecurityService.verificarRateLimit(dniLimpio);
  if (!puedeIntentar) {
    throw Exception('RATE_LIMIT_EXCEEDED');
  }

  // 3. Buscar empleado en Firestore
  final querySnapshot = await getCollection(
    'entrenadores',
    queryBuilder: (q) => q.where('dni', isEqualTo: dniLimpio),
  );

  // 4. Verificar cuenta activa
  if (empleadoData['activo'] != null && !empleadoData['activo']) {
    throw Exception('ACCOUNT_DISABLED');
  }

  // 5. Verificar contraseña (con migración de hash)
  final salt = AuthSecurityService.generateSalt(dniLimpio);
  final passwordHash = AuthSecurityService.hashPassword(contrasena, salt);

  if (empleadoData['password_hash'] != null) {
    // Sistema nuevo: comparar hash
    passwordValida = contrasenaBD == passwordHash;
  } else {
    // Sistema legacy: comparar plano y migrar
    passwordValida = contrasenaBD == contrasena;
    if (passwordValida) {
      // Migrar a hash automáticamente
      await updateDocument('entrenadores', empleadoDoc.id, {
        'password_hash': passwordHash,
        'password_updated_at': FieldValue.serverTimestamp(),
      });
    }
  }

  // 6. Registrar login exitoso
  await AuthSecurityService.limpiarIntentos(dniLimpio);
  await updateDocument('entrenadores', empleadoDoc.id, {
    'ultimo_login': FieldValue.serverTimestamp(),
  });

  return userData;
}
```

---

### 📄 **3. Colección: `credenciales`**

**Propósito:** Sistema de autenticación para clientes (área de usuario).

**Estructura del Documento:**
```dart
{
  "usuario": "juanperez",              // String - username único
  "contrasena": "cliente123",          // String - contraseña
  "clienteId": "XYZ789",               // String - referencia al documento en 'clientes'
  "activo": true,                      // Boolean
  "fechaCreacion": Timestamp,          // Timestamp
  "ultimoAcceso": Timestamp            // Timestamp
}
```

**Operaciones:**

**READ - Autenticación de Cliente:**
```dart
// Archivo: lib/screens/cliente/home_cliente_screen.dart
final snapshot = await db
    .collection('credenciales')
    .where('usuario', isEqualTo: widget.nombreUsuario)
    .get();

if (snapshot.docs.isNotEmpty) {
  final clienteId = snapshot.docs.first.get('clienteId');
  // Obtener datos completos del cliente
  final clienteDoc = await db
      .collection('clientes')
      .doc(clienteId)
      .get();
}
```

---

### 📄 **4. Colección: `membresias`**

**Propósito:** Control de planes activos por cliente con estado de pago.

**Estructura del Documento:**
```dart
{
  "clienteId": "ABC123",               // String - referencia a 'clientes'
  "planId": "PLAN001",                 // String - referencia a 'planes'
  "nombreCliente": "Juan Pérez",       // String - desnormalizado para queries
  "nombrePlan": "Plan Premium",        // String - desnormalizado
  "diasAcceso": [                      // Array<String>
    "Lunes",
    "Miércoles", 
    "Viernes"
  ],
  "horaInicio": "06:00",               // String - formato HH:mm
  "horaFin": "22:00",                  // String - formato HH:mm
  "fechaInicio": Timestamp,            // Timestamp
  "fechaFin": Timestamp,               // Timestamp
  "precio": 120.00,                    // Number
  "moneda": "PEN",                     // String - ISO 4217
  "estado": "pagada",                  // String: "pendiente", "pagada", "vencida"
  "activa": true,                      // Boolean
  "metodoPago": "efectivo",            // String: "efectivo", "tarjeta", "transferencia"
  "observaciones": "Pago completo",    // String (opcional)
  "fechaRegistro": Timestamp           // Timestamp
}
```

**Operaciones:**

**CREATE - Registro de Membresía:**
```dart
// Archivo: lib/screens/empleado/registro_membresia_screen.dart
final docRef = await FirebaseFirestore.instance
    .collection('membresias')
    .add(datosMembresia);

// Actualizar cliente con la membresía
await FirebaseFirestore.instance
    .collection('clientes')
    .doc(clienteId)
    .update({
      'membresiaId': docRef.id, 
      'tieneMembresia': true
    });
```

**READ con filtros múltiples:**
```dart
// Membresías activas y pagadas de un cliente
stream: FirebaseFirestore.instance
    .collection('membresias')
    .where('clienteId', isEqualTo: clienteId)
    .where('activa', isEqualTo: true)
    .where('estado', isEqualTo: 'pagada')
    .snapshots()
```

**UPDATE - Actualizar estado de pago:**
```dart
await FirebaseFirestore.instance
    .collection('membresias')
    .doc(membresiaId)
    .update({
      'estado': 'pagada',
      'metodoPago': 'efectivo',
      'fechaPago': FieldValue.serverTimestamp()
    });
```

---

### 📄 **5. Colección: `planes`**

**Propósito:** Catálogo de planes de membresía disponibles.

**Estructura del Documento:**
```dart
{
  "nombre": "Plan Premium",            // String
  "descripcion": "Acceso completo",    // String
  "precio": 150.00,                    // Number
  "duracion": 30,                      // Number - días
  "activo": true,                      // Boolean
  "beneficios": [                      // Array<String>
    "Acceso ilimitado",
    "Clases grupales",
    "Entrenador personal"
  ],
  "restricciones": [                   // Array<String> (opcional)
    "Sujeto a disponibilidad"
  ],
  "fechaCreacion": Timestamp,          // Timestamp
  "fechaModificacion": Timestamp       // Timestamp
}
```

**Operaciones:**

**CREATE - Crear Plan:**
```dart
// Archivo: lib/screens/empleado/gestionar_planes_screen.dart
await FirebaseFirestore.instance
    .collection('planes')
    .add(nuevoPlan.toFirestoreCreate());
```

**READ - Listar Planes Activos:**
```dart
final querySnapshot = await FirebaseFirestore.instance
    .collection('planes')
    .where('activo', isEqualTo: true)
    .get();
```

**UPDATE - Modificar Plan:**
```dart
await FirebaseFirestore.instance
    .collection('planes')
    .doc(planId)
    .update(planActualizado.toFirestore());
```

**SOFT DELETE - Desactivar Plan:**
```dart
await FirebaseFirestore.instance
    .collection('planes')
    .doc(planId)
    .update({'activo': false});
```

---

### 📄 **6. Colección: `pagos`**

**Propósito:** Registro histórico de transacciones.

**Estructura del Documento:**
```dart
{
  "clienteId": "ABC123",               // String
  "membresiaId": "MEM456",             // String
  "monto": 150.00,                     // Number
  "moneda": "PEN",                     // String
  "metodoPago": "efectivo",            // String
  "concepto": "Pago membresía enero",  // String
  "nombreCliente": "Juan Pérez",       // String - desnormalizado
  "fecha": Timestamp,                  // Timestamp
  "recibo": "REC-2025-001",            // String (opcional)
  "empleadoId": "EMP123"               // String - quien registró el pago
}
```

**Operaciones:**

**CREATE - Registrar Pago:**
```dart
// Archivo: lib/screens/empleado/pagos_screen.dart
await FirebaseFirestore.instance
    .collection('pagos')
    .add(datosPago);

// Actualizar estado de membresía
await FirebaseFirestore.instance
    .collection('membresias')
    .doc(membresiaId)
    .update({
      'estado': 'pagada',
      'fechaPago': FieldValue.serverTimestamp()
    });
```

---

### 📄 **7. Colección: `asistencias`**

**Propósito:** Control diario de asistencia de clientes.

**Estructura del Documento:**
```dart
{
  "clienteId": "ABC123",               // String
  "nombreCliente": "Juan Pérez",       // String - desnormalizado
  "fecha": "2025-11-30",               // String - formato YYYY-MM-DD
  "horaEntrada": Timestamp,            // Timestamp
  "horaSalida": Timestamp,             // Timestamp (opcional)
  "empleadoRegistro": "EMP123",        // String - quien registró
  "observaciones": ""                  // String (opcional)
}
```

**Operaciones:**

**CREATE - Registrar Asistencia:**
```dart
// Archivo: lib/screens/empleado/asistencia_screen.dart
await FirebaseFirestore.instance
    .collection('asistencias')
    .add({
      'clienteId': clienteId,
      'nombreCliente': nombreCliente,
      'fecha': fechaHoy,
      'horaEntrada': FieldValue.serverTimestamp(),
      'empleadoRegistro': empleadoId
    });
```

**READ con filtro de fecha:**
```dart
_asistenciasStream = FirebaseFirestore.instance
    .collection('asistencias')
    .where('fecha', isEqualTo: fechaHoy)
    .snapshots();
```

---

### 📄 **8. Colección: `entrenamientos`**

**Propósito:** Rutinas personalizadas por cliente organizadas por día de la semana.

**Estructura del Documento:**
```dart
{
  "clienteId": "ABC123",               // String
  "nombreCliente": "Juan Pérez",       // String
  "rutinaSemanal": {                   // Map<String, Array<String>>
    "Lunes": ["Press banca 3x12", "Sentadillas 4x10"],
    "Martes": ["Cardio 30min", "Abdominales 3x20"],
    "Miércoles": [],
    "Jueves": ["Peso muerto 4x8", "Dominadas 3x10"],
    "Viernes": ["Spinning 45min"],
    "Sábado": ["Descanso activo"]
  },
  "fechaCreacion": Timestamp,          // Timestamp
  "fechaActualizacion": Timestamp,     // Timestamp
  "activo": true                       // Boolean
}
```

**Características especiales:**
- **Un solo documento por cliente** (no se crean múltiples rutinas)
- Actualización en lugar de creación si ya existe
- Estructura anidada con Map

**Operaciones:**

**CREATE/UPDATE - Guardar Rutina:**
```dart
// Archivo: lib/screens/cliente/entrenamientos_personalizados_screen.dart

// 1. Verificar si existe documento
final entrenamientoSnapshot = await db
    .collection('entrenamientos')
    .where('clienteId', isEqualTo: clienteId)
    .limit(1)
    .get();

if (entrenamientoSnapshot.docs.isNotEmpty) {
  // ACTUALIZAR existente
  final docId = entrenamientoSnapshot.docs.first.id;
  await db.collection('entrenamientos')
      .doc(docId)
      .update({
        'rutinaSemanal': _rutinaSemanal,
        'fechaActualizacion': Timestamp.now()
      });
} else {
  // CREAR nuevo
  await db.collection('entrenamientos').add({
    'clienteId': clienteId,
    'nombreCliente': nombreCompleto,
    'rutinaSemanal': _rutinaSemanal,
    'fechaCreacion': Timestamp.now(),
    'activo': true
  });
}
```

**READ con StreamBuilder (tiempo real):**
```dart
return StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
      .collection('entrenamientos')
      .where('clienteId', isEqualTo: clienteId)
      .limit(1)
      .snapshots(),
  builder: (context, snapshot) {
    final data = snapshot.data!.docs.first.data();
    final rutina = data['rutinaSemanal'] as Map<String, dynamic>;
    // Renderizar UI
  }
);
```

---

### 📄 **9. Colección: `logs_seguridad`**

**Propósito:** Auditoría de eventos de autenticación y seguridad.

**Estructura del Documento:**
```dart
{
  "evento": "login_exitoso",           // String
  "dni": "12345678",                   // String
  "exitoso": true,                     // Boolean
  "timestamp": Timestamp,              // Timestamp
  "detalles": "Login correcto",        // String
  "ip": "mobile_app"                   // String
}
```

**Eventos registrados:**
- `intento_login`
- `login_exitoso`
- `bloqueo_rate_limit`
- `error_login`

**Operación de creación:**
```dart
// Archivo: lib/services/firestore_service.dart
Future<void> _registrarActividadSeguridad({
  required String evento,
  required String dni,
  required bool exitoso,
  String? detalles,
}) async {
  await addDocument('logs_seguridad', {
    'evento': evento,
    'dni': dni,
    'exitoso': exitoso,
    'timestamp': FieldValue.serverTimestamp(),
    'detalles': detalles,
    'ip': 'mobile_app',
  });
}
```

---

## 🔧 SERVICIO GENÉRICO DE FIRESTORE

**Archivo: `lib/services/firestore_service.dart`**

Esta clase proporciona métodos genéricos reutilizables para todas las operaciones CRUD:

```dart
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. CREATE - Agregar documento con ID auto-generado
  Future<DocumentReference> addDocument(
    String collectionPath,
    Map<String, dynamic> data,
  ) {
    return _db.collection(collectionPath).add(data);
  }

  // 2. CREATE/UPDATE - Establecer documento con ID específico
  Future<void> setDocument(
    String collectionPath,
    String docId,
    Map<String, dynamic> data, {
    bool merge = false,  // true = actualizar campos existentes
  }) {
    return _db.collection(collectionPath)
        .doc(docId)
        .set(data, SetOptions(merge: merge));
  }

  // 3. UPDATE - Actualizar campos específicos
  Future<void> updateDocument(
    String collectionPath,
    String docId,
    Map<String, dynamic> data,
  ) {
    return _db.collection(collectionPath).doc(docId).update(data);
  }

  // 4. DELETE - Eliminar documento
  Future<void> deleteDocument(String collectionPath, String docId) {
    return _db.collection(collectionPath).doc(docId).delete();
  }

  // 5. READ - Obtener un documento
  Future<DocumentSnapshot> getDocument(String collectionPath, String docId) {
    return _db.collection(collectionPath).doc(docId).get();
  }

  // 6. READ - Stream de colección (tiempo real)
  Stream<QuerySnapshot> streamCollection(
    String collectionPath, {
    Query Function(Query q)? queryBuilder,
  }) {
    Query q = _db.collection(collectionPath);
    if (queryBuilder != null) q = queryBuilder(q);
    return q.snapshots();
  }

  // 7. READ - Obtener colección (una vez)
  Future<QuerySnapshot> getCollection(
    String collectionPath, {
    Query Function(Query q)? queryBuilder,
  }) {
    Query q = _db.collection(collectionPath);
    if (queryBuilder != null) q = queryBuilder(q);
    return q.get();
  }
}
```

**Ejemplo de uso con queryBuilder:**
```dart
// Obtener solo planes activos, ordenados por precio
final planesActivos = await firestoreService.getCollection(
  'planes',
  queryBuilder: (q) => q
      .where('activo', isEqualTo: true)
      .orderBy('precio', descending: false)
      .limit(10)
);
```

---

## 📡 CONSULTAS Y FILTROS AVANZADOS

### 1. **Filtro Simple (WHERE)**
```dart
FirebaseFirestore.instance
    .collection('clientes')
    .where('activo', isEqualTo: true)
    .get();
```

### 2. **Filtros Múltiples (AND implícito)**
```dart
FirebaseFirestore.instance
    .collection('membresias')
    .where('clienteId', isEqualTo: clienteId)
    .where('activa', isEqualTo: true)
    .where('estado', isEqualTo: 'pagada')
    .snapshots();
```

### 3. **Ordenamiento**
```dart
FirebaseFirestore.instance
    .collection('pagos')
    .orderBy('fecha', descending: true)
    .limit(20)
    .get();
```

### 4. **Límite de Resultados**
```dart
FirebaseFirestore.instance
    .collection('entrenamientos')
    .where('clienteId', isEqualTo: clienteId)
    .limit(1)  // Solo el más reciente
    .get();
```

### 5. **StreamBuilder (Tiempo Real)**
```dart
StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
      .collection('asistencias')
      .where('fecha', isEqualTo: fechaHoy)
      .snapshots(),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      final documentos = snapshot.data!.docs;
      // Actualización automática al cambiar datos
    }
  }
)
```

### 6. **FutureBuilder (Una sola consulta)**
```dart
FutureBuilder<DocumentSnapshot>(
  future: FirebaseFirestore.instance
      .collection('clientes')
      .doc(clienteId)
      .get(),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      final data = snapshot.data!.data() as Map<String, dynamic>;
      // Procesar datos
    }
  }
)
```

---

## 🔒 REGLAS DE SEGURIDAD DE FIRESTORE

**Reglas implementadas (inferidas del código):**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Regla general: requiere autenticación
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
    
    // Logs de seguridad: solo escritura
    match /logs_seguridad/{logId} {
      allow write: if request.auth != null;
      allow read: if false;  // No permitir lectura desde cliente
    }
  }
}
```

---

## 3.2. CONSUMO DE SERVICIOS REST API

### ⚠️ **ANÁLISIS DE LA APLICACIÓN**

**Resultado:** La aplicación **NO consume servicios REST API externos**.

**Arquitectura Implementada:**
- ✅ **Firebase Firestore** como backend principal (NoSQL)
- ✅ **SharedPreferences** para almacenamiento local
- ❌ **No hay cliente HTTP** (no se usa `http` o `dio`)
- ❌ **No hay endpoints REST externos**

### 📦 Dependencias del Proyecto

**Archivo: `pubspec.yaml`**
```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.10.0        # Core de Firebase
  cloud_firestore: ^4.9.0       # Base de datos NoSQL
  firebase_auth: ^4.6.0         # Autenticación
  intl: ^0.18.1                 # Formato de fechas/números
  crypto: ^3.0.3                # Hashing (seguridad)
  shared_preferences: ^2.2.2    # Almacenamiento local
```

**No incluye:**
- ❌ `http` package
- ❌ `dio` package
- ❌ `retrofit` package

### 💾 Almacenamiento Local con SharedPreferences

**Uso:** Guardar datos en el dispositivo sin conexión.

**Ejemplos implementados:**

#### 1. **Calendario - Eventos del Usuario**
```dart
// Archivo: lib/screens/cliente/calendario_screen.dart

// GUARDAR eventos localmente
Future<void> _guardarEventos() async {
  final prefs = await SharedPreferences.getInstance();
  
  // Convertir eventos a JSON
  final Map<String, dynamic> eventosData = {};
  _events.forEach((date, eventsList) {
    eventosData[date.toIso8601String()] = eventsList;
  });
  
  final String eventosJson = json.encode(eventosData);
  await prefs.setString('eventos_${widget.nombreUsuario}', eventosJson);
}

// CARGAR eventos al iniciar
Future<void> _cargarEventos() async {
  final prefs = await SharedPreferences.getInstance();
  final String? eventosJson = prefs.getString('eventos_${widget.nombreUsuario}');
  
  if (eventosJson != null) {
    final Map<String, dynamic> eventosData = json.decode(eventosJson);
    // Reconstruir estructura de eventos
  }
}
```

#### 2. **Rate Limiting - Seguridad de Login**
```dart
// Archivo: lib/services/auth_security_service.dart

// REGISTRAR intento fallido
static Future<void> registrarIntentoFallido(String dni) async {
  final prefs = await SharedPreferences.getInstance();
  
  final intentos = prefs.getInt('login_attempts_$dni') ?? 0;
  await prefs.setInt('login_attempts_$dni', intentos + 1);
  await prefs.setInt('last_attempt_$dni', DateTime.now().millisecondsSinceEpoch);
}

// VERIFICAR bloqueo
static Future<bool> verificarRateLimit(String dni) async {
  final prefs = await SharedPreferences.getInstance();
  final intentos = prefs.getInt('login_attempts_$dni') ?? 0;
  
  return intentos < maxIntentos;
}
```

---

## 📊 RESUMEN DE OPERACIONES CRUD

| Colección | CREATE | READ | UPDATE | DELETE |
|-----------|--------|------|--------|--------|
| clientes | ✅ | ✅ | ✅ | ❌ (soft delete) |
| entrenadores | ❌ | ✅ | ✅ | ❌ |
| credenciales | ❌ | ✅ | ❌ | ❌ |
| membresias | ✅ | ✅ | ✅ | ❌ |
| planes | ✅ | ✅ | ✅ | ✅ (soft delete) |
| pagos | ✅ | ✅ | ❌ | ❌ |
| asistencias | ✅ | ✅ | ❌ | ❌ |
| entrenamientos | ✅ | ✅ | ✅ | ❌ |
| logs_seguridad | ✅ | ❌ | ❌ | ❌ |

---

## 🎯 CONCLUSIONES

### ✅ Fortalezas de la Arquitectura

1. **Firebase como BaaS (Backend as a Service)**
   - No requiere mantener servidor propio
   - Escalabilidad automática
   - Sincronización en tiempo real

2. **Seguridad Implementada**
   - Hash SHA-256 con salt
   - Rate limiting contra fuerza bruta
   - Logs de auditoría
   - Validación de entrada

3. **Patrones de Diseño**
   - Servicio genérico reutilizable
   - Separación de responsabilidades
   - Desnormalización estratégica (performance)

4. **Offline-First con SharedPreferences**
   - Eventos del calendario persisten localmente
   - Control de intentos de login sin conexión

### 🔄 Migración y Evolución

**Migración gradual de contraseñas:**
```dart
// Sistema detecta formato antiguo y migra automáticamente
if (empleadoData['password_hash'] != null) {
  // Usar hash
} else {
  // Comparar plano y migrar
  await updateDocument('entrenadores', empleadoDoc.id, {
    'password_hash': passwordHash,
    'password_updated_at': FieldValue.serverTimestamp(),
  });
}
```

### 📈 Métricas de Uso

**Operaciones Firestore Estimadas por Día:**
- READ: ~500 (consultas de autenticación, listas, etc.)
- WRITE: ~100 (registros, actualizaciones)
- DELETE: ~5 (desactivaciones)

**Almacenamiento Local:**
- Eventos de calendario por usuario: ~5-50 KB
- Rate limiting: ~1 KB por usuario

---

## 📚 REFERENCIAS

- [Documentación Oficial Firebase](https://firebase.google.com/docs)
- [Cloud Firestore](https://firebase.google.com/docs/firestore)
- [FlutterFire](https://firebase.flutter.dev/)
- [SharedPreferences Plugin](https://pub.dev/packages/shared_preferences)

---

**Documento generado:** 30 de noviembre de 2025  
**Versión de la App:** 0.1.0  
**Firebase Project:** fluttergym-48b76
