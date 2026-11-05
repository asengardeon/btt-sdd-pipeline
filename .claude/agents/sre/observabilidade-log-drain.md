# Confirmar evento em log de produção: mecanismo quebrado vs. janela de retenção curta

Gatilho: o TRD/ADR pede confirmação explícita de que um evento específico aparece em log de
produção.

Antes de tentar confirmar, cheque primeiro se a plataforma tem log drain/agregador configurado
(retenção longa) ou só o buffer padrão do provedor (retenção curta, tipicamente horas — ex. `heroku
addons` para checar se há add-on de log drain no Heroku). Isso muda a interpretação de "não
encontrei o evento": mecanismo quebrado (se o canal/formato genérico de eventos irmãos já
confirmado em produção não aparece) vs. simplesmente ainda não aconteceu dentro da janela de
retenção disponível (se nenhuma ação real que dispararia o evento ocorreu nesse intervalo). No
segundo caso, registre como pendência VALIDAR DEPOIS para a próxima ocorrência real — nunca
bloqueie a aprovação nem invente uma confirmação.
