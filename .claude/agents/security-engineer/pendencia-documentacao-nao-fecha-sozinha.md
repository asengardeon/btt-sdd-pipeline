# Pendência de documentação não fecha sozinha com a decisão

Gatilho: passos 3a/3b/3c do Processo — um achado recomenda ação futura, ou uma pendência é
resolvida com "aceitar o risco + documentar", ou esta é a última fatia da spec.

## 3a. Recomendação para fatia futura entra em VALIDAR DEPOIS, não só em prosa

Se um achado (mesmo não-bloqueante/ressalva) recomenda uma ação a ser feita por uma fatia futura
(ex.: "estender X quando a fatia N desenhar Y"), não deixe essa recomendação só em prosa dentro do
corpo do achado — registre-a também como uma entrada na seção "Pendências de validação (VALIDAR
DEPOIS)" deste mesmo `security-review.md`. Uma recomendação só em prosa depende de alguém lembrar
de reler aquele parágrafo específico numa rodada futura; `/sdd-pending` só enxerga a seção VALIDAR
DEPOIS, não o corpo dos achados.

## 3b. Resolver com "aceitar o risco + documentar" não fecha o item inteiro

A recíproca do 3a: ao RESOLVER uma pendência assim, a metade que sobrou — escrever a consequência
onde o operador lê — some exatamente no momento em que o risco vira permanente: a pendência é
marcada resolvida, sai de `/sdd-pending`, e a lacuna fica invisível justamente quando deixa de ser
hipotética. Desdobre a parte de documentação num item próprio de "Pendências de validação
(VALIDAR DEPOIS)", com (a) a redação mínima já escrita, (b) o arquivo/seção de destino, e (c) o
dono. Só o item **de decisão** fecha.

Sem dono dentro do próprio PR, o item tende a nunca fechar: a lacuna pode atravessar múltiplas
specs sem o documento ganhar a frase — risco mais grave quando a consequência descrita afeta dado
de terceiros que não participaram da decisão (ex.: CPF, nome, telefone de clientes).

## 3c. Na última fatia da spec, meça — não presuma — que a documentação aconteceu

`grep` no README/doc de destino pelos termos da consequência — em vez de presumir que "o usuário
decidiu, logo está tratado". Atenção à armadilha inversa: o termo pode aparecer no documento sem
comunicar a limitação — por exemplo, descrito como capacidade ou redigido em tom de tranquilização
dentro da própria seção "Limitações conhecidas". Confirme que a frase realmente expõe o risco para
quem lê, não que apenas contém a palavra-chave.
