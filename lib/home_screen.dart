import 'package:flutter/material.dart';
import 'constants.dart';
import 'screens/cita/horarios_screen.dart';
import 'screens/cliente/iniciar_sesion_screen.dart';
import 'screens/empleado/login_empleado_screen.dart';
import 'widgets/pending_operations_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        toolbarHeight: isTablet ? 100.0 : 80.0,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppTexts.gymTitle,
          style: AppTextStyles.appBarTitle.copyWith(
            fontSize: isTablet ? 28 : null,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: PendingOperationsBadge(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 40.0 : AppDimensions.horizontalPadding,
            ),
            child: Column(
              children: [
                // Espaciado superior adaptable
                SizedBox(height: isLandscape ? 5 : 10),

                // Mensaje de fuerza y movilidad
                Center(
                  child: Text(
                    AppTexts.strengthMessage,
                    style: AppTextStyles.strengthText.copyWith(
                      fontSize: isTablet ? 20 : null,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                SizedBox(height: isLandscape ? 5 : 10),

                // Botones Empleado e Iniciar Sesión - Layout responsivo
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 600) {
                      // Layout para tablets y pantallas grandes
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 200,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const LoginEmpleadoScreen(),
                                  ),
                                );
                              },
                              style: AppButtonStyles.primaryButton.copyWith(
                                backgroundColor: WidgetStateProperty.all(
                                  const Color.fromARGB(255, 0, 0, 0),
                                ),
                              ),
                              child: Text(
                                'EMPLEADO',
                                style: AppTextStyles.buttonText.copyWith(
                                  fontSize: isTablet ? 18 : null,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 20),
                          SizedBox(
                            width: 200,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const IniciarSesionScreen(),
                                  ),
                                );
                              },
                              style: AppButtonStyles.loginButton,
                              child: Text(
                                AppTexts.loginButton,
                                style: AppTextStyles.buttonText.copyWith(
                                  fontSize: isTablet ? 18 : null,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      // Layout para móviles
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const LoginEmpleadoScreen(),
                                    ),
                                  );
                                },
                                style: AppButtonStyles.primaryButton.copyWith(
                                  backgroundColor: WidgetStateProperty.all(
                                    const Color.fromARGB(255, 0, 0, 0),
                                  ),
                                ),
                                child: Text(
                                  'EMPLEADO',
                                  style: AppTextStyles.buttonText,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const IniciarSesionScreen(),
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
                          ),
                        ],
                      );
                    }
                  },
                ),

                SizedBox(height: isLandscape ? 10 : 20),

                // Imagen principal con tamaño adaptable
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: isLandscape
                          ? screenHeight * 0.4
                          : isTablet
                          ? 400
                          : 350,
                      maxWidth: isTablet ? 600 : double.infinity,
                    ),
                    child: Image.asset(
                      AppImages.mainImage,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: isLandscape ? screenHeight * 0.3 : 200,
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
                ),

                SizedBox(height: isLandscape ? 10 : 20),

                // Sección inferior con layout responsivo
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isTablet ? 600 : double.infinity,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          AppTexts.wellnessMessage,
                          style: AppTextStyles.wellnessText.copyWith(
                            fontSize: isTablet ? 18 : null,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: isLandscape ? 10 : AppDimensions.sectionSpacing,
                      ),

                      Row(
                        children: [
                          Text(
                            AppTexts.firstAppointment,
                            style: AppTextStyles.mainText.copyWith(
                              fontSize: isTablet ? 18 : null,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.add,
                            color: AppColors.secondary,
                            size: isTablet ? 28 : AppDimensions.iconSize,
                          ),
                        ],
                      ),

                      // Layout de análisis corporal y botón - responsivo
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth > 600) {
                            // Layout horizontal para tablets
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppTexts.bodyAnalysis,
                                        style: AppTextStyles.mainText.copyWith(
                                          fontSize: isTablet ? 18 : null,
                                        ),
                                      ),
                                      Text(
                                        AppTexts.free,
                                        style: AppTextStyles.mainText.copyWith(
                                          fontSize: isTablet ? 18 : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 20),
                                SizedBox(
                                  width: 200,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const HorariosScreen(),
                                        ),
                                      );
                                    },
                                    style: AppButtonStyles.primaryButton,
                                    child: Text(
                                      AppTexts.requestButton,
                                      style: AppTextStyles.buttonText.copyWith(
                                        fontSize: isTablet ? 18 : null,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          } else {
                            // Layout vertical para móviles en orientación vertical
                            if (isLandscape) {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppTexts.bodyAnalysis,
                                          style: AppTextStyles.mainText,
                                        ),
                                        Text(
                                          AppTexts.free,
                                          style: AppTextStyles.mainText,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 150,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const HorariosScreen(),
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
                              );
                            } else {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppTexts.bodyAnalysis,
                                        style: AppTextStyles.mainText,
                                      ),
                                      Text(
                                        AppTexts.free,
                                        style: AppTextStyles.mainText,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 15),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const HorariosScreen(),
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
                              );
                            }
                          }
                        },
                      ),

                      SizedBox(
                        height: isLandscape ? 10 : AppDimensions.buttonSpacing,
                      ),

                      // Información de contacto
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppTexts.moreInfo,
                                  style: AppTextStyles.contactText.copyWith(
                                    fontSize: isTablet ? 16 : null,
                                  ),
                                ),
                                Text(
                                  AppTexts.writeUs,
                                  style: AppTextStyles.contactText.copyWith(
                                    fontSize: isTablet ? 16 : null,
                                  ),
                                ),
                                Text(
                                  AppTexts.whatsappText,
                                  style: AppTextStyles.contactText.copyWith(
                                    fontSize: isTablet ? 16 : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            AppTexts.phoneNumber,
                            style: AppTextStyles.phoneText.copyWith(
                              fontSize: isTablet ? 18 : null,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(
                        height: isLandscape ? 10 : AppDimensions.bottomSpacing,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
