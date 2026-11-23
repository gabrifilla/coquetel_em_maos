import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../data/photo_store.dart';
import '../models/cocktail.dart';
import '../models/ingredient.dart';
import '../state/bar_state.dart';
import '../widgets/cocktail_image.dart';

/// Cria uma receita nova ou edita uma do usuário (inclusive as salvas da IA).
class RecipeEditorScreen extends StatefulWidget {
  const RecipeEditorScreen({super.key, this.initial, this.photoStore});

  final Cocktail? initial;
  final PhotoStore? photoStore;

  @override
  State<RecipeEditorScreen> createState() => _RecipeEditorScreenState();
}

class _EditableItem {
  _EditableItem(this.ingredientId, String amount, this.optional)
    : amount = TextEditingController(text: amount);

  final String ingredientId;
  final TextEditingController amount;
  bool optional;
}

class _RecipeEditorScreenState extends State<RecipeEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _glass;
  late final TextEditingController _extras;
  late final TextEditingController _steps;
  late final List<_EditableItem> _items;
  late final PhotoStore _photos = widget.photoStore ?? PhotoStore();
  String? _imagePath;
  final _discardedPhotos = <String>[];
  final _newPhotos = <String>[];
  bool _saved = false;

  bool get _isNew => widget.initial == null;

  @override
  void initState() {
    super.initState();
    final c = widget.initial;
    _name = TextEditingController(text: c?.name);
    _description = TextEditingController(text: c?.description);
    _glass = TextEditingController(text: c?.glass);
    _extras = TextEditingController(text: c?.extras.join(', '));
    _steps = TextEditingController(text: c?.steps.join('\n'));
    _items = [
      for (final i in c?.items ?? const <RecipeItem>[])
        _EditableItem(i.ingredientId, i.amount, i.optional),
    ];
    _imagePath = c?.imagePath;
  }

  @override
  void dispose() {
    for (final c in [_name, _description, _glass, _extras, _steps]) {
      c.dispose();
    }
    for (final i in _items) {
      i.amount.dispose();
    }
    // Saiu sem salvar: apaga as fotos escolhidas nesta edição.
    if (!_saved) {
      for (final path in _newPhotos) {
        _photos.delete(path);
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.read<BarState>();
    final theme = Theme.of(context);
    final preview = Cocktail(
      id: '',
      name: '',
      description: '',
      glass: '',
      items: const [],
      steps: const [],
      origin: widget.initial?.origin ?? CocktailOrigin.usuario,
      imagePath: _imagePath,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? 'Nova receita' : 'Editar receita'),
        actions: [TextButton(onPressed: _save, child: const Text('Salvar'))],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: Column(
                children: [
                  CocktailImage(cocktail: preview, size: 120),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      TextButton.icon(
                        onPressed: () => _pickPhoto(fromCamera: true),
                        icon: const Icon(Icons.photo_camera_outlined),
                        label: const Text('Câmera'),
                      ),
                      TextButton.icon(
                        onPressed: () => _pickPhoto(fromCamera: false),
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('Galeria'),
                      ),
                      if (_imagePath != null)
                        TextButton.icon(
                          onPressed: () => setState(() {
                            _discardedPhotos.add(_imagePath!);
                            _imagePath = null;
                          }),
                          icon: const Icon(Icons.hide_image_outlined),
                          label: const Text('Remover'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Nome'),
              validator: (v) =>
                  (v ?? '').trim().isEmpty ? 'Dê um nome à receita' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _description,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Descrição (opcional)',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _glass,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Copo (opcional)'),
            ),
            const SizedBox(height: 24),
            Text('Ingredientes', style: theme.textTheme.titleMedium),
            for (final item in _items) _itemRow(state, item),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _addIngredient(state),
              icon: const Icon(Icons.add),
              label: const Text('Adicionar ingrediente'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _extras,
              decoration: const InputDecoration(
                labelText: 'Extras (opcional)',
                helperText:
                    'Separados por vírgula. Não contam para "posso fazer". Ex.: gelo, canela',
                helperMaxLines: 2,
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _steps,
              minLines: 4,
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Modo de preparo',
                helperText: 'Um passo por linha',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              validator: (v) => _lines(v ?? '').isEmpty
                  ? 'Escreva pelo menos um passo'
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemRow(BarState state, _EditableItem item) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(state.ingredientName(item.ingredientId)),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 4,
            child: TextFormField(
              controller: item.amount,
              decoration: const InputDecoration(
                hintText: 'Quantidade',
                isDense: true,
              ),
            ),
          ),
          IconButton(
            tooltip: item.optional ? 'Opcional' : 'Obrigatório',
            icon: Icon(
              item.optional ? Icons.radio_button_unchecked : Icons.check_circle,
            ),
            onPressed: () => setState(() => item.optional = !item.optional),
          ),
          IconButton(
            tooltip: 'Remover ingrediente',
            icon: const Icon(Icons.close),
            onPressed: () => setState(() {
              _items.remove(item);
              item.amount.dispose();
            }),
          ),
        ],
      ),
    );
  }

  Future<void> _addIngredient(BarState state) async {
    final used = _items.map((i) => i.ingredientId).toSet();
    final chosen = await showModalBottomSheet<Ingredient>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _IngredientPicker(
        ingredients: state.catalog.ingredients
            .where((i) => !used.contains(i.id))
            .toList(),
      ),
    );
    if (chosen != null) {
      setState(() => _items.add(_EditableItem(chosen.id, '', false)));
    }
  }

  Future<void> _pickPhoto({required bool fromCamera}) async {
    final path = await _photos.pick(fromCamera: fromCamera);
    if (path == null || !mounted) return;
    _newPhotos.add(path);
    setState(() {
      if (_imagePath != null) _discardedPhotos.add(_imagePath!);
      _imagePath = path;
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione pelo menos um ingrediente')),
      );
      return;
    }

    final base = widget.initial;
    final recipe = Cocktail(
      id: base?.id ?? 'u_${DateTime.now().microsecondsSinceEpoch}',
      name: _name.text.trim(),
      description: _description.text.trim(),
      glass: _glass.text.trim(),
      items: [
        for (final i in _items)
          RecipeItem(
            ingredientId: i.ingredientId,
            amount: i.amount.text.trim().isEmpty
                ? 'a gosto'
                : i.amount.text.trim(),
            optional: i.optional,
          ),
      ],
      steps: _lines(_steps.text),
      extras: _extras.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      origin: base?.origin ?? CocktailOrigin.usuario,
      imagePath: _imagePath,
    );
    context.read<BarState>().saveRecipe(recipe);
    _saved = true;
    // Fotos substituídas ou removidas só são apagadas depois de salvar.
    for (final path in _discardedPhotos) {
      _photos.delete(path);
    }
    Navigator.of(context).pop(recipe);
  }

  static List<String> _lines(String text) =>
      text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
}

class _IngredientPicker extends StatefulWidget {
  const _IngredientPicker({required this.ingredients});

  final List<Ingredient> ingredients;

  @override
  State<_IngredientPicker> createState() => _IngredientPickerState();
}

class _IngredientPickerState extends State<_IngredientPicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final list = widget.ingredients
        .where((i) => i.name.toLowerCase().contains(q))
        .toList();
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.7,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SearchBar(
              autoFocus: true,
              hintText: 'Buscar ingrediente',
              leading: const Icon(Icons.search),
              elevation: const WidgetStatePropertyAll(0),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (_, i) => ListTile(
                title: Text(list[i].name),
                subtitle: Text(list[i].category.label),
                onTap: () => Navigator.pop(context, list[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
