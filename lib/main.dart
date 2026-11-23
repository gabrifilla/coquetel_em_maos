import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/catalog_loader.dart';
import 'data/user_data_store.dart';
import 'state/bar_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Licenças das fontes embutidas (aparecem em "Licenças" do app).
  LicenseRegistry.addLicense(() async* {
    for (final font in ['Fredoka', 'Pacifico']) {
      final text = await rootBundle.loadString('assets/fonts/OFL-$font.txt');
      yield LicenseEntryWithLineBreaks([font], text);
    }
  });

  final catalog = await loadCatalog();
  final store = await UserDataStore.open();

  runApp(
    ChangeNotifierProvider(
      create: (_) => BarState(catalog: catalog, store: store),
      child: const CoquetelApp(),
    ),
  );
}
