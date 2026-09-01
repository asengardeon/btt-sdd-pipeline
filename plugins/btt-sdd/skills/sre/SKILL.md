---
name: sre
description: Etapa 6 (final) do pipeline SDD. Use depois que QA e segurança aprovaram uma feature, para validar CI/CD, Docker e Terraform antes do deploy. Também use fora do fluxo de uma feature específica quando o usuário pedir revisão de pipeline ou infraestrutura. Aciona o agente sre para produzir specs/<slug>/sre-review.md.
---

# /btt-sdd:sre

Aciona a **etapa 6** do pipeline SDD descrito em `CLAUDE.md`: validação de CI/CD e infraestrutura.

## Passos

1. Identifique o slug da feature (mesma lógica das skills anteriores).
2. Confirme que `specs/<slug>/qa-report.md` **e** `specs/<slug>/security-review.md` existem com
   veredito aprovado. Se algum faltar, sugira `/btt-sdd:qa` e/ou `/btt-sdd:security` primeiro — não pule
   nenhum dos dois.
3. Invoque o agente `sre` (Agent tool, `subagent_type: "sre"`) passando o caminho do TRD (seção
   de pilares de engenharia/infra), do `qa-report.md` e do `security-review.md`, e instrução para
   produzir `specs/<slug>/sre-review.md` a partir de `specs/_template/sre-review.template.md`.
   **Se outra tarefa desta sessão ainda pode estar ativa na mesma branch**, passe `isolation:
   "worktree"` nesta chamada — nunca deixe dois agentes dividirem o mesmo diretório de trabalho
   (`docs/GIT-WORKFLOW.md`, seção "Isolamento de working tree entre agentes concorrentes").
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
6. Se aprovado, informe que a feature está pronta ponta a ponta pelo pipeline SDD, e que o merge
   do PR (GitHub Flow) fica a critério do usuário. Se você (ou o usuário) for aguardar o CI
   terminar antes desse merge, siga `docs/GIT-WORKFLOW.md`, seção "Aguardando CI antes do merge" —
   prefira uma primeira espera maior antes da primeira checagem, em vez de checagens curtas desde
   o início. Se reprovado ou aprovado com ressalvas, liste
   os itens pendentes e quem deve resolvê-los — e siga a seção "Retomando para corrigir achados de
   revisão" da skill `/btt-sdd:implement` (prefira retomar o mesmo agente que implementou a fatia
   via `SendMessage` para correções pequenas e objetivas, em vez de invocar um agente novo).
6b. **Spec finalizada → aciona `tech-writer` automaticamente.** Se a fatia aprovada (ou aprovada
   com ressalvas) nesta rodada for a **última fatia pendente da feature** (verifique a tabela
   "Decomposição de tarefas e dependências" do TRD: nenhuma outra fatia ainda não
   implementada/mergeada depois desta), a spec está completa ponta a ponta pelo pipeline. Antes de
   informar o usuário sobre o merge, invoque o agente `tech-writer` (Agent tool, `subagent_type:
   "tech-writer"`, ou `/btt-sdd:docs`) para atualizar a documentação do repositório (README,
   `docs/`, ADRs) refletindo o que esta feature introduziu de fato — não é um passo opcional a
   critério do usuário, roda automaticamente sempre que a última fatia é aprovada. Escopo da
   invocação: só o que a feature `<slug>` mudou de verdade (mecanismos novos, comportamento
   documentado alterado), nunca uma reescrita geral não relacionada. Lembre também o usuário que,
   depois do merge desta última fatia, `/btt-sdd:implement` conduz o teste geral obrigatório de
   fim de spec contra produção real (`docs/POST-MERGE-VALIDATION.md`) — não é algo que este agente
   `sre` faz agora, é o próximo passo depois do merge.

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
