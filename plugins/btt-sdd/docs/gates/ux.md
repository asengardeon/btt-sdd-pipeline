# UX / Usabilidade (`ux-designer`, condicional)

> Parte de `docs/QUALITY-GATES.md` (índice). Gate crítico: o que está marcado aqui
> **bloqueia mesmo** — não é sugestão, é a definição do que "pronto" significa.

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
