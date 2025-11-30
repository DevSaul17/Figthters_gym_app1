import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants.dart';

class MiPlanScreen extends StatefulWidget {
  final String nombreUsuario;
  const MiPlanScreen({super.key, required this.nombreUsuario});

  @override
  State<MiPlanScreen> createState() => _MiPlanScreenState();
}

class _MiPlanScreenState extends State<MiPlanScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Map<String, dynamic>? _planData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarPlan();
  }

  Future<void> _cargarPlan() async {
    try {
      // Obtener el clienteId desde credenciales
      final credencialesSnapshot = await _db
          .collection('credenciales')
          .where('usuario', isEqualTo: widget.nombreUsuario)
          .get();

      if (credencialesSnapshot.docs.isEmpty) {
        if (mounted) {
          setState(() => _isLoading = false);
          _mostrarError('Cliente no encontrado');
        }
        return;
      }

      final clienteId = credencialesSnapshot.docs.first.get('clienteId');

      // Buscar directamente en membresias por clienteId
      final membresiaSnapshot = await _db
          .collection('membresias')
          .where('clienteId', isEqualTo: clienteId)
          .get();

      if (membresiaSnapshot.docs.isEmpty) {
        if (mounted) {
          setState(() => _isLoading = false);
          _mostrarError('No tienes membresía activa');
        }
        return;
      }

      // Obtener la membresía más reciente
      final membresias = membresiaSnapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data()};
      }).toList();

      membresias.sort((a, b) {
        final fechaA =
            (a['creadoEn'] as Timestamp?)?.toDate() ?? DateTime(2000);
        final fechaB =
            (b['creadoEn'] as Timestamp?)?.toDate() ?? DateTime(2000);
        return fechaB.compareTo(fechaA);
      });

      final membresiaData = membresias.first;
      final planId = membresiaData['planId'];

      if (planId == null || planId.toString().isEmpty) {
        if (mounted) {
          setState(() => _isLoading = false);
          _mostrarError('Plan no asignado a la membresía');
        }
        return;
      }

      // Obtener los detalles del plan por ID
      final planSnapshot = await _db.collection('planes').doc(planId).get();

      if (planSnapshot.exists) {
        final planData = planSnapshot.data();

        if (mounted) {
          setState(() {
            _planData = planData;
            _planData!['membresiaInfo'] = membresiaData;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
          _mostrarError('Plan no encontrado en la base de datos');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _mostrarError('Error al cargar el plan: $e');
      }
    }
  }

  void _mostrarMensaje(String mensaje, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _mostrarError(String mensaje) {
    _mostrarMensaje(mensaje, Colors.red);
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
          'Mi Plan',
          style: AppTextStyles.appBarTitle.copyWith(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _planData == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning_amber, size: 60, color: Colors.orange),
                  SizedBox(height: 20),
                  Text(
                    'No tienes un plan activo',
                    style: AppTextStyles.mainText.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.horizontalPadding,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildPlanCard(),
                  SizedBox(height: 28),
                  _buildInfoMembresiaCard(),
                  SizedBox(height: 28),
                  _buildDetallesCard(),
                  SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildPlanCard() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.75),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.card_membership, size: 40, color: Colors.white),
          ),
          SizedBox(height: 16),
          Text(
            _planData?['nombre'] ?? 'Plan',
            style: AppTextStyles.mainText.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Plan activo',
              style: AppTextStyles.contactText.copyWith(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoMembresiaCard() {
    final membresiaInfo = _planData?['membresiaInfo'];

    if (membresiaInfo == null) {
      return SizedBox.shrink();
    }

    final diasRestantes = _calcularDiasRestantes(membresiaInfo);
    final porcentajeRestante = _calcularPorcentajeRestante(membresiaInfo);

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.blue.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.card_giftcard,
                  size: 24,
                  color: Colors.blue[700],
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Tu Membresía',
                  style: AppTextStyles.mainText.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: membresiaInfo['activa'] == true
                      ? Colors.green.withValues(alpha: 0.15)
                      : Colors.red.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  membresiaInfo['activa'] == true ? 'Activa' : 'Inactiva',
                  style: AppTextStyles.contactText.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: membresiaInfo['activa'] == true
                        ? Colors.green[700]
                        : Colors.red[700],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          // Barra de progreso de días
          if (diasRestantes > 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Días Restantes',
                  style: AppTextStyles.contactText.copyWith(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '$diasRestantes días',
                  style: AppTextStyles.mainText.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: porcentajeRestante,
                minHeight: 8,
                backgroundColor: Colors.blue.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  _obtenerColorProgreso(porcentajeRestante),
                ),
              ),
            ),
            SizedBox(height: 16),
          ],
          // Detalles en grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
            children: [
              _buildMembresiaDetailCard(
                icon: Icons.calendar_today,
                label: 'Inicio',
                value: _formatearFecha(membresiaInfo['fechaInicio']),
              ),
              _buildMembresiaDetailCard(
                icon: Icons.event_available,
                label: 'Vencimiento',
                value: _formatearFecha(membresiaInfo['fechaFin']),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMembresiaDetailCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.15)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: Colors.blue[600]),
          SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.contactText.copyWith(
              fontSize: 11,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.mainText.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  int _calcularDiasRestantes(Map<String, dynamic> membresiaInfo) {
    if (membresiaInfo['fechaFin'] != null) {
      final vencimiento = (membresiaInfo['fechaFin'] as Timestamp).toDate();
      int diasRestantes = vencimiento.difference(DateTime.now()).inDays;
      return diasRestantes < 0 ? 0 : diasRestantes;
    }
    return 0;
  }

  double _calcularPorcentajeRestante(Map<String, dynamic> membresiaInfo) {
    if (membresiaInfo['fechaInicio'] == null ||
        membresiaInfo['fechaFin'] == null) {
      return 0;
    }
    final inicio = (membresiaInfo['fechaInicio'] as Timestamp).toDate();
    final fin = (membresiaInfo['fechaFin'] as Timestamp).toDate();
    final ahora = DateTime.now();

    final diasTotales = fin.difference(inicio).inDays;
    final diasRestantes = fin.difference(ahora).inDays;

    if (diasTotales <= 0) return 0;
    double porcentaje = diasRestantes / diasTotales;
    return porcentaje < 0 ? 0 : (porcentaje > 1 ? 1 : porcentaje);
  }

  Color _obtenerColorProgreso(double porcentaje) {
    if (porcentaje > 0.5) return Colors.green;
    if (porcentaje > 0.25) return Colors.orange;
    return Colors.red;
  }

  Widget _buildDetallesCard() {
    final descripcion = _planData?['planDescripcion'] ?? '';
    final beneficios = _planData?['beneficios'] as List? ?? [];

    if (descripcion.isEmpty && beneficios.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Descripción
          if (descripcion.isNotEmpty) ...[
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.description,
                    size: 24,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Descripción',
                  style: AppTextStyles.mainText.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.15),
                ),
              ),
              child: Text(
                descripcion,
                style: AppTextStyles.contactText.copyWith(
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
            if (beneficios.isNotEmpty) SizedBox(height: 24),
          ],

          // Beneficios
          if (beneficios.isNotEmpty) ...[
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.check_circle,
                    size: 24,
                    color: Colors.green[700],
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Beneficios',
                  style: AppTextStyles.mainText.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            ...beneficios.map(
              (beneficio) => Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.check,
                          size: 14,
                          color: Colors.green[700],
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        beneficio.toString(),
                        style: AppTextStyles.contactText.copyWith(
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatearFecha(dynamic fecha) {
    if (fecha == null) return 'N/A';
    if (fecha is Timestamp) {
      return '${fecha.toDate().day}/${fecha.toDate().month}/${fecha.toDate().year}';
    }
    return 'N/A';
  }
}
