# Coquetel em Mãos

App Flutter que mostra quais coquetéis você consegue preparar com os ingredientes que tem em casa.

## Funcionalidades

- **Coquetéis**: lista o que dá para fazer agora, o que está a 1 ou 2 ingredientes de distância ("Falta pouco") e o catálogo completo, com busca.
- **Receita**: ingredientes com quantidade (marque ali mesmo o que você tem), copo, modo de preparo e botão para mandar o que falta para a lista de compras.
- **Meu bar**: ingredientes agrupados por categoria para marcar o que você tem.
- **Favoritos**: coquetéis marcados com o coração.
- **Lista de compras**: ao marcar um item como comprado, ele vai direto para o seu bar. Também sugere os ingredientes que liberariam mais coquetéis.

- **Minhas receitas**: crie, edite e exclua receitas próprias, com foto da câmera ou da galeria. Elas entram na mesma busca de "posso fazer / falta pouco".
- **Filtro por base**: mostra só os coquetéis com cachaça, vodka, gin etc.
- **Criar com IA** (✨): gera uma receita usando só os ingredientes que você tem. Toda receita gerada por IA vem com um aviso de que pode não ter um resultado perfeito. Você pode salvá-la nas suas receitas. Precisa do backend descrito em [`backend/README.md`](backend/README.md).

Ingredientes opcionais da receita (guarnição, borda de sal etc.) não impedem o preparo. "Extras" (gelo, água) aparecem na receita, mas não contam para a correspondência.

## Estrutura

```
assets/data/catalogo.json   catálogo de ingredientes e receitas (português)
lib/models/                 Ingredient, Cocktail, Catalog, CocktailMatch
lib/data/                   leitura do catálogo e dados do usuário (shared_preferences)
lib/state/bar_state.dart    estado do app (ChangeNotifier + provider)
lib/screens/                telas
lib/widgets/                componentes reutilizados
backend/                    Cloudflare Worker que chama o Gemini (guarda a chave da IA)
tool/                       importador de receitas do TheCocktailDB
```

### Importar receitas da internet (TheCocktailDB)

O script em `tool/` baixa receitas do [TheCocktailDB](https://www.thecocktaildb.com) e gera um arquivo para revisão. Nada entra no app sem você revisar:

```
# 1. Baixa e converte (oz → ml etc.). Com GEMINI_API_KEY, traduz copo e preparo.
GEMINI_API_KEY=... dart run tool/importar_cocktaildb.dart baixar

# 2. Revise tool/saida/importados_para_revisar.json: apague o que não quiser e ajuste textos.

# 3. Junta ao catálogo (valida antes de gravar) e confira com os testes.
dart run tool/importar_cocktaildb.dart mesclar tool/saida/importados_para_revisar.json
flutter test
```

- Só são importadas receitas em que **todos** os ingredientes estão em `tool/mapa_ingredientes.json`. O script lista os ingredientes que faltam no mapa. Para importar mais receitas, adicione-os ao mapa (e ao catálogo, se forem ingredientes novos).
- A chave de testes `1` do TheCocktailDB serve para desenvolvimento. Antes de publicar o app nas lojas com esse conteúdo, confira os termos do site; a publicação pode exigir uma chave paga de apoiador. As fotos importadas são carregadas da internet (`imagemUrl`) e mostram um ícone quando não há conexão.

### Como adicionar um coquetel

Inclua um item em `coqueteis` no `assets/data/catalogo.json`. Cada ingrediente referencia um `id` de `ingredientes` e pode ter `"opcional": true`. O teste `test/catalog_test.dart` confere se os ids existem.

## Rodando

Requer Flutter 3.50+ (Dart 3.14).

```
flutter pub get
flutter run --dart-define=AI_BACKEND_URL=https://...   # o define é opcional; sem ele a IA fica desligada
flutter test
```

Para regerar os ícones: `dart run flutter_launcher_icons`.
