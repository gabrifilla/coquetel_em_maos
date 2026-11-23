import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

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
