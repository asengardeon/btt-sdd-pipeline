# `security-review.md`: formato novo (split físico) vs. legado

Gatilho: antes de registrar um achado (passo 3), ao escrever o veredito desta rodada (passo 4), e
ao commitar o artefato (passo 5).

## Detecte o formato antes de escrever

`specs/<slug>/reviews/security-review/` existe como diretório → **formato novo** (seção abaixo).
Só `specs/<slug>/security-review.md` existe → **formato legado**. Para uma spec nova (nenhum dos
dois existe ainda), use o formato novo.

### Formato novo

Crie `specs/<slug>/reviews/security-review/F-<N>.md` (ou `hotfix-<data>.md`, para correção
pontual) a partir de `specs/_template/reviews/security-review/round.template.md`, com o veredito
geral e as áreas 2-7 desta rodada (superfície de ataque, OWASP, segredos, autenticação/
autorização, validação de entrada, dependências) — nunca edite o `F-<N>.md` de uma rodada já
aprovada e mergeada. Acrescente a linha correspondente em `INDEX.md` (a partir de
`index.template.md`, se ainda não existir), preenchendo `Profundidade` e `Commit` — nunca
sobrescreva uma linha já existente. Atualize `tracking.md` (a partir de `tracking.template.md`,
se ainda não existir) com os achados/pendências/log desta rodada — é lá, não num número de seção
de um arquivo único, que o achado novo do passo 3 entra.

### Formato legado

Edite in-place `specs/<slug>/security-review.md` a partir de
`specs/_template/security-review.template.md` como hoje — com veredito geral e uma linha nova na
seção "Histórico de aprovações por fatia" (preenchendo `Profundidade` e `Commit`) — nunca
sobrescreva o veredito de uma fatia já aprovada e mergeada. O achado novo do passo 3 entra na
tabela da seção 8 desse mesmo arquivo.

## Ao commitar (passo 5)

No formato novo, `git add` inclui `specs/<slug>/reviews/security-review/F-<N>.md` (ou
`hotfix-<data>.md`) + `INDEX.md` + `tracking.md`. No formato legado, só
`specs/<slug>/security-review.md`. Nos dois formatos, some também `docs/LESSONS-LEARNED.md` se
você o criou/atualizou — nunca `git add -A`/`.`.
