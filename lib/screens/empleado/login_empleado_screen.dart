import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_security_service.dart';
import 'home_gym_screen.dart';

class LoginEmpleadoScreen extends StatefulWidget {
  const LoginEmpleadoScreen({super.key});

  @override
  State<LoginEmpleadoScreen> createState() => _LoginEmpleadoScreenState();
}

class _LoginEmpleadoScreenState extends State<LoginEmpleadoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usuarioController = TextEditingController();
  final _contrasenaController = TextEditingController();
  bool _obscurePassword = true;
  bool _mantenerSesion = false;
  bool _isLoading = false;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void dispose() {
    _usuarioController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 80.0,
        title: Text(
          'LOGIN EMPLEADO',
          style: AppTextStyles.appBarTitle.copyWith(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.horizontalPadding),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono de empleado
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // ignore: deprecated_member_use
                  color: AppColors.primary.withOpacity(0.1),
                  border: Border.all(color: AppColors.primary, width: 3),
                ),
                child: Icon(Icons.badge, size: 60, color: AppColors.primary),
              ),

              SizedBox(height: 40),

              // Título
              Text(
                'Acceso de Empleado',
                style: AppTextStyles.mainText.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 30),

              // Campo Usuario
              TextFormField(
                controller: _usuarioController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(8),
                ],
                decoration: InputDecoration(
                  labelText: 'DNI',
                  hintText: 'Ingresa tu DNI (8 dígitos)',
                  prefixIcon: Icon(Icons.person, color: AppColors.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu DNI';
                  }
                  if (value.length != 8) {
                    return 'El DNI debe tener exactamente 8 dígitos';
                  }
                  return null;
                },
              ),

              SizedBox(height: 20),

              // Campo Contraseña
              TextFormField(
                controller: _contrasenaController,
                obscureText: _obscurePassword,
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  hintText: 'Ingresa tu contraseña',
                  prefixIcon: Icon(Icons.lock, color: AppColors.primary),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: AppColors.primary,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu contraseña';
                  }
                  if (value.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres';
                  }
                  return null;
                },
              ),

              SizedBox(height: 20),

              // Opción Mantener Sesión
              Row(
                children: [
                  Checkbox(
                    value: _mantenerSesion,
                    onChanged: (value) {
                      setState(() {
                        _mantenerSesion = value ?? false;
                      });
                    },
                    activeColor: AppColors.primary,
                  ),
                  Expanded(
                    child: Text(
                      'Mantener sesión iniciada',
                      style: AppTextStyles.contactText.copyWith(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 30),

              // Botón Ingresar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          _iniciarSesionEmpleado();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isLoading ? Colors.grey : Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          'Ingresar',
                          style: AppTextStyles.buttonText.copyWith(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              SizedBox(height: 20),

              // Información adicional
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey[600], size: 24),
                    SizedBox(height: 8),
                    Text(
                      'Acceso exclusivo para personal autorizado',
                      style: AppTextStyles.contactText.copyWith(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _iniciarSesionEmpleado() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final empleadoData = await _firestoreService.autenticarEmpleado(
          _usuarioController.text.trim(),
          _contrasenaController.text,
        );

        if (empleadoData != null) {
          // Limpiar campos sensibles
          _contrasenaController.clear();

          // Autenticación exitosa
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeGymScreen(
                  nombreEmpleado:
                      '${empleadoData['nombre']} ${empleadoData['apellido']}',
                ),
              ),
            );

            // Mostrar mensaje de bienvenida
            Future.delayed(Duration(milliseconds: 300), () {
              if (mounted) {
                String mensaje = _mantenerSesion
                    ? 'Sesión mantenida activa. ¡Bienvenido ${empleadoData['nombre']}!'
                    : '¡Acceso autorizado con éxito! Bienvenido ${empleadoData['nombre']}';

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(mensaje),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            });
          }
        } else {
          // Autenticación fallida
          _contrasenaController.clear();

          if (mounted) {
            // Obtener intentos restantes para mostrar información útil
            final intentosRestantes =
                await AuthSecurityService.intentosRestantes(
                  _usuarioController.text.trim(),
                );

            String mensaje;
            if (intentosRestantes <= 1) {
              mensaje =
                  'DNI o contraseña incorrectos. Último intento antes del bloqueo temporal.';
            } else {
              mensaje =
                  'DNI o contraseña incorrectos. Te quedan ${intentosRestantes - 1} intentos.';
            }

            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(mensaje),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 4),
              ),
            );
          }
        }
      } catch (e) {
        // Limpiar campos sensibles
        _contrasenaController.clear();

        String mensaje;
        if (e.toString().contains('RATE_LIMIT_EXCEEDED')) {
          // Obtener tiempo restante de bloqueo
          final tiempoRestante =
              await AuthSecurityService.tiempoDesbloqueoRestante(
                _usuarioController.text.trim(),
              );
          if (tiempoRestante != null) {
            final minutos = tiempoRestante.inMinutes;
            mensaje =
                'Demasiados intentos fallidos. Intenta de nuevo en $minutos minutos.';
          } else {
            mensaje =
                'Demasiados intentos fallidos. Intenta de nuevo en 15 minutos.';
          }
        } else if (e.toString().contains('ACCOUNT_DISABLED')) {
          mensaje = 'Tu cuenta ha sido desactivada. Contacta al administrador.';
        } else {
          mensaje =
              'Error de conexión. Verifica tu internet e intenta nuevamente.';
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(mensaje),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
              action: e.toString().contains('RATE_LIMIT_EXCEEDED')
                  ? SnackBarAction(
                      label: 'Limpiar',
                      textColor: Colors.white,
                      onPressed: () async {
                        // Función de debug para limpiar rate limiting
                        await AuthSecurityService.limpiarDatosSeguridad();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Datos de seguridad limpiados (solo para desarrollo)',
                              ),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                      },
                    )
                  : null,
            ),
          );
        }
      }
    }
  }
}
