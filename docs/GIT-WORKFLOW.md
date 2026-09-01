# Fluxo de Git: GitHub Flow aplicado ao pipeline SDD

Este repositório usa **GitHub Flow**: `main` é a única branch de longa duração (sempre
implantável), uma branch curta por **fatia vertical de entrega** (PRD, seção "Ordem de valor /
dependências entre histórias (fatias verticais de entrega)"), PR obrigatório para voltar a
`main`. Sem `develop`, sem `release/*`.

## Regras

1. **`main` sempre implantável.** Ninguém commita direto nela — toda mudança entra via PR.
2. **Uma branch por fatia**, nunca uma para a feature inteira. `feature/<NNNN-slug>` se a
   feature tem uma única fatia; `feature/<NNNN-slug>/<fatia>` (ex.:
   `feature/0002-relatorio-mensal/f-1`) quando o TRD lista mais de uma (seção "Decomposição de
   tarefas e dependências (fatias verticais de entrega)"). Full-stack = uma única branch/PR por
   fatia (`backend-developer` em `src/`+`tests/`, `frontend-developer` em `frontend/`, árvores
   separadas evitam conflito de merge entre os dois).
3. **Fatias são sequenciais em Git**, mesmo com backend+frontend em paralelo dentro de uma
   fatia. A branch da fatia N só nasce de `main` depois que o PR da fatia N-1 estiver mergeado —
   confira com `gh pr view <PR> --json state` ou `git log main` antes de criar a branch. Se a
   fatia anterior ainda não estiver mergeada, **pare** e informe o usuário.
4. **PR aberto cedo**, em modo *draft*, no primeiro commit — não só no final (mantém o CI rodando
   continuamente e dá visibilidade do progresso).
5. **Revisão de código, QA, segurança e SRE revisam o PR de cada fatia**, não a feature inteira
   de uma vez. `code-review.md`/`qa-report.md`/`security-review.md`/`sre-review.md` são editados
   in-place a cada fatia (nunca recriados), com uma linha por fatia na seção "Histórico de
   aprovações por fatia" de cada um — histórico de fatias já mergeadas nunca é apagado.
6. **Merge só depois de code review, QA, segurança e SRE aprovados *para aquela fatia*** e CI
   verde (lint + testes + gate de cobertura 80%) naquele PR. Preferência por *squash merge* — um
   commit por fatia em `main`.
7. **`main` protegida** nas configurações do repositório GitHub (fora do controle de arquivos
   versionados — o `sre` valida isso, não configura sozinho): push direto bloqueado, PR
   obrigatório, status checks do `ci.yml` obrigatórios, sem force-push.
8. **Merge dispara CD.** `cd.yml` já dispara por `workflow_run` do CI em `main` — nenhuma mudança
   de workflow é necessária, só a branch protection acima. Cada fatia mergeada pode disparar
   deploy, o que torna a entrega incremental visível também em produção.

## Mapeamento no pipeline SDD

Com mais de uma fatia, as etapas de `/sdd-implement` a `/sdd-sre` **se repetem por fatia**:
implementa, revisa/QA/segurança/SRE, mergeia, só então a fatia seguinte começa. Nunca implementa
todas as fatias de uma vez para revisar depois.

| Etapa                  | Ação de Git                                                                 |
|-------------------------|-------------------------------------------------------------------------------|
| `/sdd-prd`, `/sdd-trd`  | Nenhuma — documentos em `specs/`, sem código/branch ainda.                    |
| `/sdd-implement`        | Escolhe a próxima fatia pendente (TRD, seção 13); confirma merge da fatia anterior (regra 3); cria a branch, abre PR draft no primeiro commit, commita por incremento. Full-stack: backend e frontend na mesma branch, em paralelo. |
| `/sdd-code-review`      | Contra o PR desta fatia; registra em `code-review.md`, preservando o histórico das fatias anteriores; commita e envia (push) esse arquivo na mesma branch antes de devolver o resultado. |
| `/sdd-qa`               | Contra o PR desta fatia, só os critérios de aceite cobertos por ela; registra em `qa-report.md`; commita e envia (push) esse arquivo (e o de cobertura, se regravado) na mesma branch. |
| `/sdd-security`         | Contra o PR desta fatia; registra em `security-review.md`; commita e envia (push) esse arquivo na mesma branch. |
| `/sdd-sre`              | CI/CD/infra impactados por esta fatia; aprovado = PR pronto para merge; commita e envia (push) `sre-review.md` (e qualquer ajuste de infra desta rodada) na mesma branch. |
| Merge do PR             | Decisão do usuário, nunca automática. Dispara CD e libera a fatia seguinte.   |

## Isolamento de working tree entre agentes concorrentes

`checkout`/`commit`/`push`/`reset` são operações **globais ao repositório**, não escopadas a um
diretório — dois agentes tocando pastas diferentes (`src/` vs. `frontend/`) ainda competem pelo
mesmo `HEAD`, pelo mesmo índice do Git, e pela mesma branch remota se dividirem o mesmo diretório
de trabalho. Já aconteceu de verdade: dois agentes fazendo `checkout`/`commit`/`push` no mesmo
diretório em paralelo perderam edição não commitada, um commit caiu na branch errada, e um
`reset` de um agente desfez trabalho do outro. Os agentes se recuperaram sozinhos via rebase
não-destrutivo naquela ocasião, mas isso **não é garantido** — não é uma corrida aceitável de se
repetir só porque "geralmente dá certo".

**Regra: sempre que dois agentes/tarefas puderem tocar `checkout`/`commit`/`push`/`reset` no mesmo
repositório dentro da mesma janela de tempo, cada um trabalha num working tree isolado — nunca
dividem o mesmo diretório de trabalho.** Isso vale tanto para invocação paralela deliberada (ex.:
`backend-developer` + `frontend-developer` na mesma fatia, `/sdd-implement` passo 4d) quanto para
qualquer agente de revisão fazendo sua própria verificação independente (rodar suíte de testes,
`git diff`, lint) enquanto outra tarefa desta sessão pode ainda estar ativa na mesma branch (ex.:
uma correção retomada via `SendMessage`, `.claude/skills/sdd-implement/SKILL.md`, seção
"Retomando", ainda em andamento quando uma nova rodada de revisão é disparada). Não fica a
critério do orquestrador perceber isso depois de um incidente — é decisão obrigatória antes de
disparar a segunda invocação concorrente.

**Mecanismo preferido — Agent tool do Claude Code**: ao invocar um agente cuja execução pode
sobrepor outra tarefa no mesmo repositório, passe `isolation: "worktree"` na chamada da Agent
tool — o harness cria um worktree temporário isolado (diretório + branch próprios) para aquele
agente, eliminando a disputa de `HEAD`/índice com qualquer outra tarefa ativa.

**Mecanismo equivalente manual** (Agent tool sem essa opção, ou um agente seguindo sua própria
definição `.md` diretamente fora do harness): crie um worktree próprio antes de começar a
trabalhar, num diretório separado do worktree principal —

```bash
git worktree add <caminho-separado> -b <branch-temporária-do-agente> <branch-da-fatia-ou-base>
# ... trabalhe e commite normalmente dentro de <caminho-separado> ...
git worktree remove <caminho-separado>   # ao terminar — nunca deixe worktree órfão
```

**Reaproveite o cache de dependências entre worktrees do mesmo repositório.** Isolamento de
working tree separa árvore de arquivos e estado de Git — não precisa (e não deve) forçar
reinstalação de dependências do zero a cada worktree novo. Aponte a instalação de dependências
desta stack para um diretório de cache compartilhado entre worktrees do mesmo repositório (o
equivalente, na stack do projeto, a um cache de pacotes/módulos reaproveitável — a maioria dos
gerenciadores de dependências já suporta isso nativamente via variável de ambiente ou flag de
cache global; o que estiver documentado em `docs/STACK.md` deste projeto), em vez do padrão de
instalar tudo isolado dentro de cada worktree novo. Se outro agente já resolveu as dependências
deste repositório há pouco, um worktree novo deve conseguir reaproveitar esse cache quase
instantaneamente em vez de reinstalar tudo do zero — isolamento é sobre arquivos de código e
estado de Git, nunca precisa se estender ao cache de dependências.

**Isolamento resolve a corrida de Git — não substitui dependência lógica entre etapas.** Com
isolamento garantido (mecanismo acima), duas tarefas que não dependem do resultado uma da outra
podem — e devem, por padrão — ser invocadas em paralelo, sem a cautela de serializar tudo "por via
das dúvidas" que fazia sentido antes do isolamento existir. O caso mais comum no pipeline é a
trilha de backend e a trilha de frontend de uma fatia full-stack, quando o contrato entre elas já
está totalmente especificado no TRD (`/sdd-implement`, passo 4d) — o frontend não precisa esperar
o backend terminar, desde que trabalhe contra um dublê do contrato até o endpoint existir de
verdade. Isso **não** se aplica a etapas com dependência real de aprovação — revisão de código →
QA → segurança → SRE continuam estritamente sequenciais independente de isolamento (cada uma exige
o veredito aprovado da anterior como pré-condição, `docs/SDD-WORKFLOW.md`); isolamento nunca é
motivo para pular essa pré-condição, só elimina o risco de corrida quando duas tarefas *sem* essa
dependência de fato rodam ao mesmo tempo.

**Reconciliação para a branch compartilhada da fatia.** Como o design deste pipeline é uma única
branch/PR por fatia (regra 2 acima), o trabalho feito num worktree isolado ainda precisa chegar
nessa branch compartilhada. Antes de cada `push` para ela, sincronize primeiro — nunca assuma que
é o único a mexer na branch remota:

```bash
git fetch origin <branch-da-fatia>
git rebase origin/<branch-da-fatia>
git push origin HEAD:<branch-da-fatia>
```

Se o `push` for rejeitado (non-fast-forward, sinal de que outro agente publicou nesse intervalo),
repita `fetch` + `rebase` — mesmo limite de 3 tentativas de `docs/QUALITY-GATES.md` antes de parar
e escalar ao usuário. Essa sincronização é o que garante que múltiplos agentes isolados ainda
produzem uma única branch/PR coerente por fatia, sem que a isolação de working tree vire duas
branches divergentes por engano.

## Aguardando CI antes do merge

Quem aguarda o CI (`ci.yml`) terminar antes de confirmar que um PR está pronto para merge (regra
6 acima) não precisa checar o status a cada poucos segundos desde o início — a maioria dos
workflows de CI leva um tempo mínimo perceptível só para começar a rodar (fila do runner,
checkout, setup do ambiente) antes de produzir qualquer sinal novo. Prefira uma primeira espera
mais longa antes da primeira checagem de status, em vez de várias checagens curtas logo no
início — o valor exato dessa espera fica a critério de quem aplica esta instrução (varia por
projeto e provedor de CI), não é hardcoded neste template. Depois da primeira checagem, ajuste o
intervalo das checagens seguintes pelo que já se observou (workflow ainda na fila vs. já rodando),
em vez de manter o mesmo intervalo curto do início até o fim.

**Prefira o `--jq` embutido do `gh` a depender de um binário `jq` externo.** Ao extrair campos de
`gh pr checks`/`gh run view`/etc. para decidir quando parar de esperar (ex.:
`gh pr checks <PR> --json name,bucket --jq 'all(.bucket != "pending")'`), use a flag `--jq`
embutida do próprio `gh` (lib Go interna) em vez de fazer *pipe* para um binário `jq` externo
(`gh ... --json ... | jq '...'`). `jq` não vem instalado por padrão em vários ambientes (Windows/
Git-Bash é um caso comum) — quando ausente, o `pipe` falha silenciosamente (erro vai para stderr,
sem sinal visível), a condição de parada do loop nunca vira verdadeira, e o script só dorme até o
timeout achando que "o CI está demorando" quando na verdade é a própria ferramenta de checagem que
está quebrada — um desperdício de tempo/tokens investigando o lugar errado.

## Por que `/sdd-amend` não reescreve histórico

Uma emenda a um artefato já aprovado (`/sdd-amend`, ver `docs/SDD-WORKFLOW.md`) nunca reescreve
commits já feitos numa branch — adiciona um novo commit registrando a mudança. O "Log de
revisões" do artefato é o registro de *por que* mudou; o git log é o registro de *quando*.

## Mudanças no próprio pipeline (agentes, skills, docs, templates)

A regra 1 (`main` sempre implantável, ninguém commita direto nela) **vale para qualquer mudança
neste repositório, não só para features rastreadas em `specs/`** — inclusive edições em
`.claude/agents/`, `.claude/skills/`, `plugins/btt-sdd/`, `docs/` ou `specs/_template/` feitas
por uma sessão do Claude Code mantendo o próprio pipeline. Esse tipo de mudança não tem PRD/TRD
nem fatia (não é uma feature de produto), então usa uma branch simples em vez do padrão
`feature/<NNNN-slug>/<fatia>`:

1. Antes de editar qualquer arquivo, crie uma branch a partir de `main` atualizada, com o prefixo
   que descreve a natureza da mudança — mesma taxonomia dos tipos de commit já usados no
   histórico deste repositório (`feat:`, `fix:`, `chore:`, `perf:`, etc.):

   | Prefixo         | Quando usar                                                              |
   |------------------|---------------------------------------------------------------------------|
   | `feature/<NNNN-slug>/<fatia>` | Feature de produto rastreada em `specs/` (regra 2 acima) — não usar para mudanças no próprio pipeline. |
   | `fix/<slug>`     | Correção de bug (código, comportamento do pipeline, ou conteúdo incorreto) sem urgência de produção. |
   | `hotfix/<slug>`  | Correção urgente de algo já em produção/`main` quebrado — mesmo fluxo de PR, só não espera o próximo ciclo normal. |
   | `chore/<slug>`   | Manutenção do pipeline/tooling que não é bug nem doc pura (ex.: renomear skills, reorganizar arquivos). |
   | `docs/<slug>`    | Mudança só de documentação, sem código.                                  |
   | `refactor/<slug>`| Refatoração sem mudança de comportamento observável.                     |
   | `perf/<slug>`    | Otimização de performance ou custo (ex.: redução de tokens consumidos por um agente). |
   | `test/<slug>`    | Mudança só em testes.                                                    |
   | `ci/<slug>`      | Mudança em pipelines de CI/CD (`.github/workflows/`).                    |

   `<slug>` é um nome curto em kebab-case descrevendo a mudança (ex.: `chore/reduz-tokens-agentes`).
2. Commite nessa branch, abra o PR, e só mergeie em `main` com decisão explícita do usuário — as
   mesmas regras 1, 4, 6 e 7 acima se aplicam (PR obrigatório, sem push direto, sem force-push).
   Não há gate de QA/segurança/SRE automático para esse tipo de mudança (não é uma feature de
   produto), mas o PR ainda é o mecanismo de revisão antes do merge.

## Exceção histórica

O commit inicial deste template (estrutura, agentes, skills, docs e a feature de exemplo) foi
feito diretamente em `main`, antes desta política existir. A partir daí, toda mudança segue
GitHub Flow normalmente — inclusive as mudanças no próprio pipeline descritas acima.
