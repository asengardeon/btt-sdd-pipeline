# `qa-report.md`: formato novo (split físico) vs. legado

Gatilho: antes de registrar um achado (passo 0), ao escrever o veredito desta rodada (passo 7),
e ao commitar o artefato (passo 8).

## Detecte o formato antes de escrever

`specs/<slug>/reviews/qa-report/` existe como diretório → **formato novo** (seção abaixo). Só
`specs/<slug>/qa-report.md` existe → **formato legado**. Para uma spec nova (nenhum dos dois
existe ainda), use o formato novo.

### Formato novo

Crie `specs/<slug>/reviews/qa-report/F-<N>.md` (ou `hotfix-<data>.md`, para correção pontual) a
partir de `specs/_template/reviews/qa-report/round.template.md`, com o veredito geral e as áreas
2-5 desta rodada (cobertura, critérios de aceite, regressão/build, aderência a ports & adapters)
— nunca edite o `F-<N>.md` de uma rodada já aprovada e mergeada. Acrescente a linha
correspondente em `INDEX.md` (a partir de `index.template.md`, se ainda não existir) — nunca
sobrescreva uma linha já existente. Atualize `tracking.md` (a partir de `tracking.template.md`,
se ainda não existir) com os achados/pendências/log desta rodada — é lá, não num número de seção
de um arquivo único, que o achado novo do passo 0 entra.

### Formato legado

Edite in-place `specs/<slug>/qa-report.md` a partir de `specs/_template/qa-report.template.md`
como hoje — com veredito geral e uma linha nova na seção "Histórico de aprovações por fatia" —
nunca sobrescreva o veredito de uma fatia já aprovada e mergeada. O achado novo do passo 0 entra
na tabela da seção 6 desse mesmo arquivo.

## Ao commitar (passo 8)

No formato novo, `git add` inclui `specs/<slug>/reviews/qa-report/F-<N>.md` (ou
`hotfix-<data>.md`) + `INDEX.md` + `tracking.md`. No formato legado, só
`specs/<slug>/qa-report.md`. Nos dois formatos, some também o(s) arquivo(s) de cobertura
regravados no passo 2 e `docs/LESSONS-LEARNED.md` se você o criou/atualizou — nunca `git add
-A`/`.`.
