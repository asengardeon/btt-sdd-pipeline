# Propagação não detectada: campo novo em entidade, ou correção de bug em padrão estrutural

Gatilho: a fatia adiciona um campo a um construtor de entidade de domínio já existente, ou o dev
alega uma limitação arquitetural como justificativa para não implementar/reduzir um cenário de
teste.

## Campo novo em construtor de entidade → todo ponto de reconstrução do agregado

Quando esta fatia adiciona um campo (mesmo opcional/`default null`) ao construtor de uma entidade
de domínio já existente, grep por todo `new <Entidade>(` (ou equivalente na stack do projeto) em
todo o código-fonte, e confirme explicitamente, para cada ponto encontrado, se ele precisa
propagar o campo novo — não confie apenas na lista de arquivos que o TRD ou o dev listaram como
tocados. Um caso de uso de escrita fora do escopo da fatia que reconstrói o agregado sem repassar
o campo novo perde esse valor silenciosamente em toda edição futura — por exemplo, um campo
`deletedAt` perdido assim "ressuscita" um registro excluído, achado bloqueante de segurança mesmo
quando o mesmo padrão já apareceu sem gravidade numa fatia anterior.

**Se esta rodada sincronizou a branch com `main` e trouxe commits substanciais de outra feature
mergeada no meio do desenvolvimento desta fatia** (sinal vindo do passo de sincronização da skill
`/sdd-code-review`), trate qualquer varredura de propagação desse tipo que o dev tenha rodado
*antes* dessa sincronização como potencialmente desatualizada — confirme com um grep seu, agora,
em vez de assumir que ela continua válida: código novo trazido de `main` pode introduzir um novo
ponto de reconstrução do agregado que a varredura original não podia ter visto.

## Limitação arquitetural alegada: busque correção precedente para o mesmo padrão

Ao confirmar uma limitação arquitetural alegada pelo dev como justificativa para não implementar
(ou implementar de forma reduzida) um cenário de teste: não pare em verificar se a alegação é
verdadeira — busque ativamente se já existe uma correção precedente para o mesmo padrão
estrutural em outro lugar do código-fonte (grep pelo nome do método/guard relacionado à
limitação, ou pela mesma classe de bug já registrada em `docs/LESSONS-LEARNED.md`) antes de
aceitar a limitação como definitiva.

O dev que confirma uma limitação não tem como saber se uma correção idêntica para o mesmo padrão
estrutural já existe em outro lugar do código-base (não é seu mandato auditar todo o código
correlato ao confirmar uma limitação já assumida); é o `code-reviewer` que precisa buscar isso,
não só quando pedido explicitamente. Distinto do item anterior (campo novo não propagado para todo ponto de
reconstrução do agregado): aqui o que não foi propagado é uma correção de bug para todo consumidor
com o mesmo padrão estrutural, não um campo novo.
