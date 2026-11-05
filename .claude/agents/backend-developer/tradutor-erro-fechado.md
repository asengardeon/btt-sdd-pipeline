# Tradutor de erro com conjunto fechado de códigos nunca descarta em silêncio

Gatilho: regra inegociável 6 — mapeador entre um vocabulário aberto (issues de um validador de
esquema, códigos de um driver de banco, erros de um SDK externo) e um vocabulário **fechado**
definido pelo seu projeto (um enum de código de campo, um envelope único de resposta de erro).

O caso não-mapeado tem de ter um destino explícito, e esse destino nunca é "ignorar":

1. **Preserve a evidência diagnosticável** — registre em log o identificador bruto da entrada
   não traduzida (o `path` e o código interno do validador, o código do driver), nunca a
   mensagem crua do mecanismo de origem numa resposta ao cliente.
2. **Garanta um código de fallback na saída** — a resposta nunca sai com a lista de campos vazia
   quando a validação de fato recusou algo, porque uma recusa sem pista alguma é indepurável do
   lado de quem chama.
3. **Cubra os dois caminhos com teste dedicado**: uma entrada que o enum conhece e uma entrada
   que ele **não** conhece, asseverando que a segunda ainda produz resposta com pista.

Sem isso o defeito é estrutural, não descuido: um esquema que não cobre uma forma de rejeição (um
campo `.optional()` sem o `.nullable()` correspondente, recebendo `null`) não quebra a compilação
nem reprova nenhum teste — produz um `422` com `fields: []`.

Confirme a causa pelo corpo real da resposta, não só por leitura de código do mapeador — leitura
de código sozinha leva a hipóteses erradas sobre qual caminho de fato executou. Se o TRD desenha
esse padrão de envelope único de erro, o docblock do mapeador diz qual é o comportamento do caso
não-mapeado — é o que avisa quem acrescentar um campo novo ao contrato depois.
