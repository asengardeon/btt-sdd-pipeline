---
name: sdd-pending
description: Lista todos os itens "VALIDAR DEPOIS" em aberto em todas as features do pipeline SDD (PRD, TRD, QA report, security review, SRE review) e em docs/BASELINE.md, para o usuário revisar quando tiver tempo/resposta. Use quando o usuário perguntar o que ainda falta validar, pedir a lista de pendências, ou quiser resolver um item específico marcado como VALIDAR DEPOIS.
---

# /sdd-pending

Não aciona nenhum agente — é um utilitário de leitura, como `/sdd-status`, mas focado só nos
itens marcados "VALIDAR DEPOIS".

## Passos

1. Para cada diretório em `specs/` (exceto `_template`), leia a seção "Pendências de validação
   (VALIDAR DEPOIS)" de `prd.md`, `trd.md`, `qa-report.md`, `security-review.md` e
   `sre-review.md` (os que existirem). Se `docs/BASELINE.md` existir, leia a mesma seção nele
   também (pendências do arqueólogo não são por feature).
2. Filtre só os itens com status "pendente" (ignore os já marcados "validado").
3. Se `args` traz um slug específico, mostre só aquela feature; senão, mostre todas as que têm
   pendência.
4. Apresente uma tabela: feature | artefato | ID | pergunta | contexto resumido.
5. Se o usuário pedir para resolver um item específico (responder a pergunta agora), colete a
   resposta e acione `/sdd-amend` para registrar a resolução no artefato correto — não edite o
   artefato diretamente por fora desse fluxo, para o log de revisões ficar consistente.
6. Se não houver nenhuma pendência em lugar nenhum, diga isso claramente em vez de não retornar
   nada.
