import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'login.dart';

// Shared colors.
const Color _gold = Color(0xFFC8A46B);
const Color _trackWhite = Color(0xFFF1F1F1);

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
    // The progress indicator completes once before opening the login screen.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (_) => const LoginScreen(),
            ),
          );
        }
      })
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    // Logo is 40% of the screen width, never bigger than 170 px, so it fits small mobile screens.
    final logoSize = (screenSize.shortestSide * 0.40).clamp(0.0, 170.0);
    // Loader bar is about 43% of the screen width (same look as the reference photo).
    final loaderWidth = (screenSize.width * 0.43).clamp(0.0, 260.0);

    return Scaffold(
      // Same teal as the logo circle, so the logo blends into the background.
      backgroundColor: const Color(0xFF13343C),
      body: Stack(
        children: [
          // Background pattern: gradient, dots and rings (centered on the logo).
          Positioned.fill(
            child: CustomPaint(
              painter: BackgroundPatternPainter(
                center: Offset(screenSize.width / 2, screenSize.height / 2),
                logoRadius: logoSize / 2,
              ),
            ),
          ),
          // Logo in the exact center of the screen.
          Center(
            child: SizedBox(
              width: logoSize,
              height: logoSize,
              child: Image.asset(
                'assets/images/novelly_logo.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          // Reading-man progress loader at the bottom of the screen.
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 56),
                child: ReadingLoader(
                  animation: _controller,
                  width: loaderWidth,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// A gold progress bar with a man reading a book who walks along the bar as it fills.
class ReadingLoader extends StatelessWidget {
  final Animation<double> animation;
  final double width;

  const ReadingLoader({
    super.key,
    required this.animation,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final barHeight = width * 0.065;
    // Sizes measured from the reference photo (bar = 100%).
    final manHeight = width * 0.373;
    final manWidth =
        manHeight * (ReadingManPainter.boxW / ReadingManPainter.boxH);

    return SizedBox(
      width: width,
      height: manHeight + barHeight * 0.5,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          // Smooth start and end of every loop.
          final t = Curves.easeInOut.transform(animation.value);
          final fillWidth = width * t;
          // In the photo the man's back is about 22% of the bar behind the end of the gold fill.
          final manLeft = math.max(0.0, fillWidth - width * 0.223);

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // The progress bar.
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: barHeight,
                child: CustomPaint(
                  painter: ProgressBarPainter(fillWidth: fillWidth),
                ),
              ),
              // The man, with his feet sunk into the bar.
              Positioned(
                left: manLeft,
                bottom: barHeight * 0.5,
                width: manWidth,
                height: manHeight,
                child: const CustomPaint(painter: ReadingManPainter()),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Draws the white track and the gold fill on top of it.
class ProgressBarPainter extends CustomPainter {
  final double fillWidth;

  const ProgressBarPainter({required this.fillWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final track = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(size.height / 2),
    );
    canvas.drawRRect(track, Paint()..color = _trackWhite);

    // Clip so the gold fill keeps the rounded left corners of the track.
    canvas.save();
    canvas.clipRRect(track);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, fillWidth, size.height),
      Paint()..color = _gold,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ProgressBarPainter oldDelegate) =>
      oldDelegate.fillWidth != fillWidth;
}

// Gold silhouette of the man reading a book, traced directly from the reference photo.
// The outline is stored in an 87.4 x 119.3 design box and scaled to the widget size.
class ReadingManPainter extends CustomPainter {
  const ReadingManPainter();

  static const double boxW = 87.4;
  static const double boxH = 119.3;

  static final Path _outline = Path()
    ..moveTo(32.2, 0.0)
    ..cubicTo(31.7, 0.0, 31.3, 0.1, 30.8, 0.2)
    ..cubicTo(30.3, 0.3, 29.8, 0.4, 29.4, 0.5)
    ..cubicTo(28.9, 0.7, 28.4, 0.8, 28.0, 1.0)
    ..cubicTo(27.5, 1.2, 27.1, 1.4, 26.6, 1.6)
    ..cubicTo(26.2, 1.8, 25.8, 2.0, 25.3, 2.3)
    ..cubicTo(24.9, 2.5, 24.5, 2.8, 24.1, 3.1)
    ..cubicTo(23.7, 3.4, 23.3, 3.6, 23.0, 4.0)
    ..cubicTo(22.6, 4.3, 22.3, 4.6, 22.0, 5.0)
    ..cubicTo(21.7, 5.3, 21.4, 5.7, 21.1, 6.1)
    ..cubicTo(20.8, 6.5, 20.6, 6.9, 20.4, 7.3)
    ..cubicTo(20.2, 7.8, 20.0, 8.2, 19.9, 8.7)
    ..cubicTo(19.7, 9.2, 19.6, 9.6, 19.5, 10.1)
    ..cubicTo(19.4, 10.6, 19.3, 11.1, 19.2, 11.6)
    ..cubicTo(19.2, 12.1, 19.1, 12.7, 19.1, 13.2)
    ..cubicTo(19.1, 13.7, 19.1, 14.2, 19.0, 14.7)
    ..cubicTo(19.0, 15.3, 19.0, 15.8, 19.0, 16.3)
    ..cubicTo(19.0, 16.9, 19.0, 17.4, 19.0, 17.9)
    ..cubicTo(19.0, 18.5, 19.0, 19.0, 19.0, 19.5)
    ..cubicTo(18.9, 20.1, 18.9, 20.6, 18.9, 21.1)
    ..cubicTo(18.8, 21.6, 18.8, 22.1, 18.7, 22.6)
    ..cubicTo(18.7, 23.1, 18.6, 23.6, 18.4, 24.1)
    ..cubicTo(18.3, 24.6, 18.2, 25.1, 18.0, 25.5)
    ..cubicTo(17.8, 26.0, 17.6, 26.5, 17.4, 26.9)
    ..cubicTo(17.2, 27.3, 16.9, 27.8, 16.6, 28.2)
    ..cubicTo(16.4, 28.6, 16.1, 29.0, 15.8, 29.4)
    ..cubicTo(15.5, 29.8, 15.2, 30.2, 14.8, 30.6)
    ..cubicTo(14.5, 31.0, 14.2, 31.3, 13.9, 31.7)
    ..cubicTo(13.6, 32.1, 13.3, 32.5, 13.0, 32.9)
    ..cubicTo(12.7, 33.3, 12.4, 33.7, 12.1, 34.1)
    ..cubicTo(11.8, 34.5, 11.6, 34.9, 11.3, 35.3)
    ..cubicTo(11.0, 35.7, 10.7, 36.1, 10.5, 36.5)
    ..cubicTo(10.2, 36.9, 9.9, 37.3, 9.6, 37.7)
    ..cubicTo(9.3, 38.1, 9.0, 38.5, 8.7, 38.8)
    ..cubicTo(8.5, 39.2, 8.1, 39.6, 7.8, 40.0)
    ..cubicTo(7.5, 40.3, 7.2, 40.7, 6.9, 41.1)
    ..cubicTo(6.6, 41.5, 6.3, 41.8, 6.0, 42.2)
    ..cubicTo(5.7, 42.6, 5.4, 42.9, 5.1, 43.3)
    ..cubicTo(4.8, 43.7, 4.6, 44.1, 4.3, 44.5)
    ..cubicTo(4.0, 44.9, 3.7, 45.3, 3.5, 45.7)
    ..cubicTo(3.3, 46.1, 3.0, 46.5, 2.8, 46.9)
    ..cubicTo(2.6, 47.3, 2.4, 47.8, 2.2, 48.2)
    ..cubicTo(2.0, 48.7, 1.8, 49.1, 1.6, 49.6)
    ..cubicTo(1.4, 50.1, 1.3, 50.5, 1.1, 51.0)
    ..cubicTo(1.0, 51.5, 0.9, 51.9, 0.7, 52.4)
    ..cubicTo(0.6, 52.9, 0.5, 53.4, 0.4, 53.9)
    ..cubicTo(0.3, 54.4, 0.3, 54.9, 0.2, 55.4)
    ..cubicTo(0.2, 55.9, 0.1, 56.5, 0.1, 57.0)
    ..cubicTo(0.1, 57.5, 0.1, 58.0, 0.0, 58.6)
    ..cubicTo(0.0, 59.1, 0.0, 59.6, 0.0, 60.2)
    ..cubicTo(0.0, 60.7, 0.0, 61.2, 0.0, 61.8)
    ..cubicTo(0.0, 62.3, 0.0, 62.8, 0.0, 63.4)
    ..cubicTo(0.0, 63.9, 0.0, 64.4, 0.0, 65.0)
    ..cubicTo(-0.0, 65.5, -0.0, 66.0, 0.0, 66.6)
    ..cubicTo(0.0, 67.1, 0.0, 67.6, 0.0, 68.2)
    ..cubicTo(0.0, 68.7, 0.0, 69.2, 0.0, 69.8)
    ..cubicTo(0.0, 70.3, 0.0, 70.8, 0.0, 71.4)
    ..cubicTo(0.0, 71.9, 0.0, 72.4, 0.1, 73.0)
    ..cubicTo(0.1, 73.5, 0.1, 74.0, 0.1, 74.5)
    ..cubicTo(0.2, 75.0, 0.2, 75.6, 0.3, 76.1)
    ..cubicTo(0.3, 76.6, 0.4, 77.1, 0.4, 77.6)
    ..cubicTo(0.5, 78.1, 0.6, 78.6, 0.6, 79.1)
    ..cubicTo(0.7, 79.6, 0.7, 80.2, 0.8, 80.7)
    ..cubicTo(0.9, 81.2, 0.9, 81.7, 1.0, 82.2)
    ..cubicTo(1.1, 82.7, 1.1, 83.2, 1.2, 83.7)
    ..cubicTo(1.2, 84.2, 1.3, 84.7, 1.4, 85.2)
    ..cubicTo(1.4, 85.8, 1.5, 86.3, 1.6, 86.8)
    ..cubicTo(1.6, 87.3, 1.7, 87.8, 1.8, 88.3)
    ..cubicTo(1.8, 88.8, 1.9, 89.3, 1.9, 89.8)
    ..cubicTo(2.0, 90.3, 2.1, 90.8, 2.1, 91.3)
    ..cubicTo(2.2, 91.9, 2.2, 92.4, 2.3, 92.9)
    ..cubicTo(2.4, 93.4, 2.4, 93.9, 2.5, 94.4)
    ..cubicTo(2.5, 94.9, 2.6, 95.4, 2.7, 95.9)
    ..cubicTo(2.7, 96.4, 2.8, 96.9, 2.8, 97.5)
    ..cubicTo(2.8, 98.0, 2.8, 98.5, 2.8, 99.0)
    ..cubicTo(2.8, 99.5, 2.8, 100.0, 2.8, 100.6)
    ..cubicTo(2.8, 101.1, 2.7, 101.6, 2.7, 102.1)
    ..cubicTo(2.6, 102.6, 2.6, 103.1, 2.5, 103.6)
    ..cubicTo(2.4, 104.1, 2.3, 104.6, 2.2, 105.1)
    ..cubicTo(2.1, 105.6, 2.0, 106.1, 1.9, 106.6)
    ..cubicTo(1.8, 107.0, 1.6, 107.5, 1.5, 108.0)
    ..cubicTo(1.4, 108.5, 1.3, 109.0, 1.2, 109.5)
    ..cubicTo(1.0, 109.9, 0.9, 110.4, 0.8, 110.9)
    ..cubicTo(0.7, 111.4, 0.6, 111.9, 0.5, 112.4)
    ..cubicTo(0.5, 112.9, 0.4, 113.3, 0.4, 113.8)
    ..cubicTo(0.4, 114.3, 0.3, 114.8, 0.4, 115.2)
    ..cubicTo(0.4, 115.7, 0.5, 116.1, 0.6, 116.5)
    ..cubicTo(0.7, 116.8, 0.9, 117.2, 1.1, 117.5)
    ..cubicTo(1.3, 117.8, 1.6, 118.1, 1.9, 118.3)
    ..cubicTo(2.3, 118.5, 2.6, 118.7, 3.0, 118.8)
    ..cubicTo(3.4, 118.9, 3.9, 119.0, 4.3, 119.1)
    ..cubicTo(4.8, 119.1, 5.3, 119.2, 5.8, 119.2)
    ..cubicTo(6.3, 119.2, 6.8, 119.2, 7.4, 119.3)
    ..cubicTo(7.9, 119.3, 8.4, 119.3, 9.0, 119.3)
    ..cubicTo(9.5, 119.3, 10.0, 119.3, 10.6, 119.3)
    ..cubicTo(11.1, 119.3, 11.6, 119.3, 12.2, 119.3)
    ..cubicTo(12.7, 119.3, 13.2, 119.3, 13.8, 119.3)
    ..cubicTo(14.3, 119.3, 14.8, 119.3, 15.4, 119.3)
    ..cubicTo(15.9, 119.3, 16.4, 119.3, 17.0, 119.3)
    ..cubicTo(17.5, 119.3, 18.0, 119.3, 18.6, 119.3)
    ..cubicTo(19.1, 119.3, 19.6, 119.3, 20.2, 119.3)
    ..cubicTo(20.7, 119.3, 21.2, 119.3, 21.8, 119.3)
    ..cubicTo(22.3, 119.3, 22.8, 119.3, 23.4, 119.3)
    ..cubicTo(23.9, 119.3, 24.4, 119.3, 25.0, 119.3)
    ..cubicTo(25.5, 119.3, 26.1, 119.3, 26.6, 119.3)
    ..cubicTo(27.1, 119.3, 27.7, 119.3, 28.2, 119.3)
    ..cubicTo(28.7, 119.3, 29.3, 119.3, 29.8, 119.3)
    ..cubicTo(30.3, 119.3, 30.9, 119.3, 31.4, 119.3)
    ..cubicTo(31.9, 119.3, 32.5, 119.3, 33.0, 119.3)
    ..cubicTo(33.5, 119.3, 34.1, 119.3, 34.6, 119.3)
    ..cubicTo(35.1, 119.3, 35.7, 119.3, 36.2, 119.2)
    ..cubicTo(36.7, 119.2, 37.2, 119.2, 37.7, 119.2)
    ..cubicTo(38.2, 119.1, 38.7, 119.1, 39.1, 119.0)
    ..cubicTo(39.6, 118.9, 40.0, 118.8, 40.4, 118.6)
    ..cubicTo(40.7, 118.5, 41.1, 118.3, 41.3, 118.0)
    ..cubicTo(41.6, 117.8, 41.8, 117.5, 42.0, 117.1)
    ..cubicTo(42.2, 116.8, 42.3, 116.4, 42.4, 116.0)
    ..cubicTo(42.5, 115.5, 42.5, 115.1, 42.6, 114.6)
    ..cubicTo(42.6, 114.2, 42.6, 113.7, 42.5, 113.2)
    ..cubicTo(42.5, 112.7, 42.4, 112.2, 42.4, 111.7)
    ..cubicTo(42.4, 111.2, 42.3, 110.7, 42.2, 110.2)
    ..cubicTo(42.2, 109.7, 42.1, 109.1, 42.1, 108.6)
    ..cubicTo(42.1, 108.1, 42.0, 107.6, 42.0, 107.1)
    ..cubicTo(42.0, 106.5, 41.9, 106.0, 41.9, 105.5)
    ..cubicTo(41.9, 105.0, 41.9, 104.4, 41.9, 103.9)
    ..cubicTo(41.9, 103.4, 41.9, 102.8, 41.9, 102.3)
    ..cubicTo(41.9, 101.8, 41.9, 101.2, 41.9, 100.7)
    ..cubicTo(41.9, 100.2, 41.9, 99.6, 41.9, 99.1)
    ..cubicTo(41.9, 98.6, 42.0, 98.1, 42.0, 97.6)
    ..cubicTo(42.0, 97.1, 42.1, 96.6, 42.2, 96.1)
    ..cubicTo(42.3, 95.6, 42.4, 95.1, 42.5, 94.7)
    ..cubicTo(42.7, 94.2, 42.9, 93.8, 43.1, 93.4)
    ..cubicTo(43.3, 93.1, 43.6, 92.7, 43.9, 92.4)
    ..cubicTo(44.2, 92.1, 44.5, 91.8, 44.9, 91.5)
    ..cubicTo(45.3, 91.2, 45.7, 90.9, 46.1, 90.7)
    ..cubicTo(46.5, 90.4, 46.9, 90.2, 47.3, 89.9)
    ..cubicTo(47.7, 89.7, 48.2, 89.4, 48.6, 89.2)
    ..cubicTo(49.0, 88.9, 49.4, 88.7, 49.9, 88.4)
    ..cubicTo(50.3, 88.2, 50.7, 87.9, 51.2, 87.7)
    ..cubicTo(51.6, 87.4, 52.0, 87.2, 52.4, 86.9)
    ..cubicTo(52.9, 86.7, 53.3, 86.4, 53.7, 86.1)
    ..cubicTo(54.1, 85.8, 54.5, 85.6, 55.0, 85.3)
    ..cubicTo(55.4, 85.0, 55.8, 84.7, 56.2, 84.4)
    ..cubicTo(56.6, 84.1, 57.0, 83.8, 57.4, 83.5)
    ..cubicTo(57.8, 83.2, 58.2, 82.9, 58.6, 82.6)
    ..cubicTo(59.1, 82.4, 59.5, 82.1, 59.9, 81.9)
    ..cubicTo(60.3, 81.6, 60.8, 81.4, 61.2, 81.2)
    ..cubicTo(61.7, 80.9, 62.1, 80.7, 62.5, 80.5)
    ..cubicTo(63.0, 80.2, 63.4, 80.0, 63.8, 79.8)
    ..cubicTo(64.3, 79.5, 64.7, 79.2, 65.1, 79.0)
    ..cubicTo(65.5, 78.7, 65.9, 78.4, 66.3, 78.1)
    ..cubicTo(66.7, 77.8, 67.0, 77.4, 67.4, 77.1)
    ..cubicTo(67.8, 76.7, 68.1, 76.4, 68.4, 76.0)
    ..cubicTo(68.8, 75.6, 69.1, 75.2, 69.4, 74.8)
    ..cubicTo(69.7, 74.4, 70.0, 74.0, 70.2, 73.6)
    ..cubicTo(70.5, 73.2, 70.8, 72.8, 71.0, 72.3)
    ..cubicTo(71.3, 71.9, 71.5, 71.5, 71.8, 71.0)
    ..cubicTo(72.0, 70.6, 72.2, 70.2, 72.5, 69.7)
    ..cubicTo(72.7, 69.3, 72.9, 68.8, 73.1, 68.4)
    ..cubicTo(73.3, 68.0, 73.5, 67.5, 73.7, 67.1)
    ..cubicTo(73.9, 66.6, 74.1, 66.1, 74.3, 65.7)
    ..cubicTo(74.5, 65.2, 74.7, 64.8, 74.9, 64.3)
    ..cubicTo(75.1, 63.9, 75.3, 63.4, 75.5, 63.0)
    ..cubicTo(75.7, 62.5, 76.0, 62.1, 76.2, 61.7)
    ..cubicTo(76.4, 61.2, 76.7, 60.8, 76.9, 60.4)
    ..cubicTo(77.2, 59.9, 77.4, 59.5, 77.7, 59.1)
    ..cubicTo(78.0, 58.7, 78.3, 58.2, 78.6, 57.8)
    ..cubicTo(78.9, 57.4, 79.2, 57.0, 79.5, 56.6)
    ..cubicTo(79.8, 56.2, 80.1, 55.8, 80.4, 55.4)
    ..cubicTo(80.7, 55.0, 81.0, 54.5, 81.3, 54.1)
    ..cubicTo(81.5, 53.7, 81.8, 53.3, 82.1, 52.9)
    ..cubicTo(82.4, 52.5, 82.6, 52.1, 82.8, 51.7)
    ..cubicTo(83.0, 51.3, 83.2, 50.9, 83.4, 50.5)
    ..cubicTo(83.5, 50.1, 83.6, 49.7, 83.6, 49.3)
    ..cubicTo(83.6, 48.9, 83.5, 48.6, 83.4, 48.2)
    ..cubicTo(83.3, 47.9, 83.1, 47.6, 82.9, 47.3)
    ..cubicTo(82.6, 47.0, 82.3, 46.8, 82.0, 46.5)
    ..cubicTo(81.7, 46.2, 81.3, 46.0, 80.9, 45.8)
    ..cubicTo(80.5, 45.5, 80.1, 45.3, 79.7, 45.1)
    ..cubicTo(79.2, 44.8, 78.8, 44.6, 78.4, 44.4)
    ..cubicTo(77.9, 44.2, 77.5, 43.9, 77.1, 43.7)
    ..cubicTo(76.6, 43.5, 76.2, 43.2, 75.7, 43.0)
    ..cubicTo(75.3, 42.8, 74.9, 42.6, 74.4, 42.3)
    ..cubicTo(74.0, 42.1, 73.5, 41.9, 73.1, 41.7)
    ..cubicTo(72.6, 41.5, 72.2, 41.3, 71.7, 41.1)
    ..cubicTo(71.3, 40.9, 70.9, 40.7, 70.4, 40.6)
    ..cubicTo(69.9, 40.5, 69.5, 40.4, 69.0, 40.3)
    ..cubicTo(68.6, 40.2, 68.1, 40.2, 67.7, 40.2)
    ..cubicTo(67.3, 40.3, 66.8, 40.3, 66.4, 40.5)
    ..cubicTo(66.0, 40.6, 65.6, 40.8, 65.2, 41.0)
    ..cubicTo(64.8, 41.2, 64.4, 41.5, 64.1, 41.8)
    ..cubicTo(63.7, 42.1, 63.4, 42.5, 63.0, 42.8)
    ..cubicTo(62.7, 43.2, 62.4, 43.5, 62.0, 43.9)
    ..cubicTo(61.7, 44.3, 61.4, 44.7, 61.1, 45.1)
    ..cubicTo(60.7, 45.5, 60.4, 45.9, 60.1, 46.3)
    ..cubicTo(59.8, 46.7, 59.5, 47.1, 59.2, 47.5)
    ..cubicTo(58.9, 47.9, 58.6, 48.3, 58.3, 48.7)
    ..cubicTo(58.0, 49.2, 57.7, 49.6, 57.4, 50.0)
    ..cubicTo(57.1, 50.4, 56.9, 50.8, 56.6, 51.2)
    ..cubicTo(56.3, 51.7, 56.0, 52.1, 55.7, 52.5)
    ..cubicTo(55.4, 52.9, 55.2, 53.3, 54.9, 53.7)
    ..cubicTo(54.6, 54.1, 54.3, 54.6, 54.0, 55.0)
    ..cubicTo(53.7, 55.4, 53.4, 55.8, 53.1, 56.2)
    ..cubicTo(52.8, 56.6, 52.5, 57.0, 52.2, 57.4)
    ..cubicTo(52.0, 57.8, 51.7, 58.2, 51.5, 58.6)
    ..cubicTo(51.2, 59.1, 51.0, 59.5, 50.9, 59.9)
    ..cubicTo(50.7, 60.3, 50.6, 60.7, 50.6, 61.1)
    ..cubicTo(50.5, 61.5, 50.6, 61.9, 50.6, 62.3)
    ..cubicTo(50.7, 62.6, 50.9, 63.0, 51.1, 63.4)
    ..cubicTo(51.3, 63.7, 51.5, 64.1, 51.8, 64.4)
    ..cubicTo(52.1, 64.7, 52.4, 65.0, 52.8, 65.3)
    ..cubicTo(53.1, 65.6, 53.5, 65.8, 53.8, 66.1)
    ..cubicTo(54.2, 66.4, 54.6, 66.7, 54.9, 67.0)
    ..cubicTo(55.2, 67.3, 55.5, 67.6, 55.7, 67.9)
    ..cubicTo(55.9, 68.2, 56.1, 68.6, 56.2, 69.0)
    ..cubicTo(56.4, 69.3, 56.4, 69.7, 56.4, 70.1)
    ..cubicTo(56.4, 70.5, 56.3, 70.8, 56.1, 71.2)
    ..cubicTo(56.0, 71.6, 55.8, 72.0, 55.5, 72.3)
    ..cubicTo(55.3, 72.7, 55.0, 73.0, 54.6, 73.4)
    ..cubicTo(54.3, 73.7, 53.9, 74.0, 53.5, 74.2)
    ..cubicTo(53.2, 74.5, 52.7, 74.7, 52.3, 75.0)
    ..cubicTo(51.9, 75.2, 51.4, 75.4, 51.0, 75.6)
    ..cubicTo(50.5, 75.8, 50.1, 76.0, 49.6, 76.1)
    ..cubicTo(49.2, 76.3, 48.7, 76.5, 48.2, 76.6)
    ..cubicTo(47.8, 76.8, 47.3, 77.0, 46.8, 77.1)
    ..cubicTo(46.4, 77.2, 45.9, 77.3, 45.5, 77.4)
    ..cubicTo(45.0, 77.5, 44.6, 77.5, 44.1, 77.5)
    ..cubicTo(43.7, 77.5, 43.3, 77.5, 42.9, 77.4)
    ..cubicTo(42.5, 77.3, 42.1, 77.1, 41.7, 76.9)
    ..cubicTo(41.4, 76.7, 41.0, 76.4, 40.8, 76.1)
    ..cubicTo(40.5, 75.8, 40.2, 75.5, 40.0, 75.1)
    ..cubicTo(39.8, 74.7, 39.6, 74.2, 39.5, 73.8)
    ..cubicTo(39.3, 73.4, 39.2, 72.9, 39.1, 72.4)
    ..cubicTo(39.0, 71.9, 38.9, 71.4, 38.8, 70.9)
    ..cubicTo(38.7, 70.4, 38.6, 69.9, 38.5, 69.4)
    ..cubicTo(38.5, 68.9, 38.4, 68.4, 38.3, 67.9)
    ..cubicTo(38.3, 67.4, 38.2, 66.9, 38.1, 66.4)
    ..cubicTo(38.0, 65.9, 38.0, 65.4, 37.9, 64.9)
    ..cubicTo(37.8, 64.4, 37.8, 63.9, 37.7, 63.4)
    ..cubicTo(37.6, 62.9, 37.5, 62.4, 37.4, 61.9)
    ..cubicTo(37.3, 61.4, 37.2, 60.9, 37.1, 60.4)
    ..cubicTo(36.9, 60.0, 36.8, 59.5, 36.6, 59.0)
    ..cubicTo(36.5, 58.5, 36.3, 58.1, 36.1, 57.6)
    ..cubicTo(36.0, 57.1, 35.8, 56.7, 35.6, 56.2)
    ..cubicTo(35.4, 55.8, 35.2, 55.3, 35.0, 54.9)
    ..cubicTo(34.9, 54.4, 34.7, 53.9, 34.5, 53.5)
    ..cubicTo(34.3, 53.0, 34.2, 52.6, 34.0, 52.1)
    ..cubicTo(33.8, 51.6, 33.7, 51.1, 33.6, 50.7)
    ..cubicTo(33.4, 50.2, 33.3, 49.7, 33.2, 49.2)
    ..cubicTo(33.1, 48.7, 33.0, 48.2, 33.0, 47.7)
    ..cubicTo(32.9, 47.2, 32.8, 46.7, 32.7, 46.2)
    ..cubicTo(32.7, 45.7, 32.6, 45.2, 32.5, 44.7)
    ..cubicTo(32.5, 44.2, 32.4, 43.7, 32.3, 43.2)
    ..cubicTo(32.3, 42.8, 32.2, 42.3, 32.2, 41.8)
    ..cubicTo(32.2, 41.4, 32.1, 41.0, 32.2, 40.6)
    ..cubicTo(32.2, 40.2, 32.3, 39.8, 32.4, 39.5)
    ..cubicTo(32.6, 39.1, 32.8, 38.8, 33.0, 38.5)
    ..cubicTo(33.2, 38.3, 33.5, 38.1, 33.9, 37.8)
    ..cubicTo(34.2, 37.6, 34.6, 37.5, 35.0, 37.3)
    ..cubicTo(35.4, 37.1, 35.8, 36.9, 36.2, 36.7)
    ..cubicTo(36.7, 36.5, 37.1, 36.3, 37.5, 36.1)
    ..cubicTo(37.9, 35.8, 38.3, 35.5, 38.7, 35.2)
    ..cubicTo(39.1, 35.0, 39.4, 34.6, 39.8, 34.3)
    ..cubicTo(40.2, 33.9, 40.5, 33.6, 40.8, 33.2)
    ..cubicTo(41.2, 32.8, 41.5, 32.4, 41.8, 32.0)
    ..cubicTo(42.1, 31.6, 42.4, 31.2, 42.7, 30.8)
    ..cubicTo(42.9, 30.4, 43.2, 30.0, 43.4, 29.5)
    ..cubicTo(43.7, 29.1, 43.9, 28.6, 44.1, 28.2)
    ..cubicTo(44.3, 27.7, 44.4, 27.2, 44.6, 26.8)
    ..cubicTo(44.7, 26.3, 44.8, 25.8, 44.9, 25.3)
    ..cubicTo(45.1, 24.8, 45.2, 24.4, 45.3, 23.9)
    ..cubicTo(45.4, 23.4, 45.5, 22.9, 45.6, 22.4)
    ..cubicTo(45.7, 21.9, 45.8, 21.4, 45.9, 20.9)
    ..cubicTo(46.0, 20.4, 46.1, 19.9, 46.1, 19.4)
    ..cubicTo(46.2, 18.9, 46.3, 18.4, 46.4, 17.9)
    ..cubicTo(46.5, 17.4, 46.6, 16.9, 46.7, 16.4)
    ..cubicTo(46.8, 15.9, 46.9, 15.4, 46.9, 14.9)
    ..cubicTo(47.0, 14.4, 47.1, 13.9, 47.1, 13.4)
    ..cubicTo(47.2, 12.9, 47.3, 12.5, 47.3, 12.0)
    ..cubicTo(47.3, 11.5, 47.3, 11.0, 47.3, 10.5)
    ..cubicTo(47.3, 10.0, 47.2, 9.6, 47.2, 9.1)
    ..cubicTo(47.1, 8.6, 46.9, 8.2, 46.8, 7.8)
    ..cubicTo(46.6, 7.3, 46.4, 6.9, 46.2, 6.5)
    ..cubicTo(45.9, 6.1, 45.6, 5.8, 45.3, 5.4)
    ..cubicTo(45.0, 5.1, 44.7, 4.8, 44.3, 4.4)
    ..cubicTo(43.9, 4.1, 43.6, 3.9, 43.2, 3.6)
    ..cubicTo(42.8, 3.3, 42.3, 3.1, 41.9, 2.9)
    ..cubicTo(41.5, 2.6, 41.0, 2.4, 40.6, 2.2)
    ..cubicTo(40.2, 2.0, 39.7, 1.8, 39.3, 1.6)
    ..cubicTo(38.8, 1.4, 38.4, 1.2, 37.9, 1.0)
    ..cubicTo(37.4, 0.8, 37.0, 0.7, 36.5, 0.5)
    ..cubicTo(36.0, 0.4, 35.6, 0.3, 35.1, 0.2)
    ..cubicTo(34.6, 0.1, 34.2, 0.0, 33.7, 0.0)
    ..cubicTo(33.2, -0.0, 32.7, -0.0, 32.2, 0.0)
    ..close();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / boxW, size.height / boxH);

    canvas.drawPath(
      _outline,
      Paint()
        ..color = _gold
        ..style = PaintingStyle.fill
        ..isAntiAlias = true,
    );

    // The small open-page flap on the top corner of the book (thin light outline).
    final flap = Paint()
      ..color = const Color(0xFFE9D9B4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(79.5, 44.5)
        ..lineTo(83.6, 33.4)
        ..lineTo(86.4, 45.8),
      flap,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ReadingManPainter oldDelegate) => false;
}

// This painter draws the pattern behind the logo: a dark fade, a dot grid and thin gold rings.
class BackgroundPatternPainter extends CustomPainter {
  final Offset center;
  final double logoRadius;

  const BackgroundPatternPainter({
    required this.center,
    required this.logoRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final maxDist =
        math.sqrt(size.width * size.width + size.height * size.height) / 2;

    // 1) Radial fade: logo teal in the middle, darker toward the edges.
    final bgPaint = Paint()
      ..shader =
          const RadialGradient(
            colors: [Color(0xFF13343C), Color(0xFF0A1F25)],
          ).createShader(
            Rect.fromCircle(center: center, radius: size.longestSide * 0.75),
          );
    canvas.drawRect(rect, bgPaint);

    // 2) Dot grid, staggered row by row, brighter toward the edges.
    const spacing = 26.0;
    final clearRadius = logoRadius + 26;
    final dotPaint = Paint();
    int row = 0;
    for (double y = 0; y <= size.height + spacing; y += spacing) {
      final startX = row.isOdd ? spacing / 2 : 0.0;
      for (double x = startX; x <= size.width + spacing; x += spacing) {
        final dist = (Offset(x, y) - center).distance;
        if (dist < clearRadius) continue; // keep the area around the logo clean
        final alpha = 0.06 + 0.16 * (dist / maxDist).clamp(0.0, 1.0);
        dotPaint.color = _gold.withValues(alpha: alpha);
        canvas.drawCircle(Offset(x, y), 1.3, dotPaint);
      }
      row++;
    }

    // 3) Thin gold rings around the logo, fading outward.
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (int i = 0; i < 4; i++) {
      final radius = logoRadius + 22 + i * 34;
      ringPaint.color = _gold.withValues(alpha: 0.22 - i * 0.045);
      canvas.drawCircle(center, radius, ringPaint);
    }
  }

  @override
  bool shouldRepaint(covariant BackgroundPatternPainter oldDelegate) =>
      oldDelegate.center != center || oldDelegate.logoRadius != logoRadius;
}
