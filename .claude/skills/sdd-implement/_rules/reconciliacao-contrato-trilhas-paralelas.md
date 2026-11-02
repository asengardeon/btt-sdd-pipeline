# Reconciliar contrato gerado entre trilhas paralelas após correção

Gatilho: esta correção foi dividida em trilhas backend+frontend paralelas e a trilha backend
publica/altera um contrato (OpenAPI/GraphQL/protobuf) que a trilha frontend consome via cliente
gerado.

Reconcilie depois que as duas terminarem — antes de considerar a correção pronta para a próxima
rodada de revisão. A orientação correta de não bloquear a trilha frontend enquanto o contrato
ainda não existe (ex.: "use a string literal '...', sem bloquear nisso") abre deliberadamente uma
janela em que o cliente gerado do frontend pode ficar desatualizado em relação ao contrato
publicado depois — nenhuma das duas trilhas, sozinha, tem como notar isso no momento em que
termina (o passo "detectar desvio de artefato gerado por contrato" de
`backend-developer.md`/`frontend-developer.md` só cobre o desvio dentro da própria trilha, no
instante em que ela termina, não depois que a outra trilha publica algo novo).

Depois que as duas trilhas terminarem, confirme você mesmo que o cliente gerado do frontend está
sincronizado com o contrato publicado (geração explícita + `git diff` vazio contra o arquivo
committed, ou equivalente) — mesmo quando nenhuma das duas trilhas sinalizou isso como pendência.
Já aconteceu de verdade: o frontend terminou e empurrou seu commit antes do backend publicar o
schema; ninguém regenerou o cliente tipado depois, e o desvio só foi pego pela rodada seguinte de
code review (passo de CI "detecção de desvio entre tipos gerados e committed"), gerando uma rodada
extra de correção mecânica + duas reverificações escopadas (issue #469,
`asengardeon/btt-sdd-pipeline`).

**Se essa reconciliação gerar um commit que toca código de produção (`frontend/src`, `src/`) de
uma trilha cujo `coverage/<fatia>-<trilha>.md` já foi committado, atualize você mesmo a referência
de SHA citada nesse arquivo, como parte do mesmo commit de reconciliação** — a troca do dublê
pelos tipos reais gerados não muda comportamento, mas deixa o `coverage/<fatia>-<trilha>.md`
citando um SHA que não é mais o último a tocar aquele código. Sem essa atualização aqui, a
inconsistência só é percebida (e corrigida) por uma etapa de revisão posterior, como achado de
processo fora do escopo dela (issue #487, `asengardeon/btt-sdd-pipeline`).

**Esta checagem de sincronia não é um checkpoint único "depois que as duas trilhas terminam" —
repita-a toda vez que retomar qualquer trilha via `SendMessage` para uma correção pontual
(ambiguidade, achado de revisão etc.) depois que a reconciliação inicial já tiver acontecido.**
Antes de considerar essa correção pontual pronta para a próxima rodada de revisão, confirme se o
diff dela toca o arquivo de contrato — se tocar, repita a geração explícita do cliente do lado
consumidor, mesmo que a reconciliação inicial já tivesse rodado antes nesta mesma fatia. Já
aconteceu de verdade: a reconciliação inicial já tinha confirmado a sincronia; uma 2ª invocação de
`backend-developer` (retomada para resolver uma ambiguidade levantada durante a própria
implementação) editou o contrato de novo sem regenerar o cliente, e o CI só pegou isso na revisão
de código seguinte (issue #493, `asengardeon/btt-sdd-pipeline`).
