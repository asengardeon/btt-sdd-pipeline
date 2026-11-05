<!-- sdd-format-version: 1 -->
# Plano de implementação — <slug> / <fatia>

> Aprovado por: usuário, via `AskUserQuestion`
> Branch: `<nome-da-branch>`
> Trilhas: `<backend | frontend | backend+frontend>`
> Data:

Este arquivo registra o plano que o orquestrador de `/sdd-implement` apresentou e o usuário
aprovou **antes** de qualquer código ser escrito nesta fatia — não um resumo depois do fato.
`code-reviewer` lê este arquivo (quando existir) e confere o diff contra ele, além do TRD.

## Arquivos que mudam

Caminhos, não conteúdo — um por linha, com a trilha quando a fatia é full-stack.

| Caminho | Trilha |
|---|---|
| `<src/.../arquivo.py>` | `<backend\|frontend>` |

## Ordem dos incrementos

Numerada, na ordem real de implementação — idealmente um incremento por caso de uso. Com duas
trilhas, mostre como cada incremento de uma depende do (ou habilita o) incremento equivalente da
outra, via o contrato Frontend↔Backend do TRD (ex.: "frontend consome um dublê até o incremento 2,
quando o endpoint real passa a existir").

| # | Incremento | Trilha | Prova (teste que comprova completude) |
|---|------------|--------|------------------------------------------|
| 1 | `<descrição>` | `<backend\|frontend\|ambos>` | `<arquivo/caso de teste>` |

## Riscos

O que pode dar errado, ou a decisão mais arriscada do plano. "Nenhum risco identificado" é uma
afirmação a justificar, não o padrão default — toda fatia tem pelo menos uma decisão mais incerta
que as outras.

## Lições aplicadas

Lição de `docs/LESSONS-LEARNED.md` usada neste plano (ID + como foi aplicada) — "nenhuma lição
aplicável" se o arquivo não existe ou nenhuma entrada bate com esta fatia.

## Divergências registradas durante a implementação

Preenchido só se o código final se afastar deste plano — o que mudou e por quê, no mesmo commit em
que a divergência aparece. Vazio é o caso normal; um plano cumprido à risca não precisa de entrada
aqui.
