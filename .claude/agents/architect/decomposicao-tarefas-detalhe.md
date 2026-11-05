# Decomposição de tarefas: armadilhas específicas

Gatilho: ao preencher "Decomposição de tarefas e dependências (fatias verticais de entrega)" —
complementa o núcleo (que tem a regra básica de `Validação na fatia`, dependências e issues do
GitHub). Leia a seção abaixo cujo gatilho bater.

## Nunca use `|` literal numa célula da tabela

**Nunca use o caractere `|` literal ou escapado (`\|`) dentro de uma célula desta tabela** — os
scripts que leem esta tabela (`sdd-status`, `sdd-pending`) fazem `split` ingênuo por `|`, e um
`\|` dentro do texto de uma célula ainda conta como separador de coluna para eles, deslocando
todas as colunas seguintes daquela linha. Se precisar mesmo citar um valor com `|` (union
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
documentada no TRD" já parece suficiente para cada revisor confirmar que a tarefa está completa.
O efeito é a variável ausente só falhar de forma obscura na primeira requisição que precisar dela
em produção, em vez de falhar rápido na release phase (issue #498).

## Referencie o critério de aceite, não reformule

**Para cada tarefa que implementa um critério de aceite já mapeado na seção 6 deste TRD (tabela
de critérios de aceite/casos de uso)**, referencie o critério diretamente no texto da tarefa (ex.:
"conforme US-2, seção 6") em vez de reformulá-lo livremente — uma paráfrase resumida cria uma
superfície de divergência textual dentro do próprio documento, que ninguém mais confere antes da
aprovação. Se preferir resumir para caber na tabela, releia a seção 6 correspondente ao escrever
cada linha (não confie em ter lido antes) e garanta que o resumo é logicamente equivalente, não
uma versão editada/reduzida do comportamento exigido: uma divergência assim passa pelo code review
sem ser notada e só é pega no QA, com o comportamento errado já implementado.

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
hoje?* Se a resposta exige um arquivo que outra tarefa desta fatia vai criar, é o segundo caso. Esse
erro de classificação tende a se repetir dentro do mesmo TRD: uma investigação classificada errado
raramente é a única — confira todas as investigações da spec pelo mesmo critério, não só a
primeira que você revisar.

**O mesmo critério vale para tarefa de e2e ou de integração que exercita código de outra tarefa
desta fatia**, não só para investigação `[medido]`. A tarefa de e2e depende de toda tarefa que
implementa algo que ela exercita. Declare isso na coluna "Depende de", mesmo quando a ordem parece
óbvia. Exemplo: uma tarefa de e2e que testa rotas HTTP depende de cada tarefa que implementa uma
dessas rotas. Numa fatia de UI, a tarefa que bate contra o backend depende das tarefas que expõem
as rotas chamadas. "Parece óbvio" não é dependência declarada: quem monta o plano da rodada lê a
coluna, não a intenção. Nenhum gate automático confere essa dependência — hoje, a lacuna só é pega
por leitura manual antes de planejar a rodada.

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
custo de manter compatibilidade). Sem essa decisão registrada aqui, a lacuna só aparece tarde — na
revisão de SRE, depois do merge — forçando a mesma escolha reativamente, com custo maior de
corrigir.

**Registre também, na coluna `!` no título do PR da mesma tabela, que a fatia portadora da quebra
precisa de `!` antes dos dois-pontos no título do seu PR** (`feat(<spec>)!: ...`), ou do rodapé
`BREAKING CHANGE:`. Isso não é formalidade de commit: em repositório com release automatizado a
partir de Conventional Commits — o default que este pipeline empurra, via lint do título do PR —
o título do PR vira o subject do commit de squash, e o `!` é o **único** sinal de quebra que
sobrevive ao merge. Sem ele, o cálculo de versão classifica a mudança como MINOR e a seção "quebra
de compatibilidade" do changelog sai vazia — mesmo quando a quebra já está documentada nos outros
artefatos (PRD, TRD, README); esse gap só aparece na revisão de SRE, a última etapa, como ressalva
bloqueante no ato do merge. Você é a primeira etapa que sabe qual fatia carrega a quebra —
registrar isso aqui, em forma acionável, evita essa reconciliação reativa no fim.
