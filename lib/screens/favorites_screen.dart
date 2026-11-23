import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../state/bar_state.dart';
import '../widgets/cocktail_tile.dart';
import '../widgets/empty_state.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<BarState>().favoriteMatches;

    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      body: favorites.isEmpty
          ? const EmptyState(
              title: 'Nenhum favorito ainda',
              message: 'Toque no coração de um coquetel para guardá-lo aqui.',
            )
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: favorites.length,
              itemBuilder: (_, i) => CocktailTile(match: favorites[i]),
            ),
    );
  }
}
