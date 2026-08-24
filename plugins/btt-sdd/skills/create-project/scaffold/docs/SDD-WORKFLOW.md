# Workflow SDD (Spec-Driven Development)

Este documento explica o funcionamento completo do pipeline de 6 etapas (+ 1 condicional) deste
repositório: por que ele existe, o que cada etapa exige/produz, e como as peças (agentes, skills,
templates) se encaixam.

## Por que Spec-Driven Development

O objetivo é que nenhuma decisão importante seja tomada implicitamente dentro do código. Cada
decisão de **o que construir** (produto), **como construir** (arquitetura) e **está correto?**
(qualidade, segurança) fica registrada em um artefato revisável, na ordem certa, antes do código
ser escrito ou aceito. Isso troca "descobrir depois que o requisito era outro" por "alinhar antes
de implementar", e troca "confiar que o dev testou/pensou em segurança" por "QA e segurança
validam objetivamente contra critérios escritos".

## Etapa 0 (condicional): Levantamento de baseline

- **Agente**: `.claude/agents/codebase-archaeologist.md`
- **Skill**: `/sdd-baseline`
- **Quando roda**: só quando um TRD depende de código/sistema já existente que nenhuma spec
  anterior documentou e que não tem documentação base suficiente — cenário típico: este template
  foi adotado sobre um projeto legado. Num projeto 100% construído por este próprio pipeline
  (já documentado por construção), isso normalmente nunca dispara.
- **Entrada**: código existente insuficientemente documentado.
- **Saída**: `docs/BASELINE.md` — visão geral real do sistema, stack, estrutura, convenções
  observadas, dívida técnica identificada (nunca corrigida por este agente), lacunas de teste. Ou,
  se a documentação já é suficiente, uma constatação explícita de que nada precisa ser criado.
- **Gate de saída**: `docs/BASELINE.md` existe para a área relevante, ou a suficiência foi
  constatada explicitamente — nunca um silêncio sem conclusão.

## As 6 etapas

### 1. Produto & Design → PRD

- **Agente**: `.claude/agents/product-design.md`
- **Skill**: `/sdd-prd`
- **Entrada**: um pedido de feature, em linguagem natural.
- **Saída**: `specs/<slug>/prd.md` — o quê e por quê, nunca o como técnico. Critérios de aceite
  em Gherkin, testáveis por um terceiro sem contexto adicional. Inclui "Indicadores técnicos a
  observar" (volumetria, segurança, legal) — sinalizados, não decididos — e "Ordem de valor /
  dependências entre histórias", a visão de produto de quais histórias dependem de outras.
- **Gate de saída**: aprovação explícita do usuário.

### 2. Arquitetura → TRD

- **Agente**: `.claude/agents/architect.md`
- **Skill**: `/sdd-trd`
- **Entrada**: PRD aprovado (e, se aplicável, `docs/BASELINE.md` da etapa 0).
- **Saída**: `specs/<slug>/trd.md` — modelo de domínio, ports, casos de uso mapeados aos
  critérios de aceite, adapters necessários, plano de testes de alto nível, a seção "Pilares de
  engenharia de software" (performance, escalabilidade, resiliência, disponibilidade,
  observabilidade, manutenibilidade — detalhe em `docs/ENGINEERING-PILLARS.md`) respondida
  explicitamente para a feature, o "Contrato Frontend↔Backend" quando a feature tem UI (o que
  permite backend e frontend desenvolverem em paralelo), e a "Decomposição de tarefas e
  dependências" (backend/frontend/ambos, com dependência técnica explícita — opcionalmente
  espelhada como GitHub Issues). ADRs em `docs/adr/` para decisões técnicas significativas.
- **Gate de saída**: aprovação explícita do usuário.

### 3. Desenvolvimento → Código + Testes (backend e/ou frontend, em paralelo quando full-stack)

- **Agentes**: `.claude/agents/backend-developer.md` e, quando a feature tem UI,
  `.claude/agents/frontend-developer.md`.
- **Skill**: `/sdd-implement`
- **Entrada**: TRD aprovado.
- **Plano antes de executar**: se só uma trilha, o agente correspondente quebra sua parte do TRD
  em incrementos e pede aprovação explícita antes de escrever qualquer código (ver
  `docs/QUALITY-GATES.md`). Se as duas trilhas (full-stack), a skill `/sdd-implement` monta e
  aprova **um plano combinado** com o usuário antes de invocar os dois agentes **em paralelo**,
  cada um executando sua trilha contra o contrato do TRD sem esperar pelo outro. Só depois disso
  cria a branch `feature/<NNNN-slug>` (GitHub Flow, `docs/GIT-WORKFLOW.md`, uma única branch/PR
  mesmo com as duas trilhas) e abre o PR.
- **Saída**: branch + PR + código em `src/` (ports & adapters) e/ou `frontend/`, com testes em
  `tests/` e/ou `frontend/tests/`, produzidos via TDD (red-green-refactor), com cobertura ≥ 80%
  por pacote.
- **Gate de saída**: plano aprovado, suíte de testes passando, lint limpo, cobertura reportada por
  pacote, PR aberto, contrato respeitado por ambos os lados quando full-stack.

### 4. QA → Validação objetiva

- **Agente**: `.claude/agents/qa-engineer.md`
- **Skill**: `/sdd-qa`
- **Entrada**: implementação + PRD + TRD.
- **Saída**: `specs/<slug>/qa-report.md` — veredito por critério de aceite, cobertura vs. gate de
  80%, achados de regressão e de violação de fronteira arquitetural.
- **Gate de saída**: veredito geral aprovado (senão volta para a etapa 3).

### 5. Segurança → Revisão de segurança da aplicação

- **Agente**: `.claude/agents/security-engineer.md`
- **Skill**: `/sdd-security`
- **Entrada**: QA aprovado.
- **Saída**: `specs/<slug>/security-review.md` — superfície de ataque, checklist OWASP Top 10,
  gestão de segredos na aplicação, autenticação/autorização, validação de entrada, dependências
  vulneráveis, com veredito. Foca em segurança **da aplicação**; segurança **operacional/infra**
  (Docker, Terraform, segredos de pipeline) é revisada pelo `sre` na etapa seguinte, sem
  sobreposição.
- **Gate de saída**: veredito geral aprovado (senão volta para a etapa 3).

### 6. SRE → CI/CD e infraestrutura

- **Agente**: `.claude/agents/sre.md`
- **Skill**: `/sdd-sre`
- **Entrada**: QA **e** segurança aprovados.
- **Plano antes de executar**: qualquer alteração real de infraestrutura (`terraform apply`) é
  apresentada como plano e só executada após aprovação explícita do usuário.
- **Saída**: `specs/<slug>/sre-review.md` — checklist de CI, CD, Docker, Terraform,
  observabilidade e proteção de `main` (GitHub Flow), com veredito.
- **Gate de saída**: aprovado (ou aprovado com ressalvas registradas). Depois disso, o merge do PR
  para `main` é decisão do usuário — nenhum agente mergeia sozinho.

## Governança de decisão (vale para todas as etapas, incluindo a condicional)

Detalhe completo em `docs/QUALITY-GATES.md`. Resumo: nenhum agente faz suposição silenciosa —
toda ambiguidade vira pergunta ao usuário, com **"VALIDAR DEPOIS"** sempre disponível como opção
quando o usuário não souber responder agora (o item fica registrado na seção "Pendências de
validação" do artefato). Nenhuma ação ou pergunta se repete mais de 3 vezes sem escalar. Use
`/sdd-pending` para ver todos os itens VALIDAR DEPOIS em aberto em qualquer momento.

## Utilitários: `/sdd-status` e `/sdd-pending`

`/sdd-status` não aciona agente — lê `specs/` e reporta em que etapa cada feature está, qual o
próximo comando a rodar, quantas pendências VALIDAR DEPOIS existem e se alguma etapa foi marcada
"requer revalidação" por uma emenda. `/sdd-pending` lista o detalhe dos itens VALIDAR DEPOIS em
todas as features (e em `docs/BASELINE.md`, quando existir). Use a qualquer momento para se
orientar.

## Flexibilidade de entrada e uso em qualquer projeto

Os agentes e skills deste pipeline estão instalados globalmente (ver "Distribuição global" em
`CLAUDE.md`) — funcionam em qualquer projeto, não só neste repositório, e não dependem de um
artefato de uma etapa anterior já existir na convenção padrão para começar: skills como
`/sdd-prd` e `/sdd-trd` aceitam um caminho de arquivo explícito como entrada (ex.: `/sdd-trd
caminho/para/spec.md`) além da convenção `specs/<slug>/`. Para começar um projeto do zero num
diretório novo, use `/create-project`.

## Regra de ouro

Cada etapa **exige o artefato aprovado** da etapa anterior como pré-condição. Um agente que não
encontra o artefato de entrada não improvisa um — ele para e diz ao usuário qual comando rodar
antes. Isso é o que torna o pipeline confiável: pular etapa nunca é "mais rápido", é retrabalho
disfarçado.

## Ciclo de feedback

Se o QA reprova, a feature volta para `/sdd-implement` com achados específicos. Se a segurança
reprova, também volta para `/sdd-implement` (com os achados de segurança). Se o SRE reprova (ou
aprova com ressalvas bloqueantes), os itens voltam para quem for responsável — pode ser
`backend-developer`/`frontend-developer` (ex.: falta observabilidade no código) ou ajuste direto
do próprio `sre` em `infra/`. O PRD e o TRD só são reabertos se a causa raiz for de requisito ou
de design.

## Emenda sem reiniciar: `/sdd-amend`

Mudar uma decisão **já aprovada** (não uma reprovação — uma mudança de ideia, ou a resolução de um
item VALIDAR DEPOIS) não reinicia o pipeline. `/sdd-amend` edita o artefato in-place, registra a
mudança no "Log de revisões" dele, e marca só as etapas *posteriores* realmente afetadas como
"requer revalidação" — etapas anteriores aprovadas continuam válidas. Ex.: mudar um detalhe de
texto no PRD que não muda critério de aceite não invalida o TRD; mudar um critério de aceite
invalida TRD, implementação, QA e segurança, mas não obriga a refazer a conversa toda do PRD.

## GitHub Flow no pipeline

Detalhe completo em `docs/GIT-WORKFLOW.md`. Resumo: a etapa 0 e o PRD/TRD não têm branch (são
documentos). `/sdd-implement` cria `feature/<NNNN-slug>` e abre PR draft cedo. QA, segurança e SRE
revisam contra esse PR. Merge para `main` só acontece depois de QA, segurança e SRE aprovados, é
uma decisão do usuário (nenhum agente mergeia sozinho), e dispara o CD.

## Primeira feature deste projeto

`/create-project` já criou o primeiro PRD (`specs/0001-<slug>/prd.md`) a partir dos requisitos
que você deu. Aprove-o e rode `/sdd-trd` para seguir o pipeline a partir daqui.
