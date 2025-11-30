import 'package:flutter/material.dart';
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
  final int _rachaDias = 15; // Días consecutivos de entrenamiento

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
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              // ignore: deprecated_member_use
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Icon(Icons.person_outline, size: 60, color: AppColors.primary),
                SizedBox(height: 15),
                Text(
                  '¡Bienvenido!',
                  style: AppTextStyles.mainText.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  widget.nombreUsuario,
                  style: AppTextStyles.contactText.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
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
                  subtitle: ' $_rachaDias',
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
