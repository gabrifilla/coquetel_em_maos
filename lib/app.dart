import 'package:material_ui/material_ui.dart';

import 'screens/home_shell.dart';

/// Cores tiradas do ícone do app.
const coquetelTeal = Color(0xFF235561);
const coquetelCoral = Color(0xFFF2666A);

class CoquetelApp extends StatelessWidget {
  const CoquetelApp({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme(Brightness brightness) {
      final scheme = ColorScheme.fromSeed(
        seedColor: coquetelTeal,
        brightness: brightness,
      ).copyWith(tertiary: coquetelCoral);
      return ThemeData(colorScheme: scheme, useMaterial3: true);
    }

    return MaterialApp(
      title: 'Coquetel em Mãos',
      debugShowCheckedModeBanner: false,
      theme: theme(Brightness.light),
      darkTheme: theme(Brightness.dark),
      home: const HomeShell(),
    );
  }
}
