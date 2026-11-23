import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../models/cocktail.dart';
import '../state/bar_state.dart';
import 'ai_warning.dart';
import 'cocktail_image.dart';

/// Corpo de uma receita: foto, aviso de IA, ingredientes e modo de preparo.
class RecipeView extends StatelessWidget {
  const RecipeView({super.key, required this.cocktail, this.footer = const []});

  final Cocktail cocktail;

  /// Widgets extras no fim da lista (ex.: botões da tela de IA).
  final List<Widget> footer;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<BarState>();
    final match = state.matchFor(cocktail);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final toBuy = match.missingIds
        .where((id) => !state.isInShoppingList(id))
        .toList();
    final hasImage = cocktail.imagePath != null || cocktail.imageUrl != null;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (hasImage) ...[
          Center(child: CocktailImage(cocktail: cocktail, size: 220)),
          const SizedBox(height: 16),
        ],
        if (cocktail.origin == CocktailOrigin.ia) ...[
          const AiWarning(),
          const SizedBox(height: 16),
        ],
        if (cocktail.description.isNotEmpty) ...[
          Text(cocktail.description, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 12),
        ],
        if (cocktail.glass.isNotEmpty)
          Row(
            children: [
              Icon(
                Icons.wine_bar_outlined,
                size: 20,
                color: colors.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(cocktail.glass, style: theme.textTheme.bodyMedium),
              ),
            ],
          ),
        const SizedBox(height: 16),
        _StatusBanner(missing: match.missingIds.length),
        const SizedBox(height: 24),
        Text('Ingredientes', style: theme.textTheme.titleMedium),
        Text(
          'Toque em um ingrediente para marcar se você tem.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        for (final item in cocktail.items)
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: state.hasIngredient(item.ingredientId),
            onChanged: (_) => state.toggleIngredient(item.ingredientId),
            title: Text(state.ingredientName(item.ingredientId)),
            subtitle: Text(
              item.optional ? '${item.amount} · opcional' : item.amount,
            ),
          ),
        for (final extra in cocktail.extras)
          ListTile(
            contentPadding: const EdgeInsets.only(left: 12),
            leading: const Icon(Icons.add, size: 20),
            title: Text(extra),
            subtitle: const Text('extra'),
          ),
        if (toBuy.isNotEmpty) ...[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              state.addToShopping(toBuy);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    toBuy.length == 1
                        ? '1 ingrediente adicionado à lista de compras'
                        : '${toBuy.length} ingredientes adicionados à lista de compras',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Adicionar o que falta à lista de compras'),
          ),
        ],
        const SizedBox(height: 24),
        Text('Modo de preparo', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final (index, step) in cocktail.steps.indexed)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: colors.primaryContainer,
                  child: Text(
                    '${index + 1}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(step, style: theme.textTheme.bodyMedium)),
              ],
            ),
          ),
        ...footer,
      ],
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.missing});

  final int missing;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final canMake = missing == 0;
    final background = canMake
        ? colors.primaryContainer
        : colors.surfaceContainerHighest;
    final foreground = canMake ? colors.onPrimaryContainer : colors.onSurface;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            canMake ? Icons.check_circle : Icons.info_outline,
            color: foreground,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              canMake
                  ? 'Você tem tudo para preparar este coquetel.'
                  : missing == 1
                  ? 'Falta 1 ingrediente.'
                  : 'Faltam $missing ingredientes.',
              style: TextStyle(color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}
