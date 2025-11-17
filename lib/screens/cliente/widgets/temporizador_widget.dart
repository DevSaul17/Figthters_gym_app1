import 'package:flutter/material.dart';
import 'dart:async';
import '../../../constants.dart';

class TemporizadorWidget extends StatefulWidget {
  const TemporizadorWidget({super.key});

  @override
  State<TemporizadorWidget> createState() => _TemporizadorWidgetState();
}

class _TemporizadorWidgetState extends State<TemporizadorWidget> {
  Timer? _countdownTimer;
  bool _isCountdownRunning = false;
  int _totalSeconds = 0;
  int _remainingSeconds = 0;
  String _countdownDisplay = "00:00";
  int _selectedMinutes = 5;
  int _selectedSecondsExtra = 0;

  @override
  void initState() {
    super.initState();
    // Inicializar temporizador con 5 minutos por defecto
    _selectedMinutes = 5;
    _selectedSecondsExtra = 0;
    _updateCountdownDisplay();
  }

  @override
  void dispose() {
    if (_countdownTimer?.isActive == true) {
      _countdownTimer?.cancel();
    }
    super.dispose();
  }

  void _updateCountdownDisplay() {
    _totalSeconds = (_selectedMinutes * 60) + _selectedSecondsExtra;
    _remainingSeconds = _totalSeconds;
    _countdownDisplay = _formatCountdownTime(_remainingSeconds);
  }

  String _formatCountdownTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
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
            (timer) => _updateCountdown(timer),
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
      builder: (context) => AlertDialog(
        title: Text('¡Tiempo terminado!'),
        content: Text('El temporizador ha llegado a cero.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
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
            _buildPresetButton('1 min', 1, 0),
            _buildPresetButton('3 min', 3, 0),
            _buildPresetButton('5 min', 5, 0),
            _buildPresetButton('10 min', 10, 0),
            _buildPresetButton('15 min', 15, 0),
            _buildPresetButton('30 min', 30, 0),
            _buildPresetButton('45 min', 45, 0),
            _buildPresetButton('1 hora', 60, 0),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetButton(String label, int minutes, int seconds) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pop();
          _setPresetTime(minutes, seconds);
        },
        child: Text(label),
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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

          SizedBox(height: 20),

          // Selectores de tiempo
          Container(
            padding: EdgeInsets.all(16),
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
                SizedBox(height: 16),
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
                                    fontSize: 16,
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
                                    fontSize: 16,
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

          SizedBox(height: 20),

          // Botón de tiempos predefinidos
          TextButton(
            onPressed: _showPresetTimes,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                // ignore: deprecated_member_use
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Text(
                'Tiempos Predefinidos ⚡',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          SizedBox(height: 20),

          // Display del temporizador
          Container(
            width: 250,
            height: 250,
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

                  SizedBox(height: 16),

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
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      // ignore: deprecated_member_use
                      color: Colors.red.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.refresh, color: Colors.red, size: 24),
                      SizedBox(height: 2),
                      Text(
                        'RESET',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Botón Start/Stop
              GestureDetector(
                onTap: _startStopCountdown,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _isCountdownRunning
                          // ignore: deprecated_member_use
                          ? [Colors.red, Colors.red.withOpacity(0.8)]
                          // ignore: deprecated_member_use
                          : [Colors.orange, Colors.orange.withOpacity(0.8)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isCountdownRunning ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 32,
                      ),
                      SizedBox(height: 2),
                      Text(
                        _isCountdownRunning ? 'PAUSA' : 'INICIO',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Botón configurar
              GestureDetector(
                onTap: _showPresetTimes,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      // ignore: deprecated_member_use
                      color: Colors.blue.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.settings, color: Colors.blue, size: 24),
                      SizedBox(height: 2),
                      Text(
                        'CONFIG',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 20),
        ],
      ),
    );
  }
}
