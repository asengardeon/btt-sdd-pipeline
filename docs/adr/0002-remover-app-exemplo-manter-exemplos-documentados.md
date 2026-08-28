# ADR 0002 — Remover o app de exemplo executável, manter exemplos documentados

> Status: aceito

## Contexto

Este repositório é um **template de pipeline SDD** (agentes, skills, docs de governança) — não um
projeto de aplicação. Desde o início, `specs/0001-example-task-management/` trazia, além dos
artefatos do pipeline (PRD, TRD, QA report, security review, SRE review), uma aplicação Python
real e funcional em `src/`/`tests/`, com `pyproject.toml`, `infra/docker/`, `infra/terraform/` e
`.github/workflows/` correspondentes, só para ilustrar o fluxo ponta a ponta com código de verdade
rodando.

Manter esse código junto ao template tem um custo permanente: toda mudança estrutural no
repositório (ex.: mudar convenção de pasta, adicionar um gate novo) precisa considerar se quebra o
app de exemplo; o CI do próprio repositório roda lint/testes/build Docker de uma aplicação que
ninguém usa de verdade; e um novo usuário do template pode confundir "o exemplo Python" com "a
stack que devo usar", quando o objetivo é justamente ser agnóstico de stack.

## Decisão

Remover `src/`, `tests/`, `infra/`, `.github/workflows/` e `pyproject.toml` do repositório.
Preservar o valor ilustrativo do código removido como **exemplo documentado** em
`specs/0001-example-task-management/code-examples.md` — trechos representativos de cada camada
(domínio, port, caso de uso, adapters, testes unit/integration, packaging, Docker, CI, CD) com
contexto explicando o papel de cada um. O PRD, TRD, QA report, security review e SRE review dessa
feature **não são alterados** — continuam sendo os artefatos reais, só sem o código executável ao
lado.

Criado também um agente utilitário de documentação técnica (`tech-writer`, skill `/sdd-docs`) para
este tipo de trabalho — transformar código real em exemplo documentado, e manter README/docs em
sincronia com as mecânicas reais do pipeline.

## Alternativas consideradas

- **Manter o app de exemplo como está**: descartado — custo de manutenção permanente sem benefício
  proporcional, já que o pipeline SDD já é agnóstico de stack por design; o exemplo real não
  precisa ser executável para ensinar o nível de detalhe esperado dos artefatos.
- **Mover o app de exemplo para um repositório separado**: descartado por ora — adiciona
  complexidade de manter dois repositórios sincronizados para um ganho pequeno; o exemplo
  documentado dentro do próprio diretório da feature já cumpre o papel ilustrativo.
- **Apagar o exemplo por completo (código e artefatos)**: descartado — o PRD/TRD/reports servem de
  referência real de nível de detalhe esperado em cada etapa do pipeline, valor que não depende do
  código estar rodando.

## Consequências

- O repositório para de carregar uma aplicação Python que ninguém usa de verdade — `pyproject.toml`,
  `src/`, `tests/`, `infra/`, `.github/workflows/` deixam de existir até que uma feature real seja
  implementada aqui (ou em outro projeto que adote o template).
- PRs futuros neste repositório (só agentes/skills/docs) deixam de ter checagem automática de CI —
  aceitável, já que não há mais código para lintar/testar. Confirmado via `gh api` que a branch
  `master` não tinha proteção configurada, então isso não bloqueia merges.
- `specs/0001-example-task-management/code-examples.md` passa a ser a referência de como o código
  ficava — qualquer doc que citava "código real rodando" nesta feature agora aponta para lá.
- O agente `tech-writer`/skill `/sdd-docs` fica disponível para qualquer trabalho futuro de
  documentação técnica, não só este.
