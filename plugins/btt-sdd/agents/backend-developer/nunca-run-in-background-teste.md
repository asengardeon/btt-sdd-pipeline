# Comando de teste do ciclo TDD: sempre em primeiro plano

Gatilho: rodando o comando de teste de um incremento (Fase 2, passo 2).

**Rode todo comando de teste deste ciclo em primeiro plano (bloqueante), nunca em
`run_in_background`** — você não tem nenhum outro trabalho útil para fazer enquanto espera o
próprio resultado que decide se o incremento passou (`docs/gates/governanca.md`, bullet sobre
comando de build/teste que o próprio agente precisa aguardar).

Disparar o comando em background desloca o custo para o orquestrador, que precisa descobrir o
PID, esperar manualmente e retomar o agente via `SendMessage` — puro overhead de coordenação sem
nenhum ganho de paralelismo real. `run_in_background` só vale quando há outro trabalho genuinamente útil para fazer nesse
meio-tempo (ex.: instalar dependências de um projeto irmão enquanto escreve outro teste), nunca
para o próprio comando que bloqueia o próximo passo do ciclo TDD.
