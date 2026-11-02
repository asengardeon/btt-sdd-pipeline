# Retomar agente: nuances e riscos específicos

Gatilho: ao retomar um agente de implementação via `SendMessage` para corrigir um achado de
revisão. Complementa o núcleo (que tem a regra básica de preferir retomar a invocar de novo).

## A janela de endereçabilidade pode ser mais curta do que parece razoável supor

Já expirou em menos de 1h de wall-clock dentro da mesma sessão, preenchida só por outras duas
invocações de subagente da mesma spec (não horas, nem a sessão inteira ter encerrado). Sempre
tente `SendMessage` primeiro (é barato), mas **já formule o pedido de correção de um jeito que
funcione igualmente bem como prompt de abertura para um agente novo** — caminhos de arquivo/linha
explícitos, não referências implícitas a "o que você acabou de fazer" — assim, se a retomada
falhar, o fallback para agente novo não exige reformular o pedido do zero.

## Reaproveitar componente como referência: confira lições abertas antes

Se a instrução de correção cita um componente/padrão existente como referência de implementação
("reaproveite X", "mesmo padrão de Y") — rode `grep -i "<nome-do-componente>"
docs/LESSONS-LEARNED.md` antes de enviar a instrução. Copiar um padrão visual/estrutural sem
auditar o componente-fonte reproduz qualquer lacuna já documentada nele junto com a solução — quem
pede a correção está focado em resolver o achado atual, não em auditar o componente que está
citando como referência. Se houver lição aberta citando esse componente, inclua explicitamente na
instrução que a lacuna conhecida não deve ser copiada para o novo uso. Já aconteceu de verdade: uma
correção de UX pediu para reaproveitar um componente com padrão visual já aprovado, mas esse
componente já tinha 2 ocorrências registradas da mesma lição de acessibilidade (foco não gerenciado
ao abrir/fechar); a instrução não mencionou a lição aberta, e o fix copiou o padrão visual junto
com a lacuna — virando a 3ª ocorrência da mesma lição, só pega na reverificação da revisão
seguinte, não por nenhuma instrução (issue #464, `asengardeon/btt-sdd-pipeline`).

## Investigação de causa raiz somente-leitura prefere sub-tarefa isolada

Se decidir o que pedir na correção exige ler vários arquivos de código, histórico de Git, ou
logs — e esse conteúdo não precisa ficar retido depois de você chegar à conclusão do que pedir —
prefira delegar essa leitura a uma sub-tarefa isolada que devolva só a conclusão destilada, em vez
de investigar diretamente no seu próprio contexto de orquestrador (`docs/gates/governanca.md`,
bullet sobre investigação de causa raiz). Essa sub-tarefa é candidata típica ao **tier econômico**
(`docs/MODEL-TIERING.md`), porque você define o formato da resposta antes de invocar e confere a
conclusão contra o arquivo/linha que ela citar, sem repetir a leitura. O que **não** desce de tier
é a correção em si: quem a aplica toca código de produção via TDD, e o caminho do custo ali é
retomar o agente que já tem o contexto, não um modelo mais barato.

## Confirme sincronia com `main` antes de confiar num CI vermelho/verde

Antes de confiar num CI vermelho/verde desta fatia como definitivo, confirme que a branch ainda
está sincronizada com `main` — `git fetch origin main && git merge-base --is-ancestor origin/main
<branch-da-fatia>`; se retornar falso, sincronize primeiro (`git merge origin/main`, nunca rebase —
`docs/GIT-WORKFLOW.md`, seção "Sincronizar a branch da fatia com `main`") e só então interprete o
resultado. As quatro skills de revisão (`/sdd-code-review`/`/sdd-qa`/`/sdd-security`/`/sdd-sre`) já
têm esse gate embutido (passo 2b de cada uma), mas correção pontual conduzida diretamente aqui,
fora dessas quatro skills, não passa por ele — um hotfix mergeado em `main` durante esta correção
fica invisível até a próxima invocação de uma delas. Um CI vermelho pode ter duas causas
simultâneas (flakiness real + desincronização real); resolver a primeira não prova que a segunda
não existe (`docs/GIT-WORKFLOW.md`, mesma seção, para o caso real que motivou esta regra — issue
#525, `asengardeon/btt-sdd-pipeline`).

## Confirme a branch atual antes de qualquer `git merge`/`commit` seguinte

Depois que o agente retomado sem isolamento termina, confirme a branch atual (`git branch
--show-current`) antes de rodar qualquer `git merge`/`commit` seguinte — nunca confie só na
palavra do relatório dele. O protocolo de "sem isolamento" desse agente faz `git checkout <branch
base>` como limpeza ao final (esperado), mas isso deixa o workspace principal na branch base, não
na branch da fatia — e um `git merge --ff-only origin/<branch-da-fatia>` rodado em seguida é
sempre um fast-forward válido, só que avança a ponta da branch base em vez da branch da fatia, sem
erro nenhum (`docs/GIT-WORKFLOW.md`, seção "Isolamento de working tree", bloco "Confirme sempre o
branch atual antes de qualquer `git merge`...").
