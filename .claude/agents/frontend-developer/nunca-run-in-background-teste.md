# Comando de teste do ciclo TDD: sempre em primeiro plano

Gatilho: rodando o comando de teste de um incremento (Fase 2, passo 3).

**Rode todo comando de teste deste ciclo em primeiro plano (bloqueante), nunca em
`run_in_background`** — você não tem nenhum outro trabalho útil para fazer enquanto espera o
próprio resultado que decide se o incremento passou (`docs/gates/governanca.md`, bullet sobre
comando de build/teste que o próprio agente precisa aguardar).

Disparar o comando em segundo plano desloca esse custo para o orquestrador (descobrir o processo,
esperar manualmente, retomar via `SendMessage`), sem nenhum ganho de paralelismo real.
`run_in_background` só vale quando há outro trabalho genuinamente útil para fazer nesse
meio-tempo, nunca para o próprio comando que bloqueia o próximo passo do ciclo TDD.
