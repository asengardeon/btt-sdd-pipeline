---
name: amend
description: Emenda um artefato do pipeline SDD já aprovado (PRD, TRD, código/implementação, code review, QA report, security review ou SRE review) sem reiniciar o pipeline do zero. Use quando o usuário quiser mudar uma decisão já aprovada, resolver um item "VALIDAR DEPOIS", ou corrigir algo em uma etapa anterior sem refazer as etapas seguintes que não são afetadas.
---

# /btt-sdd:amend

Edita um artefato **in-place**, nunca recria do zero, e propaga a mudança só para as etapas
realmente afetadas — sem exigir refazer o pipeline inteiro. É a resposta a "preciso mudar algo já
aprovado sem voltar da primeira etapa".

**Antes de qualquer coisa, leia `docs/SKILL-PREAMBLE.md`** — onde ficam os docs de governança
deste pipeline e de onde vêm os templates de `specs/_template/` (nenhum dos dois vive dentro do
projeto onde você está trabalhando). Resolva esse caminho a partir do "Base directory" desta
invocação: via junction global, é `docs/` na raiz do repositório do pipeline; via plugin, é
`docs/` dentro do pacote.

## Passos

1. Identifique a feature (slug) e qual artefato muda: PRD, TRD, a implementação em
   `src/`/`tests/`, code review, QA report, security review ou SRE review. Se `args` não deixar
   claro, pergunte ao usuário (use `/btt-sdd:pending` primeiro se a emenda é para resolver um item
   VALIDAR DEPOIS específico e o usuário não lembrar qual).

1a. **Detecte o formato do artefato antes de editar** (`docs/MICRO-CONTEXT.md`, seções 2 e 2b):
   diretório existe → formato novo (split); só arquivo único existe → formato legado. Para PRD/TRD
   (split por tópico), identifique também **qual arquivo** dentro do diretório tem a seção que
   muda — a tabela de seção→arquivo está em `docs/MICRO-CONTEXT.md`, seção 2b (ex.: mudar a
   decomposição de tarefas do TRD edita `specs/<slug>/trd/tasks.md`, seção 13; mudar as histórias
   do PRD edita `specs/<slug>/prd/user-stories.md`, seções 6-7). Para os 5 artefatos de revisão
   (split por rodada), a mudança normalmente vai em `tracking.md` (achados/pendências/log) — a
   prosa de uma rodada já aprovada (`F-<N>.md`) não é reaberta por `/btt-sdd:amend`, só por uma
   rodada de revisão nova.

1b. **Confirme a branch atual (`git branch --show-current`) antes de editar qualquer artefato —
   nunca assuma que o workspace já está na branch da fatia em questão.** Entre invocações de
   agente isolado (`isolation: "worktree"`), é normal o orquestrador alternar o workspace
   principal para `main` (liberando o nome literal da branch para o próximo worktree) — e uma
   emenda disparada logo depois, sem essa confirmação, edita o artefato em `main`, não na branch da
   fatia (`docs/GIT-WORKFLOW.md`, seção "Isolamento de working tree", bloco "Confirme sempre o
   branch atual..."). Se não for a branch esperada, `git checkout <branch-da-fatia>` antes de
   continuar (issue #468).

2. Edite o artefato **in-place** com a mudança pedida — nunca gere um novo arquivo nem reescreva o
   documento inteiro do zero (no formato split, isso significa editar só o arquivo-filho certo do
   passo 1a, não recriar `INDEX.md` nem os demais arquivos do mesmo diretório). Se a mudança
   resolve um item da seção "Pendências de validação (VALIDAR DEPOIS)", marque o item como
   "validado" em vez de removê-lo (mantém o histórico de que aquela dúvida existiu e foi
   resolvida; a linha fica na tabela em que está — produto ou engenharia — e, num artefato v2 de
   tabela única, é classificada ao ser emendada). Resposta de uma rodada de perguntas ao PM que
   resolve várias pendências marca todas as do campo "Resolve" como "validado", com uma só linha
   no log (`docs/gates/governanca.md`) — no formato split, essa seção vive em `tracking.md`.

3. Registre a mudança na seção "Log de revisões" do artefato editado: data, autor (você, como
   agente, citando a instrução do usuário), o que mudou, motivo — no formato split, essa seção
   vive em `tracking.md` (PRD/TRD) ou em `tracking.md` dentro do diretório `reviews/<stage>/` (os
   5 artefatos de revisão), nunca junto do arquivo que você acabou de editar no passo 2 quando
   esse arquivo for outro.

   **Passada de coerência do TRD, sempre que esta rodada gravar uma revisão nova no "Log de
   revisões".** As seções 9, 13 e 14 não são prosa: são **contrato lido a jusante** — a 9 é onde QA
   e SRE conferem o que o mundo externo enxerga, a 13 é a fonte do Status que `/btt-sdd:pending` e
   `/btt-sdd:status` reportam e de onde a fatia seguinte tira o que implementar, e a 14 é o que o `sre`
   lê para decidir semver. Uma revisão que muda comportamento ou refuta uma premissa toca
   necessariamente essas seções, e hoje isso depende inteiramente de alguém lembrar. No formato
   split, a seção 9 vive em `architecture.md`, a 13 em `tasks.md`, e a 14 em `INDEX.md` — localize
   pela tabela seção→arquivo de `docs/MICRO-CONTEXT.md`, seção 2b, antes de aplicar as quatro
   verificações abaixo (no formato legado, as três seguem dentro do único `trd.md`):

   1. **Releia a linha 1 de cada arquivo tocado** (no formato split) ou do arquivo único (no
      formato legado) — pega corrupção acidental por edit.
   2. Se a revisão muda **contrato observável** (campo de log, coluna de arquivo, schema, literal de
      mensagem), reconcilie a **seção 9** (`architecture.md` no formato split) — é ela, não a 7,
      que as etapas seguintes leem como contrato.
   3. Se a revisão **refuta ou restringe uma premissa** (um `[não medido]` que virou medido, ou o
      contrário), varra o documento inteiro (todos os arquivos do diretório `trd/`, no formato
      split) pelas afirmações que a premissa antiga sustentava — nomeadamente as seções 7
      (`architecture.md`) e 13 (`tasks.md`), **incluindo linhas de tarefas de fatias ainda não
      iniciadas**.
   4. Atualize a linha da fatia na **seção 14** (`INDEX.md` no formato split) e a coluna Status na
      **seção 13** (`tasks.md` no formato split).

   Não é etapa nova: é um parágrafo de checklist no passo que já bumpa a revisão. O custo de não
   fazer não é teórico: higiene documental do TRD ignorada pode responder por boa parte dos achados
   de uma rodada de code review, e o ciclo de achado, correção e reverificação pode custar mais
   tempo que a própria implementação — e um achado dessa classe, recorrente entre fatias, tem
   potencial de contaminar uma fatia futura ainda não iniciada.

3b. **Se a emenda reescreve uma frase que descreve o *mecanismo* pelo qual uma garantia é obtida**
   (e não o critério que tem de ser verdade), responda as duas perguntas de
   `docs/gates/governanca.md` antes de considerar a emenda fechada:

   1. **Quantas enumerações esta frase tem?** Uma linha de plano de testes costuma ter duas — *o
      que* é coberto e *quais propriedades* são asseveradas. Corrigir uma e deixar a outra move o
      defeito em vez de eliminá-lo, e a frase passa a *parecer* corrigida.
   2. **Em quantos lugares este mesmo mecanismo está descrito?** `grep` pela afirmação antiga no
      repositório inteiro (artefatos de spec, docstrings, docblocks, ADRs) e substitua cada
      reaparição por referência ao lugar canônico, em vez de repetir a frase corrigida.

   A classe mais exposta é a seção 11 do TRD (plano de testes): seu conteúdo **é** mecanismo por
   definição, e mecanismo é o que cada rodada de correção troca. Quando possível, troque a frase de
   mecanismo pelo critério que sobrevive à troca — é a emenda que não precisa ser refeita na rodada
   seguinte.

4. Determine as etapas posteriores afetadas usando a ordem fixa do pipeline
   (PRD → TRD → implementação → revisão de código → QA → segurança → SRE, ver
   `docs/SDD-WORKFLOW.md`):
   - Mudou o PRD? TRD, implementação, revisão de código, QA, segurança e SRE dessa feature podem
     precisar de revalidação — avalie item por item da mudança se ela realmente afeta cada etapa
     seguinte (uma correção de texto sem mudança de critério de aceite pode não afetar nada a
     jusante).
   - Mudou o TRD? Implementação, revisão de código, QA e segurança podem precisar de revalidação;
     SRE só se a mudança envolve infraestrutura.
   - Mudou a implementação? Revisão de código, QA e segurança precisam de revalidação.
   - Mudou a revisão de código? Normalmente só QA precisa reconferir se a correção não introduziu
     regressão.
   - Mudou QA, segurança ou SRE? Normalmente não afeta etapas anteriores (que já estavam
     aprovadas) nem precisa reabrir nada além do próprio relatório.

5. Para cada etapa afetada, registre no "Log de revisões" do respectivo artefato downstream que
   ela **"requer revalidação"** (não apague o conteúdo existente, só sinalize) e informe ao
   usuário quais comandos (`/btt-sdd:trd`, `/btt-sdd:implement`, `/btt-sdd:code-review`,
   `/btt-sdd:qa`, `/btt-sdd:security`, `/btt-sdd:sre`) precisam ser rodados de novo —
   só esses, não o pipeline inteiro.

5b. **Ao fechar uma flag "requer revalidação"** (depois de rodar de novo o comando indicado no
   passo 5 e a etapa ter sido revalidada de verdade): a entrada de log que registra o fechamento
   **nunca deve recitar a frase-gatilho entre aspas** (ex.: nunca escreva algo como "fechando a
   pendência 'TRD requer revalidação'") — `/btt-sdd:status`/`/btt-sdd:pending` detectam a flag por
   texto livre (`grep`/regex procurando "requer revalida" em qualquer linha de log com data), então
   uma entrada de fechamento que cita a frase original é lida como uma **nova** ocorrência não
   resolvida, mais recente que a última aprovação formal — a flag nunca se resolve sozinha. Em vez
   disso: descreva a resolução sem repetir esse texto (ex.: "TRD revisado e reconfirmado contra a
   mudança do PRD") **e** garanta que o artefato-alvo (TRD ou PRD, seção "Aprovação" — `INDEX.md`
   no formato split, mesmo arquivo único no formato legado) tem uma linha formal `(Re)aprovado
   por... em <AAAA-MM-DD>` com data posterior à da flag original — é essa linha, não a entrada de
   log, que `/btt-sdd:status` usa para confirmar que a flag foi mesmo resolvida.

6. Etapas **não** afetadas continuam aprovadas como estavam — não peça reaprovação delas.

## Quando usar sem agente dedicado

Esta skill não aciona um subagente próprio — você mesmo (a sessão atual) faz a edição seguindo os
passos acima, já que é uma operação pontual sobre um artefato existente, não a geração de um
artefato novo do zero.
