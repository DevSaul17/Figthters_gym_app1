import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  // Stream de cambios de conectividad
  Stream<ConnectivityResult> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;

  // Verificar si hay conexión actualmente
  Future<bool> isConnected() async {
    final ConnectivityResult connectivityResult = await _connectivity
        .checkConnectivity();

    // Si hay algún tipo de conexión (WiFi, móvil, ethernet), retornar true
    return connectivityResult != ConnectivityResult.none;
  }

  // Obtener tipo de conexión actual
  Future<String> getConnectionType() async {
    final ConnectivityResult connectivityResult = await _connectivity
        .checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      return 'Sin conexión';
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return 'WiFi';
    } else if (connectivityResult == ConnectivityResult.mobile) {
      return 'Datos móviles';
    } else if (connectivityResult == ConnectivityResult.ethernet) {
      return 'Ethernet';
    } else {
      return 'Conectado';
    }
  }
}
