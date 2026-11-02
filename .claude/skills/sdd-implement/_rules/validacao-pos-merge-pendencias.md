# Validação manual pós-merge contra produção real

Gatilho: você (o orquestrador) faz uma validação manual pós-merge contra produção real (browser
automation, CLI do provedor, checar DNS, tail de logs, etc. — checklist em
`docs/POST-MERGE-VALIDATION.md`) para confirmar um item que `qa-report.md`/`trd.md` tinha marcado
como "VALIDAR DEPOIS" (ex.: "confirmar isso contra produção depois do deploy").

**Feche o ciclo**: rode `/sdd-amend` para marcar o(s) item(ns) `QA-N`/`TRD-N` correspondente(s)
como "validado" no artefato de origem. Não deixe isso implícito — sem esse passo, `/sdd-pending`
continua listando o item como pendente indefinidamente mesmo depois de validado de verdade.

**Teste geral obrigatório ao mergear a última fatia de uma spec.** Além de fechar itens VALIDAR
DEPOIS pontuais, se o merge que você acabou de confirmar é o da **última fatia pendente** da
feature, conduza também o teste geral de fim de spec (`docs/POST-MERGE-VALIDATION.md`, seção
"Teste geral obrigatório ao finalizar uma spec") — os principais critérios de aceite do PRD
exercitados de ponta a ponta contra produção real. Isso não é opcional nem fica a critério do
usuário pedir; é parte de considerar a spec de fato concluída.
