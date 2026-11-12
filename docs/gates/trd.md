# TRD

> Parte de `docs/QUALITY-GATES.md` (índice). Gate crítico: o que está marcado aqui
> **bloqueia mesmo** — não é sugestão, é a definição do que "pronto" significa.

- [ ] Stack tecnológica definida (seção 2 do TRD), com a fonte da decisão registrada —
  reaproveitada de `docs/STACK.md` do projeto, reaproveitada de
  `~/.claude/stack-defaults.md` (confirmada com o usuário), ou decidida nesta sessão com o
  usuário. Nunca implícita dentro de Ports/Adapters/Modelo de dados.
- [ ] Todo critério de aceite do PRD tem um caso de uso e um plano de teste correspondente.
- [ ] A leitura crítica do PRD rodou antes do desenho (`architect/readiness-do-prd.md`): bloqueantes
  perguntados em lote, assumíveis em "Premissas assumidas" (`tracking.md`, seção 15b) com ID,
  padrão e impacto, e toda decisão do TRD cita o requisito de origem.
- [ ] Todo port tem contrato claro sem vazar detalhe de implementação de adapter.
- [ ] Indicadores técnicos do PRD foram lidos e endereçados (decisão tomada ou explicitamente
  adiada com justificativa, nunca ignorados).
- [ ] Todo pilar de engenharia (`docs/ENGINEERING-PILLARS.md`: performance, escalabilidade,
  resiliência, disponibilidade, observabilidade, manutenibilidade) tem resposta específica para a
  feature, nunca em branco ou genérica.
- [ ] Se a feature inclui frontend, "Contrato Frontend↔Backend" está definido (no TRD ou num ADR
  referenciado) — nunca "a definir depois".
- [ ] **Todo critério de aceite de acesso negado (403/401) tem uma tarefa dona do teste.** Quando o
  critério reaproveita uma rota ou permissão existente, alguma tarefa lista o teste daquela rota
  (arquivo e caso), ou registra "teste já existente: `<arquivo>`" verificado por `grep`. "Suíte de
  isolamento" genérica não conta (`agents/architect/acesso-negado-teste-dono.md`).
- [ ] **No artefato da tarefa de investigação, cada afirmação está marcada `[medido]` ou
  `[inferido]`** — inclusive (sobretudo) as das seções de "nota operacional"/"consequência prática",
  que é onde a inferência se esconde. Uma frase inferida escrita num artefato cuja autoridade vem de
  ter sido medido herda essa autoridade e se propaga como restrição de desenho sem ninguém a
  questionar. E uma afirmação `[inferido]` entra no TRD como pendência ou premissa marcada, nunca
  como restrição.
- [ ] **Todo seletor/locator/contrato concreto contra um sistema externo cuja estrutura real não foi
  observada está marcado como provisório no próprio texto onde aparece, e tem uma tarefa de
  investigação agendada como primeira tarefa da primeira fatia que depende dele** — nunca só uma
  pendência "VALIDAR DEPOIS", que não bloqueia nada. Vale para seletor de DOM de terceiro, formato
  de
  resposta de API não documentada, layout de arquivo de parceiro, esquema de webhook, nome de campo
  de SSO. O motivo é que nenhuma etapa posterior pega esse erro: o dublê escrito a partir da
  suposição
  valida a suposição, e a suíte fica verde contra ela — code review, UX, QA, segurança e SRE revisam
  o código contra o TRD, e aqui o TRD é a fonte do erro
  (`.claude/agents/architect/contrato-externo-nao-observado.md`).
- [ ] **Na seção "Riscos e trade-offs", toda afirmação sobre comportamento concreto de biblioteca
  de terceiro ou de runtime está marcada `[medido]` (com versão e como) ou `[não medido]`**, e toda
  alegação de contenção ("vira falha daquela linha") cita o ponto do código onde a contenção
  acontece. Afirmação desse tipo sem marcação é lida como fato estabelecido e atravessa o pipeline
  inteiro sem verificação — inclusive escrita com hedge ("em teoria", "lançaria"), que faz o texto
  parecer análise prudente.
- [ ] **Nenhuma contagem na seção 11 (plano de testes) — e nenhuma enumeração de quais
  propriedades asseverar.** "Nos 6 estados", "os 3 casos de X" e "asseverar título e corpo" são
  mecanismo escrito como se fosse critério, e a seção 11 é estruturalmente **a seção que caduca**:
  seu conteúdo é mecanismo por definição, e mecanismo é o que cada rodada de correção troca.
  Escreva o critério que sobrevive à troca ("toda renderização visível", "trocar a ordem de qualquer
  par adjacente mata ao menos um teste").
- [ ] **Toda tarefa de "e2e do fluxo humano da fatia" tem ponto de entrada dentro da própria
  fatia.** Percorra o roteiro do primeiro passo para trás. As pré-condições típicas são sessão
  autenticada, credencial ativada, dado-semente e confirmação por e-mail. Cada uma tem produtor
  publicado **nesta** fatia, não numa posterior
  (`.claude/agents/architect/plano-de-testes-detalhe.md`). Quando
  não tem, o TRD traz a saída já decidida. São três: trazer o produtor mínimo para a fatia; dar ao
  ferramental um modo que dispense a tela ausente; declarar que o e2e cobre só o alcançável.
  Nenhuma outra
  asserção de completude pega isto. Elas cobram "permissão tem rota" e "rota tem handler", nunca "o
  roteiro tem início" — sem isso, o custo de um roteiro inalcançável por construção só aparece no
  meio da implementação.
- [ ] "Decomposição de tarefas e dependências" preenchida, com trilha (backend/frontend/ambos) e
  dependências técnicas explícitas para cada tarefa, e a coluna Status inicializada como
  `pendente` para cada tarefa nova (ciclo de vida completo na seção "Status de tarefas" abaixo).
- [ ] **Coluna `Validação na fatia` preenchida em toda tarefa** — `—` quando nenhuma validação é
  antecipada, ou `segurança`/`ux`/`sre` (combináveis) quando a etapa correspondente tem de rodar na
  própria fatia em vez de esperar o fim da spec (`docs/SDD-WORKFLOW.md`, seção "Cadência: o que
  roda por fatia e o que roda ao final da spec"). **Em branco não é opção**, e a marcação é
  **obrigatória**, não julgamento, quando a tarefa toca: autenticação, autorização, gestão de
  sessão, dado pessoal/sensível ou ponto de entrada que aceita identificador externo (→
  `segurança`); `ci.yml`/`cd.yml`, `Dockerfile`/compose, `infra/terraform`, segredo ou variável de
  ambiente de deploy, ou campo que passa a ser obrigatório numa rota ativa já consumida (→ `sre`);
  fluxo ou tela **nova** exposta ao usuário final (→ `ux`). Antecipação por julgamento próprio é
  permitida, com o motivo em uma linha na descrição da tarefa.
- [ ] **Se o projeto ainda não tem `.github/workflows/ci.yml` e esta spec produz a primeira suíte
  de testes, existe uma tarefa na decomposição que faz o workflow nascer**, com `Validação na
  fatia = sre` e apontando para `docs/CI-WORKFLOW.md` (a forma mínima). Sem ela o arquivo nasce sem
  dono e só é auditado na etapa 7, que roda uma vez ao final da spec — toda regra sobre a forma do
  `ci.yml` viraria corretiva por construção. Projeto que já tem o arquivo não precisa da tarefa:
  evoluir workflow existente é da etapa 7.
- [ ] **Toda tarefa tem a coluna "Issue GitHub" preenchida — obrigatório, não mais opcional.** Se
  não há remote GitHub configurado/autenticado, o TRD não pode ser aprovado ainda (`architect`
  para e pede para configurar `git remote`/`gh auth login` primeiro); só o PRD dispensa GitHub.
- [ ] **Toda issue GitHub que o pipeline cria no repositório do projeto-alvo carrega identificação
  estruturada da spec de origem** — não só as de tarefa do TRD. `architect` já garante isso para as
  issues de tarefa via o milestone por spec (acima). Reaproveite esse mesmo milestone (mesmo
  `<slug>`) sempre que outra issue do pipeline se referir à mesma spec/projeto — ex.: a issue de
  `/sdd-hotfix` (`.claude/skills/sdd-hotfix/SKILL.md`, passo 1b) quando o bug tem spec relacionada.
  Se ainda não existir nenhum milestone para essa spec (spec sem decomposição de tarefas em issues),
  aplique em vez disso um label `spec:<slug>` (criando-o se faltar). Uma issue aberta sem nenhuma
  spec relacionada (melhoria pontual sem origem) não precisa dessa identificação.
- [ ] Se o TRD depende de código pré-existente sem documentação suficiente, `/sdd-baseline` rodou
  antes (ou a documentação já era suficiente, explicitamente constatado).
- [ ] Nome de branch GitHub Flow definido **por fatia** (`docs/GIT-WORKFLOW.md`) — uma branch/PR
  por fatia, nunca uma única para a feature inteira quando há mais de uma fatia.
- [ ] Aprovação explícita do usuário registrada.
