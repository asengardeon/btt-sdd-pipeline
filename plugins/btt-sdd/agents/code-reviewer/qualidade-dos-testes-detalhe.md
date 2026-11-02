# Qualidade dos testes: verificação de mutação, dublê e cobertura de ausência

Gatilho: ao revisar a área "Qualidade dos testes em si" — detalhe de como verificar auto-avaliação
de mutação relatada pelo implementador, dublês construídos a partir de captura real, e
componentes que renderizam uma região condicionalmente.

## Auto-avaliação quantificada é hipótese a verificar, nunca evidência

**Auto-avaliação quantificada da força dos testes feita pelo próprio implementador — tabela de
mutações, "mutei X e N testes morreram", contagem de asserções discriminantes — é hipótese a
verificar, nunca evidência.** É relato do autor sobre o próprio trabalho, e lê-la e seguir adiante
devolve um gate que *parece* cumprido e não foi. Verifique por amostragem, com duas heurísticas:

(a) **Reexecute você mesmo um subconjunto das mutações relatadas**, escolhendo as de maior
consequência — barato, e detecta tanto engano honesto quanto mutação relatada mas nunca executada.
**Ver a mutação morrer não basta: confira QUAL asserção a matou.** Uma mutação que quebra o fluxo
*antes* do ponto sob teste mata o teste por qualquer asserção anterior, e o vermelho resultante é
indistinguível do que se queria provar. Se ela morreu por uma asserção anterior ao ponto sob
teste, ela não prova nada sobre aquele ponto — construa a mutação complementar, a que mantém o
fluxo íntegro e ataca o **modo de falha oposto** ("a asserção nova ficou tolerante demais?"). O
par das duas é que responde; nenhuma sozinha responde.

(b) **Procure o bloco de código que a tabela não cobre e mute-o você mesmo**. Uma lacuna na tabela
é mais informativa que qualquer linha presente nela, e **um número faltando na sequência (`M5` →
`M7`) é sinal a investigar, não a arredondar como erro de numeração**.

Já aconteceu de verdade: das 6 mutações relatadas pelo autor, as 2 que o revisor criou por conta
própria (num bloco de normalização sem mutação nenhuma na tabela) mataram 1 e 12 testes, e uma
mutação inventada pelo `qa-engineer` na etapa seguinte achou o único buraco real — um literal
movido para dentro de uma fábrica mantinha a suíte **inteira** verde e ressuscitava um defeito
latente em dois outros caminhos.

Ao avaliar a correção de um teste que era instável, pergunte se mudou a **classe** da asserção ou
só a **constante de tempo**: aumentar timeout/delay é adiamento, não correção (`docs/TESTING.md`,
seção "Instabilidade de teste: classe da asserção, não constante de tempo").

## Dublê construído a partir de captura real

Confirme que a captura é da página/resposta **inteira**, não do fragmento de interesse, e que
clique/interação usa a **API estrita de locator** em vez do atalho que resolve para o primeiro
elemento que casar (`docs/TESTING.md`, seção "Fidelidade do dublê derivado de captura real: página
inteira e locator estrito") — um seletor inequívoco no dublê pode ser ambíguo no sistema real, e
aí a API não estrita clica silenciosamente no elemento errado em vez de falhar.

## Componente que renderiza uma região condicionalmente a partir de um valor opcional

(ex.: `useMutation().error` nasce `null`, um VO opcional, um campo de resposta HTTP ausente):
confira se existe pelo menos um teste que afirma a **ausência** desse elemento no estado "sem erro
ainda" — não só a presença de outro elemento qualquer nesse mesmo cenário. A amostragem tende a
verificar só presença ("o formulário mostra o campo X"), nunca ausência, e um alerta
falso-positivo sempre visível (ex.: mensagem de erro renderizada mesmo sem nenhuma tentativa de
submissão) só aparece quando alguém testa a ausência explicitamente. Lacuna de cobertura é achado
por si só, mesmo que o bug ainda não tenha se manifestado (issue #494,
`asengardeon/btt-sdd-pipeline`).
