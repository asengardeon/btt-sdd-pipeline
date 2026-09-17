---
name: repo-issues
description: Utilitário exclusivo deste repositório (btt-sdd-pipeline) — nunca replicado no pacote do plugin. Lê as issues abertas em asengardeon/btt-sdd-pipeline, aplica as que fizerem sentido como mudança no pipeline, abre um PR (com Closes #N) por issue aplicada, incluindo bump de versão do plugin quando a mudança tocar conteúdo empacotado — e, depois de aprovado o lote, mergeia cada PR e confirma o fechamento da issue associada. Use quando o usuário pedir para "processar issues do repositório", "aplicar as issues abertas", ou revisar o backlog de melhorias do próprio pipeline.
---

# /repo-issues

**Esta skill é manutenção deste repositório sobre si mesmo — não é uma etapa do pipeline SDD e
não é distribuída com o plugin** (`plugins/btt-sdd/`, ver "⚠️ Isto é uma cópia, não um link" em
`plugins/btt-sdd/README.md`, que lista `skills/repo-issues/` como exceção deliberada ao processo
de sincronização — nunca replicada no plugin, diferente de `skills/create-project/scaffold/`, que
não é mais uma cópia sincronizada e sim a única cópia que existe, lida diretamente pela raiz
deste repositório). Ela só faz sentido
rodando dentro deste repositório: lê as issues do próprio `asengardeon/btt-sdd-pipeline`, decide
quais fazem sentido aplicar como mudança no pipeline (agentes, skills, docs, templates), e para
cada uma aplicada abre uma branch + PR (`docs/GIT-WORKFLOW.md`, seção "Mudanças no próprio
pipeline" — mesmo processo que qualquer outra mudança de manutenção deste repositório: sem
PRD/TRD, sem gate de QA/segurança/SRE automático, PR como mecanismo de revisão antes do merge).

**Diferente do resto do pipeline, esta skill mergeia os próprios PRs que abre** (mesmo squash +
delete-branch já usado neste repositório) e confirma o fechamento da issue associada, em vez de
parar no PR e deixar o merge para o usuário. Essa é uma exceção deliberada e explícita à regra
geral de "merge é sempre decisão do usuário" (`docs/GIT-WORKFLOW.md`) — vale só para esta skill,
só depois da aprovação do lote no passo 3 abaixo (essa aprovação já cobre o merge, não é uma
confirmação separada por PR), e só quando o PR está de fato limpo (sem conflito, CI verde se
houver). Nunca force um merge sobre um PR que não está limpo.

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
   Deixe claro que aprovar o lote também autoriza o merge de cada PR depois de limpo (não é uma
   confirmação separada por PR — ver nota no topo deste arquivo). Só prossiga para o passo 4 com
   aprovação explícita do conjunto a aplicar — o usuário pode remover issues da lista ou pedir para
   tratar uma de forma diferente do que você propôs.
4. **Para cada issue aprovada, processe uma de cada vez, do início ao fim (branch → PR → merge →
   confirmação de fechamento) antes de começar a próxima** — nunca processe duas issues desta
   skill em paralelo, mesmo com isolamento de working tree: manter `main`/`master` sempre
   atualizada entre uma issue e a próxima evita qualquer disputa de versão no `plugin.json` entre
   branches paralelas, e é o que permite mergear cada PR sem esperar coordenação manual.
   a. Confirme `main`/`master` atualizada (`git pull`) e crie a branch a partir dela, com o prefixo
      certo da tabela de `docs/GIT-WORKFLOW.md` (seção "Mudanças no próprio pipeline") —
      `fix/issue-<N>-<slug>` para correção de comportamento incorreto, `perf/issue-<N>-<slug>` para
      otimização de performance/token, `docs/issue-<N>-<slug>` para mudança só de documentação,
      `chore/issue-<N>-<slug>` nos demais casos.
   b. Aplique a mudança seguindo as convenções já estabelecidas deste repositório — inclusive
      replicando para `plugins/btt-sdd/` (agentes, skills) quando o conteúdo alterado tiver
      equivalente lá (`plugins/btt-sdd/README.md`, seção "⚠️ Isto é uma cópia, não um link").
      **Exceção ao contrário para `skills/create-project/scaffold/`**: esse conteúdo só existe em
      `plugins/btt-sdd/skills/create-project/scaffold/` — não há cópia em
      `.claude/skills/create-project/` para replicar (mesmo `plugins/btt-sdd/README.md`), então
      uma mudança ali é editada uma vez só, direto no plugin. Exceção normal: se a própria issue
      for sobre algo deliberadamente exclusivo deste repositório (como esta skill), não replique
      para o plugin.
   c. **Se a mudança tocou qualquer arquivo dentro de `plugins/btt-sdd/`**, incremente a versão em
      `plugins/btt-sdd/.claude-plugin/plugin.json` (patch por padrão — `1.X.Y` → `1.X.(Y+1)`; minor
      se a issue introduziu uma capacidade nova, não só um ajuste; pergunte ao usuário só se a
      escolha entre patch/minor não for óbvia) como parte do mesmo commit/PR. Se a mudança não
      tocou nada em `plugins/btt-sdd/`, não bata a versão. **Se a mudança tocou especificamente
      `skills/create-project/scaffold/docs/` ou `skills/create-project/scaffold/CLAUDE.md`**,
      acrescente também uma entrada em `plugins/btt-sdd/CHANGELOG.md` no mesmo commit — é o que
      permite a projetos já scaffolded em versões antigas descobrir e aplicar essa melhoria depois
      (`docs/DOCS-SYNC.md`).
   d. Commit, `git push -u origin <branch>`, e abra o PR (`gh pr create`) com `Closes #<N>` no
      corpo, resumindo o que mudou e por quê (cite a issue).
   d2. **Garanta que a issue tem os labels que a identificam contra a implementação** — issues
      abertas manualmente (fora da retrospectiva automática do `sre`, `.claude/skills/sdd-sre/
      SKILL.md`, seção "Retrospectiva da fatia") costumam chegar sem eles (`labels: []` no JSON do
      passo 1). Antes de seguir para o passo `e`, confirme via `gh issue view <N> --repo
      asengardeon/btt-sdd-pipeline --json labels` e adicione o que faltar com `gh issue edit <N>
      --repo asengardeon/btt-sdd-pipeline --add-label <nome>` (criando o label primeiro com `gh
      label create`, mesma mecânica de `sdd-sre`, se ainda não existir no repositório):
      - **Tipo**: `melhoria` se o título/corpo descreve uma sugestão de melhoria (ou já tem o
        prefixo "Melhoria:"), `aprendizado` se descreve um padrão de comportamento observado a
        generalizar (prefixo "Aprendizado:"), `bug` (label padrão do GitHub, já existe neste
        repositório) se descreve um comportamento incorreto/quebrado. Infira pelo conteúdo real da
        issue — não pelo prefixo do título sozinho, que pode faltar em issues manuais.
      - **Origem**: `spec:<projeto>/<slug>` **só quando o corpo da issue citar claramente** um
        projeto e uma spec de origem (ex.: "ridersbnu-app/specs/0012-..."). Não invente essa
        referência quando a issue não a menciona — nesse caso, deixe a issue só com o label de
        tipo.
   d3. **Aplique os mesmos labels da issue ao PR que a fecha** — o PR também deve carregar os
      labels compatíveis (tipo + origem, se houver), não só a issue. `gh pr edit <PR> --repo
      asengardeon/btt-sdd-pipeline --add-label <nome>` para cada label confirmado no passo `d2`
      (os labels já existem nesse ponto, não precisa criar de novo). Faça isso logo após abrir o
      PR no passo `d`, antes do passo `e`.
   e. **Aguarde o PR ficar limpo para merge**: `gh pr view <PR> --repo asengardeon/btt-sdd-pipeline
      --json mergeable,mergeStateStatus`. Se este repositório tiver CI configurado, siga
      `docs/GIT-WORKFLOW.md`, seção "Aguardando CI antes do merge" (espera inicial maior, não
      checagens curtas desde o início). Se depois de checar até 3 vezes o PR ainda não estiver
      `MERGEABLE`/`CLEAN` (conflito real, CI vermelho), **não force o merge** — pare, relate o
      problema nesta issue específica ao usuário no resumo do passo 5, e siga para a próxima issue
      aprovada em vez de travar o lote inteiro.
   f. **Se a mudança usou isolamento de worktree**, remova-o antes do merge (`git worktree remove
      --force <caminho>`, sem erro se já não existir) — `--delete-branch` falha se um worktree
      ainda estiver associado à branch (`docs/GIT-WORKFLOW.md`, seção "Isolamento de working tree
      entre agentes concorrentes"). **Mergeie o PR**: `gh pr merge <PR> --repo
      asengardeon/btt-sdd-pipeline --squash --delete-branch` (mesmo padrão squash + delete-branch
      já usado neste repositório). Se essa chamada em si for **negada por uma restrição de
      permissão do harness** (ex.: "Blocked by classifier" — distinto de qualquer erro de Git/
      GitHub, e o PR já confirmado `MERGEABLE`/`CLEAN` no passo anterior), isso não é um PR
      não-limpo: peça ao usuário para rodar o comando idêntico via prefixo `!` (executa fora do
      controle desse classificador) e aguarde a resposta antes de prosseguir — não trate como
      conflito/CI vermelho nem pule para a próxima issue. O fechamento da issue (`Closes #N`)
      acontece automaticamente no merge — confirme
      (`gh issue view <N> --repo asengardeon/btt-sdd-pipeline --json state`) e, no caso raro de não
      ter fechado sozinho, feche explicitamente (`gh issue close <N> --repo
      asengardeon/btt-sdd-pipeline --comment "Fechada por #<PR>"`).
   g. Volte para a branch base (`main`/`master`) e `git pull` antes de começar a próxima issue.
5. **Ao final, resuma ao usuário**: issues fechadas nesta rodada (com o PR que cada uma mergeou),
   issues aprovadas que não puderam ser mergeadas (conflito/CI vermelho — PR continua aberto,
   nenhum merge forçado), issues que ficaram pendentes de esclarecimento (com a pergunta feita), e
   issues marcadas como não aplicáveis (com o comentário deixado). Nenhuma issue "desaparece"
   silenciosamente desta rodada sem estar numa dessas quatro categorias.

## Quando usar sem o agente

Esta skill não aciona nenhum subagente dedicado — você mesmo (a sessão atual) lê, classifica e
implementa, com o mesmo rigor de qualquer mudança de manutenção deste repositório.
