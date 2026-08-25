---
name: sdd-status
description: Utilitário do pipeline SDD. Use quando o usuário perguntar em que estágio está uma feature, ou quiser um panorama de todas as features em specs/. Não aciona nenhum agente — só lê o estado atual dos artefatos.
---

# /btt-sdd:sdd-status

Não aciona nenhum agente — é um utilitário de leitura.

## Passos

1. Liste os diretórios em `specs/` (exceto `_template`).
2. Para cada um, verifique a presença de: `prd.md`, `trd.md`, `code-review.md`, `qa-report.md`,
   `security-review.md`, `sre-review.md`, e se há código/testes associados em `src/`/`tests/`
   referenciando a feature.
3. Se `args` traz um slug específico, mostre só aquela feature; senão, mostre todas.
4. Apresente uma tabela curta: feature | etapa atual | próximo comando a rodar | pendências
   VALIDAR DEPOIS | etapas "requer revalidação". A etapa atual é a última etapa concluída; o
   próximo comando é a skill seguinte na ordem
   `sdd-prd → sdd-trd → sdd-implement → sdd-code-review → sdd-qa → sdd-security → sdd-sre`.
5. Conte, por feature, quantos itens com status "pendente" existem nas seções "Pendências de
   validação (VALIDAR DEPOIS)" de cada artefato (mesma leitura que `/btt-sdd:sdd-pending` faz, aqui só
   como contagem resumida — para o detalhe, aponte o usuário para `/btt-sdd:sdd-pending`).
6. Verifique se algum artefato tem uma entrada no "Log de revisões" marcando uma etapa posterior
   como "requer revalidação" (produzido por `/btt-sdd:sdd-amend`) e sinalize isso — não trate como etapa
   concluída até a revalidação acontecer.
7. Se um `code-review.md`, `qa-report.md`, `security-review.md` ou `sre-review.md` existir com
   veredito reprovado, sinalize isso explicitamente em vez de tratar como etapa concluída.
