# Workflow SDD (Spec-Driven Development)

Este documento explica o funcionamento completo do pipeline de 5 etapas deste repositório: por
que ele existe, o que cada etapa exige/produz, e como as peças (agentes, skills, templates) se
encaixam.

## Por que Spec-Driven Development

O objetivo é que nenhuma decisão importante seja tomada implicitamente dentro do código. Cada
decisão de **o que construir** (produto), **como construir** (arquitetura) e **está correto?**
(qualidade) fica registrada em um artefato revisável, na ordem certa, antes do código ser escrito
ou aceito. Isso troca "descobrir depois que o requisito era outro" por "alinhar antes de
implementar", e troca "confiar que o dev testou" por "QA valida objetivamente contra critérios
escritos".

## As 5 etapas

### 1. Produto & Design → PRD

- **Agente**: `.claude/agents/product-design.md`
- **Skill**: `/sdd-prd`
- **Entrada**: um pedido de feature, em linguagem natural.
- **Saída**: `specs/<slug>/prd.md` — o quê e por quê, nunca o como técnico. Critérios de aceite
  em Gherkin, testáveis por um terceiro sem contexto adicional.
- **Gate de saída**: aprovação explícita do usuário.

### 2. Arquitetura → TRD

- **Agente**: `.claude/agents/architect.md`
- **Skill**: `/sdd-trd`
- **Entrada**: PRD aprovado.
- **Saída**: `specs/<slug>/trd.md` — modelo de domínio, ports, casos de uso mapeados aos
  critérios de aceite, adapters necessários, plano de testes de alto nível. ADRs em
  `docs/adr/` para decisões técnicas significativas.
- **Gate de saída**: aprovação explícita do usuário.

### 3. Desenvolvimento → Código + Testes

- **Agente**: `.claude/agents/senior-developer.md`
- **Skill**: `/sdd-implement`
- **Entrada**: TRD aprovado.
- **Saída**: código em `src/` (ports & adapters) e testes em `tests/`, produzidos via TDD
  (red-green-refactor), com cobertura ≥ 80% nas linhas/branches novas ou alteradas.
- **Gate de saída**: suíte de testes passando, lint limpo, cobertura reportada.

### 4. QA → Validação objetiva

- **Agente**: `.claude/agents/qa-engineer.md`
- **Skill**: `/sdd-qa`
- **Entrada**: implementação + PRD + TRD.
- **Saída**: `specs/<slug>/qa-report.md` — veredito por critério de aceite, cobertura vs. gate de
  80%, achados de regressão e de violação de fronteira arquitetural.
- **Gate de saída**: veredito geral aprovado (senão volta para a etapa 3).

### 5. SRE → CI/CD e infraestrutura

- **Agente**: `.claude/agents/sre.md`
- **Skill**: `/sdd-sre`
- **Entrada**: QA aprovado.
- **Saída**: `specs/<slug>/sre-review.md` — checklist de CI, CD, Docker, Terraform e
  observabilidade, com veredito.
- **Gate de saída**: aprovado (ou aprovado com ressalvas registradas).

## Utilitário: `/sdd-status`

Não aciona agente — apenas lê `specs/` e reporta em que etapa cada feature está e qual o próximo
comando a rodar. Use a qualquer momento para se orientar.

## Regra de ouro

Cada etapa **exige o artefato aprovado** da etapa anterior como pré-condição. Um agente que não
encontra o artefato de entrada não improvisa um — ele para e diz ao usuário qual comando rodar
antes. Isso é o que torna o pipeline confiável: pular etapa nunca é "mais rápido", é retrabalho
disfarçado.

## Ciclo de feedback

Se o QA reprova, a feature volta para `/sdd-implement` com achados específicos. Se o SRE reprova
(ou aprova com ressalvas bloqueantes), os itens voltam para quem for responsável — pode ser o
`senior-developer` (ex.: falta observabilidade no código) ou ajuste direto do próprio `sre` em
`infra/`. O PRD e o TRD só são reabertos se a causa raiz for de requisito ou de design — nesse
caso, trate como uma iteração normal: edite o artefato existente, não crie um novo do zero.

## Exemplo completo

`specs/0001-example-task-management/` contém um PRD, TRD, QA report e SRE review reais,
correspondentes ao código de exemplo em `src/` e `tests/`. Use como referência de nível de
detalhe esperado em cada artefato.
