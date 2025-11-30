import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../constants.dart';

class CalendarioScreen extends StatefulWidget {
  final String nombreUsuario;

  const CalendarioScreen({super.key, required this.nombreUsuario});

  @override
  State<CalendarioScreen> createState() => _CalendarioScreenState();
}

class _CalendarioScreenState extends State<CalendarioScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();
  String _selectedView = 'mes'; // día, semana, mes

  final Map<DateTime, List<Map<String, dynamic>>> _events = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarEventos();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          centerTitle: true,
          toolbarHeight: 80.0,
          title: Text(
            'Calendario',
            style: AppTextStyles.appBarTitle.copyWith(color: Colors.white),
          ),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 80.0,
        title: Text(
          'Calendario',
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
            icon: Icon(Icons.add_circle_outline, color: Colors.white, size: 28),
            onPressed: () {
              _mostrarAgregarEvento();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header con filtros de vista
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Navegación de mes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _currentMonth = DateTime(
                            _currentMonth.year,
                            _currentMonth.month - 1,
                          );
                        });
                      },
                      icon: Icon(Icons.chevron_left, color: AppColors.primary),
                    ),
                    Text(
                      _formatMonthYear(_currentMonth),
                      style: AppTextStyles.mainText.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _currentMonth = DateTime(
                            _currentMonth.year,
                            _currentMonth.month + 1,
                          );
                        });
                      },
                      icon: Icon(Icons.chevron_right, color: AppColors.primary),
                    ),
                  ],
                ),

                SizedBox(height: 16),

                // Filtros de vista
                Row(
                  children: [
                    Expanded(child: _buildViewButton('día', 'Día')),
                    SizedBox(width: 8),
                    Expanded(child: _buildViewButton('semana', 'Semana')),
                    SizedBox(width: 8),
                    Expanded(child: _buildViewButton('mes', 'Mes')),
                  ],
                ),
              ],
            ),
          ),

          // Contenido del calendario
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: _buildCalendarView(),
            ),
          ),
        ],
      ),

      // Botón flotante para agregar evento
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _mostrarAgregarEvento();
        },
        backgroundColor: AppColors.primary,
        icon: Icon(Icons.add, color: Colors.white),
        label: Text('Agregar Evento', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildViewButton(String view, String label) {
    bool isSelected = _selectedView == view;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedView = view;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey[100],
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.contactText.copyWith(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildCalendarView() {
    switch (_selectedView) {
      case 'día':
        return _buildDayView();
      case 'semana':
        return _buildWeekView();
      case 'mes':
      default:
        return _buildMonthView();
    }
  }

  Widget _buildDayView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selector de día
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedDate = _selectedDate.subtract(Duration(days: 1));
                  });
                },
                icon: Icon(Icons.chevron_left, color: AppColors.primary),
              ),
              Text(
                _formatDateComplete(_selectedDate),
                style: AppTextStyles.mainText.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedDate = _selectedDate.add(Duration(days: 1));
                  });
                },
                icon: Icon(Icons.chevron_right, color: AppColors.primary),
              ),
            ],
          ),
        ),

        SizedBox(height: 20),

        // Eventos del día
        Expanded(child: _buildDayEvents()),
      ],
    );
  }

  Widget _buildWeekView() {
    DateTime startOfWeek = _selectedDate.subtract(
      Duration(days: _selectedDate.weekday - 1),
    );

    return Column(
      children: [
        // Días de la semana
        Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: List.generate(7, (index) {
              DateTime day = startOfWeek.add(Duration(days: index));
              bool isSelected = _isSameDay(day, _selectedDate);
              bool hasEvents = _getEventsForDate(day).isNotEmpty;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = day;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    padding: EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: hasEvents
                            ? AppColors.primary
                            : Colors.grey[300]!,
                        width: hasEvents ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _getDayName(day.weekday),
                          style: AppTextStyles.contactText.copyWith(
                            fontSize: 12,
                            color: isSelected ? Colors.white : Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          day.day.toString(),
                          style: AppTextStyles.contactText.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : AppColors.primary,
                          ),
                        ),
                        if (hasEvents) ...[
                          SizedBox(height: 4),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.primary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        SizedBox(height: 16),

        // Eventos de toda la semana
        Expanded(child: _buildWeekEvents()),
      ],
    );
  }

  Widget _buildMonthView() {
    return Column(
      children: [
        // Días de la semana header
        Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: ['L', 'M', 'M', 'J', 'V', 'S', 'D']
                .map(
                  (day) => Expanded(
                    child: Text(
                      day,
                      style: AppTextStyles.contactText.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
                .toList(),
          ),
        ),

        // Calendario del mes
        SizedBox(height: 350, child: _buildMonthGrid()),

        SizedBox(height: 15),

        // Eventos del mes completo
        Expanded(child: _buildMonthEvents()),
      ],
    );
  }

  Widget _buildMonthGrid() {
    DateTime firstDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    );
    DateTime lastDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    );
    int startWeekday = firstDayOfMonth.weekday;
    int daysInMonth = lastDayOfMonth.day;

    List<Widget> dayWidgets = [];

    // Días vacíos al inicio
    for (int i = 1; i < startWeekday; i++) {
      dayWidgets.add(Container());
    }

    // Días del mes
    for (int day = 1; day <= daysInMonth; day++) {
      DateTime date = DateTime(_currentMonth.year, _currentMonth.month, day);
      bool isSelected = _isSameDay(date, _selectedDate);
      bool isToday = _isSameDay(date, DateTime.now());
      bool hasEvents = _getEventsForDate(date).isNotEmpty;

      dayWidgets.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = date;
            });
          },
          child: Container(
            margin: EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : isToday
                  // ignore: deprecated_member_use
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: hasEvents
                  ? Border.all(color: AppColors.primary, width: 1)
                  : null,
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    day.toString(),
                    style: AppTextStyles.contactText.copyWith(
                      color: isSelected
                          ? Colors.white
                          : isToday
                          ? AppColors.primary
                          : Colors.black,
                      fontWeight: isSelected || isToday
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
                if (hasEvents && !isSelected)
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return GridView.count(crossAxisCount: 7, children: dayWidgets);
  }

  Widget _buildDayEvents() {
    List<Map<String, dynamic>> dayEvents = _getEventsForDate(_selectedDate);

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Eventos para ${_formatDate(_selectedDate)}',
            style: AppTextStyles.mainText.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Expanded(
            child: dayEvents.isNotEmpty
                ? ListView.builder(
                    itemCount: dayEvents.length,
                    itemBuilder: (context, index) {
                      final event = dayEvents[index];
                      return _buildEventCard(event, false);
                    },
                  )
                : _buildEmptyStateForDay(),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event, bool isFullCard) {
    Color eventColor = _getEventColor(event['type']);

    return Container(
      margin: EdgeInsets.only(bottom: isFullCard ? 12 : 8),
      padding: EdgeInsets.all(isFullCard ? 16 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // ignore: deprecated_member_use
        border: Border.all(color: eventColor.withOpacity(0.3)),
        boxShadow: isFullCard
            ? [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: isFullCard ? 40 : 30,
            decoration: BoxDecoration(
              color: eventColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title'],
                  style: AppTextStyles.contactText.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: isFullCard ? 16 : 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  event['time'],
                  style: AppTextStyles.contactText.copyWith(
                    color: Colors.grey[600],
                    fontSize: isFullCard ? 14 : 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            _getEventIcon(event['type']),
            color: eventColor,
            size: isFullCard ? 24 : 20,
          ),
          SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              _eliminarEvento(event, _selectedDate);
            },
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: isFullCard ? 20 : 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekEvents() {
    DateTime startOfWeek = _selectedDate.subtract(
      Duration(days: _selectedDate.weekday - 1),
    );
    List<Map<String, dynamic>> weekEvents = _getEventsForWeek(startOfWeek);

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Eventos de esta semana',
            style: AppTextStyles.mainText.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Expanded(
            child: weekEvents.isNotEmpty
                ? ListView.builder(
                    itemCount: weekEvents.length,
                    itemBuilder: (context, index) {
                      final event = weekEvents[index];
                      return Column(
                        children: [
                          _buildEventWithDate(event),
                          if (index < weekEvents.length - 1)
                            SizedBox(height: 8),
                        ],
                      );
                    },
                  )
                : Center(
                    child: Text(
                      'No hay eventos para esta semana',
                      style: AppTextStyles.contactText.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthEvents() {
    List<Map<String, dynamic>> monthEvents = _getEventsForMonth(_currentMonth);

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Eventos de ${_formatMonthYear(_currentMonth)}',
            style: AppTextStyles.mainText.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Expanded(
            child: monthEvents.isNotEmpty
                ? ListView.builder(
                    itemCount: monthEvents.length,
                    itemBuilder: (context, index) {
                      final event = monthEvents[index];
                      return Column(
                        children: [
                          _buildEventWithDate(event),
                          if (index < monthEvents.length - 1)
                            SizedBox(height: 8),
                        ],
                      );
                    },
                  )
                : Center(
                    child: Text(
                      'No hay eventos para este mes',
                      style: AppTextStyles.contactText.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventWithDate(Map<String, dynamic> event) {
    Color eventColor = _getEventColor(event['type']);
    DateTime eventDate = event['date'];

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // ignore: deprecated_member_use
        border: Border.all(color: eventColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 30,
            decoration: BoxDecoration(
              color: eventColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 12),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: eventColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${eventDate.day}/${eventDate.month}',
              style: AppTextStyles.contactText.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: eventColor,
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title'],
                  style: AppTextStyles.contactText.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  event['time'],
                  style: AppTextStyles.contactText.copyWith(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(_getEventIcon(event['type']), color: eventColor, size: 20),
          SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              _eliminarEvento(event, eventDate);
            },
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.delete_outline, color: Colors.red, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateForDay() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_available, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'No tienes eventos para este día',
            style: AppTextStyles.contactText.copyWith(
              color: Colors.grey[600],
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              _mostrarAgregarEvento();
            },
            icon: Icon(Icons.add, color: Colors.white),
            label: Text(
              'Agregar Evento',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Color _getEventColor(String type) {
    switch (type) {
      case 'workout':
        return Colors.blue;
      case 'cardio':
        return Colors.red;
      case 'functional':
        return Colors.green;
      case 'evaluation':
        return Colors.orange;
      default:
        return AppColors.primary;
    }
  }

  IconData _getEventIcon(String type) {
    switch (type) {
      case 'workout':
        return Icons.fitness_center;
      case 'cardio':
        return Icons.directions_run;
      case 'functional':
        return Icons.sports_gymnastics;
      case 'evaluation':
        return Icons.assessment;
      default:
        return Icons.event;
    }
  }

  List<Map<String, dynamic>> _getEventsForDate(DateTime date) {
    return _events[DateTime(date.year, date.month, date.day)] ?? [];
  }

  List<Map<String, dynamic>> _getEventsForMonth(DateTime month) {
    List<Map<String, dynamic>> monthEvents = [];
    DateTime firstDay = DateTime(month.year, month.month, 1);
    DateTime lastDay = DateTime(month.year, month.month + 1, 0);

    for (
      DateTime date = firstDay;
      date.isBefore(lastDay.add(Duration(days: 1)));
      date = date.add(Duration(days: 1))
    ) {
      List<Map<String, dynamic>> dayEvents = _getEventsForDate(date);
      for (var event in dayEvents) {
        monthEvents.add({...event, 'date': date});
      }
    }

    // Ordenar por fecha y luego por hora
    monthEvents.sort((a, b) {
      int dateCompare = (a['date'] as DateTime).compareTo(
        b['date'] as DateTime,
      );
      if (dateCompare != 0) return dateCompare;

      // Comparar por hora si es la misma fecha
      String timeA = a['time'].toString().toLowerCase();
      String timeB = b['time'].toString().toLowerCase();
      return timeA.compareTo(timeB);
    });

    return monthEvents;
  }

  List<Map<String, dynamic>> _getEventsForWeek(DateTime weekStart) {
    List<Map<String, dynamic>> weekEvents = [];

    for (int i = 0; i < 7; i++) {
      DateTime date = weekStart.add(Duration(days: i));
      List<Map<String, dynamic>> dayEvents = _getEventsForDate(date);
      for (var event in dayEvents) {
        weekEvents.add({...event, 'date': date});
      }
    }

    // Ordenar por fecha y luego por hora
    weekEvents.sort((a, b) {
      int dateCompare = (a['date'] as DateTime).compareTo(
        b['date'] as DateTime,
      );
      if (dateCompare != 0) return dateCompare;

      String timeA = a['time'].toString().toLowerCase();
      String timeB = b['time'].toString().toLowerCase();
      return timeA.compareTo(timeB);
    });

    return weekEvents;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatMonthYear(DateTime date) {
    final months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatDate(DateTime date) {
    final months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return '${date.day} de ${months[date.month - 1]}';
  }

  String _formatDateComplete(DateTime date) {
    final months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    final weekdays = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
    ];
    return '${weekdays[date.weekday - 1]}, ${date.day} de ${months[date.month - 1]}';
  }

  String _getDayName(int weekday) {
    const days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    return days[weekday - 1];
  }

  // Métodos para guardar y cargar eventos localmente
  Future<void> _cargarEventos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? eventosJson = prefs.getString(
        'eventos_${widget.nombreUsuario}',
      );

      if (eventosJson != null) {
        final Map<String, dynamic> eventosData = json.decode(eventosJson);

        setState(() {
          _events.clear();
          eventosData.forEach((dateString, eventsList) {
            final DateTime date = DateTime.parse(dateString);
            _events[date] = List<Map<String, dynamic>>.from(
              (eventsList as List).map((e) => Map<String, dynamic>.from(e)),
            );
          });
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error cargando eventos: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _guardarEventos() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Convertir el mapa de eventos a un formato serializable
      final Map<String, dynamic> eventosData = {};
      _events.forEach((date, eventsList) {
        eventosData[date.toIso8601String()] = eventsList;
      });

      final String eventosJson = json.encode(eventosData);
      await prefs.setString('eventos_${widget.nombreUsuario}', eventosJson);
    } catch (e) {
      print('Error guardando eventos: $e');
    }
  }

  void _eliminarEvento(Map<String, dynamic> evento, DateTime fecha) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Eliminar Evento',
          style: AppTextStyles.mainText.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${evento['title']}"?',
          style: AppTextStyles.contactText,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                DateTime eventDate = DateTime(
                  fecha.year,
                  fecha.month,
                  fecha.day,
                );
                if (_events[eventDate] != null) {
                  _events[eventDate]!.removeWhere(
                    (e) =>
                        e['title'] == evento['title'] &&
                        e['time'] == evento['time'] &&
                        e['type'] == evento['type'],
                  );
                  if (_events[eventDate]!.isEmpty) {
                    _events.remove(eventDate);
                  }
                }
              });
              _guardarEventos(); // Guardar después de eliminar
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Evento eliminado exitosamente'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _mostrarAgregarEvento() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController timeController = TextEditingController();
    String selectedType = 'workout';
    DateTime selectedDate = _selectedDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            'Agregar Evento',
            style: AppTextStyles.mainText.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Título del evento',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: timeController,
                  decoration: InputDecoration(
                    labelText: 'Hora (ej: 10:00 AM)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedType,
                  decoration: InputDecoration(
                    labelText: 'Tipo de evento',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'workout',
                      child: Text('Entrenamiento'),
                    ),
                    DropdownMenuItem(value: 'cardio', child: Text('Cardio')),
                    DropdownMenuItem(
                      value: 'functional',
                      child: Text('Funcional'),
                    ),
                    DropdownMenuItem(
                      value: 'evaluation',
                      child: Text('Evaluación'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      selectedType = value;
                    }
                  },
                ),
                SizedBox(height: 16),
                ListTile(
                  title: Text('Fecha: ${_formatDate(selectedDate)}'),
                  trailing: Icon(
                    Icons.calendar_today,
                    color: AppColors.primary,
                  ),
                  onTap: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                    );
                    if (pickedDate != null) {
                      setDialogState(() {
                        selectedDate = pickedDate;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty &&
                    timeController.text.isNotEmpty) {
                  setState(() {
                    DateTime eventDate = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                    );
                    if (_events[eventDate] == null) {
                      _events[eventDate] = [];
                    }
                    _events[eventDate]!.add({
                      'title': titleController.text,
                      'time': timeController.text,
                      'type': selectedType,
                    });
                  });
                  _guardarEventos(); // Guardar después de agregar
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Evento agregado exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: Text('Agregar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
