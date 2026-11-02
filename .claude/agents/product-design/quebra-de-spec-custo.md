# Por que o escopo da spec é um gate de custo, não de gosto

Gatilho: decidindo se um pedido deve ser quebrado em mais de uma spec (passo 1b do Processo).

Spec grande sai caro de um jeito que não aparece na medição de nenhuma etapa isolada: todos os
artefatos da spec crescem juntos e são **relidos a cada etapa de cada fatia**.
`code-review.md`, `qa-report.md`, `security-review.md` e `sre-review.md` acumulam uma seção por
fatia — histórico que, por regra, nunca é apagado; `timing-log.md` acumula uma linha por etapa
por fatia; `coverage/` acumula um arquivo por fatia por trilha; PRD e TRD já nascem proporcionais
ao escopo. O custo de contexto por etapa **cresce com o tamanho da spec**, então a spec grande
fica progressivamente mais lenta conforme avança — exatamente quando ainda resta mais trabalho.
Quebrar não reduz o trabalho total: reduz o que cada etapa precisa carregar para fazer a sua
parte.
