# `ux-review`: v2 → v3 (pendências separadas em produto e engenharia)

Regra de migração carregada por `/btt-sdd:migrate <slug> ux-review` quando a instância real está em v2. Ver
`docs/MICRO-CONTEXT.md`, seção 3, para o mecanismo genérico (marcador de versão, registro de
migrações) e seção 2 para o formato do split por rodada. O formato de destino da tabela de pendências
está em `gates/governanca.md` do pipeline ("Pendência de validação: produto ou engenharia").

## Detecção

- **Origem (v2)**: `specs/<slug>/reviews/ux-review/INDEX.md` existe com marcador `<!-- sdd-format-version: 2 -->`, ou o
  `specs/<slug>/reviews/ux-review/tracking.md` tem a seção "Pendências de validação (VALIDAR DEPOIS)" com uma tabela única (sem os subtítulos `### Decisões de
  produto` e `### Decisões de engenharia`).
- **Destino (v3)**: `specs/<slug>/reviews/ux-review/tracking.md` tem os dois subtítulos. Se já tiver, recuse — esta
  spec/artefato já foi migrado.
- Instância que veio de uma migração `v1 → v2` feita com o template já em `v3` tem marcador `3`
  mas ainda a tabela única: a estrutura decide, não o marcador. Aplique só os passos 2-3.

## O que é preservado e o que não é

**Preservado por completo**: toda linha da tabela de pendências, com ID, pergunta, contexto e
status inalterados (IDs não são renumerados). Só mudam o lugar da linha (uma das duas tabelas) e o
marcador de versão. Nenhum outro arquivo do split é tocado.

## Passos de transformação

1. Leia `specs/<slug>/reviews/ux-review/tracking.md`. Localize a seção "Pendências de validação (VALIDAR DEPOIS)" pelo título exato e leia todas as linhas da
   tabela, inclusive as já marcadas "validado".
2. Classifique cada linha pelo dono da decisão (`gates/governanca.md` do pipeline): **produto** (escopo,
   regra de negócio, prazo, definição de "concluído", dono de tela, aceite de uma limitação) ou
   **engenharia** (arquitetura, infraestrutura, CI, medição, método de validação, rastreio). Linha
   que depende dos dois vai para quem tem a decisão final. **Linha ambígua não é decidida por
   você**: reúna todas numa única `AskUserQuestion` ao usuário (nenhuma suposição silenciosa).
3. Reescreva a seção com a tabela única dividida em `### Decisões de produto` e `### Decisões de
   engenharia`, na ordem original dentro de cada uma, mesmo cabeçalho de colunas da tabela de
   origem. Inclua a nota de duas tabelas do template (`specs/_template/reviews/ux-review/tracking.template.md`).
   Uma tabela sem linhas fica só com cabeçalho.
4. Troque o marcador da primeira linha de `specs/<slug>/reviews/ux-review/INDEX.md` e de `specs/<slug>/reviews/ux-review/tracking.md` para `<!--
   sdd-format-version: 3 -->`. Os demais arquivos do split continuam em `v2`.
5. Confirme que o número de linhas somadas das duas tabelas é igual ao da tabela de origem.
