# Teste de não-exposição de segredo: o valor sob teste vem do mesmo contexto da requisição

Gatilho: a fatia traz um teste cujo nome ou asserção diz que um segredo (token de sessão, chave,
senha, cookie) "nunca aparece", "não é exposto" ou "não vaza" em resposta, log ou cabeçalho.

Esse tipo de teste passa sempre quando procura o valor errado. Confira três pontos:

1. **De onde vem o valor procurado.** Ele precisa sair do mesmo contexto (sessão, cookie, usuário)
   que fez a requisição inspecionada. Um valor lido de "o primeiro registro da tabela" pode ser de
   outra sessão, deixada pelo helper de preparação do teste (um login anterior, por exemplo).
2. **Se a asserção procura o valor completo**, não só um prefixo ou o nome do campo.
3. **Se existe prova por mutação.** O autor mostra que o teste falha quando o código expõe o valor
   (por exemplo, devolver o token da sessão corrente num cabeçalho de toda resposta). A prova de
   que não vaza é essa mutação; a ausência de asserção vermelha não prova nada.

Sem os três, registre achado: o teste dá falsa segurança. Peça a correção do contexto do valor e a
mutação que a prova.
