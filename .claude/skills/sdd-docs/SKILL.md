---
name: sdd-docs
description: Utilitário do pipeline SDD, sem posição fixa numa etapa numerada. Use quando o usuário pedir para escrever ou atualizar documentação técnica — README, um doc de docs/, um ADR, ou transformar código real em exemplo documentado (ex.: antes de remover código do repositório). Aciona o agente tech-writer.
---

# /sdd-docs

Aciona o agente **de documentação técnica**, um utilitário livre do pipeline SDD descrito em
`CLAUDE.md` — não é uma etapa numerada com pré-condição de artefato anterior, é convocável a
qualquer momento em que exista documentação para escrever ou atualizar.

## Passos

1. Determine o escopo do pedido a partir de `args`/da conversa: um arquivo específico (`README.md`,
   um doc de `docs/`, um ADR novo), ou "documentar tudo" (inventário completo das mecânicas do
   pipeline).
2. Se o pedido envolve transformar código real em exemplo documentado (ex.: o código vai ser
   removido do repositório mas o valor ilustrativo deve sobreviver), informe isso explicitamente ao
   agente na invocação, incluindo onde o exemplo documentado deve ficar.
3. Invoque o agente `tech-writer` (Agent tool, `subagent_type: "tech-writer"`) passando o escopo e
   o(s) arquivo(s)-alvo.
4. Mostre ao usuário um resumo do que foi documentado/atualizado e onde encontrar.

## Quando usar sem o agente

Se o Agent tool não estiver disponível, siga `.claude/agents/tech-writer.md` diretamente — nunca
escreva/corrija código de produção, só documente o que existe de fato.
