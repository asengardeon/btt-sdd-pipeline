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
agente direto já pulou os dois silenciosamente numa sessão real, só percebido depois do merge.
**"Vivem nesta skill" quer dizer que você, o orquestrador, os executa depois que o agente `sre`
devolver o veredito no passo 3 — nunca inclua as instruções de 5b/5c no prompt passado ao agente
`sre` via Agent tool.** O agente `sre` roda a partir da própria definição de agente, que não
conhece esses dois passos, e vai (corretamente) recusar executá-los ou ignorá-los silenciosamente
se você tentar delegá-los ali — já aconteceu numa sessão real, custando uma invocação
desperdiçada.

## Passos

1. Identifique o slug da feature (mesma lógica das skills anteriores).
2. Confirme que `specs/<slug>/qa-report.md` **e** `specs/<slug>/security-review.md` existem com
   veredito aprovado. Se algum faltar, sugira `/btt-sdd:qa` e/ou `/btt-sdd:security` primeiro — não pule
   nenhum dos dois.
2b. **Se a branch/PR original da fatia já foi mergeado e apagado** (comum em revisão retroativa
   pedida depois do fato — ex.: um `/btt-sdd:hotfix` que pulou SRE no momento do merge, e o
   usuário pede para formalizar essa etapa depois), não tente localizar/rebasear uma branch
   inexistente: siga `docs/GIT-WORKFLOW.md`, seção "Revisão retroativa de um PR já mergeado" — crie
   uma branch nova a partir de `origin/main`, produza só o `sre-review.md` desta rodada, e abra um
   PR próprio (sem gate adicional, já que não há código novo a revisar). Caso contrário (branch/PR
   ainda ativo), **confirme que a branch está sincronizada com `main` antes de revisar.** Rode `git
   fetch origin main` e `git rev-list --count HEAD..origin/main` — se houver commits novos em `main` desde que
   esta branch nasceu (ex.: merge de um hotfix concorrente da mesma spec enquanto esta fatia ainda
   estava em revisão), rebaseie a branch da fatia sobre `origin/main` antes de prosseguir,
   resolvendo eventuais conflitos nos arquivos de artefato da spec (`code-review.md`/
   `qa-report.md`/`security-review.md`/`sre-review.md`/`trd.md`) preservando o conteúdo de ambos os
   lados quando tocarem os mesmos arquivos (`docs/GIT-WORKFLOW.md`, seção "Resolvendo conflitos de
   merge nos arquivos de artefato de revisão", tem o passo a passo de como preservar a estrutura
   Markdown desses arquivos), e envie (push) o resultado. Já aconteceu de verdade essa
   sincronização faltar até esta última etapa — descoberta só pelo `sre`, depois que code review, QA
   e segurança já tinham commitado às cegas sobre uma base que gerava conflito, exigindo uma
   invocação extra só para resolver retroativamente.
3. **Anote o horário atual (`date -u +%Y-%m-%dT%H:%M:%SZ`)** — vai precisar dele no passo 3b para
   registrar a duração desta invocação. Invoque o agente `sre` (Agent tool, `subagent_type:
   "sre"`) passando o caminho do TRD (seção de pilares de engenharia/infra), do `qa-report.md` e do
   `security-review.md`, e instrução para produzir `specs/<slug>/sre-review.md` a partir de
   `specs/_template/sre-review.template.md`. **Sempre passe `isolation: "worktree"` nesta chamada**
   — nunca deixe dois agentes dividirem o mesmo diretório de trabalho (`docs/GIT-WORKFLOW.md`,
   seção "Isolamento de working tree entre agentes concorrentes"). Não é uma condição a avaliar
   caso a caso ("outra tarefa pode estar ativa?") — já aconteceu numa sessão real do agente `sre`
   presumir incorretamente a quem pertenciam arquivos não commitados de outra tarefa ativa na mesma
   branch e realocá-los para o próprio PR; o padrão desta invocação é sempre isolar.
3b. **Registre a duração desta invocação em `specs/<slug>/timing-log.md`** (crie a partir de
   `specs/_template/timing-log.template.md` se ainda não existir): uma linha com o horário do
   passo 3, o horário atual, e a diferença calculada (etapa "SRE", agente "sre", fatia desta
   rodada). Commit e envie (push) essa atualização junto com o resto do que esta rodada já for
   commitar (`docs/GIT-WORKFLOW.md`, regra 4, sobre agrupar pushes relacionados) — precisa estar
   commitado antes do passo 5c (retrospectiva), que lê este arquivo.
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
   automaticamente uma extensão nova (ex. adicionar um serviço novo ao compose).
5. Mostre ao usuário o veredito e os checklists de CI, Docker e Terraform — incluindo a
   verificação de proteção da branch `main` (`docs/GIT-WORKFLOW.md`).
5b. **Spec finalizada → aciona `tech-writer` automaticamente.** Se a fatia aprovada (ou aprovada
   com ressalvas) nesta rodada for a **última fatia pendente da feature** (verifique a tabela
   "Decomposição de tarefas e dependências" do TRD: nenhuma outra fatia ainda não
   implementada/mergeada depois desta), a spec está completa ponta a ponta pelo pipeline. Antes de
   informar o usuário sobre o merge (passo 6 abaixo), invoque o agente `tech-writer` (Agent tool,
   `subagent_type: "tech-writer"`, ou `/btt-sdd:docs`) para atualizar a documentação do repositório
   (README, `docs/`, ADRs) refletindo o que esta feature introduziu de fato — não é um passo
   opcional a critério do usuário, roda automaticamente sempre que a última fatia é aprovada.
   Escopo da invocação: só o que a feature `<slug>` mudou de verdade (mecanismos novos,
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
   Essa avaliação é
   investigação somente-leitura que não precisa ficar retida no seu contexto depois de concluída —
   prefira delegar a uma sub-tarefa isolada que devolva só as sugestões destiladas
   (`docs/QUALITY-GATES.md`, seção "Governança de decisão", bullet sobre investigação de causa
   raiz).

   Para cada sugestão concreta e acionável (não "poderia ser melhor" genérico), abra uma issue
   nova em `asengardeon/btt-sdd-pipeline` — o repositório de origem deste plugin, **sempre esse
   repositório, independente de qual projeto está rodando o pipeline agora**: `gh issue create
   --repo asengardeon/btt-sdd-pipeline --title "..." --body "..." --label melhoria --label
   "spec:<projeto>/<slug>"`, com contexto suficiente (o que aconteceu nesta fatia, por que a
   sugestão faz sentido, qual arquivo do plugin mudaria). Prefixe o título com "Melhoria:". Se
   `gh` falhar (comum quando o plugin está instalado num projeto de outro operador sem acesso a
   este repositório específico), não tente mais de 3 vezes — relate as sugestões como texto ao
   usuário em vez de bloquear a aprovação da fatia por isso.

   **Abra também, separadamente, uma issue de aprendizado** (prefixo "Aprendizado:" no título,
   label `aprendizado` em vez de `melhoria`, mesmo mecanismo) para todo padrão de comportamento
   observado nesta fatia que faça sentido generalizar para o plugin — não algo específico deste
   projeto, mas algo que outro projeto usando o pipeline também se beneficiaria de ter
   documentado/instruído nos agentes ou skills. Se nenhuma sugestão ou aprendizado concreto surgir
   desta fatia, não abra issue artificial só para cumprir o passo — siga sem abrir nada, mas ainda
   assim não pule a própria avaliação: "nada digno de issue" é uma conclusão válida, "não avaliei"
   não é.

   **Toda issue criada aqui leva dois labels, para ficar identificável contra a implementação que
   a originou:**
   - **Tipo**: `melhoria` ou `aprendizado`, conforme acima.
   - **Origem**: `spec:<projeto>/<slug>`, onde `<projeto>` é o nome do repositório onde esta
     sessão está rodando agora (`basename "$(git remote get-url origin)" .git`, ou o nome do
     diretório de trabalho se não houver remote configurado) e `<slug>` é a feature desta fatia —
     permite filtrar depois, no `asengardeon/btt-sdd-pipeline`, todas as issues originadas da
     mesma spec/projeto.

   Antes de usar qualquer um desses labels pela primeira vez neste repositório, confirme que
   existe (`gh label list --repo asengardeon/btt-sdd-pipeline --json name`); se não existir, crie
   com `gh label create <nome> --repo asengardeon/btt-sdd-pipeline --color <hex> --description
   "<descrição curta>"` antes do `gh issue create` — `gh issue create --label` falha se o label
   ainda não existir no repositório de destino.
6. **Só escreva esta mensagem depois de completar 5b (se aplicável) e 5c acima.** Se aprovado,
   informe que a feature está pronta ponta a ponta pelo pipeline SDD, e que o merge do PR (GitHub
   Flow) fica a critério do usuário. Se você (ou o usuário) for aguardar o CI terminar antes desse
   merge, siga `docs/GIT-WORKFLOW.md`, seção "Aguardando CI antes do merge" — prefira uma primeira
   espera maior antes da primeira checagem, em vez de checagens curtas desde o início. Se reprovado
   ou aprovado com ressalvas, liste os itens pendentes e quem deve resolvê-los — e siga a seção
   "Retomando para corrigir achados de revisão" da skill `/btt-sdd:implement` (prefira retomar o
   mesmo agente que implementou a fatia via `SendMessage` para correções pequenas e objetivas, em
   vez de invocar um agente novo).

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

Se o Agent tool não estiver disponível, siga o mesmo processo descrito no agente `sre`
diretamente.
