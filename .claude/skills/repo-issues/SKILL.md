---
name: repo-issues
description: Utilitário exclusivo deste repositório (btt-sdd-pipeline) — nunca replicado no pacote do plugin. Lê as issues abertas em asengardeon/btt-sdd-pipeline, aplica as que fizerem sentido como mudança no pipeline, e abre um PR (com Closes #N) por issue aplicada, incluindo bump de versão do plugin quando a mudança tocar conteúdo empacotado. Use quando o usuário pedir para "processar issues do repositório", "aplicar as issues abertas", ou revisar o backlog de melhorias do próprio pipeline.
---

# /repo-issues

**Esta skill é manutenção deste repositório sobre si mesmo — não é uma etapa do pipeline SDD e
não é distribuída com o plugin** (`plugins/btt-sdd/`, ver "⚠️ Isto é uma cópia, não um link" em
`plugins/btt-sdd/README.md`, que lista `skills/repo-issues/` como uma segunda exceção deliberada
ao processo de sincronização, ao lado de `skills/create-project/scaffold/`). Ela só faz sentido
rodando dentro deste repositório: lê as issues do próprio `asengardeon/btt-sdd-pipeline`, decide
quais fazem sentido aplicar como mudança no pipeline (agentes, skills, docs, templates), e para
cada uma aplicada abre uma branch + PR (`docs/GIT-WORKFLOW.md`, seção "Mudanças no próprio
pipeline" — mesmo processo que qualquer outra mudança de manutenção deste repositório: sem
PRD/TRD, sem gate de QA/segurança/SRE automático, PR como mecanismo de revisão antes do merge).

## Pré-condição

`gh` autenticado com acesso de leitura/escrita a `asengardeon/btt-sdd-pipeline` (`gh auth status`).
Working directory limpo (`git status`) antes de começar — se houver mudanças não commitadas de
outra tarefa, pare e informe o usuário em vez de misturar.

## Passos

1. **Liste as issues abertas**: `gh issue list --repo asengardeon/btt-sdd-pipeline --state open
   --json number,title,body,url,labels,createdAt`. Se `args` traz um número específico de issue,
   processe só aquela; senão, todas as abertas.
2. **Leia cada issue e classifique** (sem aplicar nada ainda):
   - **Aplicável diretamente**: pedido concreto e não-ambíguo, escopo claro dentro de
     `.claude/agents/`, `.claude/skills/`, `docs/`, `specs/_template/` ou `plugins/btt-sdd/`
     (issues abertas pela retrospectiva automática de fatia — `.claude/skills/sdd-sre/SKILL.md`,
     seção "Retrospectiva da fatia" — já chegam com esse nível de detalhe, mas issues filed
     manualmente também podem qualificar).
   - **Precisa de esclarecimento**: pedido ambíguo, conflita com uma decisão de design já tomada,
     ou depende de uma escolha que só o usuário pode fazer — nunca decida sozinho (mesma regra de
     "Nenhuma suposição silenciosa" de `docs/QUALITY-GATES.md`).
   - **Não aplicável**: fora de escopo, duplicada de algo já implementado, ou o pedido não faz
     sentido para este template (agnóstico de stack, sem referenciar linguagem/framework
     específico). Não feche a issue — comente explicando por que não foi aplicada
     (`gh issue comment <N> --repo asengardeon/btt-sdd-pipeline --body "..."`) e deixe a decisão de
     fechar para o usuário.
3. **Apresente o plano de triagem ao usuário via `AskUserQuestion`** antes de tocar em qualquer
   arquivo: lista de issues "aplicável" com o resumo da mudança proposta para cada uma, lista de
   "precisa de esclarecimento" com a pergunta específica, e lista de "não aplicável" com o motivo.
   Só prossiga para o passo 4 com aprovação explícita do conjunto a aplicar — o usuário pode
   remover issues da lista ou pedir para tratar uma de forma diferente do que você propôs.
4. **Para cada issue aprovada, processe uma de cada vez** (sequencial por padrão — evita duas
   branches tocando o mesmo arquivo ao mesmo tempo; só rode em paralelo, com isolamento de working
   tree, `docs/GIT-WORKFLOW.md`, se as issues desta rodada forem claramente independentes em
   arquivos e o usuário pedir velocidade):
   a. Confirme `main`/`master` atualizada e crie a branch a partir dela, com o prefixo certo da
      tabela de `docs/GIT-WORKFLOW.md` (seção "Mudanças no próprio pipeline") — `fix/issue-<N>-
      <slug>` para correção de comportamento incorreto, `perf/issue-<N>-<slug>` para otimização de
      performance/token, `docs/issue-<N>-<slug>` para mudança só de documentação, `chore/issue-<N>-
      <slug>` nos demais casos.
   b. Aplique a mudança seguindo as convenções já estabelecidas deste repositório — inclusive
      replicando para `.claude/skills/create-project/scaffold/` e `plugins/btt-sdd/` (agentes,
      skills, scaffold) quando o conteúdo alterado tiver equivalente lá (`plugins/btt-sdd/README.md`,
      seção "⚠️ Isto é uma cópia, não um link"). Exceção: se a própria issue for sobre algo
      deliberadamente exclusivo deste repositório (como esta skill), não replique para o plugin.
   c. **Se a mudança tocou qualquer arquivo dentro de `plugins/btt-sdd/`**, incremente a versão em
      `plugins/btt-sdd/.claude-plugin/plugin.json` (patch por padrão — `1.X.Y` → `1.X.(Y+1)`; minor
      se a issue introduziu uma capacidade nova, não só um ajuste; pergunte ao usuário só se a
      escolha entre patch/minor não for óbvia) como parte do mesmo commit/PR. Se a mudança não
      tocou nada em `plugins/btt-sdd/`, não bata a versão.
   d. Commit, `git push -u origin <branch>`, e abra o PR (`gh pr create`) com `Closes #<N>` no
      corpo, resumindo o que mudou e por quê (cite a issue). **Nunca mergeie o PR você mesmo** —
      fica a critério do usuário, mesma regra de qualquer PR deste pipeline
      (`docs/GIT-WORKFLOW.md`). O fechamento da issue acontece automaticamente quando o usuário
      mergear (`Closes #N`), não antes.
   e. Volte para a branch base (`main`/`master`) antes de começar a próxima issue.
5. **Ao final, resuma ao usuário**: PRs abertos (com link e a issue que cada um fecha), issues que
   ficaram pendentes de esclarecimento (com a pergunta feita), e issues marcadas como não
   aplicáveis (com o comentário deixado). Nenhuma issue "desaparece" silenciosamente desta rodada
   sem estar numa dessas três categorias.

## Quando usar sem o agente

Esta skill não aciona nenhum subagente dedicado — você mesmo (a sessão atual) lê, classifica e
implementa, com o mesmo rigor de qualquer mudança de manutenção deste repositório.
