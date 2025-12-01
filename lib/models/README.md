# Modelos de Datos - Fighters Gym App

Esta carpeta contiene los modelos de datos que representan las colecciones de Firestore.

## 📁 Estructura

```
models/
├── asistencia_model.dart      # Registro de entradas al gimnasio
├── cliente_model.dart          # Datos de clientes
├── empleado_model.dart         # Datos de empleados/entrenadores
├── entrenamiento_model.dart    # Rutinas personalizadas
├── membresia_model.dart        # Membresías activas
├── pago_model.dart            # Pagos realizados
├── plan_model.dart            # Planes disponibles
└── models.dart                # Barrel file (exporta todos)
```

## 🎯 Uso Básico

### Importar todos los modelos

```dart
import 'package:fighters_gym_app/models/models.dart';
```

### Crear instancia desde Firestore

```dart
// Leer un cliente desde Firestore
final doc = await FirebaseFirestore.instance
    .collection('clientes')
    .doc(clienteId)
    .get();

final cliente = Cliente.fromJson(doc.data()!, doc.id);
print(cliente.nombre);  // Tipado seguro
```

### Guardar en Firestore

```dart
// Crear nuevo cliente
final nuevoCliente = Cliente(
  id: '',  // Se asignará automáticamente
  nombre: 'Juan Pérez',
  email: 'juan@example.com',
  telefono: '1234567890',
  fechaRegistro: DateTime.now(),
);

await FirebaseFirestore.instance
    .collection('clientes')
    .add(nuevoCliente.toJson());
```

### Actualizar documento existente

```dart
// Usar copyWith para crear copia modificada
final clienteActualizado = cliente.copyWith(
  telefono: '0987654321',
  direccion: 'Nueva dirección',
);

await FirebaseFirestore.instance
    .collection('clientes')
    .doc(cliente.id)
    .update(clienteActualizado.toJson());
```

## 📝 Modelos Disponibles

### Cliente
- **Colección**: `clientes`
- **Campos**: nombre, email, telefono, fechaRegistro, direccion, notas
- **Validaciones**: esEmailValido, esTelefonoValido, esNombreValido

### Membresia
- **Colección**: `membresias`
- **Campos**: clienteId, planId, fechaInicio, fechaFin, estado, montoTotal
- **Lógica**: estaActiva, estaVencida, diasRestantes, estaPorVencer

### Pago
- **Colección**: `pagos`
- **Campos**: clienteId, membresiaId, monto, fechaPago, metodoPago, concepto
- **Utilidades**: esMontoValido, mesAnio

### Entrenamiento
- **Colección**: `entrenamientos`
- **Campos**: clienteId, nombreRutina, rutinasPorDia, fechaCreacion
- **Utilidades**: ejerciciosPorDia(), totalEjercicios, diasConEjercicios

### Asistencia
- **Colección**: `asistencias`
- **Campos**: clienteId, fechaHoraEntrada, fechaHoraSalida, notas
- **Utilidades**: horaEntrada, horaSalida, duracionVisita, enGimnasio

### Plan
- **Colección**: `planes`
- **Campos**: nombre, descripcion, duracionDias, precio, beneficios, activo
- **Utilidades**: duracionMeses, precioPorDia, precioFormateado, esValido

### Empleado
- **Colección**: `entrenadores`
- **Campos**: nombre, email, telefono, rol, fechaContratacion, activo
- **Utilidades**: aniosAntiguedad, esAdministrador, esEntrenador, esRecepcionista

## ✨ Características

### 1. Conversión Automática de Timestamps
Todos los modelos convierten automáticamente entre `DateTime` de Dart y `Timestamp` de Firestore:

```dart
// Firestore → Dart
fechaRegistro: json['fechaRegistro'] is Timestamp
    ? (json['fechaRegistro'] as Timestamp).toDate()
    : DateTime.now(),

// Dart → Firestore
'fechaRegistro': Timestamp.fromDate(fechaRegistro),
```

### 2. Campos Opcionales con Null Safety
Los campos opcionales usan el operador `if` para no guardar valores null:

```dart
Map<String, dynamic> toJson() {
  return {
    'nombre': nombre,
    if (direccion != null) 'direccion': direccion,
    if (notas != null) 'notas': notas,
  };
}
```

### 3. Método copyWith para Inmutabilidad
Todos los modelos incluyen `copyWith` para actualizaciones inmutables:

```dart
final clienteActualizado = cliente.copyWith(telefono: '1111111111');
// cliente original no se modifica
```

### 4. Validaciones de Negocio
Propiedades computadas para validar datos:

```dart
if (!cliente.esEmailValido) {
  print('Email inválido');
}

if (membresia.estaPorVencer) {
  print('Membresía vence en ${membresia.diasRestantes} días');
}
```

### 5. Equality y HashCode
Implementación de `==` y `hashCode` para comparaciones:

```dart
if (cliente1 == cliente2) {
  print('Mismo cliente');
}

Set<Cliente> clientesUnicos = {cliente1, cliente2}; // Set usa hashCode
```

## 🔧 Ejemplo Completo: CRUD con Modelos

```dart
import 'package:fighters_gym_app/models/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClienteRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'clientes';

  // CREATE
  Future<String> crear(Cliente cliente) async {
    final docRef = await _firestore.collection(_collection).add(cliente.toJson());
    return docRef.id;
  }

  // READ (uno)
  Future<Cliente?> obtenerPorId(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists) return null;
    return Cliente.fromJson(doc.data()!, doc.id);
  }

  // READ (todos)
  Future<List<Cliente>> obtenerTodos() async {
    final snapshot = await _firestore.collection(_collection).get();
    return snapshot.docs.map((doc) => Cliente.fromJson(doc.data(), doc.id)).toList();
  }

  // UPDATE
  Future<void> actualizar(Cliente cliente) async {
    await _firestore.collection(_collection).doc(cliente.id).update(cliente.toJson());
  }

  // DELETE
  Future<void> eliminar(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  // STREAM (tiempo real)
  Stream<List<Cliente>> streamTodos() {
    return _firestore.collection(_collection).snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => Cliente.fromJson(doc.data(), doc.id)).toList(),
    );
  }
}
```

## 🚀 Ventajas sobre Map Directo

| Antes (Map<String, dynamic>) | Después (Modelos) |
|------------------------------|-------------------|
| `data['nombre']` | `cliente.nombre` |
| Sin autocompletado | ✅ Autocompletado IDE |
| Errores en runtime | ✅ Errores en compilación |
| Sin validación | ✅ Validaciones integradas |
| Código duplicado | ✅ Reutilizable |
| Difícil refactorizar | ✅ Refactor seguro |

## 📚 Buenas Prácticas

1. **Siempre usar modelos** en lugar de Maps para datos de Firestore
2. **Validar datos** antes de guardar usando los getters de validación
3. **Usar copyWith** para actualizaciones inmutables
4. **Manejar nulls** con el operador `??` en fromJson
5. **Documentar campos** con comentarios `///` para mejor IDE support
6. **Crear repositorios** que encapsulen la lógica de acceso a datos

## 🔄 Sincronización con Firestore

Los modelos están diseñados para sincronizar perfectamente con Firestore:

```dart
// StreamBuilder con modelos
StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance.collection('clientes').snapshots(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) return CircularProgressIndicator();
    
    final clientes = snapshot.data!.docs
        .map((doc) => Cliente.fromJson(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
    
    return ListView.builder(
      itemCount: clientes.length,
      itemBuilder: (context, index) {
        final cliente = clientes[index];
        return ListTile(
          title: Text(cliente.nombre),
          subtitle: Text(cliente.email),
          trailing: cliente.esEmailValido 
              ? Icon(Icons.check, color: Colors.green)
              : Icon(Icons.error, color: Colors.red),
        );
      },
    );
  },
)
```

---

**Última actualización**: Noviembre 2025
**Versión**: 1.0.0
