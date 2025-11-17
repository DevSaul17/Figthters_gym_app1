import 'package:flutter/material.dart';
import '../../constants.dart';
import 'calendario_screen.dart';
import 'dart:async';

class HomeClienteScreen extends StatefulWidget {
  final String nombreUsuario;

  const HomeClienteScreen({super.key, required this.nombreUsuario});

  @override
  State<HomeClienteScreen> createState() => _HomeClienteScreenState();
}

class _HomeClienteScreenState extends State<HomeClienteScreen> {
  int _selectedIndex = 0;

  // Variables del cronómetro
  late Stopwatch _stopwatch;
  late Timer _timer;
  bool _isRunning = false;
  String _timeDisplay = "00:00:00";

  // Variables del temporizador
  Timer? _countdownTimer;
  bool _isCountdownRunning = false;
  int _totalSeconds = 0;
  int _remainingSeconds = 0;
  String _countdownDisplay = "00:00";
  int _selectedMinutes = 5;
  int _selectedSecondsExtra = 0;

  // Variables de la calculadora IMC
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _alturaController = TextEditingController();
  double _imcCalculado = 0.0;
  String _categoriaIMC = '';
  Color _colorIMC = Colors.grey;
  bool _mostrarResultado = false;
  String _generoSeleccionado = 'Masculino';
  String _unidadAltura = 'metros'; // metros o centímetros

  // Elementos del carousel
  final List<Map<String, dynamic>> _carouselItems = [
    {
      'title': 'Entrenamientos',
      'subtitle': 'Rutinas personalizadas para ti',
      'icon': Icons.fitness_center,
      'color': Colors.blue,
      'onTap': 'entrenamientos',
    },
    {
      'title': 'Nutrición',
      'subtitle': 'Planes alimenticios saludables',
      'icon': Icons.restaurant,
      'color': Colors.green,
      'onTap': 'nutricion',
    },
    {
      'title': 'Logros',
      'subtitle': 'Tus metas alcanzadas',
      'icon': Icons.emoji_events,
      'color': Colors.orange,
      'onTap': 'logros',
    },
    {
      'title': 'Clases',
      'subtitle': 'Clases grupales disponibles',
      'icon': Icons.groups,
      'color': Colors.purple,
      'onTap': 'clases',
    },
    {
      'title': 'Mensajes',
      'subtitle': 'Comunicación con entrenadores',
      'icon': Icons.message,
      'color': Colors.teal,
      'onTap': 'mensajes',
    },
  ];

  List<Widget> get _pages => [
    _buildHomePage(),
    _buildCronometroPage(),
    _buildTemporizadorPage(),
    _buildCalculadoraIMCPage(),
  ];

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    _timer = Timer.periodic(Duration(milliseconds: 10), _updateTime);
    // Inicializar temporizador con 5 minutos por defecto
    _selectedMinutes = 5;
    _selectedSecondsExtra = 0;
    _updateCountdownDisplay();
  }

  @override
  void dispose() {
    _timer.cancel();
    if (_countdownTimer?.isActive == true) {
      _countdownTimer?.cancel();
    }
    _pesoController.dispose();
    _alturaController.dispose();
    super.dispose();
  }

  void _updateTime(Timer timer) {
    if (_stopwatch.isRunning) {
      setState(() {
        _timeDisplay = _formatTime(_stopwatch.elapsedMilliseconds);
      });
    }
  }

  String _formatTime(int milliseconds) {
    int hundreds = (milliseconds / 10).truncate() % 100;
    int seconds = (milliseconds / 1000).truncate() % 60;
    int minutes = (milliseconds / 60000).truncate() % 60;
    int hours = (milliseconds / 3600000).truncate();

    if (hours > 0) {
      return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
    } else {
      return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${hundreds.toString().padLeft(2, '0')}";
    }
  }

  void _startStopStopwatch() {
    setState(() {
      if (_stopwatch.isRunning) {
        _stopwatch.stop();
        _isRunning = false;
      } else {
        _stopwatch.start();
        _isRunning = true;
      }
    });
  }

  void _resetStopwatch() {
    setState(() {
      _stopwatch.reset();
      _timeDisplay = "00:00.00";
      _isRunning = false;
    });
  }

  // Métodos del temporizador
  void _updateCountdownDisplay() {
    setState(() {
      _totalSeconds = (_selectedMinutes * 60) + _selectedSecondsExtra;
      _remainingSeconds = _totalSeconds;
      _countdownDisplay = _formatCountdownTime(_remainingSeconds);
    });
  }

  String _formatCountdownTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  void _startStopCountdown() {
    setState(() {
      if (_isCountdownRunning) {
        _countdownTimer?.cancel();
        _isCountdownRunning = false;
      } else {
        if (_remainingSeconds > 0) {
          _isCountdownRunning = true;
          _countdownTimer = Timer.periodic(
            Duration(seconds: 1),
            _updateCountdown,
          );
        }
      }
    });
  }

  void _updateCountdown(Timer timer) {
    setState(() {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        _countdownDisplay = _formatCountdownTime(_remainingSeconds);
      } else {
        _countdownTimer?.cancel();
        _isCountdownRunning = false;
        _showTimeUpDialog();
      }
    });
  }

  void _resetCountdown() {
    setState(() {
      if (_countdownTimer?.isActive == true) {
        _countdownTimer?.cancel();
      }
      _isCountdownRunning = false;
      _remainingSeconds = _totalSeconds;
      _countdownDisplay = _formatCountdownTime(_remainingSeconds);
    });
  }

  void _showTimeUpDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.alarm, color: Colors.red, size: 30),
            SizedBox(width: 10),
            Text('¡Tiempo Terminado!'),
          ],
        ),
        content: Text('El temporizador ha llegado a cero.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _resetCountdown();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text('Entendido', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Métodos de la calculadora IMC
  void _calcularIMC() {
    final peso = double.tryParse(_pesoController.text.replaceAll(',', '.'));
    final alturaInput = double.tryParse(
      _alturaController.text.replaceAll(',', '.'),
    );

    if (peso != null && alturaInput != null && peso > 0 && alturaInput > 0) {
      // Convertir altura a metros si está en centímetros
      double alturaEnMetros;
      if (_unidadAltura == 'centímetros') {
        alturaEnMetros = alturaInput / 100;
      } else {
        alturaEnMetros = alturaInput;
      }

      setState(() {
        _imcCalculado = peso / (alturaEnMetros * alturaEnMetros);
        _categoriaIMC = _obtenerCategoriaIMC(
          _imcCalculado,
          _generoSeleccionado,
        );
        _colorIMC = _obtenerColorIMC(_imcCalculado);
        _mostrarResultado = true;
      });
    } else {
      _mostrarError();
    }
  }

  String _obtenerCategoriaIMC(double imc, String genero) {
    // Los rangos estándar del IMC son los mismos para ambos géneros
    // pero podemos incluir información adicional específica por género
    String categoria = '';

    if (imc < 18.5) {
      categoria = 'Bajo peso';
    } else if (imc < 25) {
      categoria = 'Peso normal';
    } else if (imc < 30) {
      categoria = 'Sobrepeso';
    } else if (imc < 35) {
      categoria = 'Obesidad grado I';
    } else if (imc < 40) {
      categoria = 'Obesidad grado II';
    } else {
      categoria = 'Obesidad grado III';
    }

    return categoria;
  }

  Color _obtenerColorIMC(double imc) {
    if (imc < 18.5) {
      return Colors.blue; // Bajo peso
    } else if (imc < 25) {
      return Colors.green; // Peso normal
    } else if (imc < 30) {
      return Colors.orange; // Sobrepeso
    } else if (imc < 35) {
      return Colors.red; // Obesidad grado I
    } else if (imc < 40) {
      return Colors.red[700]!; // Obesidad grado II
    } else {
      return Colors.red[900]!; // Obesidad grado III
    }
  }

  void _mostrarError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Por favor ingresa valores válidos'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _limpiarCampos() {
    setState(() {
      _pesoController.clear();
      _alturaController.clear();
      _mostrarResultado = false;
      _imcCalculado = 0.0;
      _categoriaIMC = '';
      _colorIMC = Colors.grey;
    });
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
          _getPageTitle(),
          style: AppTextStyles.appBarTitle.copyWith(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
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
            icon: Icon(Icons.alarm_outlined),
            selectedIcon: Icon(Icons.alarm, color: AppColors.primary),
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
          SizedBox(
            height: 160,
            child: PageView.builder(
              controller: PageController(viewportFraction: 0.85),
              itemCount: _carouselItems.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 8),
                  child: _buildCarouselCard(_carouselItems[index]),
                );
              },
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
                _buildMenuCard(
                  context,
                  icon: Icons.calendar_today,
                  title: 'Calendario',
                  subtitle: 'Ver entrenamientos programados',
                  onTap: () {
                    _navegarACalendario(context);
                  },
                ),
                _buildMenuCard(
                  context,
                  icon: Icons.fitness_center,
                  title: 'Mi Plan',
                  subtitle: 'Rutinas y ejercicios',
                  image: 'assets/img1.jpg',
                  onTap: () {
                    _navegarAMiPlan(context);
                  },
                ),
                _buildMenuCard(
                  context,
                  icon: Icons.show_chart,
                  title: 'Progreso',
                  subtitle: 'Ver mi evolución',
                  onTap: () {
                    _navegarAProgreso(context);
                  },
                ),
                _buildMenuCard(
                  context,
                  icon: Icons.person,
                  title: 'Mi Perfil',
                  subtitle: 'Datos personales',
                  onTap: () {
                    _navegarAPerfil(context);
                  },
                ),
                _buildMenuCard(
                  context,
                  icon: Icons.payment,
                  title: 'Pagos',
                  subtitle: 'Historial de pagos',
                  onTap: () {
                    _navegarAPagos(context);
                  },
                ),
                _buildMenuCard(
                  context,
                  icon: Icons.support_agent,
                  title: 'Soporte',
                  subtitle: 'Ayuda y contacto',
                  onTap: () {
                    _navegarASoporte(context);
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCronometroPage() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.horizontalPadding),
      child: Column(
        children: [
          SizedBox(height: 40),

          // Título con estilo moderno
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                // ignore: deprecated_member_use
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(
              'CRONÓMETRO',
              style: AppTextStyles.appBarTitle.copyWith(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),

          SizedBox(height: 60),

          // Display del tiempo con diseño circular
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.grey[100]!, Colors.white, Colors.grey[50]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 8,
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.white,
                  spreadRadius: -2,
                  blurRadius: 10,
                  offset: Offset(-5, -5),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icono del cronómetro
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isRunning ? Colors.green : AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (_isRunning ? Colors.green : AppColors.primary)
                              // ignore: deprecated_member_use
                              .withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(Icons.timer, color: Colors.white, size: 24),
                  ),

                  SizedBox(height: 20),

                  // Display del tiempo
                  Text(
                    _timeDisplay,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w300,
                      color: Colors.grey[800],
                      fontFamily: 'monospace',
                      letterSpacing: 2,
                    ),
                  ),

                  SizedBox(height: 8),

                  // Estado del cronómetro
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _isRunning
                          // ignore: deprecated_member_use
                          ? Colors.green.withOpacity(0.1)
                          // ignore: deprecated_member_use
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _isRunning ? 'EN MARCHA' : 'DETENIDO',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _isRunning ? Colors.green : Colors.grey[600],
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 80),

          // Botones de control con diseño moderno
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Botón Reset
              GestureDetector(
                onTap: _resetStopwatch,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      // ignore: deprecated_member_use
                      color: Colors.red.withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: Colors.red.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.refresh, color: Colors.red, size: 28),
                      SizedBox(height: 4),
                      Text(
                        'RESET',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Botón Start/Stop (más grande)
              GestureDetector(
                onTap: _startStopStopwatch,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _isRunning
                          // ignore: deprecated_member_use
                          ? [Colors.orange, Colors.orange.withOpacity(0.8)]
                          // ignore: deprecated_member_use
                          : [Colors.green, Colors.green.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (_isRunning ? Colors.orange : Colors.green)
                            // ignore: deprecated_member_use
                            .withOpacity(0.4),
                        spreadRadius: 3,
                        blurRadius: 15,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isRunning ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 36,
                      ),
                      SizedBox(height: 2),
                      Text(
                        _isRunning ? 'PAUSA' : 'INICIO',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Botón Lap (por ahora deshabilitado)
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: Colors.grey.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    // ignore: deprecated_member_use
                    color: Colors.grey.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.flag, color: Colors.grey, size: 28),
                    SizedBox(height: 4),
                    Text(
                      'LAP',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          Spacer(),

          // Indicador de precisión
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              // ignore: deprecated_member_use
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.precision_manufacturing,
                  color: Colors.blue,
                  size: 16,
                ),
                SizedBox(width: 8),
                Text(
                  'Precisión: 0.01 segundos',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTemporizadorPage() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.horizontalPadding),
      child: Column(
        children: [
          SizedBox(height: 20),

          // Título con estilo moderno
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                // ignore: deprecated_member_use
                colors: [Colors.orange, Colors.orange.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(
              'TEMPORIZADOR',
              style: AppTextStyles.appBarTitle.copyWith(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),

          SizedBox(height: 30),

          // Selectores de tiempo
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              children: [
                Text(
                  'Configurar Tiempo',
                  style: AppTextStyles.mainText.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Selector de minutos
                    Column(
                      children: [
                        Text(
                          'Minutos',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              // ignore: deprecated_member_use
                              color: Colors.orange.withOpacity(0.3),
                            ),
                          ),
                          child: DropdownButton<int>(
                            value: _selectedMinutes,
                            underline: SizedBox(),
                            items: List.generate(61, (index) {
                              return DropdownMenuItem<int>(
                                value: index,
                                child: Text(
                                  index.toString().padLeft(2, '0'),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              );
                            }),
                            onChanged: (value) {
                              setState(() {
                                _selectedMinutes = value!;
                                _updateCountdownDisplay();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    // Separador
                    Text(
                      ':',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    // Selector de segundos
                    Column(
                      children: [
                        Text(
                          'Segundos',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              // ignore: deprecated_member_use
                              color: Colors.orange.withOpacity(0.3),
                            ),
                          ),
                          child: DropdownButton<int>(
                            value: _selectedSecondsExtra,
                            underline: SizedBox(),
                            items: List.generate(60, (index) {
                              return DropdownMenuItem<int>(
                                value: index,
                                child: Text(
                                  index.toString().padLeft(2, '0'),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              );
                            }),
                            onChanged: (value) {
                              setState(() {
                                _selectedSecondsExtra = value!;
                                _updateCountdownDisplay();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 30),

          // Display del temporizador con diseño circular
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.orange[50]!, Colors.white, Colors.orange[100]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.orange.withOpacity(0.2),
                  spreadRadius: 8,
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.white,
                  spreadRadius: -2,
                  blurRadius: 10,
                  offset: Offset(-5, -5),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icono del temporizador
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isCountdownRunning ? Colors.red : Colors.orange,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color:
                              (_isCountdownRunning ? Colors.red : Colors.orange)
                              // ignore: deprecated_member_use
                              .withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(Icons.alarm, color: Colors.white, size: 24),
                  ),

                  SizedBox(height: 20),

                  // Display del tiempo
                  Text(
                    _countdownDisplay,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w300,
                      color: Colors.grey[800],
                      fontFamily: 'monospace',
                      letterSpacing: 3,
                    ),
                  ),

                  SizedBox(height: 12),

                  // Progreso visual
                  Container(
                    width: 160,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _totalSeconds > 0
                          ? _remainingSeconds / _totalSeconds
                          : 0,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.orange,
                              // ignore: deprecated_member_use
                              Colors.orange.withOpacity(0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 8),

                  // Estado del temporizador
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _isCountdownRunning
                          // ignore: deprecated_member_use
                          ? Colors.red.withOpacity(0.1)
                          // ignore: deprecated_member_use
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _isCountdownRunning ? 'CORRIENDO' : 'PAUSADO',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _isCountdownRunning
                            ? Colors.red
                            : Colors.grey[600],
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 40),

          // Botones de control
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Botón Reset
              GestureDetector(
                onTap: _resetCountdown,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.grey.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      // ignore: deprecated_member_use
                      color: Colors.grey.withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.refresh, color: Colors.grey[700], size: 28),
                      SizedBox(height: 4),
                      Text(
                        'RESET',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Botón Start/Stop (más grande)
              GestureDetector(
                onTap: _remainingSeconds > 0 ? _startStopCountdown : null,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: _remainingSeconds > 0
                        ? LinearGradient(
                            colors: _isCountdownRunning
                                // ignore: deprecated_member_use
                                ? [Colors.red, Colors.red.withOpacity(0.8)]
                                : [
                                    Colors.orange,
                                    // ignore: deprecated_member_use
                                    Colors.orange.withOpacity(0.8),
                                  ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : LinearGradient(
                            colors: [Colors.grey[400]!, Colors.grey[300]!],
                          ),
                    shape: BoxShape.circle,
                    boxShadow: _remainingSeconds > 0
                        ? [
                            BoxShadow(
                              color:
                                  (_isCountdownRunning
                                          ? Colors.red
                                          : Colors.orange)
                                      // ignore: deprecated_member_use
                                      .withOpacity(0.4),
                              spreadRadius: 3,
                              blurRadius: 15,
                              offset: Offset(0, 8),
                            ),
                          ]
                        : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isCountdownRunning ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 36,
                      ),
                      SizedBox(height: 2),
                      Text(
                        _isCountdownRunning ? 'PAUSA' : 'INICIO',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Botón de tiempos predefinidos
              GestureDetector(
                onTap: _showPresetTimes,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      // ignore: deprecated_member_use
                      color: Colors.blue.withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: Colors.blue.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.schedule, color: Colors.blue, size: 28),
                      SizedBox(height: 4),
                      Text(
                        'PRESETS',
                        style: TextStyle(
                          fontSize: 7,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          Spacer(),
        ],
      ),
    );
  }

  void _showPresetTimes() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tiempos Predefinidos'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('1 minuto'),
              onTap: () {
                _setPresetTime(1, 0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('3 minutos'),
              onTap: () {
                _setPresetTime(3, 0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('5 minutos'),
              onTap: () {
                _setPresetTime(5, 0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('10 minutos'),
              onTap: () {
                _setPresetTime(10, 0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('15 minutos'),
              onTap: () {
                _setPresetTime(15, 0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('30 minutos'),
              onTap: () {
                _setPresetTime(30, 0);
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _setPresetTime(int minutes, int seconds) {
    setState(() {
      _selectedMinutes = minutes;
      _selectedSecondsExtra = seconds;
      _updateCountdownDisplay();
      if (_countdownTimer?.isActive == true) {
        _countdownTimer?.cancel();
        _isCountdownRunning = false;
      }
    });
  }

  Widget _buildCalculadoraIMCPage() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.horizontalPadding),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),

            // Título con estilo moderno
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  // ignore: deprecated_member_use
                  colors: [Colors.purple, Colors.purple.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                'CALCULADORA IMC',
                style: AppTextStyles.appBarTitle.copyWith(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),

            SizedBox(height: 30),

            // Formulario de entrada
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.grey.withOpacity(0.15),
                    spreadRadius: 2,
                    blurRadius: 15,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título del formulario
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          // ignore: deprecated_member_use
                          color: Colors.purple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.calculate,
                          color: Colors.purple,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Datos Corporales',
                        style: AppTextStyles.mainText.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24),

                  // Campo de peso
                  Text(
                    'Peso (kg)',
                    style: AppTextStyles.contactText.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _pesoController,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Ej: 70.5',
                      prefixIcon: Icon(
                        Icons.monitor_weight,
                        color: Colors.purple,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.purple, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),

                  SizedBox(height: 20),

                  // Campo de altura
                  Row(
                    children: [
                      Text(
                        'Altura',
                        style: AppTextStyles.contactText.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(width: 10),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.purple[200]!),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.purple[50],
                        ),
                        child: DropdownButton<String>(
                          value: _unidadAltura,
                          isDense: true,
                          underline: SizedBox(),
                          items: [
                            DropdownMenuItem(
                              value: 'metros',
                              child: Text('m', style: TextStyle(fontSize: 12)),
                            ),
                            DropdownMenuItem(
                              value: 'centímetros',
                              child: Text('cm', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                          onChanged: (String? nuevaUnidad) {
                            setState(() {
                              _unidadAltura = nuevaUnidad!;
                              _alturaController
                                  .clear(); // Limpiar el campo al cambiar unidad
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _alturaController,
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      hintText: _unidadAltura == 'metros'
                          ? 'Ej: 1.75'
                          : 'Ej: 175',
                      prefixIcon: Icon(Icons.height, color: Colors.purple),
                      suffixText: _unidadAltura == 'metros' ? 'm' : 'cm',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.purple, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),

                  SizedBox(height: 20),

                  // Selector de género
                  Text(
                    'Género',
                    style: AppTextStyles.contactText.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[50],
                    ),
                    child: DropdownButton<String>(
                      value: _generoSeleccionado,
                      isExpanded: true,
                      underline: SizedBox(),
                      icon: Icon(Icons.arrow_drop_down, color: Colors.purple),
                      items: ['Masculino', 'Femenino'].map((String genero) {
                        return DropdownMenuItem<String>(
                          value: genero,
                          child: Row(
                            children: [
                              Icon(
                                genero == 'Masculino'
                                    ? Icons.male
                                    : Icons.female,
                                color: Colors.purple,
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Text(
                                genero,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (String? nuevoGenero) {
                        setState(() {
                          _generoSeleccionado = nuevoGenero!;
                          // Si ya se calculó el IMC, recalcular con el nuevo género
                          if (_mostrarResultado) {
                            _categoriaIMC = _obtenerCategoriaIMC(
                              _imcCalculado,
                              _generoSeleccionado,
                            );
                          }
                        });
                      },
                    ),
                  ),

                  SizedBox(height: 24),

                  // Botones
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _calcularIMC,
                          icon: Icon(Icons.calculate, size: 20),
                          label: Text(
                            'CALCULAR',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 1,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _limpiarCampos,
                        icon: Icon(Icons.clear, size: 20),
                        label: Text('LIMPIAR'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          foregroundColor: Colors.grey[700],
                          padding: EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Resultado del IMC
            if (_mostrarResultado)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    // ignore: deprecated_member_use
                    colors: [
                      // ignore: deprecated_member_use
                      _colorIMC.withOpacity(0.1),
                      // ignore: deprecated_member_use
                      _colorIMC.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  // ignore: deprecated_member_use
                  border: Border.all(
                    // ignore: deprecated_member_use
                    color: _colorIMC.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    // Icono del resultado
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: _colorIMC.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _obtenerIconoIMC(_imcCalculado),
                        color: _colorIMC,
                        size: 40,
                      ),
                    ),

                    SizedBox(height: 16),

                    // Valor del IMC
                    Text(
                      'Tu IMC es:',
                      style: AppTextStyles.contactText.copyWith(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),

                    SizedBox(height: 8),

                    Text(
                      _imcCalculado.toStringAsFixed(1),
                      style: AppTextStyles.appBarTitle.copyWith(
                        fontSize: 48,
                        fontWeight: FontWeight.w300,
                        color: _colorIMC,
                      ),
                    ),

                    SizedBox(height: 12),

                    // Categoría
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _colorIMC,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _categoriaIMC,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),

                    SizedBox(height: 16),

                    // Descripción adicional
                    Text(
                      _obtenerDescripcionIMC(
                        _imcCalculado,
                        _generoSeleccionado,
                      ),
                      style: AppTextStyles.contactText.copyWith(
                        color: Colors.grey[600],
                        fontSize: 14,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

            // Tabla de referencia IMC
            SizedBox(height: 24),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tabla de Referencia IMC',
                    style: AppTextStyles.mainText.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 12),
                  _buildTablaIMC(),
                ],
              ),
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  IconData _obtenerIconoIMC(double imc) {
    if (imc < 18.5) {
      return Icons.trending_down;
    } else if (imc < 25) {
      return Icons.check_circle;
    } else if (imc < 30) {
      return Icons.warning;
    } else {
      return Icons.error;
    }
  }

  String _obtenerDescripcionIMC(double imc, String genero) {
    String descripcionBase = '';
    String infoGenero = '';

    if (imc < 18.5) {
      descripcionBase =
          'Es recomendable consultar con un profesional de la salud para evaluar tu estado nutricional.';
      if (genero == 'Femenino') {
        infoGenero =
            ' Las mujeres pueden necesitar mayor atención a la densidad ósea y niveles de hierro.';
      } else {
        infoGenero =
            ' Los hombres pueden enfocarse en ganar masa muscular de forma saludable.';
      }
    } else if (imc < 25) {
      descripcionBase =
          '¡Felicitaciones! Tu peso está dentro del rango saludable.';
      if (genero == 'Femenino') {
        infoGenero =
            ' Mantén tus hábitos alimenticios y considera ejercicios de fuerza para la salud ósea.';
      } else {
        infoGenero =
            ' Mantén tus hábitos alimenticios y rutina de ejercicio regular.';
      }
    } else if (imc < 30) {
      descripcionBase =
          'Considera adoptar hábitos más saludables como ejercicio regular y una dieta balanceada.';
      if (genero == 'Femenino') {
        infoGenero =
            ' Las mujeres pueden beneficiarse de ejercicios cardiovasculares y de resistencia.';
      } else {
        infoGenero =
            ' Los hombres pueden enfocarse en entrenamiento de fuerza y cardio.';
      }
    } else {
      descripcionBase =
          'Te recomendamos consultar con un profesional de la salud para un plan personalizado.';
      if (genero == 'Femenino') {
        infoGenero =
            ' Considera evaluaciones hormonales y planes nutricionales específicos.';
      } else {
        infoGenero =
            ' Un enfoque integral con dieta, ejercicio y seguimiento médico es clave.';
      }
    }

    return descripcionBase + infoGenero;
  }

  Widget _buildTablaIMC() {
    return Column(
      children: [
        _buildFilaTabla('Bajo peso', '< 18.5', Colors.blue),
        _buildFilaTabla('Peso normal', '18.5 - 24.9', Colors.green),
        _buildFilaTabla('Sobrepeso', '25.0 - 29.9', Colors.orange),
        _buildFilaTabla('Obesidad I', '30.0 - 34.9', Colors.red),
        _buildFilaTabla('Obesidad II', '35.0 - 39.9', Colors.red[700]!),
        _buildFilaTabla('Obesidad III', '≥ 40.0', Colors.red[900]!),
      ],
    );
  }

  Widget _buildFilaTabla(String categoria, String rango, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              categoria,
              style: AppTextStyles.contactText.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            rango,
            style: AppTextStyles.contactText.copyWith(
              fontSize: 13,
              color: Colors.grey[600],
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    String? image,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
          border: Border.all(color: Colors.grey[200]!),
          image: image != null
              ? DecorationImage(image: AssetImage(image), fit: BoxFit.cover)
              : null,
        ),
        child: Container(
          decoration: image != null
              ? BoxDecoration(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(
                    0.3,
                  ), // Overlay semitransparente
                  borderRadius: BorderRadius.circular(15),
                )
              : null,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              image == null
                  ? Icon(icon, size: 40, color: AppColors.primary)
                  : SizedBox.shrink(),
              SizedBox(height: image == null ? 12 : 8),
              Text(
                title,
                style: AppTextStyles.contactText.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: image != null ? Colors.white : null,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTextStyles.contactText.copyWith(
                  fontSize: 12,
                  color: image != null ? Colors.white : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCarouselCard(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () => _handleCarouselTap(item['onTap']),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [item['color'], item['color'].withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: item['color'].withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(item['icon'], size: 24, color: Colors.white),
                  ),
                  SizedBox(height: 12),
                  Text(
                    item['title'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    item['subtitle'],
                    style: TextStyle(
                      // ignore: deprecated_member_use
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Ver más',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(Icons.arrow_forward, size: 12, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleCarouselTap(String action) {
    String message = '';
    switch (action) {
      case 'entrenamientos':
        message = 'Sección "Entrenamientos" en desarrollo...';
        break;
      case 'nutricion':
        message = 'Sección "Nutrición" en desarrollo...';
        break;
      case 'logros':
        message = 'Sección "Logros" en desarrollo...';
        break;
      case 'clases':
        message = 'Sección "Clases" en desarrollo...';
        break;
      case 'mensajes':
        message = 'Sección "Mensajes" en desarrollo...';
        break;
      default:
        message = 'Función en desarrollo...';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Función "Mi Plan" en desarrollo...'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _navegarAProgreso(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Función "Progreso" en desarrollo...'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _navegarAPerfil(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Función "Mi Perfil" en desarrollo...'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _navegarAPagos(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Función "Pagos" en desarrollo...'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _navegarASoporte(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Función "Soporte" en desarrollo...'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
