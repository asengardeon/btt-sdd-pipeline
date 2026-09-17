---
name: trd
description: Etapa 2 do pipeline SDD. Use depois que um PRD existe e foi aprovado, para gerar o desenho técnico. Aciona o agente architect para produzir specs/<slug>/trd.md a partir de specs/<slug>/prd.md.
---

# /btt-sdd:trd

Aciona a **etapa 2** do pipeline SDD descrito em `CLAUDE.md`: geração do TRD a partir do PRD.

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

1. Identifique o PRD de entrada: se `args` é um caminho de arquivo existente, use-o diretamente
   como PRD (mesmo fora da convenção `specs/<slug>/prd.md` — você não depende dessa convenção
   para funcionar em qualquer projeto). Senão, identifique o slug (se `args` traz um slug ou
   número, use-o; senão, se só existe uma spec com `prd.md` sem `trd.md` ainda, use essa; senão,
   pergunte ao usuário qual feature) e confirme que `specs/<slug>/prd.md` existe.
2. Se nenhum PRD foi encontrado nem indicado, informe o usuário e sugira rodar `/btt-sdd:prd`
   primeiro — não prossiga sem PRD.
3. **Anote o horário atual (`date -u +%Y-%m-%dT%H:%M:%SZ`)** — vai precisar dele no passo 3c para
   registrar a duração desta invocação. Invoque o agente `architect` (Agent tool,
   `subagent_type: "architect"`) passando o caminho do PRD e instrução para salvar o TRD em
   `specs/<slug>/trd.md` usando `specs/_template/trd.template.md`, registrando ADRs em `docs/adr/`
   quando relevante.
3b. **Se `architect` estiver rodando como subagente assíncrono/em background e devolver uma
   pergunta/lista de perguntas em texto puro** (sinal de que `AskUserQuestion` não estava
   disponível para ele nesse modo — mesmo padrão já documentado para `sre`/`/btt-sdd:sre`,
   `skills/sre/SKILL.md`, passo 4b), **você** — o orquestrador desta skill — é responsável por
   apresentar essa(s) pergunta(s) ao usuário via *sua própria* `AskUserQuestion` e repassar a
   resposta de volta ao agente (`SendMessage`, se ainda estiver ativo/endereçável) antes de tratar
   o TRD como pronto para o resumo do passo 4. Não deixe a lacuna só registrada como "VALIDAR
   DEPOIS" pelo próprio agente sem tentar obter a resposta real do usuário nesta mesma rodada
   quando possível.
3c. **Registre a duração desta invocação em `specs/<slug>/timing-log.md`** (crie a partir de
   `specs/_template/timing-log.template.md` se ainda não existir): uma linha com o horário do
   passo 3, o horário atual, e a diferença calculada (etapa "TRD", agente "architect", fatia "—").
   Como o TRD em si (`docs/GIT-WORKFLOW.md`, seção "Mapeamento no pipeline SDD"), esse arquivo
   ainda não tem branch/PR nesta etapa — fica como mudança não commitada até `/btt-sdd:implement`,
   passo 2c-bis, incluí-lo no primeiro commit da branch da 1ª fatia junto com PRD/TRD.
4. Mostre ao usuário um resumo do TRD (arquitetura proposta, ports definidos, principais
   trade-offs) e peça aprovação explícita.
5. Se pedir ajustes, repasse ao `architect` até aprovação.
6. Ao final, informe que a próxima etapa é `/btt-sdd:implement`.

## Quando usar sem o agente

Se o Agent tool não estiver disponível, siga o mesmo processo descrito no agente `architect`
diretamente.
