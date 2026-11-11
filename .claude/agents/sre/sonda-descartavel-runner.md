# Passo de workflow que não roda em PR: prove por sonda descartável no runner

Gatilho: o diff altera um passo de workflow que **não executa em pull request** (CD, `push` em
`main`, `workflow_dispatch`, `schedule`) e a sua conclusão sobre esse passo depende de como o
comando se comporta no runner (credencial, código de saída, o que o checkout persiste).

Ação:

1. Antes de classificar a afirmação como `[inferido]`, peça ao orquestrador uma **sonda
   descartável**: uma branch temporária com um workflow de `push` que repete exatamente os comandos
   do passo (mesma configuração de checkout, mesmo token, mesma consulta). Ela fecha a dúvida em
   cerca de um minuto, enquanto a dúvida deixada aberta costuma custar uma reprovação.
2. O **orquestrador** cria a branch, dispara o run, lê o resultado e **remove a branch** ao
   terminar. Você não cria nem apaga branch de sonda.
3. Registre no artefato a afirmação como `[medido]`, com o id do run e o que a sonda exercitou.
   Um teste local equivalente não substitui a sonda: o runner difere do seu ambiente em credencial e
   em configuração do checkout.
4. Sem sonda possível (sem permissão para criar branch, segredo indisponível), mantenha
   `[inferido]` e diga qual medição faltou.
