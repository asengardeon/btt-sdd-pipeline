---
name: prd
description: Etapa 1 do pipeline SDD. Use quando o usuário descrever uma nova feature, um problema a resolver, ou pedir explicitamente um PRD. Aciona o agente product-design para produzir specs/<slug>/prd.md.
---

# /btt-sdd:prd

Aciona a **etapa 1** do pipeline SDD descrito em `CLAUDE.md`: geração do PRD.

## Onde ficam os docs de governança citados nesta skill

Referências como `docs/GIT-WORKFLOW.md`, `docs/QUALITY-GATES.md`, `docs/TESTING.md`,
`docs/ENGINEERING-PILLARS.md`, `docs/ARCHITECTURE.md`, `docs/SDD-WORKFLOW.md`,
`docs/FILE-GUIDE.md` e `docs/POST-MERGE-VALIDATION.md` nesta skill apontam para os docs genéricos
deste pipeline — **não são copiados para dentro de cada projeto que o usa**. Resolva-os a partir
de onde esta própria skill está instalada (o "Base directory" desta invocação, dentro do plugin
`btt-sdd`): esses docs estão em `docs/` na raiz **deste plugin instalado**, atualizado
automaticamente a cada `claude plugin update` — não no projeto onde você está trabalhando agora.
Se o projeto atual também tiver um `docs/<nome>.md` próprio (`STACK.md`, `BASELINE.md`,
`LESSONS-LEARNED.md`, `adr/`), esse é conteúdo do projeto, não deste plugin — não confunda os
dois.

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
   para o PRD" sempre disponível como opção. Se o usuário topar:
   - **Confira `docs/DESIGN-SYSTEM.md` antes de gerar qualquer opção.** Se existir, reaproveite as
     decisões de lá (paleta de cores, tipografia, tom/estilo visual, referências) como direção para
     a skill `design` — as opções nascem já dentro da identidade visual do projeto, não com a
     paleta neutra genérica padrão da skill.
   - **Se não existir**, pergunte ao usuário via `AskUserQuestion` se ele quer estabelecer um
     sistema de design para a aplicação agora, antes de gerar as opções — com "não, usar estilo
     neutro só para esta rodada" sempre disponível. Se topar, colete (via `AskUserQuestion`,
     mais de uma pergunta se necessário): paleta de cores principais (cores/hex específicos, ou um
     produto/marca existente a espelhar), tom/estilo visual (ex.: minimalista, corporativo, lúdico,
     alto contraste/acessível), tipografia preferida se houver, e links/apps de referência visual.
     Registre essas decisões em `docs/DESIGN-SYSTEM.md` (crie o arquivo — mesmo padrão de
     `docs/STACK.md`: decisões + seção "Proveniência" + "Log de revisões") para a próxima feature
     com UI reaproveitar sem perguntar de novo. Se o usuário recusar, prossiga com a paleta neutra
     padrão da skill `design` nesta rodada, sem criar o arquivo — será oferecido de novo na próxima
     feature com UI.
   - Use a skill `design` para gerar 2-3 opções de layout/fluxo das telas principais descritas no
     pedido (aplicando o sistema de design acima, quando houver), publicadas como Artifact, e
     pergunte ao usuário qual prefere (ou se quer combinar elementos de mais de uma). Isso é uma
     exploração visual rápida para alinhar direção cedo — não substitui o desenho técnico de UI que
     fica com `architect`/`frontend-developer` depois.
   **Salve o(s) arquivo(s)-fonte `.dc.html` junto da spec**, não só a URL do Artifact (que pode
   ficar indisponível depois): copie-o(s) para `specs/<NNNN-slug>/wireframes/` (crie o diretório se
   não existir), com nome descritivo (ex.: `opcoes-tela-<nome>.dc.html`) — é esse arquivo local que
   garante a conferência futura mesmo sem acesso ao Artifact publicado; para ver de novo mais
   tarde, republique esse mesmo arquivo via Artifact em vez de recriar do zero. Leve o resultado
   (opção escolhida, URL do Artifact, caminho do arquivo salvo, e se `docs/DESIGN-SYSTEM.md` já
   existia, foi estabelecido nesta rodada, ou foi recusado — ou a recusa das opções em si) para o
   passo 3 abaixo. Se a feature não tem UI, pule este passo sem perguntar.
3. **Anote o horário atual (`date -u +%Y-%m-%dT%H:%M:%SZ`)** — vai precisar dele no passo 3c para
   registrar a duração desta invocação. Invoque o agente `product-design` (Agent tool,
   `subagent_type: "product-design"`) passando: o pedido do usuário, o número/slug decidido, o
   resultado do passo 2b (opção de wireframe escolhida com a referência do Artifact, o caminho do
   arquivo salvo em `specs/<NNNN-slug>/wireframes/`, e o status do sistema de design usado, recusa
   explícita do usuário, ou "não aplicável" se a feature não tem UI), e instrução explícita para
   salvar o PRD em `specs/<NNNN-slug>/prd.md` usando `specs/_template/prd.template.md` como
   estrutura — incluindo a seção "Wireframes/Protótipos de tela".
3b. **Se `product-design` estiver rodando como subagente assíncrono/em background e devolver uma
   pergunta/lista de perguntas em texto puro** (sinal de que `AskUserQuestion` não estava
   disponível para ele nesse modo — mesmo padrão já documentado para `sre`/`/btt-sdd:sre`,
   `skills/sre/SKILL.md`, passo 4b), **você** — o orquestrador desta skill — é responsável por
   apresentar essa(s) pergunta(s) ao usuário via *sua própria* `AskUserQuestion` e repassar a
   resposta de volta ao agente (`SendMessage`, se ainda estiver ativo/endereçável) antes de tratar
   o PRD como pronto para o resumo do passo 4. Não deixe a lacuna só registrada como "VALIDAR
   DEPOIS" pelo próprio agente sem tentar obter a resposta real do usuário nesta mesma rodada
   quando possível.
3c. **Registre a duração desta invocação em `specs/<NNNN-slug>/timing-log.md`** (crie a partir de
   `specs/_template/timing-log.template.md` se ainda não existir): uma linha com o horário do
   passo 3, o horário atual, e a diferença calculada (etapa "PRD", agente "product-design", fatia
   "—"). Como o PRD em si (`docs/GIT-WORKFLOW.md`, seção "Mapeamento no pipeline SDD"), esse
   arquivo ainda não tem branch/PR nesta etapa — fica como mudança não commitada até
   `/btt-sdd:implement`, passo 2c-bis, incluí-lo no primeiro commit da branch da 1ª fatia junto com
   PRD/TRD.
4. Depois que o agente retornar, mostre ao usuário um resumo do PRD gerado (não o arquivo
   inteiro) e pergunte se aprova ou quer ajustes.
5. Se pedir ajustes, repasse o feedback ao agente `product-design` (ou edite diretamente se for
   um ajuste trivial de texto) até haver aprovação explícita.
6. Ao final, informe que a próxima etapa é `/btt-sdd:trd`.

## Quando usar sem o agente

Se o Agent tool não estiver disponível na sessão, siga o mesmo processo descrito no agente
`product-design` diretamente, você mesmo, com o mesmo rigor — o passo 2b acima (oferta de
wireframes/protótipos) continua sendo sua responsabilidade, já que ele depende de ferramentas
(`AskUserQuestion`, `Artifact`, skill `design`) que este agente sozinho não tem.
