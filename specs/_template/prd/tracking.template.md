<!-- sdd-format-version: 3 -->
# PRD — <Nome da Feature> — Pendências e Log

> Seções 11-12 do PRD (`INDEX.md` tem o núcleo e a navegação para os demais arquivos). Duas
> tabelas compactas, append-only — nunca uma linha apagada, só marcada (`docs/MICRO-CONTEXT.md`,
> seção 2b).

## 11. Pendências de validação (VALIDAR DEPOIS)

Toda ambiguidade que o usuário não soube/quis responder agora, registrada aqui em vez de virar
suposição silenciosa. Resolvida via `/sdd-amend` quando o usuário pedir a revisão.

Duas tabelas, pelo dono da decisão (`docs/gates/governanca.md`, "Pendência de validação: produto
ou engenharia"). Item que depende dos dois fica na tabela de quem tem a decisão final, com a
dependência citada no Contexto. Mover um item entre tabelas mantém o ID.

### Decisões de produto

| ID     | Pergunta                          | Contexto                              | Status              |
|--------|--------------------------------------|-------------------------------------------|------------------------|
| PRD-1  | <pergunta que ficou sem resposta>     | <por que essa pergunta importa>            | pendente / validado |

### Decisões de engenharia

| ID     | Pergunta                          | Contexto                              | Status              |
|--------|--------------------------------------|-------------------------------------------|------------------------|

## 12. Log de revisões

Preenchido pelo `/sdd-amend` a cada mudança neste PRD depois de aprovado — nunca recrie o
documento do zero para registrar uma mudança.

| Data | Autor | O que mudou | Motivo | Etapas revalidadas |
|------|-------|--------------|--------|-----------------------|
