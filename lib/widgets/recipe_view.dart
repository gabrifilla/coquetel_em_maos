import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../models/cocktail.dart';
import '../state/bar_state.dart';
import '../theme/drink_style.dart';
import '../theme/party_theme.dart';
import 'ai_warning.dart';
import 'cocktail_image.dart';

/// Corpo de uma receita em lista simples (usado na prévia da IA).
class RecipeView extends StatelessWidget {
  const RecipeView({super.key, required this.cocktail, this.footer = const []});

  final Cocktail cocktail;

  /// Widgets extras no fim da lista (ex.: botões da tela de IA).
  final List<Widget> footer;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        Center(
          child: CocktailImage(cocktail: cocktail, size: 180, animate: true),
        ),
        const SizedBox(height: 16),
        ...recipeSections(context, cocktail),
        ...footer,
      ],
    );
  }
}

/// Seções da receita: aviso de IA, status, ingredientes e modo de preparo.
List<Widget> recipeSections(BuildContext context, Cocktail cocktail) {
  final state = context.watch<BarState>();
  final match = state.matchFor(cocktail);
  final text = Theme.of(context).textTheme;
  final style = DrinkStyle.of(cocktail);
  final toBuy = match.missingIds
      .where((id) => !state.isInShoppingList(id))
      .toList();

  return [
    if (cocktail.origin == CocktailOrigin.ia) ...[
      const AiWarning(),
      const SizedBox(height: 16),
    ],
    if (cocktail.description.isNotEmpty) ...[
      Text(cocktail.description, style: text.bodyLarge?.copyWith(height: 1.4)),
      const SizedBox(height: 12),
    ],
    if (cocktail.glass.isNotEmpty)
      Row(
        children: [
          const Icon(Icons.wine_bar_outlined, size: 20, color: Party.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              cocktail.glass,
              style: text.bodyMedium?.copyWith(color: Party.textMuted),
            ),
          ),
        ],
      ),
    const SizedBox(height: 16),
    _StatusBanner(missing: match.missingIds.length, accent: style.bottom),
    const SizedBox(height: 28),
    const _SectionTitle(emoji: '🧉', title: 'Ingredientes'),
    Text(
      'Toque para marcar o que você tem.',
      style: text.bodySmall?.copyWith(color: Party.textMuted),
    ),
    const SizedBox(height: 6),
    for (final item in cocktail.items)
      CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        value: state.hasIngredient(item.ingredientId),
        onChanged: (_) {
          HapticFeedback.selectionClick();
          state.toggleIngredient(item.ingredientId);
        },
        title: Text(
          state.ingredientName(item.ingredientId),
          style: text.titleMedium,
        ),
        subtitle: Text(
          item.optional ? '${item.amount} · opcional' : item.amount,
          style: TextStyle(color: style.top),
        ),
      ),
    for (final extra in cocktail.extras)
      ListTile(
        contentPadding: const EdgeInsets.only(left: 12),
        leading: const Text('🧊', style: TextStyle(fontSize: 18)),
        title: Text(extra),
        subtitle: const Text('extra', style: TextStyle(color: Party.textMuted)),
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
                    ? '🛒 1 ingrediente foi para a lista de compras'
                    : '🛒 ${toBuy.length} ingredientes foram para a lista de compras',
              ),
            ),
          );
        },
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('Adicionar o que falta à lista de compras'),
      ),
    ],
    const SizedBox(height: 28),
    const _SectionTitle(emoji: '🍸', title: 'Modo de preparo'),
    const SizedBox(height: 8),
    for (final (index, step) in cocktail.steps.indexed)
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: style.liquid,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A0F2E),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text(
                  step,
                  style: text.bodyLarge?.copyWith(height: 1.35),
                ),
              ),
            ),
          ],
        ),
      ),
  ];
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.emoji, required this.title});

  final String emoji;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(
        '$emoji  $title',
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.missing, required this.accent});

  final int missing;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final canMake = missing == 0;
    final message = canMake
        ? 'Você tem tudo para preparar este coquetel.'
        : missing == 1
        ? 'Falta 1 ingrediente.'
        : 'Faltam $missing ingredientes.';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: canMake
            ? LinearGradient(
                colors: [
                  Party.lime.withValues(alpha: 0.22),
                  accent.withValues(alpha: 0.18),
                ],
              )
            : null,
        color: canMake ? null : Party.surface,
        border: Border.all(
          color: canMake ? Party.lime.withValues(alpha: 0.6) : Party.outline,
        ),
      ),
      child: Row(
        children: [
          Text(canMake ? '🥳' : '🛒', style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: canMake ? Party.lime : Party.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
