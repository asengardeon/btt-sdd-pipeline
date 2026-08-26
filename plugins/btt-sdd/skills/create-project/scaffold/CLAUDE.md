# Guia para o Claude Code

Este repositório usa **SDD — Spec-Driven Development**: toda feature nasce de uma especificação
de produto, passa por um desenho técnico revisável, é implementada com TDD (backend e frontend em
paralelo, quando aplicável) e só chega a produção depois de revisão de código, QA, revisão de
segurança e validação de SRE — tudo com agentes dedicados a cada etapa, instalados globalmente
neste computador (por isso funcionam aqui sem nenhuma configuração adicional além desta estrutura
de arquivos).

Se você é uma instância do Claude Code trabalhando neste repo, leia isto antes de fazer qualquer
mudança de código. Para o detalhe de cada arquivo/pasta, veja `docs/FILE-GUIDE.md`. Para o fluxo
completo do pipeline, veja `docs/SDD-WORKFLOW.md`. Para os gates críticos que nenhuma etapa pode
pular, veja `docs/QUALITY-GATES.md`. Para o fluxo de branch/PR, veja `docs/GIT-WORKFLOW.md`. Para
os pilares de engenharia (escalabilidade, resiliência etc.) que o TRD precisa endereçar, veja
`docs/ENGINEERING-PILLARS.md`.

## O pipeline (7 etapas, + 1 etapa condicional)

```
[0] codebase-archaeologist ──▶ docs/BASELINE.md  (SÓ quando falta documentação base — condicional)
   │
   ▼
ideia/pedido
   │
   ▼
[1] product-design    ──▶  PRD  (specs/<slug>/prd.md) — inclui ordem de valor entre histórias
   │
   ▼
[2] architect          ──▶  TRD  (specs/<slug>/trd.md)  [+ ADR se relevante]
                              — inclui contrato Frontend↔Backend e decomposição de tarefas
   │
   ▼
[3] backend-developer   ──▶  código + testes em src/ (ports & adapters) via TDD
    frontend-developer      código + testes em frontend/ via TDD, contra o contrato do TRD
    (em paralelo quando a feature é full-stack, orquestrados por /sdd-implement)
   │
   ▼
[4] code-reviewer       ──▶  Code review (specs/<slug>/code-review.md) — engenheiro sênior:
                              ports & adapters, SOLID, clean code, qualidade dos testes
   │
   ▼
[5] qa-engineer         ──▶  QA report (specs/<slug>/qa-report.md)
   │
   ▼
[6] security-engineer   ──▶  Security review (specs/<slug>/security-review.md) — OWASP, segredos, authn/authz
   │
   ▼
[7] sre                 ──▶  SRE review (specs/<slug>/sre-review.md) — CI/CD, Docker, Terraform
```

Cada etapa só começa com o artefato aprovado da etapa anterior. Nenhuma etapa pula a anterior.

**Quando o TRD tem mais de uma fatia vertical de entrega** (seção "Decomposição de tarefas e
dependências (fatias verticais de entrega)"), as etapas [3] a [7] se repetem **por fatia**, em
loop: cada fatia é sua própria branch/PR, passa por code review/QA/segurança/SRE, e só é mergeada
em `main` antes da fatia seguinte começar. Detalhe completo em `docs/GIT-WORKFLOW.md`.

| Comando            | Agente(s)                                    | Produz                         |
|--------------------|------------------------------------------------|---------------------------------|
| `/create-project`   | (usa `product-design`)                          | um projeto novo, do zero, num diretório separado |
| `/sdd-baseline`     | codebase-archaeologist                          | `docs/BASELINE.md` (condicional) |
| `/sdd-prd`          | product-design                                  | `specs/<slug>/prd.md`          |
| `/sdd-trd`          | architect                                        | `specs/<slug>/trd.md`          |
| `/sdd-implement`    | backend-developer e/ou frontend-developer         | branch + PR + código + testes  |
| `/sdd-code-review`  | code-reviewer                                    | `specs/<slug>/code-review.md`  |
| `/sdd-qa`           | qa-engineer                                      | `specs/<slug>/qa-report.md`    |
| `/sdd-security`     | security-engineer                                | `specs/<slug>/security-review.md` |
| `/sdd-sre`          | sre                                              | `specs/<slug>/sre-review.md`   |
| `/sdd-status`       | (nenhum, utilitário)                             | resumo do estágio da feature |
| `/sdd-amend`        | (nenhum, utilitário)                             | emenda um artefato já aprovado sem reiniciar o pipeline |
| `/sdd-pending`      | (nenhum, utilitário)                             | lista itens "VALIDAR DEPOIS" em aberto |

## Princípios de arquitetura (não negociáveis)

1. **Ports & Adapters (arquitetura hexagonal).** `src/domain` não importa nada de fora.
   `src/application` define casos de uso e *ports* — nunca implementações concretas de
   infraestrutura. `src/adapters` implementa os ports (saída) ou aciona os casos de uso (entrada).
   Quando a feature tem frontend, `frontend/` segue separação análoga (componentes vs. serviços),
   consumindo o backend via o contrato definido no TRD. Detalhe em `docs/ARCHITECTURE.md`.
2. **SOLID** aplicado a ports, casos de uso e adapters — detalhe em `docs/ARCHITECTURE.md`.
3. **Clean Code** — funções pequenas, nomes que revelam intenção, sem código morto.
4. **TDD estrito.** Todo código nasce de um teste que falha primeiro (red-green-refactor).
5. **Cobertura mínima de 80%, por pacote** (`src/` e `frontend/`, quando existir).
6. **Pilares de engenharia** respondidos explicitamente em todo TRD — `docs/ENGINEERING-PILLARS.md`.
7. **Stack tecnológica nunca implícita.** O `architect` decide a stack antes de desenhar qualquer
   outra coisa no TRD: reaproveita `docs/STACK.md` deste projeto se já existir, senão propõe o
   padrão de `~/.claude/stack-defaults.md` (opcional) confirmando com o usuário, senão pergunta
   do zero. Toda decisão nova é gravada em `docs/STACK.md`.

## Onde as coisas vivem

- `specs/` — PRDs, TRDs, QA reports, security reviews e SRE reviews, um diretório por feature.
- `src/` — código de produção de backend em ports & adapters (criado quando a stack for
  decidida no primeiro TRD — não existe ainda neste scaffold).
- `frontend/` — código de produção de frontend, quando alguma feature tiver UI.
- `tests/` — testes de backend espelhando `src/`.
- `infra/`, `.github/workflows/` — infraestrutura e CI/CD (criados pelo `sre` quando a stack e a
  infra forem decididas — não existem ainda neste scaffold).
- `docs/` — arquitetura, workflow SDD, testes, pilares de engenharia, gates críticos, fluxo de
  Git e guia arquivo-a-arquivo.

## Regras de governança (valem para todos os agentes)

Detalhe completo em `docs/QUALITY-GATES.md` — aqui só o resumo:

1. **Nenhuma suposição silenciosa.** Toda ambiguidade vira pergunta ao usuário via
   `AskUserQuestion` — nunca uma escolha implícita do agente. **"VALIDAR DEPOIS"** é sempre uma
   opção quando o usuário não souber responder agora; revise com `/sdd-pending`, resolva com
   `/sdd-amend`.
2. **Nenhuma ação ou pergunta se repete mais de 3 vezes.** Na 3ª tentativa sem sucesso, o agente
   para e escala ao usuário.
3. **Planeje antes de executar, sempre.** `/sdd-implement` e `/sdd-sre` apresentam o plano e pedem
   aprovação explícita antes de agir; em feature full-stack, um único plano combinado antes de
   acionar `backend-developer` e `frontend-developer` em paralelo.
4. **Artefatos aprovados são editados in-place**, nunca recriados do zero — use `/sdd-amend`.
5. **Fluxo de Git = GitHub Flow.** `main` sempre implantável, uma branch por fatia vertical de
   entrega (não por feature inteira), PR obrigatório, merge só após revisão de código, QA,
   segurança e SRE aprovados para aquela fatia. Vale também para mudanças no próprio pipeline
   (agentes, skills, docs, templates) — nunca commite direto em `main`/`master`; crie uma branch
   (`chore/<slug>` quando não há PRD/TRD/fatia envolvidos) e abra PR antes de mergear. Detalhe em
   `docs/GIT-WORKFLOW.md`.
6. Nunca avance uma etapa sem o artefato de entrada da anterior aprovado.
7. Nunca reduza a cobertura de testes abaixo de 80% em qualquer pacote para "economizar tempo".
8. Sempre registre decisões técnicas relevantes como ADR em `docs/adr/`.

## Próximo passo

Este projeto acabou de ser criado por `/create-project` — ainda não tem stack, código, nem
infraestrutura definidos. O primeiro PRD deve estar em `specs/0001-<slug>/prd.md`; aprove-o e
rode `/sdd-trd` para o `architect` desenhar a solução técnica (é aí que a stack é decidida).
