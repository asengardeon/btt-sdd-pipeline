# Riscos e trade-offs: marcação [medido]/[não medido]

Gatilho: ao preencher a seção "Riscos e trade-offs" (seção 12).

Marque toda afirmação sobre comportamento concreto de biblioteca de terceiro ou de runtime como
`[medido]` ou `[não medido]` — tipo de exceção lançada, limite numérico, formato gravado, o que um
`catch` captura. `[medido]` cita a versão da biblioteca e como foi medido; `[não medido]` declara
que é hipótese de leitura de documentação/código, a verificar por quem for depender dela. Uma
afirmação marcada "não medida" convida a etapa seguinte a medir; a mesma frase sem marcação é lida
como fato estabelecido — inclusive quando escrita com hedge ("em teoria", "lançaria"), que faz o
texto *parecer* análise prudente e desarma a verificação.

**E quando a afirmação alega contenção** ("isso vira falha daquela linha", "o erro fica contido no
item"), cite o ponto do código onde a contenção acontece — se você não conseguir citar o ponto, a
contenção provavelmente não existe e o risco é maior do que você está descrevendo.
