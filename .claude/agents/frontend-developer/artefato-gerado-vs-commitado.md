# Artefato gerado a partir de contrato: rode a geração, não só o build

Gatilho: esta trilha gera e commita um artefato a partir de um contrato (tipos/cliente gerados de
OpenAPI/GraphQL/protobuf, ou qualquer pipeline "gere e commite") — passo 5a-ter.

Rode a geração explícita seguida de diff contra o arquivo committed — nunca só o build de
desenvolvimento — antes de declarar a trilha pronta para code review. Build local costuma
regenerar esse artefato do zero a cada execução, o que mascara desvio entre o contrato e o
arquivo commitado (`docs/TESTING.md`, seção "Build/empacotamento real"). Rode o mesmo comando que
o CI roda para detectar esse desvio (geração + `git diff --exit-code` contra o arquivo gerado),
não o build.

Já aconteceu de verdade: um arquivo de tipos à mão ficou desatualizado em relação ao contrato
publicado pela trilha de backend, o build local regenerava e mascarava o desvio a cada execução,
e o defeito funcional resultante só foi notado pelo `code-reviewer` numa rodada inteira depois,
com o CI já vermelho desde o primeiro push (issue #449, `asengardeon/btt-sdd-pipeline`).
