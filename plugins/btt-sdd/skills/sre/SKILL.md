---
name: sre
description: Etapa 6 (final) do pipeline SDD. Use depois que QA e segurança aprovaram uma feature, para validar CI/CD, Docker e Terraform antes do deploy. Também use fora do fluxo de uma feature específica quando o usuário pedir revisão de pipeline ou infraestrutura. Aciona o agente sre para produzir specs/<slug>/sre-review.md.
---

# /btt-sdd:sre

Aciona a **etapa 6** do pipeline SDD descrito em `CLAUDE.md`: validação de CI/CD e infraestrutura.

**Sempre passe por esta skill — nunca invoque o agente `sre` diretamente via Agent tool fora
dela** (diferente da etapa 3, onde invocar `backend-developer`/`frontend-developer` direto é o
padrão correto). Isso importa mais aqui do que nas outras etapas de revisão: os passos 5b
(tech-writer automático na última fatia) e 5c (retrospectiva obrigatória de toda fatia, abrindo
issues em `asengardeon/btt-sdd-pipeline`) vivem **nesta skill**, não no agente `sre` — invocar o
agente direto pula os dois silenciosamente, sem aviso.
**"Vivem nesta skill" quer dizer que você, o orquestrador, os executa depois que o agente `sre`
devolver o veredito no passo 3 — nunca inclua as instruções de 5b/5c no prompt passado ao agente
`sre` via Agent tool.** O agente `sre` roda a partir da própria definição de agente, que não
conhece esses dois passos, e vai (corretamente) recusar executá-los ou ignorá-los silenciosamente
se você tentar delegá-los ali, desperdiçando a invocação.

**Antes de qualquer coisa, leia `docs/SKILL-PREAMBLE.md`** — onde ficam os docs de governança
deste pipeline e de onde vêm os templates de `specs/_template/` (nenhum dos dois vive dentro do
projeto onde você está trabalhando). Resolva esse caminho a partir do "Base directory" desta
invocação: via junction global, é `docs/` na raiz do repositório do pipeline; via plugin, é
`docs/` dentro do pacote.
## Quando esta etapa roda

Ao final da spec, na última fatia pendente da decomposição do TRD, sobre o **diff acumulado**
da spec — não a cada fatia. Roda antes disso, dentro de uma fatia intermediária, só quando
alguma tarefa dela tem a coluna `Validação na fatia` (seção 13 do TRD) marcando `sre` — marcação
que o `architect` é obrigado a fazer quando a tarefa toca `ci.yml`/`cd.yml`, `Dockerfile`/compose,
`infra/terraform`, segredo ou variável de ambiente de
deploy, ou um campo que passa a ser obrigatório numa rota ativa já consumida. Seção canônica da
cadência:
`docs/SDD-WORKFLOW.md`, "Cadência: o que roda por fatia e o que roda ao final da spec".

Rodando sobre o acumulado, o escopo é todo o diff da spec desde a última rodada desta etapa
registrada como completa — nunca só o da última fatia. Se este `/btt-sdd:sre` foi acionado por uma
fatia
intermediária sem essa marcação na tabela, diga isso ao usuário antes de rodar: a etapa cabe no
fim da spec, e rodá-la por fatia é exatamente o custo que a cadência existe para cortar.

## Passos

1. Identifique o slug da feature (mesma lógica das skills anteriores).
2. Confirme que `specs/<slug>/qa-report.md` **e** `specs/<slug>/security-review.md` existem com
   veredito aprovado. Se algum faltar, sugira `/btt-sdd:qa` e/ou `/btt-sdd:security` primeiro —
   não pule
   nenhum dos dois.
2b. **Se a branch/PR original da fatia já foi mergeado e apagado** (comum em revisão retroativa
   pedida depois do fato — ex.: um `/btt-sdd:hotfix` que pulou SRE no momento do merge, e o usuário
   pede para formalizar essa etapa depois), não tente localizar/rebasear uma branch inexistente:
   siga `docs/GIT-WORKFLOW.md`, seção "Revisão retroativa de um PR já mergeado" — crie uma branch
   nova a partir de `origin/main`, produza só o `sre-review.md` desta rodada, e abra um PR próprio
   (sem gate adicional, já que não há código novo a revisar). Caso contrário (branch/PR ainda
   ativo), **confirme que a branch está sincronizada com `main` antes de revisar.** Rode `git fetch
   origin main` e `git rev-list --count HEAD..origin/main` — se houver commits novos em `main` desde
   que esta branch nasceu (ex.: merge de um hotfix concorrente da mesma spec enquanto esta fatia
   ainda estava em revisão), **sincronize com `git merge origin/main` — nunca `git rebase`**
   (`docs/GIT-WORKFLOW.md`, seção "Sincronizar a branch da fatia com `main`: `merge`, nunca
   `rebase`": a branch já está publicada, então rebase exigiria força-push, que o classificador do
   modo automático recusa e que já apagou trabalho revisado em silêncio neste pipeline),
   resolvendo eventuais conflitos nos arquivos de artefato da spec (`code-review.md`/
   `qa-report.md`/`security-review.md`/`sre-review.md`/`trd.md` no formato legado, ou os arquivos
   dentro de `reviews/<etapa>/`/`trd/` no formato novo) preservando o conteúdo de ambos os
   lados quando tocarem os mesmos arquivos (`docs/GIT-WORKFLOW.md`, seção "Resolvendo conflitos de
   merge nos arquivos de artefato de revisão", tem o passo a passo de como preservar a estrutura
   Markdown desses arquivos), e envie (push) o resultado. Isso evita que a sincronização falte até
   esta última etapa, descoberta só pelo `sre` depois que code review, QA e segurança já tiverem
   commitado às cegas sobre uma base que gera conflito — exigindo uma invocação extra só para
   resolver retroativamente.
3. **Anote o horário atual (`date -u +%Y-%m-%dT%H:%M:%SZ`)** — vai precisar dele no passo 3b para
   registrar a duração desta invocação. Invoque o agente `sre` (Agent tool, `subagent_type:
   "sre"`) passando o caminho do TRD (seção de pilares de engenharia/infra), do `qa-report.md` e do
   `security-review.md`, e instrução para produzir o relatório desta rodada — o próprio agente
   detecta se esta spec já usa o formato novo (`specs/<slug>/reviews/sre-review/`) ou o legado
   (`specs/<slug>/sre-review.md`), conforme `agents/sre/artefato-split-fisico.md`; você não
   precisa decidir isso por ele. **Sempre passe `isolation: "worktree"` nesta chamada**
   — nunca deixe dois agentes dividirem o mesmo diretório de trabalho (`docs/GIT-WORKFLOW.md`,
   seção "Isolamento de working tree entre agentes concorrentes"). Não é uma condição a avaliar
   caso a caso ("outra tarefa pode estar ativa?") — sem isolamento, o agente pode presumir
   incorretamente a quem pertencem arquivos não commitados de outra tarefa ativa na mesma branch e
   realocá-los para o próprio PR; o padrão desta invocação é sempre isolar.
3a. **Ao incluir na instrução um fato que outra etapa mediu, diga quem mediu e como — e marque se
   ele é carga para alguma conclusão desta etapa.** Repassar o que a etapa anterior já mediu é
   desejável (é para isso que as seções "o que a próxima etapa herda" existem), mas a repetição
   **lava a origem**: o que era "medido pela etapa X, com o método Y" chega como premissa sem
   procedência, indistinguível de um fato do desenho — e quem recebe não tem como saber que precisa
   reconferir. Rotule assim: *"medido pelo `security-engineer` lendo `pull_request.base.sha` —
   **reconfira se sua conclusão depender disso**"*. Vale também para medição **sua**, de
   orquestrador: diga o que você leu para chegar nela. Duas armadilhas concretas mostram por que
   isso importa: ler `pull_request.base.sha` não garante a causa real do pulo de um job de CI em
   evento `synchronize`, onde o `base` efetivo é `github.event.before` — a causa pode variar de run
   para run, e um defeito repassado como medido pode ser mais grave do que o descrito; e contar
   módulos no código-fonte (ex.: "1 módulo do Workbox importado") pode divergir do artefato
   construído, que pode ter mais de um marcador. Confira o artefato construído, não só o
   código-fonte, e marque a procedência do fato — uma medição errada herdada custa mais que uma
   remedição.
3b. **Registre a duração desta invocação em `specs/<slug>/timing-log.md`** (crie a partir de
   `specs/_template/timing-log.template.md` se ainda não existir): uma linha com o horário do
   passo 3, o horário atual, e a diferença calculada (etapa "SRE", agente "sre", fatia desta
   rodada). Commit e envie (push) essa atualização junto com o resto do que esta rodada já for
   commitar (`docs/GIT-WORKFLOW.md`, regra 4, sobre agrupar pushes relacionados) — precisa estar
   commitado antes do passo 5c (retrospectiva), que lê este arquivo. **Vale também quando esta
   invocação é só uma reverificação pontual de um achado específico** — nunca pule este registro
   por ser "só uma reverificação", senão o `timing-log.md` da fatia fica sistematicamente
   incompleto. **Quando a reverificação pontual retoma o agente via `SendMessage` em vez de
   abrir uma invocação nova, o passo 3 não acontece — anote o horário antes do `SendMessage` do
   mesmo jeito.** **Uma linha por etapa, sempre, e
   nenhuma linha nomeando duas etapas**: se o trabalho de orquestrador nesta etapa foi zero,
   registre `0m` com justificativa em vez de omitir a linha; se esta etapa rodou em paralelo com
   outra, são duas linhas com o mesmo horário de início, nunca uma linha "X + Y"
   (`specs/_template/timing-log.template.md`, seção "Uma linha por etapa, sempre"). **E se esta
   invocação retomou o agente em vez de criá-lo**, registre a **diferença** contra a notificação
   anterior do mesmo agente, não o contador bruto — crescimento monotônico entre rodadas é a
   assinatura de contador cumulativo desde a criação (mesmo template, seção "O que a coluna
   'Duração' mede").
4. O agente `sre` já embute o gate de aprovação: qualquer proposta de mudança real de
   infraestrutura (`terraform apply`) é apresentada como plano e só executada após aprovação
   explícita do usuário via `AskUserQuestion`. Você não precisa duplicar essa confirmação, mas
   nunca instrua o agente a pular esse passo.
4b. Se o agente `sre` estiver rodando como subagente assíncrono/em background e devolver uma
   pergunta ou plano em texto puro (sinal de que `AskUserQuestion` não estava disponível para ele
   nesse modo), **você** — o orquestrador desta skill — é responsável por apresentar esse plano ao
   usuário via *sua própria* `AskUserQuestion` antes de instruir o agente a prosseguir. Nunca
   repasse "pode prosseguir" para o agente sem ter, você mesmo, obtido a aprovação explícita do
   usuário nesse turno — aprovação de uma etapa anterior (ex. do Docker base) não cobre
   automaticamente uma extensão nova (ex. adicionar um serviço novo ao compose). **E se a pergunta
   que você
   intermediou era uma oferta de escalonamento de uma entrada de `docs/LESSONS-LEARNED.md`**
   (`docs/gates/licoes.md`, bullets sobre entrada que atinge 3 ocorrências), **escreva a resposta do
   usuário no campo `Escalonamento` da entrada correspondente neste mesmo turno** — não só no
   artefato da rodada. O gate instrui a *ler* o campo antes de ofertar de novo, mas sem dono para o
   preenchimento ele acumula `sem resposta` em entradas cuja resposta já foi dada, e a rodada
   seguinte repete a oferta que o campo existe para evitar.
4c. **Integre o commit do agente na branch da fatia, localmente** (`docs/GIT-WORKFLOW.md`,
   seção "Push único por fatia: o CI roda uma vez, não uma vez por artefato de revisão"). O agente
   commitou o artefato e informou a branch e o SHA; se ele rodou em working tree isolado, essa
   branch é a temporária do worktree — integre e confirme **antes** de remover o worktree.
   **Confirme a branch atual antes do merge — nunca assuma** (`docs/GIT-WORKFLOW.md`, seção
   "Isolamento de working tree", bloco "Confirme sempre o branch atual antes de qualquer `git
   merge`..."): um agente retomado sem isolamento devolve o workspace via `git checkout <branch
   base>`, e um `merge --ff-only` sobre a branch errada avança a ponta dela em silêncio em vez de
   falhar.

   ```bash
   git branch --show-current                              # confirme antes de qualquer merge
   git merge --ff-only <branch-informada-pelo-agente>
   # artefato alcançável na branch da fatia — formato novo são 3 arquivos, legado é 1:
   git log -1 --format=%H -- specs/<slug>/reviews/sre-review/ specs/<slug>/sre-review.md
   git worktree remove <caminho-do-worktree>              # se houver
   ```

   Confirmar não é zelo: os itens de gate que antes exigiam push nasceram de artefato que não
   chegava à branch. A durabilidade continua obrigatória — o meio é que mudou.
5. Mostre ao usuário o veredito e os checklists de CI, Docker e Terraform — incluindo a
   verificação de proteção da branch `main` (`docs/GIT-WORKFLOW.md`).
5b. **Spec finalizada → aciona `tech-writer` automaticamente.** Se a fatia aprovada (ou aprovada com
   ressalvas) nesta rodada for a **última fatia pendente da feature** (verifique a tabela
   "Decomposição de tarefas e dependências" do TRD: nenhuma outra fatia ainda não
   implementada/mergeada depois desta), a spec está completa ponta a ponta pelo pipeline. Antes de
   informar o usuário sobre o merge (passo 6 abaixo), invoque o agente `tech-writer` (Agent tool,
   `subagent_type: "tech-writer"`, ou `/btt-sdd:docs`) para atualizar a documentação do repositório
   (README, `docs/`, ADRs) refletindo o que esta feature introduziu de fato — este é também o
   gatilho de `docs/DOCS-MAP.md` (`agents/tech-writer/mapa-de-documentacao.md`), já que uma spec
   recém-concluída é o momento natural de refletir no índice qualquer artefato que mudou de
   formato. **Passe explicitamente,
   na invocação, a lista de itens VALIDAR DEPOIS de tipo "documentação" abertos nesta spec e nas
   anteriores** (condições do tipo "aceitar o risco + documentar", `agents/security-engineer.md`,
   item 3b): esta é a única etapa do pipeline com dono natural para texto de README, e ela **não
   recebe a tarefa a menos que alguém a nomeie** — não é um passo opcional a critério do usuário,
   roda automaticamente sempre que a última fatia é aprovada. Escopo da invocação: só o que a feature `<slug>` mudou de verdade (mecanismos novos,
   comportamento documentado alterado), nunca uma reescrita geral não relacionada. Lembre também o
   usuário que, depois do merge desta última fatia, `/btt-sdd:implement` conduz o teste geral
   obrigatório de fim de spec contra produção real (`docs/POST-MERGE-VALIDATION.md`) — não é algo
   que este agente `sre` faz agora, é o próximo passo depois do merge.
5c. **Retrospectiva da fatia → abre issues de melhoria no repositório do plugin — SEMPRE, em toda
   fatia aprovada, antes de escrever a mensagem do passo 6.** Este passo não é um adendo opcional
   depois de já ter informado o resultado ao usuário — é uma pré-condição do passo 6, no mesmo
   espírito do 5b acima: **você só escreve a mensagem "aprovado, pronto para merge" depois de ter
   completado este passo**, mesmo que pareça uma tarefa administrativa a mais numa fatia que já
   está aprovada. Avalie a execução desta rodada (implementação → revisão de código → QA →
   segurança → SRE, incluindo quantas rodadas de correção pontual foram necessárias) e identifique,
   com evidência concreta dos artefatos desta rodada (não especulação genérica): pontos de melhoria
   de fluxo do próprio pipeline (etapa redundante, instrução ambígua que gerou retrabalho, gate que
   bloqueou sem necessidade), otimizações de performance, e otimizações de custo de token
   (invocação repetida do que já existia, contexto inflado sem necessidade). **Leia
   `specs/<slug>/timing-log.md`, se existir**, como parte dessa avaliação — a duração de cada
   invocação desta fatia (e, se houver histórico de fatias anteriores da mesma spec no arquivo, a
   tendência entre elas) é evidência concreta para a análise de otimização de performance, não só
   contagem de rodadas de correção. Uma etapa desproporcionalmente lenta em relação às outras da
   mesma rodada (ex.: `code-reviewer` levando 3x mais que `qa-engineer` sem justificativa óbvia no
   escopo) é candidata a virar uma issue de melhoria como qualquer outro achado desta retrospectiva.
   **Linhas com `Agente = orquestrador (sem agente)` contam como qualquer outra** — são trabalho da
   etapa conduzido sem agente (investigação ao vivo, rodadas de `AskUserQuestion`, intermediação de
   subagente isolado; `specs/_template/timing-log.template.md`, seção "Trabalho conduzido pelo
   orquestrador"). Se uma etapa tem só linhas de agente e você sabe, pelos artefatos desta rodada,
   que houve trabalho de orquestrador nela, a série está subestimando essa etapa: diga isso na
   análise em vez de concluir que ela foi barata.
   **Leia também a coluna `Modelo`** desse arquivo: ela diz em que tier cada invocação rodou
   (`docs/MODEL-TIERING.md`). Duas leituras saem dela, e as duas são achado de retrospectiva como
   qualquer outro — (a) sub-tarefa auxiliar que atravessou a fatia em tier econômico **sem
   repromoção** é candidata a virar padrão para esse tipo de sub-tarefa; (b) o mesmo tipo de
   sub-tarefa repromovido duas vezes (duas linhas, a econômica e a que a substituiu) é sinal de que
   ele não passa no teste das cinco condições — e insistir custa mais que nunca ter rebaixado. Uma
   **linha de etapa** marcada `econômico` não é economia: é um limite rígido violado, e entra como
   achado explícito.
   Essa avaliação é
   investigação somente-leitura que não precisa ficar retida no seu contexto depois de concluída —
   prefira delegar a uma sub-tarefa isolada que devolva só as sugestões destiladas
   (`docs/gates/governanca.md`, bullet sobre investigação de causa
   raiz). Essa sub-tarefa é candidata típica ao **tier econômico** (`docs/MODEL-TIERING.md`): o
   formato do que você espera de volta é definido por você antes de invocar, e a conclusão é
   conferível contra as linhas do arquivo sem reler o arquivo inteiro. A decisão de abrir issue
   continua sua, no padrão da sessão — a sub-tarefa levanta, você decide.

   Para cada sugestão concreta e acionável (não "poderia ser melhor" genérico), abra uma issue
   nova em `asengardeon/btt-sdd-pipeline` — o repositório de origem deste plugin, **sempre esse
   repositório, independente de qual projeto está rodando o pipeline agora**: `gh issue create
   --repo asengardeon/btt-sdd-pipeline --title "..." --body "..." --label melhoria`, com contexto
   suficiente (o que aconteceu nesta fatia, por que a sugestão faz sentido, qual arquivo do
   plugin mudaria). Prefixe o título com "Melhoria:". Se `gh` falhar (comum quando o plugin está
   instalado num projeto de outro operador sem acesso a este repositório específico), não tente
   mais de 3 vezes — relate as sugestões como texto ao usuário em vez de bloquear a aprovação da
   fatia por isso.

   **Nunca identifique o projeto/repositório consumidor de origem** — nem no título, nem no
   corpo, nem como label. `asengardeon/btt-sdd-pipeline` é público; o projeto consumidor
   normalmente não é, e nomeá-lo ali (mesmo só como contexto, ex.: "na spec X do projeto Y")
   vaza publicamente qual operador privado usa o pipeline. Descreva o contexto de forma genérica
   ("nesta fatia", "um projeto usando o pipeline", "a stack em uso") em vez de citar o nome real
   do repositório/projeto/cliente (issue #607).

   **Abra também, separadamente, uma issue de aprendizado** (prefixo "Aprendizado:" no título,
   label `aprendizado` em vez de `melhoria`, mesmo mecanismo, mesma regra de nunca identificar o
   projeto de origem) para todo padrão de comportamento observado nesta fatia que faça sentido
   generalizar para o plugin — não algo específico deste projeto, mas algo que outro projeto
   usando o pipeline também se beneficiaria de ter documentado/instruído nos agentes ou skills.
   Se nenhuma sugestão ou aprendizado concreto surgir desta fatia, não abra issue artificial só
   para cumprir o passo — siga sem abrir nada, mas ainda assim não pule a própria avaliação: "nada
   digno de issue" é uma conclusão válida, "não avaliei" não é.

   **Toda issue criada aqui leva um label de tipo** — `melhoria` ou `aprendizado`, conforme acima
   — e nenhum outro label identificando a origem. Confirme que o label existe (`gh label list
   --repo asengardeon/btt-sdd-pipeline --json name`); se não existir, crie com `gh label create
   <nome> --repo asengardeon/btt-sdd-pipeline --color <hex> --description "<descrição curta>"`
   antes do `gh issue create` — `gh issue create --label` falha se o label ainda não existir no
   repositório de destino.
5c-bis. **Faça o push único da fatia antes do passo 5d**, agora que todos os artefatos de revisão
   dela estão commitados e integrados localmente (`docs/GIT-WORKFLOW.md`, seção "Push único por
   fatia: o CI roda uma vez, não uma vez por artefato de revisão"). Um `git push` só, na branch da
   fatia. **Exceção**: se o `sre` ajustou `ci.yml`/`cd.yml`, `Dockerfile`/compose ou `infra/`, ele
   já empurrou na hora e esperou o CI — isso muda comportamento e precisa de run próprio; aqui você
   só confirma que não ficou nada por enviar. Um push que só acrescenta Markdown em `specs/` não
   precisa de run verde próprio: `docs/gates/merge.md` aceita o run anterior desde que você
   **prove**, com `git diff --stat <headSha-do-run>..<headRefOid-atual>`, que nada relevante ao
   workflow mudou entre os dois — prova explícita, nunca presunção.
5d. **Se aprovado (ou aprovado com ressalvas não-bloqueantes), tire o PR do modo draft antes da
   mensagem do passo 6.** `docs/GIT-WORKFLOW.md`, regra 4, já instrui abrir o PR cedo em modo draft
   no primeiro commit da fatia — mas nada no pipeline transiciona ele para "Ready for review"
   depois, mesmo sabendo, ao final desta etapa, que a fatia está pronta para merge. Confira
   (`gh pr view <PR> --json isDraft`); se `isDraft` for `true`, rode `gh pr ready <PR>` antes de
   informar o resultado ao usuário. PRs com `mergeStateStatus=CLEAN`/`mergeable=MERGEABLE` ainda
   ficam bloqueados na UI do GitHub até essa transição manual — não é uma pendência a deixar para o
   usuário perceber sozinho. Reprovado não passa por este passo (o PR
   continua draft até nova rodada de correção).

   **Num projeto com cadência `ci-antes-do-merge`** (`docs/PROJECT-CONVENTIONS.md`), esta transição
   deixa de ser cosmética: é ela que **dispara a única execução completa da suíte da fatia
   inteira**,
   e é por desenho o último ato antes do merge. Diga isso explicitamente na mensagem do passo 6, e
   diga de quem é a espera: **do orquestrador**, não sua — você não bloqueia aguardando CI
   (`docs/GIT-WORKFLOW.md`, seção "Aguardando CI antes do merge"). Na prática: rode `gh pr ready`,
   informe que o run completo acabou de ser disparado por essa transição, e que o merge depende
   dele ficar verde. Sem isso o usuário vê um PR "pronto" cujo único run de verdade ainda está
   rodando — ou, pior, lê como pronto um verde que era do caminho pulado.
6. **Só escreva esta mensagem depois de completar 5b, 5c e 5d (se aplicáveis) acima.** Se aprovado,
   informe que a feature está pronta ponta a ponta pelo pipeline SDD, que o PR já saiu do modo draft
   (passo 5d), e que o merge (GitHub Flow) fica a critério do usuário. Se você (ou o usuário) for
   aguardar o CI terminar antes desse merge, siga `docs/GIT-WORKFLOW.md`, seção "Aguardando CI antes
   do merge" — prefira uma primeira espera maior antes da primeira checagem, em vez de checagens
   curtas desde o início. Se reprovado ou aprovado com ressalvas, liste os itens pendentes e quem
   deve resolvê-los — e siga a seção "Retomando para corrigir achados de revisão" de
   `skills/implement/SKILL.md` (prefira retomar o mesmo agente que implementou a fatia via
   `SendMessage` para correções pequenas e objetivas, em vez de invocar um agente novo).

## Auto-aprovação nunca é o gate real

Se o agente `sre` foi invocado fora deste fluxo normal só para *implementar* um ajuste pontual de
infraestrutura (ex.: corrigir um `cd.yml` a pedido do orquestrador), essa invocação **não conta**
como a revisão desta etapa, mesmo que o mesmo agente já esteja "na área" e tecnicamente pudesse
escrever o veredito. Depois que o ajuste estiver pronto e code review/QA/segurança tiverem
completado normalmente, invoque uma instância **nova e independente** do `sre` para produzir
`sre-review.md` — nunca aceite um veredito escrito na mesma rodada em que o `sre` implementou a
correção.

## Quando usar fora do fluxo de feature

Se o usuário pedir "revisa nosso pipeline" ou "audita a infra" sem uma feature específica, aponte
o agente `sre` para os checklists gerais dele mesmo sem um `qa-report.md` associado.

## Quando usar sem o agente

Se o Agent tool não estiver disponível, siga `agents/sre.md` diretamente.
