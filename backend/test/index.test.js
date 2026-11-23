import { test } from 'node:test';
import assert from 'node:assert/strict';
import worker, { validarEntrada, limparReceita, gerarReceita, LimiteDaIa } from '../src/index.js';

const entrada = {
  ingredientes: [
    { id: 'cachaca', nome: 'Cachaça' },
    { id: 'limao', nome: 'Limão taiti' },
    { id: 'acucar', nome: 'Açúcar' },
  ],
  pedido: 'refrescante',
};

const respostaGemini = (receita, status = 200) => async (url, init) => {
  respostaGemini.ultima = { url, init };
  return new Response(
    JSON.stringify({ candidates: [{ content: { parts: [{ text: JSON.stringify(receita) }] } }] }),
    { status },
  );
};

test('rejeita entrada inválida', () => {
  assert.throws(() => validarEntrada({}), /ingredientes/);
  assert.throws(() => validarEntrada({ ingredientes: [{ id: 'cachaca', nome: 'Cachaça' }] }), /pelo menos 2/);
  assert.throws(() => validarEntrada({ ingredientes: [{ id: 'DROP TABLE', nome: 'x' }, entrada.ingredientes[0]] }), /id inválido/);
});

test('remove ingredientes que o usuário não tem e duplicados', () => {
  const r = limparReceita(
    {
      nome: 'Caipira',
      descricao: 'd',
      copo: 'c',
      ingredientes: [
        { id: 'cachaca', quantidade: '50 ml' },
        { id: 'vodka', quantidade: '50 ml' },
        { id: 'cachaca', quantidade: '10 ml' },
      ],
      preparo: ['Misture'],
    },
    new Set(['cachaca', 'limao']),
  );
  assert.deepEqual(r.ingredientes, [{ id: 'cachaca', quantidade: '50 ml', opcional: false }]);
  assert.deepEqual(r.extras, []);
});

test('gera receita pedindo JSON com os ids permitidos', async () => {
  const receita = {
    nome: 'Caipirinha',
    descricao: 'Clássica',
    copo: 'Copo baixo',
    ingredientes: [{ id: 'cachaca', quantidade: '60 ml' }, { id: 'limao', quantidade: '1 un' }],
    extras: ['gelo'],
    preparo: ['Macere', 'Sirva'],
  };
  const r = await gerarReceita(validarEntrada(entrada), { GEMINI_API_KEY: 'k' }, respostaGemini(receita));
  assert.equal(r.nome, 'Caipirinha');
  const { url, init } = respostaGemini.ultima;
  assert.match(url, /models\/gemini-2\.5-flash:generateContent$/);
  assert.equal(init.headers['x-goog-api-key'], 'k');
  const body = JSON.parse(init.body);
  assert.equal(body.generationConfig.responseMimeType, 'application/json');
  assert.deepEqual(body.generationConfig.responseSchema.properties.ingredientes.items.properties.id.enum, ['cachaca', 'limao', 'acucar']);
  assert.match(body.contents[0].parts[0].text, /refrescante/);
});

test('limite do Gemini vira LimiteDaIa', async () => {
  await assert.rejects(gerarReceita(validarEntrada(entrada), { GEMINI_API_KEY: 'k' }, respostaGemini({}, 429)), LimiteDaIa);
});

test('rota: só POST /gerar-receita', async () => {
  const get = await worker.fetch(new Request('https://x/gerar-receita'), {});
  assert.equal(get.status, 405);
  const outra = await worker.fetch(new Request('https://x/outra', { method: 'POST' }), {});
  assert.equal(outra.status, 404);
  const ruim = await worker.fetch(new Request('https://x/gerar-receita', { method: 'POST', body: '{}' }), {});
  assert.equal(ruim.status, 400);
});

test('rota: respeita o limitador por IP', async () => {
  const env = { RATE_LIMITER: { limit: async () => ({ success: false }) } };
  const r = await worker.fetch(new Request('https://x/gerar-receita', { method: 'POST', body: JSON.stringify(entrada) }), env);
  assert.equal(r.status, 429);
});
