<!-- sdd-format-version: 2 -->
# TRD — <Nome da Feature> — Índice

> Status: rascunho | em revisão | aprovado
> Autor: agente `architect`
> PRD relacionado: `specs/<slug>/prd/` (ou `prd.md`, se a spec ainda está no formato legado)
> ADRs relacionados: (link, se houver)

Núcleo pequeno, sempre lido por completo — contexto, stack tecnológica, controle de versão por
fatia e aprovação (`docs/MICRO-CONTEXT.md`, seção 2b). O resto do TRD — arquitetura, contrato,
casos de uso, pilares de engenharia, plano de testes e a decomposição de tarefas — vive nos
arquivos-filho deste diretório, lidos só quando a tarefa realmente pedir — ver "Arquivos deste
TRD" ao final. **Cada seção abaixo mantém o número que tinha no TRD de arquivo único** — uma
referência a "seção 13 do TRD" em qualquer agente/skill continua válida, só mudando de arquivo
(`tasks.md`, neste caso).

## 1. Contexto

Resumo de uma frase do problema (ver PRD) e a abordagem técnica escolhida.

## 2. Stack Tecnológica

Decidida **antes** de qualquer coisa abaixo que dependa dela (nunca implícita dentro de
Ports/Adapters/Modelo de dados). Ver processo de decisão em `.claude/agents/architect.md`.

- **Linguagem/runtime**: <...>
- **Framework principal**: <... ou "nenhum">
- **Persistência**: <... ou "nenhuma">
- **Gerenciador de pacotes**: <...>
- **Proveniência desta decisão**: `<reaproveitada de docs/STACK.md deste projeto / reaproveitada
  do harness global ~/.claude/stack-defaults.md, confirmada com o usuário / decidida nesta sessão
  com o usuário>`

Se esta é a primeira vez que a stack foi decidida neste projeto, `docs/STACK.md` foi
criado/atualizado com o mesmo conteúdo — próximas features reaproveitam a partir de lá.

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

Cada fatia vertical de `tasks.md` (seção 13) é entregue como sua **própria branch/PR**, incremental
sobre a fatia anterior já mergeada em `main` — nunca uma branch/PR única cobrindo todas as fatias
de uma vez (ver `docs/GIT-WORKFLOW.md`). A branch da fatia N só é criada depois que o PR da fatia
N-1 está mergeado.

| Fatia | Branch                                              | PR                            | Status                              |
|-------|--------------------------------------------------------|----------------------------------|------------------------------------------|
| F-1   | `feature/<NNNN-slug>` (ou `feature/<NNNN-slug>/f-1` se houver mais de uma fatia) | <link, preenchido quando existir> | aberto / mergeado |

- Se a fatia é full-stack: dentro da branch dessa fatia, `backend-developer` trabalha em
  `src/`+`tests/`, `frontend-developer` em `frontend/`, ambos na mesma branch — árvores de
  diretório separadas evitam conflito de merge.
- Se houver só uma fatia (feature pequena, não fatiada), a tabela tem uma única linha e a branch
  usa o nome simples `feature/<NNNN-slug>`, sem sufixo de fatia.

## 17. Aprovação

- [ ] Aprovado por: <usuário> em <data>
