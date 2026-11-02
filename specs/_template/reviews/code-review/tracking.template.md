<!-- sdd-format-version: 2 -->
# Code Review — <Nome da Feature> — Achados, Pendências e Log

Três tabelas compactas, append-only — nunca uma linha apagada, só marcada
(`docs/MICRO-CONTEXT.md`, seção 2). Uma linha cujo `Status` já foi resolvido e cuja `Fatia` já foi
mergeada é referência sob demanda, não leitura obrigatória (`docs/AGENT-PREAMBLE.md`, seção
"Artefato de revisão que acumulou rodadas"). Linhas com `Status` aberto continuam leitura
obrigatória todo round, mesmo que de uma fatia anterior.

## Achados (acumulado entre fatias — nunca recriado do zero)

Uma linha por achado, nunca removida — ao corrigir, atualize o `Status` da própria linha em vez
de apagá-la ou duplicá-la.

| # | Fatia | Arquivo:linha | Problema | Sugestão | Severidade | Status |
|---|-------|-----------------|----------|----------|------------|--------|

## Pendências de validação (VALIDAR DEPOIS)

**ID no formato `CR-<AAAA-MM-DD>-<slug-curto>`** (data + slug curto do próprio item — nunca um
contador sequencial simples como `CR-1`/`CR-2`): duas branches de fatia paralelas calculando o
"próximo número" a partir da própria cópia local já geraram colisão real de ID em merge (mesmo
critério de `docs/LESSONS-LEARNED.md`, `docs/gates/licoes.md`). Na rara colisão de duas entradas
com data e slug idênticos, acrescente um sufixo numérico ao segundo (`-2`, `-3`, ...) no momento
do merge.

| ID | Pergunta | Contexto | Status |
|----|----------|----------|--------|
| CR-2026-08-25-criterio-timeout | <pergunta que ficou sem resposta> | <por que essa pergunta importa> | pendente / validado |

## Log de revisões

| Data | Autor | O que mudou | Motivo | Etapas revalidadas |
|------|-------|--------------|--------|-----------------------|
