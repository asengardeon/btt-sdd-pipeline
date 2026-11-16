# Teste de não-exposição de segredo: aplique você mesmo a mutação que expõe o valor

Gatilho: a fatia traz um teste cujo nome ou asserção diz que um segredo (token de sessão, chave,
senha, cookie) "nunca aparece", "não é exposto" ou "não vaza" em resposta, log ou cabeçalho.

Esse tipo de teste passa sempre quando procura o valor errado. Um helper de preparação que já fez
um login deixa outra sessão com outro token, e o teste que lê "o primeiro token da tabela" procura
o valor errado.

1. **Confira de onde vem o valor procurado.** Ele precisa sair do mesmo contexto (sessão, cookie,
   usuário) que fez a requisição inspecionada.
2. **Aplique você mesmo a mutação que expõe o valor** (por exemplo, devolver o token da sessão
   corrente num cabeçalho de toda resposta) e confirme que o teste falha. Uma suíte inteira verde
   com essa mutação aplicada é achado bloqueante.
3. Registre no `qa-report.md` a mutação aplicada e o teste que a matou. A ausência de asserção
   vermelha não é prova de que o segredo não vaza.
