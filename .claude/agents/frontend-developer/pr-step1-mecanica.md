# Mecânica do PR no passo 1: `Closes #N` e título de quebra de contrato

Gatilho: abrindo ou atualizando o corpo/título do PR da fatia, passo 1 da Fase 2.

## `Closes #N` por issue — nunca lista com vírgulas

Se a tabela "Decomposição de tarefas e dependências" do TRD tem issues do GitHub associadas
(coluna "Issue GitHub" preenchida com `#N`) a tarefas de frontend **ou de trilha `ambos`, se o
backend-developer ainda não a incluiu** cobertas por esta fatia, inclua `Closes #N` no corpo do PR
para cada uma. Se o PR já foi aberto por `backend-developer` em paralelo, **leia o corpo atual
primeiro** — `gh pr view <PR> --json body` — e acrescente ao que já está lá; nunca chame `gh pr
edit --body` com um texto novo construído do zero, que substitui o corpo inteiro e apaga as
linhas `Closes` que a outra trilha já tiver escrito.

Já aconteceu de verdade: a edição final do corpo (a última a rodar, de uma das duas trilhas)
sobrescreveu a seção que a outra trilha tinha escrito antes, incluindo as `Closes` dela — 8 de 11
issues da fatia continuaram abertas depois do merge, só fechadas manualmente pelo orquestrador
(issue #501, `asengardeon/btt-sdd-pipeline`).

**Repita a palavra-chave por issue** — `Closes #117, Closes #118, Closes #119` — nunca a lista
com vírgulas simples (`Closes #117, #118, #119`), que o GitHub aplica **só ao primeiro número** e
deixa as demais abertas em silêncio (`docs/GIT-WORKFLOW.md`, regra 5b). A forma "mais limpa" volta
sozinha se você não lembrar do porquê.

## Título com `!` quando esta fatia porta uma quebra de contrato

Se o TRD marca esta fatia como portadora de uma quebra de contrato (seção "Janelas de quebra de
contrato entre fatias", coluna `!` no título do PR = sim), abra o PR **já com `!` antes dos
dois-pontos no título** (`feat(<spec>)!: <descrição> (F-N)`) ou com o rodapé `BREAKING CHANGE:` no
corpo. Num squash merge o título do PR vira o subject do commit, e esse `!` é o único sinal de
quebra que sobrevive até o cálculo automático de versão — sem ele, uma mudança incompatível é
publicada como MINOR e a seção de quebra de compatibilidade do changelog sai vazia
(`docs/GIT-WORKFLOW.md`, seção "Quebra de contrato e o título do PR"). É um caractere, decidido no
TRD; corrigir depois do merge custa uma versão errada já publicada.
