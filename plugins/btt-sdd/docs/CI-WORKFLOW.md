# Forma mínima do workflow de CI (`.github/workflows/ci.yml`)

Este arquivo responde **uma** pergunta: quando o `ci.yml` de um projeto nasce, que forma ele já
precisa ter. É o contrato entre três papéis que antes não se encontravam em lugar nenhum — o
`architect`, que cria a tarefa que faz o arquivo nascer; quem a implementa
(`backend-developer`/`frontend-developer`); e o `sre`, que audita o resultado.

A medição e o histórico de cada regra abaixo ficam em `agents/sre.md`, área "CI" — aqui
está só a forma, para quem escreve o arquivo não precisar carregar a área inteira do `sre`.

## Por que isto existe

O nascimento do `ci.yml` não tinha dono. O scaffold de `/create-project` não traz
`.github/workflows/` (correto: a forma depende da stack, e a stack só é decidida no primeiro TRD);
as skills e os agentes de implementação não mencionavam o arquivo; e o `sre` trata de CI como
**auditoria de infraestrutura existente**, na etapa 7. O resultado era que o workflow nascia na
forma que parecesse razoável a quem implementava a primeira fatia, e só era confrontado com as
regras do pipeline depois de já ter rodado — toda regra sobre a forma dele era corretiva por
construção.

Com a cadência de `docs/SDD-WORKFLOW.md` (seção "Cadência: o que roda por fatia e o que roda ao
final da spec"), o `sre` roda **uma vez, ao final da spec**. Um `ci.yml` malformado atravessaria a
spec inteira antes de alguém olhar a forma dele.

## Quem faz o quê

- **`architect`**: quando o projeto ainda não tem `.github/workflows/ci.yml` e esta spec vai
  produzir a primeira suíte de testes, cria a tarefa que faz o arquivo nascer na decomposição
  (seção 13 do TRD), com `Validação na fatia = sre` — obrigatório para tarefa que toca `ci.yml`
  (`docs/gates/trd.md`). A tarefa aponta para este arquivo; o `architect` não redesenha a forma no
  TRD, só decide os **comandos** da stack, que já vão para `docs/STACK.md`.
- **quem implementa**: segue a forma abaixo. Não invente um `ci.yml` mínimo "para começar" e deixe
  o resto para depois — "depois" é a etapa 7 de uma spec inteira adiante.
- **`sre`**: audita contra esta mesma forma, e passa a encontrar o arquivo certo em vez de
  descobri-lo errado.

## A forma

### 1. Jobs: lint, testes e o gate de cobertura de 80% em todo PR

O conteúdo é o que `docs/STACK.md` documentar como comando de lint, de teste/cobertura e de
build/empacotamento de produção da stack decidida — nunca hardcoded neste pipeline
(`docs/TESTING.md`). O gate de 80% é **por pacote** (`src/` e `frontend/` têm cada um o seu), nunca
uma média combinada.

### 2. `concurrency` com `cancel-in-progress`, fora da branch base

```yaml
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: ${{ github.ref != 'refs/heads/main' }}
```

O pipeline empurra mais de um push na mesma branch da fatia (código, depois a sincronização com
`main`, depois o push dos artefatos de revisão). Sem isso, cada run antigo segue até o fim
validando um SHA que ninguém vai mergear. Nenhum sinal se perde: o run mais novo cobre o mesmo
código **e** o delta. **Na branch base não se cancela** — ali cada commit é um estado final com
veredito próprio.

### 3. Short-circuit de mudança só de documentação — pela comparação com o último run verde

Nunca por `paths`/`paths-ignore` no gatilho, e **nunca com o gate no job**: um job que não roda não
reporta status, e um *required status check* que nunca reporta bloqueia o PR para sempre. O gate vai
nos **passos**: o job sempre inicia, decide numa linha se deve rodar, e sai.

A decisão é "o código em `HEAD` é comprovadamente idêntico ao de um SHA que **já passou** no CI
nesta mesma branch":

1. consulte, via `gh api`, o run mais recente **bem-sucedido** deste workflow nesta branch e pegue
   o `headSha`;
2. `git diff --name-only <esseSha> HEAD` e confirme que **todo** arquivo do diff casa o filtro de
   caminhos de documentação (`specs/`, `docs/`, `*.md` da raiz);
3. se nada sobrou fora do filtro, os passos caros são pulados e o check reporta sucesso em
   segundos;
4. **qualquer falha em qualquer etapa** (sem run anterior, SHA inalcançável, API fora) → trate como
   se não fosse docs-only e rode a suíte. A direção de falha segura é preservada.

Isso é estritamente mais seguro que pular por caminho: só pula quando aquele código **já passou**,
em vez de pular sem nunca ter testado o conteúdo.

**O job que faz essa consulta declara `permissions: actions: read`.** O `GITHUB_TOKEN` padrão não
traz esse escopo em toda configuração de repositório, e sem ele a chamada `gh api` falha. Como a
direção de falha segura é "roda a suíte", a falta da permissão **não quebra nada visivelmente**: o
workflow continua correto, o desperdício continua inteiro, e ninguém descobre que o short-circuit
nunca funcionou. Declare a permissão junto do job, não depois.

### 4. O caminho pulado tem um passo informativo próprio

Um passo que só roda quando o short-circuit (ou a cadência do item 5) pulou os passos caros, dizendo
isso em uma linha. Não é enfeite: um run verde de 23 s com todos os passos `skipped` é
indistinguível de um run completo para quem olha só o `conclusion` — e as etapas de revisão são
**obrigadas** a reportar o estado do CI nos artefatos delas (`docs/gates/sre.md`).

### 5. Cache de dependências do gerenciador da stack

Declarado no workflow, apontando para o que `docs/STACK.md` documentar. Reinstalar dependências do
zero a cada run é custo puro de runner (`docs/TESTING.md`, seção "Custo de execução da suíte").

### 6. Amostrador deliberado de instabilidade (`schedule`), junto do item 3

**Não adote o short-circuit sozinho.** As execuções redundantes que ele suprime funcionavam, sem
ninguém ter planejado, como **amostragem de flakiness**: rodar a mesma suíte N vezes sobre o mesmo
código é um teste de repetição, e teste de repetição acha asserção instável. Já aconteceu de
verdade:
numa fatia, os **dois runs vermelhos rodaram em commits só de documentação, sobre código que já
tinha passado verde** — a receita os teria pulado, e foram exatamente eles que acharam o achado
bloqueante do code review.

Então um `ci.yml` que nasce com o item 3 nasce com um `schedule` rodando a suíte de integração
completa na branch base N vezes por dia, fora do caminho crítico de qualquer PR. Custa o mesmo
tempo de runner que hoje se gasta por acidente, e produz série temporal em vez de anedota.

## O que **não** entra por padrão

- **`paths`/`paths-ignore` no gatilho** — ver item 3. Se um projeto já tem isso no gatilho de um
  check obrigatório, é achado a reportar, não configuração a preservar.
- **Cadência `ci-antes-do-merge`** (suíte completa só quando o PR sai do draft) — é **opt-in por
  projeto**, registrada em `docs/PROJECT-CONVENTIONS.md`, nunca adotada por conta própria. O motivo
  é honesto: um defeito que só o ambiente do CI pega passa a aparecer mais tarde, já com as
  revisões aprovadas. Detalhe e a receita (gate nos passos, nunca no gatilho) em
  `agents/sre.md`.
- **Sharding da camada cara** — reduz tempo de parede e **multiplica minutos faturáveis** (N jobs
  pagam a subida de ambiente N vezes). Só com os dois eixos medidos, como `docs/gates/sre.md` já
  exige.
