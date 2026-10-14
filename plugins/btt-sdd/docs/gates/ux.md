# UX / Usabilidade (`ux-designer`, condicional)

> Parte de `docs/QUALITY-GATES.md` (índice). Gate crítico: o que está marcado aqui
> **bloqueia mesmo** — não é sugestão, é a definição do que "pronto" significa.

- [ ] **Esta etapa roda ao final da spec, sobre o diff acumulado — ou na fatia que a antecipar.**
  O padrão é a última fatia pendente da decomposição do TRD, cobrindo o diff acumulado da spec,
  nunca só o da última fatia. Roda antes, dentro de uma fatia intermediária, quando a coluna
  `Validação na fatia` da seção 13 do TRD marca `ux` para alguma tarefa dela — **obrigatório**
  quando a tarefa expõe fluxo ou tela **nova** ao usuário final. Ajuste dentro de fluxo que esta
  etapa já revisou não qualifica (`docs/SDD-WORKFLOW.md`, seção "Cadência: o que roda por fatia e o que roda ao final da spec").
- [ ] **Critério objetivo para UX review obrigatória**: sempre que o diff da fatia tocar alguma
  tela/fluxo com superfície de UI perceptível pelo usuário final (layout, navegação, visibilidade
  condicional de controles, estado vazio/erro, conteúdo de mídia) — nunca uma decisão de "merece ou
  não" reavaliada caso a caso. Fatia 100% backend/infra sem nenhuma tela afetada marca a etapa como
  "não aplicável", registrado em `ux-review.md` sob o heading padronizado `## Decisão: UX review
  pulado (justificado)`, nunca simplesmente omitida.
- [ ] `code-review.md` com veredito aprovado (ou aprovado com ressalvas aceitas pelo usuário) — sem
  isso, a UX review não começa.
- [ ] **A aprovação de code review vigente cobre o HEAD atual da branch.** Não basta
  `code-review.md` existir aprovado: `git diff --name-only <sha da rodada que aprovou>..HEAD --
  <diretórios de produção>` tem de ser **vazio**. Se não for, esta etapa não começa — roda-se uma
  rodada de code review escopada ao delta, numa instância nova, antes de prosseguir. A checagem de
  sincronia que as skills já fazem é contra `main` (`git rev-list --count HEAD..origin/main`) e
  **não cobre este caso**: o que avançou foi a própria branch da fatia, depois do carimbo. Isso
  acontece no caminho normal, não num desvio — a etapa 4b roda depois da 4 e **gera código de
  produção**, então correções de achados de UX aceitas pelo usuário atravessam duas etapas com um
  carimbo que já não corresponde ao código. Já aconteceu de verdade: 5 arquivos de produção e 824
  inserções depois do sha aprovado, dois commits de correção de UX sem rodada nenhuma de revisão —
  a rodada escopada ao delta **reprovou**, achando um bloqueante (um `useEffect` dependendo do
  **valor** e não da **transição**, roubando o foco a cada volta à tela) e um 5º sinal de plataforma
  sem nenhuma menção em `specs/`, `docs/` ou código. Foi pego só porque o `qa-engineer` inventou a
  checagem por iniciativa própria — ela não estava escrita em lugar nenhum. O custo da checagem é
  um comando.
- [ ] Cada uma das 7 áreas de revisão (consistência e padrões; visibilidade do estado do sistema e
  prevenção de erro; controle/liberdade do usuário e navegabilidade; consciência de estado/ciclo de
  vida do domínio; robustez de conteúdo gerado pelo usuário; hierarquia de informação; alvo de
  toque/acessibilidade básica) tem veredito com evidência ou "sem achados" — nunca em branco.
- [ ] O método usado nesta rodada (verificação ao vivo via automação de navegador, ou leitura de
  código na ausência dela) está documentado em `ux-review.md` — um veredito baseado só em leitura
  estática nunca é apresentado como equivalente a uma verificação ao vivo.
- [ ] **Afirmação de que um nó "está montado" / "está na árvore de acessibilidade" é asseverada
  contra o documento com CSS aplicado, nunca contra a presença da classe no JSX.** Quando a rodada
  roda em jsdom (ou outro DOM sem engine de estilo) e o veredito depende de visibilidade, presença
  na árvore de acessibilidade, ordem de foco ou geometria, a regra de CSS relevante é **compilada
  com a toolchain do projeto e injetada no documento** antes da consulta; sem isso, a área é
  declarada **não medida**, não "sem achados". Isso não é redundante com o item de método acima:
  ali o problema é leitura estática apresentada como verificação ao vivo, aqui o método **era**
  execução instrumentada e ainda assim mediu o documento errado. Já aconteceu de `empty:hidden` (que
  compila para `display:none`) fazer `getByRole('status')` devolver **0** enquanto a região estava
  vazia, enquanto quatro artefatos afirmavam que ela era "sempre montada" e a suíte ficava verde —
  três etapas de revisão passaram por isso sem pegar nada por leitura.
- [ ] **Nenhum achado desta etapa fica fechado só com evidência técnica.** Quando uma correção de
  achado bloqueante (ou de ressalva que o usuário mandou corrigir) levantado **por esta etapa** é
  reverificada pelo `code-reviewer` escopado ao delta, essa rodada técnica não fecha o achado: o
  retorno antes de `/btt-sdd:qa` é uma rodada de UX review **escopada ao achado**, que acrescenta a
  `ux-review.md` uma seção de reverificação nomeando o achado, o método e a evidência. O
  `code-reviewer` confirma "o código faz o que devia"; "isso resolve o problema de usabilidade
  real" é veredito desta etapa. É a regra simétrica da que já existe no sentido inverso (correção
  de UX que toca produção volta para code review escopado) — sem ela, a etapa que existe para
  pegar essa classe de defeito carimba o fechamento sem nunca ter olhado o resultado. Já aconteceu
  de verdade: um achado bloqueante de navegação (edição pendente descartada em silêncio) foi
  corrigido com `useBlocker`, reverificado só tecnicamente, e o pipeline seguiu para `/btt-sdd:qa` —
  `code-review.md` atribuiu a aprovação a uma seção de `ux-review.md` que **não existia**. Foi o
  `qa-engineer`, por iniciativa própria, que conferiu via `git log` e registrou a lacuna como
  achado de processo, forçando uma rodada extra fora do fluxo.
- [ ] `ux-review.md` referencia o PR e a fatia desta rodada.
- [ ] **A linha desta rodada existe em `specs/<slug>/timing-log.md` e nomeia uma única etapa.** Etapa
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
- [ ] `ux-review.md` commitado (só esse arquivo, nunca `git add -A`/`.`) e enviado (push) na branch
  do PR pelo próprio `ux-designer` antes de devolver o resultado.
