# Preâmbulo dos agentes do pipeline

Todo agente deste pipeline (`architect`, `backend-developer`, `code-reviewer`, `qa-engineer`,
`security-engineer`, `sre`, `ux-designer`, `product-design`, `codebase-archaeologist`,
`frontend-developer`, `tech-writer`) lê este arquivo antes de começar. Ele existe porque o que
está aqui valia para todos e estava copiado dentro de cada um — e a cópia já divergiu sozinha
pelo menos uma vez (`docs/FILE-GUIDE.md`, sobre este arquivo).

Nada aqui substitui os gates: cada agente declara no próprio arquivo os 2-5 arquivos de
`docs/gates/` que valem para a etapa dele.

## Como este agente está organizado: núcleo + detalhe sob demanda

Se o seu próprio arquivo (`.claude/agents/<seu-nome>.md`) tiver uma seção "Índice de regras sob
demanda", ela lista arquivos-filho (`.claude/agents/<seu-nome>/<topico>.md`) com um gatilho
objetivo cada. **Leia um arquivo-filho só quando a tarefa atual bater no gatilho descrito** — nunca
pré-carregue todos "por garantia": isso anula o ganho de ter um núcleo pequeno. Detalhe completo da
convenção em `docs/MICRO-CONTEXT.md`, seção 1. Nem todo agente já foi migrado para este formato —
ausência da seção "Índice de regras sob demanda" significa que este agente ainda carrega tudo
inline, não é um erro.

## Onde ficam os docs de governança citados nos arquivos deste pipeline

Referências como `docs/GIT-WORKFLOW.md`, `docs/QUALITY-GATES.md`, `docs/gates/*.md`,
`docs/TESTING.md`, `docs/ENGINEERING-PILLARS.md`, `docs/ARCHITECTURE.md`, `docs/SDD-WORKFLOW.md`,
`docs/FILE-GUIDE.md`, `docs/POST-MERGE-VALIDATION.md` `docs/MODEL-TIERING.md`,
`docs/MICRO-CONTEXT.md`, `docs/WRITING-STYLE.md` e `docs/TOOLING.md` apontam para os docs
genéricos deste pipeline — **não
são copiados para dentro de cada projeto que o usa**. Eles vivem junto da distribuição do próprio
pipeline: se você
foi carregado via junction global (`.claude/agents/<seu-nome>.md` apontando para este repositório,
`CLAUDE.md`, seção "Distribuição global"), esses docs estão em `docs/` na raiz **deste mesmo
repositório** — não necessariamente no projeto onde você está trabalhando agora. Se o projeto
atual também tiver um `docs/<nome>.md` próprio (`STACK.md`, `DESIGN-SYSTEM.md`, `BASELINE.md`,
`LESSONS-LEARNED.md`, `GLOSSARY.md`, `DOCS-MAP.md`, `FEATURES.md`, `adr/`), esse é conteúdo do
projeto, não deste pipeline — não
confunda os dois. Se não conseguir determinar de onde você foi carregado, pergunte a quem te
invocou.

**Se você foi carregado via plugin instalado (não via junction), resolva o caminho da instalação
por uma fonte determinística — nunca por tentativa de adivinhação no filesystem (`ls` em caminhos
inventados, navegação pelo diretório pai).** A fonte de verdade é
`~/.claude/plugins/installed_plugins.json` (`%USERPROFILE%\.claude\plugins\installed_plugins.json`
no Windows): o campo `plugins["btt-sdd@btt-sdd-pipeline"][].installPath` tem o caminho exato e
atual da instalação (ex.: `...\.claude\plugins\cache\btt-sdd-pipeline\btt-sdd\<versão>`) — leia-o
como primeiro passo, não como último recurso depois de tentativas falhas: um caminho inventado
pode levar a listar o diretório pai inteiro — revelando outros repositórios não relacionados no
mesmo host — antes de alguém consultar o arquivo que resolvia a pergunta de forma exata desde o
início (issue #616).

## Se você recebeu um worktree isolado, sincronize antes de ler qualquer código

Worktree isolado reaproveitado nasce na base da invocação anterior, não na ponta da branch. Rode
`git fetch` e compare com `origin/<branch>` antes de qualquer leitura ou trabalho. O passo a passo
e o porquê estão em `docs/GIT-WORKFLOW.md`, seção "Isolamento de working tree entre agentes
concorrentes".

## Se for retomado via `SendMessage` e instruído a registrar sua própria linha em `timing-log.md`

Escreva só a descrição do que fez nesta rodada — nunca um valor de duração. Medir a duração é
responsabilidade exclusiva de quem te invocou (o orquestrador da skill), porque só ele vê a
notificação de conclusão da sua invocação anterior e consegue calcular a diferença contra o
horário anotado antes do `SendMessage` (`specs/_template/timing-log.template.md`, seção "O que a
coluna 'Duração' mede"). Você, retomado, não tem acesso a essa notificação anterior — qualquer
número que você escrever ali é inventado, não medido, mesmo que pareça plausível (issue #611).

## `docs/PROJECT-CONVENTIONS.md`: leia antes de começar, se existir

É o canal pelo qual cada projeto registra como particulariza este pipeline — modelo de workflow de
Git, estrutura de pastas, nomenclatura, gate de cobertura próprio, etapas que aquele projeto não
roda. Trate cada entrada relevante à sua etapa como **restrição que se sobrepõe ao padrão
genérico** do pipeline, exatamente como você já trata `docs/LESSONS-LEARNED.md`. Onde uma convenção
do projeto conflita com uma instrução genérica sua, a convenção do projeto vence — e você registra
isso no seu artefato citando o arquivo ("fora do escopo por `docs/PROJECT-CONVENTIONS.md`"), nunca
"por instrução do usuário nesta rodada": a segunda forma é a marca de uma regra que chegou por
prompt, que não é auditável e não sobrevive à invocação seguinte. Ausência do arquivo é normal e
não é um problema — significa que o projeto segue o padrão genérico. Limite: uma convenção de
projeto **não** desliga um gate crítico de `docs/gates/governanca.md` (ex.: dispensar revisão de
segurança, baixar cobertura mínima sem decisão registrada); se parecer que é o caso, pergunte em
vez de aplicar.

**Antes de nomear uma convenção deste projeto pelo nome num artefato de revisão ("este projeto usa
a cadência X"), `grep` a linha exata de `docs/PROJECT-CONVENTIONS.md` que a registra — nunca
assuma que ela existe porque uma rodada anterior da mesma spec já a nomeou daquele jeito.** Ao
explicar por que um comportamento observado aconteceu (ex.: um passo caro de CI ficou `skipped`),
cite o mecanismo real pelo nome do job/step (`gh api .../jobs` ou equivalente) **e**, só se for
atribuí-lo a uma convenção nomeada do projeto, cite a linha exata que a registra. Um nome de
convenção pode se propagar entre rodadas mesmo sem nunca ter existido no arquivo: a primeira rodada
descreve o mecanismo real em prosa, e cada rodada seguinte cita o nome herdado da anterior sem
conferir a fonte primária, porque "o comportamento observado bate" faz a citação parecer verificada
(issue #499).

**Antes de repetir "mecanismo X já existe desde a spec Y, inalterado" para evitar reverificação
redundante, confirme se alguma migração de stack/framework/linguagem aconteceu desde a spec Y**
(`grep` em `docs/adr/` por ADRs de migração/reescrita). Citar um mecanismo como "já existente e
inalterado" é uma economia de tempo/contexto geralmente correta — mas só é segura quando nada
mudou estruturalmente desde a spec que o introduziu, e uma migração de stack é justamente o tipo
de evento que invalida essa premissa. Se houver migração desde Y, a citação exige reverificação
por leitura direta do código atual antes de ser repetida — nunca repetição verbatim da rodada
anterior. Um mecanismo pode deixar de existir numa migração de stack sem que ninguém note: rodadas
de SRE sucessivas, em specs diferentes já na stack nova, podem repetir que ele "já existia,
inalterado" — cada vez com descrição mais específica que a anterior, mas sem nenhuma verificar
contra o código real pós-migração — até que uma delas finalmente confirme por leitura direta que o
mecanismo nunca existiu na stack nova (issue #527).

**Ao citar um artefato de investigação como base de uma ressalva, verifique a marcação
`[medido]`/`[inferido]` da frase que você está usando** (`agents/architect/contrato-externo-nao-
observado.md`). Uma
ressalva apoiada em `[inferido]` declara isso — e, quando a medição for barata e o ambiente
estiver à mão, propor medi-la sai mais barato que carregar a ressalva por três fatias.

## Artefato de revisão que acumulou rodadas: leia a vigente e a penúltima, não todas

Os artefatos de revisão (`code-review.md`, `ux-review.md`, `qa-report.md`, `security-review.md`,
`sre-review.md`) acumulam uma rodada por fatia, e numa spec com muitas rodadas o volume total deixa
de caber confortavelmente no seu contexto. Os 5 já suportam o split físico
(`docs/MICRO-CONTEXT.md`, seção 2), mas dois formatos coexistem na prática: specs criadas antes de
cada migração continuam no formato antigo até alguém converter (`/sdd-migrate`,
`docs/MICRO-CONTEXT.md`, seção 3) ou até a próxima rodada real nascer direto no formato novo —
nunca retroativo por conta própria de uma leitura.

- **Formato novo (split físico)**: `specs/<slug>/reviews/<área>/` existe como diretório, com
  `INDEX.md`, `tracking.md` e um `F-<N>.md`/`hotfix-<data>.md` por rodada. Detalhe completo do
  layout em `docs/MICRO-CONTEXT.md`, seção 2.
- **Formato legado (arquivo único)**: só `specs/<slug>/<área>.md` existe, editado **in-place** a
  cada rodada, nunca recriado — o caso de qualquer spec criada antes da migração de um artefato
  específico, para qualquer um dos 5. **O arquivo continua inteiro: o que muda é quanto dele você
  lê.**

**Verifique qual formato está em uso antes de ler ou escrever** (o diretório `reviews/<área>/`
existe → novo; só o arquivo único existe → legado) — nunca assuma um ou outro. A regra de leitura
seletiva é a mesma nos dois formatos, só muda a unidade (arquivo separado no novo, seção dentro do
mesmo arquivo no legado):

- **Sempre leia por completo** a tabela "Histórico de aprovações por fatia" (`INDEX.md` no formato
  novo, seção dentro do arquivo no legado — é o índice de todas as rodadas, e é curta) e **o
  conteúdo da rodada vigente** (`F-<N>.md` ou a seção correspondente).
- **Leia também a penúltima rodada** — é a que diz se um achado desta rodada é reincidência e se
  uma ressalva anterior foi resolvida.
- **Rodadas anteriores à penúltima são referência consultada sob demanda**, não leitura
  obrigatória: vá buscar uma delas quando o índice, um achado desta rodada ou uma flag de
  revalidação apontar para ela — não "por completude". No formato novo isso significa nem abrir o
  arquivo daquela rodada; no legado, nem rolar até aquela seção.

**Exceções em que o seu próprio passo exige alcançar mais atrás** — nesses casos leia o que o
passo pedir, sem limite de duas rodadas:

- **Auditoria completa da fatia final** (`security-engineer`, `sre`): cobre o diff acumulado desde
  a última rodada registrada como `Profundidade = completo`, que pode estar várias fatias atrás
  (`docs/gates/seguranca.md`, `docs/gates/sre.md`).
- **Promoção de lição aprendida**: confirmar a 2ª ocorrência de um padrão exige procurar o achado
  equivalente em revisões anteriores (`docs/gates/licoes.md`).
- **Qualquer flag `requer revalidação` em aberto**, que pode ter sido registrada numa rodada
  antiga.

**O lado de quem escreve**, que é o que torna a leitura limitada possível: no formato legado,
identifique a rodada no cabeçalho da seção que você acrescenta (`F-N` ou `hotfix-<data>`, o mesmo
identificador que você usa na tabela de histórico), para que a próxima pessoa/agente encontre a
vigente sem varrer o arquivo; no formato novo, o identificador já é o próprio nome do arquivo
(`F-N.md`/`hotfix-<data>.md`). Nos dois formatos, nunca reescreva rodada anterior para "enxugar" —
tabelas/seções (legado) e `INDEX.md`/`tracking.md` (novo) são append-only
(`docs/gates/governanca.md`); limitar leitura é escolha de quem lê, nunca apagamento de histórico.

**A mesma regra vale para a tabela de Achados/Pendências** (`tracking.md` no formato novo; seção
dentro de `code-review.md`/`qa-report.md`/`security-review.md`/`sre-review.md` no legado) — a que
de fato cresce mais rápido, um achado por área por rodada, não uma linha por fatia como o
Histórico. Cada linha tem colunas `Fatia` e `Status`
(`aberto` / `corrigido` / `aceito como ressalva` — ou `aberto`/`resolvido` nas Pendências do
`sre`): uma linha com `Status` resolvido cuja `Fatia` já foi mergeada é referência sob demanda,
igual a uma rodada antiga do Histórico — não precisa ser relida por completo, só contada como já
resolvida. Linhas com `Status` aberto continuam leitura obrigatória todo round, mesmo que de uma
fatia anterior. Ao confirmar uma correção, **atualize o `Status` da linha original** — nunca
apague a linha nem crie uma duplicata; a linha em si nunca é removida, só marcada.

Um `code-review.md` que acumula muitas rodadas históricas (ex.: milhares de linhas, nove seções)
fica caro de reler in-place a cada rodada só para encontrar a vigente — e confiar num cabeçalho
antigo em vez da tabela de histórico pode levar a revisar a fatia errada.
