import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../models/ingredient.dart';
import '../state/bar_state.dart';
import '../widgets/empty_state.dart';

class ShoppingListScreen extends StatelessWidget {
  const ShoppingListScreen({super.key});

  /// Quantas sugestões de compra mostrar.
  static const _maxSuggestions = 5;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<BarState>();
    final theme = Theme.of(context);
    final items = state.shoppingIngredients;
    final suggestions = _suggestions(state);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de compras 🛒'),
        actions: [
          if (items.isNotEmpty)
            IconButton(
              tooltip: 'Limpar lista',
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () => _confirmClear(context, state),
            ),
        ],
      ),
      body: items.isEmpty && suggestions.isEmpty
          ? const EmptyState(
              title: 'Lista vazia',
              message:
                  'Na tela de um coquetel, adicione aqui os ingredientes que faltam.',
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                if (items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Sua lista está vazia.'),
                  )
                else ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Text(
                      'Marque o que comprou e o item vai direto para o seu bar.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  for (final ingredient in items)
                    _ShoppingItem(ingredient: ingredient),
                ],
                if (suggestions.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
                    child: Text(
                      'Sugestões de compra',
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                  for (final ingredient in suggestions)
                    ListTile(
                      leading: const Icon(Icons.lightbulb_outline),
                      title: Text(ingredient.name),
                      subtitle: Text(
                        _unlocksText(state.unlocksIfBought(ingredient.id)),
                      ),
                      trailing: IconButton(
                        tooltip: 'Adicionar à lista',
                        icon: const Icon(Icons.add_shopping_cart),
                        onPressed: () => state.addToShopping([ingredient.id]),
                      ),
                    ),
                ],
              ],
            ),
    );
  }

  /// Ingredientes que, sozinhos, liberam mais coquetéis e ainda não estão na lista.
  List<Ingredient> _suggestions(BarState state) {
    final candidates =
        state.catalog.ingredients
            .where(
              (i) =>
                  !state.hasIngredient(i.id) && !state.isInShoppingList(i.id),
            )
            .map((i) => (ingredient: i, unlocks: state.unlocksIfBought(i.id)))
            .where((c) => c.unlocks > 0)
            .toList()
          ..sort((a, b) => b.unlocks.compareTo(a.unlocks));
    return candidates.take(_maxSuggestions).map((c) => c.ingredient).toList();
  }

  Future<void> _confirmClear(BuildContext context, BarState state) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar lista de compras?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) state.clearShopping();
  }
}

String _unlocksText(int count) =>
    count == 1 ? 'Libera 1 coquetel' : 'Libera $count coquetéis';

class _ShoppingItem extends StatelessWidget {
  const _ShoppingItem({required this.ingredient});

  final Ingredient ingredient;

  @override
  Widget build(BuildContext context) {
    final state = context.read<BarState>();
    final unlocks = state.unlocksIfBought(ingredient.id);

    return Dismissible(
      key: ValueKey(ingredient.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        color: Theme.of(context).colorScheme.errorContainer,
        child: const Icon(Icons.delete_outline),
      ),
      onDismissed: (_) => state.removeFromShopping(ingredient.id),
      child: CheckboxListTile(
        controlAffinity: ListTileControlAffinity.leading,
        value: false,
        onChanged: (_) {
          state.markBought(ingredient.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${ingredient.name} foi para o seu bar')),
          );
        },
        title: Text(ingredient.name),
        subtitle: unlocks > 0 ? Text(_unlocksText(unlocks)) : null,
      ),
    );
  }
}
