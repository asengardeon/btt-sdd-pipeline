# Contrato concreto contra sistema externo não observado

Gatilho: o TRD depende da forma concreta de um contrato de integração — seletor de DOM de
terceiro, formato de resposta de API não documentada, layout de arquivo/CSV de parceiro, esquema
de webhook, nome de campo de um SSO — que a estrutura real não foi observada, nesta spec ou numa
anterior deste projeto.

Isto é distinto da premissa comportamental de `architect/automacao-navegador-premissa-manual.md`:
lá a premissa é **comportamental** ("login não é exigido"); aqui é a **forma concreta** do
contrato. Duas obrigações, não uma:

- **Marque como provisório no próprio texto onde ele aparece.** Não basta uma pendência distante
  em "VALIDAR DEPOIS": quem implementa lê a seção de desenho, não a lista de pendências.
- **Crie uma tarefa de investigação** na decomposição de tarefas (seção 13), com Issue GitHub
  própria como qualquer outra tarefa — e com o label `premissa-nao-validada`, para ela continuar
  visível em `/sdd-pending` depois que esta spec encerrar (`skills/pending/SKILL.md`, passo 1b);
  registre no corpo da issue quantos consumidores a premissa tem hoje. Posicione-a como **primeira
  tarefa da primeira fatia que depende dessa estrutura** — nunca como pendência "VALIDAR DEPOIS",
  que não bloqueia nada e pode atravessar a spec inteira. A tarefa produz um artefato em
  `specs/<slug>/` com a estrutura real capturada (snapshot ARIA/DOM, payload real, amostra do
  arquivo) e uma seção "correções obrigatórias ao desenho do TRD"; o TRD é emendado (log de
  revisões) **antes** de a fatia prosseguir.
- **Cada pergunta declara a decisão que depende dela** — não só a área da feature a que ela
  pertence superficialmente. Nomeie a tarefa, a fatia e, quando a consequência é de outro domínio,
  a etapa de revisão que vai precisar da resposta (ex.: "alimenta o controle de limpeza de
  armazenamento da T-15, F-3; consequência de **segurança**"). O risco é de catalogação: perguntas
  são agrupadas pela área onde nasceram (instalabilidade, upload, notificação), e quando a decisão
  que elas alimentam está em outra fatia, outra etapa ou outro domínio, **o agente que precisa da
  resposta nunca vê a pergunta** — ele procura premissas do seu próprio domínio, não a lista de
  perguntas da área onde ela foi catalogada. Já aconteceu de verdade: uma pergunta catalogada como
  "instalabilidade" ("a sessão sobrevive a fechar e reabrir no standalone?") decidia uma
  propriedade de **segurança** de outra fatia — se o standalone tem partição de armazenamento
  própria, o `clearAll()` do logout alcança só o contexto que executou o logout, e o requisito
  escrito para "outra pessoa no mesmo aparelho" passa a valer por contexto, não por aparelho. Só
  foi percebido porque o `security-engineer` leu o artefato de investigação inteiro por iniciativa
  própria, numa fatia em que não era obrigado a isso.
- **Marcação por afirmação, dentro do artefato**: cada frase é `[medido]` (com o comando/caminho
  que produziu a observação) ou `[inferido]` (com o que precisaria ser medido para confirmar).
  Uma seção de "nota operacional"/"consequência prática" é justamente onde a inferência se
  esconde — ela **não** fica de fora da regra. O motivo é que este é o único documento da spec
  cuja autoridade vem de ter sido medido: uma frase inferida escrita aqui **herda a autoridade do
  artefato inteiro**, e nenhum agente a jusante a questiona. Já aconteceu de verdade: num artefato
  excelente, que derrubou quatro suposições do TRD medindo o DOM real, duas sentenças do mesmo
  parágrafo eram uma medida e a outra inferência pura, sem marcação e com o mesmo tom afirmativo.
  A inferida virou restrição em dois artefatos a jusante (uma seção do TRD e uma ressalva de SRE)
  por dois agentes diferentes, e só caiu porque o **usuário** disse "isso não bate com o que eu
  vejo" — a medição que a refutou custou poucos minutos, com ferramenta que o projeto já usava.
- **Ao emendar o TRD com o resultado**: uma afirmação `[inferido]` entra como **pendência VALIDAR
  DEPOIS ou como premissa marcada**, nunca como restrição de desenho.

**A armadilha que torna isso obrigatório em vez de recomendável: o dublê escrito a partir da
suposição valida a suposição, não a realidade.** Uma suíte verde não é evidência aqui, e nenhuma
etapa de revisão posterior supre a lacuna — elas revisam o código contra o TRD, e o TRD é a fonte
do erro. O modo de falha é silencioso do começo ao fim: mock verde, code review, UX, QA, segurança
e SRE aprovando, e a descoberta só na validação pós-merge contra produção, depois de um ciclo
completo de pipeline.

Já aconteceu de verdade, e a tarefa de investigação é o que evitou o desastre: um TRD desenhou a
localização de uma linha num modal como `GetByRole(Button, { Name: <rótulo>, Exact: true })`. O
DOM real tinha o nome acessível `"undefined. Dimas (Blumenau)."` — com prefixo `undefined. ` e
ponto final, em **todas as 17 linhas observadas**, por um defeito do próprio site de terceiro. O
locator desenhado casava **zero** elementos. A mesma investigação derrubou outras três suposições
do desenho (nome acessível do gatilho também não casava por texto exato; a busca por rótulo na
página inteira retornava 2 ocorrências, exigindo escopo obrigatório ao modal; e o contêiner do
modal ficava visível **antes** de as linhas existirem, exigindo esperar o conteúdo, não o
contêiner). É a terceira spec seguida do mesmo projeto em que uma tarefa de investigação agendada
como primeira da primeira fatia se pagou.
