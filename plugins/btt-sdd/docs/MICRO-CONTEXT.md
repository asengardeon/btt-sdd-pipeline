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

## 3. Marcador de versão de formato + migração genérica (qualquer artefato gerado em projeto consumidor)

Todo template em `specs/_template/` (inclusive cada arquivo dentro de
`specs/_template/reviews/<stage>/`) declara sua própria versão de formato numa linha HTML comment
logo após o título: `<!-- sdd-format-version: N -->`. Todo artefato que um agente gera "a partir
de" esse template herda essa linha verbatim — é assim que a instância real em `specs/<slug>/...`
carrega a mesma informação. A numeração é **por artefato**, nunca global: `qa-report` pode estar
em `v2` enquanto `prd` continua em `v1` desde que o pipeline existe — um não bloqueia o outro.

`/btt-sdd:migrate <slug> <artefato>` é o comando genérico que lê a versão gravada na instância
real (`specs/<slug>/...`), compara com a versão atual do template correspondente, e aplica a
transformação registrada se houver uma — nunca automaticamente, sempre por pedido explícito, um
artefato de uma spec por vez. O registro de migrações vive em `skills/migrate/migrations/`: um
arquivo por par `<artefato>-v<origem>-to-v<destino>`, cada um descrevendo a própria detecção e
transformação — nenhum comando genérico centraliza a lógica de todo artefato, só sabe onde
procurar o par certo. Hoje só existe um par registrado por artefato — `code-review`, `qa-report`,
`security-review`, `sre-review` e `ux-review`, todos `v1` (arquivo único) `→` `v2` (split físico
por rodada, seção 2 acima). Artefatos sem par registrado (`prd`, `trd`, `coverage-summary`,
`timing-log`, `oneshot`) nunca mudaram de formato desde que o pipeline existe — o comando responde
"nada para migrar" para eles, não um erro; é a infraestrutura pronta para quando (e se) uma
mudança de formato futura precisar de um par novo, sem reescrever o comando em si.

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
