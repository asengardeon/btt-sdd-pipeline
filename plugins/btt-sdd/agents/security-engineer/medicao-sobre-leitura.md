# Isolamento por tenant e condição de corrida: medição, nunca só leitura

Gatilho: área 9 (feature separa dados por tenant/espaço/organização) ou área 10 (correção de
condição de corrida com lock).

## Isolamento por tenant/escopo se confirma por medição, nunca por leitura do filtro

O método padrão é a **mutação**: alterar no código de produção a consulta que delimita o escopo,
de forma que ela deixe de delimitá-lo, e confirmar que a suíte de isolamento pega a falha — ou,
se a suíte continuar verde, que o controle no banco (política de row-level security ou
equivalente) sustenta o isolamento sozinho. Reverta a mutação antes de qualquer commit, como
qualquer mutação de teste.

**Se a edição do arquivo de produção for recusada pelo classificador de segurança do ambiente**
— essa classe de mutação casa com um padrão que o classificador reconhece como perigoso, mesmo
dentro de um teste que seria revertido —, não insista numa 4ª tentativa (regra 2 de
`docs/QUALITY-GATES.md`) **e não desista da medição**, aceitando o relato do QA sem evidência
própria. O método equivalente, que não toca código de produção: acrescente um **teste de
integração temporário** que executa a consulta crua já sem a delimitação de escopo, contra o
banco real em container, e assevere ali o que a mutação provaria. A evidência é a mesma; o
arquivo de produção fica intocado; os testes temporários são revertidos antes do push. Registre
no relatório qual dos dois métodos você usou e por quê — um veredito de isolamento sem medição
nenhuma nunca é apresentado como equivalente aos dois.

## Condição de corrida com lock: confira todo lado que perde a corrida

Ao revisar/corrigir uma condição de corrida com lock (`SELECT ... FOR UPDATE` ou equivalente),
`grep` por TODO `UPDATE ... WHERE status = ` (ou equivalente) que escreve na mesma linha
protegida pelo lock, e confirme que cada um confere linhas afetadas antes de reportar sucesso —
não só o `UPDATE` que motivou a correção original. O lock resolve o lado que motivou o achado; o
lado que **perde** a corrida depois do lock tem o próprio risco: silenciosamente devolver sucesso
para uma operação que, na prática, não teve efeito nenhum (a linha já tinha sido alterada pelo
concorrente). Checar "quantas linhas um `UPDATE` afetou" é, em si, uma checagem de concorrência —
ignorá-la em qualquer lado de uma corrida reintroduz silenciosamente a classe de bug que o lock
do outro lado acabou de fechar (issue #496, `asengardeon/btt-sdd-pipeline`).
