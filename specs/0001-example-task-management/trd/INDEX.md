<!-- sdd-format-version: 2 -->
# TRD — Gestão simples de tarefas (exemplo do pipeline SDD) — Índice

> Status: aprovado
> Autor: agente `architect`
> PRD relacionado: `specs/0001-example-task-management/prd/`
> ADRs relacionados: nenhum (design direto, sem trade-off significativo a registrar)

Migrado do formato legado (arquivo único `trd.md`) para o split por tópico em 2026-11-02
(`docs/MICRO-CONTEXT.md`, seção 2b). O arquivo legado é mantido como referência histórica — ver
banner no topo dele.

## 1. Contexto

Implementar criar/listar/concluir tarefas como exemplo de referência do pipeline, usando Python
como stack ilustrativa, respeitando ports & adapters, SOLID, TDD e o gate de cobertura de 80%.

## 2. Stack Tecnológica

- **Linguagem/runtime**: Python 3.11+
- **Framework principal**: nenhum — só stdlib (`argparse` para a CLI).
- **Persistência**: nenhuma — repositório em memória (fora de escopo por PRD).
- **Gerenciador de pacotes**: `pip` + `pyproject.toml`
- **Proveniência desta decisão**: decidida nesta sessão com o usuário (primeira feature deste
  repositório — não havia `docs/STACK.md` nem `~/.claude/stack-defaults.md` ainda). `docs/STACK.md`
  foi criado com este mesmo conteúdo a partir desta decisão.

## Arquivos deste TRD

| Arquivo | Seções | Conteúdo | Leia quando |
|---|---|---|---|
| `architecture.md` | 3-5, 7, 9 | Visão de arquitetura, modelo de domínio, ports, adapters, modelo de dados | Ao implementar (`backend-developer`) ou revisar ports & adapters (`code-reviewer`) |
| `contract.md` | 8 | Contrato Frontend↔Backend (API) | `backend-developer`/`frontend-developer` em paralelo — leem só este arquivo para desenvolver contra o contrato, sem esperar a implementação real um do outro |
| `use-cases.md` | 6 | Casos de uso (critério de aceite do PRD → caso de uso → ports) | Ao planejar implementação, ou em `/sdd-gap-report` |
| `quality.md` | 10, 12 | Pilares de engenharia de software; riscos e trade-offs | `code-reviewer`/`security-engineer`/`sre`, e qualquer rodada que precise justificar um desvio |
| `test-plan.md` | 11 | Plano de testes (alto nível) | Ao planejar a suíte (`backend-developer`/`frontend-developer`), ou QA validando cobertura |
| `tasks.md` | 13 | Decomposição de tarefas e dependências (fatias verticais), incl. janelas de quebra de contrato | `/sdd-implement`, `/sdd-status`, `/sdd-pending` — a tabela mais lida de toda a spec |
| `tracking.md` | 15-16 | Pendências VALIDAR DEPOIS + log de revisões | Ao rodar `/sdd-pending`/`/sdd-amend`, ou investigar o histórico de uma mudança |

## 14. Controle de versão (GitHub Flow, por fatia)

- Branch: `feature/0001-example-task-management`
- PR: não aplicável — esta feature de exemplo foi commitada diretamente em `main` no commit
  inicial do repositório, antes da política de GitHub Flow existir (ver "Exceção histórica" em
  `docs/GIT-WORKFLOW.md`). Toda feature a partir de agora segue o fluxo de branch/PR normalmente.

## 17. Aprovação

- [x] Aprovado por: asengardeons@hotmail.com em 2026-08-24
