# btt-sdd (plugin)

Empacotamento, como plugin instalável do Claude Code, do mesmo pipeline SDD que vive em
`.claude/agents/` e `.claude/skills/` na raiz deste repositório. Ver `CLAUDE.md` (raiz) e
`docs/SDD-WORKFLOW.md` para o funcionamento completo do pipeline — este README é só sobre o
empacotamento como plugin.

## Instalação a partir do GitHub (qualquer computador)

```
claude plugin marketplace add asengardeon/btt-sdd-pipeline
claude plugin install btt-sdd@btt-sdd-pipeline
```

O repositório é **privado** — precisa de uma conta com acesso já autenticada (`gh auth login`,
ou credenciais HTTPS/SSH do git já configuradas nesta máquina) antes de rodar `marketplace add`.
Sem isso, o clone do marketplace falha silenciosamente ou pede autenticação.

**Testado de verdade**: `marketplace add asengardeon/btt-sdd-pipeline` clonou o repositório
privado via HTTPS usando as credenciais já configuradas (sem prompt adicional), `plugin install`
funcionou, e `claude plugin details` confirmou os 11 skills e 8 agentes corretos.

Essa instalação é uma **cópia fixa do momento do clone** — editar o repositório depois não
atualiza o plugin já instalado sozinho. Ver "Atualizar o plugin" abaixo.

## Instalação local (para desenvolver o próprio plugin)

```
claude plugin marketplace add C:\repositorios\projeto-base-ia
claude plugin install btt-sdd@btt-sdd-pipeline
```

Ou, para testar sem instalar:

```
claude --plugin-dir plugins\btt-sdd
```

Diferente da instalação via GitHub, este método aponta para o caminho local — editar os arquivos
do plugin aqui reflete na próxima sessão nova do Claude Code, sem precisar de `update`. É o método
recomendado enquanto você estiver editando o próprio pipeline; use a instalação via GitHub para
usar o plugin em outro computador ou sem manter uma cópia local do repositório.

**Status**: instalação testada de verdade neste computador — `marketplace add` e `plugin
install` rodaram com sucesso (`claude plugin list` mostra `btt-sdd@btt-sdd-pipeline`, escopo
`user`, `enabled`), e uma sessão nova (`claude -p "/btt-sdd:status"`) reconheceu e executou o
comando namespaced corretamente contra `specs/0001-example-task-management/`, coexistindo sem
conflito com os comandos sem prefixo da junction (`/sdd-pending` etc.).

## Atualizar o plugin

Depende de como foi instalado (ver seções acima):

- **Instalação via GitHub** (`marketplace add asengardeon/btt-sdd-pipeline`): é uma cópia fixa do
  momento do clone — mudanças no repositório remoto não chegam sozinhas. Depois que uma mudança
  estiver commitada e *pushed* neste repositório, rode:
  ```
  claude plugin update btt-sdd@btt-sdd-pipeline
  ```
  Se isso não pegar a versão mais nova, remova e reinstale:
  ```
  claude plugin uninstall btt-sdd@btt-sdd-pipeline
  claude plugin install btt-sdd@btt-sdd-pipeline
  ```

- **Instalação local** (`marketplace add C:\repositorios\projeto-base-ia`, ou
  `--plugin-dir plugins\btt-sdd`): aponta direto para os arquivos deste repositório no disco —
  não precisa de `update`. A próxima sessão nova do Claude Code já reflete qualquer edição salva
  em `plugins/btt-sdd/`.

**Se você é quem mantém este repositório** (editando `.claude/agents/`/`.claude/skills/` na
raiz): editar só a raiz não atualiza o plugin. A ordem completa é:

1. Sincronize a mudança para dentro de `plugins/btt-sdd/` seguindo o processo descrito em
   "⚠️ Isto é uma cópia, não um link" logo abaixo.
2. Commit e *push* das duas cópias juntas (raiz + `plugins/btt-sdd/`) no mesmo commit, para não
   deixar o marketplace remoto com as cópias divergentes.
3. Só depois disso os usuários com instalação via GitHub verão a mudança ao rodar
   `claude plugin update btt-sdd@btt-sdd-pipeline` — quem usa instalação local já vê na próxima
   sessão, sem passo extra.

## ⚠️ Isto é uma cópia, não um link

Diferente de `.claude/agents/`/`.claude/skills/` (que ficam disponíveis globalmente via junction
de diretório em `~/.claude/agents`/`~/.claude/skills`, apontando direto para cá), o conteúdo
deste plugin é uma **cópia própria** — necessário porque skills instaladas via plugin ganham o
namespace `btt-sdd:` (ex.: `/btt-sdd:trd`), então toda referência interna a um comando `/sdd-*`
dentro dos arquivos deste plugin já vem adaptada para esse namespace, diferente das cópias em
`.claude/`.

**Convenção de nomes das skills deste plugin — sem o prefixo `sdd-` redundante.** Os diretórios
em `.claude/skills/` mantêm o nome completo (`sdd-prd`, `sdd-trd`, `sdd-implement`,
`sdd-code-review`, `sdd-qa`, `sdd-security`, `sdd-sre`, `sdd-status`, `sdd-amend`,
`sdd-pending`, `sdd-baseline`, `sdd-hotfix`, `sdd-sync-docs`, entre outras) porque, sem namespace
de plugin, o prefixo `sdd-` é o que evita colisão com skills de outros projetos (`/sdd-trd`, não
`/trd`). Dentro deste plugin o namespace `btt-sdd:` já cumpre esse papel sozinho, então o `sdd-`
seria redundante — por isso os diretórios equivalentes aqui **removem** esse prefixo:
`skills/prd/`, `skills/trd/`, `skills/implement/`, `skills/code-review/`, `skills/qa/`,
`skills/security/`, `skills/sre/`, `skills/status/`, `skills/amend/`, `skills/pending/`,
`skills/baseline/`, `skills/hotfix/`, `skills/sync-docs/`, entre outras — resultando em
`/btt-sdd:trd` em vez de `/btt-sdd:sdd-trd`. `create-project` já não tinha o prefixo `sdd-`, então
seu diretório não muda (`skills/create-project/` nos dois lados).

**Isso significa que editar `.claude/agents/*.md` ou `.claude/skills/*` na raiz do repositório não
atualiza este plugin automaticamente.** Ao mudar algo relevante lá, replique aqui:

1. Copie o arquivo alterado de `.claude/agents/` para o caminho equivalente em `agents/` deste
   plugin (mesmo nome de arquivo). Para skills, copie `.claude/skills/sdd-<nome>/SKILL.md` para
   `skills/<nome>/SKILL.md` deste plugin — **sem** o prefixo `sdd-` no caminho — e atualize o
   campo `name:` do frontmatter para o mesmo `<nome>` sem prefixo (ex.: `.claude/skills/sdd-trd/`
   com `name: sdd-trd` vira `plugins/btt-sdd/skills/trd/` com `name: trd`).
2. Se o arquivo copiado menciona um comando `/sdd-*` (skill deste pipeline) ou `/create-project`,
   troque pelo namespace deste plugin **removendo também o `sdd-`**: `/sdd-trd` → `/btt-sdd:trd`,
   `/sdd-code-review` → `/btt-sdd:code-review`, `/create-project` → `/btt-sdd:create-project`.
3. Se o arquivo menciona `.claude/agents/<nome>.md` como fallback ("se o Agent tool não estiver
   disponível, siga..."), troque pela referência genérica ao nome do agente (esse caminho não
   existe no contexto de um projeto onde o plugin foi instalado).

`skills/create-project/scaffold/` é a exceção — é conteúdo genérico que vai para o projeto-alvo
tal como está, sem menção a comandos deste plugin (usa a convenção `/sdd-*` sem namespace, igual
à raiz deste repositório), então uma cópia direta de
`.claude/skills/create-project/scaffold/` sempre basta.

**`.claude/skills/repo-issues/` é a segunda exceção — deliberadamente nunca replicada aqui.** É
manutenção deste repositório sobre si mesmo (lê/aplica issues de `asengardeon/btt-sdd-pipeline`,
abre PR e ajusta a versão deste `plugin.json`) — não faz sentido rodando em outro projeto, e não é
uma etapa do pipeline SDD que um usuário do plugin precise. Fica só na raiz, disponível nesta
máquina via junction (`~/.claude/skills`), fora do pacote instalável.
