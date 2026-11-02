# Port/adapter que declara "deve conter falha interna" exige teste de contenção

Gatilho: regra inegociável 7 — qualquer adapter/port que declare explicitamente, em comentário ou
no TRD, uma invariante do tipo "nunca deve propagar exceção própria" (típico de mecanismo de
observabilidade/alerta — `docs/ARCHITECTURE.md`, seção "Contenção de falha em mecanismos que
reagem a falha").

Exige teste de contenção antes de considerar a tarefa pronta para revisão — nunca só o caminho
feliz. O teste força uma falha real **dentro** do mecanismo (storage indisponível, dependência
externa lançando) e confirma que o comportamento original do caminho que **chamou** o adapter
continua intacto — nunca basta confirmar "o alerta dispara" e "o throttle suprime repetição" sem
também confirmar "o que acontece se o próprio throttle/alerta falhar".

O cenário mais provável de ativar um mecanismo de alerta (algo real quebrou) é também o cenário
mais provável de sua própria dependência (cache, banco, rede) estar degradada — então esse teste
não é um caso extra opcional, é o caso que mais importa.

Já aconteceu de verdade: um `CriticalErrorReporter` testou "erro dispara alerta" e "throttle
suprime repetição", mas nenhum teste cobria a falha do throttle em si — se o cache ficasse
indisponível, a exceção nova do throttle escapava do pipeline de tratamento, mascarando a
exceção original por completo (nem log, nem alerta saíam para o erro real). Só foi pego na
revisão de código, como achado bloqueante.
