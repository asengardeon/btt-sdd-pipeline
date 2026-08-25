# Guia de arquivos — o que cada arquivo/pasta faz

Referência item a item do repositório. Para o *porquê* das decisões, veja `docs/ARCHITECTURE.md`
e `docs/SDD-WORKFLOW.md`; este documento é sobre *o que cada coisa é*.

## Raiz

- **`CLAUDE.md`** — arquivo que o Claude Code carrega automaticamente no início de toda sessão
  neste repositório. É o ponto de entrada: resume o pipeline, os princípios e onde encontrar
  cada detalhe.
- **`README.md`** — introdução para humanos.

## Agentes e skills (globais)

Os agentes (`product-design`, `architect`, `backend-developer`, `frontend-developer`,
`code-reviewer`, `qa-engineer`, `security-engineer`, `sre`, `codebase-archaeologist`) e as skills
(`/sdd-*`, `/create-project`) **não vivem neste repositório** — estão instalados globalmente no computador
onde este projeto foi criado, e funcionam aqui porque este repositório segue a mesma estrutura de
`specs/`, `docs/`, `CLAUDE.md` que eles esperam. Não é necessário (nem esperado) copiar
`.claude/agents/` ou `.claude/skills/` para dentro deste projeto.

## `docs/` — documentação de referência

- **`ARCHITECTURE.md`** — explica ports & adapters, SOLID, clean code, e a convenção de
  `frontend/` quando aplicável.
- **`SDD-WORKFLOW.md`** — explica o pipeline de 7 etapas (+ 1 condicional) em detalhe.
- **`TESTING.md`** — explica TDD, a pirâmide de testes e o gate de cobertura de 80% por pacote.
- **`ENGINEERING-PILLARS.md`** — explica os pilares de engenharia (performance, escalabilidade,
  resiliência, disponibilidade, observabilidade, manutenibilidade) que o `architect` precisa
  endereçar explicitamente em todo TRD.
- **`QUALITY-GATES.md`** — checklist único e não-negociável dos gates críticos do pipeline.
- **`GIT-WORKFLOW.md`** — GitHub Flow aplicado ao pipeline.
- **`BASELINE.md`** — **gerado condicionalmente** pelo `codebase-archaeologist`, só se este
  projeto vier a incorporar código pré-existente sem documentação suficiente. Não existe por
  padrão num projeto criado do zero.
- **`STACK.md`** — **gerado condicionalmente** pelo `architect`, na primeira vez que a stack
  tecnológica é decidida neste projeto (linguagem, framework, persistência). Não é criado por
  `/create-project` — sua ausência é o sinal de "stack ainda não decidida". Quando existe, é a
  fonte que evita perguntar de novo em features seguintes.
- **`FILE-GUIDE.md`** — este arquivo.
- **`adr/`** — Architecture Decision Records. `0001-...md` é o próprio ADR que estabelece a
  convenção de registrar ADRs.

## `specs/` — os artefatos do pipeline SDD, um diretório por feature

- **`_template/`** — os modelos que os agentes preenchem (`prd`, `trd`, `code-review`,
  `qa-report`, `security-review`, `sre-review`). Não é uma feature, é a fôrma usada por todas.
- **Cada feature** ganha uma pasta `NNNN-slug-em-kebab-case/` com os artefatos que forem sendo
  produzidos por cada etapa.

## `src/`, `frontend/`, `tests/` — ainda não existem

Este projeto foi criado por `/create-project` e ainda não tem stack decidida. Essas pastas são
criadas por `backend-developer`/`frontend-developer` na primeira vez que `/sdd-implement` roda,
seguindo a convenção descrita em `docs/ARCHITECTURE.md` (ports & adapters em `src/`; componentes/
serviços em `frontend/`, se a feature tiver UI).

## `infra/`, `.github/workflows/` — ainda não existem

Criados pelo `sre` (`/sdd-sre`) quando a primeira feature chega a essa etapa, depois que a stack
já foi decidida no TRD — não faz sentido escolher Docker/Terraform antes de saber a linguagem.

## Arquivos de configuração da stack

Decididos pelo `architect` no primeiro TRD e registrados em `docs/STACK.md` (linguagem,
framework, persistência, gerenciador de pacotes); os arquivos de configuração propriamente ditos
(`pyproject.toml`, `package.json`, ou equivalente) são criados por
`backend-developer`/`frontend-developer` durante a implementação, seguindo essa decisão.

- **`.gitignore`** — padrões genéricos a ignorar; ajuste conforme a stack escolhida.
