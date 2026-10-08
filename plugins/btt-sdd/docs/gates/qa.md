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
- [ ] Todo critério de aceite coberto pela fatia desta rodada tem veredito individual com evidência
  (teste ou passo manual).
- [ ] Suíte completa rodou (regressão, inclui fatias anteriores já mergeadas), não só os testes
  desta fatia — reaproveitando o resumo de cobertura já gravado pela implementação
  (`specs/<slug>/coverage/`) quando o commit bate com o HEAD atual; re-executada e regravada só se o
  arquivo estiver ausente ou desatualizado (`docs/TESTING.md`).
- [ ] `qa-report.md` referencia o PR e a fatia desta rodada.
- [ ] `qa-report.md` (e o arquivo de cobertura, se regravado) commitados (só esses arquivos, nunca
  `git add -A`/`.`) e enviados (push) na branch do PR pelo próprio `qa-engineer` antes de devolver o
  resultado.
