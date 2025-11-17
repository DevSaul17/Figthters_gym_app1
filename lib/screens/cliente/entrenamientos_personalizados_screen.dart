import 'package:flutter/material.dart';
import '../../constants.dart';

class TareaGym {
  String id;
  String titulo;
  String descripcion;
  String categoria;
  bool completada;
  DateTime fechaCreacion;
  DateTime fechaProgramada; // Nueva propiedad para la fecha programada
  Color color;
  IconData icono;

  TareaGym({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.categoria,
    this.completada = false,
    required this.fechaCreacion,
    required this.fechaProgramada,
    required this.color,
    required this.icono,
  });
}

class EntrenamientosPersonalizadosScreen extends StatefulWidget {
  final String nombreUsuario;

  const EntrenamientosPersonalizadosScreen({
    super.key,
    required this.nombreUsuario,
  });

  @override
  // ignore: library_private_types_in_public_api
  _EntrenamientosPersonalizadosScreenState createState() =>
      _EntrenamientosPersonalizadosScreenState();
}

class _EntrenamientosPersonalizadosScreenState
    extends State<EntrenamientosPersonalizadosScreen> {
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  String _categoriaSeleccionada = 'Entrenamiento';
  DateTime _fechaSeleccionada = DateTime.now();

  // Nuevas variables para filtros y vistas
  int _vistaActual = 0; // 0: Hoy, 1: Esta Semana, 2: Completadas
  DateTime _fechaFiltro = DateTime.now();

  final List<String> _tiposVista = ['Hoy', 'Esta Semana', 'Completadas'];

  final List<String> _categorias = [
    'Entrenamiento',
    'Nutrición',
    'Cardio',
    'Fuerza',
    'Flexibilidad',
    'Descanso',
  ];

  final List<Color> _colores = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.indigo,
    Colors.pink,
  ];

  final List<IconData> _iconos = [
    Icons.fitness_center,
    Icons.directions_run,
    Icons.restaurant_menu,
    Icons.self_improvement,
    Icons.timer,
    Icons.favorite,
    Icons.local_fire_department,
    Icons.stars,
  ];

  List<TareaGym> _tareas = [];

  @override
  void initState() {
    super.initState();
    _inicializarTareas();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  void _inicializarTareas() {
    final hoy = DateTime.now();
    final manana = DateTime(hoy.year, hoy.month, hoy.day + 1);

    _tareas = [
      TareaGym(
        id: '1',
        titulo: 'Rutina de Pecho y Tríceps',
        descripcion: '4 series de press de banca, 3 series de flexiones',
        categoria: 'Fuerza',
        fechaCreacion: hoy,
        fechaProgramada: hoy,
        color: Colors.red,
        icono: Icons.fitness_center,
      ),
      TareaGym(
        id: '2',
        titulo: 'Cardio matutino',
        descripcion: '30 minutos de caminata rápida',
        categoria: 'Cardio',
        fechaCreacion: hoy,
        fechaProgramada: hoy,
        color: Colors.blue,
        icono: Icons.directions_run,
      ),
      TareaGym(
        id: '3',
        titulo: 'Estiramientos',
        descripcion: '15 minutos de yoga y flexibilidad',
        categoria: 'Flexibilidad',
        fechaCreacion: hoy,
        fechaProgramada: manana,
        color: Colors.green,
        icono: Icons.self_improvement,
      ),
      TareaGym(
        id: '4',
        titulo: 'Beber 2L de agua',
        descripcion: 'Mantener hidratación durante el día',
        categoria: 'Nutrición',
        fechaCreacion: hoy,
        fechaProgramada: hoy,
        color: Colors.teal,
        icono: Icons.local_drink,
        completada: true,
      ),
    ];
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'TAREAS DE GIMNASIO',
          style: AppTextStyles.appBarTitle.copyWith(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white, size: 28),
            onPressed: _mostrarDialogoAgregarTarea,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            // Mensaje de bienvenida
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
                  Icon(Icons.task_alt, size: 50, color: AppColors.primary),
                  SizedBox(height: 15),
                  Text(
                    '¡Hola ${widget.nombreUsuario}!',
                    style: AppTextStyles.mainText.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Organiza tus metas y tareas del gimnasio',
                    style: AppTextStyles.contactText.copyWith(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            // Filtros de vista
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _tiposVista.length,
                itemBuilder: (context, index) {
                  final esSeleccionado = _vistaActual == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _vistaActual = index;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 15),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: esSeleccionado
                            ? AppColors.primary
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Text(
                          _tiposVista[index],
                          style: TextStyle(
                            color: esSeleccionado
                                ? Colors.white
                                : Colors.grey[600],
                            fontWeight: esSeleccionado
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            // Estadísticas rápidas
            Row(
              children: [
                Expanded(
                  child: _buildEstadisticaCard(
                    'Total',
                    '${_obtenerTareasFiltradas().length}',
                    Icons.list_alt,
                    Colors.blue,
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: _buildEstadisticaCard(
                    'Completadas',
                    '${_obtenerTareasFiltradas().where((t) => t.completada).length}',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: _buildEstadisticaCard(
                    'Pendientes',
                    '${_obtenerTareasFiltradas().where((t) => !t.completada).length}',
                    Icons.pending,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),

            // Título de la sección con fecha
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _obtenerTituloSeccion(),
                  style: AppTextStyles.mainText.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                if (_vistaActual !=
                    2) // No mostrar selector de fecha para completadas
                  IconButton(
                    onPressed: () => _seleccionarFecha(context),
                    icon: Icon(Icons.calendar_today, color: AppColors.primary),
                  ),
              ],
            ),

            SizedBox(height: 20),

            // Lista de tareas
            _construirListaTareas(),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadisticaCard(
    String titulo,
    String valor,
    IconData icono,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icono, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            valor,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(titulo, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildListaVacia() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, size: 60, color: Colors.grey[400]),
            SizedBox(height: 15),
            Text(
              'No tienes tareas aún',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Toca el botón + para agregar tu primera tarea',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTareaCard(TareaGym tarea, int index, {bool esFiltrada = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: tarea.completada
            ? Border.all(color: Colors.green, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Dismissible(
        key: Key(tarea.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(15),
          ),
          padding: EdgeInsets.only(right: 20),
          child: Icon(Icons.delete, color: Colors.white, size: 30),
        ),
        onDismissed: (direction) {
          _eliminarTarea(index, esFiltrada: esFiltrada);
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  // Checkbox para completar
                  GestureDetector(
                    onTap: () =>
                        _toggleCompletarTarea(index, esFiltrada: esFiltrada),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: tarea.completada ? Colors.green : Colors.grey,
                          width: 2,
                        ),
                        color: tarea.completada
                            ? Colors.green
                            : Colors.transparent,
                      ),
                      child: tarea.completada
                          ? Icon(Icons.check, color: Colors.white, size: 16)
                          : null,
                    ),
                  ),
                  SizedBox(width: 15),
                  // Icono colorido
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: tarea.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(tarea.icono, color: tarea.color, size: 25),
                  ),
                  SizedBox(width: 15),
                  // Información de la tarea
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tarea.titulo,
                          style: AppTextStyles.mainText.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: tarea.completada
                                ? Colors.grey
                                : AppColors.primary,
                            decoration: tarea.completada
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          tarea.descripcion,
                          style: AppTextStyles.contactText.copyWith(
                            fontSize: 12,
                            color: tarea.completada
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                // ignore: deprecated_member_use
                                color: tarea.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                tarea.categoria,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: tarea.color,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                // ignore: deprecated_member_use
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${tarea.fechaProgramada.day}/${tarea.fechaProgramada.month}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Botón de editar
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.grey[400], size: 20),
                    onPressed: () => _mostrarDialogoEditarTarea(index),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleCompletarTarea(int index, {bool esFiltrada = false}) {
    if (esFiltrada) {
      // Obtener la tarea de la lista filtrada
      final tareasFiltradas = _obtenerTareasFiltradas();
      if (index >= tareasFiltradas.length) return;

      final tareaFiltrada = tareasFiltradas[index];
      final indexReal = _tareas.indexWhere((t) => t.id == tareaFiltrada.id);

      if (indexReal != -1) {
        setState(() {
          _tareas[indexReal].completada = !_tareas[indexReal].completada;
        });
      }
    } else {
      setState(() {
        _tareas[index].completada = !_tareas[index].completada;
      });
    }

    final tarea = esFiltrada
        ? _obtenerTareasFiltradas()[index]
        : _tareas[index];

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          tarea.completada
              ? '¡Tarea completada! 🎉'
              : 'Tarea marcada como pendiente',
        ),
        backgroundColor: tarea.completada ? Colors.green : Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _eliminarTarea(int index, {bool esFiltrada = false}) {
    TareaGym tareaEliminada;
    int indexReal = index;

    if (esFiltrada) {
      final tareasFiltradas = _obtenerTareasFiltradas();
      if (index >= tareasFiltradas.length) return;

      tareaEliminada = tareasFiltradas[index];
      indexReal = _tareas.indexWhere((t) => t.id == tareaEliminada.id);

      if (indexReal == -1) return;
    } else {
      tareaEliminada = _tareas[index];
    }

    setState(() {
      _tareas.removeAt(indexReal);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tarea "${tareaEliminada.titulo}" eliminada'),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Deshacer',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _tareas.insert(indexReal, tareaEliminada);
            });
          },
        ),
      ),
    );
  }

  void _mostrarDialogoAgregarTarea() {
    _tituloController.clear();
    _descripcionController.clear();
    _categoriaSeleccionada = _categorias.first;
    _fechaSeleccionada = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => _buildDialogoTarea(false, -1),
    );
  }

  void _mostrarDialogoEditarTarea(int indexOriginal) {
    final tareasFiltradas = _obtenerTareasFiltradas();
    if (indexOriginal >= tareasFiltradas.length) return;

    final tarea = tareasFiltradas[indexOriginal];
    final indexReal = _tareas.indexWhere((t) => t.id == tarea.id);

    _tituloController.text = tarea.titulo;
    _descripcionController.text = tarea.descripcion;
    _categoriaSeleccionada = tarea.categoria;
    _fechaSeleccionada = tarea.fechaProgramada;

    showDialog(
      context: context,
      builder: (context) => _buildDialogoTarea(true, indexReal),
    );
  }

  // Métodos auxiliares para filtrado y gestión
  List<TareaGym> _obtenerTareasFiltradas() {
    switch (_vistaActual) {
      case 0: // Hoy
        return _tareas.where((tarea) {
          final fechaTarea = DateTime(
            tarea.fechaProgramada.year,
            tarea.fechaProgramada.month,
            tarea.fechaProgramada.day,
          );
          final fechaFiltroSolo = DateTime(
            _fechaFiltro.year,
            _fechaFiltro.month,
            _fechaFiltro.day,
          );
          return fechaTarea.isAtSameMomentAs(fechaFiltroSolo) &&
              !tarea.completada;
        }).toList();
      case 1: // Esta semana
        return _obtenerTareasEstaSemana();
      case 2: // Completadas
        return _tareas.where((tarea) => tarea.completada).toList();
      default:
        return _tareas;
    }
  }

  List<TareaGym> _obtenerTareasEstaSemana() {
    final inicioSemana = _fechaFiltro.subtract(
      Duration(days: _fechaFiltro.weekday - 1),
    );
    final finSemana = inicioSemana.add(Duration(days: 6));

    return _tareas.where((tarea) {
      final fechaTarea = DateTime(
        tarea.fechaProgramada.year,
        tarea.fechaProgramada.month,
        tarea.fechaProgramada.day,
      );
      final inicioSemanaFiltro = DateTime(
        inicioSemana.year,
        inicioSemana.month,
        inicioSemana.day,
      );
      final finSemanaFiltro = DateTime(
        finSemana.year,
        finSemana.month,
        finSemana.day,
      );

      return (fechaTarea.isAfter(inicioSemanaFiltro) ||
              fechaTarea.isAtSameMomentAs(inicioSemanaFiltro)) &&
          (fechaTarea.isBefore(finSemanaFiltro.add(Duration(days: 1))) ||
              fechaTarea.isAtSameMomentAs(finSemanaFiltro)) &&
          !tarea.completada;
    }).toList();
  }

  String _obtenerTituloSeccion() {
    switch (_vistaActual) {
      case 0:
        return 'Tareas de Hoy';
      case 1:
        return 'Tareas de la Semana';
      case 2:
        return 'Tareas Completadas';
      default:
        return 'Mis Tareas';
    }
  }

  Widget _construirListaTareas() {
    final tareasFiltradas = _obtenerTareasFiltradas();

    if (tareasFiltradas.isEmpty) {
      return _buildListaVacia();
    }

    if (_vistaActual == 2) {
      // Vista de completadas agrupada por fecha
      return _construirListaCompletadas(tareasFiltradas);
    } else {
      // Vista normal
      return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: tareasFiltradas.length,
        itemBuilder: (context, index) {
          final tarea = tareasFiltradas[index];
          return _buildTareaCard(tarea, index, esFiltrada: true);
        },
      );
    }
  }

  Widget _construirListaCompletadas(List<TareaGym> tareasCompletadas) {
    // Agrupar por fecha
    Map<String, List<TareaGym>> tareasPorFecha = {};

    for (var tarea in tareasCompletadas) {
      final fechaKey =
          '${tarea.fechaProgramada.day}/${tarea.fechaProgramada.month}/${tarea.fechaProgramada.year}';
      if (!tareasPorFecha.containsKey(fechaKey)) {
        tareasPorFecha[fechaKey] = [];
      }
      tareasPorFecha[fechaKey]!.add(tarea);
    }

    return Column(
      children: tareasPorFecha.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Separador de fecha
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              margin: EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                // ignore: deprecated_member_use
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Text(
                'Completadas el ${entry.key}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                  fontSize: 14,
                ),
              ),
            ),
            // Lista de tareas para esa fecha
            ...entry.value.map((tarea) {
              final index = tareasCompletadas.indexOf(tarea);
              return _buildTareaCard(tarea, index, esFiltrada: true);
            }),
            SizedBox(height: 15),
          ],
        );
      }).toList(),
    );
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: _fechaFiltro,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: Locale('es', 'ES'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (fechaSeleccionada != null) {
      setState(() {
        _fechaFiltro = fechaSeleccionada;
      });
    }
  }

  Widget _buildDialogoTarea(bool esEdicion, int index) {
    return StatefulBuilder(
      builder: (context, setDialogState) {
        return AlertDialog(
          title: Text(
            esEdicion ? 'Editar Tarea' : 'Nueva Tarea',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _tituloController,
                  decoration: InputDecoration(
                    labelText: 'Título de la tarea',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.title),
                  ),
                ),
                SizedBox(height: 15),
                TextField(
                  controller: _descripcionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Descripción',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.description),
                  ),
                ),
                SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  initialValue: _categoriaSeleccionada,
                  decoration: InputDecoration(
                    labelText: 'Categoría',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: _categorias.map((String categoria) {
                    return DropdownMenuItem<String>(
                      value: categoria,
                      child: Text(categoria),
                    );
                  }).toList(),
                  onChanged: (String? nuevaCategoria) {
                    setDialogState(() {
                      _categoriaSeleccionada = nuevaCategoria!;
                    });
                  },
                ),
                SizedBox(height: 15),
                // Selector de fecha
                GestureDetector(
                  onTap: () async {
                    final DateTime? fechaSeleccionada = await showDatePicker(
                      context: context,
                      initialDate: _fechaSeleccionada,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: AppColors.primary,
                              onPrimary: Colors.white,
                              surface: Colors.white,
                              onSurface: Colors.black,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );

                    if (fechaSeleccionada != null) {
                      setDialogState(() {
                        _fechaSeleccionada = fechaSeleccionada;
                      });
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: Colors.grey),
                        SizedBox(width: 10),
                        Text(
                          'Fecha: ${_fechaSeleccionada.day}/${_fechaSeleccionada.month}/${_fechaSeleccionada.year}',
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => _guardarTarea(esEdicion, index),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(esEdicion ? 'Actualizar' : 'Agregar'),
            ),
          ],
        );
      },
    );
  }

  void _guardarTarea(bool esEdicion, int index) {
    if (_tituloController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('El título es obligatorio'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final colorAleatorio =
        _colores[DateTime.now().millisecondsSinceEpoch % _colores.length];
    final iconoAleatorio =
        _iconos[DateTime.now().millisecondsSinceEpoch % _iconos.length];

    if (esEdicion) {
      setState(() {
        _tareas[index].titulo = _tituloController.text.trim();
        _tareas[index].descripcion = _descripcionController.text.trim();
        _tareas[index].categoria = _categoriaSeleccionada;
      });
    } else {
      final nuevaTarea = TareaGym(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        titulo: _tituloController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        categoria: _categoriaSeleccionada,
        fechaCreacion: DateTime.now(),
        fechaProgramada: _fechaSeleccionada,
        color: colorAleatorio,
        icono: iconoAleatorio,
      );

      setState(() {
        _tareas.add(nuevaTarea);
      });
    }

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          esEdicion
              ? 'Tarea actualizada correctamente'
              : 'Nueva tarea agregada correctamente',
        ),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
