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
atualiza o plugin já instalado. Para pegar mudanças novas, rode `claude plugin update
btt-sdd@btt-sdd-pipeline` (ou remova e reinstale).

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
`user`, `enabled`), e uma sessão nova (`claude -p "/btt-sdd:sdd-status"`) reconheceu e executou o
comando namespaced corretamente contra `specs/0001-example-task-management/`, coexistindo sem
conflito com os comandos sem prefixo da junction (`/sdd-pending` etc.).

## ⚠️ Isto é uma cópia, não um link

Diferente de `.claude/agents/`/`.claude/skills/` (que ficam disponíveis globalmente via junction
de diretório em `~/.claude/agents`/`~/.claude/skills`, apontando direto para cá), o conteúdo
deste plugin é uma **cópia própria** — necessário porque skills instaladas via plugin ganham o
namespace `btt-sdd:` (ex.: `/btt-sdd:sdd-trd`), então toda referência interna a um comando
`/sdd-*` dentro dos arquivos deste plugin já vem com esse prefixo, diferente das cópias em
`.claude/`.

**Isso significa que editar `.claude/agents/*.md` ou `.claude/skills/*` na raiz do repositório não
atualiza este plugin automaticamente.** Ao mudar algo relevante lá, replique aqui:

1. Copie o arquivo alterado de `.claude/agents/` ou `.claude/skills/` para o caminho equivalente
   em `agents/`/`skills/` deste plugin.
2. Se o arquivo copiado menciona um comando `/sdd-*` ou `/create-project`, adicione o prefixo
   `btt-sdd:` logo após a barra (ex.: `/sdd-trd` → `/btt-sdd:sdd-trd`).
3. Se o arquivo menciona `.claude/agents/<nome>.md` como fallback ("se o Agent tool não estiver
   disponível, siga..."), troque pela referência genérica ao nome do agente (esse caminho não
   existe no contexto de um projeto onde o plugin foi instalado).

`skills/create-project/scaffold/` é a exceção — é conteúdo genérico que vai para o projeto-alvo
tal como está, sem menção a comandos deste plugin, então uma cópia direta de
`.claude/skills/create-project/scaffold/` sempre basta.
