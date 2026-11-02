# QA Report — <Nome da Feature> — Índice

> Autor: agente `qa-engineer`
> PRD: `specs/<slug>/prd.md` | TRD: `specs/<slug>/trd.md`

Este arquivo é sempre pequeno — é o índice, nunca o conteúdo (`docs/MICRO-CONTEXT.md`, seção 2).
**Leitura obrigatória toda rodada, por completo.** O conteúdo de cada rodada vive em `F-<N>.md`
(ou `hotfix-<data>.md`, para correção pontual) neste mesmo diretório; achados, pendências e log
acumulados vivem em `tracking.md`. Leia também `F-<N>.md` da rodada vigente e da penúltima —
rodadas mais antigas são referência sob demanda (`docs/AGENT-PREAMBLE.md`, seção "Artefato de
revisão que acumulou rodadas").

## Histórico de aprovações por fatia

Uma linha por rodada de QA (uma por fatia, ou uma por `hotfix-<data>`) — nunca sobrescreva o
veredito de uma fatia já aprovada e mergeada, acrescente uma linha nova. `Arquivo` é o nome do
arquivo desta rodada no mesmo diretório.

| Fatia | Arquivo | PR | Veredito | Data |
|-------|---------|-----|----------|------|
| F-1   | `F-1.md` | `<link>` | `<veredito>` | `<data>` |

## Próximo passo

`/sdd-security` (se aprovado, para a fatia da rodada vigente) ou `/sdd-implement` (se reprovado,
com os achados abertos de `tracking.md`).
