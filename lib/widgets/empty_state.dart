import 'package:material_ui/material_ui.dart';

import '../theme/drink_style.dart';
import '../theme/party_theme.dart';
import 'drink_glass.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.action,
  });

  final String title;
  final String message;
  final Widget? action;

  static const _style = DrinkStyle(
    top: Color(0xFFFF8FB1),
    bottom: Party.coral,
    glass: GlassShape.martini,
    garnish: Garnish.lime,
  );

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const DrinkGlass(style: _style, size: 140, animate: true),
            const SizedBox(height: 20),
            Text(title, style: text.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              message,
              style: text.bodyLarge?.copyWith(color: Party.textMuted),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[const SizedBox(height: 24), action!],
          ],
        ),
      ),
    );
  }
}
