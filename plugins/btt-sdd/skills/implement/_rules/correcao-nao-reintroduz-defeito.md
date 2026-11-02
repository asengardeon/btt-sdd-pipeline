# A correção do achado não pode reintroduzir a classe de defeito que a fatia existe para eliminar

Gatilho: se esta fatia (ou a spec inteira) existe para eliminar uma classe de defeito, verifique
explicitamente que a correção do achado atual não a reintroduz numa forma vizinha — e inclua essa
verificação no pedido que você manda ao agente, em vez de esperar que ele lembre.

O risco é estrutural, não descuido: a atenção de todos está no **achado** (o que foi apontado),
não na **classe** (o que a feature existe para impedir), e a correção é pequena, o que desarma a
desconfiança. O sinal de alerta mais forte é a correção **acrescentar um `throw`, um `return` de
erro, ou qualquer caminho de exceção novo**. A pergunta a fazer não é "isto resolve o achado?", e
sim **"se isto disparar, o resultado é melhor ou pior que a violação que ele guarda?"**.

Já aconteceu de verdade: uma fatia existia para impedir que uma exceção lançada de dentro de um
caminho de reporte de falha derrubasse o lote inteiro (via `Task.WhenAll`) em vez de falhar só
aquela linha; na fatia seguinte, a correção de uma ressalva legítima do `code-reviewer` acrescentou
`_ => throw new NotSupportedException(...)` **dentro do mesmo método de renderização de falha** —
passando pelo desenvolvedor *e* pelo revisor que levantou a ressalva, porque ambos olhavam para "a
categoria fica sem declaração?" e não para "o que acontece se isto disparar?". Três medições
desfizeram o caso: acrescentar uma categoria real ao enum e compilar mostrou 0 avisos (o braço `_`
suprime o aviso de exaustividade — a "rede de compilação" que justificaria o `throw` nunca
existiu, ele a *custava*); o caminho real era avaliação ávida dentro de um `catch`, sem `catch`
externo; e no cenário em que dispara, o resultado é **pior** que a violação que ele guarda — o
invariante era "nunca uma falha sem classificação", e o `throw` não produz falha sem
classificação, produz **nenhum relatório para nenhuma linha**, inclusive as bem-sucedidas. A forma
final foi degradação local + teste de exaustividade mais apertado.
