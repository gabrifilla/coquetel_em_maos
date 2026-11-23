import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/catalog_loader.dart';
import 'data/user_data_store.dart';
import 'state/bar_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final catalog = await loadCatalog();
  final store = await UserDataStore.open();

  runApp(
    ChangeNotifierProvider(
      create: (_) => BarState(catalog: catalog, store: store),
      child: const CoquetelApp(),
    ),
  );
}
