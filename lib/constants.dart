import 'package:flutter/material.dart';

// COLORES
class AppColors {
  static const Color primary = Colors.black;
  static const Color secondary = Colors.red;
  static const Color background = Colors.white;
  static const Color textPrimary = Colors.black;
  static const Color textSecondary = Colors.white;
}

// TEXTOS
class AppTexts {
  // Títulos
  static const String appTitle = 'Fight\'s Gym';
  static const String gymTitle = 'FIGHTER\'S GYM';

  // Botones
  static const String loginButton = 'INICIAR SESIÓN';
  static const String requestButton = 'SOLICITAR AQUÍ!!';

  // Mensajes principales
  static const String strengthMessage = 'Fuerza y movilidad a toda edad !!';
  static const String wellnessMessage = '¡Tu bienestar empieza hoy!';
  static const String firstAppointment = 'Primera cita';
  static const String bodyAnalysis = 'Análisis corporal';
  static const String free = 'GRATIS';

  // Información de contacto
  static const String moreInfo = 'Para más información';
  static const String writeUs = 'escríbenos';
  static const String whatsappText = 'al siguiente whatsapp!!';
  static const String phoneNumber = '999 999 999';
}

// IMÁGENES
class AppImages {
  static const String mainImage = 'assets/main1.jpg';
  static const String horarioImage = 'assets/horario.jpeg';
}

// ESTILOS DE TEXTO
class AppTextStyles {
  static const TextStyle appBarTitle = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    letterSpacing: 2.0,
    color: Color.fromARGB(255, 255, 255, 255),
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
  );

  static const TextStyle strengthText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle wellnessText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle mainText = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle contactText = TextStyle(
    fontSize: 14,
    color: AppColors.textPrimary,
  );

  static const TextStyle phoneText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );
}

// CONFIGURACIONES DE BOTONES
class AppButtonStyles {
  static ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.textSecondary,
    padding: const EdgeInsets.symmetric(vertical: 20),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  );

  static ButtonStyle loginButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.textSecondary,
    padding: const EdgeInsets.symmetric(vertical: 20),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  );
}

// DIMENSIONES Y ESPACIADO
class AppDimensions {
  static const double horizontalPadding = 24.0;
  static const double topSpacing = 60.0;
  static const double sectionSpacing = 16.0;
  static const double buttonSpacing = 24.0;
  static const double bottomSpacing = 40.0;
  static const double iconSize = 28.0;
}
