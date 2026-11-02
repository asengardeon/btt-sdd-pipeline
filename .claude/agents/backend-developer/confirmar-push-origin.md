# Confirme contra `origin/<branch>`, não só que `git push` retornou sucesso

Gatilho: antes de reportar a trilha como concluída — passo 5b.

Um push bem-sucedido só garante que os commits que existiam localmente *naquele momento* foram
enviados — não protege contra um commit anterior ter sido perdido por um `fetch`+`rebase`
concorrente no meio da sessão (`docs/GIT-WORKFLOW.md`, seção "Reconciliação para a branch
compartilhada da fatia").

Depois do push final desta trilha, rode `git fetch origin <branch>` e confirme que cada arquivo
citado no seu resumo (o commit de `coverage/<fatia>-backend.md`, o código e os testes da sua
trilha, etc.) está de fato presente em `origin/<branch>` — ex.: `git diff origin/<branch> --
<arquivo>` vazio, ou `git log origin/<branch> -1 --stat` incluindo o commit esperado. Se algo
estiver faltando, refaça o commit/push antes de declarar sucesso — nunca reporte "commitado e
enviado" só porque o comando `git push` não retornou erro.
