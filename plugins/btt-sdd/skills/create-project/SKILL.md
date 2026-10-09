---
name: create-project
description: Skill global. Use quando o usuário quiser começar um projeto novo do zero a partir de uma especificação do que a aplicação deve fazer — cria um diretório separado, inicializa git, monta a estrutura base do pipeline SDD, e gera o primeiro PRD a partir dos requisitos coletados. Não use para trabalhar num projeto já existente (aí é /btt-sdd:prd, /btt-sdd:trd etc. dentro dele).
---

# /btt-sdd:create-project

Bootstrap de um projeto novo, em qualquer lugar do sistema de arquivos, com a estrutura SDD
completa (`CLAUDE.md`, `docs/`, `specs/_template/`) pronta para o pipeline
(`docs/SDD-WORKFLOW.md`) rodar nele desde o primeiro PRD. Não aciona um subagente próprio para o
scaffolding — você mesmo (a sessão atual) monta a estrutura e, para o primeiro PRD, conduz o
processo completo de `/btt-sdd:prd` (passo 6), não só o do agente `product-design`.

**Antes de qualquer coisa, leia `docs/SKILL-PREAMBLE.md`** — onde ficam os docs de governança
deste pipeline e de onde vêm os templates de `specs/_template/` (nenhum dos dois vive dentro do
projeto onde você está trabalhando). Resolva esse caminho a partir do "Base directory" desta
invocação: via junction global, é `docs/` na raiz do repositório do pipeline; via plugin, é
`docs/` dentro do pacote.

## Passos

1. **Pergunte, não assuma** (mesma governança do resto do pipeline, `docs/gates/governanca.md`):
   - Nome do projeto.
   - Diretório de destino — sugira um caminho razoável (ex.: irmão do diretório atual, ou dentro
     de uma pasta comum de projetos que você identificar no sistema), mas **pergunte
     explicitamente**, nunca crie em um lugar sem confirmação.
   - Os requisitos da aplicação — o que ela deve fazer. Se o usuário já descreveu isso no pedido
     que disparou `/btt-sdd:create-project`, use isso como ponto de partida e só pergunte o que faltar.

2. **Confirme que o diretório não existe ainda** (ou está vazio). Se já existe com conteúdo, pare
   e pergunte ao usuário como proceder — nunca sobrescreva silenciosamente.

3. **Crie o diretório e inicialize git**: `mkdir` do caminho confirmado, `git init` dentro dele.

4. **Copie o scaffold**: todo o conteúdo da pasta `scaffold/` deste plugin (a pasta irmã deste
   arquivo `SKILL.md`, dentro de onde quer que o plugin `btt-sdd` esteja instalado) para o
   diretório novo, preservando a estrutura (`CLAUDE.md`, `README.md`, `.gitignore`, `docs/adr/**`,
   `specs/_template/**`). **Note que `docs/` do scaffold só tem `adr/`** — os docs de governança
   genéricos do pipeline (`GIT-WORKFLOW.md`, `QUALITY-GATES.md`, `TESTING.md`, etc.) não são
   copiados: eles vivem em `docs/` na raiz deste plugin instalado, lidos diretamente pelos
   agentes/skills a partir de lá — nunca duplicados para dentro do projeto novo, o que elimina a
   necessidade de qualquer sincronização futura. O `docs/` do projeto novo fica só com o que é
   genuinamente dele (`adr/` agora; `STACK.md`/`BASELINE.md`/`LESSONS-LEARNED.md` nascem depois,
   conforme o pipeline avança). Se o usuário deu um nome de projeto, substitua o placeholder
   `<nome do projeto>` no `README.md` copiado.

5. **Semeie `docs/PROJECT-CONVENTIONS.md`**: invoque o `codebase-archaeologist` (mesmo processo de
   `/btt-sdd:project-conventions`) contra o diretório recém-criado, para registrar desde já
   qualquer particularidade que já exista neste momento (ex.: convenção de nomenclatura pedida pelo
   usuário nos requisitos coletados). Num projeto novo, sem histórico de branch e sem estrutura
   além do scaffold genérico, o resultado mais comum é "nenhuma particularidade a registrar ainda"
   — não crie o arquivo nesse caso; ele nasce mais tarde, via `/btt-sdd:project-conventions` ou
   `/btt-sdd:baseline`, assim que o projeto acumular convenções reais.

6. **Gere o primeiro PRD**: conduza o processo completo de `/btt-sdd:prd`
   (`skills/prd/SKILL.md`, passos 2b a 5) usando os requisitos coletados no passo 1
   como o pedido, salvando em `<diretório novo>/specs/0001-<slug>/prd.md`. **Não basta seguir
   `agents/product-design.md`** — aquele é o processo do agente, e dois gates obrigatórios
   de `docs/gates/prd.md` vivem no orquestrador da etapa 1, fora do agente: (a) a oferta de
   wireframes/protótipos ao usuário, com a consulta sobre estabelecer `docs/DESIGN-SYSTEM.md`
   quando ele ainda não existe, e (b) a consultoria de `ux-designer`, que
   `agents/ux-designer.md` só aceita vinda de quem orquestra a etapa 1, nunca direto. O
   agente não tem as ferramentas (`Artifact`, skill `design`, Agent tool) para produzir nenhum dos
   dois sozinho. Aplique a mesma governança de não-suposição — pergunte o que for ambíguo, com
   "VALIDAR DEPOIS" como opção.

   **Aqui o passo 2b praticamente sempre dispara**: é um produto inteiro nascendo, então "a
   aplicação tem UI?" é sim, salvo quando o usuário descreveu explicitamente algo sem interface
   (biblioteca, CLI, serviço headless). E é a rodada de maior efeito composto — é nela que
   `docs/DESIGN-SYSTEM.md` nasce para toda feature seguinte reaproveitar, e em que o parecer de UX
   ainda pode mudar a forma do produto. Pular esses dois gates aqui faz o primeiro PRD do projeto
   nascer reprovado no gate da própria etapa.

7. **Pare aqui.** Não continue o pipeline sozinho (TRD, implementação, etc.) — cada etapa exige
   aprovação explícita do usuário (`docs/gates/governanca.md`). Apresente um resumo do PRD gerado,
   peça aprovação, e quando aprovado informe que o próximo passo é `cd` para o diretório novo e
   rodar `/btt-sdd:trd` lá dentro.

## Por que `src/`, `frontend/`, `infra/`, `.github/workflows/` não são criados aqui

A stack (linguagem, framework, banco, infra) só é decidida no primeiro TRD, pelo `architect` —
criar essas pastas agora seria uma suposição sobre a stack antes de qualquer decisão técnica.
Elas nascem naturalmente quando o projeto chegar em `/btt-sdd:implement` e `/btt-sdd:sre` pela primeira
vez.
