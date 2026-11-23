import 'dart:io';
import 'dart:ui' show Color;

import 'package:coquetel_em_maos/data/catalog_loader.dart';
import 'package:coquetel_em_maos/models/catalog.dart';
import 'package:coquetel_em_maos/theme/drink_style.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final catalog = Catalog.fromJsonString(
    File(catalogAssetPath).readAsStringSync(),
  );
  DrinkStyle styleOf(String id) => DrinkStyle.of(catalog.cocktailById(id)!);

  test('copo segue o tipo descrito na receita', () {
    expect(styleOf('dry_martini').glass, GlassShape.martini);
    expect(styleOf('mimosa').glass, GlassShape.flute);
    expect(styleOf('moscow_mule').glass, GlassShape.mug);
    expect(styleOf('aperol_spritz').glass, GlassShape.wine);
    expect(styleOf('mojito').glass, GlassShape.highball);
    expect(styleOf('caipirinha').glass, GlassShape.lowball);
  });

  test('cor e guarnição vêm dos ingredientes', () {
    expect(styleOf('blue_lagoon').bottom, const Color(0xFF1C6CFF));
    expect(styleOf('negroni').bottom, styleOf('negroni').bottom); // estável
    expect(styleOf('dry_martini').garnish, Garnish.olive);
    expect(styleOf('mojito').garnish, Garnish.mint);
    expect(styleOf('manhattan').garnish, Garnish.cherry);
  });

  test('todo coquetel do catálogo tem um estilo', () {
    for (final c in catalog.cocktails) {
      expect(() => DrinkStyle.of(c), returnsNormally, reason: c.id);
    }
  });
}
