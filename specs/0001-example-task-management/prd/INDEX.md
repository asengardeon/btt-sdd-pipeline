<!-- sdd-format-version: 2 -->
# PRD — Gestão simples de tarefas (exemplo do pipeline SDD) — Índice

> Status: aprovado
> Autor: agente `product-design`
> Relacionado: nenhum (primeira feature do repositório)

Migrado do formato legado (arquivo único `prd.md`) para o split por tópico em 2026-11-02
(`docs/MICRO-CONTEXT.md`, seção 2b). O arquivo legado é mantido como referência histórica — ver
banner no topo dele.

## 1. Visão geral

Uma feature mínima de gestão de tarefas — criar, listar e concluir tarefas — usada como exemplo
de referência do pipeline SDD deste repositório, ponta a ponta.

## 2. Problema

Este repositório é um template. Sem um exemplo real de código, os agentes e os templates ficam
abstratos demais para servir de referência de "nível de detalhe esperado". Uma feature pequena,
mas completa, resolve isso.

## 3. Usuários / Personas

Desenvolvedor(a) usando o repositório via linha de comando para gerenciar uma lista de tarefas
pessoal simples.

## 4. Objetivos

- Permitir criar uma tarefa com um título.
- Permitir listar todas as tarefas e seu status (pendente/concluída).
- Permitir marcar uma tarefa como concluída.

## 5. Fora de escopo

- Persistência em disco/banco de dados real (o exemplo usa um repositório em memória).
- Edição ou remoção de tarefas.
- Autenticação/múltiplos usuários.
- Interface gráfica ou API HTTP (o exemplo expõe apenas uma CLI).

## 8. Métricas de sucesso

N/A — feature de exemplo, não vai a produção real. O "sucesso" aqui é servir de referência clara
para o pipeline SDD.

## 9. Indicadores técnicos a observar

- **Volumetria**: trivial — dataset em memória, escopo de uso pessoal/demonstração, sem
  expectativa de crescimento (fora de escopo persistência real, ver seção 5).
- **Segurança**: nenhum indicador relevante — não há dado sensível/pessoal, autenticação ou
  superfície de ataque nova (CLI local, sem rede).
- **Legal/compliance**: nenhum indicador relevante — não há dado pessoal armazenado, retenção ou
  contrato com terceiro envolvido.

## Arquivos deste PRD

| Arquivo | Seções | Conteúdo | Leia quando |
|---|---|---|---|
| `user-stories.md` | 6-7 | Histórias de usuário, critérios de aceite (gherkin), wireframes/protótipos de tela | Sempre, antes de qualquer decisão de design/implementação — é o contrato de comportamento verificável pelo QA |
| `value-order.md` | 10 | Ordem de valor / dependências entre histórias (fatias verticais de entrega) | Ao decompor em TRD (`architect`) ou escolher a próxima fatia (`/sdd-implement`) |
| `tracking.md` | 11-12 | Pendências VALIDAR DEPOIS + log de revisões | Ao rodar `/sdd-pending`/`/sdd-amend`, ou investigar o histórico de uma mudança |

## 13. Aprovação

- [x] Aprovado por: asengardeons@hotmail.com em 2026-08-24
