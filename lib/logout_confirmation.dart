import 'package:flutter/material.dart';

const _logoutInk = Color(0xFF103D43);
const _logoutGold = Color(0xFFB77A18);
const _logoutBorder = Color(0xFFE8CDA6);
const _logoutSurface = Color(0xFFFFFCF7);

Future<bool?> showLogoutConfirmationDialog(BuildContext context) =>
    showDialog<bool>(
      context: context,
      builder: (_) => const LogoutConfirmationDialog(),
    );

class LogoutConfirmationDialog extends StatelessWidget {
  const LogoutConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: Colors.transparent,
    elevation: 0,
    insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 430),
      child: Container(
        decoration: BoxDecoration(
          color: _logoutSurface,
          borderRadius: BorderRadius.circular(23),
          border: Border.all(color: _logoutBorder),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A72552D),
              blurRadius: 25,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: [
            const Positioned(
              top: 19,
              left: 15,
              child: _BotanicalDecoration(width: 40, height: 42),
            ),
            const Positioned(
              top: 19,
              right: 15,
              child: _BotanicalDecoration(
                width: 40,
                height: 42,
                mirrored: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 37, 18, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F0E3),
                      shape: BoxShape.circle,
                      border: Border.all(color: _logoutBorder),
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      color: _logoutGold,
                      size: 42,
                    ),
                  ),
                  const SizedBox(height: 11),
                  const Text(
                    'Log out?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _logoutInk,
                      fontFamily: 'Georgia',
                      fontSize: 33,
                      fontWeight: FontWeight.w600,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Are you sure you want to log out?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF202B2D),
                      fontSize: 17,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(height: 1, color: _logoutBorder),
                  const SizedBox(height: 17),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: IconButton.styleFrom(
                            foregroundColor: _logoutInk,
                            minimumSize: const Size.fromHeight(54),
                          ),
                          child: const Text(
                            'No',
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 19,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: FilledButton.styleFrom(
                            backgroundColor: _logoutInk,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(54),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(17),
                            ),
                          ),
                          child: const Text(
                            'Yes',
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 19,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class LogoutButton extends StatelessWidget {
  const LogoutButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: 'Log out',
    child: IconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.logout_rounded, color: _logoutGold, size: 20),
      constraints: const BoxConstraints.tightFor(width: 40, height: 40),
      style: IconButton.styleFrom(
        foregroundColor: _logoutInk,
        padding: const EdgeInsets.all(10),
      ),
    ),
  );
}

class _BotanicalDecoration extends StatelessWidget {
  const _BotanicalDecoration({
    required this.width,
    required this.height,
    this.mirrored = false,
  });

  final double width;
  final double height;
  final bool mirrored;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size(width, height),
    painter: _BotanicalPainter(mirrored: mirrored),
  );
}

class _BotanicalPainter extends CustomPainter {
  const _BotanicalPainter({required this.mirrored});

  final bool mirrored;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    if (mirrored) {
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
    }
    final scaleX = size.width / 43;
    final scaleY = size.height / 45;
    canvas.scale(scaleX, scaleY);
    final paint = Paint()
      ..color = const Color(0xFFC89543)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..strokeCap = StrokeCap.round;
    final stem = Path()
      ..moveTo(4, 41)
      ..cubicTo(8, 28, 7, 17, 21, 5);
    canvas.drawPath(stem, paint);
    final leaves = [
      (Path()
        ..moveTo(10, 29)
        ..quadraticBezierTo(2, 26, 2, 19)
        ..quadraticBezierTo(9, 21, 10, 29)),
      (Path()
        ..moveTo(13, 22)
        ..quadraticBezierTo(13, 14, 20, 13)
        ..quadraticBezierTo(19, 20, 13, 22)),
      (Path()
        ..moveTo(17, 15)
        ..quadraticBezierTo(10, 12, 12, 6)
        ..quadraticBezierTo(18, 9, 17, 15)),
      (Path()
        ..moveTo(18, 11)
        ..quadraticBezierTo(23, 7, 30, 9)
        ..quadraticBezierTo(25, 14, 18, 11)),
    ];
    for (final leaf in leaves) {
      canvas.drawPath(leaf, paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_BotanicalPainter oldDelegate) =>
      mirrored != oldDelegate.mirrored;
}
