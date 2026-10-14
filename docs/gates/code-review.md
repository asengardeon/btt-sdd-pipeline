# Revisão de código (`code-reviewer`)

> Parte de `docs/QUALITY-GATES.md` (índice). Gate crítico: o que está marcado aqui
> **bloqueia mesmo** — não é sugestão, é a definição do que "pronto" significa.

- [ ] Nenhuma violação de fronteira ports & adapters (domain/application sem import de infra)
  aprovada sem ressalva.
- [ ] Princípios SOLID avaliados de forma funcional (import de fato, não intenção declarada).
- [ ] Qualidade dos próprios testes avaliada (fragilidade, falso positivo) — cobertura numérica é
  do QA, não desta etapa.
- [ ] Se full-stack: contrato Frontend↔Backend do TRD checado como implementado exatamente pelos
  dois lados.
- [ ] Débito técnico introduzido está sinalizado explicitamente (pelo dev ou pela revisão) — débito
  silencioso não documentado é achado bloqueante.
- [ ] **A prosa dentro do código segue `docs/gates/escrita.md`** — docstring de port, docblock de
  adapter e o comentário que explica um porquê não óbvio. O item que mais rende aqui é "um termo
  por conceito": o nome do conceito no comentário é o mesmo nome no código e no TRD. Comentário que
  nomeia a coisa de um jeito e o símbolo de outro obriga quem lê a decidir se são a mesma coisa —
  e essa é a decisão que a revisão existe para eliminar, não para delegar.
- [ ] **Fatia que estende um guard/regra de autorização já implementado por uma fatia anterior
  (ex.: de "só autor" para "autor OU organizador/admin") renomeia os testes cujo nome descreve o
  comportamento que a nova fatia inverte — não só altera a asserção.** Um teste chamado
  `test_rejects_organizer` cuja asserção passou a esperar sucesso em vez de recusa é uma inversão
  semântica silenciosa: o nome descreve um comportamento que já não é mais verdade. Confirme
  também, via grep pelo nome antigo do teste no restante da suíte, que nenhuma referência órfã
  (import, chamada direta, menção em comentário) ficou para trás. Achado bloqueante se algum teste
  tocado pela fatia mantiver um nome que descreve o comportamento anterior.
- [ ] **Nenhum tradutor de erro com conjunto fechado de códigos descarta em silêncio a entrada que
  não sabe traduzir.** Se a fatia toca um mapeador entre vocabulário aberto (issues de validador de
  esquema, códigos de driver, erros de SDK) e vocabulário fechado do projeto (enum de código de
  campo, envelope único de resposta de erro), o caso não-mapeado tem destino explícito: log do
  identificador bruto, código de fallback na saída, e teste dedicado para a entrada que o enum
  **não** conhece. Achado bloqueante quando a resposta pode sair sem pista alguma — `fields: []`
  num `422` que de fato recusou algo é indepurável de fora. O defeito é estrutural: um campo
  `.optional()` sem o `.nullable()` correspondente, recebendo `null`, não quebra compilação nem
  reprova teste; só produz uma resposta vazia. Já custou uma rodada de correção inteira, com duas
  hipóteses descartadas por leitura de código antes de alguém capturar o corpo real da resposta
  (`.claude/agents/backend-developer.md`, "Regras inegociáveis de código", regra sobre tradutor de
  erro).
- [ ] Se a fatia tem trilha de frontend, ou gera qualquer outro artefato de build/empacotamento
  distinto do código-fonte, o comando de build/empacotamento real de produção (`docs/STACK.md`)
  foi verificado (reaproveitado do arquivo de cobertura da fatia ou reexecutado nesta rodada) antes
  de aprovar — nunca aprovado só com base em lint/tipo/teste unitário nesse caso
  (`docs/TESTING.md`, seção "Build/empacotamento real como parte da suíte completa").
- [ ] Se esta rodada gravou revisão nova no "Log de revisões" do TRD, as seções 9 (contrato
  observável), 13 (decomposição/Status) e 14 (controle de versão por fatia) foram reconciliadas —
  não só a seção que a revisão editou. São as seções que as etapas seguintes leem como contrato.
- [ ] Se o TRD marca esta fatia como portadora de uma quebra de contrato (seção "Janelas de quebra
  de contrato entre fatias", coluna "`!` no título do PR"), o título do PR tem `!` antes dos
  dois-pontos (ou o rodapé `BREAKING CHANGE:` no corpo) — checagem de um caractere, três etapas
  antes do SRE (`docs/GIT-WORKFLOW.md`, seção "Quebra de contrato e o título do PR"). Uma quebra
  encontrada no diff que o TRD **não** declarou é achado por si só.
- [ ] **A rodada declara no artefato se a fatia tem ou não superfície de UI perceptível pelo
  usuário final** (critério objetivo em `docs/gates/ux.md`), porque é esta etapa que roteia a
  seguinte: com superfície, a próxima é a 4b (`/sdd-ux-review`); sem, é o QA, e a decisão de pular
  fica registrada sob o heading padronizado de `ux-review.md`. A informação é de quem leu o diff —
  declará-la aqui deixa a decisão auditável em vez de implícita. Já aconteceu de uma fatia com
  superfície de UI pular a 4b inteira e ser mergeada em `main` sem revisão de usabilidade, numa
  spec onde a etapa já existia.
- [ ] `code-review.md` existe, referencia o PR e a fatia desta rodada, e cada área de revisão tem
  veredito com evidência (arquivo/linha) ou "sem achados".
- [ ] **A linha desta rodada existe em `specs/<slug>/timing-log.md` e nomeia uma única etapa.**
  Etapa
  cujo trabalho de orquestrador foi zero registra `0m` com justificativa — nunca nenhuma linha; e
  uma linha que nomeia duas etapas ("Segurança + code review") deixa uma das duas com zero minuto
  atribuível, então duas etapas que rodaram em paralelo são duas linhas com o mesmo horário de
  início. Em agente **retomado**, o valor registrado é a **diferença** contra a notificação anterior
  do mesmo agente, nunca o contador bruto — crescimento monotônico entre rodadas é a assinatura de
  contador cumulativo desde a criação (`specs/_template/timing-log.template.md`, seções "O que a
  coluna 'Duração' mede" e "Uma linha por etapa, sempre"). A retrospectiva de fatia lê este arquivo
  como evidência concreta de performance, e os três defeitos de medição empurram na **mesma
  direção**: superestimam as etapas de agente e subestimam as do orquestrador — numa fatia medida,
  29% do esforço era de orquestrador.
- [ ] `code-review.md` commitado (só esse arquivo, nunca `git add -A`/`.`) na branch do PR pelo
  próprio `code-reviewer` antes de devolver o resultado, e **integrado na branch da fatia**
  por quem o invocou (`git merge --ff-only` da branch informada, com o artefato confirmado
  alcançável) antes de a etapa seguinte começar. **O push não é por etapa**: é um por fatia,
  ao final da cadeia de revisão dela (`docs/GIT-WORKFLOW.md`, seção "Push único por fatia: o
  CI roda uma vez, não uma vez por artefato de revisão"). Commit e integração continuam
  obrigatórios — artefato que não chega à branch é o que estes itens existem para impedir; só
  o meio mudou.
