# `grep` antes de concluir: comportamento observável antigo e cópia pré-divergência

Gatilho: regras inegociáveis 6 e 7 — mudança de texto/comportamento de tela já existente, ou
implementação de tela cujo wireframe antecede uma divergência `TRD-N`.

## Mudar texto/comportamento observável de uma tela que já existia antes desta spec

Ao mudar o texto/comportamento observável de uma tela/fluxo que já existia antes desta spec
começar (não uma tela nova introduzida por ela), `grep` os testes e2e de TODAS as specs — não só
a atual — por referência àquele texto/seletor antes de considerar a tarefa completa. O mecanismo
"e2e completo só na última fatia de uma spec" (`docs/CI-WORKFLOW.md`) cria um ponto cego
estrutural: um e2e de uma spec anterior que afirma o texto antigo só é exercitado de verdade
quando a spec atual chegar na própria última fatia — podendo ficar quebrado, sem nenhum CI notar,
por várias fatias. O custo de um `grep` é desprezível comparado ao de descobrir isso tarde, numa
fatia sem nenhuma relação aparente com a mudança original (issue #489,
`asengardeon/btt-sdd-pipeline`).

## Tela cujo wireframe foi desenhado antes de uma divergência `TRD-N`

Ao implementar essa tela (compare a data do wireframe/PRD com a data da divergência no TRD),
`grep` o texto do wireframe por qualquer frase que descreva o comportamento divergente antes de
copiar cópia literal para o componente. Uma divergência `TRD-N` tende a propagar para o
**cálculo/comportamento** (o que o plano de testes verifica) mas não para a **cópia de UI** que
descreve esse mesmo comportamento para quem usa o produto — a cópia vem de uma fonte diferente (o
wireframe, que carrega a versão pré-divergência) e não passa pelo mesmo crivo. Nenhum teste de
comportamento pega isso, porque o texto não afeta o cálculo (issue #497,
`asengardeon/btt-sdd-pipeline`).
