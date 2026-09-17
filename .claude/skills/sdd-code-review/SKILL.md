---
name: sdd-code-review
description: Etapa 4 do pipeline SDD. Use depois que a implementação de uma feature está pronta (PR aberto), antes do QA, para uma revisão de código de engenheiro sênior — ports & adapters, SOLID, clean code, qualidade dos testes. Aciona o agente code-reviewer para produzir specs/<slug>/code-review.md.
---

# /sdd-code-review

Aciona a **etapa 4** do pipeline SDD descrito em `CLAUDE.md`: revisão de código por um engenheiro
de software sênior, entre a implementação e o QA.

**Sempre passe por esta skill — nunca invoque o agente `code-reviewer` diretamente via Agent tool**
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
2. Confirme que existe um PR aberto pela etapa de implementação (branch `feature/<NNNN-slug>`,
   ver `docs/GIT-WORKFLOW.md`). Se não, sugira `/sdd-implement` primeiro.
2b. **Confirme que a branch está sincronizada com `main` antes de revisar.** Rode `git fetch origin
   main` e `git rev-list --count HEAD..origin/main` — se houver commits novos em `main` desde que
   esta branch nasceu (ex.: merge de um hotfix concorrente da mesma spec enquanto esta fatia ainda
   estava em revisão), rebaseie a branch da fatia sobre `origin/main` antes de prosseguir,
   resolvendo eventuais conflitos nos arquivos de artefato da spec (`code-review.md`/
   `qa-report.md`/`security-review.md`/`sre-review.md`/`trd.md`) preservando o conteúdo de ambos os
   lados quando tocarem os mesmos arquivos (`docs/GIT-WORKFLOW.md`, seção "Resolvendo conflitos de
   merge nos arquivos de artefato de revisão", tem o passo a passo de como preservar a estrutura
   Markdown desses arquivos), e envie (push) o resultado. Isso evita que esta e as
   etapas seguintes (QA, segurança, SRE) commitem "às cegas" sobre uma base que já vai gerar
   conflito — descoberto só na última etapa, exigindo uma correção retroativa. **Se o rebase trouxe
   commits substanciais de outra feature mergeada** (não só um hotfix pontual da mesma spec),
   informe explicitamente ao `code-reviewer` que vai revisar esta rodada: qualquer varredura
   exaustiva de propagação de campo/assinatura (ex.: "todo `new <Entidade>(` do repositório") que
   `backend-developer`/`frontend-developer` tenha rodado *antes* deste rebase pode estar
   desatualizada — código novo trazido pelo rebase pode ter introduzido um ponto de propagação que
   a varredura original não podia ver. Não é motivo para reprovar de antemão; é sinal para o
   `code-reviewer` reconfirmar com uma varredura própria (área 9 de `.claude/agents/code-reviewer.md`)
   em vez de confiar que "já rodei isso uma vez" continua válido.
3. **Anote o horário atual (`date -u +%Y-%m-%dT%H:%M:%SZ`)** — vai precisar dele no passo 3b para
   registrar a duração desta invocação. Invoque o agente `code-reviewer` (Agent tool,
   `subagent_type: "code-reviewer"`) passando o caminho do TRD e o PR/branch da feature, e
   instrução para produzir `specs/<slug>/code-review.md` a partir de
   `specs/_template/code-review.template.md`, referenciando o PR. **Sempre passe `isolation:
   "worktree"` nesta chamada** — nunca deixe dois agentes dividirem o mesmo diretório de trabalho
   (`docs/GIT-WORKFLOW.md`, seção "Isolamento de working tree entre agentes concorrentes"). Não é
   uma condição a avaliar caso a caso ("outra tarefa pode estar ativa?", ex.: uma correção retomada
   via `SendMessage` que ainda não terminou) — é o padrão desta invocação.
3b. **Registre a duração desta invocação em `specs/<slug>/timing-log.md`** (crie a partir de
   `specs/_template/timing-log.template.md` se ainda não existir): uma linha com o horário do
   passo 3, o horário atual, e a diferença calculada (etapa "Code review", agente
   "code-reviewer", fatia desta rodada). Commit e envie (push) essa atualização junto com o resto
   do que esta rodada já for commitar (`docs/GIT-WORKFLOW.md`, regra 4, sobre agrupar pushes
   relacionados).
4. Mostre ao usuário o veredito geral (aprovado/aprovado com ressalvas/reprovado) e os achados
   principais do relatório.
5. Se reprovado, informe que a feature volta para `/sdd-implement` com os achados listados — e
   siga a seção "Retomando para corrigir achados de revisão" de
   `.claude/skills/sdd-implement/SKILL.md` (prefira retomar o mesmo agente que implementou a
   fatia via `SendMessage` para correções pequenas e objetivas, em vez de invocar um agente novo).
   Se aprovado (ou aprovado com ressalvas aceitas pelo usuário), informe que a próxima etapa é
   `/sdd-qa`.

## Quando usar sem o agente

Se o Agent tool não estiver disponível, siga `.claude/agents/code-reviewer.md` diretamente — leia
o diff do PR você mesmo antes de dar qualquer veredito.
