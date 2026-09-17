# Changelog do scaffold do plugin btt-sdd (histórico — mecanismo descontinuado)

**Este arquivo é só histórico a partir da versão que removeu `/sdd-sync-docs`/`docs/DOCS-SYNC.md`
(ver issue de consolidação dos docs de governança no repositório do plugin).** Os docs de
governança genéricos do pipeline não são mais copiados para dentro de cada projeto novo — vivem
bundled com o próprio plugin/distribuição (`plugins/btt-sdd/docs/`) e se atualizam sozinhos a cada
`claude plugin update`, sem nada para um projeto precisar "sincronizar" manualmente. Não há mais
motivo para registrar novas entradas aqui — as entradas abaixo ficam preservadas como registro do
que já mudou no scaffold ao longo do tempo, mas nada as consome automaticamente mais.

~~Este arquivo rastreava só as mudanças em `skills/create-project/scaffold/docs/*.md` e
`skills/create-project/scaffold/CLAUDE.md` deste plugin — os arquivos que `/create-project` copiava
para dentro de um projeto novo no momento em que ele era criado. Não era o changelog geral do
plugin (isso seria todo o histórico de commits/PRs); era especificamente a lista do que um projeto
já scaffolded numa versão antiga estava sem, para `/sdd-sync-docs` comparar contra a versão
instalada e oferecer aplicar.~~

**Rastreamento começou na versão `1.14.0`** — mudanças de scaffold anteriores a ela não têm
entrada retroativa aqui (não havia registro confiável o suficiente para reconstruir seção por
seção de todas as versões passadas).

## 1.22.11 — 2026-09-17

- **Estrutural, sem impacto para quem já scaffolded**: este repositório deixou de manter uma
  segunda cópia local do scaffold (`.claude/skills/create-project/scaffold/`) — `/create-project`
  agora lê direto do scaffold deste plugin, que passa a ser a única fonte, mesmo quando invocado
  via junction sem o plugin instalado. Isso não muda o conteúdo entregue a um projeto novo.
- Reconciliação de conteúdo que havia divergido entre as duas cópias antes desta unificação (issue
  #201) — projetos scaffolded a partir da cópia local (agora removida) estavam sem: (a) os itens
  de governança "Nenhum agente encerra numa branch de feature" e "Nenhum agente aprova/reprova o
  próprio trabalho" em `docs/QUALITY-GATES.md`; (b) a correção de frescor de cobertura por commit
  mais recente que tocou `src/`/`frontend/` em vez de HEAD literal (issue #172) em
  `docs/TESTING.md` e `docs/QUALITY-GATES.md`; (c) as colunas `Profundidade`/`Commit` no histórico
  de aprovações por fatia de `security-review.template.md`/`sre-review.template.md`.

## 1.22.4 — 2026-09-15

- `docs/QUALITY-GATES.md`, seção "Revisão de código": novo item — uma fatia que estende um
  guard/regra de autorização já implementado por uma fatia anterior precisa renomear os testes
  cujo nome descreve o comportamento invertido pela nova fatia (não só alterar a asserção), e
  confirmar via grep que nenhuma referência órfã ao nome antigo do teste ficou para trás. (issue
  #177)

## 1.22.2 — 2026-09-15

- `docs/QUALITY-GATES.md`, seção "Governança de decisão": novo item — reconfirmar um ponto técnico
  já documentado em detalhe por uma etapa anterior (`code-review.md`/`qa-report.md`/
  `security-review.md`) com veredito "sem achado" não exige reescrever a explicação inteira; a
  verificação independente continua obrigatória, mas a conclusão pode ser registrada por referência
  cruzada ao relatório anterior, reduzindo tamanho de artefato e custo de geração. (issue #173)

## 1.21.4 — 2026-09-10

- `docs/QUALITY-GATES.md`, seção "Lições aprendidas recorrentes": o mecanismo de escalonamento de
  3 ocorrências (issue #140) agora também cobre entradas `acionável-por-agente`, não só `depende de
  ação externa` — "virar entrada e ser lida no planejamento" evita o bug em código novo, mas não
  corrige consumidores já existentes com o mesmo padrão. Na 3ª ocorrência confirmada sem correção
  efetiva, o agente de revisão propõe explicitamente uma mini-fatia/hotfix dedicada via
  `AskUserQuestion`. (issue #151)

## 1.21.2 — 2026-09-10

- `docs/QUALITY-GATES.md`, seção "SRE / CI-CD / Infra": novo item exigindo que `ci.yml` tenha
  filtro de `paths`/`paths-ignore` cobrindo `specs/**`, `docs/**` e `*.md` da raiz — sem isso, cada
  push de um artefato de revisão (`code-review.md`/`qa-report.md`/`security-review.md`/
  `sre-review.md`) dispara um run completo de CI desnecessário. Confirmado ao vivo: um PR só com
  `qa-report.md` atualizado disparou ~4min de CI sem necessidade. (issue #146)

## 1.21.1 — 2026-09-10

- `docs/QUALITY-GATES.md`, seção "Status de tarefas": documenta o caso especial da última fatia de
  uma spec, que nunca tem "fatia seguinte" para disparar a promoção de Status para `concluído
  (mergeado)` — `/sdd-implement` (passo 2a) agora cobre isso, confirmando o merge real via `gh pr
  view` e promovendo retroativamente antes de informar "nada a fazer". Já causou falso-positivo
  sistemático em 7 specs de um mesmo projeto, todas 100% mergeadas mas reportadas como "próxima
  fatia pendente" indefinidamente. (issue #144)

## 1.21.0 — 2026-09-10

- `docs/QUALITY-GATES.md`: entradas de "Lições aprendidas recorrentes" ganham o campo "Classe"
  (`acionável-por-agente` vs. `depende de ação externa`), e uma entrada `depende de ação externa`
  que atinge 3 ocorrências confirmadas aciona `AskUserQuestion` oferecendo resolver a pendência
  diretamente (ex.: `sre` configurando proteção de branch/environment via API do GitHub, sujeito a
  aprovação explícita) em vez de só acrescentar mais uma linha passiva à tabela. (issue #140)

## 1.20.20 — 2026-09-10

- `docs/QUALITY-GATES.md`: novo item na seção "Lições aprendidas recorrentes" — uma entrada de
  `docs/LESSONS-LEARNED.md` nunca substitui a regra canônica que ela generaliza; se a entrada (ou
  sua paráfrase por qualquer agente) parecer contradizer ou estreitar uma regra já formalizada em
  outro doc do projeto (`docs/TESTING.md`, `docs/QUALITY-GATES.md`, etc.), a regra canônica
  prevalece e a divergência é sinal de corrigir a entrada, não de que a regra mudou. (issue #133)

## 1.20.12 — 2026-09-08

- `docs/TESTING.md`: nova seção "Frontend (quando aplicável)" explica que, sem um harness de e2e
  de browser real contra backend real, uma tarefa de TRD descrita como "e2e do fluxo humano" exige
  que o `architect` já especifique o mecanismo de verificação alternativo (ex.: integração HTTP
  encadeada) na própria tarefa, em vez de deixar implícito. (issue #115)

## 1.20.10 — 2026-09-08

- `docs/QUALITY-GATES.md`: novo item bloqueante no gate SRE/CI-CD/Infra — quando uma fatia torna
  obrigatório um campo antes opcional/ausente numa rota já ativa consumida por um cliente já
  implantado que ainda não foi atualizado, e os gates de deploy automático já estão ligados, o
  `sre` exige um default retrocompatível ou confirmação explícita do usuário antes do merge, em
  vez de registrar como nota não-bloqueante de coordenação de deploy. (issue #113)

## 1.20.9 — 2026-09-08

- `docs/ENGINEERING-PILLARS.md`: seção "Disponibilidade" ganha um parágrafo apontando que, em
  features multi-fatia, o TRD também precisa endereçar janelas de quebra de contrato *entre*
  fatias (não só a disponibilidade da feature inteira) — ver "Janelas de quebra de contrato entre
  fatias" na seção 13 de `specs/_template/trd.template.md`. (issue #109)

## 1.20.7 — 2026-09-08

- `docs/GIT-WORKFLOW.md`: a seção "Isolamento de arquivos não é isolamento de serviços com estado"
  agora deixa explícito que o `architect` decide e registra em `docs/STACK.md` o mecanismo de
  isolamento de serviço com estado (banco/fila/emulador) entre execuções concorrentes assim que a
  stack do projeto passa a depender de um, em vez de deixar essa decisão totalmente implícita
  esperando alguém perceber a lacuna só depois de uma contenção real entre agentes. (issue #107)

## 1.20.5 — 2026-09-07

- `docs/DOCS-SYNC.md`: corrige a condição que dispara a comparação estrutural completa de
  `/sdd-sync-docs` — passa a rodar também quando `docs/.sdd-plugin-version` está presente mas
  anterior a `1.15.0` (não só quando o marcador está ausente), e passa a checar também a direção
  scaffold → projeto (arquivo inteiro do scaffold ausente no projeto), não só seções dentro de
  arquivos que já existem nos dois lados. Sem essa correção, um projeto cujo marcador foi gravado
  antes da `1.15.0` existir nunca recebia essa varredura, mesmo depois de atualizar o plugin várias
  vezes — achado real num projeto com 30 seções/arquivos de scaffold ausentes, todos anteriores a
  `1.14.0`.

## 1.20.2 — 2026-09-07

- `docs/QUALITY-GATES.md`: gate novo na seção "Governança de decisão" — merge de PR nunca é ação
  de um agente, mesmo o próprio agente que implementou o ajuste sendo revisado; documenta como
  risco conhecido de agentes autônomos com escrita em sistemas compartilhados, a partir de um
  incidente real em que o agente `sre` mergeou um PR sozinho apesar de instrução explícita em
  contrário. Exceção deliberada continua sendo a skill `/repo-issues`.

## 1.20.0 — 2026-09-07

- `docs/QUALITY-GATES.md`: gate novo na seção "PRD" — se a feature tem UI e wireframes são
  oferecidos, mas `docs/DESIGN-SYSTEM.md` ainda não existir no projeto, o usuário precisa ser
  consultado sobre estabelecer um sistema de design (paleta de cores, tipografia, tom visual,
  referências) antes de gerar as opções de wireframe, com recusa explícita sempre disponível
  (`/sdd-prd` passo 2b). Uma vez estabelecido, `docs/DESIGN-SYSTEM.md` é reaproveitado pelas
  próximas features com UI sem perguntar de novo — mesmo padrão de `docs/STACK.md`.

## 1.19.2 — 2026-09-07

- `docs/QUALITY-GATES.md`: toda issue GitHub que o pipeline cria no repositório do projeto-alvo
  passa a exigir identificação estruturada da spec de origem, não só as de tarefa do TRD —
  reaproveitar o milestone da spec quando existir, ou aplicar um label `spec:<slug>` quando não
  houver milestone ainda (ex.: issue de `/sdd-hotfix` associada a uma spec sem decomposição de
  tarefas em issues).

## 1.19.0 — 2026-09-07

- `docs/QUALITY-GATES.md`: criar Issue GitHub para toda tarefa do TRD deixa de ser opcional —
  sem remote GitHub configurado/autenticado, o TRD não pode ser aprovado (só o PRD dispensa
  GitHub); `/sdd-implement`/`/sdd-hotfix` não iniciam nenhuma fatia/correção sem a issue já
  existir.

## 1.15.2 — 2026-09-04

- `docs/GIT-WORKFLOW.md`: nova subseção em "Isolamento de working tree entre agentes concorrentes"
  — isolamento de `git worktree` cobre arquivos/estado de Git, não serviços com estado
  compartilhados no host (banco de teste, emulador de nuvem local); cada agente/worktree que roda
  testes de integração contra um desses serviços precisa de instância/banco/schema isolado por
  execução.

## 1.15.1 — 2026-09-04

- `docs/GIT-WORKFLOW.md`: nova subseção em "Aguardando CI antes do merge" — timeout de job de CI
  sob alta concorrência do próprio pipeline (múltiplas fatias/PRs rodando CI em paralelo) é um
  falso-negativo conhecido; tentar `gh run rerun --failed` antes de investigar como bug de código.

## 1.15.0 — 2026-09-03

- `docs/DOCS-SYNC.md`: nova subseção "Comparação estrutural na primeira sincronização" — cobre a
  lacuna de projetos scaffolded antes do início do rastreamento deste changelog (`1.14.0`):
  `/sdd-sync-docs`, na primeira sincronização de um projeto (`docs/.sdd-plugin-version` ausente),
  agora também compara títulos de seção entre os docs do projeto e o scaffold atual, além de ler
  este changelog.

## 1.14.1 — 2026-09-03

- `docs/TESTING.md`: nova subseção "Armadilha conhecida: `testPathIgnorePatterns` do Jest com
  `<rootDir>` e path com segmento iniciado por ponto" (dentro de "Frontend (quando aplicável)") —
  documenta uma falha silenciosa do Jest no Windows quando `rootDir` contém um segmento iniciado
  por ponto (ex. `.claude/worktrees/<id>`, a convenção deste pipeline para isolamento de working
  tree), e o padrão seguro recomendado para `testPathIgnorePatterns`/`modulePathIgnorePatterns`.

## 1.14.0 — 2026-09-03

- `docs/DOCS-SYNC.md` (arquivo novo): introduz o marcador `docs/.sdd-plugin-version` e o
  mecanismo de sincronização de docs em si — este changelog é a peça de dados que o mecanismo lê.
- `CLAUDE.md`: nova linha `/sdd-sync-docs` na tabela de comandos.
