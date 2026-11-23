import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../widgets/party_effects.dart';

import '../state/bar_state.dart';
import 'cocktails_screen.dart';
import 'favorites_screen.dart';
import 'my_bar_screen.dart';
import 'shopping_list_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  static const _barTab = 1;

  int _index = 0;

  late final BarState _bar = context.read<BarState>();
  late Set<String> _canMakeIds = _currentCanMake();

  @override
  void initState() {
    super.initState();
    _bar.addListener(_celebrateNewDrinks);
  }

  @override
  void dispose() {
    _bar.removeListener(_celebrateNewDrinks);
    super.dispose();
  }

  Set<String> _currentCanMake() =>
      _bar.canMake.map((m) => m.cocktail.id).toSet();

  /// Quando um ingrediente novo libera drinks, comemora com confete.
  void _celebrateNewDrinks() {
    final now = _currentCanMake();
    final unlocked = now.difference(_canMakeIds);
    _canMakeIds = now;
    if (unlocked.isEmpty || !mounted) return;

    final names = unlocked
        .map((id) => _bar.cocktailById(id)?.name)
        .whereType<String>()
        .toList();
    HapticFeedback.mediumImpact();
    showConfetti(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            names.length == 1
                ? '🎉 Liberou: ${names.single}!'
                : '🎉 Liberou ${names.length} drinks: ${names.join(', ')}!',
          ),
        ),
      );
  }

  void _goTo(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    final shoppingCount = context.select<BarState, int>(
      (s) => s.shopping.length,
    );

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          CocktailsScreen(onOpenBar: () => _goTo(_barTab)),
          const MyBarScreen(),
          const FavoritesScreen(),
          const ShoppingListScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _goTo,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.local_bar_outlined),
            selectedIcon: Icon(Icons.local_bar),
            label: 'Coquetéis',
          ),
          const NavigationDestination(
            icon: Icon(Icons.liquor_outlined),
            selectedIcon: Icon(Icons.liquor),
            label: 'Meu bar',
          ),
          const NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: shoppingCount > 0,
              label: Text('$shoppingCount'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: shoppingCount > 0,
              label: Text('$shoppingCount'),
              child: const Icon(Icons.shopping_cart),
            ),
            label: 'Compras',
          ),
        ],
      ),
    );
  }
}
