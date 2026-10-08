# TRD

> Parte de `docs/QUALITY-GATES.md` (índice). Gate crítico: o que está marcado aqui
> **bloqueia mesmo** — não é sugestão, é a definição do que "pronto" significa.

- [ ] Stack tecnológica definida (seção 2 do TRD), com a fonte da decisão registrada — reaproveitada
  de `docs/STACK.md` do projeto, reaproveitada de `~/.claude/stack-defaults.md` (confirmada com o
  usuário), ou decidida nesta sessão com o usuário. Nunca implícita dentro de Ports/Adapters/Modelo
  de dados.
- [ ] Todo critério de aceite do PRD tem um caso de uso e um plano de teste correspondente.
- [ ] Todo port tem contrato claro sem vazar detalhe de implementação de adapter.
- [ ] Indicadores técnicos do PRD foram lidos e endereçados (decisão tomada ou explicitamente adiada
  com justificativa, nunca ignorados).
- [ ] Todo pilar de engenharia (`docs/ENGINEERING-PILLARS.md`: performance, escalabilidade,
  resiliência, disponibilidade, observabilidade, manutenibilidade) tem resposta específica para a
  feature, nunca em branco ou genérica.
- [ ] Se a feature inclui frontend, "Contrato Frontend↔Backend" está definido (no TRD ou num ADR
  referenciado) — nunca "a definir depois".
- [ ] **No artefato da tarefa de investigação, cada afirmação está marcada `[medido]` ou
  `[inferido]`** — inclusive (sobretudo) as das seções de "nota operacional"/"consequência prática",
  que é onde a inferência se esconde. Uma frase inferida escrita num artefato cuja autoridade vem de
  ter sido medido herda essa autoridade e se propaga como restrição de desenho sem ninguém a
  questionar. E uma afirmação `[inferido]` entra no TRD como pendência ou premissa marcada, nunca
  como restrição.
- [ ] **Todo seletor/locator/contrato concreto contra um sistema externo cuja estrutura real não foi
  observada está marcado como provisório no próprio texto onde aparece, e tem uma tarefa de
  investigação agendada como primeira tarefa da primeira fatia que depende dele** — nunca só uma
  pendência "VALIDAR DEPOIS", que não bloqueia nada. Vale para seletor de DOM de terceiro, formato de
  resposta de API não documentada, layout de arquivo de parceiro, esquema de webhook, nome de campo
  de SSO. O motivo é que nenhuma etapa posterior pega esse erro: o dublê escrito a partir da suposição
  valida a suposição, e a suíte fica verde contra ela — code review, UX, QA, segurança e SRE revisam
  o código contra o TRD, e aqui o TRD é a fonte do erro. Já aconteceu de um locator desenhado casar
  zero elementos no DOM real por um defeito do próprio site de terceiro, pego só porque a tarefa de
  investigação existia (`agents/architect.md`, passo 1c).
- [ ] **Na seção "Riscos e trade-offs", toda afirmação sobre comportamento concreto de biblioteca de
  terceiro ou de runtime está marcada `[medido]` (com versão e como) ou `[não medido]`**, e toda
  alegação de contenção ("vira falha daquela linha") cita o ponto do código onde a contenção
  acontece. Afirmação desse tipo sem marcação é lida como fato estabelecido e atravessa o pipeline
  inteiro sem verificação — inclusive escrita com hedge ("em teoria", "lançaria"), que faz o texto
  parecer análise prudente.
- [ ] **Nenhuma contagem na seção 11 (plano de testes) — e nenhuma enumeração de quais
  propriedades asseverar.** "Nos 6 estados", "os 3 casos de X" e "asseverar título e corpo" são
  mecanismo escrito como se fosse critério, e a seção 11 é estruturalmente **a seção que caduca**:
  seu conteúdo é mecanismo por definição, e mecanismo é o que cada rodada de correção troca.
  Escreva o critério que sobrevive à troca ("toda renderização visível", "trocar a ordem de qualquer
  par adjacente mata ao menos um teste"). Já aconteceu de verdade: de seis frases de artefato
  desmentidas por medição numa única fatia, **quatro estavam nesta seção** ou em docblock de teste —
  duas mutações de ordem sobreviveram a 113/113 verdes contra uma linha que dizia "os 3 casos de
  precedência", e depois de a contagem ser trocada por critério o defeito seguinte entrou pelo
  **segundo eixo da mesma frase** (quais propriedades asseverar), com duas mutações sobrevivendo à
  suíte inteira, 1644/1644 verdes.
- [ ] "Decomposição de tarefas e dependências" preenchida, com trilha (backend/frontend/ambos) e
  dependências técnicas explícitas para cada tarefa, e a coluna Status inicializada como `pendente`
  para cada tarefa nova (ciclo de vida completo na seção "Status de tarefas" abaixo).
- [ ] **Toda tarefa tem a coluna "Issue GitHub" preenchida — obrigatório, não mais opcional.** Se
  não há remote GitHub configurado/autenticado, o TRD não pode ser aprovado ainda (`architect` para
  e pede para configurar `git remote`/`gh auth login` primeiro); só o PRD dispensa GitHub.
- [ ] **Toda issue GitHub que o pipeline cria no repositório do projeto-alvo carrega identificação
  estruturada da spec de origem** — não só as de tarefa do TRD. `architect` já garante isso para as
  issues de tarefa via o milestone por spec (acima). Reaproveite esse mesmo milestone (mesmo
  `<slug>`) sempre que outra issue do pipeline se referir à mesma spec/projeto — ex.: a issue de
  `/btt-sdd:hotfix` (`skills/hotfix/SKILL.md`, passo 1b) quando o bug tem spec relacionada. Se ainda
  não existir nenhum milestone para essa spec (spec sem decomposição de tarefas em issues), aplique
  em vez disso um label `spec:<slug>` (criando-o se faltar). Uma issue aberta sem nenhuma spec
  relacionada (melhoria pontual sem origem) não precisa dessa identificação.
- [ ] Se o TRD depende de código pré-existente sem documentação suficiente, `/btt-sdd:baseline`
  rodou antes (ou a documentação já era suficiente, explicitamente constatado).
- [ ] Nome de branch GitHub Flow definido **por fatia** (`docs/GIT-WORKFLOW.md`) — uma branch/PR por
  fatia, nunca uma única para a feature inteira quando há mais de uma fatia.
- [ ] Aprovação explícita do usuário registrada.
