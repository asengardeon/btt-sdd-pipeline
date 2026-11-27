# Teste que espera uma exceção: a asserção de falha nunca fica dentro do `try` cujo `catch` a captura

Gatilho: escrevendo ou revisando teste que espera uma exceção com `try { ação; falhar() } catch (Tipo)` em vez do mecanismo nativo do framework de teste (Fase 2, passo 2).

**Se a falha explícita do framework de teste (`fail()`, `assert false`, `raise AssertionError`)
fica dentro do `try`, o `catch` não pode capturar o tipo dela.** Em vários frameworks esse tipo
herda do mesmo ancestral das exceções de domínio. Exemplo: o `fail()` do PHPUnit estende
`RuntimeException`, então `catch (RuntimeException $e)` engole a falha e o teste nunca reprova.

Prefira o mecanismo nativo (`expectException`/`expectExceptionMessage` no PHPUnit,
`pytest.raises`, `assertThrows`). Se precisa inspecionar a exceção, use um helper que captura a
exceção e afirma **fora** do `catch`. O `catch` de um tipo amplo (a classe-base de erros do
runtime ou do framework) só é seguro quando a hierarquia do framework de teste não passa por ele.

Ao achar o padrão num teste, varra o repositório pelo mesmo uso: no caso que originou a regra eram
mais 7 ocorrências. Um teste com esse defeito não prova nada: uma mutação do código de produção
sobreviveu a 79 testes (issue #741, `asengardeon/btt-sdd-pipeline`).
