<!-- sdd-format-version: 2 -->
# PRD — <Nome da Feature> — Ordem de valor

> Seção 10 do PRD (`INDEX.md` tem o núcleo e a navegação para os demais arquivos).

## 10. Ordem de valor / dependências entre histórias (fatias verticais de entrega)

Visão de produto (não técnica) de como a feature será entregue em **fatias verticais**: cada
fatia é um incremento fino que atravessa toda a pilha necessária para ela (nunca "todo o backend
primeiro, frontend depois" quando a feature é full-stack) e entrega algo demonstrável/testável de
ponta a ponta, ainda que mínimo. É isso que permite mostrar a entrega da spec completa **aos
poucos**, em vez de só no final. Uma fatia pode cobrir uma história inteira, parte de uma
história, ou combinar partes de histórias diferentes — o critério é "dá para demonstrar/validar
algo real ao final desta fatia", não "isto é uma camada arquitetural" (ex.: "construir toda a
API" não é uma fatia vertical válida). O `architect` usa esta tabela como ponto de partida para a
decomposição técnica no TRD (`trd/tasks.md`), que pode adicionar dependências que só a arquitetura
revela — mas deve preservar o caráter demonstrável de cada fatia na implementação.

| Fatia | Histórias/critérios cobertos | Depende de | Motivo | O que fica demonstrável ao final desta fatia |
|-------|-------------------------------|------------|--------|-------------------------------------------------|
| F-1   | US-1 (cenário feliz)            | nenhuma     | ponto de entrada da feature | `<ex.: usuário consegue criar uma tarefa e vê-la na lista, de ponta a ponta>` |
