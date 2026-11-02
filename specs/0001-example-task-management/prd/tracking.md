<!-- sdd-format-version: 2 -->
# PRD — Gestão simples de tarefas (exemplo do pipeline SDD) — Pendências e Log

> Seções 11-12 do PRD (`INDEX.md` tem o núcleo e a navegação para os demais arquivos).

## 11. Pendências de validação (VALIDAR DEPOIS)

Nenhuma pendência registrada — o escopo desta feature de exemplo foi fechado deliberadamente
pequeno e sem ambiguidade residual, exatamente para servir de referência do pipeline sem itens em
aberto.

| ID     | Pergunta                          | Contexto                              | Status               |
|--------|------------------------------------|-----------------------------------------|-----------------------|

## 12. Log de revisões

| Data       | Autor                 | O que mudou                                                              | Motivo                                                                 | Etapas revalidadas |
|------------|------------------------|----------------------------------------------------------------------------|----------------------------------------------------------------------------|------------------------|
| 2026-08-24 | sessão Claude Code      | Adicionadas as seções "Indicadores técnicos a observar", "Pendências de validação" e este log; removida a antiga seção "Suposições" (a política mudou: nenhuma suposição silenciosa, só pergunta ou VALIDAR DEPOIS) | Alinhamento com o template vigente na época após reforço de governança do pipeline | Nenhuma — mudança só de estrutura do documento, sem alterar requisito ou critério de aceite |
| 2026-11-02 | sessão Claude Code (`/sdd-migrate`) | Migrado do formato legado (arquivo único) para o split por tópico | `docs/MICRO-CONTEXT.md`, seção 3 — `prd` v1 → v2 | Nenhuma — requisitos e critérios de aceite originais não mudam |
