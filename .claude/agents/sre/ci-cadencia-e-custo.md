# Desenhar/revisar ci.yml para custo e cadência

Gatilho: ao desenhar ou revisar a cadência de execução, custo de runner, concorrência ou
short-circuit de `ci.yml`/`cd.yml` — não a checklist básica de lint/teste/cobertura (essa fica no
núcleo).

## Meça desperdício em minutos faturáveis, não em tempo de parede

São dois comandos e uma multiplicação, e é o eixo em que o usuário decide:

1. `gh api repos/<owner>/<repo> --jq .private` — repositório **privado** tem os minutos de
   Actions cobrados; **público** não. Num repositório público o desperdício é de latência e de
   bloqueio de merge, não de dinheiro, e a urgência da recomendação muda de verdade.
2. O **multiplicador do runner**, lido do próprio `runs-on`: `ubuntu` 1×, `windows` **2×**,
   `macos` **10×**.
3. O total em **minutos faturáveis** (`minutos × multiplicador`), reportado junto do total em
   relógio — nunca só o relógio.

Sem isso o argumento sai sistematicamente mais fraco que a realidade, em todo projeto privado:
uma spec de três fatias pode gastar ~206 min de runner Windows em commits que, por
construção (só `.md` de artefato de revisão), não podiam mudar comportamento — da ordem de
**~412 minutos faturáveis**.

## Cadência opt-in: `ci-antes-do-merge`

A forma que um `ci.yml` recém-nascido já deve ter está em `docs/CI-WORKFLOW.md` — audite contra
ela, não contra o que lhe parecer razoável.

**Leia `docs/PROJECT-CONVENTIONS.md` antes de desenhar ou revisar o `ci.yml`.** O padrão deste
pipeline é rodar a suíte completa a cada push, e continua sendo o padrão quando o arquivo não diz
nada. Mas o pipeline é estruturalmente caro em minutos de runner: cada etapa de revisão commita e
envia seu artefato na branch da fatia, então uma fatia típica acumula ~10 runs — com os ~11–15 min
por run medidos em runner Windows, ~2h de runner por fatia, multiplicado pelo número de fatias da
spec. Um projeto pode registrar a cadência **`ci-antes-do-merge`** em `docs/PROJECT-CONVENTIONS.md`:
a suíte completa roda quando o PR **não é draft** (e em push para a branch base); enquanto o PR é
draft, o job reporta sucesso em segundos.

Isso não exige mecanismo novo, porque o pipeline já gerencia o estado exato: o PR é aberto em
draft no primeiro commit e sai do draft (`gh pr ready`) ao final da última etapa de revisão, quando
a fatia é aprovada (`docs/GIT-WORKFLOW.md`, regra 4). "CI só antes do merge" é literalmente "CI só
quando o PR não é draft", e a transição draft → ready é o sinal, no momento exato.

**O gate vai nos passos caros, nunca no job nem no gatilho** — mesma armadilha do `paths-ignore`
abaixo: um job que não roda não reporta status, e um *required status check* que nunca reporta
bloqueia o PR para sempre. O job sempre inicia, decide numa linha se deve rodar, e sai; um job que
só arranca e para consome ~1 min em vez de ~13:

```yaml
on:
  push:
    branches: [main]
  pull_request:
    types: [opened, synchronize, reopened, ready_for_review]

jobs:
  test:
    runs-on: <runner do projeto>
    steps:
      - id: cadencia
        shell: bash
        run: |
          if [ "${{ github.event_name }}" = "push" ] || \
             [ "${{ github.event.pull_request.draft }}" = "false" ]; then
            echo "rodar=true" >> "$GITHUB_OUTPUT"
          else
            echo "rodar=false" >> "$GITHUB_OUTPUT"
            echo "PR em draft: suite completa roda ao sair do draft, antes do merge."
          fi
      - if: steps.cadencia.outputs.rodar == 'true'
        uses: actions/checkout@v4
      # ... setup, lint, testes, cobertura, build — todos com o mesmo if
```

Compõe com o short-circuit de docs-only abaixo em vez de substituí-lo: quando o PR sai do draft,
aquele ainda evita repetir a suíte se o código não mudou desde o último run verde. Inclua
`workflow_dispatch` no gatilho como escape para forçar um run no meio da fatia.

**O caminho pulado precisa de um passo informativo próprio** — sem ele, um run verde de 23 s com
todos os passos `skipped` é indistinguível de um run completo para quem olha só o `conclusion`.

**Essa cadência é opt-in por projeto, nunca o padrão que você aplica por conta própria**, e o
motivo é honesto: o sinal de teste não desaparece durante a fatia (os agentes de implementação
rodam a suíte completa com cobertura ao final de cada trilha e registram em
`specs/<slug>/coverage/`), mas um defeito que **só o ambiente do CI pega** (dependência de
plataforma, runner Windows, serviço de container) passa a aparecer mais tarde, já com as revisões
aprovadas. Se `docs/PROJECT-CONVENTIONS.md` não registra a cadência, mantenha o padrão e não
sugira a troca como se fosse consenso — se o custo de runner do projeto parecer alto, aponte o
número medido e ofereça a opção ao usuário.

## Short-circuit de mudança só de documentação — pelo último run verde, nunca por `paths-ignore`

As etapas de revisão commitam e enviam (push) seus artefatos na branch da fatia, então **depois
que o código para de mudar a branch ainda recebe uma dezena de commits de documentação pura**,
cada um disparando o CI completo. Isso é consequência estrutural do pipeline, não descuido de
ninguém — e o custo é real: 4 linhas de Markdown podem comprar ~50 min de runner Windows em 4
runs completos, com risco de um deles sair vermelho por flakiness de suíte de navegador, mesmo
num commit que não podia ter mudado comportamento.

Duas formas erradas de resolver:

- **`paths-ignore` no gatilho é ativamente errado** quando o job é *required status check* de
  branch protection: se o workflow não dispara, o GitHub nunca reporta status para o check
  obrigatório, e um PR só de documentação fica **bloqueado para sempre**.
- **Um passo interno que decide comparando contra `github.event.pull_request.base.sha`** — a base
  do diff é o tip de `main`, então num PR de código o diff do PR inteiro **sempre** contém `src/`,
  e `docs_only` é `false` para todo push subsequente, inclusive os de documentação pura. A
  correção não é só "comparar sempre contra `base.sha` em `pull_request`" — é que
  `github.event.before`/`.after` também existem no payload de `pull_request` quando a ação é
  `synchronize` (todo push numa branch de PR já aberta), com o mesmo significado que em `push`.
  `base.sha` só é o ponto de comparação certo em `opened`/`reopened`. Mesmo corrigido assim, isto
  continua **mais fraco** que a receita abaixo: comparar contra o commit anterior não confirma que
  aquele commit teve CI **verde** — só que ele existiu. Um run cancelado pelo `cancel-in-progress`
  (código substituído por um commit de documentação logo depois) nunca chega a provar nada, e esta
  variante aceitaria isso mesmo assim.

**A receita que funciona**: pular o build apenas quando o código em `HEAD` for comprovadamente
idêntico ao de um SHA que **já passou** no CI nesta mesma branch.

1. Consulte, via `gh api` com o `GITHUB_TOKEN`, o run mais recente **bem-sucedido** do workflow de
   CI para esta branch, e pegue seu `headSha`. **O job que faz essa consulta declara `permissions:
   actions: read`** — o `GITHUB_TOKEN` padrão não traz esse escopo em toda configuração de
   repositório, e sem ele a chamada falha silenciosamente (o workflow continua correto, o
   desperdício continua inteiro, e ninguém descobre que o short-circuit nunca funcionou).
2. `git diff --name-only <esseSha> HEAD` e verifique se **todo** arquivo do diff casa o filtro de
   caminhos de documentação — `specs/` (documentação de spec: PRD, TRD e todo artefato
   de revisão da fatia, formato novo ou legado), `docs/` (documentação da aplicação) e `*.md` da raiz.
3. Se nada sobrou fora do filtro, é mudança só de documentação sobre código que já passou: o check
   reporta sucesso em segundos.
4. **Qualquer falha em qualquer etapa** (sem run anterior, SHA inalcançável, API fora) → trate
   como se não fosse docs-only e rode a suíte. A direção de falha segura é preservada.

Isso é **estritamente mais seguro** que pular por caminho: só pula quando o código já passou, em
vez de pular sem nunca ter testado aquele conteúdo. Se este projeto tem hoje um filtro de
`paths`/`paths-ignore` no gatilho de um check obrigatório, isso é um achado a reportar.

**Nunca ofereça esta receita sozinha — ofereça junto a contrapartida.** As execuções redundantes
que ela suprime funcionam, sem ninguém ter planejado, como **amostragem de flakiness**: rodar a
mesma suíte N vezes sobre o mesmo código é um teste de repetição, e teste de repetição acha
asserção instável. Ao propor a receita, proponha no mesmo movimento um
substituto **deliberado** — tipicamente um `schedule` rodando a suíte de integração completa na
branch base, N vezes por dia, fora do caminho crítico de qualquer PR.

## Cache e sharding

Cache de dependências declarado no workflow (confirme que o `ci.yml` declara o cache do
gerenciador de dependências da stack, `docs/STACK.md`). **Sharding** (dividir a camada cara em N
jobs paralelos) não é economia: reduz o tempo de parede e **multiplica os minutos faturáveis**,
porque os N jobs pagam a subida de ambiente N vezes. Só recomende com os dois eixos na mesa — em
repositório privado com runner Windows (2×) ou macOS (10×), sharding mal dimensionado é a troca
mais cara deste pipeline.

## `concurrency` com `cancel-in-progress`

Run supersedido na mesma branch é cancelado, não terminado — o pipeline empurra vários pushes em
sequência na mesma branch da fatia, e sem isso cada run antigo segue até o fim validando um SHA
que ninguém vai mergear:

```yaml
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: ${{ github.ref != 'refs/heads/main' }}
```

**Nunca cancele na branch base** — ali cada commit é um estado final que merece seu próprio
veredito. Ao reportar: um run `cancelled` na lista não é achado nenhum quando existe um run mais
novo verde para o HEAD atual; e isto remove parte da amostragem acidental de flakiness do
short-circuit acima — se o projeto adotar os dois, proponha no mesmo movimento o amostrador
deliberado (`schedule` na branch base).

## Falha por timeout sob contenção de runners

Se um job falhar/for cancelado só por estourar `timeout-minutes` (sem nenhum teste vermelho),
principalmente quando múltiplas fatias/PRs desta mesma sessão estão rodando CI em paralelo, trate
como possível falso-negativo por contenção de runners antes de investigar como bug de código —
tente `gh run rerun --failed` uma vez antes de escalar como achado bloqueante
(`docs/GIT-WORKFLOW.md`, seção "Aguardando CI antes do merge").
