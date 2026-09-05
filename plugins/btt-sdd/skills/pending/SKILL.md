---
name: pending
description: Lista todos os itens "VALIDAR DEPOIS" em aberto em todas as features do pipeline SDD (PRD, TRD, QA report, security review, SRE review) e em docs/BASELINE.md, além das tarefas ainda não implementadas na tabela de decomposição de cada TRD, para o usuário revisar quando tiver tempo/resposta. Use quando o usuário perguntar o que ainda falta validar ou o que ainda falta implementar, pedir a lista de pendências, ou quiser resolver um item específico marcado como VALIDAR DEPOIS.
allowed-tools: Bash(${CLAUDE_SKILL_DIR}/scripts/sdd-pending.sh *) PowerShell(${CLAUDE_SKILL_DIR}/scripts/sdd-pending.ps1 *)
---

# /btt-sdd:pending

Não aciona nenhum agente — é um utilitário de leitura, como `/btt-sdd:status`, focado em duas
coisas: os itens marcados "VALIDAR DEPOIS" e as tarefas que a tabela de decomposição de cada TRD
(seção "Decomposição de tarefas e dependências") ainda não marca como implementadas. Diferente de
`/btt-sdd:gap-report` (que compara os casos de uso do TRD, seção 6, com o código real) — aqui a
fonte é só a coluna **Status** que os próprios agentes já mantêm in-place
(`docs/QUALITY-GATES.md`, seção "Status de tarefas"), sem inspecionar código.

## Passos

1. **Prefira o script auxiliar em vez de ler cada artefato inteiro** (economiza tokens): rode
   `${CLAUDE_SKILL_DIR}/scripts/sdd-pending.sh [slug]` (bash) ou
   `${CLAUDE_SKILL_DIR}/scripts/sdd-pending.ps1 [-Slug <slug>]` (PowerShell) — o script roda a
   partir de onde estiver instalado, mas lê `specs/`/`docs/` relativos ao diretório de trabalho
   atual, que deve ser a raiz do projeto. Ele devolve duas tabelas:
   - **Pendências VALIDAR DEPOIS**: varre `prd.md`, `trd.md`, `code-review.md`, `qa-report.md`,
     `security-review.md`, `sre-review.md` e `docs/BASELINE.md`, filtra só os itens com status
     "pendente" e devolve feature | artefato | ID | pergunta | contexto — já deduplicada (linhas
     que só repetem uma referência a uma rodada anterior sem conteúdo novo, ex. "ver rodada
     anterior", são colapsadas na ocorrência mais informativa da mesma pergunta).
   - **Tarefas ainda não implementadas**: varre a tabela de decomposição de cada `trd.md` e lista
     toda linha cujo **Status** ainda não chegou a "implementado" (ou seja, está em "pendente",
     "em andamento" ou "bloqueado") — feature | ID | tarefa | trilha | status | issue. Specs com
     `prd.md` aprovado mas sem `trd.md` ainda (nenhuma tarefa decomposta) aparecem à parte, só
     pelo nome da feature.
2. Apresente as duas tabelas retornadas diretamente ao usuário — não recalcule do zero a partir
   dos artefatos.
3. **Só leia os artefatos manualmente** (fallback abaixo) se o script falhar.
4. Se o usuário pedir para resolver um item específico de VALIDAR DEPOIS (responder a pergunta
   agora), colete a resposta e acione `/btt-sdd:amend` para registrar a resolução no artefato
   correto — não edite o artefato diretamente por fora desse fluxo, para o log de revisões ficar
   consistente. Se o item já foi confirmado por uma validação manual pós-merge contra produção
   real (`docs/POST-MERGE-VALIDATION.md`), a mesma lógica se aplica: feche via `/btt-sdd:amend`,
   nunca editando o artefato direto. Se responder exigir investigação somente-leitura (ler vários
   arquivos de código, histórico de Git) cujo conteúdo não precisa ficar retido depois de chegar à
   resposta, prefira delegar essa leitura a uma sub-tarefa isolada que devolva só a conclusão
   (`docs/QUALITY-GATES.md`, seção "Governança de decisão", bullet sobre investigação de causa
   raiz) em vez de inflar seu próprio contexto com o conteúdo lido.
5. Se o usuário pedir para avançar numa tarefa específica da tabela de "Tarefas ainda não
   implementadas", **não** é caso de `/btt-sdd:amend` (não é uma decisão já aprovada sendo
   emendada) — aponte para a skill certa conforme o Status da linha: `pendente`/`em andamento`/
   `bloqueado` sem código ainda apontam para `/btt-sdd:implement` na fatia correspondente; se o
   TRD nem existe ainda para aquela feature (linha "Specs com PRD aprovado mas sem TRD"), aponte
   para `/btt-sdd:trd` primeiro.
6. Se não houver nenhuma pendência em lugar nenhum (nem VALIDAR DEPOIS, nem tarefa não
   implementada), diga isso claramente em vez de não retornar nada.

### Fallback sem o script (comportamento anterior)

1. Para cada diretório em `specs/` (exceto `_template`), leia a seção "Pendências de validação
   (VALIDAR DEPOIS)" de `prd.md`, `trd.md`, `code-review.md`, `qa-report.md`,
   `security-review.md` e `sre-review.md` (os que existirem). Se `docs/BASELINE.md` existir, leia
   a mesma seção nele também (pendências do arqueólogo não são por feature).
2. Filtre só os itens com status "pendente" (ignore os já marcados "validado").
3. Se `args` traz um slug específico, mostre só aquela feature; senão, mostre todas as que têm
   pendência.
4. Apresente uma tabela: feature | artefato | ID | pergunta | contexto resumido.
5. Para a segunda tabela, leia a seção "Decomposição de tarefas e dependências" de cada `trd.md`
   e filtre as linhas cujo **Status** não seja "implementado", "aprovado" nem "concluído
   (mergeado)" (ou seja, "pendente", "em andamento" ou "bloqueado"). Apresente: feature | ID |
   tarefa | trilha | status | issue. Liste à parte as features que têm `prd.md` mas ainda não têm
   `trd.md`.
