import 'dart:io';

import 'package:material_ui/material_ui.dart';

import '../models/cocktail.dart';

/// Foto do coquetel: arquivo local, imagem da internet ou um ícone.
class CocktailImage extends StatelessWidget {
  const CocktailImage({super.key, required this.cocktail, this.size = 40});

  final Cocktail cocktail;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final placeholder = Container(
      width: size,
      height: size,
      color: colors.primaryContainer,
      child: Icon(
        cocktail.origin == CocktailOrigin.ia
            ? Icons.auto_awesome
            : Icons.local_bar,
        size: size * 0.5,
        color: colors.onPrimaryContainer,
      ),
    );

    final Widget image;
    if (cocktail.imagePath != null) {
      image = Image.file(
        File(cocktail.imagePath!),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => placeholder,
      );
    } else if (cocktail.imageUrl != null) {
      image = Image.network(
        cocktail.imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => placeholder,
      );
    } else {
      image = placeholder;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(size / 4),
      child: image,
    );
  }
}
