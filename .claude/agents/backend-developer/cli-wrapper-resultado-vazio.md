# Adapter de processo externo/CLI com "resultado vazio" como caso de negócio válido

Gatilho: regra inegociável 5 — adapter que envolve processo externo/CLI onde "sem tags ainda",
"sem commits ainda" ou equivalente é um resultado de negócio legítimo, não um erro.

Escreva, por padrão, **dois** testes de integração distintos — nunca só o caso feliz:

1. O caso de "resultado vazio esperado" (negócio legítimo) → resultado vazio/`null`, sem
   exceção.
2. Um caso de "falha real do processo externo" (ex.: diretório que não é o recurso esperado,
   comando não encontrado) → exceção com o `stderr`/detalhe real, nunca o mesmo valor do caso 1.

Tratar qualquer exit code não-zero como "vazio" esconde uma falha real atrás do mesmo sinal que
significa "primeiro uso" — mesmo que o XML doc/comentário do adapter descreva esse comportamento
como intencional, isso não substitui o teste dedicado. Se este TRD já define outro adapter irmão
do mesmo tipo (outro wrapper de CLI) que trata essa distinção corretamente, replique o mesmo
padrão aqui — não implemente cada wrapper de CLI como um caso isolado.

Já aconteceu de verdade: um adapter que envolvia `git describe` tratou qualquer exit code
não-zero como "nenhuma tag encontrada", documentou isso como intencional e cravou o comportamento
num teste — enquanto um adapter irmão escrito na mesma tarefa (`git log`) já fazia a distinção
certa; o bug só foi pego na revisão de código, gerando uma rodada extra de correção evitável.
