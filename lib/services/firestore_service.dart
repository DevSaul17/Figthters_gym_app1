import 'package:cloud_firestore/cloud_firestore.dart';

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
}
