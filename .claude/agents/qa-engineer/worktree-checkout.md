# Mecânica de checkout e leitura em working tree isolado

Gatilho: toda invocação com `isolation: "worktree"` (o padrão desta invocação), antes do primeiro
`git checkout`/leitura de artefato; e ao devolver o resultado, no commit/push do `qa-report.md`.

## Antes de ler qualquer artefato ou rodar qualquer suíte

`specs/` e o código vivem só na branch até o merge — um artefato desta mesma fatia (ex.:
`code-review.md`) só existe, com conteúdo atualizado, na branch que este worktree isolado tem
checked out; o repositório principal pode estar noutra branch e uma ferramenta de leitura com
cache pode devolver uma versão desatualizada do mesmo path. Se tiver motivo para desconfiar do
conteúdo retornado, reconfirme via leitura direta de shell (`cat`/equivalente) antes de basear seu
veredito nele. Já aconteceu de verdade: uma leitura via `Read` retornou conteúdo obsoleto de
`code-review.md` porque o path usado apontava fora do worktree isolado — só percebido porque o
agente reconfirmou manualmente antes de confiar no trecho.

**Nunca faça `git checkout <branch>` diretamente — nem tente primeiro "para ver se funciona".**
Normalmente vai falhar (`fatal: '<branch>' is already used by worktree at '<caminho>'`, porque
quem abriu o PR tem essa branch como `HEAD` no worktree principal e o Git não permite a mesma
branch checked out em dois worktrees), mas **mesmo quando não falhar** (nenhum outro worktree tem
a branch aberta neste instante), isso não é seguro — é uma condição de corrida favorável, não uma
garantia: numa fatia com duas trilhas em paralelo, ou com o orquestrador tocando a branch
principal ao mesmo tempo, o mesmo `checkout` colidiria. Vá direto para a variante que sempre
funciona, incondicionalmente:

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
# ... validação, commit do artefato ...
git push origin HEAD:<branch>                       # `HEAD` não precisa *ser* <branch> para isso
```

`git checkout <branch>` direto só está correto quando você compartilha literalmente o working tree
do orquestrador. **Depois do push, registre no seu relatório que a branch local do checkout
principal ficou atrás do remoto** — quem orquestra precisa de `git pull` antes de seguir, ou de ler
o artefato direto do remoto. Detalhe em `docs/GIT-WORKFLOW.md`, seção "Isolamento de working tree
entre agentes concorrentes".

## Ao commitar o `qa-report.md`

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

O worktree principal do orquestrador provavelmente já tem essa branch como `HEAD` ativo, e Git não
permite a mesma branch em dois worktrees ao mesmo tempo — tentar isso pode falhar explicitamente
ou, pior, ter sucesso e bloquear o orquestrador de voltar a essa branch até que este worktree
isolado seja removido. Basta permanecer na própria branch da fatia (a sessão deste agente já está
terminando) — ou, se precisar mesmo sair dela antes, use `git checkout --detach` em vez de mirar
numa branch específica. Já aconteceu de verdade: agentes isolados tentando `git checkout main`
dentro do próprio worktree bloquearam repetidamente o worktree principal do orquestrador de voltar
a `main` para prosseguir com merges, exigindo remoção manual do worktree órfão a cada vez.
