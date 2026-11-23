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

- Para regerar os ícones: `dart run flutter_launcher_icons`.
- Para regerar a tela de abertura: `dart run flutter_native_splash:create`.

## iPhone (iOS)

O projeto já está pronto para iOS:
- **Requisitos:** iOS 15 ou mais recente.
- **Bundle id:** `com.gabrielfillacamargo.coquetelemmaos`.
- **Orientação:** só em pé no iPhone; no iPad, todas.
- **Visual:** barra de status clara, splash escura e ícone gerado.
- **Permissões:** mensagens de câmera e galeria já configuradas.
- **Envio para a loja:** `ITSAppUsesNonExemptEncryption = false`, o que pula a pergunta sobre criptografia no envio.

Cada push roda o workflow `.github/workflows/ci.yml`, que **compila o app para iOS num Mac do GitHub** (sem assinatura), além dos testes e do build de Android.

Para rodar no seu iPhone, você precisa de um Mac com Xcode:

1. `flutter pub get` e depois abra `ios/Runner.xcworkspace` no Xcode.
2. Em *Runner → Signing & Capabilities*, escolha seu **Team**. Uma Apple ID grátis já permite instalar no seu próprio iPhone, mas o app expira em 7 dias.
3. Conecte o iPhone (com o *Modo de desenvolvedor* ativado) e rode `flutter run --release --dart-define=AI_BACKEND_URL=https://...`.

Para publicar (TestFlight/App Store), é preciso a conta paga do Apple Developer Program. Os passos:

1. Crie o app no App Store Connect com o mesmo bundle id. Se quiser outro, troque antes do primeiro envio, porque depois ele não muda.
2. Rode `flutter build ipa --dart-define=AI_BACKEND_URL=https://...`.
3. Envie o `build/ios/ipa/*.ipa` pelo app **Transporter**.

## Visual

O tema "lounge de coquetel" fica em `lib/theme/party_theme.dart`: fundo ameixa escuro com acentos suaves (coral do ícone, pistache e champanhe). As fontes são **Fredoka** (textos) e **Pacifico** (logo), embutidas no app sob a licença OFL, para funcionarem offline.

Cada coquetel ganha um copo desenhado (`lib/widgets/drink_glass.dart`) com:
- o formato do copo da receita;
- a cor do drink, tirada dos ingredientes (`lib/theme/drink_style.dart`);
- a guarnição e bolhas subindo.

Ao marcar um ingrediente que libera um drink novo, aparece um confete. Bolhas e confete são desligados quando o aparelho está com **Reduzir movimento** ativado.
