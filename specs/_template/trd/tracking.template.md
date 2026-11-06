<!-- sdd-format-version: 3 -->
# TRD — <Nome da Feature> — Pendências e Log

> Seções 15-16 do TRD (`INDEX.md` tem o núcleo e a navegação para os demais arquivos). Duas
> tabelas compactas, append-only — nunca uma linha apagada, só marcada (`docs/MICRO-CONTEXT.md`,
> seção 2b).

## 15. Pendências de validação (VALIDAR DEPOIS)

Duas tabelas, pelo dono da decisão (`docs/gates/governanca.md`, "Pendência de validação: produto
ou engenharia"). Item que depende dos dois fica na tabela de quem tem a decisão final, com a
dependência citada no Contexto. Mover um item entre tabelas mantém o ID.

### Decisões de produto

| ID     | Pergunta                          | Contexto                              | Status              |
|--------|--------------------------------------|-------------------------------------------|------------------------|
| TRD-1  | <pergunta que ficou sem resposta>     | <por que essa pergunta importa>            | pendente / validado |

### Decisões de engenharia

| ID     | Pergunta                          | Contexto                              | Status              |
|--------|--------------------------------------|-------------------------------------------|------------------------|

## 15b. Premissas assumidas

Lacuna do PRD com padrão razoável e reversão barata: o `architect` segue com o padrão e registra
aqui (`architect/readiness-do-prd.md`). A tarefa que usa a premissa a marca para validação.

| ID    | Padrão assumido | Impacto se estiver errada | Requisito de origem | Status              |
|-------|-------------------|-------------------------------|------------------------|---------------------|
| PRM-1 | <padrão escolhido> | <o que muda se for outro>       | <história/critério do PRD> | assumida / validada |

## 16. Log de revisões

| Data | Autor | O que mudou | Motivo | Etapas revalidadas |
|------|-------|--------------|--------|-----------------------|
