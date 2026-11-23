import 'package:material_ui/material_ui.dart';

import 'screens/home_shell.dart';
import 'theme/party_theme.dart';

class CoquetelApp extends StatelessWidget {
  const CoquetelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coquetel em Mãos',
      debugShowCheckedModeBanner: false,
      // Clima de bar à noite em qualquer configuração do aparelho.
      theme: Party.theme(),
      themeMode: ThemeMode.dark,
      darkTheme: Party.theme(),
      home: const HomeShell(),
    );
  }
}
