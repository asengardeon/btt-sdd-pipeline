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

## Passos

1. Identifique o slug da feature (mesma lógica das skills anteriores).
2. Confirme que `specs/<slug>/qa-report.md` existe com veredito aprovado. Se não, sugira
   `/sdd-qa` primeiro — não pule QA.
3. Invoque o agente `security-engineer` (Agent tool, `subagent_type: "security-engineer"`)
   passando os caminhos do TRD e do `qa-report.md`, e o PR da feature, com instrução para
   produzir `specs/<slug>/security-review.md` a partir de
   `specs/_template/security-review.template.md`. **Se outra tarefa desta sessão ainda pode estar
   ativa na mesma branch**, passe `isolation: "worktree"` nesta chamada — nunca deixe dois agentes
   dividirem o mesmo diretório de trabalho (`docs/GIT-WORKFLOW.md`, seção "Isolamento de working
   tree entre agentes concorrentes").
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
