# Sincronização de docs entre o template do plugin e projetos já scaffolded

Todo projeto criado por `/create-project` recebe uma cópia, feita uma única vez, de
`skills/create-project/scaffold/{CLAUDE.md,docs/}` na versão do plugin instalada naquele momento
(`CLAUDE.md`, seção "Distribuição global"). Diferente dos agentes/skills — que, quando instalados
via plugin, são trocados inteiros a cada `claude plugin update` — os *docs do projeto* nunca são
atualizados automaticamente por um `update` de plugin, porque são arquivos do projeto, não do
plugin: `claude plugin update` troca os agentes/skills instalados, mas não toca `docs/*.md`/
`CLAUDE.md` de nenhum projeto que já existe. Isso significa que toda melhoria feita depois no
template de scaffold (`skills/create-project/scaffold/docs/*.md`) fica invisível para projetos
scaffolded antes dela, silenciosamente, para sempre — a menos que alguém porte a mudança
manualmente.

## O mecanismo

- **`plugins/btt-sdd/CHANGELOG.md`** registra, por versão do plugin, toda mudança feita nos
  arquivos de `skills/create-project/scaffold/docs/` e `skills/create-project/scaffold/CLAUDE.md`
  — as únicas partes do plugin que um projeto "possui" como cópia própria e desatualizável. Nada
  além disso entra nesse changelog (agentes/skills evoluem via `claude plugin update` normalmente,
  sem precisar desse mecanismo). Entrada nova acontece no mesmo commit/PR que muda o scaffold —
  nunca depois (`docs/GIT-WORKFLOW.md`, seção "Mudanças no próprio pipeline").
- **`docs/.sdd-plugin-version`** (na raiz de `docs/` de cada projeto que usa o pipeline via
  plugin instalado) guarda, em uma linha, a versão do plugin cujo scaffold esse projeto tem hoje —
  seja porque foi criado com `/create-project` naquela versão, seja porque `/sdd-sync-docs` já
  sincronizou até ela numa rodada anterior. Ausência do arquivo equivale a "nunca sincronizado
  desde que este mecanismo existe" (a versão mais antiga rastreada em
  `plugins/btt-sdd/CHANGELOG.md`). Projetos que usam a distribuição via junction (`CLAUDE.md`,
  seção "Distribuição global") nunca precisam desse arquivo — a junction sempre reflete a versão
  corrente deste repositório, não existe cópia para ficar desatualizada.
- **`/sdd-sync-docs`** (`.claude/skills/sdd-sync-docs/SKILL.md`) compara as duas coisas acima e
  oferece aplicar, uma a uma, as seções novas que o projeto ainda não tem — nunca sobrescrevendo
  conteúdo que o projeto já customizou.

## Quando `/sdd-sync-docs` roda

- **Sob demanda**, a qualquer momento, se o usuário pedir.
- **Automaticamente, uma vez por sessão**, na primeira vez que qualquer comando `/sdd-*` (ou
  `/btt-sdd:*`) desta sessão for invocado: confira `docs/.sdd-plugin-version` contra a versão do
  plugin instalada (`claude plugin details btt-sdd@btt-sdd-pipeline` — mesmo comando validado em
  `plugins/btt-sdd/README.md`); se `plugins/btt-sdd/CHANGELOG.md` tem entrada mais nova que a
  versão marcada, rode `/sdd-sync-docs` antes de prosseguir com o comando original. Não repita essa
  checagem a cada comando subsequente na mesma sessão — uma vez já é suficiente para saber se a
  sessão inteira está desatualizada ou não.
- Projetos sem `plugins/btt-sdd/` instalado (uso via junction) pulam essa checagem inteiramente —
  não se aplica (ver acima).

## O que `/sdd-sync-docs` faz

Ver `.claude/skills/sdd-sync-docs/SKILL.md` para o passo a passo completo. Resumo: lê as entradas
do changelog entre a versão marcada e a instalada, localiza a seção nova/alterada correspondente no
scaffold atual do plugin, verifica se ela já existe no arquivo real do projeto (por título de
seção) e, se não existir, propõe adicionar — sempre com aprovação explícita do usuário antes de
tocar em qualquer arquivo (`docs/QUALITY-GATES.md`, "Nenhuma suposição silenciosa"). Ao final,
atualiza `docs/.sdd-plugin-version` para a versão instalada, mesmo que o usuário tenha recusado
alguma seção específica — o marcador significa "esta versão já foi verificada", não "tudo foi
aplicado"; seções recusadas ficam registradas no resumo final para o usuário revisitar manualmente
se mudar de ideia depois.
