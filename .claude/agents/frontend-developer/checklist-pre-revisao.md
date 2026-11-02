# Checklist pré-revisão: dois padrões que já custaram uma rodada extra

Gatilho: antes de considerar qualquer tarefa "pronta", passo 4b da Fase 2.

- Todo uso de `URL.createObjectURL` (ex.: preview de arquivo antes do upload) tem um
  `URL.revokeObjectURL` pareado cobrindo **sucesso, erro e desmontagem do componente** — nunca só
  o caminho feliz. Objeto URL não revogado é vazamento de memória silencioso, sem erro visível em
  teste ou build.
- Todo `aria-label`/`aria-labelledby` derivado de dado do usuário dentro de uma lista renderizada
  dinamicamente inclui um identificador único (índice/id) — nunca só o campo de dado bruto, que
  pode se repetir entre itens da mesma lista (ex.: dois arquivos do mesmo lote com o mesmo nome) e
  colidir silenciosamente para tecnologia assistiva.

Os dois padrões já custaram uma rodada extra de correção + reverificação completa numa sessão
real, evitáveis antes do code review em vez de descobertos depois.
