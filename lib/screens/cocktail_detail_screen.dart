import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../state/bar_state.dart';

class CocktailDetailScreen extends StatelessWidget {
  const CocktailDetailScreen({super.key, required this.cocktailId});

  final String cocktailId;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<BarState>();
    final cocktail = state.catalog.cocktailById(cocktailId)!;
    final match = state.matchFor(cocktail);
    final favorite = state.isFavorite(cocktail.id);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final toBuy = match.missingIds
        .where((id) => !state.isInShoppingList(id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(cocktail.name),
        actions: [
          IconButton(
            tooltip: favorite
                ? 'Remover dos favoritos'
                : 'Adicionar aos favoritos',
            icon: Icon(favorite ? Icons.favorite : Icons.favorite_outline),
            color: favorite ? colors.tertiary : null,
            onPressed: () => state.toggleFavorite(cocktail.id),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(cocktail.description, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 12),
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
                  Expanded(
                    child: Text(step, style: theme.textTheme.bodyMedium),
                  ),
                ],
              ),
            ),
        ],
      ),
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
