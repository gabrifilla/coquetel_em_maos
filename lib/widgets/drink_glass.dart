import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../theme/drink_style.dart';

/// Copo desenhado com a cor do drink, guarnição e (opcionalmente) bolhas subindo.
class DrinkGlass extends StatefulWidget {
  const DrinkGlass({
    super.key,
    required this.style,
    this.size = 48,
    this.animate = false,
    this.seed = 0,
  });

  final DrinkStyle style;
  final double size;

  /// Bolhas subindo. Desligado automaticamente se o sistema pede menos movimento.
  final bool animate;
  final int seed;

  @override
  State<DrinkGlass> createState() => _DrinkGlassState();
}

class _DrinkGlassState extends State<DrinkGlass>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 5),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (widget.animate && !reduceMotion) {
      if (!_controller.isAnimating) _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) => CustomPaint(
          size: Size.square(widget.size),
          painter: GlassPainter(widget.style, _controller.value, widget.seed),
        ),
      ),
    );
  }
}

class GlassPainter extends CustomPainter {
  GlassPainter(this.style, this.t, this.seed);

  final DrinkStyle style;

  /// Fase da animação das bolhas (0..1).
  final double t;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    Offset p(double x, double y) => Offset(x * s, y * s);

    final shape = _shape(style.glass, p, s);
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.035
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.9);

    // Brilho atrás do copo.
    canvas.drawCircle(
      p(0.5, 0.55),
      s * 0.42,
      Paint()
        ..shader = RadialGradient(
          colors: [style.bottom.withValues(alpha: 0.18), Colors.transparent],
        ).createShader(Rect.fromCircle(center: p(0.5, 0.55), radius: s * 0.42)),
    );

    // Vidro.
    canvas.drawPath(
      shape.interior,
      Paint()..color = Colors.white.withValues(alpha: 0.07),
    );

    // Líquido: interior do copo abaixo da linha do líquido.
    final bounds = shape.interior.getBounds();
    final liquid = Path.combine(
      PathOperation.intersect,
      shape.interior,
      Path()..addRect(Rect.fromLTRB(0, shape.liquidTop * s, s, s)),
    );
    final liquidRect = Rect.fromLTRB(
      bounds.left,
      shape.liquidTop * s,
      bounds.right,
      bounds.bottom,
    );
    canvas.drawPath(
      liquid,
      Paint()..shader = style.liquid.createShader(liquidRect),
    );

    // Gelo e bolhas, presos ao líquido.
    canvas.save();
    canvas.clipPath(liquid);
    if (shape.ice) {
      final ice = Paint()..color = Colors.white.withValues(alpha: 0.28);
      for (final (x, y, a) in [
        (0.36, 0.62, -0.2),
        (0.55, 0.58, 0.3),
        (0.46, 0.74, 0.1),
      ]) {
        canvas.save();
        canvas.translate(x * s, y * s);
        canvas.rotate(a);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: s * 0.15,
              height: s * 0.15,
            ),
            Radius.circular(s * 0.03),
          ),
          ice,
        );
        canvas.restore();
      }
    }
    final rnd = math.Random(seed);
    final bubble = Paint()..color = Colors.white.withValues(alpha: 0.45);
    for (var i = 0; i < 7; i++) {
      final x = bounds.left + bounds.width * (0.2 + rnd.nextDouble() * 0.6);
      final speed = 0.6 + rnd.nextDouble() * 0.8;
      final phase = (t * speed + rnd.nextDouble()) % 1.0;
      final y = liquidRect.bottom - phase * (liquidRect.height + s * 0.05);
      canvas.drawCircle(
        Offset(x, y),
        s * (0.012 + rnd.nextDouble() * 0.014),
        bubble,
      );
    }
    canvas.restore();

    // Superfície do líquido.
    canvas.drawLine(
      Offset(bounds.left + s * 0.02, shape.liquidTop * s),
      Offset(bounds.right - s * 0.02, shape.liquidTop * s),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.45)
        ..strokeWidth = s * 0.018,
    );

    if (shape.straw) {
      canvas.drawLine(
        p(0.56, 0.86),
        p(0.74, 0.06),
        Paint()
          ..color = const Color(0xFFEE7F76)
          ..strokeWidth = s * 0.045
          ..strokeCap = StrokeCap.round,
      );
    }

    canvas.drawPath(shape.outline, stroke);

    // Reflexo no vidro.
    canvas.drawLine(
      Offset(bounds.left + s * 0.07, bounds.top + bounds.height * 0.2),
      Offset(bounds.left + s * 0.07, bounds.top + bounds.height * 0.45),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..strokeWidth = s * 0.025
        ..strokeCap = StrokeCap.round,
    );

    _garnish(canvas, shape.rim, s);
  }

  void _garnish(Canvas canvas, Offset rim, double s) {
    final r = s * 0.11;
    switch (style.garnish) {
      case Garnish.lime || Garnish.orange:
        final color = style.garnish == Garnish.lime
            ? const Color(0xFFCFDC92)
            : const Color(0xFFFFA62B);
        final peel = style.garnish == Garnish.lime
            ? const Color(0xFF86A85A)
            : const Color(0xFFE86A10);
        canvas.drawCircle(rim, r, Paint()..color = peel);
        canvas.drawCircle(rim, r * 0.82, Paint()..color = color);
        final seg = Paint()
          ..color = Colors.white.withValues(alpha: 0.7)
          ..strokeWidth = s * 0.012;
        for (var i = 0; i < 6; i++) {
          final a = i * math.pi / 3;
          canvas.drawLine(
            rim,
            rim + Offset(math.cos(a), math.sin(a)) * r * 0.78,
            seg,
          );
        }
      case Garnish.mint:
        final leaf = Paint()..color = const Color(0xFF4CC26A);
        for (final a in [-0.6, 0.5]) {
          canvas.save();
          canvas.translate(rim.dx, rim.dy);
          canvas.rotate(a);
          canvas.drawOval(
            Rect.fromCenter(
              center: Offset(0, -r * 0.6),
              width: r * 0.9,
              height: r * 1.6,
            ),
            leaf,
          );
          canvas.restore();
        }
      case Garnish.cherry:
        canvas.drawLine(
          rim,
          rim + Offset(r * 0.6, -r * 1.4),
          Paint()
            ..color = const Color(0xFF86A85A)
            ..strokeWidth = s * 0.02
            ..strokeCap = StrokeCap.round,
        );
        canvas.drawCircle(
          rim,
          r * 0.75,
          Paint()..color = const Color(0xFFE8174B),
        );
        canvas.drawCircle(
          rim + Offset(-r * 0.25, -r * 0.25),
          r * 0.2,
          Paint()..color = Colors.white.withValues(alpha: 0.6),
        );
      case Garnish.olive:
        canvas.drawLine(
          rim + Offset(-r * 1.4, -r * 1.2),
          rim + Offset(r * 0.9, r * 0.8),
          Paint()
            ..color = const Color(0xFFF7F1FF)
            ..strokeWidth = s * 0.015,
        );
        canvas.drawOval(
          Rect.fromCenter(center: rim, width: r * 1.5, height: r * 1.2),
          Paint()..color = const Color(0xFF8BB33A),
        );
        canvas.drawCircle(
          rim + Offset(r * 0.35, 0),
          r * 0.22,
          Paint()..color = const Color(0xFFE8174B),
        );
      case Garnish.none:
        break;
    }
  }

  @override
  bool shouldRepaint(GlassPainter old) =>
      old.t != t || old.style != style || old.seed != seed;
}

class _Shape {
  _Shape({
    required this.interior,
    required this.outline,
    required this.liquidTop,
    required this.rim,
    this.ice = false,
    this.straw = false,
  });

  final Path interior;
  final Path outline;
  final double liquidTop;
  final Offset rim;
  final bool ice;
  final bool straw;
}

_Shape _shape(GlassShape glass, Offset Function(double, double) p, double s) {
  Path stemAndBase(double top, double bottom) => Path()
    ..moveTo(p(0.5, top).dx, p(0.5, top).dy)
    ..lineTo(p(0.5, bottom).dx, p(0.5, bottom).dy)
    ..moveTo(p(0.32, bottom).dx, p(0.32, bottom).dy)
    ..lineTo(p(0.68, bottom).dx, p(0.68, bottom).dy);

  switch (glass) {
    case GlassShape.martini:
      final cone = Path()
        ..moveTo(p(0.16, 0.24).dx, p(0.16, 0.24).dy)
        ..lineTo(p(0.84, 0.24).dx, p(0.84, 0.24).dy)
        ..lineTo(p(0.5, 0.6).dx, p(0.5, 0.6).dy)
        ..close();
      return _Shape(
        interior: cone,
        outline: Path.from(cone)..addPath(stemAndBase(0.6, 0.9), Offset.zero),
        liquidTop: 0.31,
        rim: p(0.8, 0.24),
      );
    case GlassShape.flute:
      final bowl = Path()
        ..moveTo(p(0.38, 0.12).dx, p(0.38, 0.12).dy)
        ..lineTo(p(0.62, 0.12).dx, p(0.62, 0.12).dy)
        ..quadraticBezierTo(
          p(0.63, 0.52).dx,
          p(0.63, 0.52).dy,
          p(0.5, 0.6).dx,
          p(0.5, 0.6).dy,
        )
        ..quadraticBezierTo(
          p(0.37, 0.52).dx,
          p(0.37, 0.52).dy,
          p(0.38, 0.12).dx,
          p(0.38, 0.12).dy,
        )
        ..close();
      return _Shape(
        interior: bowl,
        outline: Path.from(bowl)..addPath(stemAndBase(0.6, 0.9), Offset.zero),
        liquidTop: 0.22,
        rim: p(0.62, 0.13),
      );
    case GlassShape.wine:
      final bowl = Path()
        ..moveTo(p(0.27, 0.18).dx, p(0.27, 0.18).dy)
        ..lineTo(p(0.73, 0.18).dx, p(0.73, 0.18).dy)
        ..cubicTo(
          p(0.86, 0.42).dx,
          p(0.86, 0.42).dy,
          p(0.72, 0.62).dx,
          p(0.72, 0.62).dy,
          p(0.5, 0.62).dx,
          p(0.5, 0.62).dy,
        )
        ..cubicTo(
          p(0.28, 0.62).dx,
          p(0.28, 0.62).dy,
          p(0.14, 0.42).dx,
          p(0.14, 0.42).dy,
          p(0.27, 0.18).dx,
          p(0.27, 0.18).dy,
        )
        ..close();
      return _Shape(
        interior: bowl,
        outline: Path.from(bowl)..addPath(stemAndBase(0.62, 0.9), Offset.zero),
        liquidTop: 0.34,
        rim: p(0.72, 0.19),
        ice: true,
      );
    case GlassShape.highball:
      final body = Path()
        ..addRRect(
          RRect.fromRectAndCorners(
            Rect.fromPoints(p(0.3, 0.16), p(0.7, 0.9)),
            bottomLeft: Radius.circular(s * 0.06),
            bottomRight: Radius.circular(s * 0.06),
          ),
        );
      return _Shape(
        interior: body,
        outline: body,
        liquidTop: 0.28,
        rim: p(0.32, 0.17),
        ice: true,
        straw: true,
      );
    case GlassShape.mug:
      final body = Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromPoints(p(0.22, 0.28), p(0.66, 0.88)),
            Radius.circular(s * 0.06),
          ),
        );
      final handle = Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromPoints(p(0.66, 0.4), p(0.82, 0.72)),
            Radius.circular(s * 0.08),
          ),
        );
      return _Shape(
        interior: body,
        outline: Path.from(body)..addPath(handle, Offset.zero),
        liquidTop: 0.36,
        rim: p(0.26, 0.29),
        ice: true,
      );
    case GlassShape.lowball:
      final body = Path()
        ..moveTo(p(0.22, 0.38).dx, p(0.22, 0.38).dy)
        ..lineTo(p(0.78, 0.38).dx, p(0.78, 0.38).dy)
        ..lineTo(p(0.74, 0.88).dx, p(0.74, 0.88).dy)
        ..lineTo(p(0.26, 0.88).dx, p(0.26, 0.88).dy)
        ..close();
      return _Shape(
        interior: body,
        outline: body,
        liquidTop: 0.48,
        rim: p(0.74, 0.39),
        ice: true,
      );
  }
}
