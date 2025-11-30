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
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: image == null
                  ? [
                      // ignore: deprecated_member_use
                      AppColors.primary.withOpacity(0.9),
                      // ignore: deprecated_member_use
                      AppColors.primary.withOpacity(0.7),
                    ]
                  : [Colors.transparent, Colors.transparent],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: AppColors.primary.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
            // ignore: deprecated_member_use
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
            image: image != null
                ? DecorationImage(image: AssetImage(image!), fit: BoxFit.cover)
                : null,
          ),
          child: Container(
            decoration: image != null
                ? BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(18),
                  )
                : null,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Ícono en contenedor
                if (image == null)
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, size: 36, color: Colors.white),
                  ),
                SizedBox(height: image == null ? 14 : 0),
                // Título
                Text(
                  title,
                  style: AppTextStyles.mainText.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: subtitle.isNotEmpty ? 6 : 0),
                // Subtítulo
                if (subtitle.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      subtitle,
                      style: AppTextStyles.contactText.copyWith(
                        fontSize: 12,
                        // ignore: deprecated_member_use
                        color: Colors.white.withOpacity(0.9),
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
