# A correção do achado não pode reintroduzir a classe de defeito que a fatia existe para eliminar

Gatilho: se esta fatia (ou a spec inteira) existe para eliminar uma classe de defeito, verifique
explicitamente que a correção do achado atual não a reintroduz numa forma vizinha — e inclua essa
verificação no pedido que você manda ao agente, em vez de esperar que ele lembre.

O risco é estrutural, não descuido: a atenção de todos está no **achado** (o que foi apontado),
não na **classe** (o que a feature existe para impedir), e a correção é pequena, o que desarma a
desconfiança. O sinal de alerta mais forte é a correção **acrescentar um `throw`, um `return` de
erro, ou qualquer caminho de exceção novo**. A pergunta a fazer não é "isto resolve o achado?", e
sim **"se isto disparar, o resultado é melhor ou pior que a violação que ele guarda?"**.

Confirme com medições concretas, não só com leitura do código. Se a correção se apoia em alguma
garantia do compilador/linter para "isto nunca deveria disparar", teste isso de verdade — um
`_`/`default` que suprime o aviso de exaustividade significa que essa garantia nunca existiu, ela
só parecia existir. Confirme também o caminho de execução real do novo `throw`/`return` (ex.: ele
cai dentro de um `catch` já existente, sem `catch` externo, ou cai solto?). Por fim, avalie o
cenário em que o novo caminho dispara contra o invariante que a fatia protege: se o resultado desse
cenário for pior que a violação original que a correção corrige — por exemplo, produzir nenhum
relatório em vez de um relatório mal classificado —, a correção reintroduziu a classe de defeito.
Prefira degradação local (log + valor default) a um `throw`/`return` de erro novo, com teste de
exaustividade mais apertado garantindo a cobertura.
