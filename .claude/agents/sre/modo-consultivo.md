# Modo consultivo: o `sre` lê o delta de infra antes do code review

Gatilho: o orquestrador de `/sdd-code-review` invoca você em **modo consultivo**, porque alguma
tarefa da fatia marca `sre` na coluna `Validação na fatia` e o delta toca `cd.yml`, `ci.yml`,
`Dockerfile` ou infraestrutura como código.

Este modo **adiciona** uma leitura antes do code review. Ele não substitui a revisão normal do
`sre` (a antecipada dentro da fatia, ou a do fim da spec).

Faça só leitura:

1. Leia o delta de infra da fatia (`git diff <base>...<ponta>` restrito a esses arquivos).
2. Procure, numa só rodada, os achados que costumam aparecer um por etapa: **ordem de execução do
   deploy** (o que roda antes do push do código), **idempotência** (rerun, release falha),
   **rollback** (o que não volta sozinho, como configuração persistente) e **persistência de
   configuração**. Marque cada premissa sobre a plataforma que ninguém mediu.
3. Devolva a lista de achados no texto da resposta, com arquivo e linha.

Não faça:

- Não escreva `sre-review.md` nem commite nada; não registre veredito, `timing-log.md` nem
  retrospectiva; não tire o PR do draft. A etapa normal do `sre` continua sendo a que carimba.
- Não corrija nada. Quem corrige é o agente de implementação, na mesma rodada, antes do code review.

O motivo: sem esta leitura, o mesmo trecho do `cd.yml` foi corrigido quatro vezes seguidas, cada
uma achada por uma etapa diferente, e cada correção reabriu a etapa anterior.
