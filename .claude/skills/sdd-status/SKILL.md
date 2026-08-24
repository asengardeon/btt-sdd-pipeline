---
name: sdd-status
description: Utilitário do pipeline SDD. Use quando o usuário perguntar em que estágio está uma feature, ou quiser um panorama de todas as features em specs/. Não aciona nenhum agente — só lê o estado atual dos artefatos.
---

# /sdd-status

Não aciona nenhum agente — é um utilitário de leitura.

## Passos

1. Liste os diretórios em `specs/` (exceto `_template`).
2. Para cada um, verifique a presença de: `prd.md`, `trd.md`, `qa-report.md`, `sre-review.md`, e
   se há código/testes associados em `src/`/`tests/` referenciando a feature.
3. Se `args` traz um slug específico, mostre só aquela feature; senão, mostre todas.
4. Apresente uma tabela curta: feature | etapa atual | próximo comando a rodar. A etapa atual é a
   última etapa concluída; o próximo comando é a skill seguinte na ordem
   `sdd-prd → sdd-trd → sdd-implement → sdd-qa → sdd-sre`.
5. Se um `qa-report.md` ou `sre-review.md` existir com veredito reprovado, sinalize isso
   explicitamente em vez de tratar como etapa concluída.
