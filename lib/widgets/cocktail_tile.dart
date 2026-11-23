import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../models/cocktail.dart';
import '../models/cocktail_match.dart';
import '../screens/cocktail_detail_screen.dart';
import '../state/bar_state.dart';
import 'cocktail_image.dart';

class CocktailTile extends StatelessWidget {
  const CocktailTile({super.key, required this.match});

  final CocktailMatch match;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<BarState>();
    final colors = Theme.of(context).colorScheme;
    final cocktail = match.cocktail;
    final favorite = state.isFavorite(cocktail.id);

    final String status;
    final Color statusColor;
    if (match.canMake) {
      status = 'Você tem tudo!';
      statusColor = colors.primary;
    } else {
      status =
          'Falta: ${match.missingIds.map(state.ingredientName).join(', ')}';
      statusColor = match.isAlmost ? colors.tertiary : colors.onSurfaceVariant;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CocktailImage(cocktail: cocktail),
        title: Row(
          children: [
            Flexible(
              child: Text(cocktail.name, overflow: TextOverflow.ellipsis),
            ),
            if (cocktail.origin == CocktailOrigin.ia) ...[
              const SizedBox(width: 6),
              Icon(Icons.auto_awesome, size: 16, color: colors.tertiary),
            ],
          ],
        ),
        subtitle: Text(
          status,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: statusColor),
        ),
        trailing: IconButton(
          tooltip: favorite
              ? 'Remover dos favoritos'
              : 'Adicionar aos favoritos',
          icon: Icon(favorite ? Icons.favorite : Icons.favorite_outline),
          color: favorite ? colors.tertiary : null,
          onPressed: () => state.toggleFavorite(cocktail.id),
        ),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => CocktailDetailScreen(cocktailId: cocktail.id),
          ),
        ),
      ),
    );
  }
}
