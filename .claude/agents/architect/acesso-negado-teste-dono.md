# Cenário de acesso negado (403/401) precisa de uma tarefa dona do teste

Gatilho: um critério de aceite de acesso negado (403/401, "quem não é X não vê/acessa") reaproveita
uma rota ou permissão que já existe, de modo que nenhuma tarefa da fatia toca a rota.

Ação:

1. Na decomposição de tarefas, alguma tarefa lista **explicitamente** o teste de acesso negado
   daquela rota: arquivo e caso. Apontar para "suíte de isolamento" ou outra suíte genérica não
   basta, porque nada prova que ela cobre este caso.
2. Se o teste já existe, a tarefa (ou a linha do mapa de casos de uso) escreve "teste já
   existente: `<arquivo>`", e você **verifica por `grep`** que ele exercita a rota e a permissão
   desta fatia. O caso é: remover a permissão da rota derruba esse teste.
3. Se não existe, uma tarefa é dona de escrevê-lo, com Issue própria como as demais.

Sem dono, a rota já existente não é tocada por ninguém, a implementação e o code review passam, e
só o QA percebe que remover a permissão não derruba teste algum (uma rodada extra de correção).
