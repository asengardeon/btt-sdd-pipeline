---
name: sdd-security
description: Etapa 5 do pipeline SDD. Use depois que o QA aprovou uma feature, para revisar segurança da aplicação (OWASP, segredos, autenticação/autorização, validação de entrada, dependências) antes da revisão de SRE. Aciona o agente security-engineer para produzir specs/<slug>/security-review.md.
---

# /sdd-security

Aciona a **etapa 5** do pipeline SDD descrito em `CLAUDE.md`: revisão de segurança da aplicação.

**Sempre passe por esta skill — nunca invoque o agente `security-engineer` diretamente via Agent
tool** (diferente da etapa 3, onde invocar `backend-developer`/`frontend-developer` direto é o
padrão correto). Esta skill em si não carrega lógica extra além de acionar o agente, mas o hábito
de pular a skill nas etapas 4-7 já causou passos de outras skills de revisão (`/sdd-sre`) serem
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
2. Confirme que `specs/<slug>/qa-report.md` existe com veredito aprovado. Se não, sugira
   `/sdd-qa` primeiro — não pule QA.
2b. **Se a branch/PR original da fatia já foi mergeado e apagado** (comum em revisão retroativa
   pedida depois do fato — ex.: um `/sdd-hotfix` que pulou segurança no momento do merge, e o
   usuário pede para formalizar essa etapa depois), não tente localizar/rebasear uma branch
   inexistente: siga `docs/GIT-WORKFLOW.md`, seção "Revisão retroativa de um PR já mergeado" — crie
   uma branch nova a partir de `origin/main`, produza só o `security-review.md` desta rodada, e
   abra um PR próprio (sem gate adicional, já que não há código novo a revisar). Caso contrário
   (branch/PR ainda ativo), **confirme que a branch está sincronizada com `main` antes de revisar.**
   Rode `git fetch origin main` e `git rev-list --count HEAD..origin/main` — se houver commits novos em `main` desde que
   esta branch nasceu (ex.: merge de um hotfix concorrente da mesma spec enquanto esta fatia ainda
   estava em revisão), rebaseie a branch da fatia sobre `origin/main` antes de prosseguir,
   resolvendo eventuais conflitos nos arquivos de artefato da spec (`code-review.md`/
   `qa-report.md`/`security-review.md`/`sre-review.md`/`trd.md`) preservando o conteúdo de ambos os
   lados quando tocarem os mesmos arquivos (`docs/GIT-WORKFLOW.md`, seção "Resolvendo conflitos de
   merge nos arquivos de artefato de revisão", tem o passo a passo de como preservar a estrutura
   Markdown desses arquivos), e envie (push) o resultado. Isso evita que esta e a
   etapa seguinte (SRE) commitem "às cegas" sobre uma base que já vai gerar conflito — descoberto só
   na última etapa, exigindo uma correção retroativa.
3. **Anote o horário atual (`date -u +%Y-%m-%dT%H:%M:%SZ`)** — vai precisar dele no passo 3b para
   registrar a duração desta invocação. Invoque o agente `security-engineer` (Agent tool,
   `subagent_type: "security-engineer"`) passando os caminhos do TRD e do `qa-report.md`, e o PR
   da feature, com instrução para produzir `specs/<slug>/security-review.md` a partir de
   `specs/_template/security-review.template.md`. **Sempre passe `isolation: "worktree"` nesta
   chamada** — nunca deixe dois agentes dividirem o mesmo diretório de trabalho
   (`docs/GIT-WORKFLOW.md`, seção "Isolamento de working tree entre agentes concorrentes"). Não é
   uma condição a avaliar caso a caso ("outra tarefa pode estar ativa?") — é o padrão desta
   invocação.
3b. **Registre a duração desta invocação em `specs/<slug>/timing-log.md`** (crie a partir de
   `specs/_template/timing-log.template.md` se ainda não existir): uma linha com o horário do
   passo 3, o horário atual, e a diferença calculada (etapa "Segurança", agente
   "security-engineer", fatia desta rodada). Commit e envie (push) essa atualização junto com o
   resto do que esta rodada já for commitar (`docs/GIT-WORKFLOW.md`, regra 4, sobre agrupar pushes
   relacionados). **Vale também quando esta invocação é só uma reverificação pontual de um achado
   específico** (`security-engineer.md`, seção "Escopo de uma rodada de reverificação de achado
   específico") — nunca pule este registro por ser "só uma reverificação", senão o `timing-log.md`
   da fatia fica sistematicamente incompleto.
4. Mostre ao usuário o veredito geral e os achados por área (OWASP, segredos, autenticação,
   validação de entrada, dependências).
5. Se reprovado, informe que a feature volta para `/sdd-implement` com os achados listados — e
   siga a seção "Retomando para corrigir achados de revisão" de
   `.claude/skills/sdd-implement/SKILL.md` (prefira retomar o mesmo agente que implementou a
   fatia via `SendMessage` para correções pequenas e objetivas, em vez de invocar um agente novo).
   Se aprovado (ou aprovado com ressalvas não-bloqueantes), informe que a próxima etapa é
   `/sdd-sre`.

## Quando usar sem o agente

Se o Agent tool não estiver disponível, siga `.claude/agents/security-engineer.md` diretamente,
com o mesmo rigor de revisão.
