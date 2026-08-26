# Fluxo de Git: GitHub Flow aplicado ao pipeline SDD

Este repositório usa **GitHub Flow**: um único branch de longa duração (`main`, sempre
implantável), uma branch curta por **fatia vertical de entrega** (ver `CLAUDE.md` e a seção
"Ordem de valor / dependências entre histórias (fatias verticais de entrega)" do PRD), Pull
Request obrigatório para voltar a `main`. Sem `develop`, sem `release/*`, sem branches de longa
duração além de `main`.

## Regras

1. **`main` é sempre implantável.** Ninguém commita direto nela. Toda mudança entra via PR.
2. **Uma branch por fatia vertical**, não uma branch para a feature inteira. Nome:
   `feature/<NNNN-slug>` quando a feature tem uma única fatia (não foi fatiada, ou é pequena o
   bastante para não precisar); `feature/<NNNN-slug>/<fatia>` (ex.:
   `feature/0002-relatorio-mensal/f-1`) quando o TRD lista mais de uma fatia na seção
   "Decomposição de tarefas e dependências (fatias verticais de entrega)". Isso mantém o vínculo
   spec ↔ fatia ↔ branch ↔ PR rastreável só pelo nome. Quando a fatia é full-stack, é **uma única
   branch/PR para aquela fatia** — `backend-developer` trabalha em `src/`+`tests/`,
   `frontend-developer` em `frontend/`, cada um só na sua árvore de diretório, o que evita
   conflito de merge entre os dois trabalhando em paralelo dentro da mesma fatia.
3. **Fatias são sequenciais em Git, mesmo que o desenvolvimento dentro de uma fatia seja
   paralelo (backend+frontend).** A branch da fatia N só é criada a partir de `main` **depois**
   que o PR da fatia N-1 da mesma feature já foi mergeado em `main` — nunca antes. Isso é o que
   torna a entrega vertical de verdade: cada fatia mergeada é um incremento real e implantável de
   `main`, não um checkpoint intermediário isolado numa branch longa. Antes de criar a branch de
   uma fatia que não é a primeira, confirme o merge da fatia anterior (`gh pr view <PR>
   --json state`, ou `git log main` procurando o commit de squash merge dela). Se a fatia
   anterior ainda não foi mergeada (revisão de código/QA/segurança/SRE pendente, ou aprovada mas
   ainda não mergeada), **pare** e informe ao usuário — não crie a branch da próxima fatia em
   cima de uma `main` desatualizada.
4. **PR aberto cedo**, como *draft*, assim que o primeiro commit da fatia existe — não só no
   final. Isso deixa o CI rodando continuamente contra a branch (`ci.yml` já dispara em
   `pull_request`) e dá visibilidade do progresso.
5. **Revisão de código, QA, segurança e SRE revisam o PR de cada fatia**, não a feature inteira de
   uma vez: `code-review.md`, `qa-report.md`, `security-review.md` e `sre-review.md` da feature
   são documentos vivos, editados in-place a cada fatia (nunca recriados do zero), com uma linha
   de veredito por fatia na seção "Histórico de aprovações por fatia" de cada um — histórico de
   fatias já aprovadas/mergeadas nunca é apagado ao revisar a fatia seguinte.
6. **Merge só depois de revisão de código, QA, segurança e SRE aprovados para aquela fatia** e CI
   verde (lint + testes + gate de cobertura 80%) **naquele PR**. Preferência por *squash merge* —
   um commit por fatia em `main`, histórico linear e legível, cada commit correspondendo a um
   incremento demonstrável da spec.
7. **`main` protegida** nas configurações do repositório GitHub (fora do controle de arquivos
   versionados, é responsabilidade de quem administra o repo — normalmente o agente `sre` valida
   isso, não configura sozinho):
   - Push direto bloqueado.
   - PR obrigatório antes de mergear.
   - Status checks obrigatórios: o job de lint/teste/cobertura do `ci.yml`.
   - Sem force-push em `main`.
8. **Merge para `main` dispara CD.** `cd.yml` já dispara por `workflow_run` do `CI` concluído com
   sucesso em `main` — nenhuma mudança de workflow é necessária para isso funcionar, só a
   configuração de branch protection acima. Cada fatia mergeada pode disparar um deploy — é isso
   que torna a entrega incremental visível também em produção, não só no repositório.

## Mapeamento no pipeline SDD

Quando a feature tem mais de uma fatia vertical, as etapas de `/sdd-implement` até `/sdd-sre`
**se repetem por fatia**, em loop: implementa-se uma fatia, ela passa pela revisão/QA/segurança/
SRE, é mergeada, e só então a fatia seguinte começa (branch nova a partir da `main` já
atualizada). Não se implementam todas as fatias de uma vez para só depois revisar tudo junto.

| Etapa                | Ação de Git                                                                 |
|-----------------------|-------------------------------------------------------------------------------|
| `/sdd-prd`, `/sdd-trd` | Nenhuma — são documentos em `specs/`, ainda não há código/branch.             |
| `/sdd-implement`       | Escolhe a próxima fatia pendente (ordem da seção 13 do TRD); confirma que o PR da fatia anterior já foi mergeado (regra 3); cria a branch da fatia a partir de `main` atualizada; abre PR draft no primeiro commit; commita incrementalmente (um commit por ciclo TDD ou por incremento coerente). Se a fatia é full-stack, `backend-developer` e `frontend-developer` commitam na mesma branch em paralelo. |
| `/sdd-code-review`      | Roda contra o PR desta fatia; referencia o PR e a fatia no `code-review.md`, preservando o histórico de fatias anteriores. |
| `/sdd-qa`               | Roda contra o PR desta fatia, validando só os critérios de aceite cobertos por ela; referencia o PR e a fatia no `qa-report.md`. |
| `/sdd-security`         | Roda contra o PR desta fatia; referencia o PR e a fatia no `security-review.md`.             |
| `/sdd-sre`              | Revisa CI/CD/infra impactados por esta fatia; se aprovado, marca o PR como pronto para review humano/merge. |
| Merge do PR desta fatia | Feito pelo usuário (ou por quem tiver permissão) depois dos aprovados acima — não é um passo automático de nenhum agente. Dispara CD. Libera a próxima fatia para começar. |

## Por que não usar `/sdd-amend` para reescrever histórico

Uma emenda a um artefato já aprovado (`/sdd-amend`, ver `docs/SDD-WORKFLOW.md`) nunca reescreve
commits já feitos em uma branch de feature — ela adiciona um novo commit registrando a mudança
(commits de correção fazem parte do histórico normal do PR). O log de revisões dentro do próprio
artefato (`prd.md`/`trd.md`/etc.) é o registro de *por que* mudou; o git log é o registro de
*quando*.

## Exceção histórica

O commit inicial deste template (estrutura, agentes, skills, docs e a feature de exemplo) foi
feito diretamente em `main` antes desta política existir. A partir de agora, toda mudança segue
GitHub Flow normalmente.
