---
name: sdd-security
description: Etapa 5 do pipeline SDD. Use depois que o QA aprovou uma feature, para revisar segurança da aplicação (OWASP, segredos, autenticação/autorização, validação de entrada, dependências) antes da revisão de SRE. Aciona o agente security-engineer para produzir specs/<slug>/security-review.md.
---

# /btt-sdd:sdd-security

Aciona a **etapa 5** do pipeline SDD descrito em `CLAUDE.md`: revisão de segurança da aplicação.

## Passos

1. Identifique o slug da feature (mesma lógica das skills anteriores).
2. Confirme que `specs/<slug>/qa-report.md` existe com veredito aprovado. Se não, sugira
   `/btt-sdd:sdd-qa` primeiro — não pule QA.
3. Invoque o agente `security-engineer` (Agent tool, `subagent_type: "security-engineer"`)
   passando os caminhos do TRD e do `qa-report.md`, e o PR da feature, com instrução para
   produzir `specs/<slug>/security-review.md` a partir de
   `specs/_template/security-review.template.md`.
4. Mostre ao usuário o veredito geral e os achados por área (OWASP, segredos, autenticação,
   validação de entrada, dependências).
5. Se reprovado, informe que a feature volta para `/btt-sdd:sdd-implement` com os achados listados. Se
   aprovado (ou aprovado com ressalvas não-bloqueantes), informe que a próxima etapa é
   `/btt-sdd:sdd-sre`.

## Quando usar sem o agente

Se o Agent tool não estiver disponível, siga o mesmo processo descrito no agente
`security-engineer` diretamente, com o mesmo rigor de revisão.
