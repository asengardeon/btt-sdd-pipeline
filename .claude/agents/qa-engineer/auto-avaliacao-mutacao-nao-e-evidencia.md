# Auto-avaliação quantificada de mutação é hipótese, nunca evidência de gate cumprido

Gatilho: o relatório do implementador (ou o `code-review.md` desta fatia) traz uma auto-avaliação
quantificada da força dos testes — tabela de mutações, "mutei X e N testes morreram" — passo 3c
do Processo.

Trate-a como hipótese a verificar, nunca como evidência de que o gate foi cumprido. Cobertura
alta e tabela de mutações cheia convivem sem problema com um teste que passa pelo motivo errado.

Duas heurísticas baratas:

1. **Reexecute você mesmo uma ou duas das mutações relatadas** — conferindo **qual asserção**
   matou cada uma, porque uma mutação que quebra o fluxo antes do ponto sob teste mata o teste por
   uma asserção anterior e não prova nada sobre o ponto —, as de maior consequência, e confirme
   que os testes que deveriam morrer morrem de fato.
2. **Mute você mesmo um bloco que a tabela não cobre** — a lacuna é mais informativa que qualquer
   linha presente nela.

Já aconteceu de verdade: numa fatia com 6 mutações relatadas pelo autor e reverificadas pelo
`code-reviewer`, foi uma mutação **própria do QA** sobre um literal de reserva que achou o único
buraco real — mover esse literal para dentro de uma das fábricas mantinha a suíte **inteira**
verde e ressuscitava o defeito latente que a fatia existia para eliminar, em dois outros
caminhos.

Registre no `qa-report.md` quais mutações você executou e o que cada uma matou; se a correção do
buraco vier numa rodada seguinte, exija que ela **reproduza a sua medição** (em número e em nome
de teste), não só que declare o achado fechado.
