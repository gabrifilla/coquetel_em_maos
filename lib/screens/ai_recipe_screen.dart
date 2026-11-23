import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../data/ai_recipe_service.dart';
import '../models/cocktail.dart';
import '../state/bar_state.dart';
import '../widgets/ai_warning.dart';
import '../widgets/empty_state.dart';
import '../widgets/recipe_view.dart';

/// Gera uma receita com IA usando os ingredientes que o usuário marcou no bar.
class AiRecipeScreen extends StatefulWidget {
  const AiRecipeScreen({super.key, this.service});

  final AiRecipeService? service;

  @override
  State<AiRecipeScreen> createState() => _AiRecipeScreenState();
}

class _AiRecipeScreenState extends State<AiRecipeScreen> {
  static const _minIngredients = 2;

  late final AiRecipeService _service = widget.service ?? AiRecipeService();
  final _wish = TextEditingController();

  /// Ingredientes do bar que o usuário NÃO quer usar nesta receita.
  final _excluded = <String>{};

  bool _loading = false;
  String? _error;
  Cocktail? _result;
  bool _savedResult = false;

  @override
  void dispose() {
    _wish.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<BarState>();
    final result = _result;

    return Scaffold(
      appBar: AppBar(title: Text(result?.name ?? 'Criar com IA')),
      body: !_service.isConfigured
          ? const EmptyState(
              title: 'IA não configurada',
              message:
                  'Esta versão do app foi compilada sem o endereço do servidor de IA.',
            )
          : result != null
          ? RecipeView(cocktail: result, footer: _resultActions(state, result))
          : _form(state),
    );
  }

  Widget _form(BarState state) {
    final theme = Theme.of(context);
    final owned = state.catalog.ingredients
        .where((i) => state.hasIngredient(i.id))
        .toList();
    final selected = owned.where((i) => !_excluded.contains(i.id)).toList();

    if (owned.length < _minIngredients) {
      return const EmptyState(
        title: 'Poucos ingredientes',
        message:
            'Marque pelo menos 2 ingredientes em "Meu bar" para a IA criar uma receita.',
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const AiWarning(),
        const SizedBox(height: 24),
        Text('Usar estes ingredientes', style: theme.textTheme.titleMedium),
        Text(
          'Toque para tirar algum da receita.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final ingredient in owned)
              FilterChip(
                label: Text(ingredient.name),
                selected: !_excluded.contains(ingredient.id),
                onSelected: _loading
                    ? null
                    : (on) => setState(() {
                        on
                            ? _excluded.remove(ingredient.id)
                            : _excluded.add(ingredient.id);
                      }),
              ),
          ],
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _wish,
          enabled: !_loading,
          maxLength: 120,
          decoration: const InputDecoration(
            labelText: 'Algum pedido? (opcional)',
            hintText: 'Ex.: refrescante, pouco doce, para a tarde',
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
        ],
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _loading || selected.length < _minIngredients
              ? null
              : () => _generate(state, selected.map((i) => i.id)),
          icon: _loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.auto_awesome),
          label: Text(_loading ? 'Criando receita...' : 'Gerar receita'),
        ),
      ],
    );
  }

  List<Widget> _resultActions(BarState state, Cocktail result) {
    return [
      const SizedBox(height: 24),
      FilledButton.icon(
        onPressed: _savedResult
            ? null
            : () {
                state.saveRecipe(result);
                setState(() => _savedResult = true);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Salva em "Minhas receitas"')),
                );
              },
        icon: Icon(_savedResult ? Icons.check : Icons.bookmark_add_outlined),
        label: Text(_savedResult ? 'Salva' : 'Salvar nas minhas receitas'),
      ),
      const SizedBox(height: 8),
      OutlinedButton.icon(
        onPressed: () => setState(() {
          _result = null;
          _savedResult = false;
        }),
        icon: const Icon(Icons.refresh),
        label: const Text('Gerar outra'),
      ),
    ];
  }

  Future<void> _generate(BarState state, Iterable<String> ids) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final recipe = await _service.generate({
        for (final id in ids) id: state.ingredientName(id),
      }, wish: _wish.text);
      if (mounted) setState(() => _result = recipe);
    } on AiRecipeException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
