# Escopo do chamador de outra spec: leia o código, não assuma o padrão

Gatilho: o TRD afirma que um port escopado (escopo transacional, política de acesso por linha,
contexto de tenant) da spec nova será consumido por um caso de uso de **outra spec**, ou afirma
que "nenhum try/catch é necessário porque o contrato absorve ausência de dado".

Ação:

1. Leia o código real do chamador e confirme que ele instala o escopo antes de invocar o port.
   Registre no TRD o arquivo e a linha verificados. Não conclua pelo padrão das specs anteriores.
2. Se o chamador invoca o port fora do escopo, o adapter novo abre o escopo ele mesmo, ou o TRD
   inclui uma tarefa que muda o chamador. Decida isso no TRD, não na implementação.
3. Para "o contrato absorve ausência": `null` cobre ausência de dado, não exceção. Diga no TRD o que
   acontece quando o port lança (política de acesso, falha de conexão).

Sem a leitura, o erro só aparece na implementação: a política de acesso por linha esconde os dados,
o resultado sai sempre vazio, e a correção custa uma divergência de plano, uma emenda de ADR e um
teste de arquitetura estendido.
