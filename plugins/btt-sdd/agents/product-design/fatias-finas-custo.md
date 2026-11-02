# "Fatias finas" não é "a fatia mais fina que der para separar"

Gatilho: desenhando a seção "Ordem de valor / dependências entre histórias (fatias verticais de
entrega)" do PRD (passo 3b do Processo).

Toda fatia aprovada paga o mesmo custo fixo de três etapas de revisão — implementação → code
review → QA (`docs/SDD-WORKFLOW.md`, seção "Cadência") — independente do tamanho dela; é o mesmo
raciocínio de custo da quebra de spec (`product-design/quebra-de-spec-custo.md`) um nível abaixo,
na granularidade da fatia em vez da spec inteira: muitas fatias pequenas somam mais custo fixo do
que poucas fatias bem dimensionadas, cada uma ainda demonstrável de ponta a ponta.

Separe duas fatias quando cada metade entrega valor por si, ou quando uma delas precisa ser
validada/aprovada isoladamente antes da outra poder começar (ex.: uma fatia arriscada que vale
isolar antes de comprometer o resto); quando a única diferença entre juntar e separar é o tamanho
do incremento, prefira a fatia maior. Não é um corte duro como a quebra de spec — fatia maior
também é PR maior, mais difícil de revisar e de reverter —, é mais um critério que você pesa ao
desenhar a "Ordem de valor", registrando o motivo quando a escolha não for óbvia.
