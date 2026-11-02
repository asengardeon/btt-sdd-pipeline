# `sre-review.md`: formato novo (split físico) vs. legado

Gatilho: ao registrar um achado/pendência (passo 4), ao escrever o veredito desta rodada (passo
4), ao commitar o artefato (passo 5), e ao confirmar contra `origin/<branch>` (passo 5a).

## Detecte o formato antes de escrever

`specs/<slug>/reviews/sre-review/` existe como diretório → **formato novo** (seção abaixo). Só
`specs/<slug>/sre-review.md` existe → **formato legado**. Para uma spec nova (nenhum dos dois
existe ainda), use o formato novo.

### Formato novo

Crie `specs/<slug>/reviews/sre-review/F-<N>.md` (ou `hotfix-<data>.md`, para correção pontual) a
partir de `specs/_template/reviews/sre-review/round.template.md`, com o veredito geral e as
áreas 2-6 desta rodada (CI, CD, Docker, Terraform, observabilidade) — nunca edite o `F-<N>.md` de
uma rodada já aprovada e mergeada. Acrescente a linha correspondente em `INDEX.md` (a partir de
`index.template.md`, se ainda não existir), preenchendo `Profundidade` e `Commit` — nunca
sobrescreva uma linha já existente. Atualize `tracking.md` (a partir de `tracking.template.md`,
se ainda não existir) com as pendências/VALIDAR DEPOIS/log desta rodada — é lá, não num número de
seção de um arquivo único, que a pendência nova do passo 4 entra.

### Formato legado

Edite in-place `specs/<slug>/sre-review.md` a partir de `specs/_template/sre-review.template.md`
como hoje — com veredito geral e uma linha nova na seção "Histórico de aprovações por fatia"
(preenchendo `Profundidade` e `Commit`) — nunca sobrescreva o veredito de uma fatia já aprovada e
mergeada. A pendência nova do passo 4 entra na tabela da seção 7 desse mesmo arquivo.

## Ao commitar (passo 5)

No formato novo, `git add` inclui `specs/<slug>/reviews/sre-review/F-<N>.md` (ou
`hotfix-<data>.md`) + `INDEX.md` + `tracking.md`. No formato legado, só
`specs/<slug>/sre-review.md`. Nos dois formatos, some também qualquer arquivo de
`infra/`/`.github/workflows/` ajustado nesta rodada e `docs/LESSONS-LEARNED.md` se você o
criou/atualizou — nunca `git add -A`/`.`.

## Ao confirmar contra `origin/<branch>` (passo 5a)

Se esta rodada não deu push, a confirmação local é `git log -1 --format=%H --` seguido dos
caminhos do formato em uso: `specs/<slug>/reviews/sre-review/` no formato novo,
`specs/<slug>/sre-review.md` no legado.
