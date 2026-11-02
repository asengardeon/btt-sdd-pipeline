# `prd`: v1 (arquivo único) → v2 (split por tópico)

Regra de migração carregada por `/sdd-migrate <slug> prd` quando a instância real está em v1. Ver
`docs/MICRO-CONTEXT.md`, seção 3, para o mecanismo genérico (marcador de versão, registro de
migrações) e seção 2b para o formato de destino e a tabela seção→arquivo.

## Detecção

- **Origem (v1)**: `specs/<slug>/prd.md` existe; marcador `<!-- sdd-format-version: 1 -->` ou
  ausente (specs escritas antes da convenção de marcador existir — tratadas como v1 por padrão).
- **Destino (v2)**: `specs/<slug>/prd/INDEX.md` existe. Se já existir, recuse — esta spec/artefato
  já foi migrado.

## O que é preservado e o que não é

**Preservado por completo** — PRD v1 nunca sobrescrevia seção nenhuma a cada rodada (diferente
dos 5 artefatos de revisão); é um único documento escrito uma vez e emendado. Toda seção migra
sem perda:

- Seções 1-5 (visão geral, problema, personas, objetivos, fora de escopo).
- Seções 6-7 (histórias de usuário e critérios de aceite; wireframes/protótipos).
- Seções 8-9 (métricas de sucesso; indicadores técnicos a observar).
- Seção 10 (ordem de valor / fatias verticais).
- Seção 11 (pendências VALIDAR DEPOIS).
- Seção 12 (log de revisões).
- Seção 13 (aprovação).

**Instância mais antiga que o próprio v1** (sem marcador, escrita antes de alguma seção do
template atual existir — ex.: um PRD de antes da seção "Wireframes/Protótipos de tela" ou "Ordem
de valor" serem adicionadas ao template): a seção simplesmente não existe na origem. Não invente
conteúdo — no arquivo-destino correspondente, registre a seção/tabela como "não aplicável — esta
versão do PRD, anterior à introdução desta seção no template, não tinha este conteúdo
documentado" em vez de deixar em branco ou copiar o placeholder do template como se fosse real.

## Passos de transformação

1. Leia `specs/<slug>/prd.md` por completo. Identifique cada seção pelo **título exato** (nunca
   só pela posição — um PRD emendado várias vezes pode ter parágrafos extras entre seções, **e o
   número à frente do título pode não bater com o template atual**: seções foram adicionadas ao
   template ao longo do tempo sem bump de versão, então duas instâncias em "v1" podem ter
   numeração diferente para o mesmo conteúdo). Mapeie por título, não por número — o arquivo de
   destino usa a numeração do template de destino (`specs/_template/prd/*.template.md`), nunca a
   numeração que a origem por acaso tinha.
2. Crie `specs/<slug>/prd/INDEX.md` a partir de `specs/_template/prd/index.template.md` (marcador
   `v2` herdado do template): copie o cabeçalho (Status/Autor/Relacionado) e as seções 1-5, 8, 9,
   13 verbatim, preenchendo a tabela "Arquivos deste PRD" com os três arquivos criados nos passos
   seguintes.
3. Crie `specs/<slug>/prd/user-stories.md` a partir de
   `specs/_template/prd/user-stories.template.md`: copie as seções 6 e 7 verbatim (todas as
   histórias de usuário, todos os critérios de aceite, a subseção de wireframes completa).
4. Crie `specs/<slug>/prd/value-order.md` a partir de
   `specs/_template/prd/value-order.template.md`: copie a tabela da seção 10 linha por linha, sem
   alterar valores.
5. Crie `specs/<slug>/prd/tracking.md` a partir de `specs/_template/prd/tracking.template.md`:
   copie as tabelas das seções 11 e 12 linha por linha, sem alterar valores.
6. Adicione o banner de migração no topo do arquivo legado (texto exato no núcleo da skill, passo
   7 de `.claude/skills/sdd-migrate/SKILL.md`) — nunca delete nem mova o arquivo original.
