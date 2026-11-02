# Artefato gerado a partir de contrato: rode a geração, não só o build

Gatilho: esta trilha gera e commita um artefato a partir de um contrato (tipos/cliente gerados de
OpenAPI/GraphQL/protobuf, ou qualquer pipeline "gere e commite") — passo 5a-ter.

Rode a geração explícita seguida de diff contra o arquivo committed — nunca só o build de
desenvolvimento — antes de declarar a trilha pronta para code review. Build local costuma
regenerar esse artefato do zero a cada execução, o que mascara desvio entre o contrato e o
arquivo commitado (`docs/TESTING.md`, seção "Build/empacotamento real"). Rode o mesmo comando que
o CI roda para detectar esse desvio (geração + `git diff --exit-code` contra o arquivo gerado),
não o build.
