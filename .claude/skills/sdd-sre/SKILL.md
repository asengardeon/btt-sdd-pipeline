---
name: sdd-sre
description: Etapa 5 (final) do pipeline SDD. Use depois que o QA aprovou uma feature, para validar CI/CD, Docker e Terraform antes do deploy. Também use fora do fluxo de uma feature específica quando o usuário pedir revisão de pipeline ou infraestrutura. Aciona o agente sre para produzir specs/<slug>/sre-review.md.
---

# /sdd-sre

Aciona a **etapa 5** do pipeline SDD descrito em `CLAUDE.md`: validação de CI/CD e infraestrutura.

## Passos

1. Identifique o slug da feature (mesma lógica das skills anteriores).
2. Confirme que `specs/<slug>/qa-report.md` existe com veredito aprovado. Se não, sugira
   `/sdd-qa` primeiro — não pule QA.
3. Invoque o agente `sre` (Agent tool, `subagent_type: "sre"`) passando o caminho do TRD (seção
   de requisitos não funcionais/infra) e do `qa-report.md`, e instrução para produzir
   `specs/<slug>/sre-review.md` a partir de `specs/_template/sre-review.template.md`.
4. Se o agente propuser mudança real de infraestrutura (`terraform apply`), NUNCA execute sem
   confirmação explícita do usuário — trate como ação destrutiva/de alto impacto.
5. Mostre ao usuário o veredito e os checklists de CI, Docker e Terraform.
6. Se aprovado, informe que a feature está pronta ponta a ponta pelo pipeline SDD. Se reprovado
   ou aprovado com ressalvas, liste os itens pendentes e quem deve resolvê-los.

## Quando usar fora do fluxo de feature

Se o usuário pedir "revisa nosso pipeline" ou "audita a infra" sem uma feature específica, aponte
o agente `sre` para os checklists gerais dele mesmo sem um `qa-report.md` associado.

## Quando usar sem o agente

Se o Agent tool não estiver disponível, siga `.claude/agents/sre.md` diretamente.
