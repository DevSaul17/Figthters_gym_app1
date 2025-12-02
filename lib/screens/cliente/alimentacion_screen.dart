import 'package:flutter/material.dart';
import '../../constants.dart';

class AlimentacionScreen extends StatelessWidget {
  final String nombreUsuario;

  const AlimentacionScreen({super.key, required this.nombreUsuario});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'TIPS ALIMENTICIOS',
          style: AppTextStyles.appBarTitle.copyWith(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(AppDimensions.horizontalPadding),
        children: [
          SizedBox(height: 20),

          // Encabezado
          _buildHeader(),

          SizedBox(height: 25),

          // Tips alimenticios
          _buildTipCard(
            icon: Icons.water_drop,
            color: Colors.blue,
            title: 'Hidratación',
            tips: [
              'Bebe al menos 2-3 litros de agua al día',
              'Hidrátate antes, durante y después del entrenamiento',
              'El agua es esencial para el rendimiento físico',
            ],
          ),

          _buildTipCard(
            icon: Icons.restaurant,
            color: Colors.green,
            title: 'Proteínas',
            tips: [
              'Consume proteínas después de entrenar para recuperación muscular',
              'Incluye carnes magras, pescado, huevo, legumbres',
              'Aproximadamente 1.6-2g de proteína por kg de peso corporal',
            ],
          ),

          _buildTipCard(
            icon: Icons.grass,
            color: Colors.lightGreen,
            title: 'Frutas y Verduras',
            tips: [
              'Consume 5 porciones de frutas y verduras al día',
              'Aportan vitaminas, minerales y antioxidantes',
              'Prioriza verduras de hoja verde',
            ],
          ),

          _buildTipCard(
            icon: Icons.grain,
            color: Colors.orange,
            title: 'Carbohidratos',
            tips: [
              'Consume carbohidratos complejos (avena, arroz integral, pasta)',
              'Son la principal fuente de energía para el entrenamiento',
              'Evita azúcares refinados en exceso',
            ],
          ),

          _buildTipCard(
            icon: Icons.favorite,
            color: Colors.red,
            title: 'Grasas Saludables',
            tips: [
              'Incluye aguacate, frutos secos, aceite de oliva',
              'Las grasas son necesarias para la absorción de vitaminas',
              'Ayudan en la producción hormonal',
            ],
          ),

          _buildTipCard(
            icon: Icons.schedule,
            color: Colors.purple,
            title: 'Horarios de Comida',
            tips: [
              'Come cada 3-4 horas para mantener el metabolismo activo',
              'No te saltes el desayuno',
              'Come 1-2 horas antes de entrenar',
            ],
          ),

          _buildTipCard(
            icon: Icons.block,
            color: Colors.redAccent,
            title: 'Evita',
            tips: [
              'Alimentos ultraprocesados',
              'Bebidas azucaradas y alcohol en exceso',
              'Frituras y comida rápida frecuentemente',
            ],
          ),

          _buildTipCard(
            icon: Icons.psychology,
            color: Colors.teal,
            title: 'Suplementos',
            tips: [
              'Considera suplementos solo si tu dieta no es suficiente',
              'Consulta con un nutriólogo antes de tomar suplementos',
              'Los más comunes: proteína en polvo, creatina, omega-3',
            ],
          ),

          SizedBox(height: 20),

          // Mensaje final
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber, width: 2),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber,
                  color: Colors.amber.shade900,
                  size: 28,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Recuerda: Estos son consejos generales. Para un plan personalizado, consulta con un nutriólogo profesional.',
                    style: AppTextStyles.contactText.copyWith(
                      fontSize: 13,
                      color: Colors.amber.shade900,
                    ),
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

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.restaurant_menu, size: 48, color: Colors.white),
          SizedBox(height: 12),
          Text(
            'Guía de Alimentación',
            style: AppTextStyles.mainText.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Una buena alimentación es clave para alcanzar tus objetivos',
            style: AppTextStyles.contactText.copyWith(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard({
    required IconData icon,
    required Color color,
    required String title,
    required List<String> tips,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              SizedBox(width: 12),
              Text(
                title,
                style: AppTextStyles.mainText.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          ...tips.map(
            (tip) => Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      tip,
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
      ),
    );
  }
}
