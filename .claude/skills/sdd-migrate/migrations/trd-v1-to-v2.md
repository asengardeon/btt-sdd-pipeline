# `trd`: v1 (arquivo único) → v2 (split por tópico)

Regra de migração carregada por `/sdd-migrate <slug> trd` quando a instância real está em v1. Ver
`docs/MICRO-CONTEXT.md`, seção 3, para o mecanismo genérico (marcador de versão, registro de
migrações) e seção 2b para o formato de destino e a tabela seção→arquivo.

## Detecção

- **Origem (v1)**: `specs/<slug>/trd.md` existe; marcador `<!-- sdd-format-version: 1 -->` ou
  ausente (specs escritas antes da convenção de marcador existir — tratadas como v1 por padrão).
- **Destino (v2)**: `specs/<slug>/trd/INDEX.md` existe. Se já existir, recuse — esta
  spec/artefato já foi migrado.

## O que é preservado e o que não é

**Preservado por completo** — TRD v1 nunca sobrescrevia seção nenhuma a cada rodada (diferente
dos 5 artefatos de revisão); é um único documento escrito uma vez e emendado. Toda seção migra
sem perda:

- Seções 1-2 (contexto; stack tecnológica).
- Seções 3-5, 7, 9 (arquitetura; modelo de domínio; ports; adapters; modelo de dados).
- Seção 6 (casos de uso).
- Seção 8 (contrato Frontend↔Backend).
- Seções 10, 12 (pilares de engenharia; riscos e trade-offs).
- Seção 11 (plano de testes).
- Seção 13 (decomposição de tarefas, incl. "Janelas de quebra de contrato entre fatias").
- Seção 14 (controle de versão por fatia).
- Seções 15-16 (pendências VALIDAR DEPOIS; log de revisões).
- Seção 17 (aprovação).

## Passos de transformação

1. Leia `specs/<slug>/trd.md` por completo. Identifique cada seção pelo **título exato**
   (`## N. <título>`), nunca só pela posição — um TRD emendado várias vezes (`/sdd-amend`) pode
   ter parágrafos extras entre seções, e a tabela de decomposição de tarefas (seção 13) pode ter
   dezenas de linhas acumuladas entre fatias.
2. Crie `specs/<slug>/trd/INDEX.md` a partir de `specs/_template/trd/index.template.md` (marcador
   `v2` herdado do template): copie o cabeçalho (Status/Autor/PRD relacionado/ADRs relacionados)
   e as seções 1, 2, 14, 17 verbatim — incluindo a tabela de branch/PR por fatia da seção 14
   inteira, linha por linha — preenchendo a tabela "Arquivos deste TRD" com os sete arquivos
   criados nos passos seguintes.
3. Crie `specs/<slug>/trd/architecture.md` a partir de
   `specs/_template/trd/architecture.template.md`: copie as seções 3, 4, 5, 7, 9 verbatim
   (diagrama de arquitetura, modelo de domínio, todos os ports, adapters de entrada e saída,
   modelo de dados).
4. Crie `specs/<slug>/trd/contract.md` a partir de `specs/_template/trd/contract.template.md`:
   copie a seção 8 verbatim.
5. Crie `specs/<slug>/trd/use-cases.md` a partir de `specs/_template/trd/use-cases.template.md`:
   copie a tabela da seção 6 linha por linha, sem alterar valores.
6. Crie `specs/<slug>/trd/quality.md` a partir de `specs/_template/trd/quality.template.md`:
   copie as seções 10 e 12 verbatim, incluindo a tabela de riscos da seção 12 linha por linha e
   as marcações `[medido]`/`[não medido]` exatamente como estavam.
7. Crie `specs/<slug>/trd/test-plan.md` a partir de `specs/_template/trd/test-plan.template.md`:
   copie a seção 11 verbatim.
8. Crie `specs/<slug>/trd/tasks.md` a partir de `specs/_template/trd/tasks.template.md`: copie a
   tabela principal da seção 13 e a tabela "Janelas de quebra de contrato entre fatias" linha por
   linha, sem alterar valores — inclusive a coluna `Status` e `Issue GitHub` de cada tarefa, que é
   a fonte de verdade usada por `/sdd-implement`/`/sdd-status`/`/sdd-pending`.
9. Crie `specs/<slug>/trd/tracking.md` a partir de `specs/_template/trd/tracking.template.md`:
   copie as tabelas das seções 15 e 16 linha por linha, sem alterar valores.
10. **Esvazie o corpo do arquivo legado**, mantendo só o título e o banner de migração (texto
    exato no núcleo da skill, passo 9) apontando para `specs/<slug>/trd/` — nunca delete nem mova
    o arquivo original, só o conteúdo dele.
