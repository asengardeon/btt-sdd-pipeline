---
name: migrate-reviews
description: Converte retroativamente um artefato de revisão de uma spec existente (code-review.md, qa-report.md, security-review.md, sre-review.md ou ux-review.md) do formato legado de arquivo único para o split físico por rodada (docs/MICRO-CONTEXT.md, seção 2). Use quando o usuário pedir para "atualizar"/"migrar"/"converter" uma spec antiga para o formato novo. Nunca roda automaticamente — sempre por pedido explícito, um artefato de uma spec por vez.
---

# /btt-sdd:migrate-reviews

Converte **um** artefato de revisão de **uma** spec do formato legado (`specs/<slug>/<stage>.md`,
arquivo único editado in-place a cada fatia) para o split físico por rodada
(`specs/<slug>/reviews/<stage>/{INDEX.md,tracking.md,F-<N>.md,...}`, `docs/MICRO-CONTEXT.md`,
seção 2). A migração **não é automática em nenhum outro comando** — só acontece quando este
comando é invocado explicitamente, uma spec e um artefato por vez (nunca um scan do projeto
inteiro, nunca os 5 artefatos de uma fatia de uma vez).

**Antes de qualquer coisa, leia `docs/SKILL-PREAMBLE.md`** — onde ficam os docs de governança
deste pipeline e de onde vêm os templates de `specs/_template/` (nenhum dos dois vive dentro do
projeto onde você está trabalhando). Resolva esse caminho a partir do "Base directory" desta
invocação: via junction global, é `docs/` na raiz do repositório do pipeline; via plugin, é
`docs/` dentro do pacote.

**Esta skill não aciona nenhum subagente** — você mesmo (a sessão atual) faz a conversão seguindo
os passos abaixo, mesmo padrão de `/btt-sdd:amend` e `/btt-sdd:pending`: é uma operação pontual e
determinística sobre um artefato existente, não a geração de conteúdo novo a partir de análise.

## Entrada

`args`: `<slug> <stage>`, onde `stage` é um de `code-review`, `qa-report`, `security-review`,
`sre-review`, `ux-review`. Se faltar um dos dois, pergunte ao usuário — nunca adivinhe o stage a
partir de "o que existe na spec" (pode haver mais de um artefato legado na mesma spec; cada
migração é deliberada e uma por vez).

## O que é preservado e o que não é

**Preservado por completo** (as três tabelas do formato legado já eram append-only, exatamente
como `tracking.md` exige):
- A tabela "Histórico de aprovações por fatia" inteira — toda linha, de toda rodada já registrada.
- A tabela de achados/pendências de conteúdo técnico (nome e colunas variam por stage — tabela de
  referência abaixo).
- A tabela "Pendências de validação (VALIDAR DEPOIS)".
- A tabela "Log de revisões".

**Não recuperável, por limitação do próprio formato legado — não desta migração**: o conteúdo
detalhado de cada área revisada (seções 2 em diante do template legado) era **sobrescrito a cada
rodada** no formato antigo — só a rodada mais recente sobrevive no arquivo no momento da migração.
Rodadas anteriores só têm a linha na tabela de histórico; o texto da revisão daquela rodada já não
existia mais antes da migração começar. Isso não é perda introduzida pela conversão — é a
constatação de uma limitação que já existia. Deixe isso explícito ao usuário no resumo final
(passo 7), e marque `Arquivo = —` nas linhas do histórico anteriores à rodada vigente (só ela
ganha um `F-<N>.md` real).

## Tabela de referência por stage

| Stage | Colunas do Histórico | Seção do Histórico | Nome/seção da tabela técnica | Colunas da tabela técnica | Seção VALIDAR DEPOIS | Seção Log | Seção Próximo passo | Áreas da rodada (passam para `round.template.md`) |
|---|---|---|---|---|---|---|---|---|
| `code-review` | Fatia, PR, Veredito, Profundidade, Data | dentro da seção 1 | 10. Achados | #, Fatia, Arquivo:linha, Problema, Sugestão, Severidade, Status | 11 | 12 | 13 | 2–9 |
| `qa-report` | Fatia, PR, Veredito, Data | dentro da seção 1 | 6. Achados | #, Fatia, Arquivo/cenário, Esperado, Observado, Severidade, Status | 7 | 8 | 9 | 2–5 |
| `security-review` | Fatia, PR, Veredito, Profundidade, Commit, Data | dentro da seção 1 | 8. Achados | #, Fatia, Área, Esperado, Observado, Severidade, Status | 9 | 10 | 11 | 2–7 |
| `sre-review` | Fatia, PR, Veredito, Profundidade, Commit, Data | dentro da seção 1 | 7. Pendências | #, Fatia, Item, Responsável, Bloqueia release?, Status | 8 | 9 | 10 | 2–6 |
| `ux-review` | Fatia, PR, Veredito, Método, Data | dentro da seção 1 | 9. Achados | #, Arquivo/componente, Esperado, Observado, Severidade (**sem** Fatia/Status no legado) | 10 | 11 | 12 | 2–8 |

Os números de seção acima são os do **template padrão** (`specs/_template/<stage>.template.md`).
Uma spec real pode variar o nível de cabeçalho (`#`/`##`) ou ter seções renumeradas por edições
manuais — identifique cada tabela/seção **pelo título exato** (ex.: "Histórico de aprovações por
fatia", "Pendências de validação (VALIDAR DEPOIS)", "Log de revisões"), nunca só pelo número,
mesma lógica de robustez que `sdd-status.sh`/`sdd-pending.sh` já aplicam.

## Passos

1. **Confirme a branch atual (`git branch --show-current`)** antes de editar qualquer coisa —
   mesma regra de `/btt-sdd:amend`, passo 1b: nunca assuma que o workspace já está na branch certa.

2. **Pré-condições, nesta ordem — pare e informe o usuário se qualquer uma falhar**:
   - `specs/<slug>/<stage>.md` existe. Se não existir, não há o que migrar.
   - `specs/<slug>/reviews/<stage>/` **não** existe (nem `INDEX.md` dentro dele). Se já existir,
     esta spec/artefato já foi migrado — recuse-se a migrar de novo (evita sobrescrever
     silenciosamente um `INDEX.md`/`tracking.md` que já acumulou rodadas reais desde a migração).
   - O arquivo legado tem conteúdo preenchido de verdade (pelo menos um veredito registrado na
     tabela de Histórico) — um arquivo ainda no estado de template vazio não precisa de migração,
     só precisa nascer direto no formato novo na próxima vez que o agente da etapa escrever nele.

3. **Leia o arquivo legado por completo.** Usando a tabela de referência acima para este `stage`,
   identifique (pelo título, não pela posição) as quatro tabelas e o bloco de conteúdo da rodada
   vigente:
   - A tabela "Histórico de aprovações por fatia" — a **última linha** é a rodada vigente; seu
     valor de `Fatia` (`F-<N>` ou `hotfix-<data>`) nomeia o arquivo que você vai criar no passo 5.
   - A tabela técnica (achados ou pendências, conforme o stage).
   - A tabela "Pendências de validação (VALIDAR DEPOIS)".
   - A tabela "Log de revisões".
   - O conteúdo das áreas da rodada vigente (intervalo de seções da tabela de referência) — é só
     o que está escrito **agora** no arquivo; não existe conteúdo de rodada anterior para
     recuperar (ver "O que é preservado e o que não é" acima).

4. **Crie `specs/<slug>/reviews/<stage>/INDEX.md`** a partir de
   `specs/_template/reviews/<stage>/index.template.md`:
   - Copie a tabela de Histórico **linha por linha, na mesma ordem**, sem alterar nenhum valor
     existente.
   - Acrescente a coluna `Arquivo`: `F-<N>.md` (ou `hotfix-<data>.md`) na última linha (a rodada
     vigente); `—` em toda linha anterior.
   - Preencha "Próximo passo" com o mesmo texto que o arquivo legado já tinha na própria seção
     "Próximo passo" (reaproveite a decisão já registrada, não decida de novo).

5. **Crie `specs/<slug>/reviews/<stage>/tracking.md`** a partir de
   `specs/_template/reviews/<stage>/tracking.template.md`:
   - Copie a tabela técnica (achados/pendências) **linha por linha**, sem alterar valores. Se o
     stage é `ux-review` e a tabela legada não tem as colunas `Fatia`/`Status` (ela não acumula
     entre rodadas no formato antigo — só mostra a rodada vigente), preencha `Fatia` com o
     identificador da rodada vigente (mesmo valor do passo 4) e `Status = aberto` em cada linha
     migrada — vira o ponto de partida do acumulado a partir de agora.
   - Copie a tabela "Pendências de validação (VALIDAR DEPOIS)" **linha por linha**, sem alterar
     valores (inclusive linhas já `validado`).
   - Copie a tabela "Log de revisões" **linha por linha**, sem alterar valores.

6. **Crie `specs/<slug>/reviews/<stage>/<identificador-da-rodada-vigente>.md`** (`F-<N>.md` ou
   `hotfix-<data>.md`, o mesmo nome usado no passo 4) a partir de
   `specs/_template/reviews/<stage>/round.template.md`:
   - Veredito geral desta rodada: copie o valor da última linha da tabela de Histórico.
   - Áreas da rodada (intervalo da tabela de referência): copie o conteúdo de cada seção
     correspondente do arquivo legado, sem reescrever ou resumir — é a prosa que já existia,
     só movida de arquivo.
   - **Não crie `F-<N>.md` para rodadas anteriores à vigente** — não existe conteúdo de área para
     elas (ver "O que é preservado e o que não é").

7. **Adicione um banner no topo do arquivo legado** (não o delete, não o mova) — logo abaixo do
   título, antes de qualquer outro conteúdo:

   ```
   > **Migrado para o formato novo em <AAAA-MM-DD>.** Ver `specs/<slug>/reviews/<stage>/`.
   > Este arquivo é mantido como referência histórica (rodadas anteriores à migração, cujo
   > conteúdo de área não foi recuperável — ver `docs/MICRO-CONTEXT.md`, seção 2) — não edite;
   > toda rodada nova usa o formato novo.
   ```

   Nunca apague o restante do conteúdo do arquivo legado — ele continua sendo a única fonte do
   texto de rodadas anteriores à vigente (perdido para fins de split, mas não para leitura manual
   de arquivo único, se alguém precisar).

8. **Commite as mudanças** (os 3 arquivos novos + o arquivo legado com o banner) na branch atual
   — mesma branch que o usuário já estava usando, nunca uma branch nova própria desta migração a
   menos que o usuário peça. Mensagem de commit descritiva citando a spec e o stage migrados.
   Nunca `git add -A`/`.` — liste os arquivos explicitamente.

9. **Resuma ao usuário**: quantas rodadas tinha o histórico, quantos achados/pendências/linhas de
   log foram preservados, e — explicitamente — que o conteúdo de área das rodadas anteriores à
   vigente não foi recuperado (limitação do formato legado, não desta migração). Sugira rodar
   `/btt-sdd:status` depois, para confirmar que a spec aparece corretamente no formato novo.

## Quando recusar

- `stage` fora dos 5 valores válidos, ou `slug` que não corresponde a um diretório em `specs/`.
- O artefato já está no formato novo (`reviews/<stage>/INDEX.md` existe) — não decida "mesclar" ou
  "atualizar": pare e informe que já foi migrado.
- O arquivo legado existe mas está vazio/não preenchido — não há nada para migrar; informe que a
  próxima rodada real já vai nascer direto no formato novo.
