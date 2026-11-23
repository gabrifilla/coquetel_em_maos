// Conversão de receitas do TheCocktailDB para o formato do catalogo.json.
// Só funções puras aqui, para dar para testar sem internet.

/// Ingredientes que, quando vêm sem quantidade ou como guarnição, viram opcionais.
const _guarnicoes = {
  'azeitona',
  'cereja',
  'laranja',
  'hortela',
  'sal',
  'limao',
};

class ImportResult {
  ImportResult(this.recipes, this.unmapped);

  /// Receitas prontas para revisão, no formato do catálogo.
  final List<Map<String, dynamic>> recipes;

  /// Ingredientes sem correspondência no mapa → em quantas receitas aparecem.
  final Map<String, int> unmapped;
}

/// Converte os drinks da API. Ignora os que já existem no catálogo (pelo nome)
/// e os que usam ingrediente fora do [map].
ImportResult convertDrinks(
  List<Map<String, dynamic>> drinks, {
  required Map<String, String> map,
  required Set<String> existingNames,
  required Set<String> existingIds,
}) {
  final recipes = <Map<String, dynamic>>[];
  final unmapped = <String, int>{};
  final usedIds = {...existingIds};
  final usedNames = existingNames.map(normalize).toSet();

  for (final drink in drinks) {
    final name = (drink['strDrink'] as String? ?? '').trim();
    if (name.isEmpty || usedNames.contains(normalize(name))) continue;

    final items = <Map<String, dynamic>>[];
    final extras = <String>[];
    final missing = <String>[];
    for (var n = 1; n <= 15; n++) {
      final raw = (drink['strIngredient$n'] as String?)?.trim() ?? '';
      if (raw.isEmpty) continue;
      final measure = (drink['strMeasure$n'] as String?)?.trim() ?? '';
      final id = map[raw.toLowerCase()];
      if (id == null) {
        missing.add(raw);
      } else if (id == 'extra') {
        extras.add(raw.toLowerCase() == 'water' ? 'água' : 'gelo');
      } else if (!items.any((i) => i['id'] == id)) {
        final garnish =
            _guarnicoes.contains(id) &&
            (measure.isEmpty ||
                RegExp(
                  r'garnish|twist|peel|slice|wedge',
                  caseSensitive: false,
                ).hasMatch(measure));
        items.add({
          'id': id,
          'quantidade': convertMeasure(measure),
          if (garnish) 'opcional': true,
        });
      }
    }

    if (missing.isNotEmpty) {
      for (final m in missing) {
        unmapped[m] = (unmapped[m] ?? 0) + 1;
      }
      continue;
    }
    if (!items.any((i) => i['opcional'] != true)) continue;

    var id = slug(name);
    for (var k = 2; usedIds.contains(id); k++) {
      id = '${slug(name)}_$k';
    }
    usedIds.add(id);
    usedNames.add(normalize(name));

    final instructions = (drink['strInstructions'] as String? ?? '').trim();
    recipes.add({
      'id': id,
      'nome': name,
      'descricao': '',
      'copo': (drink['strGlass'] as String? ?? '').trim(),
      'ingredientes': items,
      if (extras.isNotEmpty) 'extras': extras.toSet().toList(),
      'preparo': splitSteps(instructions),
      if (drink['strDrinkThumb'] is String) 'imagemUrl': drink['strDrinkThumb'],
      'fonte': 'TheCocktailDB #${drink['idDrink']}',
      'traduzido': false,
    });
  }
  return ImportResult(recipes, unmapped);
}

/// "1 1/2 oz" → "45 ml"; "2 cl" → "20 ml"; "1 tsp" → "1 colher de chá".
String convertMeasure(String measure) {
  final m = measure.trim();
  if (m.isEmpty) return 'a gosto';
  final lower = m.toLowerCase();
  if (RegExp(r'^(top|fill)').hasMatch(lower)) return 'para completar';

  final match = RegExp(r'^([\d\s./]+)\s*(.*)$').firstMatch(lower);
  if (match == null) return m;
  final amount = _parseNumber(match.group(1)!);
  final unit = match.group(2)!.trim();
  if (amount == null) return m;

  String fmt(num v) => v == v.roundToDouble()
      ? v.round().toString()
      : v.toStringAsFixed(1).replaceAll('.', ',');
  if (RegExp(r'^oz').hasMatch(unit)) return '${(amount * 30).round()} ml';
  if (RegExp(r'^cl').hasMatch(unit)) return '${(amount * 10).round()} ml';
  if (RegExp(r'^ml').hasMatch(unit)) return '${amount.round()} ml';
  if (RegExp(r'^(tsp|teaspoon)').hasMatch(unit)) {
    return '${fmt(amount)} ${amount == 1 ? 'colher' : 'colheres'} de chá';
  }
  if (RegExp(r'^(tblsp|tbsp|tablespoon)').hasMatch(unit)) {
    return '${fmt(amount)} ${amount == 1 ? 'colher' : 'colheres'} de sopa';
  }
  if (RegExp(r'^dash').hasMatch(unit)) {
    return '${fmt(amount)} ${amount == 1 ? 'dash' : 'dashes'}';
  }
  if (RegExp(r'^cups?$').hasMatch(unit)) {
    return '${fmt(amount)} ${amount == 1 ? 'xícara' : 'xícaras'}';
  }
  if (unit.isEmpty) {
    return '${fmt(amount)} ${amount == 1 ? 'unidade' : 'unidades'}';
  }
  return m;
}

double? _parseNumber(String text) {
  var total = 0.0;
  var found = false;
  for (final part in text.trim().split(RegExp(r'\s+'))) {
    if (part.isEmpty) continue;
    final frac = RegExp(r'^(\d+)/(\d+)$').firstMatch(part);
    final value = frac != null
        ? int.parse(frac.group(1)!) / int.parse(frac.group(2)!)
        : double.tryParse(part);
    if (value == null) return null;
    total += value;
    found = true;
  }
  return found ? total : null;
}

/// Quebra as instruções em passos (uma frase por passo).
List<String> splitSteps(String text) => text
    .split(RegExp(r'(?<=[.!?])\s+|\r?\n'))
    .map((s) => s.trim())
    .where((s) => s.length > 1)
    .toList();

String normalize(String s) {
  const from = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
  const to = 'aaaaaeeeeiiiiooooouuuucn';
  final lower = s.toLowerCase();
  final buffer = StringBuffer();
  for (final ch in lower.split('')) {
    final i = from.indexOf(ch);
    buffer.write(i >= 0 ? to[i] : ch);
  }
  return buffer.toString().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
}

String slug(String s) => normalize(s).replaceAll(' ', '_');
