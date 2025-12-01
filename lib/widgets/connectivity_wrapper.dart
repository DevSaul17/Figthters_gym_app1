import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/connectivity_service.dart';

class ConnectivityWrapper extends StatefulWidget {
  final Widget child;

  const ConnectivityWrapper({super.key, required this.child});

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  final ConnectivityService _connectivityService = ConnectivityService();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _checkInitialConnection();
    _subscribeToConnectivityChanges();
  }

  // Verificar estado de conexión inicial
  Future<void> _checkInitialConnection() async {
    final isConnected = await _connectivityService.isConnected();

    if (mounted) {
      setState(() {
        _isConnected = isConnected;
      });
    }
  } // Suscribirse a cambios de conectividad

  void _subscribeToConnectivityChanges() {
    _connectivitySubscription = _connectivityService.onConnectivityChanged
        .listen((ConnectivityResult result) async {
          final isConnected = result != ConnectivityResult.none;
          final connectionType = await _connectivityService.getConnectionType();

          if (mounted) {
            setState(() {
              _isConnected = isConnected;
            });

            // Mostrar mensaje cuando se recupera la conexión
            if (isConnected) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Conexión restaurada ($connectionType)'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          }
        });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Banner de estado de conexión
        if (!_isConnected)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.grey[400]!,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Sin conexión a internet',
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

        // Contenido principal de la app
        Expanded(child: widget.child),
      ],
    );
  }
}
