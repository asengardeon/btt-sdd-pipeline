---
name: sdd-prd
description: Etapa 1 do pipeline SDD. Use quando o usuário descrever uma nova feature, um problema a resolver, ou pedir explicitamente um PRD. Aciona o agente product-design para produzir specs/<slug>/prd.md.
---

# /sdd-prd

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
2b. **Feature com UI → ofereça wireframes/protótipos antes do PRD.** Se o pedido descreve tela(s)
   nova(s) ou mudança visual relevante em tela existente, pergunte ao usuário via
   `AskUserQuestion` se ele quer ver 2-3 opções de wireframe/protótipo de baixa fidelidade das
   telas principais antes de escrever as histórias de usuário em detalhe — com "não, seguir direto
   para o PRD" sempre disponível como opção. Se o usuário topar, use a skill `design` para gerar
   2-3 opções de layout/fluxo das telas principais descritas no pedido, publicadas como Artifact, e
   pergunte ao usuário qual prefere (ou se quer combinar elementos de mais de uma). Isso é uma
   exploração visual rápida para alinhar direção cedo — não substitui o desenho técnico de UI que
   fica com `architect`/`frontend-developer` depois. Leve o resultado (opção escolhida, ou a
   recusa) para o passo 3 abaixo. Se a feature não tem UI, pule este passo sem perguntar.
3. Invoque o agente `product-design` (Agent tool, `subagent_type: "product-design"`) passando:
   o pedido do usuário, o número/slug decidido, o resultado do passo 2b (opção de wireframe
   escolhida com a referência do Artifact, recusa explícita do usuário, ou "não aplicável" se a
   feature não tem UI), e instrução explícita para salvar o PRD em `specs/<NNNN-slug>/prd.md`
   usando `specs/_template/prd.template.md` como estrutura — incluindo a seção "Wireframes/
   Protótipos de tela".
4. Depois que o agente retornar, mostre ao usuário um resumo do PRD gerado (não o arquivo
   inteiro) e pergunte se aprova ou quer ajustes.
5. Se pedir ajustes, repasse o feedback ao agente `product-design` (ou edite diretamente se for
   um ajuste trivial de texto) até haver aprovação explícita.
6. Ao final, informe que a próxima etapa é `/sdd-trd`.

## Quando usar sem o agente

Se o Agent tool não estiver disponível na sessão, siga o processo descrito em
`.claude/agents/product-design.md` diretamente, você mesmo, com o mesmo rigor — o passo 2b acima
(oferta de wireframes/protótipos) continua sendo sua responsabilidade, já que ele depende de
ferramentas (`AskUserQuestion`, `Artifact`, skill `design`) que este agente sozinho não tem.
