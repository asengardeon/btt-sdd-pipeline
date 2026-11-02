# Pendência de documentação não fecha sozinha com a decisão

Gatilho: passos 3a/3b/3c do Processo — um achado recomenda ação futura, ou uma pendência é
resolvida com "aceitar o risco + documentar", ou esta é a última fatia da spec.

## 3a. Recomendação para fatia futura entra em VALIDAR DEPOIS, não só em prosa

Se um achado (mesmo não-bloqueante/ressalva) recomenda uma ação a ser feita por uma fatia futura
(ex.: "estender X quando a fatia N desenhar Y"), não deixe essa recomendação só em prosa dentro do
corpo do achado — registre-a também como uma entrada na seção "Pendências de validação (VALIDAR
DEPOIS)" deste mesmo `security-review.md`. Uma recomendação só em prosa depende de alguém lembrar
de reler aquele parágrafo específico numa rodada futura; `/btt-sdd:pending` só enxerga a seção
VALIDAR DEPOIS, não o corpo dos achados — já aconteceu de uma recomendação assim ficar órfã
porque a fatia que deveria endereçá-la nunca chegou a implementar aquele ponto específico.

## 3b. Resolver com "aceitar o risco + documentar" não fecha o item inteiro

A recíproca do 3a: ao RESOLVER uma pendência assim, a metade que sobrou — escrever a consequência
onde o operador lê — some exatamente no momento em que o risco vira permanente: a pendência é
marcada resolvida, sai de `/btt-sdd:pending`, e a lacuna fica invisível justamente quando deixa
de ser hipotética. Desdobre a parte de documentação num item próprio de "Pendências de validação
(VALIDAR DEPOIS)", com (a) a redação mínima já escrita, (b) o arquivo/seção de destino, e (c) o
dono. Só o item **de decisão** fecha.

Já aconteceu três vezes no mesmo projeto, e a assimetria é instrutiva: **a única que fechou foi a
que tinha dono dentro do próprio PR**; as duas que descreviam consequência para dado de terceiro
(CPF, nome, telefone de clientes que não participaram de decisão nenhuma) não tinham dono — e a
mais antiga já atravessou **quatro specs** sem o README ganhar a frase.

## 3c. Na última fatia da spec, meça — não presuma — que a documentação aconteceu

`grep` no README/doc de destino pelos termos da consequência — em vez de presumir que "o usuário
decidiu, logo está tratado". Foi literalmente assim que um achado desta classe apareceu: o `grep`
voltou vazio, enquanto o README apresentava a mesma característica como **capacidade** em três
lugares, um deles dentro da seção "Limitações conhecidas" e ainda assim redigido como
tranquilização.
