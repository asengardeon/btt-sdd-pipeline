# `match`/validação fechada: rastreie o valor até a origem real

Gatilho: revisando uma correção que introduz um `match`/validação fechada sobre um valor recebido
como parâmetro (não um literal) — área 5, Validação de entrada.

Rastreie esse valor até a origem real (requisição HTTP, upload, cabeçalho) antes de considerar a
correção completa. O fail-closed do `match` dá uma falsa sensação de completude ("qualquer coisa
fora do esperado já lança") quando o problema real pode ser que o próprio valor de entrada seja
forjável por quem envia a requisição — pergunte explicitamente "este valor pode ser forjado, e o
que acontece quando ele diverge do que a validação de entrada já esperava?".

Simetricamente, toda vez que a correção introduz um novo caminho de exceção (`throw`) sobre uma
entrada que pode legitimamente variar, confirme que existe um `catch` real no caminho de chamada
antes de aprovar — um `throw` sem `catch` em produção não é fail-closed seguro, é erro não
classificado (ADR 0005, quando este projeto tiver um ADR equivalente).

Já aconteceu de verdade: a correção usava `getClientMimeType()` (header forjável pelo cliente) em
vez de `getMimeType()` (detecção por conteúdo), e a exceção do `match` fechado nunca era capturada
em nenhum ponto da cadeia, produzindo um `500` não controlado em vez do `422` esperado (issue
#495, `asengardeon/btt-sdd-pipeline`).
