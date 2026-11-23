import 'package:material_ui/material_ui.dart';

/// Aviso fixo em toda receita gerada por IA.
class AiWarning extends StatelessWidget {
  const AiWarning({super.key});

  static const text =
      'Receita gerada por inteligência artificial. '
      'Ela pode não ter um resultado perfeito: prove e ajuste as quantidades a gosto.';

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.tertiaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome, color: colors.onTertiaryContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: colors.onTertiaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}
