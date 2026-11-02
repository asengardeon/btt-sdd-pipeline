<!-- sdd-format-version: 2 -->
# TRD — <Nome da Feature> — Decomposição de tarefas

> Seção 13 do TRD (`INDEX.md` tem o núcleo e a navegação para os demais arquivos). A tabela mais
> lida de toda a spec — `/sdd-implement`, `/sdd-status` e `/sdd-pending` leem este arquivo
> diretamente, sem precisar do resto do TRD.

## 13. Decomposição de tarefas e dependências (fatias verticais de entrega)

Ponto de partida: a seção "Ordem de valor / dependências entre histórias (fatias verticais de
entrega)" do PRD (`prd/value-order.md` ou `prd.md`, seção 10, conforme o formato da spec). Aqui a
decomposição é técnica, por tarefa, incluindo dependências que só a arquitetura revela — mas
**agrupe as tarefas por fatia de forma que, ao final de cada fatia, o resultado continue
demonstrável de ponta a ponta** (quando full-stack: backend e frontend da mesma fatia concluídos
juntos, nunca "todo o backend primeiro, todo o frontend depois"). É isso que permite entregar e
mostrar a spec completa aos poucos, em vez de só no fim.

**Tarefa de investigação vem primeiro.** Se alguma decisão desta spec depende da forma concreta de um
contrato com um sistema externo que ninguém observou (seletor de DOM de terceiro, formato de resposta
de API não documentada, layout de arquivo de parceiro, esquema de webhook, nome de campo de SSO), a
tarefa que captura essa estrutura real é a **primeira** tarefa da primeira fatia que depende dela —
antes de qualquer tarefa que escreva código de produção contra ela, e com Issue GitHub própria como
qualquer outra. Ela entrega um artefato em `specs/<slug>/` com a estrutura capturada (snapshot
ARIA/DOM, payload real, amostra do arquivo) e uma seção "correções obrigatórias ao desenho do TRD";
este TRD é emendado antes de a fatia prosseguir. O motivo é que o dublê escrito a partir de uma
estrutura suposta **valida a suposição, não a realidade**: a suíte fica verde e nenhuma etapa de
revisão posterior consegue distinguir isso de uma suíte verde contra a realidade.

**...exceto quando ela mede a plataforma contra o artefato desta própria fatia.** Uma investigação
que mede a plataforma **isoladamente** ("que código HTTP o serviço devolve para endereço revogado")
roda antes do código e pode ter "Depende de" = `nenhuma`. Uma que mede o comportamento da
plataforma **contra artefato produzido por outras tarefas desta fatia** ("o navegador oferece
instalar com *este* manifest e *este* service worker?") não pode precedê-lo: a coluna "Depende de"
lista as tarefas cujo artefato a medição exige, o texto da tarefa diz que ela roda **ao fim** da
fatia, e o plano de testes (`test-plan.md`, seção 11) não afirma que as investigações rodam antes
do código sem qualificar quais. Teste de um passo: *a medição é possível com o repositório como
está hoje?*

| ID   | Tarefa                    | Trilha                    | Fatia (PRD) | Depende de | Validação na fatia | Status | Issue GitHub |
|------|------------------------------|------------------------------|--------------|---------------|--------------------|-----------|------------------|
| T-1  | <descrição da tarefa>         | backend / frontend / ambos    | F-1           | nenhuma        | — / segurança / ux / sre | pendente  | `<#N ou "não espelhada">` |

A coluna **Validação na fatia** decide se uma das três etapas de fim de spec (4b UX, 6 segurança,
7 SRE) é **antecipada** para a fatia desta tarefa, em vez de rodar sobre o diff acumulado no fim da
spec (`docs/SDD-WORKFLOW.md`, seção "Cadência: o que roda por fatia e o que roda ao final da
spec"). `—` é o caso normal. **Em branco não é opção**, e a marcação não é julgamento quando a
tarefa toca:

| Marque | Quando a tarefa toca |
|--------|------------------------|
| `segurança` | autenticação, autorização, gestão de sessão, dado pessoal/sensível, ou ponto de entrada que aceita identificador externo |
| `sre` | `ci.yml`/`cd.yml`, `Dockerfile`/compose, `infra/terraform`, segredo ou variável de ambiente de deploy, ou campo que passa a ser obrigatório numa rota ativa já consumida por cliente implantado |
| `ux` | fluxo ou tela **nova** exposta ao usuário final (ajuste dentro de fluxo que a 4b já revisou não qualifica) |

Fora desses casos a antecipação é julgamento do `architect` — permitida, com o motivo em uma linha
na descrição da tarefa — ou pedido explícito do usuário. Valores combinam quando mais de uma se
aplica (ex.: `segurança, sre`).

### Janelas de quebra de contrato entre fatias

Preencher só se alguma fatia acima introduz uma mudança de contrato obrigatória (campo novo
obrigatório numa API, mensagem/evento incompatível, remoção de suporte a formato antigo) que só
fica coerente depois que outra fatia posterior (ex.: a que atualiza o cliente/frontend) também
mergear — nunca deixar essa janela implícita. Se nenhuma fatia introduz esse tipo de janela,
escreva "não aplicável".

| Fatia que quebra | O que quebra | Só fica coerente depois de | Mitigação decidida | `!` no título do PR |
|--------------------|-----------------|--------------------------------|------------------------|------------------|
| F-1                  | <ex.: campo `tenantSlug` passa a ser obrigatório em `POST /auth/login`> | F-3 (seletor de tenant na UI) | <ex.: campo aceito como opcional com fallback até F-3 mergear / segurar merge de F-1 até F-3 estar pronta / janela aceita conscientemente, com justificativa> | sim / não |

A última coluna é acionável, não informativa: em repositório com release automatizado por
Conventional Commits, o `!` antes dos dois-pontos no título do PR (`feat(0005)!: ...`) é o **único**
sinal de quebra que sobrevive ao squash merge — o subject do commit de squash é o título do PR. Sem
ele, uma mudança que rejeita tudo que o usuário tinha em mãos é publicada como MINOR, e o número de
versão é o único aviso que chega a quem só baixa o artefato da página de Releases. Marque "sim"
sempre que a fatia carregar a quebra, mesmo que a mitigação escolhida reduza o impacto; "não" só
quando a fatia não é a portadora da quebra.

A coluna **Status** é a fonte de verdade de onde cada tarefa está, mantida **in-place** por quem
causa cada transição — nunca inferida depois por outra etapa. `architect` inicializa toda tarefa
nova como `pendente`. Ciclo de vida completo e responsabilidade de cada transição em
`docs/gates/status-de-tarefas.md`: `pendente` → `em andamento` → `implementado`
→ `aprovado` → `concluído (mergeado)`, com `bloqueado` como estado de exceção (uma revisão
reprovou; volta a `em andamento` quando a correção começa).

**Toda tarefa desta tabela precisa de uma Issue GitHub associada antes do TRD ser considerado
pronto para aprovação — obrigatório, não mais uma preferência.** O `architect` verifica remote
GitHub configurado e autenticado ao preencher esta tabela: se houver, cria as issues via `gh issue
create` (informando o usuário, sem perguntar se ele quer); se não houver, o TRD não pode ser
finalizado até o usuário configurar `git remote` + `gh auth login` — diferente do PRD, que não
exige GitHub, a decomposição de tarefas exige. Nenhuma fatia desta spec pode ser iniciada por
`/sdd-implement` sem que todas as suas tarefas tenham a coluna "Issue GitHub" preenchida.

Toda issue de tarefa criada aqui é identificável contra a spec e o tipo de trabalho que
representa:
- **Milestone**: um milestone por spec, nomeado com o `<slug>` da feature (ex.:
  `0012-excluir-eventos-cancelados`) — cria o milestone no repositório do projeto se ainda não
  existir (`gh api repos/<owner>/<repo>/milestones -f title="<slug>" -f state="open"`, verificando
  antes com `gh api repos/<owner>/<repo>/milestones --jq '.[].title'` para não duplicar) e associa
  toda issue de tarefa desta spec a ele (`gh issue create --milestone "<slug>" ...`). Agrupa todas
  as tarefas da mesma spec com acompanhamento nativo de % concluído no GitHub.
- **Label de tipo**: `enhancement` para a imensa maioria das tarefas (implementação nova, o caso
  padrão de uma tarefa de TRD), `bug` só se a tarefa for uma correção de defeito já existente, e
  `documentation` se a tarefa for só de documentação — todos labels padrão do GitHub, presentes na
  maioria dos repositórios; confirme que existem (`gh label list --repo <owner>/<repo> --json
  name`) e crie se faltar antes de usar.
- **Label de trilha**: `backend`, `frontend` ou `ambos`, espelhando a coluna **Trilha** da tabela
  acima — crie o label no repositório do projeto se ainda não existir (`gh label create`, mesma
  mecânica acima).

Ciclo de vida de cada issue criada: o PR da fatia que cobre a tarefa referencia `Closes #N`
(`backend-developer`/`frontend-developer`, ao abrir o PR); `sre`, ao aprovar a fatia, comenta na
issue documentando o que foi implementado (link do PR e dos artefatos de revisão); a issue fecha
sozinha quando o usuário mergear o PR — nunca fechada manualmente antes disso. Sempre que a coluna
Status de uma tarefa muda, o mesmo agente/skill responsável por essa transição comenta a mudança
na issue associada (`gh issue comment`), para o TRD e o GitHub nunca divergirem.
