---
name: project-conventions
description: Utilitário do pipeline SDD, sem posição fixa numa etapa. Use quando o usuário quiser registrar/atualizar as particularidades deste projeto em relação ao padrão genérico do pipeline — modelo de workflow de Git, estrutura de pastas, nomenclatura etc. — para facilitar a identidade própria do projeto. Aciona o agente codebase-archaeologist para produzir/atualizar docs/PROJECT-CONVENTIONS.md.
---

# /btt-sdd:project-conventions

Aciona o agente **arqueólogo de código** numa responsabilidade separada de `/btt-sdd:baseline`: em
vez de documentar o sistema em si (`docs/BASELINE.md`), documenta como **este projeto**
particulariza o próprio pipeline SDD — só as divergências em relação ao padrão genérico, nunca o
óbvio. Útil a qualquer momento: logo após adotar o pipeline num projeto existente, ou depois de uma
mudança real de convenção (ex.: o time passou a usar outro prefixo de branch).

**Antes de qualquer coisa, leia `docs/SKILL-PREAMBLE.md`** — onde ficam os docs de governança
deste pipeline e de onde vêm os templates de `specs/_template/` (nenhum dos dois vive dentro do
projeto onde você está trabalhando). Resolva esse caminho a partir do "Base directory" desta
invocação: via junction global, é `docs/` na raiz do repositório do pipeline; via plugin, é
`docs/` dentro do pacote.

## Passos

1. Determine o escopo: o projeto inteiro (padrão) — não faz sentido escopar por spec, já que
   convenções de git/estrutura são transversais a todo o projeto.
2. Invoque o agente `codebase-archaeologist` (Agent tool, `subagent_type:
   "codebase-archaeologist"`) com instrução explícita para produzir/atualizar **apenas**
   `docs/PROJECT-CONVENTIONS.md` (não `docs/BASELINE.md` — essa é uma responsabilidade separada,
   acionada por `/btt-sdd:baseline`).
3. O agente pode concluir "nenhuma particularidade a registrar" sem criar nada — resultado válido e
   esperado (comum logo após `/btt-sdd:create-project`, antes de qualquer convenção real ter se
   estabelecido), não uma falha. Comunique esse resultado ao usuário normalmente.
4. Se `docs/PROJECT-CONVENTIONS.md` foi criado/atualizado, mostre um resumo ao usuário (as
   divergências registradas) e onde o arquivo ficou.

## Quando usar sem o agente

Se o Agent tool não estiver disponível, siga a seção "docs/PROJECT-CONVENTIONS.md — particularidades
do projeto vs. padrão do pipeline" de `agents/codebase-archaeologist.md` diretamente — nunca
corrija/ refatore o que encontrar, só documente.
