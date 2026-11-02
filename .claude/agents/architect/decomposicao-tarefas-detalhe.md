# Decomposição de tarefas: armadilhas específicas

Gatilho: ao preencher "Decomposição de tarefas e dependências (fatias verticais de entrega)" —
complementa o núcleo (que tem a regra básica de `Validação na fatia`, dependências e issues do
GitHub). Leia a seção abaixo cujo gatilho bater.

## Nunca use `|` literal numa célula da tabela

**Nunca use o caractere `|` literal ou escapado (`\|`) dentro de uma célula desta tabela** — os
scripts que leem esta tabela (`sdd-status`, `sdd-pending`) fazem `split` ingênuo por `|`, e um
`\|` dentro do texto de uma célula ainda conta como separador de coluna para eles, deslocando
todas as colunas seguintes daquela linha (já aconteceu de verdade: uma célula descrevendo valores
literais entre aspas com `'a' \| 'b'` fez o parser contar colunas a mais e ler o Status errado,
reportando uma fatia já mergeada como pendente). Se precisar mesmo citar um valor com `|` (union
type, opções separadas por barra), reescreva como prosa (`'a', 'b' ou 'c'`) ou use a entidade HTML
`&#124;` quando a barra for genuinamente necessária no texto renderizado.

## Toda porta/adapter nova com variável de ambiente nova

**Toda tarefa que desenha uma porta/adapter de saída nova que fala com um serviço externo e
introduz variável(is) de ambiente nova(s) tem, como critério de aceite explícito no texto da
tarefa, "variáveis de ambiente novas adicionadas a `.env.example` e ao validador de ambiente desta
stack (ou equivalente)" — não só documentar a variável em prosa na seção de infraestrutura.**
Documentar a *existência* da variável não garante que ela entre no mecanismo de fail-fast: sem
esse critério de aceite explícito, nenhuma das rodadas de revisão que passam pelo mesmo código
(code review, QA, segurança) tem motivo para verificar a ausência, porque "a variável está
documentada no TRD" já parece suficiente para cada revisor confirmar que a tarefa está completa —
até um primeiro deploy real falhar de forma obscura na primeira requisição que precisar da
variável ausente, em vez de falhar rápido na release phase (issue #498,
`asengardeon/btt-sdd-pipeline`).

## Referencie o critério de aceite, não reformule

**Para cada tarefa que implementa um critério de aceite já mapeado na seção 6 deste TRD (tabela
de critérios de aceite/casos de uso)**, referencie o critério diretamente no texto da tarefa (ex.:
"conforme US-2, seção 6") em vez de reformulá-lo livremente — uma paráfrase resumida cria uma
superfície de divergência textual dentro do próprio documento, que ninguém mais confere antes da
aprovação. Se preferir resumir para caber na tabela, releia a seção 6 correspondente ao escrever
cada linha (não confie em ter lido antes) e garanta que o resumo é logicamente equivalente, não
uma versão editada/reduzida do comportamento exigido. Já aconteceu de verdade: uma tarefa dizia
"estado `empty` sem mudança", divergindo da própria seção 6 do mesmo TRD (que exigia um link
secundário desaparecer nesse estado) — o `frontend-developer` seguiu a tarefa ao pé da letra e
entregou o comportamento errado, só pego pelo QA depois de code review já ter aprovado.

**Preserve o caráter vertical de cada fatia**: agrupe as tarefas para que, ao final de todas as
tarefas de uma fatia, ela seja demonstrável de ponta a ponta — nunca sequencie de forma que uma
fatia só termine quando "todo o backend" ou "todo o frontend" da feature inteira estiver pronto.
Se uma fatia do PRD não for tecnicamente viável como um incremento vertical isolado (ex.: uma
dependência de infraestrutura compartilhada obriga agrupar duas fatias), registre essa divergência
explicitamente e explique o motivo — não silencie a mudança em relação ao que o PRD propôs.

## Tarefa de investigação: "primeiro" só vale para medir a plataforma isoladamente

Se alguma decisão desta spec depende da forma concreta de um contrato externo que ninguém
observou ainda (`architect/contrato-externo-nao-observado.md`): a **primeira tarefa da primeira
fatia que depende dessa estrutura é a tarefa de investigação** que a captura — antes de qualquer
tarefa que escreva código de produção contra ela. Ela entra na tabela como qualquer outra tarefa
(com Issue GitHub, Status, trilha), não como nota de rodapé, e as tarefas que dependem dela
declaram essa dependência na coluna de dependências.

**Mas "primeiro" só vale para investigação que mede a plataforma isoladamente — declare qual dos
dois casos é o seu, tarefa por tarefa.** São duas classes, e só uma pode preceder o código:

- **Mede a plataforma isoladamente** (ex.: "que código HTTP o serviço devolve para endereço
  revogado", "qual o nome acessível real daquele elemento no site de terceiro"): roda **antes** de
  qualquer código, "Depende de" pode ser `nenhuma`. É o caso default.
- **Mede o comportamento da plataforma contra artefato produzido por outras tarefas da mesma
  fatia** (ex.: "o navegador oferece instalar com *este* manifest e *este* service worker?", "a
  sessão sobrevive a reabrir *no app instalado*?"): **não pode** preceder o artefato. Aqui a
  coluna "Depende de" **nunca** diz `nenhuma` — lista as tarefas cujo artefato a medição exige —,
  o texto da tarefa diz que ela roda **ao fim** da fatia, e o plano de testes não afirma que "as
  investigações rodam antes de escrever código" sem qualificar **quais**.

Pergunta que separa os dois casos em um passo: *a medição é possível com o repositório como está
hoje?* Se a resposta exige um arquivo que outra tarefa desta fatia vai criar, é o segundo caso. Já
aconteceu de verdade: uma investigação com cinco perguntas, "Depende de" marcado `nenhuma` e plano
de testes afirmando que rodava antes do código — **todas as cinco** exigiam o manifest, os ícones
e o service worker de três tarefas irmãs. A fatia teve de ser reordenada em execução, com emenda
ao TRD, e o mesmo TRD tinha outras duas investigações com o mesmo defeito, prontas para repetir o
episódio duas vezes.

**O mesmo critério vale para tarefa de e2e ou de integração que exercita código de outra tarefa
desta fatia**, não só para investigação `[medido]`. A tarefa de e2e depende de toda tarefa que
implementa algo que ela exercita. Declare isso na coluna "Depende de", mesmo quando a ordem parece
óbvia. Exemplo: uma tarefa de e2e que testa rotas HTTP depende de cada tarefa que implementa uma
dessas rotas. Numa fatia de UI, a tarefa que bate contra o backend depende das tarefas que expõem
as rotas chamadas. "Parece óbvio" não é dependência declarada: quem monta o plano da rodada lê a
coluna, não a intenção. Já aconteceu de verdade: numa única fatia, duas tarefas de e2e ficaram com
a dependência ausente da tabela. Nas duas vezes foi leitura manual antes de planejar a rodada que
pegou a lacuna, não um gate.

## Janela de quebra de contrato entre fatias

Para cada fatia que introduz uma mudança de contrato obrigatória (campo novo obrigatório numa API,
mensagem/evento com formato incompatível, remoção de suporte a um formato antigo): pergunte
explicitamente se essa mudança só fica coerente depois que outra fatia (posterior, ex.: a que
atualiza o cliente/frontend) também mergear — se sim, essa fatia introduz uma **janela de quebra
entre fatias**, e o TRD precisa dizer isso, não deixar implícito. Registre a janela na tabela
desta seção (nota na linha da tarefa, ou subseção própria "Janelas de quebra de contrato entre
fatias" logo abaixo da tabela) e já proponha a mitigação como parte do desenho — campo opcional
com fallback para o valor antigo até a fatia seguinte mergear é o padrão default; segurar o merge
até a fatia seguinte estar pronta, ou aceitar a janela conscientemente, são alternativas válidas
se justificadas. Isso é uma decisão de arquitetura sua, não uma pergunta ao usuário por padrão —
só vire `AskUserQuestion` se as opções de mitigação tiverem trade-off real (ex.: janela aceita vs.
custo de manter compatibilidade). Já aconteceu de verdade: um campo obrigatório novo numa fatia só
foi satisfeito pelo frontend em produção duas fatias depois, descoberto só na revisão de SRE da
primeira fatia — o usuário teve que decidir reativamente, no meio da revisão final, entre segurar
o merge, tornar o campo opcional, ou aceitar a janela.

**Registre também, na coluna `!` no título do PR da mesma tabela, que a fatia portadora da quebra
precisa de `!` antes dos dois-pontos no título do seu PR** (`feat(<spec>)!: ...`), ou do rodapé
`BREAKING CHANGE:`. Isso não é formalidade de commit: em repositório com release automatizado a
partir de Conventional Commits — o default que este pipeline empurra, via lint do título do PR —
o título do PR vira o subject do commit de squash, e o `!` é o **único** sinal de quebra que
sobrevive ao merge. Sem ele, o cálculo de versão classifica a mudança como MINOR e a seção "quebra
de compatibilidade" do changelog sai vazia. Já aconteceu de verdade: uma fatia que tornou uma
coluna obrigatória — rejeitando **toda** planilha que o operador já tinha — publicaria `v1.10.0`,
e isso só foi pego na última etapa do pipeline (SRE), como a única ressalva bloqueante no ato do
merge. A declaração da quebra existia nos três artefatos certos (PRD, TRD, README); o que faltava
era ela chegar ao artefato que decide a versão. Você é a primeira etapa que sabe qual fatia carrega
a quebra — registrar isso aqui, em forma acionável, é o que evita a reconciliação reativa no fim.
