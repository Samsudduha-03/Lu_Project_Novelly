import 'dart:math' as math;

import 'package:flutter/material.dart';

// This is the splash screen widget. It keeps the design in its own file so the main app entry stays simple.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // This animation rotates the loading ring continuously while the splash screen is visible.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The background teal color matches the mockup closely.
      backgroundColor: const Color(0xFF0F3F4D),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // The logo is loaded from the assets folder so it can be reused anywhere.
            SizedBox(
              width: 420,
              height: 420,
              child: Image.asset(
                'assets/images/novelly_logo.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 95),
            // The loader below the logo is a partial circle arc that rotates in place.
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _controller.value * 2 * math.pi,
                  child: CustomPaint(
                    size: const Size(118, 118),
                    painter: LoadingArcPainter(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// This painter draws a simple circular loading arc like the one in the mockup.
class LoadingArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xFFF1F1F1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    // A partial arc gives the same curved loading shape seen in the design.
    canvas.drawArc(
      Rect.fromCircle(
        center: size.center(Offset.zero),
        radius: size.width / 2 - 6,
      ),
      math.pi * 0.18,
      math.pi * 1.5,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
