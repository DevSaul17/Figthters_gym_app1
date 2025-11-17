import 'package:flutter/material.dart';
import 'dart:async';
import '../../../constants.dart';

class CronometroWidget extends StatefulWidget {
  const CronometroWidget({super.key});

  @override
  State<CronometroWidget> createState() => _CronometroWidgetState();
}

class _CronometroWidgetState extends State<CronometroWidget> {
  late Stopwatch _stopwatch;
  late Timer _timer;
  bool _isRunning = false;
  String _timeDisplay = "00:00:00";

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    _timer = Timer.periodic(Duration(milliseconds: 10), _updateTime);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateTime(Timer timer) {
    if (_stopwatch.isRunning) {
      setState(() {
        final elapsed = _stopwatch.elapsed;
        final minutes = elapsed.inMinutes.toString().padLeft(2, '0');
        final seconds = (elapsed.inSeconds % 60).toString().padLeft(2, '0');
        final centiseconds = ((elapsed.inMilliseconds % 1000) ~/ 10)
            .toString()
            .padLeft(2, '0');
        _timeDisplay = "$minutes:$seconds:$centiseconds";
      });
    }
  }

  void _startStopStopwatch() {
    setState(() {
      if (_isRunning) {
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
      _isRunning = false;
      _timeDisplay = "00:00:00";
    });
  }

  @override
  Widget build(BuildContext context) {
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

          // Usar Expanded para el contenido principal
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Display del tiempo con diseño circular
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.grey[100]!,
                        Colors.white,
                        Colors.grey[50]!,
                      ],
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
                            color: _isRunning
                                ? Colors.green
                                : AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    (_isRunning
                                            ? Colors.green
                                            : AppColors.primary)
                                        // ignore: deprecated_member_use
                                        .withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.timer,
                            color: Colors.white,
                            size: 24,
                          ),
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
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
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
                              color: _isRunning
                                  ? Colors.green
                                  : Colors.grey[600],
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

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
                                ? [
                                    Colors.orange,
                                    // ignore: deprecated_member_use
                                    Colors.orange.withOpacity(0.8),
                                  ]
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
              ],
            ),
          ),

          SizedBox(height: 10),
        ],
      ),
    );
  }
}
