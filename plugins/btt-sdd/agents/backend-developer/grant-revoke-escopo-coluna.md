# `GRANT`/`REVOKE` de privilégio: sempre escopo de coluna, provado via catálogo

Gatilho: regras inegociáveis 8 e 9 — migração que faz `GRANT`/`REVOKE` de privilégio no Postgres,
ou teste dessa migração.

## Regra 8: sempre escopo à(s) coluna(s) exatas, nunca à tabela inteira

`grant update on <tabela> to <papel>` (sem lista de colunas) concede `UPDATE` em **todas** as
colunas da tabela de uma vez — mesmo que a intenção seja só satisfazer uma exigência pontual
(ex.: o lock `SELECT ... FOR KEY SHARE` que toda constraint de chave estrangeira dispara ao
inserir numa tabela que a referencia) — e reabre qualquer coluna que uma migração anterior tenha
bloqueado deliberadamente como defesa em profundidade além de RLS.

O efeito é simétrico e mais perigoso no `down()`: `revoke update on <tabela> from <papel>` (sem
lista de colunas) remove **todos** os `GRANT`s de `UPDATE` do papel na tabela — inclusive os
concedidos por migrações **anteriores**, não relacionadas; um rollback real quebraria
funcionalidade de produção sem nada a ver com a migração atual.

A forma correta é sempre `grant update (coluna) on <tabela> to <papel>` / `revoke update
(coluna) on <tabela> from <papel>`, de modo que tanto o `up()` quanto o `down()` tocam só o que
a própria migração concedeu. Vale sempre que o projeto usa RLS + privilégio de coluna como defesa
em profundidade (`docs/STACK.md`/ADR do projeto) — nunca a forma larga "por conveniência", mesmo
que pareça inofensiva no momento em que é escrita.

## Regra 9: teste prova o escopo via consulta de catálogo, nunca só o comportamento

Um teste que só confirma "a operação de negócio volta a funcionar" (ex.: um `INSERT` na tabela
filha passa a funcionar depois do `GRANT`) não distingue um `GRANT` largo (tabela inteira) de um
`GRANT` escopado (uma coluna) — os dois fazem a operação passar igualmente. Só uma asserção
direta contra o catálogo do banco (`has_column_privilege()`/`has_table_privilege()` no Postgres,
ou equivalente) prova o escopo **mínimo**, não só **suficiente**.

A mesma lacuna vale para o `down()`: um teste de comportamento não detecta que um `REVOKE` sem
lista de colunas também apagou `GRANT`s de coluna pré-existentes de outras migrações — só fica
claro rodando o rollback de fato e consultando o catálogo depois. Toda migração que faz
`GRANT`/`REVOKE` de privilégio (tabela ou coluna, regra 8) inclui, no mínimo, uma asserção de
catálogo cobrindo o `up()` e uma cobrindo o `down()`.
