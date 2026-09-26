# Quality Gates — validações críticas do pipeline

Checklist único e não-negociável, **dividido por etapa** para cada agente carregar só o que
usa. Um gate marcado como bloqueante **bloqueia mesmo** — não é sugestão, é a definição do que
"pronto" significa neste pipeline. Os "Definition of Done" de cada agente são a aplicação
específica destes gates à etapa dele; estes arquivos são a referência única, para não duplicar
a lista em cada um.

**Este arquivo é um índice: não contém gate nenhum.** Conteúdo em dois lugares é a origem da
deriva que a #280 documentou — cada gate vive em exatamente um arquivo.

## Mapa

| Arquivo | O que cobre |
|---|---|
| [`gates/governanca.md`](gates/governanca.md) | Regras que valem em **todas** as etapas: nenhuma suposição silenciosa, limite de 3 tentativas, plano aprovado antes de agir, nenhum agente aprova o próprio trabalho, pergunta de subagente isolado é recolhida por quem o invocou, feedback vira issue. |
| [`gates/licoes.md`](gates/licoes.md) | Mecanismo de memória do projeto (`docs/LESSONS-LEARNED.md`): quando uma entrada nasce, como registrar ocorrência, escalonamento com estado, e quando uma entrada fica obsoleta. |
| [`gates/status-de-tarefas.md`](gates/status-de-tarefas.md) | Ciclo de vida da coluna Status da decomposição do TRD e de quem é cada transição — `architect` inicializa, implementação promove, revisões bloqueiam. |
| [`gates/baseline.md`](gates/baseline.md) | Etapa 0, condicional (`codebase-archaeologist`). |
| [`gates/prd.md`](gates/prd.md) | Etapa 1 (`product-design`). |
| [`gates/trd.md`](gates/trd.md) | Etapa 2 (`architect`). |
| [`gates/implementacao.md`](gates/implementacao.md) | Etapa 3 (`backend-developer`/`frontend-developer`). |
| [`gates/code-review.md`](gates/code-review.md) | Etapa 4 (`code-reviewer`). |
| [`gates/ux.md`](gates/ux.md) | Etapa 4b, condicional (`ux-designer`). |
| [`gates/qa.md`](gates/qa.md) | Etapa 5 (`qa-engineer`). |
| [`gates/seguranca.md`](gates/seguranca.md) | Etapa 6 (`security-engineer`). |
| [`gates/sre.md`](gates/sre.md) | Etapa 7 (`sre`) — CI/CD, Docker, Terraform, cadência de CI e custo de runner. |
| [`gates/merge.md`](gates/merge.md) | O que precisa estar verdadeiro para uma fatia entrar em `main`. |

## Quem lê o quê

Os dois transversais (`governanca`, `licoes`) valem para todas as etapas. Os demais são da
etapa que os nomeia.

| Agente | Lê |
|---|---|
| `product-design` | governanca, licoes, prd |
| `architect` | governanca, licoes, trd, status-de-tarefas |
| `backend-developer` / `frontend-developer` | governanca, licoes, implementacao, status-de-tarefas |
| `code-reviewer` | governanca, licoes, code-review, status-de-tarefas |
| `ux-designer` | governanca, licoes, ux |
| `qa-engineer` | governanca, licoes, qa |
| `security-engineer` | governanca, licoes, seguranca |
| `sre` | governanca, licoes, sre, merge |
| `codebase-archaeologist` | governanca, baseline |
| `tech-writer` | governanca |

## Seção antiga → arquivo

Referências escritas antes da divisão citam este arquivo com o nome da seção. O mapa abaixo
resolve essas citações sem precisar reescrevê-las todas de uma vez.

| Seção (nome antigo) | Arquivo |
|---|---|
| "Governança de decisão (vale para todas as etapas, incluindo a condicional de baseline)" | `gates/governanca.md` |
| "Lições aprendidas recorrentes (`docs/LESSONS-LEARNED.md`)" | `gates/licoes.md` |
| "Status de tarefas (coluna "Status" da decomposição do TRD)" | `gates/status-de-tarefas.md` |
| "Baseline (condicional, `codebase-archaeologist`)" | `gates/baseline.md` |
| "PRD" | `gates/prd.md` |
| "TRD" | `gates/trd.md` |
| "Implementação" | `gates/implementacao.md` |
| "Revisão de código (`code-reviewer`)" | `gates/code-review.md` |
| "UX / Usabilidade (`ux-designer`, condicional)" | `gates/ux.md` |
| "QA" | `gates/qa.md` |
| "Segurança (`security-engineer`)" | `gates/seguranca.md` |
| "SRE / CI-CD / Infra" | `gates/sre.md` |
| "Merge para `main` (por fatia)" | `gates/merge.md` |
