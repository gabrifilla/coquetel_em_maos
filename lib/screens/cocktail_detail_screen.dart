import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../data/photo_store.dart';
import '../state/bar_state.dart';
import '../widgets/recipe_view.dart';
import 'recipe_editor_screen.dart';

class CocktailDetailScreen extends StatelessWidget {
  const CocktailDetailScreen({super.key, required this.cocktailId});

  final String cocktailId;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<BarState>();
    final cocktail = state.cocktailById(cocktailId);
    // A receita pode ter sido excluída enquanto a tela fechava.
    if (cocktail == null) return const Scaffold();

    final favorite = state.isFavorite(cocktail.id);
    final colors = Theme.of(context).colorScheme;

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
          if (cocktail.isUserRecipe)
            PopupMenuButton<String>(
              onSelected: (action) async {
                if (action == 'editar') {
                  await Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => RecipeEditorScreen(initial: cocktail),
                    ),
                  );
                } else if (action == 'excluir' &&
                    await _confirmDelete(context)) {
                  await PhotoStore().delete(cocktail.imagePath);
                  state.deleteRecipe(cocktail.id);
                  if (context.mounted) Navigator.of(context).pop();
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'editar', child: Text('Editar')),
                PopupMenuItem(value: 'excluir', child: Text('Excluir')),
              ],
            ),
        ],
      ),
      body: RecipeView(cocktail: cocktail),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir esta receita?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }
}
