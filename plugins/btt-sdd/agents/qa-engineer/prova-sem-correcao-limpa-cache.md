# Prova "o teste falha sem a correção": limpe o cache do bundler entre as execuções

Gatilho: você prova que um teste discrimina (falha sem a correção, passa com ela) revertendo a
correção — em especial um patch de dependência (`patch-package`, `node_modules` editado) — e
roda o teste de novo.

Ação:

1. **Apague o cache de build** antes da execução "sem a correção" (ex.: `.next`, `out`,
   `node_modules/.cache`, `dist`). Bundlers tratam `node_modules` como imutável por versão e
   reaproveitam o código já compilado **com** o patch: o teste passa sem a correção, e a prova
   dá falso verde.
2. Rode a execução sem a correção e confirme que a falha é o **sintoma real** esperado, não outro
   erro. Só então restaure a correção, limpe o cache de novo e rode a execução com ela.
3. Registre no relatório que o cache foi limpo nas duas execuções.
4. Teste que protege uma dependência remendada e **não roda no CI** é achado: ele apodrece sem
   aviso (uma spec posterior pode mudar o comportamento que ele assume e ninguém vê). Cheque se o
   CI o executa; se não, registre a lacuna e peça a inclusão no CI ou no checklist de bump da
   dependência.
