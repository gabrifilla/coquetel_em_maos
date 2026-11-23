import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../models/cocktail.dart';
import '../models/cocktail_match.dart';
import '../screens/cocktail_detail_screen.dart';
import '../state/bar_state.dart';
import '../theme/drink_style.dart';
import '../theme/party_theme.dart';
import 'cocktail_image.dart';

class CocktailTile extends StatelessWidget {
  const CocktailTile({super.key, required this.match});

  final CocktailMatch match;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<BarState>();
    final text = Theme.of(context).textTheme;
    final cocktail = match.cocktail;
    final favorite = state.isFavorite(cocktail.id);
    final style = DrinkStyle.of(cocktail);

    final (String status, Color statusColor) = match.canMake
        ? ('Bora! Você tem tudo 🎉', Party.lime)
        : (
            'Falta: ${match.missingIds.map(state.ingredientName).join(', ')}',
            match.isAlmost ? Party.citrus : Party.textMuted,
          );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Material(
        color: Party.surface,
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => CocktailDetailScreen(cocktailId: cocktail.id),
            ),
          ),
          child: Container(
            // Faixa na cor do drink à esquerda.
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: match.canMake ? style.bottom : Party.outline,
                  width: 5,
                ),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
            child: Row(
              children: [
                CocktailImage(cocktail: cocktail),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              cocktail.name,
                              style: text.titleMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (cocktail.origin == CocktailOrigin.ia) ...[
                            const SizedBox(width: 6),
                            const _Badge(label: 'IA', color: Party.citrus),
                          ] else if (cocktail.origin ==
                              CocktailOrigin.usuario) ...[
                            const SizedBox(width: 6),
                            const _Badge(label: 'MINHA', color: Party.lagoon),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        status,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodyMedium?.copyWith(color: statusColor),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: favorite
                      ? 'Remover dos favoritos'
                      : 'Adicionar aos favoritos',
                  icon: Icon(
                    favorite ? Icons.favorite : Icons.favorite_outline,
                  ),
                  color: favorite ? Party.pink : Party.textMuted,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    state.toggleFavorite(cocktail.id);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
