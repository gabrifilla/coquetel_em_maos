import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../theme/party_theme.dart';

/// Bolhas coloridas subindo devagar, para o fundo dos cabeçalhos.
class BubblesBackground extends StatefulWidget {
  const BubblesBackground({super.key, required this.child});

  final Widget child;

  @override
  State<BubblesBackground> createState() => _BubblesBackgroundState();
}

class _BubblesBackgroundState extends State<BubblesBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    reduceMotion ? _controller.stop() : _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, _) =>
                  CustomPaint(painter: _BubblesPainter(_controller.value)),
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _BubblesPainter extends CustomPainter {
  _BubblesPainter(this.t);

  final double t;

  static const _colors = [
    Party.pink,
    Party.lime,
    Party.citrus,
    Party.lagoon,
    Party.grape,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(7);
    for (var i = 0; i < 18; i++) {
      final color = _colors[i % _colors.length];
      final x = rnd.nextDouble() * size.width;
      final r = 3 + rnd.nextDouble() * 9;
      final speed = 0.5 + rnd.nextDouble();
      final phase = (t * speed + rnd.nextDouble()) % 1.0;
      final y = size.height + r - phase * (size.height + 2 * r);
      final wobble = math.sin((phase + i) * math.pi * 2) * 6;
      final paint = Paint()
        ..style = i.isEven ? PaintingStyle.fill : PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = color.withValues(alpha: 0.18 + 0.25 * (1 - phase));
      canvas.drawCircle(Offset(x + wobble, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(_BubblesPainter old) => old.t != t;
}

/// Explosão rápida de confete por cima da tela (ex.: liberou um drink novo).
void showConfetti(BuildContext context) {
  final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (reduceMotion || overlay == null) return;
  late final OverlayEntry entry;
  entry = OverlayEntry(builder: (_) => _Confetti(onDone: () => entry.remove()));
  overlay.insert(entry);
}

class _Confetti extends StatefulWidget {
  const _Confetti({required this.onDone});

  final VoidCallback onDone;

  @override
  State<_Confetti> createState() => _ConfettiState();
}

class _ConfettiState extends State<_Confetti>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..forward().whenComplete(widget.onDone);
  final _seed = DateTime.now().millisecond;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) => CustomPaint(
          size: Size.infinite,
          painter: _ConfettiPainter(_controller.value, _seed),
        ),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.t, this.seed);

  final double t;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(seed);
    final origin = Offset(size.width / 2, size.height * 0.35);
    final fade = t < 0.7 ? 1.0 : 1 - (t - 0.7) / 0.3;
    for (var i = 0; i < 60; i++) {
      final angle = rnd.nextDouble() * math.pi * 2;
      final speed = 180 + rnd.nextDouble() * 320;
      final pos =
          origin +
          Offset(
            math.cos(angle) * speed * t,
            math.sin(angle) * speed * t + 420 * t * t,
          ); // gravidade
      final paint = Paint()
        ..color = _BubblesPainter._colors[i % 5].withValues(
          alpha: fade.clamp(0, 1),
        );
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(t * 10 * (rnd.nextDouble() - 0.5));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-5, -3, 10, 6),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}
