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

Já aconteceu de verdade: um TRD descreveu um limite de célula de planilha como risco contido por
linha ("`PersistFailedException` para aquela linha"); a revisão de segurança mediu com a
biblioteca real e achou as duas metades erradas — o tipo lançado escapava do `catch when` do
adapter, e a chamada acontecia **fora** do `try` do caso de uso, então qualquer falha subia ao
`Task.WhenAll` e derrubava o lote inteiro. O impacto real era o oposto do descrito, e a frase
atravessou a aprovação do TRD, a implementação e duas etapas de revisão sem ser questionada.
