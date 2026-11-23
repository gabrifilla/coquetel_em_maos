import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../data/photo_store.dart';
import '../models/cocktail.dart';
import '../state/bar_state.dart';
import '../theme/drink_style.dart';
import '../theme/party_theme.dart';
import '../widgets/cocktail_image.dart';
import '../widgets/party_effects.dart';
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
    final style = DrinkStyle.of(cocktail);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 300,
            backgroundColor: Party.night,
            title: Text(cocktail.name),
            actions: [
              IconButton(
                tooltip: favorite
                    ? 'Remover dos favoritos'
                    : 'Adicionar aos favoritos',
                icon: Icon(favorite ? Icons.favorite : Icons.favorite_outline),
                color: favorite ? Party.coral : null,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  state.toggleFavorite(cocktail.id);
                },
              ),
              if (cocktail.isUserRecipe) _menu(context, state, cocktail),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [style.bottom.withValues(alpha: 0.28), Party.night],
                  ),
                ),
                child: BubblesBackground(
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 56, bottom: 16),
                      child: Center(
                        child: CocktailImage(
                          cocktail: cocktail,
                          size: 200,
                          animate: true,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            sliver: SliverList.list(
              children: recipeSections(context, cocktail),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menu(BuildContext context, BarState state, Cocktail cocktail) {
    return PopupMenuButton<String>(
      onSelected: (action) async {
        if (action == 'editar') {
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => RecipeEditorScreen(initial: cocktail),
            ),
          );
        } else if (action == 'excluir' && await _confirmDelete(context)) {
          await PhotoStore().delete(cocktail.imagePath);
          state.deleteRecipe(cocktail.id);
          if (context.mounted) Navigator.of(context).pop();
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'editar', child: Text('Editar')),
        PopupMenuItem(value: 'excluir', child: Text('Excluir')),
      ],
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
