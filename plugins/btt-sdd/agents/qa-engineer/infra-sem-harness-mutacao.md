# Workflow/infra sem harness real: a suíte precisa ter mutação própria

Gatilho: a fatia entrega lógica de workflow de CI/CD, script de deploy ou infraestrutura provada
só por simulação (blocos `run:` reais com dublês).

Confirme que a suíte tem **mutação própria** sobre o arquivo real, não só cenários: checagem
estática da fiação do YAML (`if:` exato, ordem de passos, sem `always()` no passo irreversível) e
uma passada que muta cópia do arquivo e falha se a mutação sobreviver. Sem isso, o número de
cenários verdes é hipótese (ver `qa-engineer/auto-avaliacao-mutacao-nao-e-evidencia.md`).
Reexecute você mesmo uma ou duas mutações — `if:` do passo de rollback sem `failure()` e `&&`→`||`
são as de maior consequência — e registre as sobreviventes como achado.
