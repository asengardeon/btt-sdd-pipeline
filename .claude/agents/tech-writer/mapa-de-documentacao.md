# `docs/DOCS-MAP.md`: mapa de navegação da constelação de artefatos

Gatilho: você foi invocado com escopo amplo ("documentar tudo"/inventário completo), ou foi
acionado automaticamente por `/sdd-sre` ao aprovar a última fatia pendente de uma spec
(`CLAUDE.md`, linha do comando `/sdd-docs`). **Não** gere/atualize este arquivo numa invocação
escopada a um único arquivo específico (ex.: "atualize a seção de instalação do README") — o
custo de varrer `specs/` inteiro não se justifica para um pedido pontual.

## Por que este arquivo existe

Desde `docs/MICRO-CONTEXT.md`, seção 2, um artefato de revisão pode estar em dois formatos —
arquivo único (`specs/<slug>/<stage>.md`) ou split físico por rodada
(`specs/<slug>/reviews/<stage>/INDEX.md` + `tracking.md` + `F-<N>.md`) — e cada spec migra de
forma independente, no seu próprio ritmo. Sem um índice central, qualquer agente/skill que
precisa encontrar "o artefato de QA da spec X" tem que primeiro descobrir qual dos dois formatos
está em uso antes de conseguir ler qualquer coisa. `docs/DOCS-MAP.md` resolve isso de uma vez:
aponta, para cada spec e cada artefato, o caminho exato de entrada — sem que quem lê precise
adivinhar ou testar os dois formatos.

## Estrutura exata do arquivo

```markdown
# Mapa de documentação — <nome do projeto>

Índice de onde cada artefato deste pipeline vive — gerado/atualizado por `tech-writer`
(`/sdd-docs`). **Não edite manualmente**: peça uma atualização via `/sdd-docs` em vez de editar
este arquivo direto, ou a próxima regeneração sobrescreve a edição manual sem aviso.

Atualizado em: <AAAA-MM-DD>

## Specs

| Slug | PRD | TRD | Code review | UX review | QA | Segurança | SRE |
|------|-----|-----|--------------|-----------|----|-----------|-----|
| <slug> | `prd.md` | `trd.md` | `reviews/code-review/INDEX.md` (novo) | `ux-review.md` (legado) | — | — | — |

Cada célula de artefato de revisão é um dos três valores: o caminho de entrada com `(novo)` —
`reviews/<stage>/INDEX.md` —, o caminho com `(legado)` — `<stage>.md` —, ou `—` se o artefato
ainda não existe para aquela spec/fatia.

## Docs do projeto (`docs/`)

| Arquivo | Existe? | Resumo de 1 linha |
|---|---|---|
| `docs/STACK.md` | sim/não | <resumo, ou "—" se não existe> |
| `docs/BASELINE.md` | sim/não | |
| `docs/PROJECT-CONVENTIONS.md` | sim/não | |
| `docs/LESSONS-LEARNED.md` | sim/não | |
| `docs/GLOSSARY.md` | sim/não | |
| `docs/DESIGN-SYSTEM.md` | sim/não | |
| `docs/FEATURES.md` | sim/não | ver `tech-writer/catalogo-de-features.md` |

## ADRs (`docs/adr/`)

| # | Título | Arquivo |
|---|--------|---------|
| 0001 | <título> | `docs/adr/0001-<slug>.md` |
```

## Processo de geração

1. **Specs**: `Glob` em `specs/*/` (exclua `_template`). Para cada slug, e para cada um dos 5
   artefatos de revisão (`code-review`, `ux-review`, `qa-report`, `security-review`,
   `sre-review`), teste `specs/<slug>/reviews/<stage>/INDEX.md` primeiro; se não existir, teste
   `specs/<slug>/<stage>.md`; se nenhum existir, a célula é `—` (mesma lógica de detecção já
   usada por `sdd-status.sh`/`sdd-pending.sh`, `docs/MICRO-CONTEXT.md`, seção 2). PRD e TRD não
   têm dual-format — só confira se `prd.md`/`trd.md` existem.
2. **Docs do projeto**: teste a existência de cada arquivo condicional listado na tabela. Para o
   resumo de 1 linha, leia só o suficiente do arquivo para extrair a essência (ex.: a primeira
   frase de `docs/STACK.md`, ou o título da decisão mais recente) — nunca abra o arquivo inteiro
   só para preencher uma linha de resumo.
3. **ADRs**: `Glob` em `docs/adr/*.md` (exclua o modelo `0001-record-architecture-decisions.md`
   se ele for só o template explicativo, não uma decisão real deste projeto — confirme pelo
   título). Liste número + título de cada um.
4. **Escreva/edite `docs/DOCS-MAP.md` in-place** (crie se não existir) seguindo a estrutura
   exata acima. Atualize a data no topo.
5. Nunca invente uma linha para uma spec/artefato que você não confirmou existir por teste de
   caminho real — toda célula reflete o que você de fato encontrou nesta rodada, não o que
   "provavelmente" deveria existir.
