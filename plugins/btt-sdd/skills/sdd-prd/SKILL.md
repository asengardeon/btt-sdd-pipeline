---
name: sdd-prd
description: Etapa 1 do pipeline SDD. Use quando o usuário descrever uma nova feature, um problema a resolver, ou pedir explicitamente um PRD. Aciona o agente product-design para produzir specs/<slug>/prd.md.
---

# /btt-sdd:sdd-prd

Aciona a **etapa 1** do pipeline SDD descrito em `CLAUDE.md`: geração do PRD.

## Passos

1. Se `args` é um caminho de arquivo existente (ex.: uma spec/requisito já escrito em outro
   lugar, não necessariamente dentro de `specs/`), leia seu conteúdo e use como base do pedido —
   você não depende de nenhum arquivo anterior deste pipeline para começar. Senão, se `args`
   descreve a feature em texto livre, use isso como o pedido inicial. Se vazio, pergunte ao
   usuário o que ele quer construir.
2. Determine o próximo número sequencial de spec olhando os diretórios existentes em `specs/`
   (ex.: se o maior é `0001-...`, o próximo é `0002-...`) e um slug curto em kebab-case para a
   feature.
3. Invoque o agente `product-design` (Agent tool, `subagent_type: "product-design"`) passando:
   o pedido do usuário, o número/slug decidido, e instrução explícita para salvar o PRD em
   `specs/<NNNN-slug>/prd.md` usando `specs/_template/prd.template.md` como estrutura.
4. Depois que o agente retornar, mostre ao usuário um resumo do PRD gerado (não o arquivo
   inteiro) e pergunte se aprova ou quer ajustes.
5. Se pedir ajustes, repasse o feedback ao agente `product-design` (ou edite diretamente se for
   um ajuste trivial de texto) até haver aprovação explícita.
6. Ao final, informe que a próxima etapa é `/btt-sdd:sdd-trd`.

## Quando usar sem o agente

Se o Agent tool não estiver disponível na sessão, siga o mesmo processo descrito no agente
`product-design` diretamente, você mesmo, com o mesmo rigor.
