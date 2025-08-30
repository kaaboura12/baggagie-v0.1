import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final String? text;
  final TextStyle? textStyle;
  final double spacing;

  const AppLogo({
    super.key,
    this.size = 80.0,
    this.showText = true,
    this.text,
    this.textStyle,
    this.spacing = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo container using the actual logo image
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * 0.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8E44AD).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(size * 0.2),
            child: Image.asset(
              'lib/public/assets/logo.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback to custom logo if image fails to load
                return Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF8E44AD), // Deep purple
                        Color(0xFF9B59B6), // Medium purple
                      ],
                    ),
                    borderRadius: BorderRadius.circular(size * 0.2),
                  ),
                  child: Icon(
                    Icons.luggage,
                    size: size * 0.5,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),
        ),
        
        if (showText) ...[
          SizedBox(height: spacing),
          Text(
            text ?? 'Baggagie',
            style: textStyle ?? TextStyle(
              fontFamily: 'Pacifico',
              fontSize: size * 0.3,
              fontWeight: FontWeight.normal,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ],
    );
  }
}
