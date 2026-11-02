<!-- sdd-format-version: 2 -->
# UX Review — <Nome da Feature> — Achados, Pendências e Log

Três tabelas compactas, append-only — nunca uma linha apagada, só marcada (`MICRO-CONTEXT.md` do
pipeline, seção 2). Uma linha cujo `Status` já foi resolvido e cuja `Fatia` já foi mergeada é
referência sob demanda, não leitura obrigatória (`AGENT-PREAMBLE.md` do pipeline, seção
"Artefato de revisão que acumulou rodadas"). Linhas com `Status` aberto continuam leitura
obrigatória todo round, mesmo que de uma fatia anterior.

## Achados (acumulado entre fatias — nunca recriado do zero)

Uma linha por achado, nunca removida — ao corrigir, atualize o `Status` da própria linha em vez
de apagá-la ou duplicá-la.

| # | Fatia | Arquivo/componente | Esperado | Observado | Severidade | Status |
|---|-------|----------------------|----------|-----------|------------|--------|

## Pendências de validação (VALIDAR DEPOIS)

Ambiguidade de design não coberta pelo PRD/TRD/`docs/DESIGN-SYSTEM.md` vira pergunta ao usuário;
se ele não souber responder agora, registre aqui em vez de decidir por conta própria. **ID no
formato `UX-<AAAA-MM-DD>-<slug-curto>`** (data + slug curto do próprio item — nunca um contador
sequencial simples) — mesmo critério de `gates/licoes.md` do pipeline/`docs/LESSONS-LEARNED.md`
sobre colisão de ID entre branches paralelas.

| ID                          | Pergunta                          | Contexto                    | Status              |
|------------------------------|--------------------------------------|-----------------------------------|------------------------|
| UX-2026-08-25-cor-de-alerta   | <pergunta que ficou sem resposta>     | <por que essa pergunta importa>    | pendente / validado |

## Log de revisões

| Data | Autor | O que mudou | Motivo | Etapas revalidadas |
|------|-------|--------------|--------|-----------------------|
