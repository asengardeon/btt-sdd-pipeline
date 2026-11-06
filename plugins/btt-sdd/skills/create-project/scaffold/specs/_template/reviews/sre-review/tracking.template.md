<!-- sdd-format-version: 3 -->
# SRE Review — <Nome da Feature> — Pendências, VALIDAR DEPOIS e Log

Três tabelas compactas, append-only — nunca uma linha apagada, só marcada (`MICRO-CONTEXT.md` do
pipeline, seção 2). Uma linha cujo `Status` já foi resolvido e cuja `Fatia` já foi mergeada é
referência sob demanda, não leitura obrigatória (`AGENT-PREAMBLE.md` do pipeline, seção
"Artefato de revisão que acumulou rodadas"). Linhas com `Status` aberto continuam leitura
obrigatória todo round, mesmo que de uma fatia anterior.

## Pendências (acumulado entre fatias — nunca recriado do zero)

Uma linha por pendência, nunca removida — ao resolver, atualize o `Status` da própria linha em
vez de apagá-la ou duplicá-la.

| # | Fatia | Item | Responsável | Bloqueia release? | Status |
|---|-------|------|--------------|---------------------|--------|

## Pendências de validação (VALIDAR DEPOIS)

Duas tabelas, pelo dono da decisão (`gates/governanca.md` do pipeline, "Pendência de
validação: produto ou engenharia"). Item que depende dos dois fica na tabela de quem tem a
decisão final, com a dependência citada no Contexto. Mover um item entre tabelas mantém o ID.

### Decisões de produto

| ID    | Pergunta                          | Contexto                              | Status              |
|-------|--------------------------------------|-------------------------------------------|------------------------|
| SRE-1 | <pergunta que ficou sem resposta>     | <por que essa pergunta importa>            | pendente / validado |

### Decisões de engenharia

| ID    | Pergunta                          | Contexto                              | Status              |
|-------|--------------------------------------|-------------------------------------------|------------------------|

## Log de revisões

| Data | Autor | O que mudou | Motivo | Etapas revalidadas |
|------|-------|--------------|--------|-----------------------|
