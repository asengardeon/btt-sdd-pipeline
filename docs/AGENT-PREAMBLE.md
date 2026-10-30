# Preâmbulo dos agentes do pipeline

Todo agente deste pipeline (`architect`, `backend-developer`, `code-reviewer`, `qa-engineer`,
`security-engineer`, `sre`, `ux-designer`, `product-design`, `codebase-archaeologist`,
`frontend-developer`, `tech-writer`) lê este arquivo antes de começar. Ele existe porque o que
está aqui valia para todos e estava copiado dentro de cada um — e a cópia já divergiu sozinha
pelo menos uma vez (`docs/FILE-GUIDE.md`, sobre este arquivo).

Nada aqui substitui os gates: cada agente declara no próprio arquivo os 2-5 arquivos de
`docs/gates/` que valem para a etapa dele.

## Onde ficam os docs de governança citados nos arquivos deste pipeline

Referências como `docs/GIT-WORKFLOW.md`, `docs/QUALITY-GATES.md`, `docs/gates/*.md`,
`docs/TESTING.md`, `docs/ENGINEERING-PILLARS.md`, `docs/ARCHITECTURE.md`, `docs/SDD-WORKFLOW.md`,
`docs/FILE-GUIDE.md`, `docs/POST-MERGE-VALIDATION.md` `docs/MODEL-TIERING.md`,
`docs/WRITING-STYLE.md` e `docs/TOOLING.md` apontam para os docs genéricos deste pipeline — **não
são copiados para dentro de cada projeto que o usa**. Eles vivem junto da distribuição do próprio
pipeline: se você
foi carregado via junction global (`.claude/agents/<seu-nome>.md` apontando para este repositório,
`CLAUDE.md`, seção "Distribuição global"), esses docs estão em `docs/` na raiz **deste mesmo
repositório** — não necessariamente no projeto onde você está trabalhando agora. Se o projeto
atual também tiver um `docs/<nome>.md` próprio (`STACK.md`, `DESIGN-SYSTEM.md`, `BASELINE.md`,
`LESSONS-LEARNED.md`, `GLOSSARY.md`, `adr/`), esse é conteúdo do projeto, não deste pipeline — não
confunda os dois. Se não conseguir determinar de onde você foi carregado, pergunte a quem te
invocou.

## Se você recebeu um worktree isolado, sincronize antes de ler qualquer código

Worktree isolado reaproveitado nasce na base da invocação anterior, não na ponta da branch. Rode
`git fetch` e compare com `origin/<branch>` antes de qualquer leitura ou trabalho. O passo a passo
e o porquê estão em `docs/GIT-WORKFLOW.md`, seção "Isolamento de working tree entre agentes
concorrentes". Isso já aconteceu em sete de sete invocações isoladas da mesma fatia, e nenhuma
delas tinha sido instruída a checar.

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
atribuí-lo a uma convenção nomeada do projeto, cite a linha exata que a registra. Já aconteceu de
verdade: uma convenção nomeada (`ci-antes-do-merge`) nunca existiu em `docs/PROJECT-CONVENTIONS.md`
— o comportamento observado era real, mas produzido por um mecanismo diferente, já existente antes
da spec. A primeira rodada da spec descreveu o mecanismo certo em prosa; a partir da rodada
seguinte, cada artefato citou o nome errado herdado da rodada anterior, sem nenhuma conferir a
fonte primária, porque "o comportamento observado bate" tornava a citação parecer verificada
(issue #499, `asengardeon/btt-sdd-pipeline`).

**Antes de repetir "mecanismo X já existe desde a spec Y, inalterado" para evitar reverificação
redundante, confirme se alguma migração de stack/framework/linguagem aconteceu desde a spec Y**
(`grep` em `docs/adr/` por ADRs de migração/reescrita). Citar um mecanismo como "já existente e
inalterado" é uma economia de tempo/contexto geralmente correta — mas só é segura quando nada
mudou estruturalmente desde a spec que o introduziu, e uma migração de stack é justamente o tipo
de evento que invalida essa premissa. Se houver migração desde Y, a citação exige reverificação
por leitura direta do código atual antes de ser repetida — nunca repetição verbatim da rodada
anterior. Já aconteceu de verdade: um mecanismo de log estruturado por requisição, implementado
na stack original, nunca foi portado numa migração de linguagem/framework que não mencionou
observabilidade em nenhuma linha — e quatro rodadas de SRE consecutivas, em quatro specs
diferentes já na stack nova, afirmaram que ele "já existia desde a spec original, inalterado",
cada rodada tornando a descrição mais específica que a anterior sem nenhuma verificar contra o
código real pós-migração. Só a quinta rodada a citar a afirmação verificou e descobriu que o
mecanismo nunca existiu na stack nova (issue #527, `asengardeon/btt-sdd-pipeline`).

**Ao citar um artefato de investigação como base de uma ressalva, verifique a marcação
`[medido]`/`[inferido]` da frase que você está usando** (`agents/architect.md`, item 1c). Uma
ressalva apoiada em `[inferido]` declara isso — e, quando a medição for barata e o ambiente
estiver à mão, propor medi-la sai mais barato que carregar a ressalva por três fatias.

## Artefato in-place que acumulou rodadas: leia a vigente e a penúltima, não todas

Os artefatos de revisão (`code-review.md`, `ux-review.md`, `qa-report.md`, `security-review.md`,
`sre-review.md`) são editados **in-place** a cada fatia/rodada, nunca recriados — então eles
crescem indefinidamente, e numa spec com muitas rodadas o arquivo inteiro deixa de caber
confortavelmente no seu contexto. **O arquivo continua inteiro: o que muda é quanto dele você
lê.**

- **Sempre leia por completo** a tabela "Histórico de aprovações por fatia" (é o índice de todas
  as rodadas, e é curta) e **o conteúdo da rodada vigente**.
- **Leia também a penúltima rodada** — é a que diz se um achado desta rodada é reincidência e se
  uma ressalva anterior foi resolvida.
- **Rodadas anteriores à penúltima são referência consultada sob demanda**, não leitura
  obrigatória: vá buscar uma delas quando a tabela de histórico, um achado desta rodada ou uma
  flag de revalidação apontar para ela — não "por completude".

**Exceções em que o seu próprio passo exige alcançar mais atrás** — nesses casos leia o que o
passo pedir, sem limite de duas rodadas:

- **Auditoria completa da fatia final** (`security-engineer`, `sre`): cobre o diff acumulado desde
  a última rodada registrada como `Profundidade = completo`, que pode estar várias fatias atrás
  (`docs/gates/seguranca.md`, `docs/gates/sre.md`).
- **Promoção de lição aprendida**: confirmar a 2ª ocorrência de um padrão exige procurar o achado
  equivalente em revisões anteriores (`docs/gates/licoes.md`).
- **Qualquer flag `requer revalidação` em aberto**, que pode ter sido registrada numa rodada
  antiga.

**O lado de quem escreve**, que é o que torna a leitura limitada possível: identifique a rodada no
cabeçalho da seção que você acrescenta (`F-N` ou `hotfix-<data>`, o mesmo identificador que você
usa na tabela de histórico), para que a próxima pessoa/agente encontre a vigente sem varrer o
arquivo. E nunca reescreva rodada anterior para "enxugar" o arquivo — essas tabelas e seções são
append-only (`docs/gates/governanca.md`); limitar leitura é escolha de quem lê, nunca apagamento
de histórico.

Já aconteceu de verdade: um `code-review.md` de **3.216 linhas**, com nove seções de rodadas
históricas, era relido in-place por cada revisor seguinte só para encontrar a rodada vigente — e,
no mesmo PR, um revisor que confiou num cabeçalho antigo em vez da tabela quase revisou a fatia
errada.
