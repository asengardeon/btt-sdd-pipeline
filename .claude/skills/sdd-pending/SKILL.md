---
name: sdd-pending
description: Lista todos os itens "VALIDAR DEPOIS" em aberto em todas as features do pipeline SDD (PRD, TRD, QA report, security review, SRE review) e em docs/BASELINE.md, para o usuário revisar quando tiver tempo/resposta. Use quando o usuário perguntar o que ainda falta validar, pedir a lista de pendências, ou quiser resolver um item específico marcado como VALIDAR DEPOIS.
allowed-tools: Bash(${CLAUDE_SKILL_DIR}/scripts/sdd-pending.sh *) PowerShell(${CLAUDE_SKILL_DIR}/scripts/sdd-pending.ps1 *)
---

# /sdd-pending

Não aciona nenhum agente — é um utilitário de leitura, como `/sdd-status`, mas focado só nos
itens marcados "VALIDAR DEPOIS".

## Passos

1. **Prefira o script auxiliar em vez de ler cada artefato inteiro** (economiza tokens): rode
   `${CLAUDE_SKILL_DIR}/scripts/sdd-pending.sh [slug]` (bash) ou
   `${CLAUDE_SKILL_DIR}/scripts/sdd-pending.ps1 [-Slug <slug>]` (PowerShell) — o script roda a
   partir de onde estiver instalado, mas lê `specs/`/`docs/` relativos ao diretório de trabalho
   atual, que deve ser a raiz do projeto. Ele já varre `prd.md`, `trd.md`, `code-review.md`,
   `qa-report.md`, `security-review.md`, `sre-review.md` e `docs/BASELINE.md`, filtra só os itens
   com status "pendente" e devolve uma tabela: feature | artefato | ID | pergunta | contexto — já
   deduplicada (linhas que só repetem uma referência a uma rodada anterior sem conteúdo novo, ex.
   "ver rodada anterior", são colapsadas na ocorrência mais informativa da mesma pergunta).
2. Apresente a tabela retornada diretamente ao usuário.
3. **Só leia os artefatos manualmente** (fallback abaixo) se o script falhar.
4. Se o usuário pedir para resolver um item específico (responder a pergunta agora), colete a
   resposta e acione `/sdd-amend` para registrar a resolução no artefato correto — não edite o
   artefato diretamente por fora desse fluxo, para o log de revisões ficar consistente. Se o item
   já foi confirmado por uma validação manual pós-merge contra produção real
   (`docs/POST-MERGE-VALIDATION.md`), a mesma lógica se aplica: feche via `/sdd-amend`, nunca
   editando o artefato direto. Se responder exigir investigação somente-leitura (ler vários
   arquivos de código, histórico de Git) cujo conteúdo não precisa ficar retido depois de chegar à
   resposta, prefira delegar essa leitura a uma sub-tarefa isolada que devolva só a conclusão
   (`docs/QUALITY-GATES.md`, seção "Governança de decisão", bullet sobre investigação de causa
   raiz) em vez de inflar seu próprio contexto com o conteúdo lido.
5. Se não houver nenhuma pendência em lugar nenhum, diga isso claramente em vez de não retornar
   nada.

### Fallback sem o script (comportamento anterior)

1. Para cada diretório em `specs/` (exceto `_template`), leia a seção "Pendências de validação
   (VALIDAR DEPOIS)" de `prd.md`, `trd.md`, `code-review.md`, `qa-report.md`,
   `security-review.md` e `sre-review.md` (os que existirem). Se `docs/BASELINE.md` existir, leia
   a mesma seção nele também (pendências do arqueólogo não são por feature).
2. Filtre só os itens com status "pendente" (ignore os já marcados "validado").
3. Se `args` traz um slug específico, mostre só aquela feature; senão, mostre todas as que têm
   pendência.
4. Apresente uma tabela: feature | artefato | ID | pergunta | contexto resumido.
