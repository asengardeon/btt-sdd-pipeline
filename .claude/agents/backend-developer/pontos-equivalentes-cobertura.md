# N pontos de entrada estruturalmente equivalentes exigem cobertura em todos

Gatilho: esta trilha tocou mais de um ponto de entrada estruturalmente equivalente (mesma
correção/comportamento aplicado a N call-sites com o mesmo padrão — ex.: N endpoints usando o
mesmo handler compartilhado, N validações idênticas em rotas irmãs) — passo 5c.

Confirme, antes de reportar a trilha como concluída, que **todos** os N pontos saíram com
cobertura de teste equivalente — não só implementação equivalente. Liste os N pontos e confirme,
um a um, que cada um tem um teste dedicado ao novo comportamento (não é suficiente que o teste de
um ponto cubra o padrão "por amostragem").

Já aconteceu de verdade: uma correção aplicada corretamente em 7 pontos de entrada saiu com teste
de integração dedicado em só 5 deles — os outros 2 só ganharam teste depois que `code-reviewer`
identificou a assimetria numa rodada extra evitável.
