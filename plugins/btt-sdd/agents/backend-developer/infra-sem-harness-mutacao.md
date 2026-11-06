# Workflow/infra sem harness real: cenários verdes não bastam

Gatilho: a trilha entrega lógica de workflow de CI/CD, script de deploy ou infraestrutura que não
dá para exercitar de verdade (ex.: rollback automático de um `cd.yml`), e a prova é uma simulação —
blocos `run:` reais extraídos e rodados com dublês (`curl`, `jq`, CLI de nuvem).

"N cenários verdes" prova pouco sobre a lógica que fica **fora** do script: o `if:` do passo, a
ordem dos passos, permissões. Antes de pedir revisão, faça as três coisas:

1. **Checagem estática da fiação do YAML**, em teste: `if:` exato de cada passo sensível (ex.: o
   passo de rollback exige `failure()`; sem isso ele nunca roda e a suíte segue verde), ordem dos
   passos, e ausência de `always()` no passo irreversível.
2. **Passada de mutação automática sobre o arquivo real**: copie o workflow/script, aplique cada
   mutação (troca de `&&` por `||`, remoção ou troca do `if:`, janela de health check reduzida,
   delimitador de marcador alterado), rode a suíte contra a cópia mutada e **falhe se a mutação
   sobreviver**. Cada mutação sobrevivente vira cenário ou asserção nova.
3. **Relate no resumo da trilha** as mutações mortas e as sobreviventes (com a asserção que matou
   cada uma, arquivo:linha — ver `backend-developer/evidencia-direta-nao-suposicao.md`).
