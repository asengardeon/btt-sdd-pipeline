# btt-sdd-pipeline

Template de desenvolvimento orientado a especificação (**SDD — Spec-Driven Development**) para o
Claude Code: cada feature nasce de um PRD, passa por um TRD, é implementada com TDD em ports &
adapters, passa por revisão de código, é validada por QA/segurança, e liberada por SRE — com um
agente dedicado a cada etapa, mais um punhado de mecânicas de eficiência e governança que fazem o
pipeline não repetir trabalho nem pular rigor.

Comece por `CLAUDE.md` — é o arquivo que o Claude Code lê automaticamente e que resume tudo isto.
Para a explicação de cada arquivo/pasta deste repositório, veja `docs/FILE-GUIDE.md`.

## Pipeline

```
[0] codebase-archaeologist  →  docs/BASELINE.md   (condicional — só quando falta doc de código legado)
    │
[1] product-design    →  PRD   (specs/<slug>/prd.md)
    │
[2] architect          →  TRD   (specs/<slug>/trd.md [+ ADR])
    │
[3] backend-developer / frontend-developer  →  código + testes (TDD, em paralelo quando full-stack)
    │
[4] code-reviewer       →  code-review.md
    │
[5] qa-engineer         →  qa-report.md
    │
[6] security-engineer   →  security-review.md
    │
[7] sre                 →  sre-review.md
```

| Comando            | Agente(s)                                    | Produz                         |
|--------------------|------------------------------------------------|---------------------------------|
| `/create-project`   | (usa `product-design`)                          | um projeto novo, do zero, num diretório separado |
| `/sdd-baseline`     | codebase-archaeologist                          | `docs/BASELINE.md` (condicional) |
| `/sdd-prd`          | product-design                                  | `specs/<slug>/prd.md`          |
| `/sdd-trd`          | architect                                        | `specs/<slug>/trd.md`          |
| `/sdd-implement`    | backend-developer e/ou frontend-developer         | branch + PR + código + testes  |
| `/sdd-code-review`  | code-reviewer                                    | `specs/<slug>/code-review.md`  |
| `/sdd-qa`           | qa-engineer                                      | `specs/<slug>/qa-report.md`    |
| `/sdd-security`     | security-engineer                                | `specs/<slug>/security-review.md` |
| `/sdd-sre`          | sre                                              | `specs/<slug>/sre-review.md`   |
| `/sdd-status`       | (utilitário)                                     | resumo do estágio de cada feature |
| `/sdd-amend`        | (utilitário)                                     | emenda um artefato aprovado sem reiniciar o pipeline |
| `/sdd-pending`      | (utilitário)                                     | lista itens "VALIDAR DEPOIS" em aberto |
| `/sdd-gap-report`   | (utilitário)                                     | compara casos de uso do TRD com o código real |
| `/sdd-docs`         | tech-writer (utilitário)                        | README, docs/, ADRs, exemplos de código documentados |

Detalhe de cada etapa (entrada/saída/gate) em `docs/SDD-WORKFLOW.md`.

## Fatia vertical + GitHub Flow

Quando o TRD tem mais de uma fatia vertical de entrega, as etapas [3]–[7] se repetem **por
fatia**: cada fatia é sua própria branch/PR, passa pelas quatro revisões, e só mergeia em `main`
antes da fatia seguinte começar — nunca se implementam todas de uma vez para revisar tudo junto
depois. Detalhe completo (convenção de nomes de branch, prefixos por tipo de mudança, proteção de
`main`) em `docs/GIT-WORKFLOW.md`. Vale também para mudanças no próprio pipeline (agentes, skills,
docs, templates) — nunca commit direto em `main`/`master`.

## Governança (vale para todo agente, toda etapa)

- **Nenhuma suposição silenciosa.** Toda ambiguidade que mudaria um artefato é uma pergunta ao
  usuário via `AskUserQuestion`, nunca uma escolha implícita — com **"VALIDAR DEPOIS"** sempre
  disponível quando o usuário não sabe responder agora (`/sdd-pending` lista o que ficou pendente,
  `/sdd-amend` resolve depois sem reiniciar o pipeline).
- **Nenhuma ação ou pergunta se repete mais de 3 vezes.** Na 3ª tentativa sem sucesso, o agente
  para e escala ao usuário com o que tentou e sua recomendação.
- **Plano antes de executar, sempre.** `/sdd-implement` e `/sdd-sre` apresentam o plano (código ou
  infraestrutura) e pedem aprovação explícita antes de agir.
- **Artefatos aprovados são editados in-place**, nunca recriados do zero (`/sdd-amend`).

Checklist completo, gate a gate, em `docs/QUALITY-GATES.md` — é a referência única citada por
todos os agentes, para não duplicar a lista em cada um deles.

## Mecânicas de eficiência e memória do pipeline

Além do fluxo linear acima, o pipeline acumulou mecanismos para não repetir trabalho nem esperar a
próxima rodada de revisão apontar de novo um problema já conhecido:

- **Reaproveitamento de cobertura entre etapas.** `backend-developer`/`frontend-developer` gravam
  o resultado da suíte completa (com o commit SHA) em `specs/<slug>/coverage/`; `code-reviewer` e
  `qa-engineer` reaproveitam esse resumo em vez de re-executar a suíte, só rodando de novo se o
  commit registrado estiver desatualizado. Detalhe em `docs/TESTING.md`.
- **Fast-path de segurança/SRE + auditoria completa obrigatória na fatia final.** `security-engineer`
  e `sre` rodam `git diff --stat` antes de cada fatia e condensam evidência das áreas que o diff
  claramente não toca — mas nunca pulam veredito. Para fechar o círculo (uma sequência de fatias
  individualmente inofensivas nunca escapando de auditoria nenhuma), a **última fatia pendente de
  uma feature sempre recebe revisão completa**, cobrindo o diff acumulado desde a última revisão
  marcada como `completo` na tabela "Histórico de aprovações por fatia" de cada artefato — não só
  o diff da última fatia isolada. Critério completo em `docs/QUALITY-GATES.md`.
- **Lições aprendidas recorrentes entre features.** Quando um achado de `code-review`/`qa`/
  `security`/`sre` se repete numa **2ª feature diferente**, o agente promove o padrão para
  `docs/LESSONS-LEARNED.md` (arquivo condicional — não existe até a primeira promoção). Um achado
  isolado nunca vira entrada, só um padrão confirmado. `backend-developer`/`frontend-developer`
  leem esse arquivo antes de planejar a implementação seguinte e aplicam as lições relevantes como
  restrição adicional ao TRD — evitando repetir um erro que o pipeline já viu antes de qualquer
  revisão apontar de novo. Critério completo em `docs/QUALITY-GATES.md`.
- **Retomar o mesmo agente em vez de recomeçar.** Quando uma revisão reprova (ou levanta achado
  sobre) uma fatia que um agente de implementação acabou de entregar **na mesma sessão**, e a
  correção é pequena e objetiva, `/sdd-implement` prefere retomar esse mesmo agente via
  `SendMessage` em vez de invocar um agente novo do zero — ele já tem o contexto da fatia na
  própria conversa, então não precisa re-explorar arquivos/convenções. Um agente novo só entra
  quando a correção exige desenho novo, o agente original não está mais endereçável, ou o achado
  está fora do escopo do que ele tocou. Detalhe em `.claude/skills/sdd-implement/SKILL.md`.
- **Cada agente de revisão commita o próprio artefato.** `code-reviewer`/`qa-engineer`/
  `security-engineer`/`sre` fazem `git add`/commit/push do seu próprio relatório (só esse arquivo,
  nunca `git add -A`) antes de devolver o resultado — quem chama a skill não precisa fazer esse
  passo manualmente.

## Distribuição global (junction + plugin)

Os agentes (`.claude/agents/`) e skills (`.claude/skills/`) deste repositório ficam disponíveis em
**qualquer projeto** deste computador via junction de diretório
(`~/.claude/agents`/`~/.claude/skills` apontando para cá) — editar aqui atualiza o que está
disponível globalmente, sem passo de sincronização manual. O mesmo pipeline também existe
empacotado como **plugin instalável** do Claude Code em `plugins/btt-sdd/` (namespace `/btt-sdd:*`,
ex. `/btt-sdd:trd`), necessário porque comandos de plugin ganham esse prefixo — é uma cópia
própria, não um link, então uma mudança feita aqui precisa ser replicada lá (processo documentado
em `plugins/btt-sdd/README.md`). Ver "Distribuição global" em `CLAUDE.md` para o detalhe completo,
incluindo como instalar o plugin a partir do GitHub ou localmente.

## Começando um projeto do zero

`/create-project` pergunta requisitos, cria um diretório novo e separado, copia a estrutura
genérica de `plugins/btt-sdd/skills/create-project/scaffold/` para lá, e inicia o pipeline com o
primeiro PRD — use isto para adotar o template num projeto novo, não neste repositório.

## O exemplo (`specs/0001-example-task-management/`)

PRD, TRD, QA report, security review e SRE review **reais**, usados como referência de nível de
detalhe esperado em cada artefato. O código Python que ilustrava esses artefatos rodando de
verdade (`src/`, `tests/`, `pyproject.toml`, `infra/`, `.github/workflows/`) foi removido deste
repositório — este é um template de **pipeline**, não de aplicação — mas está preservado como
exemplo documentado em `specs/0001-example-task-management/code-examples.md`. Motivação completa
em `docs/adr/0002-remover-app-exemplo-manter-exemplos-documentados.md`.

## Contribuindo para o próprio pipeline

Mudar agentes/skills/docs/templates segue o mesmo GitHub Flow do restante: nunca commit direto em
`main`/`master`, sempre uma branch com o prefixo certo (`fix/`, `feat/`, `chore/`, `docs/`,
`refactor/`, `perf/`, `test/`, `ci/` — tabela completa em `docs/GIT-WORKFLOW.md`) e PR antes de
mergear. Uma mudança em `.claude/agents/`/`.claude/skills/` na raiz não atualiza sozinha o plugin
em `plugins/btt-sdd/` — replique seguindo `plugins/btt-sdd/README.md`, seção "⚠️ Isto é uma cópia,
não um link".
