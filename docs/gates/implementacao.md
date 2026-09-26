# Implementação

> Parte de `docs/QUALITY-GATES.md` (índice). Gate crítico: o que está marcado aqui
> **bloqueia mesmo** — não é sugestão, é a definição do que "pronto" significa.

- [ ] Todo código de produção nasceu de um teste que falhou primeiro (TDD).
- [ ] Cobertura de linhas/branches novas ou alteradas ≥ 80%, **por pacote** (`src/` e, se
  aplicável, `frontend/` separadamente).
- [ ] Lint sem erros.
- [ ] Nenhuma violação de fronteira ports & adapters (domain/application sem import de infra).
- [ ] Se a feature é full-stack: todo adapter de entrada que o frontend consome implementa
  exatamente o contrato do TRD — nenhum campo/rota inventado por qualquer um dos dois lados.
- [ ] **Antes de criar a branch, `/sdd-implement` confirmou que toda tarefa desta fatia tem a
  coluna "Issue GitHub" preenchida no TRD — nenhuma fatia começa sem isso** (gate obrigatório,
  `.claude/skills/sdd-implement/SKILL.md`, passo 2c-ter). O mesmo vale para `/sdd-hotfix`: a issue
  do bug/ajuste existe antes da branch ser criada. Antes de tratar uma coluna "Issue GitHub" vazia
  como fatia pendente, o mesmo gate cruza com `git log`/`gh pr list` em busca de um commit/PR já
  mergeado cobrindo aquela fatia — Status desatualizado no TRD é uma discrepância de documentação
  a corrigir, não trabalho pendente a reabrir com issues novas.
- [ ] Branch da fatia criada a partir de `main` atualizada (só depois do PR da fatia anterior já
  mergeado, se houver uma); PR aberto (única branch/PR por fatia, mesmo quando backend e frontend
  desenvolvem em paralelo dentro dela).
- [ ] O PR referencia `Closes #N` para cada issue do GitHub associada às tarefas desta fatia
  (coluna "Issue GitHub" do TRD), **com a palavra-chave repetida por issue** (`Closes #117, Closes
  #118`), nunca a lista com vírgulas simples (`Closes #117, #118`), que o GitHub aplica só ao
  primeiro número (`docs/GIT-WORKFLOW.md`, regra 5b) — issues ficam abertas até o merge de verdade,
  nunca fechadas manualmente antes disso.
- [ ] Plano de implementação foi aprovado pelo usuário antes do primeiro commit de código (plano
  combinado quando full-stack, orquestrado por `/sdd-implement`).
- [ ] Resultado da suíte completa com cobertura gravado em
  `specs/<slug>/coverage/<fatia>-<trilha>.md` (`docs/TESTING.md`), com o commit SHA da execução —
  formato condensado, nunca o relatório bruto (HTML) colado — para as etapas seguintes
  reaproveitarem em vez de re-executar a suíte.
- [ ] Se a fatia tem trilha de frontend, ou gera qualquer outro artefato de build/empacotamento
  distinto do código-fonte, o comando de build/empacotamento real de produção (`docs/STACK.md`)
  também rodou e passou, registrado no mesmo arquivo de cobertura (`docs/TESTING.md`, seção
  "Build/empacotamento real como parte da suíte completa") — lint/tipo/teste unitário sozinhos não
  bastam como "suíte completa" nesse caso.
