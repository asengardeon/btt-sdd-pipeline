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
| `/sdd-code-review`      | Contra o PR desta fatia; registra em `code-review.md`, preservando o histórico das fatias anteriores. |
| `/sdd-qa`               | Contra o PR desta fatia, só os critérios de aceite cobertos por ela; registra em `qa-report.md`. |
| `/sdd-security`         | Contra o PR desta fatia; registra em `security-review.md`.                   |
| `/sdd-sre`              | CI/CD/infra impactados por esta fatia; aprovado = PR pronto para merge.       |
| Merge do PR             | Decisão do usuário, nunca automática. Dispara CD e libera a fatia seguinte.   |

## Por que `/sdd-amend` não reescreve histórico

Uma emenda a um artefato já aprovado (`/sdd-amend`, ver `docs/SDD-WORKFLOW.md`) nunca reescreve
commits já feitos numa branch — adiciona um novo commit registrando a mudança. O "Log de
revisões" do artefato é o registro de *por que* mudou; o git log é o registro de *quando*.

## Exceção histórica

O commit inicial deste template (estrutura, agentes, skills, docs e a feature de exemplo) foi
feito diretamente em `main`, antes desta política existir. A partir daí, toda mudança segue
GitHub Flow normalmente.
