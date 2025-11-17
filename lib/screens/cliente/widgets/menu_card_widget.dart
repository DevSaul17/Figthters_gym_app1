import 'package:flutter/material.dart';
import '../../../constants.dart';

class MenuCardWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? image;

  const MenuCardWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
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
              ? DecorationImage(image: AssetImage(image!), fit: BoxFit.cover)
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
}
