// EJEMPLO: Migración de código existente para usar modelos
// Este archivo muestra cómo convertir código que usa Map directo a usar modelos

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fighters_gym_app/models/models.dart';

// ============================================================================
// EJEMPLO 1: Leer y mostrar lista de clientes
// ============================================================================

// ❌ ANTES (usando Map directo)
Future<void> cargarClientesAntiguo() async {
  final snapshot = await FirebaseFirestore.instance
      .collection('clientes')
      .get();

  for (var doc in snapshot.docs) {
    final data = doc.data();
    print('Cliente: ${data['nombre']}'); // Sin tipado, propenso a errores
    print('Email: ${data['email']}');
    // Si cometes error en el nombre del campo, solo lo sabes en runtime
  }
}

// ✅ DESPUÉS (usando modelos)
Future<void> cargarClientesNuevo() async {
  final snapshot = await FirebaseFirestore.instance
      .collection('clientes')
      .get();

  final clientes = snapshot.docs
      .map((doc) => Cliente.fromJson(doc.data(), doc.id))
      .toList();

  for (var cliente in clientes) {
    print('Cliente: ${cliente.nombre}'); // Tipado seguro, autocompletado
    print('Email: ${cliente.email}');

    // Validaciones integradas
    if (!cliente.esEmailValido) {
      print('⚠️ Email inválido');
    }
  }
}

// ============================================================================
// EJEMPLO 2: Crear nuevo cliente
// ============================================================================

// ❌ ANTES
Future<void> crearClienteAntiguo(
  String nombre,
  String email,
  String telefono,
) async {
  await FirebaseFirestore.instance.collection('clientes').add({
    'nombre': nombre,
    'email': email,
    'telefono': telefono,
    'fechaRegistro': Timestamp.fromDate(DateTime.now()),
    // Fácil olvidar campos o escribir mal el nombre
  });
}

// ✅ DESPUÉS
Future<String> crearClienteNuevo(
  String nombre,
  String email,
  String telefono,
) async {
  final cliente = Cliente(
    id: '', // Se asignará automáticamente
    nombre: nombre,
    email: email,
    telefono: telefono,
    fechaRegistro: DateTime.now(),
  );

  // Validar antes de guardar
  if (!cliente.esNombreValido) {
    throw Exception('Nombre debe tener al menos 3 caracteres');
  }
  if (!cliente.esEmailValido) {
    throw Exception('Email inválido');
  }
  if (!cliente.esTelefonoValido) {
    throw Exception('Teléfono debe tener 10 dígitos');
  }

  final docRef = await FirebaseFirestore.instance
      .collection('clientes')
      .add(cliente.toJson());

  return docRef.id;
}

// ============================================================================
// EJEMPLO 3: Actualizar cliente
// ============================================================================

// ❌ ANTES
Future<void> actualizarClienteAntiguo(String id, String nuevoTelefono) async {
  await FirebaseFirestore.instance.collection('clientes').doc(id).update({
    'telefono': nuevoTelefono,
    // Otros campos pueden sobrescribirse accidentalmente
  });
}

// ✅ DESPUÉS
Future<void> actualizarClienteNuevo(String id, String nuevoTelefono) async {
  // Primero obtener el cliente actual
  final doc = await FirebaseFirestore.instance
      .collection('clientes')
      .doc(id)
      .get();
  final cliente = Cliente.fromJson(doc.data()!, doc.id);

  // Crear copia modificada (inmutable)
  final clienteActualizado = cliente.copyWith(telefono: nuevoTelefono);

  // Validar antes de actualizar
  if (!clienteActualizado.esTelefonoValido) {
    throw Exception('Teléfono inválido');
  }

  await FirebaseFirestore.instance
      .collection('clientes')
      .doc(id)
      .update(clienteActualizado.toJson());
}

// ============================================================================
// EJEMPLO 4: StreamBuilder con modelos
// ============================================================================

// ❌ ANTES
/*
StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance.collection('clientes').snapshots(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) return CircularProgressIndicator();
    
    return ListView.builder(
      itemCount: snapshot.data!.docs.length,
      itemBuilder: (context, index) {
        final doc = snapshot.data!.docs[index];
        final data = doc.data() as Map<String, dynamic>;
        
        return ListTile(
          title: Text(data['nombre'] ?? ''), // Null checks manuales
          subtitle: Text(data['email'] ?? ''),
        );
      },
    );
  },
)
*/

// ✅ DESPUÉS
/*
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
          title: Text(cliente.nombre), // Sin ?? necesario, tipado seguro
          subtitle: Text(cliente.email),
          trailing: cliente.esEmailValido 
              ? Icon(Icons.check_circle, color: Colors.green)
              : Icon(Icons.error, color: Colors.red),
          onTap: () {
            // Pasar objeto completo en lugar de Map
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetalleClienteScreen(cliente: cliente),
              ),
            );
          },
        );
      },
    );
  },
)
*/

// ============================================================================
// EJEMPLO 5: Verificar membresías vencidas
// ============================================================================

// ❌ ANTES
Future<List<Map<String, dynamic>>> obtenerMembresiasVencidasAntiguo() async {
  final snapshot = await FirebaseFirestore.instance
      .collection('membresias')
      .where('estado', isEqualTo: 'activa')
      .get();

  List<Map<String, dynamic>> vencidas = [];

  for (var doc in snapshot.docs) {
    final data = doc.data();
    final fechaFin = (data['fechaFin'] as Timestamp).toDate();

    if (fechaFin.isBefore(DateTime.now())) {
      vencidas.add(data);
    }
  }

  return vencidas;
}

// ✅ DESPUÉS
Future<List<Membresia>> obtenerMembresiasVencidasNuevo() async {
  final snapshot = await FirebaseFirestore.instance
      .collection('membresias')
      .where('estado', isEqualTo: 'activa')
      .get();

  final membresias = snapshot.docs
      .map((doc) => Membresia.fromJson(doc.data(), doc.id))
      .where((m) => m.estaVencida) // Lógica encapsulada en el modelo
      .toList();

  return membresias;
}

// También puedes obtener membresías por vencer
Future<List<Membresia>> obtenerMembresiasProximasAVencer() async {
  final snapshot = await FirebaseFirestore.instance
      .collection('membresias')
      .where('estado', isEqualTo: 'activa')
      .get();

  final membresias = snapshot.docs
      .map((doc) => Membresia.fromJson(doc.data(), doc.id))
      .where((m) => m.estaPorVencer) // Menos de 7 días
      .toList();

  return membresias;
}

// ============================================================================
// EJEMPLO 6: Calcular total de pagos del mes
// ============================================================================

// ❌ ANTES
Future<double> calcularTotalPagosMesAntiguo(int mes, int anio) async {
  final snapshot = await FirebaseFirestore.instance.collection('pagos').get();

  double total = 0;

  for (var doc in snapshot.docs) {
    final data = doc.data();
    final fechaPago = (data['fechaPago'] as Timestamp).toDate();

    if (fechaPago.month == mes && fechaPago.year == anio) {
      total += (data['monto'] as num).toDouble();
    }
  }

  return total;
}

// ✅ DESPUÉS
Future<double> calcularTotalPagosMesNuevo(int mes, int anio) async {
  final snapshot = await FirebaseFirestore.instance.collection('pagos').get();

  final pagos = snapshot.docs
      .map((doc) => Pago.fromJson(doc.data(), doc.id))
      .where((p) => p.fechaPago.month == mes && p.fechaPago.year == anio)
      .toList();

  return pagos.fold<double>(0, (sum, pago) => sum + pago.monto);
}

// ============================================================================
// EJEMPLO 7: Obtener rutina de entrenamiento por día
// ============================================================================

// ❌ ANTES
Future<List<String>> obtenerEjerciciosDiaAntiguo(
  String clienteId,
  String dia,
) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('entrenamientos')
      .where('clienteId', isEqualTo: clienteId)
      .limit(1)
      .get();

  if (snapshot.docs.isEmpty) return [];

  final data = snapshot.docs.first.data();

  if (data[dia] == null) return [];

  return List<String>.from(data[dia] as List);
}

// ✅ DESPUÉS
Future<List<String>> obtenerEjerciciosDiaNuevo(
  String clienteId,
  String dia,
) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('entrenamientos')
      .where('clienteId', isEqualTo: clienteId)
      .limit(1)
      .get();

  if (snapshot.docs.isEmpty) return [];

  final entrenamiento = Entrenamiento.fromJson(
    snapshot.docs.first.data(),
    snapshot.docs.first.id,
  );

  return entrenamiento.ejerciciosPorDia(dia); // Método del modelo
}

// ============================================================================
// EJEMPLO 8: Repositorio Pattern (Recomendado)
// ============================================================================

class ClienteRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'clientes';

  Future<String> crear(Cliente cliente) async {
    final docRef = await _firestore
        .collection(_collection)
        .add(cliente.toJson());
    return docRef.id;
  }

  Future<Cliente?> obtenerPorId(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists) return null;
    return Cliente.fromJson(doc.data()!, doc.id);
  }

  Future<List<Cliente>> obtenerTodos() async {
    final snapshot = await _firestore.collection(_collection).get();
    return snapshot.docs
        .map((doc) => Cliente.fromJson(doc.data(), doc.id))
        .toList();
  }

  Future<void> actualizar(Cliente cliente) async {
    await _firestore
        .collection(_collection)
        .doc(cliente.id)
        .update(cliente.toJson());
  }

  Future<void> eliminar(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  Stream<List<Cliente>> streamTodos() {
    return _firestore
        .collection(_collection)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Cliente.fromJson(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<List<Cliente>> buscarPorNombre(String nombre) async {
    final snapshot = await _firestore.collection(_collection).get();
    return snapshot.docs
        .map((doc) => Cliente.fromJson(doc.data(), doc.id))
        .where((c) => c.nombre.toLowerCase().contains(nombre.toLowerCase()))
        .toList();
  }
}

// Uso del repositorio
void ejemploUsoRepositorio() async {
  final repo = ClienteRepository();

  // Crear
  final nuevoCliente = Cliente(
    id: '',
    nombre: 'Ana García',
    email: 'ana@example.com',
    telefono: '1234567890',
    fechaRegistro: DateTime.now(),
  );
  final id = await repo.crear(nuevoCliente);

  // Leer
  final cliente = await repo.obtenerPorId(id);
  print(cliente?.nombre);

  // Actualizar
  if (cliente != null) {
    final actualizado = cliente.copyWith(telefono: '0987654321');
    await repo.actualizar(actualizado);
  }

  // Eliminar
  await repo.eliminar(id);

  // Stream
  repo.streamTodos().listen((clientes) {
    print('Total clientes: ${clientes.length}');
  });
}
