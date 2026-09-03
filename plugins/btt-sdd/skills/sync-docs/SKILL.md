---
name: sync-docs
description: Utilitário do pipeline SDD. Compara os docs do projeto (CLAUDE.md, docs/*.md) contra o changelog de scaffold da versão instalada do plugin btt-sdd, e oferece aplicar seções novas que o projeto ainda não tem. Use quando o plugin foi atualizado (claude plugin update) e os docs do projeto podem ter ficado para trás, ou quando outro comando /btt-sdd:* detectar essa divergência no início da sessão. Ver docs/DOCS-SYNC.md para o mecanismo completo.
---

# /btt-sdd:sync-docs

Utilitário — não aciona nenhum agente, não faz parte das 7 etapas do pipeline. Resolve a
divergência descrita em `docs/DOCS-SYNC.md`: docs de projeto (`CLAUDE.md`, `docs/*.md`) que
nasceram de uma versão antiga do template de scaffold do plugin
(`skills/create-project/scaffold/`) e nunca foram atualizados quando o template ganhou seções
novas depois.

**Só se aplica a projetos que usam o plugin instalado** (`plugins/btt-sdd/`). Projetos que usam a
distribuição via junction (`CLAUDE.md`, seção "Distribuição global") não têm esse problema — pare e
informe isso ao usuário se for o caso, sem prosseguir com os passos abaixo.

## Passos

1. Descubra a versão do plugin instalada: `claude plugin details btt-sdd@btt-sdd-pipeline` (mesmo
   comando validado em `plugins/btt-sdd/README.md`). Se o comando falhar ou o plugin não estiver
   instalado, pare e informe — não há o que sincronizar.
2. Leia `docs/.sdd-plugin-version` do projeto atual (raiz do projeto, não do plugin). Se não
   existir, trate como "nunca sincronizado" — toda entrada do changelog do plugin conta como
   pendente.
3. Localize o `CHANGELOG.md` do plugin instalado (mesmo caminho relativo que
   `plugins/btt-sdd/CHANGELOG.md` tem neste repositório, dentro da instalação real do plugin no
   sistema do usuário — o caminho exato depende de onde `claude plugin details` apontou no passo
   1) e liste as entradas com versão maior que a marcada no passo 2, até a versão instalada
   (inclusive).
   - Se não houver entrada nenhuma nesse intervalo, informe "docs já sincronizados, nada a fazer",
     atualize `docs/.sdd-plugin-version` para a versão instalada de qualquer forma (evita reler o
     changelog inteiro de novo na próxima checagem) e pare aqui.
4. Para cada entrada do changelog no intervalo, e para cada arquivo que ela cita: abra o arquivo
   correspondente do projeto atual (`docs/<arquivo>.md` ou `CLAUDE.md`) e o arquivo equivalente do
   scaffold instalado (mesmo caminho relativo dentro da instalação do plugin). Verifique se a
   seção/parágrafo citado pela entrada (pelo título ou pela âncora que a entrada descrever) já
   existe no arquivo do projeto:
   - Se já existir (idêntica ou visivelmente customizada pelo projeto), pule — não é pendência.
   - Se não existir, é uma seção candidata a aplicar.
5. **Apresente todas as seções candidatas ao usuário via `AskUserQuestion`** antes de tocar em
   qualquer arquivo — uma lista com o arquivo, o título da seção, e um resumo do que ela diz.
   Nunca aplique sem essa aprovação: o projeto pode ter reestruturado o documento de um jeito que
   torna a seção do template redundante ou incompatível, e só o usuário sabe disso (mesma regra de
   "Nenhuma suposição silenciosa" de `docs/QUALITY-GATES.md`).
6. Para cada seção aprovada, adicione ao arquivo do projeto **como uma adição líquida** — anexe a
   seção inteira (título + conteúdo) no ponto mais parecido com onde ela está no template (mesmo
   arquivo, posição relativa às seções vizinhas que já existem nos dois lados) sem alterar nenhuma
   linha já existente do arquivo do projeto. Nunca reescreva o arquivo inteiro a partir do
   template — isso descartaria customizações do projeto sem relação com o changelog.
7. Commite as mudanças (`docs/*.md`/`CLAUDE.md` tocados, mais `docs/.sdd-plugin-version`) numa
   branch própria (`docs/sync-docs-<versão>`, `docs/GIT-WORKFLOW.md`) e abra PR — mesmo processo de
   qualquer mudança de manutenção deste projeto. Este comando não mergeia o próprio PR (diferente
   de `/repo-issues`, que é exclusivo do repositório de origem do plugin e não é distribuído com
   ele) — o merge fica a critério do usuário, como em qualquer PR normal deste pipeline.
8. **Atualize `docs/.sdd-plugin-version` para a versão instalada** mesmo que o usuário tenha
   recusado alguma seção candidata no passo 5 — o marcador significa "esta versão já foi
   verificada", não "tudo foi aplicado". Liste as seções recusadas no resumo final para o usuário
   revisitar manualmente se mudar de ideia depois; elas não voltam a ser propostas automaticamente
   numa sincronização futura (só a partir da próxima versão do changelog em diante).

## Quando outro comando `/btt-sdd:*` te aciona automaticamente

Ver `docs/DOCS-SYNC.md`, seção "Quando `/sdd-sync-docs` roda" — outro comando do pipeline pode
rodar você primeiro, uma vez por sessão, antes de prosseguir com o que o usuário pediu. Nesse caso,
depois de terminar (passos 1-8 acima, incluindo a aprovação do usuário), volte o controle para o
comando original — não é preciso o usuário invocar `/btt-sdd:sync-docs` de novo separadamente.
