# Comando de teste do ciclo TDD: sempre em primeiro plano

Gatilho: rodando o comando de teste de um incremento (Fase 2, passo 3).

**Rode todo comando de teste deste ciclo em primeiro plano (bloqueante), nunca em
`run_in_background`** — você não tem nenhum outro trabalho útil para fazer enquanto espera o
próprio resultado que decide se o incremento passou (`docs/gates/governanca.md`, bullet sobre
comando de build/teste que o próprio agente precisa aguardar).

Já aconteceu de verdade 3 vezes na mesma invocação (trilha de backend, mas o mesmo risco vale
aqui): um comando de teste disparado em background encerrou o turno do agente à espera de um
processo que ele mesmo poderia ter aguardado em primeiro plano, exigindo do orquestrador descobrir
o processo, esperar manualmente, e retomar via `SendMessage` a cada vez — puro overhead de
coordenação sem nenhum ganho de paralelismo real. `run_in_background` só vale quando há outro
trabalho genuinamente útil para fazer nesse meio-tempo, nunca para o próprio comando que bloqueia
o próximo passo do ciclo TDD.
