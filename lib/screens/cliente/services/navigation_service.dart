import 'package:flutter/material.dart';
import '../calendario_screen.dart';
import '../entrenamientos_personalizados_screen.dart';

class NavigationService {
  static void navegarACalendario(BuildContext context, String nombreUsuario) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CalendarioScreen(nombreUsuario: nombreUsuario),
      ),
    );
  }

  static void navegarAEntrenamientos(
    BuildContext context,
    String nombreUsuario,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EntrenamientosPersonalizadosScreen(nombreUsuario: nombreUsuario),
      ),
    );
  }

  static void navegarANutricion(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Función "Nutrición" en desarrollo...'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  static void navegarALogros(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Función "Logros" en desarrollo...'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  static void navegarAClases(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Función "Clases" en desarrollo...'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  static void navegarAMensajes(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Función "Mensajes" en desarrollo...'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  static void navegarAMiPerfil(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Función "Mi Perfil" en desarrollo...'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  static void manejarCarruselTap(
    BuildContext context,
    String accion,
    String nombreUsuario,
  ) {
    switch (accion) {
      case 'entrenamientos':
        navegarAEntrenamientos(context, nombreUsuario);
        break;
      case 'nutricion':
        navegarANutricion(context);
        break;
      case 'logros':
        navegarALogros(context);
        break;
      case 'clases':
        navegarAClases(context);
        break;
      case 'mensajes':
        navegarAMensajes(context);
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Función no implementada'),
            backgroundColor: Colors.grey,
          ),
        );
    }
  }
}
