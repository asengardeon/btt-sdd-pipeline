---
name: migrate
description: Converte um artefato gerado pelo pipeline (qualquer um com template em specs/_template/) de uma versão de formato antiga para a versão atual, usando o marcador <!-- sdd-format-version: N --> e o registro de migrações em skills/migrate/migrations/. Use quando o usuário pedir para "atualizar"/"migrar"/"converter" uma spec antiga para o formato novo. Nunca roda automaticamente — sempre por pedido explícito, um artefato de uma spec por vez.
---

# /btt-sdd:migrate

Converte **um** artefato de **uma** spec existente para a versão de formato atual do template
correspondente (`docs/MICRO-CONTEXT.md`, seção 3: marcador de versão + registro de migrações).
**Nunca automático em nenhum outro comando** — só acontece quando este comando é invocado
explicitamente, uma spec e um artefato por vez (nunca um scan do projeto inteiro, nunca vários
artefatos de uma vez).

**Antes de qualquer coisa, leia `docs/SKILL-PREAMBLE.md`** — onde ficam os docs de governança
deste pipeline e de onde vêm os templates de `specs/_template/` (nenhum dos dois vive dentro do
projeto onde você está trabalhando). Resolva esse caminho a partir do "Base directory" desta
invocação: via junction global, é `docs/` na raiz do repositório do pipeline; via plugin, é
`docs/` dentro do pacote.

**Esta skill não aciona nenhum subagente** — você mesmo (a sessão atual) faz a conversão seguindo
os passos abaixo mais o arquivo de regra de migração aplicável, mesmo padrão de `/btt-sdd:amend`
e `/btt-sdd:pending`: é uma operação pontual e determinística sobre um artefato existente, não a
geração de conteúdo novo a partir de análise.

## O registro de migrações: um núcleo genérico, regras específicas por par de versões

Este arquivo **não sabe como transformar nenhum artefato específico** — só sabe onde procurar a
regra certa. Cada arquivo em
`skills/migrate/migrations/<artefato>-v<origem>-to-v<destino>.md` descreve a detecção e a
transformação de **um** par de versões de **um** artefato. Hoje existem 7 regras, todas `v1 →
v2`: 5 arquivo único → split físico por rodada (`docs/MICRO-CONTEXT.md`, seção 2) e 2 arquivo
único → split por tópico (`docs/MICRO-CONTEXT.md`, seção 2b — PRD/TRD não têm rodada, só tópico):

| Artefato | Arquivo de regra |
|---|---|
| `code-review` | `migrations/code-review-v1-to-v2.md` |
| `qa-report` | `migrations/qa-report-v1-to-v2.md` |
| `security-review` | `migrations/security-review-v1-to-v2.md` |
| `sre-review` | `migrations/sre-review-v1-to-v2.md` |
| `ux-review` | `migrations/ux-review-v1-to-v2.md` |
| `prd` | `migrations/prd-v1-to-v2.md` |
| `trd` | `migrations/trd-v1-to-v2.md` |

Artefatos sem regra registrada (`coverage-summary`, `timing-log`) nunca mudaram de formato desde
que o pipeline existe — não é um erro, é "nada para migrar". Quando um desses artefatos ganhar
uma versão nova no futuro, a extensão é **acrescentar** um arquivo de regra novo em
`migrations/`, nunca reescrever este núcleo.

## Entrada

`args`: `<slug> <artefato>`, onde `<artefato>` é o nome de qualquer template em
`specs/_template/` sem a extensão `.template.md` (ex.: `prd`, `trd`, `code-review`, `qa-report`,
`security-review`, `sre-review`, `ux-review`, `coverage-summary`, `timing-log`). Se faltar um dos
dois, pergunte ao usuário — nunca adivinhe o artefato a partir de "o que existe na spec" (pode
haver mais de um artefato defasado na mesma spec; cada migração é deliberada e uma por vez).

## Passos

1. **Confirme a branch atual (`git branch --show-current`)** antes de editar qualquer coisa —
   mesma regra de `/btt-sdd:amend`, passo 1b: nunca assuma que o workspace já está na branch
   certa.

1b. **Se a branch atual for a branch padrão do repositório** (normalmente `main` — confirme com
   `git symbolic-ref refs/remotes/origin/HEAD` se houver dúvida, ou pela convenção já declarada
   para este projeto), **nunca commite a migração ali**: `/btt-sdd:migrate` pode ser invocado sem
   fatia ativa (ex.: migrando uma spec antiga muito depois dela ter mergeado), e seguir o passo 10
   literalmente nesse estado commitaria direto na branch padrão — violando `docs/GIT-WORKFLOW.md`,
   regra 1 ("`main` sempre implantável. Ninguém commita direto nela — toda mudança entra via
   PR"), que vale para qualquer artefato de qualquer projeto consumidor, não só feature rastreada
   em `specs/` (a seção "Mudanças no próprio pipeline" daquele doc é especificamente sobre manter
   os `agents/`/`skills/`/templates do próprio pipeline, não aplica aqui — mas a regra 1 em si é
   geral). Antes de prosseguir para o passo 2:
   - Confirme/crie uma issue (do GitHub, ou do sistema de rastreamento deste projeto, se outro)
     descrevendo por que esta migração está sendo feita agora — reaproveite uma issue existente
     se o pedido já nasceu de uma; senão, crie uma antes de criar a branch, nunca depois como
     formalidade retroativa. Se o projeto não usar issues, pule esta etapa.
   - Crie uma branch a partir da branch padrão atualizada, prefixo `docs/` (é uma mudança só de
     documentação/Markdown em `specs/`, sem código) — ex. `docs/migrate-<slug>-<artefato>`.
   - Só prossiga com os passos 2+ nessa branch nova.
   Se a branch atual **já não é** a padrão (o usuário está no meio de outro trabalho — fatia,
   chore, etc.), siga como sempre: nenhuma branch nova, commite a migração na branch atual
   (passo 10).

2. **Determine a versão atual do template.** Leia a primeira linha de
   `specs/_template/<artefato>.template.md` — `<!-- sdd-format-version: N -->`. Se este artefato
   também tiver versão split, leia o marcador do `index.template.md` correspondente também: a
   versão "atual" é sempre a mais alta das duas (hoje é sempre a do split — `v2`). O split pode
   estar em dois lugares (`docs/MICRO-CONTEXT.md`, seções 2 e 2b): `specs/_template/reviews/
   <artefato>/index.template.md` (split por rodada — os 5 artefatos de revisão) ou
   `specs/_template/<artefato>/index.template.md` (split por tópico — `prd`, `trd`).

3. **Determine a versão da instância real em `specs/<slug>/`, nesta ordem**:
   - Se `specs/<slug>/reviews/<artefato>/INDEX.md` existe (split por rodada) ou
     `specs/<slug>/<artefato>/INDEX.md` existe (split por tópico — `prd`, `trd`), leia o marcador
     dele.
   - Senão, se `specs/<slug>/<artefato>.md` existe, leia seu marcador na primeira linha.
     **Se não tiver marcador** (artefato escrito antes desta convenção existir — lacuna
     transitória documentada em `docs/MICRO-CONTEXT.md`, seção 3), trate como a versão mais
     antiga conhecida daquele artefato — confirme por detecção estrutural (o shape do arquivo
     bate com o template dessa versão), nunca assuma só pela ausência do marcador.
   - Senão, `specs/<slug>/` não tem nenhuma instância deste artefato ainda — recuse, não há o
     que migrar.

4. **Se a versão da instância já é igual à versão atual do template**: informe "já está no
   formato atual, nada para migrar" e pare — não decida "mesclar" ou "atualizar" de qualquer
   jeito.

5. **Procure em `skills/migrate/migrations/` um arquivo `<artefato>-v<origem>-to-v<destino>.md`**
   cobrindo a versão encontrada no passo 3. Se não existir regra para essa versão: informe ao
   usuário que o artefato está numa versão antiga sem regra de migração registrada — **nunca
   invente uma transformação própria**; isso é uma lacuna real do registro, não um caso para
   resolver por conta própria.

6. **Se a instância estiver mais de uma versão atrás** (ex.: template já em `v3`, instância em
   `v1`), aplique os pares em sequência — `v1→v2`, depois `v2→v3` — confirmando a versão
   resultante a cada passo antes de aplicar o próximo. Hoje nenhum artefato tem mais de duas
   versões conhecidas, então este caso ainda não ocorre na prática — a lógica existe para quando
   ocorrer.

7. **Leia o arquivo de regra encontrado e siga exatamente os passos dele** — detecção fina das
   seções/tabelas de origem, quais arquivos criar, como transformar o conteúdo. O núcleo aqui não
   duplica esse detalhe.

8. **Garanta que todo arquivo criado pela migração carrega o marcador da versão de destino** —
   herdado do próprio template usado como base (`specs/_template/.../*.template.md` já inclui a
   linha correta); nunca copie o marcador do artefato de origem para o de destino.

9. **Nunca delete nem mova o arquivo do artefato original — mas esvazie o corpo dele.** O
   histórico real já está preservado pelo Git (`git log`/`git show` continuam funcionando no
   arquivo legado); manter o conteúdo inteiro duplicado nos dois formatos não serve a nenhum
   propósito além de inflar o repositório. Para todas as 7 migrações: substitua o corpo do
   arquivo pelo título original seguido só do banner "migrado" (que passa a dizer que o conteúdo
   foi **removido**, não que o arquivo é "referência histórica" — já que não sobra conteúdo nele)
   apontando para onde o conteúdo real agora vive. Texto exato do banner e do corte: arquivo de
   regra de migração aplicável.

9b. **Confirme mecanicamente que o passo 9 funcionou — nunca confie só em ter seguido os passos.**
   Rode `${CLAUDE_SKILL_DIR}/scripts/check-legacy-emptied.sh <arquivo-legado>` (bash) ou
   `${CLAUDE_SKILL_DIR}/scripts/check-legacy-emptied.ps1 -File <arquivo-legado>` (PowerShell) —
   devolve "OK" e sai com código 0 se só título + banner sobraram, ou "FALHOU" com a lista exata
   de linhas extras e código 1 se qualquer conteúdo original ainda estiver lá. **Nunca prossiga
   para o passo 10 enquanto o script reportar "FALHOU"** — corrija o arquivo (remova o que o
   script listou) e rode de novo. Esta verificação existe porque o passo 9, sendo só prosa, já
   falhou silenciosamente em produção: todas as execuções anteriores de `/btt-sdd:migrate` num
   projeto consumidor fizeram a transformação para v2 corretamente mas nenhuma esvaziou o arquivo
   legado — 75 arquivos com ~78.700 linhas de conteúdo original duplicado, só descoberto por
   auditoria manual (issue #602, `asengardeon/btt-sdd-pipeline`). Um check de código, não a
   lembrança de quem roda a migração, é o que fecha essa lacuna de raiz.

10. **Commite as mudanças** (os arquivos novos + o artefato original com o banner/marcação que a
    regra específica definir) na branch atual — a mesma branch que o usuário já estava usando se
    o passo 1b não disparou, ou a branch nova criada pelo passo 1b se disparou (nunca uma branch
    própria desta migração **fora** desse caso, a menos que o usuário peça). Mensagem de commit
    descritiva citando a spec e o artefato migrados. Nunca `git add -A`/`.` — liste os arquivos
    explicitamente. **Se o passo 1b criou uma branch nova**, abra também um PR (`gh pr create`)
    referenciando a issue do passo 1b — nunca mergeie sozinho; merge continua sendo decisão do
    usuário.

11. **Resuma ao usuário**: de qual versão para qual versão, quantas rodadas/linhas de cada
    tabela foram preservadas, e — quando a regra específica apontar perda de conteúdo de rodada
    anterior — isso explicitamente, como limitação do formato de origem, não desta migração.
    Se o passo 1b criou branch/PR, inclua o link do PR no resumo. Sugira rodar
    `/btt-sdd:status` depois, para confirmar que a spec aparece corretamente na versão nova.

## Quando recusar

- `artefato` não corresponde a nenhum `specs/_template/<artefato>.template.md` conhecido, ou
  `slug` que não corresponde a um diretório em `specs/`.
- A instância já está na versão atual do template — não decida "mesclar" ou "atualizar": pare e
  informe que já está atualizada.
- A instância existe mas está vazia/não preenchida (ainda no estado de template, sem nenhum
  veredito registrado) — não há nada para migrar; a próxima rodada real já vai nascer direto na
  versão atual.
- Não existe regra de migração registrada para o par de versões encontrado — nunca invente uma
  transformação; informe a lacuna.
