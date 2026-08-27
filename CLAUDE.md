# btt-sdd-pipeline — guia para o Claude Code

Este repositório é um **template de desenvolvimento orientado a especificação (SDD — Spec-Driven
Development)**. Ele existe para que qualquer feature nasça de uma especificação de produto,
passe por um desenho técnico revisável, seja implementada com TDD (backend e frontend em
paralelo, quando aplicável) e só chegue a produção depois de revisão de código, QA, revisão de
segurança e validação de SRE — tudo com agentes dedicados a cada etapa, **instalados globalmente**
(ver "Distribuição global" abaixo) para funcionar em qualquer projeto, não só neste.

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

Cada etapa só começa com o artefato aprovado da etapa anterior. Nenhuma etapa pula a anterior:
backend/frontend não implementam sem TRD aprovado, o QA não assina sem os testes rodando, a
segurança não aprova sem QA verde, o SRE não aprova pipeline/infra sem QA e segurança aprovados.

**Quando o TRD tem mais de uma fatia vertical de entrega** (seção "Decomposição de tarefas e
dependências (fatias verticais de entrega)"), as etapas [3] a [7] se repetem **por fatia**, em
loop: cada fatia é sua própria branch/PR, passa por code review/QA/segurança/SRE, e só é mergeada
em `main` antes da fatia seguinte começar — nunca se implementam todas as fatias de uma vez para
só depois revisar tudo junto. Detalhe completo em `docs/GIT-WORKFLOW.md`.

Cada agente vive em `.claude/agents/<nome>.md` e é acionado por uma skill em
`.claude/skills/sdd-*`. Use os comandos:

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
| `/sdd-gap-report`   | (nenhum, utilitário)                             | compara casos de uso do TRD (seção 6) com o código real |

Veja um exemplo completo já rodado em `specs/0001-example-task-management/` (backend-only, CLI
Python).

## Distribuição global

Os agentes (`.claude/agents/`) e skills (`.claude/skills/`) deste repositório estão disponíveis
**em qualquer projeto** neste computador via junction de diretório:
`C:\Users\<usuário>\.claude\agents` e `...\.claude\skills` apontam para as pastas equivalentes
aqui — um único conjunto de arquivos, editar aqui atualiza o que está disponível globalmente sem
passo de sincronização manual. Isso significa duas coisas na prática:

- Você pode rodar `/sdd-trd`, `/sdd-implement` etc. dentro de **qualquer outro projeto** que
  tenha a mesma estrutura de `specs/`, `docs/`, `CLAUDE.md` — não precisa estar neste
  repositório.
- `/sdd-prd` e `/sdd-trd` aceitam um **caminho de arquivo explícito** como entrada (ex.:
  `/sdd-trd caminho/para/spec.md`), não só a convenção `specs/<slug>/`.
- `/create-project` é a forma de começar um projeto novo do zero: pergunta requisitos, cria um
  diretório separado, copia a estrutura genérica (`.claude/skills/create-project/scaffold/`) para
  lá, e inicia o pipeline com o primeiro PRD.

Além da junction, o mesmo pipeline também existe empacotado como **plugin instalável** do Claude
Code, em `plugins/btt-sdd/` (manifesto `.claude-plugin/plugin.json`, mais `.claude-plugin/
marketplace.json` na raiz do repo funcionando como marketplace local). É uma cópia própria, não
um link — necessária porque comandos instalados via plugin ganham o namespace `btt-sdd:` (ex.:
`/btt-sdd:trd` em vez de `/sdd-trd`); ver `plugins/btt-sdd/README.md` para o processo de
manter as duas cópias em sincronia. Instalação testada e confirmada de verdade neste computador:

```
claude plugin marketplace add C:\repositorios\projeto-base-ia
claude plugin install btt-sdd@btt-sdd-pipeline
```

(a pasta local deste repositório continua se chamando `projeto-base-ia` no disco — só a
identidade do projeto/marketplace/repositório GitHub é `btt-sdd-pipeline`; o caminho acima reflete
isso.)

Depois de instalado, os comandos ficam disponíveis com o prefixo `/btt-sdd:` em qualquer sessão
nova do Claude Code neste computador, coexistindo sem conflito com os comandos sem prefixo da
junction (`/sdd-status` e `/btt-sdd:status`, por exemplo, funcionam os dois, cada um lendo o
projeto onde a sessão estiver aberta).

**Atualizar o plugin depois de uma mudança** não é automático — instalação via GitHub é uma cópia
fixa do momento do clone, precisa de `claude plugin update btt-sdd@btt-sdd-pipeline` (instalação
local reflete sozinha na próxima sessão). Ver `plugins/btt-sdd/README.md`, seção "Atualizar o
plugin", para o passo a passo completo (sincronizar as duas cópias antes de commitar/dar push).

## Princípios de arquitetura (não negociáveis)

1. **Ports & Adapters (arquitetura hexagonal).** `src/domain` não importa nada de fora. `src/application`
   define casos de uso e *ports* (interfaces) — nunca implementações concretas de infraestrutura.
   `src/adapters` implementa os ports (saída: banco, filas, APIs externas) ou aciona os casos de uso
   (entrada: HTTP, CLI, eventos). Dependências sempre apontam para dentro (regra da dependência).
   Quando a feature tem frontend, `frontend/` segue uma separação análoga (componentes vs.
   serviços), consumindo o backend via o contrato definido no TRD. Detalhe completo em
   `docs/ARCHITECTURE.md`.

2. **SOLID.** Toda classe/módulo novo deve justificar sua responsabilidade única (S). Extensão de
   comportamento se dá por composição/novos adapters, não por `if/else` crescente (O). Implementações
   de um port são substituíveis entre si sem quebrar o caso de uso (L). Interfaces de port são
   pequenas e específicas por caso de uso, não um "God interface" (I). Casos de uso dependem de
   abstrações (ports), nunca de classes concretas de adapter (D).

3. **Clean Code.** Funções pequenas, nomes que dizem o que a coisa é, sem comentários explicando
   o óbvio (comentário só quando explica um *porquê* não óbvio). Sem código morto, sem flags de
   feature esquecidas, sem abstração especulativa para "o futuro".

4. **TDD estrito.** Todo código de produção nasce de um teste que falha primeiro (red), o mínimo
   de código para passar (green), depois refatoração (refactor) mantendo os testes verdes.
   `backend-developer` e `frontend-developer` seguem esse ciclo — nunca escrevem implementação sem
   teste antes.

5. **Cobertura mínima de 80%, por pacote.** Aplicado por CI (`.github/workflows/ci.yml`) e
   verificado pelo agente `qa-engineer` antes de qualquer aprovação. `src/` e `frontend/` (quando
   existir) têm cada um seu próprio gate — cobertura abaixo de 80% em qualquer um bloqueia o
   pipeline. Detalhe em `docs/TESTING.md`.

6. **Pilares de engenharia.** Todo TRD responde explicitamente a performance, escalabilidade,
   resiliência, disponibilidade, observabilidade e manutenibilidade — nunca em branco. Detalhe em
   `docs/ENGINEERING-PILLARS.md`.

7. **Stack tecnológica nunca implícita.** O `architect` decide a stack antes de desenhar qualquer
   outra coisa no TRD, nesta ordem: reaproveita `docs/STACK.md` deste projeto se já existir;
   senão propõe o padrão de `~/.claude/stack-defaults.md` (arquivo pessoal opcional) se existir,
   confirmando com o usuário; senão pergunta do zero. Toda decisão nova é gravada em
   `docs/STACK.md` para a próxima feature reaproveitar.

## Onde as coisas vivem

- `specs/` — PRDs, TRDs, QA reports, security reviews e SRE reviews, um diretório por feature.
- `src/domain`, `src/application`, `src/adapters` — código de produção de backend em ports &
  adapters.
- `frontend/` — código de produção de frontend, quando a feature tem UI (não existe neste
  repositório hoje).
- `tests/unit`, `tests/integration`, `tests/e2e` — testes de backend espelhando a arquitetura.
- `infra/docker`, `infra/terraform` — containerização e infraestrutura como código.
- `.github/workflows` — pipelines de CI (lint + testes + gate de cobertura) e CD (deploy via Terraform).
- `docs/` — arquitetura, workflow SDD, política de testes, pilares de engenharia, gates críticos,
  fluxo de Git e guia arquivo-a-arquivo.

## Nota sobre a stack

Este template é **agnóstico de linguagem** na estrutura, nos agentes e nas skills — os princípios
(ports & adapters, SOLID, TDD, cobertura 80%) valem para qualquer stack. O diretório `src/` traz
uma **feature de exemplo em Python** (`specs/0001-example-task-management/`) só para ilustrar o
fluxo ponta a ponta com código real e testes rodando — é backend-only (sem frontend). Ao adotar
outra linguagem, troque o conteúdo de `src/`/`tests/`, o `Dockerfile` e o job de testes do
`ci.yml` — a estrutura de pastas e o pipeline SDD continuam os mesmos.

## Regras de governança (valem para todos os agentes)

Detalhe completo em `docs/QUALITY-GATES.md` — aqui só o resumo:

1. **Nenhuma suposição silenciosa.** Toda ambiguidade que mudaria um artefato (requisito, decisão
   técnica, interpretação de critério de aceite, decisão de infraestrutura) é uma pergunta ao
   usuário via `AskUserQuestion` — nunca uma escolha implícita do agente. Quando o usuário não
   souber responder agora, **"VALIDAR DEPOIS"** é sempre uma opção válida; o item fica registrado
   na seção "Pendências de validação (VALIDAR DEPOIS)" do artefato e pode ser revisado depois com
   `/sdd-pending` e resolvido com `/sdd-amend`.
2. **Nenhuma ação ou pergunta se repete mais de 3 vezes.** Na 3ª tentativa (correção de teste,
   comando, reformulação de pergunta) sem sucesso, o agente para e escala ao usuário com o que
   tentou e sua recomendação — nunca insiste numa 4ª vez.
3. **Planeje antes de executar, sempre.** PRD e TRD já são planos (a aprovação deles é o próprio
   gate). Para `/sdd-implement` e `/sdd-sre`, que executam ações reais (código, infraestrutura), o
   agente apresenta o plano e pede aprovação explícita via `AskUserQuestion` antes de agir — em
   feature full-stack, `/sdd-implement` apresenta um único plano combinado antes de acionar
   `backend-developer` e `frontend-developer` em paralelo.
4. **Artefatos aprovados são editados in-place**, nunca recriados do zero. Mudar uma decisão já
   aprovada usa `/sdd-amend`, que só reabre as etapas posteriores realmente afetadas — sem
   reiniciar o pipeline da primeira etapa.
5. **Fluxo de Git = GitHub Flow.** `main` sempre implantável, uma branch por **fatia vertical de
   entrega** (não por feature inteira), PR obrigatório, merge só após revisão de código, QA,
   segurança e SRE aprovados para aquela fatia. **Vale também para mudanças no próprio pipeline**
   (agentes, skills, docs, templates) — nunca commite direto em `main`/`master`, mesmo para uma
   edição pontual de documentação: crie uma branch com o prefixo certo (`fix/`, `hotfix/`,
   `chore/`, `docs/`, `refactor/`, `perf/`, `test/`, `ci/` — tabela completa em
   `docs/GIT-WORKFLOW.md`) e abra PR antes de mergear.
6. Nunca avance uma etapa sem o artefato de entrada da etapa anterior existir e estar aprovado
   pelo usuário (não apenas gerado).
7. Nunca escreva código de produção fora de `src/`/`frontend/` seguindo a separação de
   responsabilidade de cada um.
8. Nunca reduza a cobertura de testes abaixo de 80% em qualquer pacote para "economizar tempo" —
   se um trecho é genuinamente difícil de testar, isso é um sinal de design a ser resolvido pelo
   `architect`, não ignorado.
9. Sempre registre decisões técnicas relevantes (troca de padrão, escolha de tecnologia, trade-off
   de arquitetura, contrato de API reutilizável) como ADR em `docs/adr/`, usando
   `docs/adr/0001-record-architecture-decisions.md` como modelo.
