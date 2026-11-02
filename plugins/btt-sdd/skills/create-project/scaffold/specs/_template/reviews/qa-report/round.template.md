<!-- sdd-format-version: 2 -->
# QA Report — <Nome da Feature> — <F-N ou hotfix-<data>>

> PR desta fatia: <link do Pull Request revisado>
> Data: <data>

Um arquivo por rodada — nunca edite o arquivo de uma rodada já aprovada e mergeada; crie um novo
para a próxima rodada (`MICRO-CONTEXT.md` do pipeline, seção 2). Acrescente a linha
correspondente em `INDEX.md` ao criar este arquivo.

## Veredito geral desta rodada

**Aprovado / Reprovado**

## 2. Cobertura de testes

| Métrica            | Resultado | Gate  | Status |
|---------------------|-----------|-------|--------|
| Cobertura de linhas  | __%       | 80%   | ✅/❌ |
| Cobertura de branches| __%       | 80%   | ✅/❌ |

Fonte: `<reaproveitado de specs/<slug>/coverage/<fatia>-<trilha>.md, commit <sha> | re-executado nesta rodada — arquivo estava ausente/desatualizado>`
Comando usado: `<comando de teste com cobertura>`

## 3. Critérios de aceite (PRD) cobertos por esta fatia

Só os critérios da fatia desta rodada (seção "Ordem de valor" do PRD / coluna "Fatia (PRD)" do
TRD) — critérios de fatias futuras ainda não implementadas não entram aqui.

| ID    | Critério                         | Teste automatizado         | Veredito |
|-------|------------------------------------|------------------------------|----------|
| US-1  | <cenário Gherkin resumido>          | `tests/.../test_x.py::...`   | ✅/❌   |

## 4. Regressão

Resultado da suíte completa (não só os testes novos): `<passou/falhou, X testes, Y falhas>`.

### 4b. Build/empacotamento real (se a fatia tem trilha de frontend ou gera artefato próprio)

Resultado do comando de build/empacotamento real de produção (`docs/STACK.md`), reaproveitado de
`specs/<slug>/coverage/<fatia>-<trilha>.md` ou reexecutado nesta rodada — `TESTING.md` do
pipeline, seção "Build/empacotamento real como parte da suíte completa". Lint/tipo/teste unitário
sozinhos não contam como suíte completa quando este campo se aplica. "Não aplicável" se a fatia é
backend-only sem etapa de empacotamento própria além dos testes.

## 5. Aderência a ports & adapters

Testes de domínio/aplicação rodam isolados de infraestrutura real? Sim/Não — se não, detalhe
onde a fronteira foi violada.

Achados desta rodada entram direto na tabela de Achados de `tracking.md` — "sem achados"
explícito se nenhuma área acusou nada nesta rodada.
