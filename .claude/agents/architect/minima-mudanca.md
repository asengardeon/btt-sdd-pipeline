# Modo de mínima mudança arquitetural

Gatilho: o argumento `--minima-mudanca` em `/sdd-trd`, ou `Modo arquitetural: mínima mudança` no
cabeçalho do PRD (`prd/INDEX.md`). A declaração vale só para esta spec; uma spec posterior do
mesmo projeto declara de novo. Evolução de sistema existente é o caso típico.

No modo ativo, anote `Modo arquitetural: mínima mudança` no cabeçalho do `trd/INDEX.md` e escreva
a seção "3b. Mínima mudança arquitetural" de `trd/architecture.md`, com três elementos
obrigatórios:

1. **Peças novas e por que o existente não basta.** Uma linha por peça nova (camada, contrato,
   componente de entrada ou de saída):

   | Peça nova | Componente existente mais próximo que ela imita | Por que o existente não basta |
   |---|---|---|

   Peça sem componente existente a imitar precisa de justificativa explícita. Antes de propor uma
   peça, procure no código se ela já existe: parte do que se propõe construir costuma existir.
2. **Alternativa conservadora.** Toda decisão que introduz algo novo em "Riscos e trade-offs"
   (`quality.md`) compara com pelo menos uma opção ainda mais conservadora e dá o custo de cada.
3. **Impacto no legado e nos produtos atuais.** Por repositório ou módulo: o que é tocado, o que
   **não** é tocado, e o risco de regressão. Mais a lista de consumidores conhecidos e
   desconhecidos do que está sendo alterado, cada um `[medido]` ou `[não medido]`.

## Lacuna entre o PRD e o mecanismo atual

Onde o PRD exige algo que o mecanismo atual não entrega, **não redesenhe**. Registre a lacuna como
decisão de produto na tabela "Decisões de produto" de `tracking.md`, com o impacto de cada
caminho: aceitar a limitação, ou investir numa mudança maior.

## Decomposição de tarefas

Cada tarefa indica o repositório ou módulo e **um arquivo existente a imitar** como padrão, na
descrição da tarefa.
