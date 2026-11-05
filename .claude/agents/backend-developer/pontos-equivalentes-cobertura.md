# N pontos de entrada estruturalmente equivalentes exigem cobertura em todos

Gatilho: esta trilha tocou mais de um ponto de entrada estruturalmente equivalente (mesma
correção/comportamento aplicado a N call-sites com o mesmo padrão — ex.: N endpoints usando o
mesmo handler compartilhado, N validações idênticas em rotas irmãs) — passo 5c.

Confirme, antes de reportar a trilha como concluída, que **todos** os N pontos saíram com
cobertura de teste equivalente — não só implementação equivalente. Liste os N pontos e confirme,
um a um, que cada um tem um teste dedicado ao novo comportamento (não é suficiente que o teste de
um ponto cubra o padrão "por amostragem").
