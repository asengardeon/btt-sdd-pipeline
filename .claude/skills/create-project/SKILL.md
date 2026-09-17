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
   `README.md`, `.gitignore`, `docs/**`, `specs/_template/**`). Este repositório não mantém uma
   cópia própria do scaffold em `.claude/skills/create-project/` — a cópia do plugin é a única
   fonte, mesma usada por uma instalação standalone do plugin (`docs/GIT-WORKFLOW.md` não exige
   isso, mas evita duas cópias divergindo silenciosamente; ver `plugins/btt-sdd/README.md`). Se o
   usuário deu um nome de projeto, substitua o placeholder `<nome do projeto>` no `README.md`
   copiado.

5. **Gere o primeiro PRD**: siga o processo descrito em `.claude/agents/product-design.md` (o
   mesmo que `/sdd-prd` aciona) usando os requisitos coletados no passo 1, salvando em
   `<diretório novo>/specs/0001-<slug>/prd.md`. Aplique a mesma governança de não-suposição —
   pergunte o que for ambíguo, com "VALIDAR DEPOIS" como opção.

6. **Pare aqui.** Não continue o pipeline sozinho (TRD, implementação, etc.) — cada etapa exige
   aprovação explícita do usuário (`docs/QUALITY-GATES.md`). Apresente um resumo do PRD gerado,
   peça aprovação, e quando aprovado informe que o próximo passo é `cd` para o diretório novo e
   rodar `/sdd-trd` lá dentro.

## Por que `src/`, `frontend/`, `infra/`, `.github/workflows/` não são criados aqui

A stack (linguagem, framework, banco, infra) só é decidida no primeiro TRD, pelo `architect` —
criar essas pastas agora seria uma suposição sobre a stack antes de qualquer decisão técnica.
Elas nascem naturalmente quando o projeto chegar em `/sdd-implement` e `/sdd-sre` pela primeira
vez.
