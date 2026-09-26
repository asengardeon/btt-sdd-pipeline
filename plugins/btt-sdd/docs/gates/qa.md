# QA

> Parte de `docs/QUALITY-GATES.md` (índice). Gate crítico: o que está marcado aqui
> **bloqueia mesmo** — não é sugestão, é a definição do que "pronto" significa.

- [ ] `code-review.md` com veredito aprovado (ou aprovado com ressalvas aceitas pelo usuário) — sem
  isso, o QA não começa.
- [ ] Se a fatia tem superfície de UI perceptível (UX review não marcada "não aplicável"),
  `ux-review.md` com veredito aprovado (ou aprovado com ressalvas aceitas pelo usuário) — sem isso,
  o QA não começa.
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
