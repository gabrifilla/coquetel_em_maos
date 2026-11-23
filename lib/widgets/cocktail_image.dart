import 'dart:io';

import 'package:material_ui/material_ui.dart';

import '../models/cocktail.dart';
import '../theme/drink_style.dart';
import '../theme/party_theme.dart';
import 'drink_glass.dart';

/// Foto do coquetel (arquivo local ou internet) ou o copo desenhado na cor do drink.
class CocktailImage extends StatelessWidget {
  const CocktailImage({
    super.key,
    required this.cocktail,
    this.size = 56,
    this.animate = false,
  });

  final Cocktail cocktail;
  final double size;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final style = DrinkStyle.of(cocktail);
    final drawn = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [Color(0xFF45303D), Party.surfaceHigh],
          radius: 0.9,
        ),
      ),
      child: DrinkGlass(
        style: style,
        size: size,
        animate: animate,
        seed: cocktail.id.hashCode,
      ),
    );

    final Widget image;
    if (cocktail.imagePath != null) {
      image = Image.file(
        File(cocktail.imagePath!),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => drawn,
      );
    } else if (cocktail.imageUrl != null) {
      image = Image.network(
        cocktail.imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => drawn,
      );
    } else {
      image = drawn;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.3),
      child: image,
    );
  }
}
