import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../models/cocktail_match.dart';
import '../state/bar_state.dart';
import '../widgets/cocktail_tile.dart';
import '../theme/party_theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/party_effects.dart';
import 'ai_recipe_screen.dart';
import 'recipe_editor_screen.dart';

enum _Filter { canMake, almost, all, mine }

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

  /// Destilado escolhido no filtro "Base" (null = qualquer).
  String? _base;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<BarState>();
    final canMake = state.canMake;
    final almost = state.almost;
    final mine = state.matches.where((m) => m.cocktail.isUserRecipe).toList();
    final spirits = state.baseSpirits;

    final List<CocktailMatch> source = switch (_filter) {
      _Filter.canMake => canMake,
      _Filter.almost => almost,
      _Filter.all => state.matches,
      _Filter.mine => mine,
    };
    final query = _query.trim().toLowerCase();
    final visible = source
        .where(
          (m) => query.isEmpty || m.cocktail.name.toLowerCase().contains(query),
        )
        .where((m) => _base == null || m.cocktail.uses(_base!))
        .toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const RecipeEditorScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Nova receita'),
      ),
      body: Column(
        children: [
          _Header(canMakeCount: canMake.length, hasBar: state.owned.isNotEmpty),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: SearchBar(
              hintText: 'Buscar coquetel',
              leading: const Icon(Icons.search),
              elevation: const WidgetStatePropertyAll(0),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          _chipRow([
            _filterChip(_Filter.canMake, 'Posso fazer (${canMake.length})'),
            _filterChip(_Filter.almost, 'Falta pouco (${almost.length})'),
            _filterChip(_Filter.all, 'Todos (${state.matches.length})'),
            _filterChip(_Filter.mine, 'Minhas receitas (${mine.length})'),
          ]),
          const SizedBox(height: 4),
          _chipRow([
            ChoiceChip(
              label: const Text('Qualquer base'),
              selected: _base == null,
              onSelected: (_) => setState(() => _base = null),
            ),
            for (final spirit in spirits)
              ChoiceChip(
                label: Text(spirit.name),
                selected: _base == spirit.id,
                onSelected: (_) => setState(
                  () => _base = _base == spirit.id ? null : spirit.id,
                ),
              ),
          ]),
          const SizedBox(height: 8),
          Expanded(
            child: visible.isEmpty
                ? _emptyState(state)
                : ListView.builder(
                    // Espaço para o botão "Nova receita" não cobrir o último item.
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: visible.length,
                    itemBuilder: (_, i) => CocktailTile(match: visible[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _chipRow(List<Widget> chips) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(spacing: 8, children: chips),
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
    if (_query.trim().isNotEmpty || _base != null) {
      return const EmptyState(
        title: 'Nada encontrado',
        message: 'Nenhum coquetel com esse nome ou base neste filtro.',
      );
    }
    if (_filter == _Filter.mine) {
      return const EmptyState(
        title: 'Nenhuma receita sua ainda',
        message:
            'Toque em "Nova receita" para criar uma, ou use a IA (✨) para '
            'inventar uma com o que você tem.',
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
      _Filter.all || _Filter.mine => const SizedBox.shrink(),
    };
  }
}

/// Topo da tela inicial: nome do app, quantos drinks dá para fazer e o botão da IA.
class _Header extends StatelessWidget {
  const _Header({required this.canMakeCount, required this.hasBar});

  final int canMakeCount;
  final bool hasBar;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final subtitle = !hasBar
        ? 'Monte seu bar e descubra o que dá pra preparar'
        : canMakeCount == 0
        ? 'Quase lá! Veja o que falta pouco'
        : canMakeCount == 1
        ? 'Hoje dá pra fazer 1 drink'
        : 'Hoje dá pra fazer $canMakeCount drinks';

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: Party.headerGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        child: BubblesBackground(
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Semantics(
                          header: true,
                          child: const Text(
                            'Coquetel em Mãos',
                            style: TextStyle(
                              fontFamily: Party.logoFont,
                              fontSize: 30,
                              color: Party.text,
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: text.titleMedium?.copyWith(
                            color: Party.champagne,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Tooltip(
                    message: 'Criar com IA',
                    child: FilledButton.tonalIcon(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.08),
                        foregroundColor: Party.text,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const AiRecipeScreen(),
                        ),
                      ),
                      icon: const Icon(
                        Icons.auto_awesome,
                        color: Party.champagne,
                      ),
                      label: const Text('IA'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
