# Micro contexto: núcleo pequeno, detalhe sob demanda, ferramenta antes de verificação manual

Todo arquivo `.md` deste pipeline — agente, skill, ou artefato que um agente gera num projeto
consumidor — é, em algum momento, injetado por completo no contexto de quem o lê. Um agente
(`architect`, `sre`, ...) tem seu `.md` inteiro carregado como prompt a cada invocação, mesmo
quando a tarefa do momento só toca uma fração do que ele sabe fazer. Um artefato de revisão editado
in-place (`code-review.md`, `qa-report.md`) cresce a cada rodada e, sem estrutura, vira um arquivo
que ninguém lê por completo mas que todo mundo paga para abrir.

Este doc define quatro convenções relacionadas — para arquivo-fonte do plugin, para arquivo
gerado em projeto consumidor (duas: split físico e versionamento/migração), e para uso de
ferramenta — cada uma resolvendo a mesma pergunta: **o que precisa estar sempre carregado, e o
que pode ser buscado só quando a tarefa realmente pedir.**

## 1. Núcleo + detalhe sob demanda (agentes e skills)

Um agente/skill fica com um **núcleo pequeno**, sempre carregado:

- papel, pré-condição, processo (passo a passo numerado) — o que já existia antes;
- 2-5 ponteiros de gate em `docs/gates/` — o que já existia antes;
- um **índice de regras sob demanda**: uma tabela curta, uma linha por tópico, com o **gatilho
  objetivo** ("a tarefa envolve GRANT/REVOKE de privilégio") e o arquivo-filho correspondente.

Qualquer regra que hoje carrega justificativa longa — exemplo extenso, "já aconteceu de verdade",
o porquê de uma decisão não óbvia — move para um **arquivo-filho**, nunca fica inline no núcleo:

- agente: `agents/<nome-do-agente>/<topico-slug>.md`
- skill: `skills/<nome-da-skill>/_rules/<topico-slug>.md`

O agente/skill só faz `Read` do arquivo-filho quando a tarefa atual bate no gatilho descrito no
índice do núcleo — nunca pré-carrega todos os filhos "por garantia". Pré-carregar tudo anula o
ganho inteiro desta convenção: o núcleo existe para que a invocação comum (a que não toca nenhum
tópico raro) pague só o preço do processo, não o de toda exceção já catalogada.

**Nenhum conteúdo é perdido ao mover — só realocado.** O motivo de tanta elaboração nas regras
atuais não é acidental: `docs/gates/governanca.md` e vários achados reais deste próprio
repositório mostram que regra terse sem o porquê já foi ignorada ou mal aplicada antes. Mover a
elaboração para um arquivo-filho preserva o porquê para quem precisar dele — só deixa de custar
contexto para quem não precisa.

**Como escrever o núcleo**: cada linha do índice é "se `<condição objetiva e verificável>`, leia
`<arquivo>`". Condição vaga ("se a tarefa for complexa") não serve de gatilho — o agente não tem
como avaliar isso sem já ter lido o arquivo, o que anula a economia. Condição objetiva ("se o diff
contém `GRANT`/`REVOKE`", "se a fatia toca `.github/workflows/`") é verificável a partir do próprio
diff/tarefa, sem precisar abrir nada primeiro.

## 2. Split físico por rodada (artefatos gerados em projetos consumidores)

Um artefato de revisão editado in-place (`code-review.md`, `qa-report.md`, `security-review.md`,
`sre-review.md`, `ux-review.md`) deixa de ser um único arquivo que cresce a cada fatia/rodada.
Vira um diretório:

```
specs/<slug>/reviews/<stage>/
  INDEX.md         — tabela "Histórico de aprovações por fatia" (uma linha por rodada) + próximo
                      passo. Sempre pequeno — é o índice, nunca o conteúdo.
  tracking.md       — achados (coluna Fatia/Status), pendências "VALIDAR DEPOIS", log de revisões:
                      três tabelas compactas, append-only, nunca uma linha apagada — só marcada.
  F-<N>.md          — a prosa da rodada N (as áreas revisadas, achados discutidos, veredito
                      detalhado). Um arquivo por rodada; `hotfix-<data>.md` para correção pontual.
```

`<stage>` é o nome literal do artefato legado sem a extensão (`code-review`, `qa-report`,
`security-review`, `sre-review`, `ux-review`) — nunca um nome curto inventado (ex.: "qa" em vez
de "qa-report"). Isso não é estético: os scripts `sdd-status`/`sdd-pending` já resolvem o
diretório a partir do próprio nome do stage (`reviews/<stage>/INDEX.md`) sem precisar de uma
tabela de mapeamento stage→diretório — inventar um nome curto por área forçaria esse mapeamento
a existir só para desfazer uma abreviação sem ganho real. Leitura, numa rodada nova:
sempre `INDEX.md` inteiro (é curto) + `tracking.md` (ao menos as linhas abertas) + `F-<N>.md` da
rodada vigente + da penúltima. Rodadas mais antigas são `Read` só sob demanda — quando o índice de
`INDEX.md`, um achado específico, ou uma flag de revalidação apontar para elas — nunca abertas "por
completude". Mesmo critério de leitura seletiva que já valia para o arquivo único, só que agora
cada rodada antiga nem chega a ser lida em bytes, porque é um `Read` de arquivo separado, não um
scroll dentro de um arquivo gigante.

**Formato legado continua suportado para leitura.** Uma spec já em andamento num projeto
consumidor, criada antes desta convenção existir, continua com `specs/<slug>/<stage>.md` único —
a migração **não é automática**. Toda skill/agente que lê esses artefatos detecta qual formato
está em uso (o diretório `specs/<slug>/reviews/<stage>/` existe → novo; só o arquivo único existe
→ legado) antes de decidir como ler ou escrever.

## 2b. Split por tópico (PRD, TRD)

PRD e TRD não têm "rodada" — nascem de uma única invocação do agente de origem
(`product-design`/`architect`) e depois só são emendados via `/btt-sdd:amend`, nunca reescritos
por fatia como os 5 artefatos da seção 2. Por isso o split deles segue o princípio da seção 1
(núcleo pequeno + arquivo-filho sob demanda), aplicado a um artefato gerado em projeto consumidor
em vez de a um agente/skill, e não o split por rodada da seção 2.

Em vez de um único arquivo que cresce com cada história de usuário, cada fatia e cada pendência,
vira um diretório com um núcleo pequeno (`INDEX.md`) e um arquivo por tópico — **cada um mantendo
a numeração de seção original do artefato de arquivo único, nunca renumerado**. É isso que
permite toda referência já escrita em qualquer agente/skill/doc deste pipeline ("seção 6 do PRD",
"seção 13 do TRD") continuar significando exatamente a mesma seção de sempre — só muda **onde**
procurá-la, nunca o número:

```
specs/<slug>/prd/
  INDEX.md         — núcleo: seções 1-5, 8, 9, 13 (visão geral, problema, personas, objetivos,
                      fora de escopo, métricas de sucesso, indicadores técnicos, aprovação) +
                      tabela de navegação para os arquivos abaixo.
  user-stories.md  — seções 6-7 (histórias de usuário e critérios de aceite; wireframes/protótipos
                      de tela, quando aplicável).
  value-order.md   — seção 10 (ordem de valor / dependências entre histórias — fatias verticais).
  tracking.md      — seções 11-12 (pendências VALIDAR DEPOIS; log de revisões), append-only, mesmo
                      critério da seção 2.

specs/<slug>/trd/
  INDEX.md         — núcleo: seções 1, 2, 14, 17 (contexto, stack tecnológica, controle de versão
                      por fatia, aprovação) + tabela de navegação para os arquivos abaixo.
  architecture.md  — seções 3, 4, 5, 7, 9 (visão de arquitetura, modelo de domínio, ports,
                      adapters, modelo de dados/contratos externos).
  contract.md      — seção 8 (contrato Frontend↔Backend) — lido isoladamente por
                      `backend-developer`/`frontend-developer` sem precisar reler o TRD inteiro.
  use-cases.md     — seção 6 (casos de uso — critério de aceite do PRD → caso de uso → ports).
  quality.md       — seções 10, 12 (pilares de engenharia de software; riscos e trade-offs).
  test-plan.md     — seção 11 (plano de testes, alto nível).
  tasks.md         — seção 13 (decomposição de tarefas e dependências — fatias verticais —,
                      incluindo a subseção "Janelas de quebra de contrato entre fatias").
  tracking.md      — seções 15-16 (pendências VALIDAR DEPOIS; log de revisões), append-only.
```

Toda referência numerada a seção de PRD/TRD em qualquer agente/skill/doc deste pipeline continua
válida como está — resolva pela tabela acima quando a spec já usa o formato novo
(`specs/<slug>/prd/` ou `specs/<slug>/trd/` existe) ou pelo arquivo único de sempre quando não
(`specs/<slug>/prd.md`/`trd.md`), mesmo critério de detecção estrutural da seção 2 (diretório
existe → novo; só arquivo único existe → legado). **Formato legado continua suportado para
leitura**, mesma regra da seção 2 — a migração para o split por tópico também não é automática
(`/btt-sdd:migrate <slug> prd`/`trd`, seção 3 abaixo).

## 3. Marcador de versão de formato + migração genérica (qualquer artefato gerado em projeto consumidor)

Todo template em `specs/_template/` (inclusive cada arquivo dentro de
`specs/_template/reviews/<stage>/` e, para PRD/TRD, dentro de `specs/_template/prd/` e
`specs/_template/trd/`) declara sua própria versão de formato numa linha HTML comment logo após o
título: `<!-- sdd-format-version: N -->`. Todo artefato que um agente gera "a partir de" esse
template herda essa linha verbatim — é assim que a instância real em `specs/<slug>/...` carrega a
mesma informação. A numeração é **por artefato**, nunca global: `qa-report` pode estar em `v2`
enquanto `coverage-summary` continua em `v1` desde que o pipeline existe — um não bloqueia o
outro.

`/btt-sdd:migrate <slug> <artefato>` é o comando genérico que lê a versão gravada na instância
real (`specs/<slug>/...`), compara com a versão atual do template correspondente, e aplica a
transformação registrada se houver uma — nunca automaticamente, sempre por pedido explícito, um
artefato de uma spec por vez. O registro de migrações vive em `skills/migrate/migrations/`: um
arquivo por par `<artefato>-v<origem>-to-v<destino>`, cada um descrevendo a própria detecção e
transformação — nenhum comando genérico centraliza a lógica de todo artefato, só sabe onde
procurar o par certo. Hoje existe um par `v1 → v2` registrado para sete artefatos —
`code-review`, `qa-report`, `security-review`, `sre-review` e `ux-review` (`v2` = split físico
por rodada, seção 2 acima) e `prd` e `trd` (`v2` = split por tópico, seção 2b acima). Artefatos
sem par registrado (`coverage-summary`, `timing-log`) nunca mudaram de formato desde que o
pipeline existe — o comando responde "nada para migrar" para eles, não um erro; é a
infraestrutura pronta para quando (e se) uma mudança de formato futura precisar de um par novo,
sem reescrever o comando em si.

**A mesma convenção vale para artefato de `docs/` gerado por um agente sem template em
`specs/_template/`** (a estrutura exata vive inline no próprio arquivo-filho do agente, ex.
`agents/tech-writer/mapa-de-documentacao.md` para `docs/DOCS-MAP.md` e
`agents/tech-writer/catalogo-de-features.md` para `docs/FEATURES.md`) — o marcador é a primeira
linha do bloco ```markdown` que descreve a "Estrutura exata do arquivo", e
`check-migration-coverage.py` descobre esses dois num registro próprio (não via `Glob` em
`specs/_template/`, que não se aplica a eles) para que também apareçam no total verificado.

**Artefato sem marcador (escrito antes desta convenção existir) é tratado como a versão mais
antiga conhecida daquele artefato** — detectado estruturalmente (a mesma técnica que a seção 2
já descreve: diretório vs. arquivo único), nunca pelo marcador ausente. É uma lacuna transitória
inevitável: não existe como gravar retroativamente um marcador num arquivo escrito antes dele ser
inventado — ela se fecha sozinha conforme specs antigas são migradas ou specs novas nascem já com
o marcador.

**Toda versão de formato nova que quebra a estrutura do arquivo exige a regra de migração
correspondente no mesmo commit/PR — não é opcional, não fica para depois.** Quem bumpa
`<!-- sdd-format-version: N -->` de um template (`N` maior do que a versão anterior conhecida
daquele artefato) é responsável por também criar `migrations/<artefato>-v<N-1>-to-v<N>.md` —
nunca entregar o template novo e deixar a conversão retroativa para uma sessão futura decidir
como fazer. `python scripts/check-migration-coverage.py` verifica isso mecanicamente (compara
a versão de cada template de arquivo único com a versão do split correspondente, quando
existir, e confirma que o arquivo de regra para cada salto existe) — rode antes de comitar
qualquer mudança que bump a versão de um template, mesmo padrão de
`python scripts/check-plugin-sync.py` para a sincronia entre as duas cópias do pipeline.

## 4. Ferramenta conhecida antes de verificação manual

`docs/TOOLING.md` já cataloga ferramentas determinísticas por área (rtk para saída de shell,
ast-grep para Ports & Adapters, gitleaks/semgrep/osv-scanner para segurança, hadolint/checkov para
infra). A partir desta convenção, a ordem é sempre: **tentar a ferramenta primeiro, usar o
resultado como achado já pronto para triar, e só cair para verificação manual quando o binário não
estiver disponível no ambiente** — nunca o inverso (fazer a verificação manual e "também" rodar a
ferramenta depois, como checagem redundante).

Isso **não** cria gate novo: nenhuma etapa deste pipeline bloqueia pela ausência de uma dessas
ferramentas — a verificação manual que a ferramenta cobriria continua obrigatória quando ela não
está disponível. O que muda é a ordem dentro da mesma etapa, não o que é exigido no total.
