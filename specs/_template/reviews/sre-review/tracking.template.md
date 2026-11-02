<!-- sdd-format-version: 2 -->
# SRE Review — <Nome da Feature> — Pendências, VALIDAR DEPOIS e Log

Três tabelas compactas, append-only — nunca uma linha apagada, só marcada
(`docs/MICRO-CONTEXT.md`, seção 2). Uma linha cujo `Status` já foi resolvido e cuja `Fatia` já foi
mergeada é referência sob demanda, não leitura obrigatória (`docs/AGENT-PREAMBLE.md`, seção
"Artefato de revisão que acumulou rodadas"). Linhas com `Status` aberto continuam leitura
obrigatória todo round, mesmo que de uma fatia anterior.

## Pendências (acumulado entre fatias — nunca recriado do zero)

Uma linha por pendência, nunca removida — ao resolver, atualize o `Status` da própria linha em
vez de apagá-la ou duplicá-la.

| # | Fatia | Item | Responsável | Bloqueia release? | Status |
|---|-------|------|--------------|---------------------|--------|

## Pendências de validação (VALIDAR DEPOIS)

| ID    | Pergunta                          | Contexto                              | Status              |
|-------|--------------------------------------|-------------------------------------------|------------------------|
| SRE-1 | <pergunta que ficou sem resposta>     | <por que essa pergunta importa>            | pendente / validado |

## Log de revisões

| Data | Autor | O que mudou | Motivo | Etapas revalidadas |
|------|-------|--------------|--------|-----------------------|
