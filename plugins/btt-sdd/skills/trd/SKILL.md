---
name: trd
description: Etapa 2 do pipeline SDD. Use depois que um PRD existe e foi aprovado, para gerar o desenho técnico. Aciona o agente architect para produzir specs/<slug>/trd.md a partir de specs/<slug>/prd.md.
---

# /btt-sdd:trd

Aciona a **etapa 2** do pipeline SDD descrito em `CLAUDE.md`: geração do TRD a partir do PRD.

## Passos

1. Identifique o PRD de entrada: se `args` é um caminho de arquivo existente, use-o diretamente
   como PRD (mesmo fora da convenção `specs/<slug>/prd.md` — você não depende dessa convenção
   para funcionar em qualquer projeto). Senão, identifique o slug (se `args` traz um slug ou
   número, use-o; senão, se só existe uma spec com `prd.md` sem `trd.md` ainda, use essa; senão,
   pergunte ao usuário qual feature) e confirme que `specs/<slug>/prd.md` existe.
2. Se nenhum PRD foi encontrado nem indicado, informe o usuário e sugira rodar `/btt-sdd:prd`
   primeiro — não prossiga sem PRD.
3. Invoque o agente `architect` (Agent tool, `subagent_type: "architect"`) passando o caminho do
   PRD e instrução para salvar o TRD em `specs/<slug>/trd.md` usando
   `specs/_template/trd.template.md`, registrando ADRs em `docs/adr/` quando relevante.
4. Mostre ao usuário um resumo do TRD (arquitetura proposta, ports definidos, principais
   trade-offs) e peça aprovação explícita.
5. Se pedir ajustes, repasse ao `architect` até aprovação.
6. Ao final, informe que a próxima etapa é `/btt-sdd:implement`.

## Quando usar sem o agente

Se o Agent tool não estiver disponível, siga o mesmo processo descrito no agente `architect`
diretamente.
