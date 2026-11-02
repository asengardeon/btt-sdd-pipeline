# Evidência direta, não suposição: erro opaco e relato de mutação

Gatilho: depurando um erro opaco (resposta sem detalhe, geometria que não bate, falha de e2e
genérica), ou reportando mutação como evidência de discriminância dos testes.

## Erro opaco se depura capturando a evidência bruta primeiro — não formulando a correção primeiro

Erro opaco é o que não nomeia sua própria causa: um `422` sem detalhe de campo, uma geometria que
não bate (overflow de N pixels), uma falha de e2e com mensagem genérica. Diante dele, o primeiro
passo é **uma medição direta do fenômeno**, não uma hipótese: o corpo real da resposta HTTP
(capturado da rede — `page.waitForResponse` + `await response.json()` ou equivalente), não o que
o esquema/VO "deveria" produzir; a geometria real do documento renderizado
(`getBoundingClientRect()`/`scrollWidth` avaliados no navegador), não a árvore de acessibilidade,
que mostra **estrutura** e não **geometria**. Custa uma linha de código ou um `console.log`; uma
rodada de correção baseada em hipótese errada custa a rodada inteira.

**Uma correção que não move a medição não é a correção** — se você mediu o mesmo valor antes e
depois, isso já é a prova de que a causa é outra, e não uma razão para empurrar a mudança e
esperar o CI decidir. Ao relatar a correção, diga **qual medição direta confirmou a causa**;
eliminação de hipóteses por leitura de código não fecha causa, só estreita a busca.

Já aconteceu de verdade, duas vezes na mesma fatia: um overflow "corrigido" por leitura da árvore
de acessibilidade do Playwright (a causa real era outro elemento, sem `flex-wrap`, achado só ao
instrumentar a geometria no navegador), e um `422` com duas hipóteses descartadas por leitura de
VO antes de alguém capturar o corpo real e ver `fields: []` — a pista que levou à causa genuína.

## Relato de mutação: a asserção que falhou, não só "N testes morreram"

Se você reportar mutação como evidência de discriminância dos testes, informe **qual asserção
falhou (arquivo:linha) e a mensagem de falha** — nunca só "mutação X, N testes morreram". Esse
formato resumido torna invisível o engano mais comum: uma mutação que quebra o fluxo *antes* do
ponto sob teste mata o teste por uma asserção anterior, e o vermelho é indistinguível do que se
queria provar. Se a asserção que falhou não é a que a mutação pretendia exercitar, **diga isso**
— é informação, não demérito, e é o que permite ao revisor construir a mutação complementar em
vez de repetir a sua.
