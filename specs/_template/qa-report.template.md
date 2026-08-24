# QA Report — <Nome da Feature>

> Autor: agente `qa-engineer`
> PRD: `specs/<slug>/prd.md` | TRD: `specs/<slug>/trd.md`
> Data:

## 1. Veredito geral

**Aprovado / Reprovado**

## 2. Cobertura de testes

| Métrica            | Resultado | Gate  | Status |
|---------------------|-----------|-------|--------|
| Cobertura de linhas  | __%       | 80%   | ✅/❌ |
| Cobertura de branches| __%       | 80%   | ✅/❌ |

Comando usado: `<comando de teste com cobertura>`

## 3. Critérios de aceite (PRD)

| ID    | Critério                         | Teste automatizado         | Veredito |
|-------|------------------------------------|------------------------------|----------|
| US-1  | <cenário Gherkin resumido>          | `tests/.../test_x.py::...`   | ✅/❌   |

## 4. Regressão

Resultado da suíte completa (não só os testes novos): `<passou/falhou, X testes, Y falhas>`.

## 5. Aderência a ports & adapters

Testes de domínio/aplicação rodam isolados de infraestrutura real? Sim/Não — se não, detalhe
onde a fronteira foi violada.

## 6. Achados (se reprovado)

| # | Arquivo/cenário | Esperado | Observado | Severidade |
|---|-------------------|----------|-----------|------------|

## 7. Próximo passo

`/sdd-sre` (se aprovado) ou `/sdd-implement` (se reprovado, com os achados acima).
