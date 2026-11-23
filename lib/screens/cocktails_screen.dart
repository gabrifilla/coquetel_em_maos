import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../models/cocktail_match.dart';
import '../state/bar_state.dart';
import '../widgets/cocktail_tile.dart';
import '../widgets/empty_state.dart';

enum _Filter { canMake, almost, all }

class CocktailsScreen extends StatefulWidget {
  const CocktailsScreen({super.key, required this.onOpenBar});

  /// Leva o usuário até a aba "Meu bar".
  final VoidCallback onOpenBar;

  @override
  State<CocktailsScreen> createState() => _CocktailsScreenState();
}

class _CocktailsScreenState extends State<CocktailsScreen> {
  _Filter _filter = _Filter.canMake;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<BarState>();
    final canMake = state.canMake;
    final almost = state.almost;

    final List<CocktailMatch> source = switch (_filter) {
      _Filter.canMake => canMake,
      _Filter.almost => almost,
      _Filter.all => state.matches,
    };
    final query = _query.trim().toLowerCase();
    final visible = query.isEmpty
        ? source
        : source
              .where((m) => m.cocktail.name.toLowerCase().contains(query))
              .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Coquetel em Mãos')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SearchBar(
              hintText: 'Buscar coquetel',
              leading: const Icon(Icons.search),
              elevation: const WidgetStatePropertyAll(0),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              spacing: 8,
              children: [
                _filterChip(_Filter.canMake, 'Posso fazer (${canMake.length})'),
                _filterChip(_Filter.almost, 'Falta pouco (${almost.length})'),
                _filterChip(_Filter.all, 'Todos (${state.matches.length})'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: visible.isEmpty
                ? _emptyState(state)
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: visible.length,
                    itemBuilder: (_, i) => CocktailTile(match: visible[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(_Filter filter, String label) {
    return ChoiceChip(
      label: Text(label),
      selected: _filter == filter,
      onSelected: (_) => setState(() => _filter = filter),
    );
  }

  Widget _emptyState(BarState state) {
    if (_query.trim().isNotEmpty) {
      return const EmptyState(
        title: 'Nada encontrado',
        message: 'Nenhum coquetel com esse nome neste filtro.',
      );
    }
    if (state.owned.isEmpty) {
      return EmptyState(
        title: 'Seu bar está vazio',
        message:
            'Marque os ingredientes que você tem em casa e '
            'mostramos o que dá para preparar.',
        action: FilledButton.icon(
          onPressed: widget.onOpenBar,
          icon: const Icon(Icons.liquor),
          label: const Text('Montar meu bar'),
        ),
      );
    }
    return switch (_filter) {
      _Filter.canMake => EmptyState(
        title: 'Ainda não dá para fazer nenhum',
        message:
            'Veja em "Falta pouco" os coquetéis que estão a um ou dois '
            'ingredientes de distância.',
        action: OutlinedButton(
          onPressed: () => setState(() => _filter = _Filter.almost),
          child: const Text('Ver o que falta pouco'),
        ),
      ),
      _Filter.almost => const EmptyState(
        title: 'Nenhum coquetel quase pronto',
        message:
            'Adicione mais ingredientes ao seu bar para ver sugestões aqui.',
      ),
      _Filter.all => const SizedBox.shrink(),
    };
  }
}
