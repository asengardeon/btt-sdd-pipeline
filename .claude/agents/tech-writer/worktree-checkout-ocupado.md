# Checkout de branch de fatia já ocupada por outro worktree

Gatilho: ao atualizar documentação como parte da retrospectiva de uma fatia (`/sdd-sre`, passo
5b), você normalmente precisa de `checkout` na branch da fatia para ler/commitar diretamente
nela. Se isso falhar (`fatal: '<branch>' is already used by worktree at '<caminho>'` — outro
worktree, principal ou de um agente concorrente, já tem essa branch como `HEAD`), **não fique
bloqueado esperando decidir como proceder**.

Siga o mesmo mecanismo já documentado para `backend-developer`/`frontend-developer`
(`docs/GIT-WORKFLOW.md`, seção "Isolamento de working tree entre agentes concorrentes", parágrafo
"Se `git checkout <branch-da-fatia>` falhar..."): crie uma branch local temporária rastreando
`origin/<branch-da-fatia>` (`git checkout -b <nome-temporário> origin/<branch-da-fatia>`), trabalhe
nela normalmente, e ao final sincronize de volta com `git fetch origin <branch-da-fatia>` + `git
rebase origin/<branch-da-fatia>` + `git push origin HEAD:<branch-da-fatia>` (mesma seção). Não é
preciso que `HEAD` literalmente seja `<branch-da-fatia>` para isso funcionar — já aconteceu de
você (`tech-writer`) ficar preso >40 minutos sem progresso nesse exato obstáculo por não ter essa
orientação disponível.
