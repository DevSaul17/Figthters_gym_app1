import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import '../../constants.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_security_service.dart';
import 'home_cliente_screen.dart';

class IniciarSesionScreen extends StatefulWidget {
  const IniciarSesionScreen({super.key});

  @override
  State<IniciarSesionScreen> createState() => _IniciarSesionScreenState();
}

class _IniciarSesionScreenState extends State<IniciarSesionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dniController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void dispose() {
    _dniController.dispose();
    _passwordController.dispose();
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
          'Iniciar Sesión',
          style: AppTextStyles.appBarTitle.copyWith(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.horizontalPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40),

              // Logo o título
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.fitness_center,
                      size: 80,
                      color: AppColors.primary,
                    ),
                    SizedBox(height: 20),
                    Text(
                      AppTexts.gymTitle,
                      style: AppTextStyles.mainText.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 50),

              // Campo Usuario (DNI)
              _buildTextField(
                controller: _dniController,
                label: 'DNI',
                hintText: 'Ingresa tu DNI',
                prefixIcon: Icons.card_membership,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu DNI';
                  }
                  if (!AuthSecurityService.validarDNI(value.trim())) {
                    return 'DNI inválido (debe tener 8 dígitos)';
                  }
                  return null;
                },
              ),

              SizedBox(height: 20),

              // Campo Contraseña
              _buildTextField(
                controller: _passwordController,
                label: 'Contraseña',
                hintText: 'Ingresa tu contraseña',
                prefixIcon: Icons.lock_outline,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey[600],
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
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

              SizedBox(height: 30),

              // Botón Iniciar Sesión
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => _iniciarSesion(),
                  style: AppButtonStyles.primaryButton.copyWith(
                    backgroundColor: WidgetStateProperty.all(AppColors.primary),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    padding: WidgetStateProperty.all(
                      EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Iniciar Sesión',
                          style: AppTextStyles.buttonText.copyWith(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                ),
              ),

              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.contactText.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          style: AppTextStyles.contactText.copyWith(fontSize: 16),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[500]),
            prefixIcon: Icon(prefixIcon, color: AppColors.primary),
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  void _iniciarSesion() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final dni = _dniController.text.trim();
      final contrasena = _passwordController.text;

      // Verificar rate limiting
      final puedeIntentar = await AuthSecurityService.verificarRateLimit(dni);
      if (!puedeIntentar) {
        final tiempoRestante =
            await AuthSecurityService.tiempoDesbloqueoRestante(dni);
        if (mounted) {
          _mostrarDialogoError(
            'Cuenta Bloqueada',
            'Demasiados intentos fallidos. Intenta en ${tiempoRestante?.inMinutes ?? 15} minutos.',
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Buscar credenciales en la colección de credenciales
      final querySnapshot = await _firestoreService
          .getCollection(
            'credenciales',
            queryBuilder: (q) => q.where('usuario', isEqualTo: dni),
          )
          .timeout(AuthSecurityService.timeoutAutenticacion);

      if (querySnapshot.docs.isEmpty) {
        await AuthSecurityService.registrarIntentoFallido(dni);
        if (mounted) {
          _mostrarDialogoError(
            'Usuario No Encontrado',
            'El DNI ingresado no existe en nuestros registros.',
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final credencialDoc = querySnapshot.docs.first;
      final credencialData = credencialDoc.data() as Map<String, dynamic>;

      // Verificar si la cuenta está activa
      if (credencialData['activo'] != null && !credencialData['activo']) {
        await AuthSecurityService.registrarIntentoFallido(dni);
        if (mounted) {
          _mostrarDialogoError(
            'Cuenta Desactivada',
            'Tu cuenta ha sido desactivada. Contacta al administrador.',
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Verificar contraseña - hashear la contraseña ingresada para compararla con la guardada en Firebase
      final contrasenaBD = credencialData['contrasena'];
      final contrasenaHash = sha256.convert(contrasena.codeUnits).toString();

      if (contrasenaBD != contrasenaHash) {
        await AuthSecurityService.registrarIntentoFallido(dni);
        final intentosRestantes = await AuthSecurityService.intentosRestantes(
          dni,
        );
        if (mounted) {
          _mostrarDialogoError(
            'Contraseña Incorrecta',
            'Te quedan $intentosRestantes intentos.',
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Autenticación exitosa
      await AuthSecurityService.limpiarIntentos(dni);

      // Actualizar último login
      await _firestoreService.updateDocument('credenciales', credencialDoc.id, {
        'ultimo_login': DateTime.now(),
      });

      if (mounted) {
        _mostrarDialogoExito(dni, credencialData['nombre']);
      }
    } catch (e) {
      if (mounted) {
        _mostrarDialogoError('Error', 'Ocurrió un error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _mostrarDialogoError(String titulo, String mensaje) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          titulo,
          style: AppTextStyles.mainText.copyWith(
            color: Colors.red[700],
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red[600]),
            SizedBox(height: 16),
            Text(
              mensaje,
              style: AppTextStyles.contactText.copyWith(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Entendido',
              style: AppTextStyles.buttonText.copyWith(
                color: AppColors.primary,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoExito(String dni, String nombre) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Acceso Exitoso',
          style: AppTextStyles.mainText.copyWith(
            color: Colors.green[700],
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 60, color: Colors.green[600]),
            SizedBox(height: 16),
            Text(
              '¡Bienvenido $nombre!',
              style: AppTextStyles.contactText.copyWith(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar el diálogo
              // Navegar a pantalla de cliente
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeClienteScreen(nombreUsuario: dni),
                ),
              );
            },
            child: Text(
              'Continuar',
              style: AppTextStyles.buttonText.copyWith(
                color: AppColors.primary,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
