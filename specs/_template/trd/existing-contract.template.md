<!-- sdd-format-version: 2 -->
# TRD — <Nome da Feature> — Contrato existente por alvo

> Condicional: só em spec de migração ou paridade (`architect/ficha-contrato-existente.md`). Em
> outra spec, não crie este arquivo. Uma ficha por alvo do PRD. Cada linha é `[medido]` (com
> caminho), `[inferido]` ou `[não medido]`; todo `[não medido]` traz o teste barato que o resolve.

## Alvo: <tela / endpoint / comando / job>

| Campo | Conteúdo | Evidência |
|---|---|---|
| Interface de entrada e saída | <endpoints, verbos, formatos> | medido: <caminho> / inferido / não medido: <teste> |
| Autorização | <o que a interface exige; bate com o cliente atual?> | |
| Regras de negócio | <validações, invariantes, valores fixos> | |
| Efeitos colaterais | <leituras que gravam, eventos, integrações> | |
| Cliente atual | <o que chama, destino, rotas e parâmetros extras> | |
| Testes existentes | <quais, ou "nenhum"> | |

Alvo sem teste: a primeira tarefa dele em `tasks.md` é um teste de caracterização.
