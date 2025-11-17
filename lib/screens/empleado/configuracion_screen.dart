import 'package:flutter/material.dart';
import '../../constants.dart';
import 'gestionar_planes_screen.dart';
import 'entrenadores_screen.dart';

class ConfiguracionScreen extends StatefulWidget {
  const ConfiguracionScreen({super.key});

  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
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
          'CONFIGURACIÓN',
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección Planes de Membresía
            _buildSeccionTitulo('Planes de Membresía', Icons.card_membership),
            SizedBox(height: 16),
            _buildOpcionCard(
              'Gestionar Planes de Membresía',
              'Agregar, editar o eliminar planes de membresía',
              Icons.card_membership,
              Colors.blue,
              () => _navegarAGestionarPlanes(),
            ),

            SizedBox(height: 24),

            // Sección Entrenadores
            _buildSeccionTitulo('Entrenadores', Icons.fitness_center),
            SizedBox(height: 16),
            _buildOpcionCard(
              'Gestionar Entrenadores',
              'Registrar, ver y administrar entrenadores del equipo',
              Icons.fitness_center,
              Colors.purple,
              () => _navegarAGestionarEntrenadores(),
            ),

            SizedBox(height: 24),

            // Sección Eventos
            _buildSeccionTitulo('Eventos', Icons.event),
            SizedBox(height: 16),
            _buildOpcionCard(
              'Gestionar Eventos',
              'Crear, editar o cancelar eventos y competencias',
              Icons.event,
              Colors.red,
              () => _mostrarEnDesarrollo('Gestionar Eventos'),
            ),
            _buildOpcionCard(
              'Calendario de Eventos',
              'Visualizar todos los eventos programados',
              Icons.calendar_month,
              Colors.deepOrange,
              () => _mostrarEnDesarrollo('Calendario Eventos'),
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSeccionTitulo(String titulo, IconData icono, [Color? color]) {
    return Row(
      children: [
        Icon(icono, color: color ?? AppColors.primary, size: 24),
        SizedBox(width: 12),
        Text(
          titulo,
          style: AppTextStyles.mainText.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color ?? AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildOpcionCard(
    String titulo,
    String subtitulo,
    IconData icono,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // ignore: deprecated_member_use
        border: Border.all(color: color.withOpacity(0.3)),
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
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icono, color: color, size: 24),
        ),
        title: Text(
          titulo,
          style: AppTextStyles.mainText.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text(
            subtitulo,
            style: AppTextStyles.contactText.copyWith(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: color),
        onTap: onTap,
      ),
    );
  }

  void _mostrarEnDesarrollo(String funcion) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$funcion en desarrollo...'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _navegarAGestionarPlanes() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GestionarPlanesScreen()),
    );
  }

  void _navegarAGestionarEntrenadores() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EntrenadoresScreen()),
    );
  }
}
