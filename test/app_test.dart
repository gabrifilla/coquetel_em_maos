import 'dart:io';

import 'package:coquetel_em_maos/app.dart';
import 'package:coquetel_em_maos/data/catalog_loader.dart';
import 'package:coquetel_em_maos/data/user_data_store.dart';
import 'package:coquetel_em_maos/models/catalog.dart';
import 'package:coquetel_em_maos/screens/my_bar_screen.dart';
import 'package:coquetel_em_maos/state/bar_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('montar o bar mostra a caipirinha e permite favoritar', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final catalog = Catalog.fromJsonString(
      File(catalogAssetPath).readAsStringSync(),
    );
    final state = BarState(catalog: catalog, store: await UserDataStore.open());

    await tester.pumpWidget(
      ChangeNotifierProvider.value(value: state, child: const CoquetelApp()),
    );

    expect(find.text('Seu bar está vazio'), findsOneWidget);

    await tester.tap(find.text('Montar meu bar'));
    await tester.pumpAndSettle();
    for (final name in ['Cachaça', 'Limão taiti', 'Açúcar']) {
      final chip = find.widgetWithText(FilterChip, name);
      await tester.scrollUntilVisible(
        chip,
        100,
        scrollable: find
            .descendant(
              of: find.byType(MyBarScreen),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.tap(chip);
      await tester.pump();
    }

    await tester.tap(find.text('Coquetéis').last);
    await tester.pumpAndSettle();
    expect(find.text('Caipirinha'), findsOneWidget);
    expect(find.text('Posso fazer (1)'), findsOneWidget);

    await tester.tap(find.text('Caipirinha'));
    await tester.pumpAndSettle();
    expect(
      find.text('Você tem tudo para preparar este coquetel.'),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Adicionar aos favoritos'));
    await tester.pump();
    expect(state.isFavorite('caipirinha'), isTrue);
  });
}
