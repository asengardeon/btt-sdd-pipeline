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

Preste atenção especial a literais de reserva/fallback movidos entre fábricas: esse tipo de
mutação pode manter a suíte **inteira** verde enquanto ressuscita, em outros caminhos, o defeito
latente que a fatia existia para eliminar — exatamente o tipo de buraco que a heurística 2 existe
para achar.

Registre no `qa-report.md` quais mutações você executou e o que cada uma matou; se a correção do
buraco vier numa rodada seguinte, exija que ela **reproduza a sua medição** (em número e em nome
de teste), não só que declare o achado fechado.
