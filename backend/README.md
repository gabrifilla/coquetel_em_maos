# Backend de IA do Coquetel em Mãos

Um Cloudflare Worker pequeno, que cabe no plano gratuito. Ele recebe do app os ingredientes que o usuário tem, pede uma receita ao **Google Gemini** e devolve um JSON já validado.

**Por que existe:** a chave da API não pode ficar dentro do app, porque qualquer pessoa consegue extraí-la do APK/IPA. Ela fica guardada só aqui, como *secret*.

## O que ele faz

- Expõe `POST /gerar-receita` com o corpo `{ "ingredientes": [{ "id": "cachaca", "nome": "Cachaça" }, ...], "pedido": "refrescante" }`.
- Valida a entrada: de 2 a 40 ingredientes, ids no formato do catálogo e pedido de até 120 caracteres.
- Pede ao Gemini uma resposta em JSON com esquema fixo, em que o campo `id` só aceita os ids enviados.
- Limpa a resposta antes de devolver: descarta ingredientes que o usuário não tem, remove duplicados e limita o tamanho dos textos.
- Limita a 10 pedidos por minuto por IP (binding `RATE_LIMITER` no `wrangler.toml`).

## Como publicar

1. Crie uma chave gratuita no [Google AI Studio](https://aistudio.google.com/apikey).
2. Crie uma conta gratuita no Cloudflare e, nesta pasta, rode:
   ```
   npx wrangler login
   npx wrangler secret put GEMINI_API_KEY   # cole a chave quando pedir
   npx wrangler deploy
   ```
3. O deploy mostra uma URL do tipo `https://coquetel-em-maos.<sua-conta>.workers.dev`. Compile o app com ela:
   ```
   flutter run --dart-define=AI_BACKEND_URL=https://coquetel-em-maos.<sua-conta>.workers.dev
   ```
   Sem esse `--dart-define`, a tela "Criar com IA" avisa que a IA não está configurada.

Para testar localmente, crie um arquivo `.dev.vars` (já no `.gitignore`) com `GEMINI_API_KEY=...` e rode `npx wrangler dev`.

## Pontos de atenção

- **Modelo:** o padrão é `GEMINI_MODEL = "gemini-2.5-flash"`, definido no `wrangler.toml`. Confira na [página de preços do Gemini](https://ai.google.dev/gemini-api/docs/pricing) quais modelos têm plano gratuito hoje e troque se precisar.
- **Plano gratuito:** tem limite de pedidos por minuto e por dia. Quando o limite estoura, o backend responde 429 e o app mostra "Muitos pedidos agora".
- **Privacidade:** no plano gratuito, o Google pode usar o conteúdo enviado para melhorar os produtos dele. O app só envia nomes de ingredientes e o pedido opcional, nada pessoal. Mesmo assim, confira os termos atuais.
- **Custos:** sem cobrança ativada no projeto do Google, não há como gerar custo. No pior caso, a cota acaba.

## Testes

```
npm test
```

Os testes usam respostas simuladas e não chamam o Gemini.
