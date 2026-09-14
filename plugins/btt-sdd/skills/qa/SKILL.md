---
name: qa
description: Etapa 5 do pipeline SDD. Use depois que a revisão de código aprovou uma feature, para validar objetivamente contra o PRD/TRD e checar o gate de cobertura de 80%. Aciona o agente qa-engineer para produzir specs/<slug>/qa-report.md.
---

# /btt-sdd:qa

Aciona a **etapa 5** do pipeline SDD descrito em `CLAUDE.md`: validação de QA.

**Sempre passe por esta skill — nunca invoque o agente `qa-engineer` diretamente via Agent tool**
(diferente da etapa 3, onde invocar `backend-developer`/`frontend-developer` direto é o padrão
correto). Esta skill em si não carrega lógica extra além de acionar o agente, mas o hábito de
pular a skill nas etapas 4-7 já causou passos de outras skills de revisão (`/btt-sdd:sre`) serem
pulados silenciosamente numa sessão real — ver `CLAUDE.md`, seção do pipeline.

## Passos

1. Identifique o slug da feature (mesma lógica das skills anteriores).
2. Confirme que existe `specs/<slug>/code-review.md` com veredito aprovado (ou aprovado com
   ressalvas aceitas pelo usuário). Se não existir, sugira `/btt-sdd:code-review` primeiro; se
   existir reprovado, sugira `/btt-sdd:implement` para tratar os achados antes de rodar o QA.
2b. **Se a branch/PR original da fatia já foi mergeado e apagado** (comum em revisão retroativa
   pedida depois do fato — ex.: um `/btt-sdd:hotfix` que pulou QA no momento do merge, e o usuário
   pede para formalizar essa etapa depois), não tente localizar/rebasear uma branch inexistente:
   siga `docs/GIT-WORKFLOW.md`, seção "Revisão retroativa de um PR já mergeado" — crie uma branch
   nova a partir de `origin/main`, produza só o `qa-report.md` desta rodada, e abra um PR próprio
   (sem gate adicional, já que não há código novo a revisar). Caso contrário (branch/PR ainda
   ativo), **confirme que a branch está sincronizada com `main` antes de revisar.** Rode `git fetch
   origin main` e `git rev-list --count HEAD..origin/main` — se houver commits novos em `main` desde que
   esta branch nasceu (ex.: merge de um hotfix concorrente da mesma spec enquanto esta fatia ainda
   estava em revisão), rebaseie a branch da fatia sobre `origin/main` antes de prosseguir,
   resolvendo eventuais conflitos nos arquivos de artefato da spec (`code-review.md`/
   `qa-report.md`/`security-review.md`/`sre-review.md`/`trd.md`) preservando o conteúdo de ambos os
   lados quando tocarem os mesmos arquivos (`docs/GIT-WORKFLOW.md`, seção "Resolvendo conflitos de
   merge nos arquivos de artefato de revisão", tem o passo a passo de como preservar a estrutura
   Markdown desses arquivos), e envie (push) o resultado. Isso evita que esta e as
   etapas seguintes (segurança, SRE) commitem "às cegas" sobre uma base que já vai gerar conflito —
   descoberto só na última etapa, exigindo uma correção retroativa.
3. **Anote o horário atual (`date -u +%Y-%m-%dT%H:%M:%SZ`)** — vai precisar dele no passo 3b para
   registrar a duração desta invocação. Invoque o agente `qa-engineer` (Agent tool,
   `subagent_type: "qa-engineer"`) passando os caminhos do PRD e TRD e o PR/branch da feature
   (`feature/<slug>`, ver `docs/GIT-WORKFLOW.md`), e instrução para produzir
   `specs/<slug>/qa-report.md` a partir de `specs/_template/qa-report.template.md`, referenciando
   o PR. **Sempre passe `isolation: "worktree"` nesta chamada** — nunca deixe dois agentes
   dividirem o mesmo diretório de trabalho (`docs/GIT-WORKFLOW.md`, seção "Isolamento de working
   tree entre agentes concorrentes"). Não é uma condição a avaliar caso a caso ("outra tarefa pode
   estar ativa?") — é o padrão desta invocação.
3b. **Registre a duração desta invocação em `specs/<slug>/timing-log.md`** (crie a partir de
   `specs/_template/timing-log.template.md` se ainda não existir): uma linha com o horário do
   passo 3, o horário atual, e a diferença calculada (etapa "QA", agente "qa-engineer", fatia desta
   rodada). Commit e envie (push) essa atualização junto com o resto do que esta rodada já for
   commitar (`docs/GIT-WORKFLOW.md`, regra 4, sobre agrupar pushes relacionados).
4. Mostre ao usuário o veredito geral (aprovado/reprovado) e os pontos principais do relatório.
5. Se reprovado, informe que a feature volta para `/btt-sdd:implement` com os achados listados —
   e siga a seção "Retomando para corrigir achados de revisão" da skill `/btt-sdd:implement`
   (prefira retomar o mesmo agente que implementou a fatia via `SendMessage` para correções
   pequenas e objetivas, em vez de invocar um agente novo). Se aprovado, informe que a próxima
   etapa é `/btt-sdd:security`.

## Quando usar sem o agente

Se o Agent tool não estiver disponível, siga o mesmo processo descrito no agente `qa-engineer`
diretamente — rode a suíte de testes e cobertura você mesmo antes de dar qualquer veredito.
