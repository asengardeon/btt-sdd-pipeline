# Workflow/infra sem harness real: confira a mutação, não só os cenários

Gatilho: o diff adiciona lógica de workflow de CI/CD, script de deploy ou infraestrutura cuja
prova é uma simulação (blocos `run:` reais rodados com dublês), porque o caminho real (ex.:
rollback em produção) não dá para exercitar.

Cenários verdes não cobrem o que fica fora do script. Exija, e confira no resumo da trilha do
implementador:

1. **Checagem estática da fiação do YAML**: `if:` exato por passo sensível, ordem dos passos,
   ausência de `always()` no passo irreversível.
2. **Passada de mutação sobre o arquivo real** (cópia mutada + suíte), com todas as mutações
   mortas — `&&`→`||`, `if:` removido ou sem `failure()`, janela de health check reduzida,
   delimitadores de marcador. Mutação sobrevivente ou passada ausente é achado, não nota.
3. **Mortas e sobreviventes relatadas** na trilha. Sem esse relato, a revisão acaba fazendo o papel
   do teste (duas rodadas extras numa fatia real).

Para o rollback em si, `docs/gates/sre.md` ainda exige exercício em staging quando existe.
