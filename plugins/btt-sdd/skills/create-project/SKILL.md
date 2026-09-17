---
name: create-project
description: Skill global. Use quando o usuário quiser começar um projeto novo do zero a partir de uma especificação do que a aplicação deve fazer — cria um diretório separado, inicializa git, monta a estrutura base do pipeline SDD, e gera o primeiro PRD a partir dos requisitos coletados. Não use para trabalhar num projeto já existente (aí é /btt-sdd:prd, /btt-sdd:trd etc. dentro dele).
---

# /btt-sdd:create-project

Bootstrap de um projeto novo, em qualquer lugar do sistema de arquivos, com a estrutura SDD
completa (`CLAUDE.md`, `docs/`, `specs/_template/`) pronta para o pipeline
(`docs/SDD-WORKFLOW.md`) rodar nele desde o primeiro PRD. Não aciona um subagente próprio — você
mesmo (a sessão atual) faz o scaffolding e depois segue o processo do `product-design`
diretamente.

## Passos

1. **Pergunte, não assuma** (mesma governança do resto do pipeline, `docs/QUALITY-GATES.md`):
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

5. **Gere o primeiro PRD**: siga o mesmo processo descrito no agente `product-design` (o mesmo
   que `/btt-sdd:prd` aciona) usando os requisitos coletados no passo 1, salvando em
   `<diretório novo>/specs/0001-<slug>/prd.md`. Aplique a mesma governança de não-suposição —
   pergunte o que for ambíguo, com "VALIDAR DEPOIS" como opção.

6. **Pare aqui.** Não continue o pipeline sozinho (TRD, implementação, etc.) — cada etapa exige
   aprovação explícita do usuário (`docs/QUALITY-GATES.md`). Apresente um resumo do PRD gerado,
   peça aprovação, e quando aprovado informe que o próximo passo é `cd` para o diretório novo e
   rodar `/btt-sdd:trd` lá dentro.

## Por que `src/`, `frontend/`, `infra/`, `.github/workflows/` não são criados aqui

A stack (linguagem, framework, banco, infra) só é decidida no primeiro TRD, pelo `architect` —
criar essas pastas agora seria uma suposição sobre a stack antes de qualquer decisão técnica.
Elas nascem naturalmente quando o projeto chegar em `/btt-sdd:implement` e `/btt-sdd:sre` pela primeira
vez.
