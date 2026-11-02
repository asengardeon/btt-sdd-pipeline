# Mecânica de checkout em working tree isolado

Gatilho: toda invocação com `isolation: "worktree"` (o padrão desta invocação), antes do primeiro
`git checkout`/leitura de artefato; e ao devolver o resultado, no commit/push do `ux-review.md`.

## Antes de ler qualquer artefato ou navegar qualquer fluxo

Confirme que está no commit do PR sendo revisado. Rodando em working tree isolado,
**`git checkout <branch>` vai falhar** (`fatal: '<branch>' is already used by worktree at
'<caminho>'`): quem abriu o PR normalmente tem essa branch como `HEAD` no worktree principal, e o
Git não permite a mesma branch checked out em dois worktrees. Não tente liberar a branch nem
repetir o `checkout` — vá direto para a variante que funciona:

```bash
git fetch origin <branch>
# a branch local <branch> (compartilhada entre worktrees deste repositório) pode estar na frente
# de origin/<branch> por um commit de revisão retido (push único por fatia) — baseie a temporária
# em quem estiver mais adiante, nunca assuma que é sempre a remota
if git merge-base --is-ancestor origin/<branch> <branch> 2>/dev/null; then
  git checkout -b <nome-temporário> <branch>              # local está em dia ou na frente
else
  git checkout -b <nome-temporário> origin/<branch>       # remota está na frente
fi
# ... revisão, commit do artefato ...
git push origin HEAD:<branch>                       # `HEAD` não precisa *ser* <branch> para isso
```

`git checkout <branch>` direto só está correto quando você compartilha literalmente o working tree
do orquestrador. **Depois do push, registre no seu relatório que a branch local do checkout
principal ficou atrás do remoto** — quem orquestra precisa de `git pull` antes de seguir, ou de ler
o artefato direto do remoto. Detalhe em `docs/GIT-WORKFLOW.md`, seção "Isolamento de working tree
entre agentes concorrentes".

## Ao commitar o `ux-review.md`

**Informe no seu resultado o nome da branch em que você commitou e o SHA do commit** — em working
tree isolado essa branch é a temporária do worktree, e quem te invocou precisa dos dois para
integrar na branch da fatia (`git merge --ff-only`) antes de remover o worktree. **Nunca afirme no
relatório final que o próprio worktree foi removido, ou que não precisa de integração** — essa
confirmação (e a remoção em si) é sempre do orquestrador, depois de integrar o commit na branch da
fatia. Se por algum motivo você mesmo tentar remover o worktree, confirme via `git worktree list`
que a entrada de fato não aparece mais antes de reportar sucesso — uma chamada de remoção pode
retornar sem erro (ou falhar silenciosamente, em especial no Windows, onde `git worktree remove`
pode falhar por arquivo ainda aberto e deixar a entrada de metadata num estado inconsistente) sem
o worktree ter sido de fato removido.

## Ao encerrar: nunca `checkout` da branch base dentro do worktree isolado

Mesma regra de `agents/code-reviewer.md`, passo 8: dentro de um worktree isolado, permanece na
própria branch da fatia em vez de mirar a branch base.
