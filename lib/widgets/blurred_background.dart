import 'dart:ui';
import 'package:flutter/material.dart';

class BlurredBackground extends StatelessWidget {
  final Widget child;
  final double blurIntensity;
  final Color overlayColor;
  final String? backgroundImagePath;

  const BlurredBackground({
    super.key,
    required this.child,
    this.blurIntensity = 10.0,
    this.overlayColor = const Color(0x80000000),
    this.backgroundImagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6A4C93), // Deep purple
            Color(0xFF9B59B6), // Medium purple
            Color(0xFFE8B4CB), // Light lavender-pink
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Background pattern with diagonal stripes
          _buildDiagonalStripes(),
          
          // Blurred overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurIntensity, sigmaY: blurIntensity),
            child: Container(
              color: overlayColor,
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagonalStripes() {
    return CustomPaint(
      size: const Size(double.infinity, double.infinity),
      painter: DiagonalStripesPainter(),
    );
  }
}

class DiagonalStripesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    const double stripeSpacing = 40.0;
    const double stripeAngle = -45.0; // Diagonal angle
    
    // Calculate the diagonal length to ensure stripes cover the entire canvas
    final double diagonalLength = size.width + size.height;
    final int stripeCount = (diagonalLength / stripeSpacing).ceil();

    for (int i = 0; i < stripeCount; i++) {
      final double offset = i * stripeSpacing;
      
      // Create diagonal line from top-left to bottom-right
      final Offset start = Offset(
        -size.height * 0.7 + offset,
        size.height * 0.7 + offset,
      );
      final Offset end = Offset(
        size.width * 0.7 + offset,
        -size.height * 0.7 + offset,
      );
      
      canvas.drawLine(start, end, paint);
    }

    // Add subtle star-like dots
    _drawStars(canvas, size);
  }

  void _drawStars(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final List<Offset> starPositions = [
      Offset(size.width * 0.1, size.height * 0.2),
      Offset(size.width * 0.8, size.height * 0.15),
      Offset(size.width * 0.2, size.height * 0.4),
      Offset(size.width * 0.7, size.height * 0.35),
      Offset(size.width * 0.9, size.height * 0.6),
      Offset(size.width * 0.15, size.height * 0.7),
      Offset(size.width * 0.6, size.height * 0.8),
      Offset(size.width * 0.3, size.height * 0.9),
    ];

    for (final position in starPositions) {
      canvas.drawCircle(position, 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
