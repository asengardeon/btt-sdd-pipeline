---
name: sdd-qa
description: Etapa 5 do pipeline SDD. Use depois que a revisão de código aprovou uma feature, para validar objetivamente contra o PRD/TRD e checar o gate de cobertura de 80%. Aciona o agente qa-engineer para produzir specs/<slug>/qa-report.md.
---

# /sdd-qa

Aciona a **etapa 5** do pipeline SDD descrito em `CLAUDE.md`: validação de QA.

**Sempre passe por esta skill — nunca invoque o agente `qa-engineer` diretamente via Agent tool**
(diferente da etapa 3, onde invocar `backend-developer`/`frontend-developer` direto é o padrão
correto). Esta skill em si não carrega lógica extra além de acionar o agente, mas o hábito de
pular a skill nas etapas 4-7 já causou passos de outras skills de revisão (`/sdd-sre`) serem
pulados silenciosamente numa sessão real — ver `CLAUDE.md`, seção do pipeline.

## Onde ficam os docs de governança citados nesta skill

Referências como `docs/GIT-WORKFLOW.md`, `docs/QUALITY-GATES.md`, `docs/TESTING.md`,
`docs/ENGINEERING-PILLARS.md`, `docs/ARCHITECTURE.md`, `docs/SDD-WORKFLOW.md`,
`docs/FILE-GUIDE.md` e `docs/POST-MERGE-VALIDATION.md` nesta skill apontam para os docs genéricos
deste pipeline — **não são copiados para dentro de cada projeto que o usa**. Resolva-os a partir
de onde esta própria skill está instalada (o "Base directory" desta invocação): se for
`.claude/skills/<esta-skill>/` apontando para este repositório via junction global (`CLAUDE.md`,
seção "Distribuição global"), esses docs estão em `docs/` na raiz **deste mesmo repositório** —
não necessariamente no projeto onde você está trabalhando agora. Se o projeto atual também tiver
um `docs/<nome>.md` próprio (`STACK.md`, `BASELINE.md`, `LESSONS-LEARNED.md`, `adr/`), esse é
conteúdo do projeto, não deste pipeline — não confunda os dois.

## Passos

1. Identifique o slug da feature (mesma lógica das skills anteriores).
2. Confirme que existe `specs/<slug>/code-review.md` com veredito aprovado (ou aprovado com
   ressalvas aceitas pelo usuário). Se não existir, sugira `/sdd-code-review` primeiro; se existir
   reprovado, sugira `/sdd-implement` para tratar os achados antes de rodar o QA.
2b. **Se a branch/PR original da fatia já foi mergeado e apagado** (comum em revisão retroativa
   pedida depois do fato — ex.: um `/sdd-hotfix` que pulou QA no momento do merge, e o usuário pede
   para formalizar essa etapa depois), não tente localizar/rebasear uma branch inexistente: siga
   `docs/GIT-WORKFLOW.md`, seção "Revisão retroativa de um PR já mergeado" — crie uma branch nova a
   partir de `origin/main`, produza só o `qa-report.md` desta rodada, e abra um PR próprio (sem
   gate adicional, já que não há código novo a revisar). Caso contrário (branch/PR ainda ativo),
   **confirme que a branch está sincronizada com `main` antes de revisar.** Rode `git fetch origin
   main` e `git rev-list --count HEAD..origin/main` — se houver commits novos em `main` desde que
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
   commitar (`docs/GIT-WORKFLOW.md`, regra 4, sobre agrupar pushes relacionados). **Vale também
   quando esta invocação é só uma reverificação pontual de um achado específico**
   (`qa-engineer.md`, seção "Escopo de uma rodada de reverificação de achado específico") — nunca
   pule este registro por ser "só uma reverificação", senão o `timing-log.md` da fatia fica
   sistematicamente incompleto.
3c. **Se o agente registrou perguntas como "VALIDAR DEPOIS" por não ter `AskUserQuestion`
   disponível nesta invocação** (subagente isolado/assíncrono — sinal típico: uma nota de processo no
   topo de `qa-report.md`, ou um item de pendência dizendo "não pude perguntar"), **você** — o
   orquestrador desta skill — apresenta essas perguntas ao usuário via *sua própria*
   `AskUserQuestion`, **antes** de informar o resultado da etapa no passo seguinte. Mesmo padrão já
   documentado para `sre` (`.claude/skills/sdd-sre/SKILL.md`, passo 4b) e para os agentes de
   implementação (`.claude/skills/sdd-implement/SKILL.md`, passo 5b). As que o usuário responder
   **deixam de ser pendência** e voltam ao relatório como decisão registrada — `SendMessage` ao
   agente `qa-engineer`, se ainda endereçável, ou edição direta da tabela de pendências de
   `qa-report.md`. As que ele não souber responder agora continuam como VALIDAR DEPOIS, agora
   legitimamente. Registrar em vez de perguntar é o fallback correto **do agente**, que não tinha a
   ferramenta; não é o seu, que tem — e o usuário está disponível justamente no turno em que a etapa
   roda. Perguntas binárias de política ou de comportamento, que o usuário responderia em segundos,
   já viraram dívida em `/sdd-pending` exatamente por este passo não existir.
4. Mostre ao usuário o veredito geral (aprovado/reprovado) e os pontos principais do relatório.
5. Se reprovado, informe que a feature volta para `/sdd-implement` com os achados listados — e
   siga a seção "Retomando para corrigir achados de revisão" de
   `.claude/skills/sdd-implement/SKILL.md` (prefira retomar o mesmo agente que implementou a
   fatia via `SendMessage` para correções pequenas e objetivas, em vez de invocar um agente novo).
   Se aprovado, informe que a próxima etapa é `/sdd-security`.

## Quando usar sem o agente

Se o Agent tool não estiver disponível, siga `.claude/agents/qa-engineer.md` diretamente — rode a
suíte de testes e cobertura você mesmo antes de dar qualquer veredito.
