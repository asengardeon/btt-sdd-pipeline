# Plano de testes: mecanismo vs. critério, e armadilhas de recorte

Gatilho: ao escrever o plano de testes de alto nível (seção 8 do TRD) — complementa o núcleo (que
tem a regra básica de escrever critério, não mecanismo).

## Nenhuma contagem, nenhuma enumeração

Dois eixos concretos a evitar na redação:

- **Nenhuma contagem**: "nos 6 estados", "os 3 casos de precedência". Contagem é a forma mais
  frágil de mecanismo — convida a conferir o número em vez do critério, e envelhece a cada
  variante nova. Escreva "toda renderização visível", "trocar a ordem de qualquer par adjacente
  mata ao menos um teste".
- **Nenhuma enumeração de quais propriedades asseverar**, pelo mesmo motivo: é a segunda
  enumeração escondida na mesma frase, e corrigir só a primeira **move** o defeito em vez de
  eliminá-lo.

Medido de verdade: numa fatia, **seis** frases de artefato que descreviam o mecanismo de uma
garantia foram desmentidas por medição em quatro rodadas de revisão distintas — **quatro das seis
estavam nesta seção** ou em docblock de teste. Duas mutações de ordem sobreviveram a 113/113
testes verdes contra uma linha que dizia "os 3 casos de precedência"; e depois de a linha ser
reescrita trocando contagem por critério, o defeito seguinte entrou pelo eixo das propriedades (a
ligação estado→cópia só tinha asserção negativa em 2 das 5 renderizações, e duas mutações
sobreviveram à suíte inteira, 1644/1644 verdes). Contra-exemplo útil da mesma fatia: um ADR
atravessou-a inteira sem ser desmentido porque dizia **onde** uma coisa vivia, não **o que** a
fazia existir — afirmação mais fraca, e por isso durável.

**Sempre que descrever uma tarefa como "e2e do fluxo humano" (ou equivalente) e este projeto não
tiver uma suíte de e2e de browser real contra um backend real disponível** (verifique
`docs/TESTING.md`/`docs/STACK.md` — ausência de harness documentado é o sinal), especifique já
aqui o mecanismo de verificação alternativo esperado (ex.: "via integração HTTP encadeada entre os
endpoints reais, sem dublê, seguindo o padrão de `specs/<slug-de-referência>`") em vez de deixar
essa decisão implícita para quem implementa descobrir ou perguntar no meio da fatia. Já aconteceu
de verdade: a mesma decisão (integração HTTP encadeada como equivalente a "e2e do fluxo humano"
sem harness de browser) teve que ser tomada duas vezes em fatias diferentes do mesmo projeto — uma
invocação inteira de agente a mais só para redescobrir um precedente que já existia.

## E2e do fluxo humano: roteiro percorrido do primeiro passo para trás

**Toda tarefa de "e2e do fluxo humano da fatia" tem o roteiro percorrido do primeiro passo para
trás.** Confirme que cada pré-condição dele tem produtor publicado nesta fatia. Isto é distinto do
item anterior — lá a pergunta é se o projeto tem harness de browser; aqui é se o roteiro tem
**início alcançável**. Olhe o primeiro passo do fluxo que você declarou demonstrável. Liste o que
ele pressupõe: sessão autenticada, credencial já ativada, dado-semente, confirmação por e-mail.
Para cada pré-condição, confirme que o produtor dela é publicado **nesta** fatia. Produtor é a
rota, a tela ou o comando de ferramental que a satisfaz. Quando o produtor estiver numa fatia
posterior, decida a saída aqui, no TRD. **Nunca** deixe essa decisão para quem implementa
descobrir no meio da fatia. As três saídas:

- traga o produtor mínimo para esta fatia;
- dê ao ferramental de provisionamento um modo que dispense a tela ausente;
- declare na célula da tarefa que o e2e cobre só o alcançável, e nomeie o que fica de fora.

As asserções de completude que você já escreve não pegam isso. Elas cobram "toda permissão
declarada tem rota" e "toda rota tem handler". Nenhuma cobra que o primeiro passo do roteiro tenha
porta de entrada nesta fatia. O TRD é a fonte do recorte, então uma fatia internamente consistente
passa por toda revisão que confere código contra TRD. Já aconteceu de verdade, numa fatia
full-stack com o harness disponível. O roteiro começava por uma sessão de administração. A
credencial nascia por CLI, **não ativada**, com token de senha por e-mail. A rota que consome esse
token estava na fatia seguinte, por decisão de recorte. Medido contra a pilha real, o link caía no
coringa do roteador e a rota de conclusão respondia 404. Um teste unitário da própria fatia
**assegurava** que ela ficasse ausente. A fatia era consistente e cada tarefa cumpria sua célula.
O roteiro demonstrável dela era inalcançável por construção. O custo apareceu no meio da
implementação, com o ambiente já de pé. É a mesma classe que um TRD real já registrou para o
**caminho de escrita**, agora no **caminho de entrada**.

## Mecanismo de escopo explícito: recomende teste de arquitetura dedicado

Quando o TRD/ADR descreve um mecanismo de escopo explícito — uma chamada obrigatória antes de
outra, que o compilador não força (ex.: isolamento multi-tenant via transação/escopo de RLS, ou
qualquer "chame X antes de Y" que depende de disciplina do consumidor em vez de tipo) — registre
também, na mesma seção que descreve o mecanismo, a recomendação de um **teste de arquitetura
dedicado**: percorrer todos os consumidores do port marcado como "escopado" e falhar se algum não
estiver dentro da chamada de escopo correspondente. É o mesmo espírito de "guarde-o por teste, não
por prosa", aplicado a um mecanismo que se repete por consumidor em vez de existir num ponto só —
e é exatamente por se repetir por consumidor que uma garantia sustentada só por disciplina/revisão
escala mal. Já aconteceu de verdade: numa migração/reimplementação do mesmo mecanismo de escopo, o
mesmo defeito estrutural (ler um port escopado sem instalar o escopo primeiro) apareceu em **seis**
consumidores diferentes, cada um descoberto um a um por medição ao vivo — e mesmo depois da
primeira rodada de correções, cada lente de revisão subsequente (grep por sintaxe literal, leitura
de todo consumidor, mutação própria) achou instâncias novas que a lente anterior não cobria,
porque cada uma buscava por um ângulo ligeiramente diferente. Um teste de arquitetura dedicado,
registrado no TRD/ADR desde o início, teria pego a maioria desses bugs antes de qualquer medição
manual (issue #444, `asengardeon/btt-sdd-pipeline`).

## Troca de null-object para adapter real: nomeie teste de concorrência real

Ao desenhar um port como null-object com troca para um adapter real planejada para uma spec
futura, nomeie já no TRD dessa spec futura um teste de concorrência real entre o novo adapter e
qualquer caso de uso de spec anterior que escreva na mesma entidade. Trocar o binding não é "só"
ativar uma regra já desenhada — é introduzir, de fato, concorrência real entre código de specs
diferentes que nunca foi exercitado junto, porque os dois lados nasceram em sessões/specs
diferentes. Não deixe implícito que "a suíte de X e a suíte de Y, somadas, já cobrem a interação
entre X e Y" — nenhuma das duas, isolada, testa a corrida real. Já aconteceu de verdade: a troca de
binding ativou uma corrida real entre um caso de uso já mergeado (de uma spec anterior) e dois
casos de uso novos (desta spec) escrevendo na mesma linha — só descoberta por medição manual com
duas conexões interleaved, porque nenhuma suíte testava os dois lados em concorrência (issue #496,
`asengardeon/btt-sdd-pipeline`).
