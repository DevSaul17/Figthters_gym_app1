import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class AuthSecurityService {
  // Configuración de seguridad
  static const int maxIntentos = 3;
  static const Duration tiempoBloqueo = Duration(minutes: 15);
  static const Duration timeoutAutenticacion = Duration(seconds: 10);

  // Patrones de validación
  static const String dniPattern = r'^\d{8}$';
  static const String passwordPattern = r'^.{6,}$';

  /// Hash de contraseña usando SHA-256 con salt
  static String hashPassword(String password, String salt) {
    var bytes = utf8.encode(password + salt);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Generar salt único para cada usuario
  static String generateSalt(String dni) {
    return 'gym_salt_${dni}_security_v1';
  }

  /// Validar formato de DNI
  static bool validarDNI(String dni) {
    return RegExp(dniPattern).hasMatch(dni);
  }

  /// Validar requisitos mínimos de contraseña
  static bool validarPassword(String password) {
    return RegExp(passwordPattern).hasMatch(password);
  }

  /// Verificar rate limiting por DNI
  static Future<bool> verificarRateLimit(String dni) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'login_attempts_$dni';
      final timeKey = 'last_attempt_$dni';

      final intentos = prefs.getInt(key) ?? 0;
      final ultimoIntento = prefs.getInt(timeKey) ?? 0;
      final ahora = DateTime.now().millisecondsSinceEpoch;

      // Si han pasado más de 15 minutos, resetear intentos
      if (ahora - ultimoIntento > tiempoBloqueo.inMilliseconds) {
        await prefs.remove(key);
        await prefs.remove(timeKey);
        return true;
      }

      // Si excede el límite de intentos
      if (intentos >= maxIntentos) {
        return false;
      }

      return true;
    } catch (e) {
      // En caso de error, permitir el intento
      debugPrint('Error verificando rate limit: $e');
      return true;
    }
  }

  /// Registrar intento fallido
  static Future<void> registrarIntentoFallido(String dni) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'login_attempts_$dni';
      final timeKey = 'last_attempt_$dni';

      final intentos = prefs.getInt(key) ?? 0;
      await prefs.setInt(key, intentos + 1);
      await prefs.setInt(timeKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('Error registrando intento fallido: $e');
    }
  }

  /// Limpiar intentos después de login exitoso
  static Future<void> limpiarIntentos(String dni) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('login_attempts_$dni');
      await prefs.remove('last_attempt_$dni');
    } catch (e) {
      debugPrint('Error limpiando intentos: $e');
    }
  }

  /// Obtener número de intentos restantes
  static Future<int> intentosRestantes(String dni) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final intentos = prefs.getInt('login_attempts_$dni') ?? 0;
      return maxIntentos - intentos;
    } catch (e) {
      return maxIntentos;
    }
  }

  /// Obtener tiempo de desbloqueo restante
  static Future<Duration?> tiempoDesbloqueoRestante(String dni) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ultimoIntento = prefs.getInt('last_attempt_$dni') ?? 0;
      final ahora = DateTime.now().millisecondsSinceEpoch;

      if (ultimoIntento == 0) return null;

      final tiempoTranscurrido = Duration(milliseconds: ahora - ultimoIntento);
      if (tiempoTranscurrido >= tiempoBloqueo) return null;

      return tiempoBloqueo - tiempoTranscurrido;
    } catch (e) {
      return null;
    }
  }

  /// Limpiar datos de seguridad (para debugging)
  static Future<void> limpiarDatosSeguridad() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      for (String key in keys) {
        if (key.startsWith('login_attempts_') ||
            key.startsWith('last_attempt_')) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      debugPrint('Error limpiando datos de seguridad: $e');
    }
  }
}
