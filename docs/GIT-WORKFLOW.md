# Fluxo de Git: GitHub Flow aplicado ao pipeline SDD

Este repositório usa **GitHub Flow**: `main` é a única branch de longa duração (sempre
implantável), uma branch curta por **fatia vertical de entrega** (PRD, seção "Ordem de valor /
dependências entre histórias (fatias verticais de entrega)"), PR obrigatório para voltar a
`main`. Sem `develop`, sem `release/*`.

## Regras

1. **`main` sempre implantável.** Ninguém commita direto nela — toda mudança entra via PR.
2. **Uma branch por fatia**, nunca uma para a feature inteira. `feature/<NNNN-slug>` se a
   feature tem uma única fatia; `feature/<NNNN-slug>/<fatia>` (ex.:
   `feature/0002-relatorio-mensal/f-1`) quando o TRD lista mais de uma (seção "Decomposição de
   tarefas e dependências (fatias verticais de entrega)"). Full-stack = uma única branch/PR por
   fatia (`backend-developer` em `src/`+`tests/`, `frontend-developer` em `frontend/`, árvores
   separadas evitam conflito de merge entre os dois).
3. **Fatias são sequenciais em Git**, mesmo com backend+frontend em paralelo dentro de uma
   fatia. A branch da fatia N só nasce de `main` depois que o PR da fatia N-1 estiver mergeado —
   confira com `gh pr view <PR> --json state` ou `git log main` antes de criar a branch. Se a
   fatia anterior ainda não estiver mergeada, **pare** e informe o usuário.
4. **PR aberto cedo**, em modo *draft*, no primeiro commit — não só no final (mantém o CI rodando
   continuamente e dá visibilidade do progresso). "Commita por incremento" (`backend-developer`/
   `frontend-developer`, Fase 2 — TDD red-green-refactor) é sobre **commits locais**, não sobre um
   push por commit — esses agentes já fazem só um push ao final da trilha inteira. Fora desse
   fluxo (o orquestrador, fora de um agente de trilha específico, fazendo duas ou mais mudanças
   relacionadas na mesma branch/sessão — ex.: um fix pontual e o `qa-report.md`/artefato de revisão
   que o documenta): agrupe num commit e envie (push) uma vez só, salvo motivo real de durabilidade
   incremental — cada push dispara seu próprio run de CI completo (`docs/QUALITY-GATES.md`, seção
   "SRE / CI-CD / Infra", sobre o filtro de `paths` que reduz o custo dos pushes que só tocam
   `specs/`/`docs/`, mas não elimina a necessidade de agrupar quando o push toca código).
5. **Revisão de código, QA, segurança e SRE revisam o PR de cada fatia**, não a feature inteira
   de uma vez. `code-review.md`/`qa-report.md`/`security-review.md`/`sre-review.md` são editados
   in-place a cada fatia (nunca recriados), com uma linha por fatia na seção "Histórico de
   aprovações por fatia" de cada um — histórico de fatias já mergeadas nunca é apagado.
6. **Merge só depois de code review, QA, segurança e SRE aprovados *para aquela fatia*** e CI
   verde (lint + testes + gate de cobertura 80%) naquele PR. Preferência por *squash merge* — um
   commit por fatia em `main`.
7. **`main` protegida** nas configurações do repositório GitHub (fora do controle de arquivos
   versionados — o `sre` valida isso, não configura sozinho): push direto bloqueado, PR
   obrigatório, status checks do `ci.yml` obrigatórios, sem force-push.
8. **Merge dispara CD.** `cd.yml` já dispara por `workflow_run` do CI em `main` — nenhuma mudança
   de workflow é necessária, só a branch protection acima. Cada fatia mergeada pode disparar
   deploy, o que torna a entrega incremental visível também em produção.

## Mapeamento no pipeline SDD

Com mais de uma fatia, as etapas de `/sdd-implement` a `/sdd-sre` **se repetem por fatia**:
implementa, revisa/QA/segurança/SRE, mergeia, só então a fatia seguinte começa. Nunca implementa
todas as fatias de uma vez para revisar depois.

| Etapa                  | Ação de Git                                                                 |
|-------------------------|-------------------------------------------------------------------------------|
| `/sdd-prd`, `/sdd-trd`  | Nenhuma — documentos em `specs/`, sem código/branch ainda (ficam como mudança não commitada até `/sdd-implement`, passo 2c-bis, incluí-los no primeiro commit da branch da 1ª fatia). |
| `/sdd-implement`        | Escolhe a próxima fatia pendente (TRD, seção 13); confirma merge da fatia anterior (regra 3); cria a branch, abre PR draft no primeiro commit, commita por incremento. Full-stack: backend e frontend na mesma branch, em paralelo. |
| `/sdd-code-review`      | Contra o PR desta fatia; registra em `code-review.md`, preservando o histórico das fatias anteriores; commita e envia (push) esse arquivo na mesma branch antes de devolver o resultado. |
| `/sdd-qa`               | Contra o PR desta fatia, só os critérios de aceite cobertos por ela; registra em `qa-report.md`; commita e envia (push) esse arquivo (e o de cobertura, se regravado) na mesma branch. |
| `/sdd-security`         | Contra o PR desta fatia; registra em `security-review.md`; commita e envia (push) esse arquivo na mesma branch. |
| `/sdd-sre`              | CI/CD/infra impactados por esta fatia; aprovado = PR pronto para merge; commita e envia (push) `sre-review.md` (e qualquer ajuste de infra desta rodada) na mesma branch. |
| Merge do PR             | Decisão do usuário, nunca automática. Dispara CD e libera a fatia seguinte.   |

## Revisão retroativa de um PR já mergeado

Cenário distinto de "mudança no próprio pipeline" (seção abaixo) e da regra 2 (branch por fatia):
o código de uma fatia/hotfix já foi mergeado em `main`, mas uma etapa de revisão que deveria ter
rodado antes do merge não rodou (ex.: `/sdd-hotfix` mergeou sem SRE — passo 6b da skill existe
para evitar isso, mas pode já ter acontecido antes dessa checagem existir, ou escapado por algum
outro motivo). Nem a tabela de prefixos de "Mudanças no próprio pipeline" (é sobre este
repositório, não sobre uma feature real de um projeto) nem a regra 2 (branch por fatia — não há
fatia nova aqui, não há código novo) cobrem esse caso ao pé da letra.

Para adicionar só o artefato de revisão faltante (`code-review.md`/`qa-report.md`/
`security-review.md`/`sre-review.md`), sem código novo: crie uma branch
`<prefixo-original-ou-fix>/<slug>-<etapa>-review` (reaproveite o prefixo já usado pela branch
original se ainda fizer sentido — `hotfix/`, `fix/`, `feature/` — ou `fix/` por padrão), rode a
skill de revisão correspondente contra o PR/commit já mergeado, e abra um PR próprio só com esse
artefato. Não há gate adicional de QA/segurança/SRE sobre esse PR-de-revisão em si (não há código
novo a revisar) — merge a critério do usuário, como qualquer PR de manutenção.

## Isolamento de working tree entre agentes concorrentes

`checkout`/`commit`/`push`/`reset` são operações **globais ao repositório**, não escopadas a um
diretório — dois agentes tocando pastas diferentes (`src/` vs. `frontend/`) ainda competem pelo
mesmo `HEAD`, pelo mesmo índice do Git, e pela mesma branch remota se dividirem o mesmo diretório
de trabalho. Já aconteceu de verdade: dois agentes fazendo `checkout`/`commit`/`push` no mesmo
diretório em paralelo perderam edição não commitada, um commit caiu na branch errada, e um
`reset` de um agente desfez trabalho do outro. Os agentes se recuperaram sozinhos via rebase
não-destrutivo naquela ocasião, mas isso **não é garantido** — não é uma corrida aceitável de se
repetir só porque "geralmente dá certo".

**Regra: sempre que dois agentes/tarefas puderem tocar `checkout`/`commit`/`push`/`reset` no mesmo
repositório dentro da mesma janela de tempo, cada um trabalha num working tree isolado — nunca
dividem o mesmo diretório de trabalho.** Isso vale tanto para invocação paralela deliberada (ex.:
`backend-developer` + `frontend-developer` na mesma fatia, `/sdd-implement` passo 4d) quanto para
qualquer agente de revisão fazendo sua própria verificação independente (rodar suíte de testes,
`git diff`, lint) enquanto outra tarefa desta sessão pode ainda estar ativa na mesma branch (ex.:
uma correção retomada via `SendMessage`, `.claude/skills/sdd-implement/SKILL.md`, seção
"Retomando", ainda em andamento quando uma nova rodada de revisão é disparada). Não fica a
critério do orquestrador perceber isso depois de um incidente — é decisão obrigatória antes de
disparar a segunda invocação concorrente.

**Mecanismo preferido — Agent tool do Claude Code**: ao invocar um agente cuja execução pode
sobrepor outra tarefa no mesmo repositório, passe `isolation: "worktree"` na chamada da Agent
tool — o harness cria um worktree temporário isolado (diretório + branch próprios) para aquele
agente, eliminando a disputa de `HEAD`/índice com qualquer outra tarefa ativa.

**Mecanismo equivalente manual** (Agent tool sem essa opção, ou um agente seguindo sua própria
definição `.md` diretamente fora do harness): crie um worktree próprio antes de começar a
trabalhar, num diretório separado do worktree principal —

```bash
git worktree add <caminho-separado> -b <branch-temporária-do-agente> <branch-da-fatia-ou-base>
# ... trabalhe e commite normalmente dentro de <caminho-separado> ...
git worktree remove <caminho-separado>   # ao terminar — nunca deixe worktree órfão
```

**Reaproveite o cache de dependências entre worktrees do mesmo repositório.** Isolamento de
working tree separa árvore de arquivos e estado de Git — não precisa (e não deve) forçar
reinstalação de dependências do zero a cada worktree novo. Aponte a instalação de dependências
desta stack para um diretório de cache compartilhado entre worktrees do mesmo repositório (o
equivalente, na stack do projeto, a um cache de pacotes/módulos reaproveitável — a maioria dos
gerenciadores de dependências já suporta isso nativamente via variável de ambiente ou flag de
cache global; o que estiver documentado em `docs/STACK.md` deste projeto), em vez do padrão de
instalar tudo isolado dentro de cada worktree novo. Se outro agente já resolveu as dependências
deste repositório há pouco, um worktree novo deve conseguir reaproveitar esse cache quase
instantaneamente em vez de reinstalar tudo do zero — isolamento é sobre arquivos de código e
estado de Git, nunca precisa se estender ao cache de dependências.

**Isolamento de arquivos não é isolamento de serviços com estado.** `git worktree` separa árvore
de arquivos e estado de Git — não separa serviços com estado compartilhados no host, como um banco
de dados de teste ou um emulador de nuvem local (LocalStack, floci) reaproveitado entre worktrees.
Já aconteceu de verdade: dois agentes rodando suíte de teste de integração em paralelo, cada um no
seu próprio worktree, contra o **mesmo** banco Postgres de teste — um deles rodou uma migração
destrutiva (`migrate:fresh`, que dropa e recria todo o schema) enquanto o outro ainda lia esse
schema, produzindo erros espúrios de "coluna/tabela não existe" que pareciam bug de produto e só
foram identificados como corrupção cruzada depois de investigação adicional (comparando o schema
via `\d <tabela>` entre tentativas). Sempre que mais de um agente/worktree puder rodar testes de
integração contra um serviço com estado na mesma janela de tempo, cada execução usa uma
instância/banco/schema isolado — ex.: nome de banco derivado do worktree ou da branch
(`<projeto>_test_<id-do-worktree>`), ou um container efêmero por execução — nunca um único serviço
compartilhado reaproveitado por agentes concorrentes. O mecanismo exato (nome de schema, container
por execução, etc.) é decisão de `docs/STACK.md` deste projeto, não hardcoded neste template — mas
não fica esperando alguém perceber a lacuna depois de uma contenção real: o `architect`
(`.claude/agents/architect.md`) decide e registra essa decisão explicitamente assim que a stack de
um projeto passa a usar um serviço com estado em testes de integração, no mesmo `/sdd-trd` que
decide a stack.

**Isolamento resolve a corrida de Git — não substitui dependência lógica entre etapas.** Com
isolamento garantido (mecanismo acima), duas tarefas que não dependem do resultado uma da outra
podem — e devem, por padrão — ser invocadas em paralelo, sem a cautela de serializar tudo "por via
das dúvidas" que fazia sentido antes do isolamento existir. O caso mais comum no pipeline é a
trilha de backend e a trilha de frontend de uma fatia full-stack, quando o contrato entre elas já
está totalmente especificado no TRD (`/sdd-implement`, passo 4d) — o frontend não precisa esperar
o backend terminar, desde que trabalhe contra um dublê do contrato até o endpoint existir de
verdade. Isso **não** se aplica a etapas com dependência real de aprovação — revisão de código →
QA → segurança → SRE continuam estritamente sequenciais independente de isolamento (cada uma exige
o veredito aprovado da anterior como pré-condição, `docs/SDD-WORKFLOW.md`); isolamento nunca é
motivo para pular essa pré-condição, só elimina o risco de corrida quando duas tarefas *sem* essa
dependência de fato rodam ao mesmo tempo.

**Reconciliação para a branch compartilhada da fatia.** Como o design deste pipeline é uma única
branch/PR por fatia (regra 2 acima), o trabalho feito num worktree isolado ainda precisa chegar
nessa branch compartilhada. Antes de cada `push` para ela, sincronize primeiro — nunca assuma que
é o único a mexer na branch remota:

```bash
git fetch origin <branch-da-fatia>
git rebase origin/<branch-da-fatia>
git push origin HEAD:<branch-da-fatia>
```

Se o `push` for rejeitado (non-fast-forward, sinal de que outro agente publicou nesse intervalo),
repita `fetch` + `rebase` — mesmo limite de 3 tentativas de `docs/QUALITY-GATES.md` antes de parar
e escalar ao usuário. Essa sincronização é o que garante que múltiplos agentes isolados ainda
produzem uma única branch/PR coerente por fatia, sem que a isolação de working tree vire duas
branches divergentes por engano.

**Se `git checkout <branch-da-fatia>` falhar dentro do worktree isolado** (`fatal: '<branch>' is
already used by worktree at '<caminho>'` — o mecanismo de `isolation: "worktree"` cria um worktree
com uma branch própria do agente, não a branch da fatia, e um worktree concorrente — principal ou
de outro agente — pode já ter `<branch-da-fatia>` como `HEAD`), não tente liberar a branch: crie
uma branch local temporária rastreando `origin/<branch-da-fatia>` (`git checkout -b
<nome-temporário> origin/<branch-da-fatia>`), trabalhe nela normalmente (ler artefatos, rodar
suíte, editar), e ao final use o mesmo `git push origin HEAD:<branch-da-fatia>` da sincronização
acima — não é preciso que `HEAD` literalmente *seja* `<branch-da-fatia>` para isso funcionar. Já
aconteceu de 3 agentes de revisão em sequência baterem nesse mesmo erro e cada um re-derivar essa
mesma solução de forma independente, em vez de segui-la já documentada.

**Antes de rebasear/forçar push manualmente sobre uma branch que múltiplos agentes concorrentes já
tocaram** (qualquer branch de fatia que já passou por 2+ rodadas de revisão, cada uma em worktree
separado) — risco maior que o da sincronização de rotina acima, porque aqui é o orquestrador
resolvendo um conflito manualmente, muitas vezes reaproveitando um worktree já existente. Já
aconteceu de verdade: um `git rebase origin/main` seguido de `git push --force-with-lease` teve
sucesso **silencioso** rodando num worktree desatualizado (de uma rodada de revisão anterior, nunca
atualizado com os commits que outros agentes enviaram — *push* — depois, cada um em seu próprio
worktree) —
descartando dois commits já revisados e aprovados, sem nenhum erro visível, só descoberto numa
auditoria bem posterior. `--force-with-lease` só protege contra o estado do `origin` que aquele
worktree tinha em cache no último `fetch` — não contra o estado real mais recente do remote se esse
fetch estiver atrasado. Sempre, antes de rebasear manualmente uma branch nessas condições:

1. `git fetch origin <branch-da-fatia>` primeiro, no worktree que vai fazer a operação.
2. Confirme `git rev-parse HEAD` == `git rev-parse origin/<branch-da-fatia>` **antes** de começar a
   rebasear — se forem diferentes, esse worktree está desatualizado: descarte-o (ou resete o branch
   local para `origin/<branch-da-fatia>`) antes de prosseguir. Nunca rebaseie um estado local que
   pode já estar atrás de commits pushados por outro agente.
3. Depois do rebase e antes do push (`--force-with-lease` ou normal), compare a lista de commits da
   branch antes (`git log origin/<branch-da-fatia>..HEAD` do estado pré-rebase) com a de depois —
   confirme que nenhum commit da branch original desapareceu. Não basta confirmar que o conflito foi
   resolvido; confirme também que nada foi perdido no processo.

**Resolvendo conflitos de merge nos arquivos de artefato de revisão
(`code-review.md`/`qa-report.md`/`security-review.md`/`sre-review.md`).** Fatias/PRs paralelos da
mesma spec costumam tocar os mesmos arquivos de artefato ao rebasear sobre `main`/sobre uma fatia
irmã já mergeada. O conflito **não é um simples "duas edições no mesmo lugar"**: cada rodada de
revisão escreve seu próprio bloco de cabeçalho (`## 1. Veredito geral` com sub-seções `###
Rodada mais recente` + `### Histórico —` por dentro), e os dois lados do merge reescrevem esse
mesmo bloco de formas incompatíveis. Resolver isso como texto bruto (aceitar "os dois lados" com
`sed`/remoção ingênua dos marcadores de conflito) produz cabeçalhos `##` duplicados, fragmentos
órfãos de linha cortada, e `###` colado sem linha em branco antes — quebrando a estrutura Markdown
do documento. Ao resolver um conflito nesses arquivos:

1. Combine o cabeçalho (`> PR (...)`/`> Escopo da rodada mais recente`/`> Data:`) unindo as duas
   listas — nunca escolha um lado e descarte o outro.
2. Trate cada seção numerada (`## N. ...`) que aparece duplicada como **a mesma seção, com uma
   sub-seção `###` nova por rodada** — ambos os lados adicionam, nenhum remove uma sub-seção já
   existente do lado oposto.
3. **Reordene** as sub-seções por data real da rodada, não pela ordem que o merge trouxe: a
   cronologicamente mais recente vira `### Rodada mais recente —`, qualquer rodada anterior (mesmo
   já mergeada) vira `### Histórico —`. Simplesmente concatenar na ordem do merge deixa o rótulo
   "mais recente" em uma rodada que não é.
4. Confirme, antes de commitar a resolução: nenhum `## N.` duplicado sobrou (virou uma única seção
   com múltiplas `###` por dentro); nenhum `###`/`##` ficou colado ao parágrafo anterior sem linha
   em branco; nenhum fragmento de linha (ex.: uma `> Data:` cortada no meio) ficou órfão entre duas
   seções.

Documentar isso não é opcional a cada ocorrência: sem esse checklist, cada resolução de conflito
nesses arquivos exige reconstruir esse raciocínio do zero, seção por seção, várias vezes na mesma
sessão sempre que mais de uma fatia/PR da mesma spec rebaseia em sequência.

**Conflito de rebase real em código de produção — fatia vs. hotfix concorrente.** A checagem de
drift de `main` antes de cada etapa de revisão (`git rev-list --count HEAD..origin/main` + rebase)
normalmente resolve como fast-forward limpo. Mas quando um hotfix de outra spec (sem relação de
escopo com esta fatia) já foi mergeado em `main` tocando o mesmo arquivo de produção que esta fatia
edita, o rebase pode gerar um **conflito de merge real** — situação distinta da anterior (conflito
em `code-review.md`/`qa-report.md`/etc.) porque aqui o conflito está em código/lógica de
comportamento, não em prosa de relatório. Já aconteceu de verdade: um hotfix de outra spec mergeado
em `main` no meio da implementação de uma fatia tocou o mesmo arquivo, exigindo do orquestrador
resolver o conflito manualmente duas vezes (uma vez após o merge do hotfix, outra antes do code
review), incluindo ler o arquivo inteiro por leitura direta para confirmar que as duas mudanças não
compartilhavam estado — trabalho de reconciliação sem TDD por trás, diferente do rigor normal de
quem implementa a fatia.

Quem resolve depende da natureza do conflito:
- **Conflito mecânico trivial** (import reordenado, formatação, marcador de conflito em torno de
  uma linha que não muda semântica) — o orquestrador resolve diretamente, sem reacionar nenhum
  agente.
- **Conflito que toca lógica de comportamento sobreposta** (as duas mudanças alteram o mesmo
  trecho funcional, mesmo que sirvam propósitos diferentes) — o orquestrador **não** edita código
  de produção diretamente para resolver. Reacione o `backend-developer`/`frontend-developer`
  responsável por esta fatia (via `SendMessage`, mesmo padrão de "retomar para corrigir achados",
  `.claude/skills/sdd-implement/SKILL.md`) para refazer a resolução com TDD — ajustando/adicionando
  teste que cubra o comportamento combinado das duas mudanças, não só editando o código de produção
  para fazer os dois lados coexistirem.

Isso não substitui a checagem de drift já existente antes de cada etapa de revisão — só cobre o
caso em que essa checagem encontra um conflito de merge real, não um fast-forward limpo.

**Operando diretamente sobre uma branch que um worktree isolado ainda segura.** Quando o
orquestrador (não um agente novo) precisa tocar diretamente uma branch de fatia que um subagente
com `isolation: "worktree"` tocou por último — ex.: para resolver um conflito de rebase
manualmente — um `git checkout <branch-da-fatia>` no worktree principal pode falhar com `fatal:
'<branch>' is already used by worktree at '<caminho>'`, mesmo que o agente já tenha terminado e
relatado ter "devolvido" seu working directory. Isso já aconteceu de verdade: o agente relatou ter
devolvido, mas voltou para uma branch de estacionamento própria do worktree, não a branch da fatia
— porque `main` e a branch da fatia já estavam ocupadas por outros worktrees concorrentes no
momento em que ele tentou voltar, então a branch da fatia continuou presa àquele worktree.

Antes de assumir que o `checkout` vai funcionar no worktree principal, rode `git worktree list`
para descobrir se algum worktree isolado ainda segura aquela branch. Se sim, opere diretamente no
diretório desse worktree (`cd`/caminho absoluto nos comandos seguintes) em vez de tentar liberá-la
no worktree principal.

**Limpe o worktree antes de apagar a branch associada.** Se um worktree isolado da fatia (criado
pelo mecanismo acima, ou reaproveitado por agentes de revisão subsequentes na mesma fatia — QA,
segurança, SRE reusando o worktree que o `backend-developer`/`frontend-developer` já tinha criado)
ainda existir no momento do merge, `git branch -d`/`gh pr merge --delete-branch` falha (`git`
recusa apagar uma branch em uso por um worktree). Isso já aconteceu de verdade: um worktree
reaproveitado por várias rodadas de revisão da mesma fatia nunca foi removido por nenhuma delas —
cada agente assumia que não era "dono" do worktree, já que não foi quem o criou — bloqueando a
exclusão da branch depois do merge, com um erro só descoberto na hora (`error: cannot delete
branch '...' used by worktree at '...'`). Antes de tentar `gh pr merge --delete-branch` (ou
qualquer exclusão de branch) para uma fatia que usou isolamento de worktree, remova o worktree
primeiro — `git worktree remove --force <caminho>` (sem erro se ele já não existir mais) — como
parte padrão do fluxo de merge, sem depender de nenhum agente individual ter lembrado de limpar ao
terminar sua própria etapa.

## Aguardando CI antes do merge

Quem aguarda o CI (`ci.yml`) terminar antes de confirmar que um PR está pronto para merge (regra
6 acima) não precisa checar o status a cada poucos segundos desde o início — a maioria dos
workflows de CI leva um tempo mínimo perceptível só para começar a rodar (fila do runner,
checkout, setup do ambiente) antes de produzir qualquer sinal novo. Prefira uma primeira espera
mais longa antes da primeira checagem de status, em vez de várias checagens curtas logo no
início — o valor exato dessa espera fica a critério de quem aplica esta instrução (varia por
projeto e provedor de CI), não é hardcoded neste template. Depois da primeira checagem, ajuste o
intervalo das checagens seguintes pelo que já se observou (workflow ainda na fila vs. já rodando),
em vez de manter o mesmo intervalo curto do início até o fim.

**Prefira o `--jq` embutido do `gh` a depender de um binário `jq` externo.** Ao extrair campos de
`gh pr checks`/`gh run view`/etc. para decidir quando parar de esperar (ex.:
`gh pr checks <PR> --json name,bucket --jq 'all(.bucket != "pending")'`), use a flag `--jq`
embutida do próprio `gh` (lib Go interna) em vez de fazer *pipe* para um binário `jq` externo
(`gh ... --json ... | jq '...'`). `jq` não vem instalado por padrão em vários ambientes (Windows/
Git-Bash é um caso comum) — quando ausente, o `pipe` falha silenciosamente (erro vai para stderr,
sem sinal visível), a condição de parada do loop nunca vira verdadeira, e o script só dorme até o
timeout achando que "o CI está demorando" quando na verdade é a própria ferramenta de checagem que
está quebrada — um desperdício de tempo/tokens investigando o lugar errado.

**Timeout de job de CI sob alta concorrência do próprio pipeline é um falso-negativo conhecido.**
Quando `/sdd-implement` (ou o orquestrador de uma sessão) dispara múltiplas fatias/PRs em paralelo
no mesmo projeto, os runners/rede do provedor de CI ficam sob contenção real — passos normalmente
rápidos (`npm ci`, `npm audit`, instalação de dependências em geral) podem levar bem mais tempo que
o observado isoladamente, estourando `timeout-minutes` do job sem nenhum teste vermelho. Já
aconteceu de verdade: um job cancelado só por timeout, sob 3+ branches rodando CI ao mesmo tempo
pela mesma sessão, sem nenhum defeito de código — confirmado comparando com um run de CI
concorrente da mesma janela. Antes de investigar isso como bug de código, tente `gh run rerun
--failed` uma vez — se o rerun passar limpo sem qualquer mudança de código, a causa era contenção
de CI, não a feature. Só escale como achado bloqueante se o rerun também falhar, ou se falhar com
teste vermelho (não só timeout).

## Por que `/sdd-amend` não reescreve histórico

Uma emenda a um artefato já aprovado (`/sdd-amend`, ver `docs/SDD-WORKFLOW.md`) nunca reescreve
commits já feitos numa branch — adiciona um novo commit registrando a mudança. O "Log de
revisões" do artefato é o registro de *por que* mudou; o git log é o registro de *quando*.

## Mudanças no próprio pipeline (agentes, skills, docs, templates)

A regra 1 (`main` sempre implantável, ninguém commita direto nela) **vale para qualquer mudança
neste repositório, não só para features rastreadas em `specs/`** — inclusive edições em
`.claude/agents/`, `.claude/skills/`, `plugins/btt-sdd/`, `docs/` ou `specs/_template/` feitas
por uma sessão do Claude Code mantendo o próprio pipeline. Esse tipo de mudança não tem PRD/TRD
nem fatia (não é uma feature de produto), então usa uma branch simples em vez do padrão
`feature/<NNNN-slug>/<fatia>`:

1. **Confirme que existe uma issue do GitHub descrevendo o porquê desta mudança antes de criar a
   branch.** Mesma exigência já aplicada a `/sdd-hotfix` (`docs/QUALITY-GATES.md`, seção
   "Implementação" — "a issue do bug/ajuste existe antes da branch ser criada"), estendida a
   qualquer mudança no próprio pipeline: o diff mostra *o quê* mudou, mas só a issue registra *por
   quê* — histórico de revisão sem isso vira uma sequência de commits sem contexto recuperável
   meses depois. Se a mudança já nasceu de uma issue existente (ex.: `/repo-issues`, ou um pedido
   do usuário que você já registrou como issue via `docs/QUALITY-GATES.md`, seção "Todo feedback
   real sobre o próprio plugin vira issue"), reaproveite-a. Se não existir nenhuma, crie uma
   (`gh issue create --repo asengardeon/btt-sdd-pipeline --title "..." --body "..."`) antes de
   prosseguir — nunca abra a branch/PR primeiro e a issue depois, como formalidade retroativa.
2. Crie uma branch a partir de `main` atualizada, com o prefixo que descreve a natureza da
   mudança — mesma taxonomia dos tipos de commit já usados no histórico deste repositório
   (`feat:`, `fix:`, `chore:`, `perf:`, etc.):

   | Prefixo         | Quando usar                                                              |
   |------------------|---------------------------------------------------------------------------|
   | `feature/<NNNN-slug>/<fatia>` | Feature de produto rastreada em `specs/` (regra 2 acima) — não usar para mudanças no próprio pipeline. |
   | `fix/<slug>`     | Correção de bug (código, comportamento do pipeline, ou conteúdo incorreto) sem urgência de produção. |
   | `hotfix/<slug>`  | Correção urgente de algo já em produção/`main` quebrado — mesmo fluxo de PR, só não espera o próximo ciclo normal. |
   | `chore/<slug>`   | Manutenção do pipeline/tooling que não é bug nem doc pura (ex.: renomear skills, reorganizar arquivos). |
   | `docs/<slug>`    | Mudança só de documentação, sem código.                                  |
   | `refactor/<slug>`| Refatoração sem mudança de comportamento observável.                     |
   | `perf/<slug>`    | Otimização de performance ou custo (ex.: redução de tokens consumidos por um agente). |
   | `test/<slug>`    | Mudança só em testes.                                                    |
   | `ci/<slug>`      | Mudança em pipelines de CI/CD (`.github/workflows/`).                    |

   `<slug>` é um nome curto em kebab-case descrevendo a mudança (ex.: `chore/reduz-tokens-agentes`).
3. Commite nessa branch, abra o PR **referenciando `Closes #N` da issue confirmada/criada no passo
   1**, e só mergeie em `main` com decisão explícita do usuário — as mesmas regras 1, 4, 6 e 7
   acima se aplicam (PR obrigatório, sem push direto, sem force-push). Não há gate de QA/segurança/
   SRE automático para esse tipo de mudança (não é uma feature de produto), mas o PR ainda é o
   mecanismo de revisão antes do merge. **Se a mudança tocar algum arquivo de
   `skills/create-project/scaffold/docs/` ou `skills/create-project/scaffold/CLAUDE.md` deste
   plugin**, acrescente também uma entrada em `plugins/btt-sdd/CHANGELOG.md` no mesmo commit/PR —
   é o que permite a projetos já scaffolded em versões antigas descobrir e aplicar essa melhoria
   depois (`docs/DOCS-SYNC.md`).

## Exceção histórica

O commit inicial deste template (estrutura, agentes, skills, docs e a feature de exemplo) foi
feito diretamente em `main`, antes desta política existir. A partir daí, toda mudança segue
GitHub Flow normalmente — inclusive as mudanças no próprio pipeline descritas acima.
