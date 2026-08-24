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
- **Plano antes de executar**: o agente quebra o TRD em incrementos e pede aprovação explícita do
  usuário *antes* de escrever qualquer código (ver `docs/QUALITY-GATES.md`) — só depois disso cria
  a branch `feature/<NNNN-slug>` (GitHub Flow, `docs/GIT-WORKFLOW.md`) e abre o PR.
- **Saída**: branch + PR + código em `src/` (ports & adapters) e testes em `tests/`, produzidos
  via TDD (red-green-refactor), com cobertura ≥ 80% nas linhas/branches novas ou alteradas.
- **Gate de saída**: plano aprovado, suíte de testes passando, lint limpo, cobertura reportada,
  PR aberto.

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
- **Plano antes de executar**: qualquer alteração real de infraestrutura (`terraform apply`) é
  apresentada como plano e só executada após aprovação explícita do usuário.
- **Saída**: `specs/<slug>/sre-review.md` — checklist de CI, CD, Docker, Terraform,
  observabilidade e proteção de `main` (GitHub Flow), com veredito.
- **Gate de saída**: aprovado (ou aprovado com ressalvas registradas). Depois disso, o merge do PR
  para `main` é decisão do usuário — nenhum agente mergeia sozinho.

## Governança de decisão (vale para as 5 etapas)

Detalhe completo em `docs/QUALITY-GATES.md`. Resumo: nenhum agente faz suposição silenciosa —
toda ambiguidade vira pergunta ao usuário, com **"VALIDAR DEPOIS"** sempre disponível como opção
quando o usuário não souber responder agora (o item fica registrado na seção "Pendências de
validação" do artefato). Nenhuma ação ou pergunta se repete mais de 3 vezes sem escalar. Use
`/sdd-pending` para ver todos os itens VALIDAR DEPOIS em aberto em qualquer momento.

## Utilitários: `/sdd-status` e `/sdd-pending`

`/sdd-status` não aciona agente — lê `specs/` e reporta em que etapa cada feature está, qual o
próximo comando a rodar, quantas pendências VALIDAR DEPOIS existem e se alguma etapa foi marcada
"requer revalidação" por uma emenda. `/sdd-pending` lista o detalhe dos itens VALIDAR DEPOIS em
todas as features. Use a qualquer momento para se orientar.

## Regra de ouro

Cada etapa **exige o artefato aprovado** da etapa anterior como pré-condição. Um agente que não
encontra o artefato de entrada não improvisa um — ele para e diz ao usuário qual comando rodar
antes. Isso é o que torna o pipeline confiável: pular etapa nunca é "mais rápido", é retrabalho
disfarçado.

## Ciclo de feedback

Se o QA reprova, a feature volta para `/sdd-implement` com achados específicos. Se o SRE reprova
(ou aprova com ressalvas bloqueantes), os itens voltam para quem for responsável — pode ser o
`senior-developer` (ex.: falta observabilidade no código) ou ajuste direto do próprio `sre` em
`infra/`. O PRD e o TRD só são reabertos se a causa raiz for de requisito ou de design.

## Emenda sem reiniciar: `/sdd-amend`

Mudar uma decisão **já aprovada** (não uma reprovação — uma mudança de ideia, ou a resolução de um
item VALIDAR DEPOIS) não reinicia o pipeline. `/sdd-amend` edita o artefato in-place, registra a
mudança no "Log de revisões" dele, e marca só as etapas *posteriores* realmente afetadas como
"requer revalidação" — etapas anteriores aprovadas continuam válidas. Ex.: mudar um detalhe de
texto no PRD que não muda critério de aceite não invalida o TRD; mudar um critério de aceite
invalida TRD, implementação e QA, mas não obriga a refazer a conversa toda do PRD.

## GitHub Flow no pipeline

Detalhe completo em `docs/GIT-WORKFLOW.md`. Resumo: PRD e TRD não têm branch (são documentos).
`/sdd-implement` cria `feature/<NNNN-slug>` e abre PR draft cedo. QA e SRE revisam contra esse PR.
Merge para `main` só acontece depois de QA e SRE aprovados, é uma decisão do usuário (nenhum
agente mergeia sozinho), e dispara o CD.

## Exemplo completo

`specs/0001-example-task-management/` contém um PRD, TRD, QA report e SRE review reais,
correspondentes ao código de exemplo em `src/` e `tests/`. Use como referência de nível de
detalhe esperado em cada artefato.
