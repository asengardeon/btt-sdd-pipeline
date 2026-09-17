---
name: sdd-project-conventions
description: Utilitário do pipeline SDD, sem posição fixa numa etapa. Use quando o usuário quiser registrar/atualizar as particularidades deste projeto em relação ao padrão genérico do pipeline — modelo de workflow de Git, estrutura de pastas, nomenclatura etc. — para facilitar a identidade própria do projeto. Aciona o agente codebase-archaeologist para produzir/atualizar docs/PROJECT-CONVENTIONS.md.
---

# /sdd-project-conventions

Aciona o agente **arqueólogo de código** numa responsabilidade separada de `/sdd-baseline`: em vez
de documentar o sistema em si (`docs/BASELINE.md`), documenta como **este projeto** particulariza o
próprio pipeline SDD — só as divergências em relação ao padrão genérico, nunca o óbvio. Útil a
qualquer momento: logo após adotar o pipeline num projeto existente, ou depois de uma mudança real
de convenção (ex.: o time passou a usar outro prefixo de branch).

## Onde ficam os docs de governança citados nesta skill

Referências como `docs/GIT-WORKFLOW.md` e `docs/FILE-GUIDE.md` nesta skill apontam para os docs
genéricos deste pipeline — **não são copiados para dentro de cada projeto que o usa**. Resolva-os a
partir de onde esta própria skill está instalada (o "Base directory" desta invocação): se for
`.claude/skills/<esta-skill>/` apontando para este repositório via junction global (`CLAUDE.md`,
seção "Distribuição global"), esses docs estão em `docs/` na raiz **deste mesmo repositório** — não
necessariamente no projeto onde você está trabalhando agora.

## Passos

1. Determine o escopo: o projeto inteiro (padrão) — não faz sentido escopar por spec, já que
   convenções de git/estrutura são transversais a todo o projeto.
2. Invoque o agente `codebase-archaeologist` (Agent tool, `subagent_type:
   "codebase-archaeologist"`) com instrução explícita para produzir/atualizar **apenas**
   `docs/PROJECT-CONVENTIONS.md` (não `docs/BASELINE.md` — essa é uma responsabilidade separada,
   acionada por `/sdd-baseline`).
3. O agente pode concluir "nenhuma particularidade a registrar" sem criar nada — resultado válido e
   esperado (comum logo após `/create-project`, antes de qualquer convenção real ter se
   estabelecido), não uma falha. Comunique esse resultado ao usuário normalmente.
4. Se `docs/PROJECT-CONVENTIONS.md` foi criado/atualizado, mostre um resumo ao usuário (as
   divergências registradas) e onde o arquivo ficou.

## Quando usar sem o agente

Se o Agent tool não estiver disponível, siga a seção "docs/PROJECT-CONVENTIONS.md — particularidades
do projeto vs. padrão do pipeline" de `.claude/agents/codebase-archaeologist.md` diretamente — nunca
corrija/refatore o que encontrar, só documente.
