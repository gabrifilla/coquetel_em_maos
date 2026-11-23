# Coquetel em Mãos

App Flutter que mostra quais coquetéis você consegue preparar com os ingredientes que tem em casa.

## Funcionalidades

- **Coquetéis**: lista o que dá para fazer agora, o que está a 1 ou 2 ingredientes de distância ("Falta pouco") e o catálogo completo, com busca.
- **Receita**: ingredientes com quantidade (marque ali mesmo o que você tem), copo, modo de preparo e botão para mandar o que falta para a lista de compras.
- **Meu bar**: ingredientes agrupados por categoria para marcar o que você tem.
- **Favoritos**: coquetéis marcados com o coração.
- **Lista de compras**: ao marcar um item como comprado, ele vai direto para o seu bar. Também sugere os ingredientes que liberariam mais coquetéis.

Ingredientes opcionais da receita (guarnição, borda de sal etc.) não impedem o preparo.

## Estrutura

```
assets/data/catalogo.json   catálogo de ingredientes e receitas (português)
lib/models/                 Ingredient, Cocktail, Catalog, CocktailMatch
lib/data/                   leitura do catálogo e dados do usuário (shared_preferences)
lib/state/bar_state.dart    estado do app (ChangeNotifier + provider)
lib/screens/                telas
lib/widgets/                componentes reutilizados
```

### Como adicionar um coquetel

Inclua um item em `coqueteis` no `assets/data/catalogo.json`. Cada ingrediente referencia um `id` de `ingredientes` e pode ter `"opcional": true`. O teste `test/catalog_test.dart` confere se os ids existem.

## Rodando

Requer Flutter 3.50+ (Dart 3.14).

```
flutter pub get
flutter run
flutter test
```

Para regerar os ícones: `dart run flutter_launcher_icons`.
