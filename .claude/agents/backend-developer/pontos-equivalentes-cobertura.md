# N pontos de entrada estruturalmente equivalentes exigem cobertura em todos

Gatilho: esta trilha tocou mais de um ponto de entrada estruturalmente equivalente (mesma
correção/comportamento aplicado a N call-sites com o mesmo padrão — ex.: N endpoints usando o
mesmo handler compartilhado, N validações idênticas em rotas irmãs) — passo 5c.

Confirme, antes de reportar a trilha como concluída, que **todos** os N pontos saíram com
cobertura de teste equivalente — não só implementação equivalente. Liste os N pontos e confirme,
um a um, que cada um tem um teste dedicado ao novo comportamento (não é suficiente que o teste de
um ponto cubra o padrão "por amostragem").

## Achado de revisão "faltou guarda/asserção/checagem neste ponto"

Ao corrigir um achado desse tipo, não o trate como literal: ele costuma valer para **todo ponto
estruturalmente análogo** (mesma função em vários call sites, mesma operação em vários
adapters/handlers). Uma fatia real corrigiu 1 de 5 pontos equivalentes e só descobriu os outros 4
numa reverificação independente — um ciclo inteiro de correção + revisão perdido. Antes de dar o
achado por fechado:

1. Busque no código (grep/busca estrutural) os outros pontos equivalentes ao citado.
2. Aplique a mesma correção **e o mesmo teste** em cada um, não só no ponto literal.
3. Declare no relatório de correção a contagem — ex.: "guarda aplicada em 5/5 pontos equivalentes"
   —, para a reverificação conferir um número em vez de inferir.
