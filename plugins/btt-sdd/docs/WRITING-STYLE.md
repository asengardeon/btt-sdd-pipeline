# Estilo de escrita dos artefatos: as regras da ASD-STE100, adaptadas ao idioma

Este pipeline é uma cadeia de artefatos: o PRD é lido por quem desenha, o TRD por quem implementa,
o relatório de revisão pela etapa seguinte. Uma frase ambígua aqui não custa uma correção de texto
— custa retrabalho duas etapas adiante, por reinterpretação.

A **ASD-STE100 (Simplified Technical English)** existe exatamente para esse problema: documentação
técnica que precisa ser executada sem reinterpretação, por quem não a escreveu. Este doc adota o
**conjunto de regras** dela. O gate correspondente, só com os itens verificáveis, está em
`docs/gates/escrita.md`.

## Duas ressalvas sobre a adoção, antes das regras

**1. A STE é um padrão de inglês; aqui adotamos as regras, não o dicionário.** O padrão combina
regras de escrita com um **dicionário controlado** de palavras aprovadas e não-aprovadas. Esse
dicionário é material licenciado da ASD. Não é reproduzível aqui, e não tem equivalente direto em
português. O papel funcional dele é cumprido pelo **glossário do projeto** (seção "Um termo por
conceito" abaixo): a mesma garantia — um conceito, um nome — obtida pelo uso em vez de por lista
fechada. As regras de estrutura de frase, voz, tempo e procedimento valem em qualquer idioma. São
elas que este doc aplica.

**2. O limite é por frase, nunca por conteúdo.** Aplicada ingenuamente, a STE apaga justamente o
que dá autoridade aos documentos deste pipeline: a narrativa de incidente concreto ("já aconteceu
de verdade: ...") que explica **por que** uma regra existe. Isso não é verbosidade — é a evidência
que impede a regra de ser revogada por quem não viu o problema acontecer. Frase longa demais se
**divide**; fato nunca se apaga. Se a escolha for entre uma seção mais longa e um fato perdido, a
seção fica mais longa.

## As regras verificáveis

Estas são as que o gate cobra (`docs/gates/escrita.md`), porque dá para conferir sem discutir
gosto:

1. **Uma ideia por frase.** Duas afirmações independentes numa frase são duas frases. O sinal mais
   comum é a conjunção carregando conteúdo novo em vez de ligar partes da mesma ideia.
2. **Limite de palavras por frase: 20 em texto de procedimento, 25 em texto descritivo.** São os
   limites da STE. Procedimento é toda instrução a executar (passo de skill, item de gate, critério
   de aceite); descritivo é o resto. Contar é o último recurso — a frase que estoura o limite quase
   sempre já falhou na regra 1.
3. **Voz ativa sempre que a frase tem agente identificável.** "O `architect` decide a stack", não
   "a stack é decidida". Passiva fica reservada para quando o agente é genuinamente irrelevante ou
   desconhecido.
4. **Tempo simples.** Presente, passado ou futuro simples. Perífrase ("vai estar sendo validado")
   e condicional empilhado escondem quem faz o quê e quando.
5. **Um termo por conceito, um conceito por termo.** Sinônimo elegante é defeito, não estilo: "a
   fatia", "o incremento" e "a entrega" usados para a mesma coisa obrigam o leitor a decidir se são
   a mesma coisa. Igualmente proibido o inverso — o mesmo termo para dois conceitos ("revisão" para
   code review e para rodada de correção).
6. **Procedimento em imperativo, numerado, uma instrução por item.** Escreva "rode a suíte
   completa". Não escreva "a suíte completa deve ser rodada" nem "é importante que a suíte seja
   rodada". Item com duas instruções vira dois itens.
7. **Sem estilo telegráfico.** Não omita artigo, preposição ou verbo para encurtar. "Grave
   resultado artefato cobertura" não é mais claro que a frase inteira — é mais curto e mais
   ambíguo.
8. **Verbo em vez de nominalização.** "Para validar o contrato", não "para a realização da
   validação do contrato". A nominalização esconde o agente e alonga a frase sem acrescentar nada.
9. **Negação simples, nunca dupla.** "Nenhuma etapa começa sem o artefato aprovado" é claro;
   "não é incomum que etapas não comecem sem que o artefato não esteja aprovado" não é verificável
   por ninguém.

## Os itens de julgamento (orientação, não gate)

Estes mudam a qualidade do texto, mas reprovar um artefato por eles seria reprovar por gosto de
redação. Siga-os; não bloqueie por eles:

- **A informação mais importante primeiro**, na frase e na seção. O leitor que para na primeira
  linha precisa ter recebido o essencial.
- **Tabela ou lista quando a prosa está enumerando.** Três ou mais itens paralelos num parágrafo
  quase sempre cabem melhor numa lista. A lista também torna visível o item que falta.
- **Exemplo concreto onde a regra tem mais de uma leitura plausível.** Um exemplo custa duas linhas
  e elimina uma rodada de pergunta.
- **Nomeie o agente da ação, não o papel genérico.** "O `qa-engineer` reprova" diz mais que "a
  etapa seguinte pode reprovar".

## Um termo por conceito: `docs/GLOSSARY.md`

É o equivalente funcional do dicionário controlado da STE, construído pelo uso em vez de por lista
fechada. **Condicional, mesmo padrão de `docs/BASELINE.md` e `docs/LESSONS-LEARNED.md`**: não
existe por padrão, e a ausência já significa "nenhuma colisão de termo confirmada ainda".

- **Nasce na segunda ocorrência**, igual à promoção de lição aprendida (`docs/gates/licoes.md`).
  A colisão tem duas formas: um conceito com dois nomes em artefatos da mesma spec, ou um nome
  usado para dois conceitos. Quem detectar registra a entrada: o termo escolhido, o que ele
  significa, e os nomes rejeitados. O nome rejeitado fica na entrada de propósito — é por ele que
  a próxima busca encontra o termo certo.
- **Quem consolida é o `tech-writer`** (`agents/tech-writer.md`), convocável a qualquer
  momento. Qualquer agente pode acrescentar uma entrada; nenhum reescreve as dos outros.
- **Precede o artefato novo, não o corrige depois.** Todo agente que escreve artefato lê o
  glossário, se existir, e usa o termo registrado. É a mesma precedência de
  `docs/PROJECT-CONVENTIONS.md` (`docs/AGENT-PREAMBLE.md`).

## Onde isto se aplica — e onde não

**Aplica-se** a:

- os artefatos de `specs/<slug>/` — PRD, TRD, `code-review.md`, `ux-review.md`, `qa-report.md`,
  `security-review.md`, `sre-review.md`, artefatos de tarefa de investigação;
- `docs/`, `README.md` e os ADRs de `docs/adr/` — a documentação de projeto escrita pelo
  `tech-writer` e pelo `codebase-archaeologist` (`BASELINE.md`, `PROJECT-CONVENTIONS.md`);
- **comentários e docstrings de código**. São três lugares: docstring de port, docblock de adapter,
  e o comentário que explica um porquê não óbvio (`CLAUDE.md`, princípio de clean code). Aqui a
  regra 5 é a que mais rende: o nome do conceito no comentário é o mesmo nome no código.

**Não se aplica** a mensagem de commit, corpo de PR e corpo de issue. A exclusão é deliberada.
Esses textos têm convenção própria já definida (`docs/GIT-WORKFLOW.md`). Eles são escritos uma vez
e lidos no contexto do diff. Não são a cadeia de artefatos que uma etapa seguinte executa.

## O que fazer quando a regra e a clareza divergem

A regra serve à clareza, não o contrário. Dois casos reais em que o item verificável atrapalha:
um termo técnico consagrado que não tem equivalente curto, e uma frase cuja divisão quebraria a
relação de causa que ela carrega. Nesses casos, escreva a forma mais clara. Diga por quê, em uma
linha, no próprio artefato. Isso é decisão registrada, não suposição silenciosa
(`docs/gates/governanca.md`): o revisor vê a escolha em vez de reabri-la como achado.
