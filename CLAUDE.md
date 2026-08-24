# projeto-base-ia — guia para o Claude Code

Este repositório é um **template de desenvolvimento orientado a especificação (SDD — Spec-Driven
Development)**. Ele existe para que qualquer feature nasça de uma especificação de produto,
passe por um desenho técnico revisável, seja implementada com TDD e só chegue a produção depois
de QA e validação de SRE — tudo com agentes dedicados a cada etapa.

Se você é uma instância do Claude Code trabalhando neste repo, leia isto antes de fazer qualquer
mudança de código. Para o detalhe de cada arquivo/pasta, veja `docs/FILE-GUIDE.md`. Para o fluxo
completo do pipeline, veja `docs/SDD-WORKFLOW.md`.

## O pipeline (5 etapas, 5 agentes)

```
ideia/pedido
   │
   ▼
[1] product-design  ──▶  PRD  (specs/<slug>/prd.md)
   │
   ▼
[2] architect        ──▶  TRD  (specs/<slug>/trd.md)  [+ ADR se relevante]
   │
   ▼
[3] senior-developer  ──▶  código + testes (src/, tests/) via TDD
   │
   ▼
[4] qa-engineer       ──▶  QA report (specs/<slug>/qa-report.md)
   │
   ▼
[5] sre               ──▶  SRE review (specs/<slug>/sre-review.md) — CI/CD, Docker, Terraform
```

Cada etapa só começa com o artefato aprovado da etapa anterior. Nenhuma etapa pula a anterior:
o dev sênior não implementa sem TRD aprovado, o QA não assina sem os testes rodando, o SRE não
aprova pipeline/infra sem o QA verde.

Cada agente vive em `.claude/agents/<nome>.md` e é acionado por uma skill em
`.claude/skills/sdd-*`. Use os comandos:

| Comando            | Agente             | Produz                         |
|--------------------|--------------------|---------------------------------|
| `/sdd-prd`          | product-design     | `specs/<slug>/prd.md`          |
| `/sdd-trd`          | architect          | `specs/<slug>/trd.md`          |
| `/sdd-implement`    | senior-developer   | código + testes                |
| `/sdd-qa`           | qa-engineer        | `specs/<slug>/qa-report.md`    |
| `/sdd-sre`          | sre                | `specs/<slug>/sre-review.md`   |
| `/sdd-status`       | (nenhum, utilitário) | resumo do estágio da feature |

Veja um exemplo completo já rodado em `specs/0001-example-task-management/`.

## Princípios de arquitetura (não negociáveis)

1. **Ports & Adapters (arquitetura hexagonal).** `src/domain` não importa nada de fora. `src/application`
   define casos de uso e *ports* (interfaces) — nunca implementações concretas de infraestrutura.
   `src/adapters` implementa os ports (saída: banco, filas, APIs externas) ou aciona os casos de uso
   (entrada: HTTP, CLI, eventos). Dependências sempre apontam para dentro (regra da dependência).
   Detalhe completo em `docs/ARCHITECTURE.md`.

2. **SOLID.** Toda classe/módulo novo deve justificar sua responsabilidade única (S). Extensão de
   comportamento se dá por composição/novos adapters, não por `if/else` crescente (O). Implementações
   de um port são substituíveis entre si sem quebrar o caso de uso (L). Interfaces de port são
   pequenas e específicas por caso de uso, não um "God interface" (I). Casos de uso dependem de
   abstrações (ports), nunca de classes concretas de adapter (D).

3. **Clean Code.** Funções pequenas, nomes que dizem o que a coisa é, sem comentários explicando
   o óbvio (comentário só quando explica um *porquê* não óbvio). Sem código morto, sem flags de
   feature esquecidas, sem abstração especulativa para "o futuro".

4. **TDD estrito.** Todo código de produção nasce de um teste que falha primeiro (red), o mínimo
   de código para passar (green), depois refatoração (refactor) mantendo os testes verdes. O
   agente `senior-developer` segue esse ciclo — nunca escreve implementação sem teste antes.

5. **Cobertura mínima de 80%.** Aplicado por CI (`.github/workflows/ci.yml`) e verificado pelo
   agente `qa-engineer` antes de qualquer aprovação. Cobertura abaixo de 80% bloqueia o pipeline.
   Detalhe em `docs/TESTING.md`.

## Onde as coisas vivem

- `specs/` — PRDs, TRDs, test plans, QA reports e SRE reviews, um diretório por feature.
- `src/domain`, `src/application`, `src/adapters` — código de produção em ports & adapters.
- `tests/unit`, `tests/integration`, `tests/e2e` — testes espelhando a arquitetura.
- `infra/docker`, `infra/terraform` — containerização e infraestrutura como código.
- `.github/workflows` — pipelines de CI (lint + testes + gate de cobertura) e CD (deploy via Terraform).
- `docs/` — explicação de arquitetura, workflow SDD, política de testes e guia arquivo-a-arquivo.

## Nota sobre a stack

Este template é **agnóstico de linguagem** na estrutura, nos agentes e nas skills — os princípios
(ports & adapters, SOLID, TDD, cobertura 80%) valem para qualquer stack. O diretório `src/` traz
uma **feature de exemplo em Python** (`specs/0001-example-task-management/`) só para ilustrar o
fluxo ponta a ponta com código real e testes rodando. Ao adotar outra linguagem, troque o
conteúdo de `src/`/`tests/`, o `Dockerfile` e o job de testes do `ci.yml` — a estrutura de pastas
e o pipeline SDD continuam os mesmos.

## Regras de trabalho para os agentes

- Nunca avance uma etapa sem o artefato de entrada da etapa anterior existir e estar aprovado
  pelo usuário (não apenas gerado).
- Nunca escreva código de produção fora de `src/` seguindo a separação domain/application/adapters.
- Nunca reduza a cobertura de testes abaixo de 80% para "economizar tempo" — se um trecho é
  genuinamente difícil de testar, isso é um sinal de design a ser resolvido pelo `architect`, não
  ignorado.
- Sempre registre decisões técnicas relevantes (troca de padrão, escolha de tecnologia, trade-off
  de arquitetura) como ADR em `docs/adr/`, usando `docs/adr/0001-record-architecture-decisions.md`
  como modelo.
