# Lições aprendidas recorrentes (`docs/LESSONS-LEARNED.md`)

> Parte de `docs/QUALITY-GATES.md` (índice). Gate crítico: o que está marcado aqui
> **bloqueia mesmo** — não é sugestão, é a definição do que "pronto" significa.

Mecanismo de memória do próprio projeto: captura padrões de achados que já se repetiram entre
features, para que `backend-developer`/`frontend-developer` os evitem desde o início da próxima
implementação, em vez de descobri-los de novo numa rodada de revisão. `docs/LESSONS-LEARNED.md` não
existe por padrão — só nasce na primeira vez que uma 2ª ocorrência é confirmada (mesmo padrão de
`docs/STACK.md`/`docs/BASELINE.md`: ausência do arquivo já é sinal de "nenhum padrão recorrente
confirmado ainda").

- [ ] **Só vira entrada com 2 ocorrências confirmadas, nunca na primeira vez que aparece.** Antes de
  registrar um achado, o agente de revisão (`code-reviewer`/`qa-engineer`/`security-engineer`/
  `sre`) verifica se `docs/LESSONS-LEARNED.md` já existe e se alguma entrada da sua própria área já
  descreve o mesmo padrão — se sim, cita o ID da entrada no achado desta rodada e acrescenta esta
  feature/fatia à lista de ocorrências da entrada. Se não há entrada correspondente, verifica se um
  achado essencialmente igual já apareceu numa revisão anterior de **outra** feature/fatia (grep em
  `specs/*/<mesmo-tipo-de-artefato>.md`, excluindo a feature atual). Só ao confirmar essa 2ª
  ocorrência cria uma nova entrada (criando o arquivo se for a primeira entrada de sempre), citando
  as duas ocorrências e uma recomendação objetiva de implementação. Achado isolado (1ª ocorrência)
  nunca vira entrada — fica só no relatório da própria feature.
- [ ] **Formato de entrada**: uma seção por área (Backend / Frontend / Segurança / Infra-SRE /
  Testes-QA), com ID no formato `L-<AAAA-MM-DD>-<slug-curto>` (data da criação da entrada + slug
  curto em kebab-case do próprio achado, ex.: `L-2026-08-25-timeout-http-nao-configuravel`) e os
  campos "Detectado por", "Ocorrências" (caminho do artefato + fatia, por feature), "Padrão
  observado", "Recomendação para implementação", **"Escalonamento"** (append-only, só quando houver
  oferta — ver o bullet sobre estado da oferta abaixo) e **"Classe"** (`acionável-por-agente` se o
  próximo dev/agente consegue evitar o padrão sozinho ao implementar a partir da lição; ou `depende
  de ação externa` se a resolução depende de uma configuração fora do código — proteção de
  branch/environment, segredo, permissão de infra — que nenhum agente corrige sozinho sem aprovação
  explícita do usuário). A distinção importa porque a estratégia para quebrar o ciclo de repetição é
  diferente para cada classe (próximo bullet). **Nunca use um contador sequencial simples (`L-001`,
  `L-002`, ...)**: duas branches de fatia diferentes, cada uma calculando o "próximo ID" a partir da
  sua própria cópia local do arquivo, já geraram colisão real de ID em merge — exigiu renumeração
  manual e correção de autorreferências. Data + slug do achado é suficientemente único entre
  branches paralelas sem precisar coordenar um contador global; na rara colisão de duas entradas com
  data e slug idênticos, acrescente um sufixo numérico ao segundo (`-2`, `-3`, ...) no momento do
  merge.
- [ ] **Métrica de ambiente citada numa entrada vale só para a ocorrência que a mediu — quem
  registra uma ocorrência nova remede e reatribui, nunca copia da anterior.** Quando a assinatura ou
  a causa de uma entrada cita um número de ambiente ("N processos concorrentes de outros worktrees",
  "memória livre abaixo de X", "fila do runner acima de Y"), **remedir é parte de registrar a
  ocorrência**. Para métricas de processo/recurso, medir significa responder duas perguntas que o
  número de manchete não responde: quantos dos processos contados são realmente o que se supõe
  (processo real vs. processo filho), e **desde quando existem**. Repetir a métrica sem remedir
  registra **correlação, não causa** — e cada nova ocorrência que a copia faz a explicação *parecer*
  mais confirmada quando só está sendo propagada. Já aconteceu de verdade: uma entrada de flakiness
  de suíte de integração chegou à **18ª ocorrência** carregando "71 `chrome.exe` + 7 `dotnet.exe`
  concorrentes de outros worktrees" como causa ambiental; medido sob exatamente os mesmos números de
  manchete, só **2** dos 71 eram navegadores (os outros 69, processos filhos), **60** pertenciam ao
  navegador pessoal do operador aberto 4 dias antes da spec começar, e 6 dos 7 `dotnet.exe` eram nós
  ociosos de reuso do build. A flakiness era real; a explicação causal não — e a conduta que ela
  induzia ("esperar a contenção baixar") nunca poderia convergir, porque o número quase não desce.
- [ ] **A recíproca: entrada cuja métrica se mostra mal atribuída tem a prosa corrigida, não só a
  contagem incrementada.** Uma entrada acumula autoridade junto com ocorrências — corrigir o texto
  da causa é o que impede que as ocorrências seguintes continuem herdando a explicação errada. Vale
  para o "Padrão observado" e para a "Recomendação para implementação", não só para a tabela de
  ocorrências.
- [ ] **Antes de acrescentar uma ocorrência, confira se `docs/PROJECT-CONVENTIONS.md` tornou
  esperado o comportamento que a entrada trata como defeito.** Se tornou, **não incremente**: marque
  a entrada como obsoleta (próximo bullet). Uma convenção de projeto pode **inverter o sentido** de
  uma lição genérica, e a assimetria de custo esconde isso — contar mais uma ocorrência é barato e
  invisível, perceber que a entrada inteira caducou exige reauditar a premissa, que é justamente o
  que não se faz quando a entrada "já está estabelecida". Tende a aparecer onde o pipeline ganhou
  opt-in por projeto (`docs/PROJECT-CONVENTIONS.md` é lido por todos os agentes; a cadência
  `ci-antes-do-merge` foi o primeiro opt-in de comportamento), então quanto mais convenções um
  projeto acumula, mais lições genéricas podem deixar de valer localmente.
- [ ] **Estado `obsoleta` no formato da entrada**, para o caso em que ela deixa de valer porque o
  mundo mudou de forma deliberada — o quarto movimento, ao lado de criar, acrescentar ocorrência e
  corrigir a prosa. Três campos: **desde quando**, **por qual convenção/decisão**, e **o que
  sobrevive** dela (frequentemente sobra a parte de método, mesmo quando o diagnóstico caduca). As
  ocorrências históricas ficam **preservadas, nunca apagadas** — elas aconteceram, e sob o regime
  antigo o diagnóstico estava certo. Quando a obsolescência cria um risco novo no lugar do antigo, a
  entrada aponta o **sucessor** pelo ID. Já aconteceu de verdade: uma entrada com 6 ocorrências
  sobre "PR mergeável mas ainda marcado como draft" inverteu de sentido quando o projeto adotou
  `ci-antes-do-merge` — `isDraft: true` durante a fatia passou a ser **o mecanismo** que suprime a
  suíte cara, e um PR fora do draft é que seria anômalo. O agente chegou a registrar a 7ª ocorrência
  antes de perceber, desfez o registro, e teve de inventar a marcação na hora.
- [ ] `docs/LESSONS-LEARNED.md`, quando criado ou atualizado, é commitado junto do artefato de
  revisão da própria rodada (`code-review.md`/`qa-report.md`/`security-review.md`/ `sre-review.md`)
  — nunca num commit separado.
- [ ] **Entrada classificada como `depende de ação externa` que atinge 3 ocorrências confirmadas
  deixa de ser só uma nota passiva.** Ao reconfirmar essa entrada pela 3ª vez (contando a criação na
  2ª ocorrência), o agente que a reconfirma não só acrescenta a ocorrência à tabela — aciona
  `AskUserQuestion` oferecendo resolver a pendência ali mesmo, se tiver a capacidade técnica para
  isso (ex.: `sre` configurando proteção de branch/environment via API do GitHub — `agents/sre.md`,
  seção "Áreas de responsabilidade" — sempre sujeito a aprovação explícita antes de qualquer mudança
  real, nunca aplicado sozinho), em vez de silenciar a repetição como mais uma linha na tabela. Sem
  essa capacidade, ainda assim escala explicitamente ao usuário. Uma lição sobre configuração
  externa nunca se resolve sozinha só por ser lida no planejamento — já aconteceu de uma entrada ser
  reconfirmada 17 vezes em 9 features sem nunca resultar em correção efetiva da configuração.
- [ ] **Entrada classificada como `acionável-por-agente` que atinge 3 ocorrências confirmadas sem
  correção efetiva também escala — não é exclusividade de `depende de ação externa`.** "Virar
  entrada e ser lida no planejamento" evita o bug em código *novo*, mas não corrige consumidores já
  existentes com o mesmo padrão que nenhuma sessão foi tocar de propósito — uma lição pode ser lida
  e aplicada corretamente em toda feature nova e, mesmo assim, o padrão continuar presente
  indefinidamente em código antigo nunca revisitado. Ao reconfirmar essa entrada pela 3ª vez, o
  agente de revisão que a reconfirma (`code-reviewer`/`qa-engineer`/`security-engineer`/`sre`, o que
  estiver rodando) propõe explicitamente, via `AskUserQuestion` (ou repassando a pergunta ao
  orquestrador se estiver rodando em background), uma mini-fatia/hotfix dedicada para aplicar a
  correção já conhecida a todos os consumidores afetados — mesmo que a correção em si fique fora do
  escopo da fatia atual, a proposta explícita ao usuário não fica. Já aconteceu de verdade: uma
  correção conhecida e testada desde a 1ª ocorrência (trocar um método de resolução de identidade
  tenant-escopado por uma variante entre tenants) nunca foi propagada aos demais consumidores, e a
  mesma entrada chegou à 3ª ocorrência com o próprio achado já recomendando prioridade em texto
  livre — sem nada no processo formal forçando essa priorização a acontecer.
- [ ] **A oferta de escalonamento tem estado, e ele fica na própria entrada.** Os dois bullets
  acima criam o gatilho da oferta; sem registrar a resposta, a oferta é refeita a cada fatia, a
  pendência nunca converge, e o usuário é treinado a ignorá-la. A entrada ganha um campo
  **"Escalonamento"**, append-only, uma linha por oferta: **data**, **quem ofereceu**, **o que foi
  oferecido** e a **resposta** (`aceito` / `adiado` / `recusado` / `sem resposta`). Quem reconfirma
  a entrada **lê esse campo antes de ofertar**, e:
  - **Não repete a oferta idêntica** que já foi adiada ou recusada. Reofertar exige **fato novo** —
    uma objeção derrubada por medição, um agravamento do impacto, ou uma classe de ocorrência nova.
  - **`recusado` fecha o eixo de decisão**: a entrada continua contando ocorrências, mas para de
    escalar, e o motivo da recusa fica escrito — para a próxima spec não reabrir a discussão nem
    tratar o silêncio como pendência. Uma recusa deliberada do usuário precisa ser distinguível de
    uma pergunta que nunca chegou até ele.
  - **`adiado` ou `sem resposta` numa entrada que atinge 5 ocorrências vira issue rastreada** no
    repositório do projeto, com a decisão pendente explicitada. É a saída que tira o item do
    artefato de revisão — onde ele é relido por todo mundo e resolvido por ninguém.

  Já aconteceu de verdade, em três entradas da mesma spec: uma na **5ª** ocorrência ("oferecido e
  não aplicado" em três fatias seguidas), uma na **6ª spec** consecutiva, e uma com **29**
  ocorrências e "mitigação ainda não decidida". No caso mais ilustrativo o agente **reuniu os dados
  que resolveriam a dúvida** na própria rodada — mediu o custo do check, mostrou que não interagia
  com a cadência nova, e derrubou a objeção plausível com um incidente real do mesmo dia — e ainda
  assim o item ficou aberto, porque nada disso fica registrado como "já perguntado, faltando X". Na
  spec seguinte o próximo agente recomeça do zero.
- [ ] `backend-developer`/`frontend-developer` leem `docs/LESSONS-LEARNED.md`, se existir, na fase
  de planejamento (antes de quebrar o TRD em incrementos) e aplicam as lições da(s) área(s)
  relevante(s) à trilha como restrição adicional ao TRD, citando no plano apresentado ao usuário
  qual lição foi aplicada e como.
- [ ] **Uma entrada de lições aprendidas nunca substitui a regra canônica que ela generaliza.** Uma
  entrada existe para resumir um padrão de achado já repetido, não para redefinir a regra original —
  se a entrada (ou a paráfrase de qualquer agente ao aplicá-la) parecer contradizer ou ser mais
  estreita que uma regra já formalizada em outro doc do projeto (`docs/TESTING.md`,
  `docs/QUALITY-GATES.md`, etc.), a regra canônica prevalece: releia a doc de origem antes de tratar
  a lição como atalho, e sinalize a divergência como um sinal de que a própria entrada precisa de
  correção, não de que a regra mudou. Já aconteceu: uma lição registrada como "sempre que X tocar Y"
  restringiu implicitamente uma regra original incondicional ("toda fatia com trilha Z"), e
  `frontend-developer` pulou uma etapa obrigatória (build real) a partir da versão estreita — só
  pego porque duas rodadas de revisão independentes checaram a regra original em vez de confiar na
  paráfrase.
