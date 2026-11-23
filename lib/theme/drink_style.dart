import 'package:material_ui/material_ui.dart';

import '../models/cocktail.dart';

enum GlassShape { martini, highball, lowball, flute, wine, mug }

/// Garnições que o desenho do copo sabe mostrar.
enum Garnish { lime, orange, mint, cherry, olive, none }

/// Cor do líquido, formato do copo e guarnição de um coquetel.
class DrinkStyle {
  const DrinkStyle({
    required this.top,
    required this.bottom,
    required this.glass,
    required this.garnish,
  });

  factory DrinkStyle.of(Cocktail cocktail) {
    final ids = cocktail.items.map((i) => i.ingredientId).toSet();
    final colors = _liquidFor(ids) ?? _fallback(cocktail.id);
    return DrinkStyle(
      top: colors.$1,
      bottom: colors.$2,
      glass: _glassFor(cocktail.glass),
      garnish: _garnishFor(ids),
    );
  }

  final Color top;
  final Color bottom;
  final GlassShape glass;
  final Garnish garnish;

  @override
  bool operator ==(Object other) =>
      other is DrinkStyle &&
      other.top == top &&
      other.bottom == bottom &&
      other.glass == glass &&
      other.garnish == garnish;

  @override
  int get hashCode => Object.hash(top, bottom, glass, garnish);

  LinearGradient get liquid => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [top, bottom],
  );

  /// Ingrediente mais "colorido" decide a cor do drink (ordem importa).
  static (Color, Color)? _liquidFor(Set<String> ids) {
    const table = <String, (Color, Color)>{
      'curacau_blue': (Color(0xFF5AE4FF), Color(0xFF1C6CFF)),
      'groselha': (Color(0xFFFFB347), Color(0xFFE8174B)),
      'suco_tomate': (Color(0xFFFF6A4D), Color(0xFFB3122E)),
      'campari': (Color(0xFFFF5A5F), Color(0xFFB0102F)),
      'aperol': (Color(0xFFFFA24A), Color(0xFFFF5A2E)),
      'suco_cranberry': (Color(0xFFFF7AA8), Color(0xFFD6145F)),
      'licor_cafe': (Color(0xFFC99A6E), Color(0xFF4A2616)),
      'cafe': (Color(0xFFC99A6E), Color(0xFF4A2616)),
      'vermute_rosso': (Color(0xFFE0703B), Color(0xFF7A1F1A)),
      'bourbon': (Color(0xFFFFC46B), Color(0xFFC7681C)),
      'suco_laranja': (Color(0xFFFFD25E), Color(0xFFFF8A1F)),
      'suco_abacaxi': (Color(0xFFFFF0A0), Color(0xFFFFC93C)),
      'leite_coco': (Color(0xFFFFFBF2), Color(0xFFF1E3C8)),
      'leite_condensado': (Color(0xFFFFFBF2), Color(0xFFF1E3C8)),
      'creme_leite': (Color(0xFFF2E2CF), Color(0xFFB98A62)),
      'agua_tonica': (Color(0xFFF2F8FA), Color(0xFFCFE3EA)),
      'hortela': (Color(0xFFF7F8EE), Color(0xFFDCE5C6)),
      'ginger_beer': (Color(0xFFFFF1BF), Color(0xFFE8B84A)),
      'refrigerante_cola': (Color(0xFF8A4B2A), Color(0xFF2A1208)),
      'espumante': (Color(0xFFFFF6C9), Color(0xFFFFD86B)),
      'suco_toranja': (Color(0xFFFFC2B0), Color(0xFFFF7C6B)),
      // Caipirinha e afins: translúcido, branco com um toque de limão.
      'limao': (Color(0xFFFBF9EE), Color(0xFFE4E7C8)),
    };
    for (final entry in table.entries) {
      if (ids.contains(entry.key)) return entry.value;
    }
    return null;
  }

  static (Color, Color) _fallback(String id) {
    const options = [
      (Color(0xFFFF8FB1), Color(0xFFFF3D7F)),
      (Color(0xFFB79CFF), Color(0xFF7A4DFF)),
      (Color(0xFF8BF0E6), Color(0xFF1FB8B0)),
      (Color(0xFFFFE08A), Color(0xFFFFA62B)),
    ];
    return options[id.codeUnits.fold(0, (a, b) => a + b) % options.length];
  }

  static GlassShape _glassFor(String glass) {
    final g = glass.toLowerCase();
    if (g.contains('martini') ||
        g.contains('coupe') ||
        g.contains('margarita')) {
      return GlassShape.martini;
    }
    if (g.contains('flute')) return GlassShape.flute;
    if (g.contains('caneca') || g.contains('mug')) return GlassShape.mug;
    if (g.contains('vinho') || g.contains('balão') || g.contains('wine')) {
      return GlassShape.wine;
    }
    if (g.contains('alto') ||
        g.contains('highball') ||
        g.contains('collins') ||
        g.contains('hurricane')) {
      return GlassShape.highball;
    }
    return GlassShape.lowball;
  }

  static Garnish _garnishFor(Set<String> ids) {
    if (ids.contains('azeitona')) return Garnish.olive;
    if (ids.contains('cereja')) return Garnish.cherry;
    if (ids.contains('hortela')) return Garnish.mint;
    if (ids.contains('limao')) return Garnish.lime;
    if (ids.contains('laranja') || ids.contains('suco_laranja')) {
      return Garnish.orange;
    }
    return Garnish.none;
  }
}
