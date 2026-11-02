<!-- sdd-format-version: 2 -->
# TRD — Gestão simples de tarefas (exemplo do pipeline SDD) — Pendências e Log

> Seções 15-16 do TRD (`INDEX.md` tem o núcleo e a navegação para os demais arquivos).

## 15. Pendências de validação (VALIDAR DEPOIS)

Nenhuma.

| ID     | Pergunta                          | Contexto                              | Status               |
|--------|------------------------------------|-----------------------------------------|-----------------------|

## 16. Log de revisões

| Data       | Autor                 | O que mudou                                                              | Motivo                                                                 | Etapas revalidadas |
|------------|------------------------|----------------------------------------------------------------------------|----------------------------------------------------------------------------|------------------------|
| 2026-08-24 | sessão Claude Code      | Adicionadas as seções "Controle de versão", "Pendências de validação" e este log; adicionada referência a indicadores técnicos herdados do PRD na seção 8; renumeradas as seções seguintes | Alinhamento com o template vigente na época após reforço de governança do pipeline | Nenhuma — mudança só de estrutura do documento, sem alterar arquitetura, ports ou casos de uso |
| 2026-08-24 | sessão Claude Code      | Seção 8 "Requisitos não funcionais" virou "Pilares de engenharia de software", com cada pilar (performance, escalabilidade, resiliência, disponibilidade, observabilidade, manutenibilidade) respondido explicitamente | Adição do agente `security-engineer` e dos pilares de engenharia (`docs/ENGINEERING-PILLARS.md`) ao pipeline | Nenhuma — respostas são "não se aplica" com justificativa, mesma conclusão técnica de antes, só explicitada |
| 2026-08-24 | sessão Claude Code      | Adicionadas as seções "Contrato Frontend↔Backend" (não aplicável) e "Decomposição de tarefas e dependências"; renumeradas as seções seguintes; referências a `senior-developer` trocadas por `backend-developer` | Split do agente de desenvolvimento em backend/frontend, contrato de API no TRD, e mapeamento de dependências entre tarefas | Nenhuma — mudança só de estrutura/nomenclatura, sem alterar arquitetura, ports ou casos de uso |
| 2026-08-24 | sessão Claude Code      | Adicionada a seção "Stack Tecnológica" (Python 3.11+, stdlib only, sem persistência real), com proveniência registrada; renumeradas as seções seguintes; criado `docs/STACK.md` deste repositório com o mesmo conteúdo | Fechar a lacuna de "onde a stack é decidida" — antes era implícita dentro de Ports/Adapters, agora é um passo e uma seção explícitos (`.claude/agents/architect.md`) | Nenhuma — a stack já era essa na prática, só ficou explícita e centralizada |
| 2026-11-02 | sessão Claude Code (`/sdd-migrate`) | Migrado do formato legado (arquivo único) para o split por tópico; tabela de decomposição (seção 13) preservada na forma original, sem inventar colunas "Fatia (PRD)"/"Status"/"Validação na fatia" que não existiam na origem | `docs/MICRO-CONTEXT.md`, seção 3 — `trd` v1 → v2 | Nenhuma — arquitetura, ports e casos de uso originais não mudam |
