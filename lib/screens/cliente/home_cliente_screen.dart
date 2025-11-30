import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants.dart';
import 'calendario_screen.dart';
import 'perfil_screen.dart';
import 'mi_plan_screen.dart';
import 'widgets/cronometro_widget.dart';
import 'widgets/temporizador_widget.dart';
import 'widgets/calculadora_imc_widget.dart';
import 'widgets/carrusel_widget.dart';
import 'widgets/menu_card_widget.dart';
import 'services/navigation_service.dart';

class HomeClienteScreen extends StatefulWidget {
  final String nombreUsuario;

  const HomeClienteScreen({super.key, required this.nombreUsuario});

  @override
  // ignore: library_private_types_in_public_api
  _HomeClienteScreenState createState() => _HomeClienteScreenState();
}

class _HomeClienteScreenState extends State<HomeClienteScreen> {
  int _selectedIndex = 0;
  String _nombreCompleto = '';
  int _totalAsistencias = 0;
  bool _cargandoDatos = true;

  final List<Map<String, dynamic>> _carouselItems = [
    {
      'title': 'Entrenamientos',
      'subtitle': 'Accede a tus rutinas personalizadas',
      'icon': Icons.fitness_center,
      'color': AppColors.primary,
      'onTap': 'entrenamientos',
    },
    {
      'title': 'Nutrición',
      'subtitle': 'Guías y consejos nutricionales',
      'icon': Icons.restaurant,
      'color': Colors.green,
      'onTap': 'nutricion',
    },
    {
      'title': 'Comunidad',
      'subtitle': 'Conecta con otros usuarios',
      'icon': Icons.people,
      'color': Colors.blue,
      'onTap': 'comunidad',
    },
  ];

  List<Widget> get _pages => [
    _buildHomePage(),
    CronometroWidget(),
    TemporizadorWidget(),
    CalculadoraIMCWidget(),
  ];

  @override
  void initState() {
    super.initState();
    _cargarDatosCliente();
  }

  Future<void> _cargarDatosCliente() async {
    try {
      final db = FirebaseFirestore.instance;

      // Obtener clienteId desde credenciales
      final credencialesSnapshot = await db
          .collection('credenciales')
          .where('usuario', isEqualTo: widget.nombreUsuario)
          .get();

      if (credencialesSnapshot.docs.isNotEmpty) {
        final clienteId = credencialesSnapshot.docs.first.get('clienteId');

        // Obtener datos del cliente
        final clienteSnapshot = await db
            .collection('clientes')
            .doc(clienteId)
            .get();

        if (clienteSnapshot.exists && mounted) {
          final nombre = clienteSnapshot.get('nombre') ?? '';
          final apellidos = clienteSnapshot.get('apellidos') ?? '';
          final asistenciasData = clienteSnapshot.get('asistencias');

          // Convertir asistencias al formato correcto
          int asistencias = 0;
          if (asistenciasData != null) {
            if (asistenciasData is int) {
              asistencias = asistenciasData;
            } else if (asistenciasData is String) {
              asistencias = int.tryParse(asistenciasData) ?? 0;
            } else if (asistenciasData is double) {
              asistencias = asistenciasData.toInt();
            }
          }

          setState(() {
            _nombreCompleto = '$nombre $apellidos'.trim();
            _totalAsistencias = asistencias;
            _cargandoDatos = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _cargandoDatos = false);
      }
    }
  }

  @override
  void dispose() {
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
        automaticallyImplyLeading: false,
        title: Text(
          _getPageTitle(),
          style: AppTextStyles.appBarTitle.copyWith(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Cerrar Sesión'),
                  content: Text('¿Estás seguro que deseas cerrar sesión?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst);
                      },
                      child: Text(
                        'Cerrar Sesión',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: Colors.white,
        // ignore: deprecated_member_use
        indicatorColor: AppColors.primary.withOpacity(0.3),
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppColors.primary),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer, color: AppColors.primary),
            label: 'Cronómetro',
          ),
          NavigationDestination(
            icon: Icon(Icons.hourglass_empty_outlined),
            selectedIcon: Icon(Icons.hourglass_empty, color: AppColors.primary),
            label: 'Temporizador',
          ),
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate, color: AppColors.primary),
            label: 'IMC',
          ),
        ],
      ),
    );
  }

  String _getPageTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'CLIENTE';
      case 1:
        return 'CRONÓMETRO';
      case 2:
        return 'TEMPORIZADOR';
      case 3:
        return 'CALCULADORA IMC';
      default:
        return 'CLIENTE';
    }
  }

  Widget _buildHomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),

          // Bienvenida
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                // ignore: deprecated_member_use
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Ícono en contenedor
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.person_outline,
                    size: 36,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),

                // Título
                Text(
                  '¡Bienvenido!',
                  style: AppTextStyles.mainText.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),

                // Nombre completo con mejor presentación
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      // ignore: deprecated_member_use
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _cargandoDatos
                        ? 'Cargando...'
                        : (_nombreCompleto.isNotEmpty
                              ? _nombreCompleto
                              : widget.nombreUsuario),
                    style: AppTextStyles.mainText.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 10),

                // Mensaje motivacional
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.fitness_center, size: 16, color: Colors.white70),
                    SizedBox(width: 6),
                    Text(
                      'Continúa con tu entrenamiento',
                      style: AppTextStyles.contactText.copyWith(
                        fontSize: 12,
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Carousel horizontal
          CarruselWidget(
            items: _carouselItems,
            onItemTap: (String action) => NavigationService.manejarCarruselTap(
              context,
              action,
              widget.nombreUsuario,
            ),
          ),

          SizedBox(height: 20),

          // Opciones del cliente
          Text(
            'Panel de Cliente',
            style: AppTextStyles.mainText.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 15),

          // Grid de opciones con altura fija
          SizedBox(
            height: 400,
            child: GridView.count(
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: [
                MenuCardWidget(
                  icon: Icons.calendar_today,
                  title: 'Calendario',
                  subtitle: 'Ver entrenamientos programados',
                  onTap: () => _navegarACalendario(context),
                ),
                MenuCardWidget(
                  icon: Icons.fitness_center,
                  title: 'Mi Plan',
                  subtitle: '',
                  image: 'assets/img1.jpg',
                  onTap: () => _navegarAMiPlan(context),
                ),
                MenuCardWidget(
                  icon: Icons.local_fire_department,
                  title: 'Racha',
                  subtitle: '$_totalAsistencias asistencias',
                  onTap: () {}, // Función vacía - no hace nada
                ),
                MenuCardWidget(
                  icon: Icons.person,
                  title: 'Mi Perfil',
                  subtitle: 'Datos personales',
                  onTap: () => _navegarAPerfil(context),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),
        ],
      ),
    );
  }

  void _navegarACalendario(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CalendarioScreen(nombreUsuario: widget.nombreUsuario),
      ),
    );
  }

  void _navegarAMiPlan(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MiPlanScreen(nombreUsuario: widget.nombreUsuario),
      ),
    );
  }

  void _navegarAPerfil(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PerfilScreen(nombreUsuario: widget.nombreUsuario),
      ),
    );
  }
}
