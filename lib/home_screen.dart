import 'package:flutter/material.dart';
import 'constants.dart';
import 'screens/cita/horarios_screen.dart';
import 'screens/cliente/iniciar_sesion_screen.dart';
import 'screens/empleado/login_empleado_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        toolbarHeight: 80.0,
        elevation: 0,
        centerTitle: true,
        title: Text(AppTexts.gymTitle, style: AppTextStyles.appBarTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.horizontalPadding,
        ),
        child: Column(
          children: [
            // Espaciado superior
            SizedBox(height: 10),

            // Mensaje de fuerza y movilidad
            Center(
              child: Text(
                AppTexts.strengthMessage,
                style: AppTextStyles.strengthText,
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: 10),

            // Botones Empleado e Iniciar Sesión
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Botón Empleado
                SizedBox(
                  width: 180,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginEmpleadoScreen(),
                        ),
                      );
                    },
                    style: AppButtonStyles.primaryButton.copyWith(
                      backgroundColor: WidgetStateProperty.all(
                        const Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                    child: Text('EMPLEADO', style: AppTextStyles.buttonText),
                  ),
                ),
                // Botón Iniciar Sesión
                SizedBox(
                  width: 180,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const IniciarSesionScreen(),
                        ),
                      );
                    },
                    style: AppButtonStyles.loginButton,
                    child: Text(
                      AppTexts.loginButton,
                      style: AppTextStyles.buttonText,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            // Imagen principal
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                AppImages.mainImage,
                width: double.infinity,
                height: 350,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.image_not_supported,
                      size: 50,
                      color: Colors.grey[600],
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 20),

            // Sección inferior
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    AppTexts.wellnessMessage,
                    style: AppTextStyles.wellnessText,
                  ),
                ),
                SizedBox(height: AppDimensions.sectionSpacing),

                Row(
                  children: [
                    Text(
                      AppTexts.firstAppointment,
                      style: AppTextStyles.mainText,
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.add,
                      color: AppColors.secondary,
                      size: AppDimensions.iconSize,
                    ),
                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppTexts.bodyAnalysis,
                          style: AppTextStyles.mainText,
                        ),
                        Text(AppTexts.free, style: AppTextStyles.mainText),
                      ],
                    ),
                    // Botón Solicitar al lado derecho
                    SizedBox(
                      width: 180, // Mismo ancho que loginButton
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HorariosScreen(),
                            ),
                          );
                        },
                        style: AppButtonStyles.primaryButton,
                        child: Text(
                          AppTexts.requestButton,
                          style: AppTextStyles.buttonText,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: AppDimensions.buttonSpacing),

                // Información de contacto
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppTexts.moreInfo,
                          style: AppTextStyles.contactText,
                        ),
                        Text(
                          AppTexts.writeUs,
                          style: AppTextStyles.contactText,
                        ),
                        Text(
                          AppTexts.whatsappText,
                          style: AppTextStyles.contactText,
                        ),
                      ],
                    ),
                    Text(AppTexts.phoneNumber, style: AppTextStyles.phoneText),
                  ],
                ),

                SizedBox(height: AppDimensions.bottomSpacing),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
