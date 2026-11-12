# Checklist pré-revisão: padrões que já custaram uma rodada extra

Gatilho: antes de considerar qualquer tarefa "pronta", passo 4b da Fase 2.

- Todo uso de `URL.createObjectURL` (ex.: preview de arquivo antes do upload) tem um
  `URL.revokeObjectURL` pareado cobrindo **sucesso, erro e desmontagem do componente** — nunca só
  o caminho feliz. Objeto URL não revogado é vazamento de memória silencioso, sem erro visível em
  teste ou build.
- Todo `aria-label`/`aria-labelledby` derivado de dado do usuário dentro de uma lista renderizada
  dinamicamente inclui um identificador único (índice/id) — nunca só o campo de dado bruto, que
  pode se repetir entre itens da mesma lista (ex.: dois arquivos do mesmo lote com o mesmo nome) e
  colidir silenciosamente para tecnologia assistiva.
- Todo controle com `aria-label` começa com o texto visível (WCAG 2.5.3, rótulo no nome). O nome
  acessível que não contém o texto da tela quebra quem comanda a interface por voz.
- Todo par de cores novo (texto/fundo) tem o contraste **calculado a partir dos tokens, sem
  arredondar**, e registrado na matriz do design system antes da revisão. "No limite" (≈4,5:1)
  conta como não medido: 4,497:1 reprova um mínimo de 4,5:1, e o revisor recalcula.
- Componente repetível por linha, com várias instâncias abertas ao mesmo tempo, tem um nome
  acessível que distingue cada instância (`role="group"` + `aria-labelledby` apontando para o
  rótulo da linha).
- Rode mutação nos ramos novos: remova a condição ou a variável e confirme que algum teste falha.
  Variável cuja remoção não muda teste algum é código morto.

Estes padrões já custaram rodadas extras de correção + reverificação em sessões reais, evitáveis
antes do code review em vez de descobertos depois.
