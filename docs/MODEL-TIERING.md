# Escolha de modelo por subagente: onde trabalho bem definido roda mais barato

Este pipeline invoca subagentes para duas coisas com perfis de custo **opostos**, e por padrão as
duas pagam o mesmo preço. Este doc define quando a segunda pode rodar num modelo mais barato, o que
nunca pode, e como a escolha é registrada para poder ser avaliada depois.

Não é uma otimização "se der tempo": a sub-tarefa auxiliar que o pipeline já manda delegar
(`docs/gates/governanca.md`, bullet sobre investigação de causa raiz) é justamente a que menos
precisa do modelo mais capaz — e a que mais se repete por fatia.

## Os dois perfis

| | **Etapa com veredito** | **Sub-tarefa auxiliar bem definida** |
|---|---|---|
| Quem | todo agente nomeado em `.claude/agents/`: `architect`, `product-design`, `backend-developer`, `frontend-developer`, `code-reviewer`, `ux-designer`, `qa-engineer`, `security-engineer`, `sre` — e também `codebase-archaeologist` e `tech-writer`, que produzem artefato do projeto | a sub-tarefa isolada que uma skill ou um agente delega para não inflar o próprio contexto |
| Produz | artefato aprovável, veredito de gate, código de produção | uma conclusão destilada, em formato definido antes de invocar |
| Erro custa | retrabalho de etapa inteira, ou um gate aprovado indevidamente | uma reinvocação, percebida na hora por quem conferiu |
| Modelo | **sempre o padrão da sessão** | **tier econômico**, quando passar no teste abaixo |

A assimetria é a razão de tudo que vem depois: no primeiro perfil, economizar modelo troca custo
por risco de gate — e o risco é assumido por quem lê o artefato três etapas adiante, não por quem
economizou. No segundo, o erro aparece no mesmo turno, para quem pode refazer.

## O teste de "trabalho bem definido"

Rebaixe o modelo de uma sub-tarefa **só quando as cinco condições valerem**. Qualquer "não" ou
"não sei" devolve a invocação ao padrão da sessão — a dúvida resolve para o modelo mais capaz,
nunca para o mais barato.

1. **Formato de saída especificado antes de invocar.** Você já sabe a forma do que vai receber
   (uma lista de caminhos, um veredito binário com a linha que o sustenta, um número extraído de um
   relatório) — não "o que ele achar relevante".
2. **Resultado conferível sem refazer o trabalho.** Você consegue validar a resposta olhando para
   ela (o arquivo citado existe e contém o trecho? o número bate com o rodapé do relatório?), sem
   repetir a leitura que delegou. É esta condição que torna o erro barato, e é a que mais reprova
   candidatos.
3. **Nenhum veredito de gate, decisão de produto ou decisão de arquitetura.** A sub-tarefa levanta
   evidência; quem invocou decide. "Diga se este PR está aprovado" nunca passa; "liste os arquivos
   de `src/` sem teste correspondente" passa.
4. **Nenhuma ambiguidade esperada.** Se é previsível que a sub-tarefa vá topar com uma escolha que
   só o usuário pode fazer, ela não é bem definida — e ainda por cima rodaria sem
   `AskUserQuestion` (`docs/gates/governanca.md`, bullet sobre pergunta de subagente isolado).
5. **Somente leitura, ou escrita mecânica num alvo único.** Varrer, comparar, extrair, contar.
   Nunca código de produção: TDD é ciclo de julgamento (`docs/gates/implementacao.md`), não
   transcrição.

## Limites rígidos

Estes não são casos a avaliar com o teste acima — são exclusões:

- **Nenhuma etapa do pipeline roda em tier econômico** — incluindo as condicionais (baseline,
  revisão de UX) e os utilitários que escrevem artefato (`tech-writer`). Nem a mais mecânica
  delas, nem "só esta fatia porque é pequena": uma fatia pequena produz o mesmo artefato aprovável
  que uma grande, e é lida pelas mesmas etapas seguintes.
- **Nunca rebaixe pelo frontmatter do agente** (`.claude/agents/*.md`). O frontmatter congelaria o
  tier para toda invocação daquele agente, inclusive as que decidem gate; a escolha é **por
  invocação**, de quem invoca, com o contexto daquela chamada.
- **Nenhuma correção de achado de revisão em tier econômico**, mesmo quando o achado é objetivo:
  corrigir achado é tocar código de produção, e o caminho certo para o custo dessa rodada é
  retomar o agente que já tem o contexto (`.claude/skills/sdd-implement/SKILL.md`, seção
  "Retomando para corrigir achados de revisão") — retomar já é a economia, medida em fração do que
  uma instância fresca gasta só para se orientar.
- **Uma única repromoção, nunca uma terceira tentativa barata.** Se a sub-tarefa em tier econômico
  volta inutilizável (formato errado, conclusão que não se sustenta na evidência citada), reinvoque
  **uma vez** no padrão da sessão e registre que o rebaixamento não se pagou. Insistir no tier
  barato é a mesma armadilha do bullet "nenhuma ação se repete mais de 3 vezes"
  (`docs/gates/governanca.md`) com custo pior: duas rodadas baratas mais uma cara saem mais caro
  que a cara sozinha.

## Candidatos típicos que já existem no pipeline

Nenhum destes é novo — todos são sub-tarefas que o pipeline **já manda delegar** hoje, pagando
preço de etapa com veredito:

- **Investigação de causa raiz somente-leitura** antes de decidir o que pedir numa correção
  pontual (`.claude/skills/sdd-implement/SKILL.md`, passo 2a) — ler vários arquivos, histórico de
  Git ou log para devolver só a conclusão.
- **Leitura destilada do `timing-log.md`** na retrospectiva de fatia
  (`.claude/skills/sdd-sre/SKILL.md`, passo 5c): extrair as durações e a tendência entre fatias é
  extração; decidir que isso vira issue de melhoria é julgamento de quem invocou.
- **Varredura de artefatos da spec** por um padrão declarado: itens "VALIDAR DEPOIS" em aberto,
  tarefas do TRD sem Issue GitHub, marcação `[medido]`/`[inferido]` num artefato de investigação.
- **Extração de números de um relatório bruto** de cobertura/build para o formato condensado do
  artefato (`docs/TESTING.md`) — o relatório é a fonte, o resumo é transcrição.
- **Comparação mecânica de duas listas**: casos de uso da seção 6 do TRD contra o que existe em
  `src/`, ou os N pontos de entrada de uma correção contra os que têm teste dedicado
  (`.claude/agents/backend-developer.md`, passo 5c).

## Como registrar — e como isso é avaliado depois

Rebaixar sem registrar é indistinguível de nunca ter rebaixado, e a economia fica sem evidência:

- **A coluna `Modelo` de `specs/<slug>/timing-log.md`** recebe o tier de cada invocação
  (`padrão da sessão` ou `econômico`, mais o nome concreto do modelo quando você o souber).
  Invocação repromovida gera **duas linhas**, não uma corrigida — o arquivo é append-only
  (`specs/_template/timing-log.template.md`).
- **A retrospectiva de fatia lê essa coluna** junto com a duração
  (`.claude/skills/sdd-sre/SKILL.md`, passo 5c): tier econômico que atravessou a fatia sem
  repromoção é candidato a virar padrão; tier econômico repromovido duas vezes pelo mesmo tipo de
  sub-tarefa é sinal de que aquele tipo não passa no teste das cinco condições — e isso é um achado
  de retrospectiva como qualquer outro.
- **O resultado é promovido para onde sobrevive à sessão**: particularidade deste projeto vai para
  `docs/PROJECT-CONVENTIONS.md` (ex.: "aqui a varredura de pendências roda em tier econômico");
  padrão genérico vira issue em `asengardeon/btt-sdd-pipeline` (`docs/gates/governanca.md`, bullet
  sobre feedback do plugin). Nunca fica só no prompt da próxima invocação — o canal mais caro e o
  mais frágil.

## Nota sobre nomes de modelo

Este doc nomeia **tiers por função** (`padrão da sessão`, `econômico`), não produtos: o conjunto de
modelos disponíveis para subagente varia por conta, plano e harness, e um nome concreto escrito
aqui caduca sem avisar. Quem invoca resolve o tier no mecanismo que o ambiente oferecer — hoje, o
parâmetro de modelo da própria chamada de subagente. Se um projeto quiser fixar o mapeamento
(ex.: qual modelo concreto é o "econômico" dele), isso é particularidade de projeto e vive em
`docs/PROJECT-CONVENTIONS.md`, não aqui.
