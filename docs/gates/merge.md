# Merge para `main` (por fatia)

> Parte de `docs/QUALITY-GATES.md` (índice). Gate crítico: o que está marcado aqui
> **bloqueia mesmo** — não é sugestão, é a definição do que "pronto" significa.

- [ ] PR desta fatia aberto, CI verde, revisão de código aprovada, revisão de UX aprovada (ou
  marcada "não aplicável" quando a fatia não tem superfície de UI), QA aprovado, segurança
  aprovada, SRE aprovado (ou aprovado com ressalvas não-bloqueantes explicitamente aceitas pelo
  usuário em qualquer uma dessas etapas) — tudo escopado a esta fatia, não à feature inteira.
- [ ] **Depois do merge, todas as issues da fatia foram confirmadas fechadas** (`gh pr view <PR>
  --json closingIssuesReferences`), e as que não fecharam sozinhas foram fechadas à mão citando o
  PR. Não basta o corpo do PR *parecer* correto: `Closes #A, #B, #C` fecha só a primeira em
  silêncio — a forma válida repete a palavra-chave (`docs/GIT-WORKFLOW.md`, regras 5b e 5c).
- [ ] Se houver fatia seguinte pendente na feature, ela só começa depois deste merge
  (`docs/GIT-WORKFLOW.md`).
- [ ] Nenhum item "VALIDAR DEPOIS" bloqueante (marcado como tal pelo usuário) segue em aberto.
- [ ] **Retrospectiva da fatia conduzida — em toda fatia aprovada, não só a última.** `/sdd-sre`
  (`.claude/skills/sdd-sre/SKILL.md`, passo 5c) avalia a execução da rodada e abre issues de
  melhoria/aprendizado em `asengardeon/btt-sdd-pipeline` **antes** de informar o resultado ao
  usuário (passo 6) — nunca depois, e nunca pulado só porque a fatia já foi aprovada. "Nenhuma
  sugestão/aprendizado concreto desta fatia" é uma conclusão válida do passo; "não avaliei" não é.
- [ ] Se esta é a **última fatia pendente** da feature (spec finalizada): `tech-writer` foi
  acionado para atualizar a documentação (`/sdd-sre`, passo 5b) **e** o teste geral obrigatório de
  fim de spec contra produção real foi conduzido depois do merge
  (`docs/POST-MERGE-VALIDATION.md`, seção "Teste geral obrigatório ao finalizar uma spec") — a
  spec só é considerada de fato concluída com os dois.
