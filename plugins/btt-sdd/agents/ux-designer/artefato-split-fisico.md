# `ux-review.md`: formato novo (split físico) vs. legado

Gatilho: ao escrever o veredito desta rodada (passo 5) e ao commitar o artefato (passo 6) do
Processo (modo revisão pós-implementação).

## Detecte o formato antes de escrever

`specs/<slug>/reviews/ux-review/` existe como diretório → **formato novo** (seção abaixo). Só
`specs/<slug>/ux-review.md` existe → **formato legado**. Para uma spec nova (nenhum dos dois
existe ainda), use o formato novo.

### Formato novo

Crie `specs/<slug>/reviews/ux-review/F-<N>.md` (ou `hotfix-<data>.md`, para correção pontual) a
partir de `specs/_template/reviews/ux-review/round.template.md`, com o veredito geral, o método
usado e as áreas 2-8 desta rodada — nunca edite o `F-<N>.md` de uma rodada já aprovada e
mergeada. Acrescente a linha correspondente em `INDEX.md` (a partir de `index.template.md`, se
ainda não existir) — nunca sobrescreva uma linha já existente. Atualize `tracking.md` (a partir
de `tracking.template.md`, se ainda não existir) com os achados/pendências/log desta rodada — é
lá, não num número de seção de um arquivo único, que o achado do passo 4 entra.

### Formato legado

Edite in-place `specs/<slug>/ux-review.md` a partir de `specs/_template/ux-review.template.md`
como hoje — com veredito geral, o método usado, e uma linha nova na seção "Histórico de
aprovações por fatia" — nunca sobrescreva o veredito de uma fatia já aprovada e mergeada. O
achado do passo 4 entra na tabela da seção 9 desse mesmo arquivo.

## Ao commitar (passo 6)

No formato novo, `git add` inclui `specs/<slug>/reviews/ux-review/F-<N>.md` (ou
`hotfix-<data>.md`) + `INDEX.md` + `tracking.md`. No formato legado, só
`specs/<slug>/ux-review.md`. Nunca `git add -A`/`.`.
