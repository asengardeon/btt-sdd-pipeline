# Ao encerrar, nunca `checkout` da branch base dentro do worktree isolado

Gatilho: antes de encerrar a sessão — passo 7 da Fase 2, se esta execução usa um working tree
isolado (`isolation: "worktree"` da Agent tool, ou um `git worktree add` equivalente —
`docs/GIT-WORKFLOW.md`, seção "Isolamento de working tree entre agentes concorrentes").

**Não faça `git checkout <branch base>`** dentro dele: o worktree principal do orquestrador
provavelmente já tem essa branch como `HEAD` ativo, e Git não permite a mesma branch em dois
worktrees ao mesmo tempo — tentar isso pode falhar explicitamente ou, pior, ter sucesso e
bloquear o orquestrador de voltar a essa branch até que este worktree isolado seja removido.
Nesse caso, basta permanecer na própria branch da fatia (a sessão deste agente já está
terminando) — ou, se precisar mesmo sair dela antes, use `git checkout --detach` em vez de mirar
numa branch específica.

Caso contrário (working directory compartilhado com o orquestrador, sem isolamento): confirme a
branch atual (`git branch --show-current`); se não for a branch a partir da qual a branch desta
fatia foi criada (normalmente `main`), faça `git checkout <branch base>`. Nunca deixe o working
directory compartilhado na branch da fatia depois de terminar sua trilha: um comando do
orquestrador rodado ali é executado contra a branch errada sem aviso.
