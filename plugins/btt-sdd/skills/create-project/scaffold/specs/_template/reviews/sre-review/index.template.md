# SRE Review — <Nome da Feature> — Índice

> Autor: agente `sre`
> QA report: `specs/<slug>/qa-report.md`

Este arquivo é sempre pequeno — é o índice, nunca o conteúdo (`MICRO-CONTEXT.md` do pipeline,
seção 2). **Leitura obrigatória toda rodada, por completo.** O conteúdo de cada rodada vive em
`F-<N>.md` (ou `hotfix-<data>.md`, para correção pontual) neste mesmo diretório; pendências e log
acumulados vivem em `tracking.md`. Leia também `F-<N>.md` da rodada vigente e da penúltima —
rodadas mais antigas são referência sob demanda (`AGENT-PREAMBLE.md` do pipeline, seção
"Artefato de revisão que acumulou rodadas").

## Histórico de aprovações por fatia

Uma linha por rodada de revisão (uma por fatia, ou uma por `hotfix-<data>`) — nunca sobrescreva o
veredito de uma fatia já aprovada e mergeada, acrescente uma linha nova. `Arquivo` é o nome do
arquivo desta rodada no mesmo diretório.

| Fatia | Arquivo | PR | Veredito | Profundidade | Commit | Data |
|-------|---------|-----|----------|---------------|--------|------|
| F-1   | `F-1.md` | `<link>` | `<veredito>` | `<completo\|fast-path>` | `<sha>` | `<data>` |

`Profundidade`: `completo` (checklist revisado de verdade) ou `fast-path` (áreas sem superfície
tocada foram condensadas — critério em `agents/sre.md`). Na fatia final que fecha o spec, é
sempre `completo`. `Commit`: SHA do HEAD no momento desta revisão — usado para calcular o diff
acumulado na auditoria final.

## Próximo passo

Se aprovado: esta fatia está pronta para merge em `main` (`docs/GIT-WORKFLOW.md`) — se houver
fatias seguintes na feature, elas só começam depois deste merge. Caso contrário: os itens
abertos de `tracking.md` devem ser resolvidos antes.
