# QA

> Parte de `docs/QUALITY-GATES.md` (índice). Gate crítico: o que está marcado aqui
> **bloqueia mesmo** — não é sugestão, é a definição do que "pronto" significa.

- [ ] `code-review.md` com veredito aprovado (ou aprovado com ressalvas aceitas pelo usuário) — sem
  isso, o QA não começa.
- [ ] Se a fatia tem superfície de UI perceptível (UX review não marcada "não aplicável"),
  `ux-review.md` com veredito aprovado (ou aprovado com ressalvas aceitas pelo usuário) — sem isso,
  o QA não começa.
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
- [ ] Cobertura medida e comparada ao gate de 80% — sem relatório de cobertura confiável, não há
  aprovação possível.
- [ ] Se a fatia tem trilha de frontend, ou gera qualquer outro artefato de build/empacotamento
  distinto do código-fonte, o comando de build/empacotamento real de produção (`docs/STACK.md`) foi
  verificado antes de aprovar — lint/tipo/teste unitário sozinhos não são "suíte completa" nesse
  caso (`docs/TESTING.md`, seção "Build/empacotamento real como parte da suíte completa").
- [ ] **Garantia observável que depende de uma classe de CSS utilitário é asseverada contra o CSS
  publicado do build, não contra o fonte** — presença da regra quando a garantia depende de ela
  existir, ausência quando depende de ela ter sido removida. O extrator varre o arquivo inteiro,
  **comentários incluídos**, então o fonte não decide o que existe em produção: citar o nome literal
  de uma classe antiga no comentário que explica a mudança mantém a regra morta dela no CSS de
  produção, e uma classe que o código escreve pode não gerar regra nenhuma. Já aconteceu nas duas
  direções na mesma fatia — `empty:hidden` com contagem **0** nos dois arquivos de CSS do build,
  enquanto quatro artefatos afirmavam a garantia que ela deveria dar e a suíte ficava verde. É a
  contrapartida, do lado do build, do item equivalente de `docs/gates/ux.md` (compilar e injetar a
  regra no jsdom antes de consultar).
- [ ] Todo critério de aceite coberto pela fatia desta rodada tem veredito individual com evidência
  (teste ou passo manual).
- [ ] Suíte completa rodou (regressão, inclui fatias anteriores já mergeadas), não só os testes
  desta fatia — reaproveitando o resumo de cobertura já gravado pela implementação
  (`specs/<slug>/coverage/`) quando o commit bate com o HEAD atual; re-executada e regravada só se o
  arquivo estiver ausente ou desatualizado (`docs/TESTING.md`).
- [ ] `qa-report.md` referencia o PR e a fatia desta rodada.
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
- [ ] `qa-report.md` (e o arquivo de cobertura, se regravado) commitados (só esses arquivos, nunca
  `git add -A`/`.`) e enviados (push) na branch do PR pelo próprio `qa-engineer` antes de devolver o
  resultado.
