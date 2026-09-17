---
name: create-project
description: Skill global. Use quando o usuário quiser começar um projeto novo do zero a partir de uma especificação do que a aplicação deve fazer — cria um diretório separado, inicializa git, monta a estrutura base do pipeline SDD, e gera o primeiro PRD a partir dos requisitos coletados. Não use para trabalhar num projeto já existente (aí é /sdd-prd, /sdd-trd etc. dentro dele).
---

# /create-project

Bootstrap de um projeto novo, em qualquer lugar do sistema de arquivos, com a estrutura SDD
completa (`CLAUDE.md`, `docs/`, `specs/_template/`) pronta para o pipeline
(`docs/SDD-WORKFLOW.md`) rodar nele desde o primeiro PRD. Não aciona um subagente próprio — você
mesmo (a sessão atual) faz o scaffolding e depois segue o processo do `product-design`
diretamente.

## Onde ficam os docs de governança citados nesta skill

Referências como `docs/GIT-WORKFLOW.md`, `docs/QUALITY-GATES.md`, `docs/TESTING.md`,
`docs/ENGINEERING-PILLARS.md`, `docs/ARCHITECTURE.md`, `docs/SDD-WORKFLOW.md`,
`docs/FILE-GUIDE.md` e `docs/POST-MERGE-VALIDATION.md` nesta skill apontam para os docs genéricos
deste pipeline — **não são copiados para dentro de cada projeto que o usa**. Resolva-os a partir
de onde esta própria skill está instalada (o "Base directory" desta invocação): se for
`.claude/skills/<esta-skill>/` apontando para este repositório via junction global (`CLAUDE.md`,
seção "Distribuição global"), esses docs estão em `docs/` na raiz **deste mesmo repositório** —
não necessariamente no projeto onde você está trabalhando agora. Se o projeto atual também tiver
um `docs/<nome>.md` próprio (`STACK.md`, `BASELINE.md`, `LESSONS-LEARNED.md`, `adr/`), esse é
conteúdo do projeto, não deste pipeline — não confunda os dois.

## Passos

1. **Pergunte, não assuma** (mesma governança do resto do pipeline, `docs/QUALITY-GATES.md`):
   - Nome do projeto.
   - Diretório de destino — sugira um caminho razoável (ex.: irmão do diretório atual, ou dentro
     de uma pasta comum de projetos que você identificar no sistema), mas **pergunte
     explicitamente**, nunca crie em um lugar sem confirmação.
   - Os requisitos da aplicação — o que ela deve fazer. Se o usuário já descreveu isso no pedido
     que disparou `/create-project`, use isso como ponto de partida e só pergunte o que faltar.

2. **Confirme que o diretório não existe ainda** (ou está vazio). Se já existe com conteúdo, pare
   e pergunte ao usuário como proceder — nunca sobrescreva silenciosamente.

3. **Crie o diretório e inicialize git**: `mkdir` do caminho confirmado, `git init` dentro dele.

4. **Copie o scaffold**: todo o conteúdo de `plugins/btt-sdd/skills/create-project/scaffold/`
   (caminho relativo à raiz do repositório onde este arquivo `SKILL.md` vive, ou seja
   `../../../plugins/btt-sdd/skills/create-project/scaffold/` a partir daqui, de onde quer que
   esta skill esteja instalada) para o diretório novo, preservando a estrutura (`CLAUDE.md`,
   `README.md`, `.gitignore`, `docs/adr/**`, `specs/_template/**`). **Note que `docs/` do
   scaffold só tem `adr/`** — os docs de governança genéricos do pipeline (`GIT-WORKFLOW.md`,
   `QUALITY-GATES.md`, `TESTING.md`, etc.) não são copiados: eles vivem em
   `plugins/btt-sdd/docs/` (ou, via junction, na raiz deste repositório), lidos diretamente pelos
   agentes/skills a partir de onde estão instalados — nunca duplicados para dentro do projeto
   novo, o que elimina a necessidade de qualquer sincronização futura. O `docs/` do projeto novo
   fica só com o que é genuinamente dele (`adr/` agora; `STACK.md`/`BASELINE.md`/
   `LESSONS-LEARNED.md` nascem depois, conforme o pipeline avança). Este repositório não mantém
   uma cópia própria do scaffold em `.claude/skills/create-project/` — a cópia do plugin é a única
   fonte, mesma usada por uma instalação standalone do plugin (ver `plugins/btt-sdd/README.md`).
   Se o usuário deu um nome de projeto, substitua o placeholder `<nome do projeto>` no `README.md`
   copiado.

5. **Semeie `docs/PROJECT-CONVENTIONS.md`**: invoque o `codebase-archaeologist` (mesmo processo de
   `/sdd-project-conventions`) contra o diretório recém-criado, para registrar desde já qualquer
   particularidade que já exista neste momento (ex.: convenção de nomenclatura pedida pelo usuário
   nos requisitos coletados). Num projeto novo, sem histórico de branch e sem estrutura além do
   scaffold genérico, o resultado mais comum é "nenhuma particularidade a registrar ainda" — não
   crie o arquivo nesse caso; ele nasce mais tarde, via `/sdd-project-conventions` ou
   `/sdd-baseline`, assim que o projeto acumular convenções reais.

6. **Gere o primeiro PRD**: siga o processo descrito em `.claude/agents/product-design.md` (o
   mesmo que `/sdd-prd` aciona) usando os requisitos coletados no passo 1, salvando em
   `<diretório novo>/specs/0001-<slug>/prd.md`. Aplique a mesma governança de não-suposição —
   pergunte o que for ambíguo, com "VALIDAR DEPOIS" como opção.

7. **Pare aqui.** Não continue o pipeline sozinho (TRD, implementação, etc.) — cada etapa exige
   aprovação explícita do usuário (`docs/QUALITY-GATES.md`). Apresente um resumo do PRD gerado,
   peça aprovação, e quando aprovado informe que o próximo passo é `cd` para o diretório novo e
   rodar `/sdd-trd` lá dentro.

## Por que `src/`, `frontend/`, `infra/`, `.github/workflows/` não são criados aqui

A stack (linguagem, framework, banco, infra) só é decidida no primeiro TRD, pelo `architect` —
criar essas pastas agora seria uma suposição sobre a stack antes de qualquer decisão técnica.
Elas nascem naturalmente quando o projeto chegar em `/sdd-implement` e `/sdd-sre` pela primeira
vez.
