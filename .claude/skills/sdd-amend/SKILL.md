---
name: sdd-amend
description: Emenda um artefato do pipeline SDD já aprovado (PRD, TRD, código/implementação, QA report ou SRE review) sem reiniciar o pipeline do zero. Use quando o usuário quiser mudar uma decisão já aprovada, resolver um item "VALIDAR DEPOIS", ou corrigir algo em uma etapa anterior sem refazer as etapas seguintes que não são afetadas.
---

# /sdd-amend

Edita um artefato **in-place**, nunca recria do zero, e propaga a mudança só para as etapas
realmente afetadas — sem exigir refazer o pipeline inteiro. É a resposta a "preciso mudar algo já
aprovado sem voltar da primeira etapa".

## Passos

1. Identifique a feature (slug) e qual artefato muda: `prd.md`, `trd.md`, a implementação em
   `src/`/`tests/`, `qa-report.md` ou `sre-review.md`. Se `args` não deixar claro, pergunte ao
   usuário (use `/sdd-pending` primeiro se a emenda é para resolver um item VALIDAR DEPOIS
   específico e o usuário não lembrar qual).

2. Edite o artefato **in-place** com a mudança pedida — nunca gere um novo arquivo nem reescreva o
   documento inteiro do zero. Se a mudança resolve um item da seção "Pendências de validação
   (VALIDAR DEPOIS)", marque o item como "validado" em vez de removê-lo (mantém o histórico de
   que aquela dúvida existiu e foi resolvida).

3. Registre a mudança na seção "Log de revisões" do artefato editado: data, autor (você, como
   agente, citando a instrução do usuário), o que mudou, motivo.

4. Determine as etapas posteriores afetadas usando a ordem fixa do pipeline
   (PRD → TRD → implementação → QA → SRE, ver `docs/SDD-WORKFLOW.md`):
   - Mudou o PRD? TRD, implementação, QA e SRE dessa feature podem precisar de revalidação —
     avalie item por item da mudança se ela realmente afeta cada etapa seguinte (uma correção de
     texto sem mudança de critério de aceite pode não afetar nada a jusante).
   - Mudou o TRD? Implementação e QA podem precisar de revalidação; SRE só se a mudança envolve
     infraestrutura.
   - Mudou a implementação? Só QA precisa de revalidação.
   - Mudou QA ou SRE? Normalmente não afeta etapas anteriores (que já estavam aprovadas) nem
     precisa reabrir nada além do próprio relatório.

5. Para cada etapa afetada, registre no "Log de revisões" do respectivo artefato downstream que
   ela **"requer revalidação"** (não apague o conteúdo existente, só sinalize) e informe ao
   usuário quais comandos (`/sdd-trd`, `/sdd-implement`, `/sdd-qa`, `/sdd-sre`) precisam ser
   rodados de novo — só esses, não o pipeline inteiro.

6. Etapas **não** afetadas continuam aprovadas como estavam — não peça reaprovação delas.

## Quando usar sem agente dedicado

Esta skill não aciona um subagente próprio — você mesmo (a sessão atual) faz a edição seguindo os
passos acima, já que é uma operação pontual sobre um artefato existente, não a geração de um
artefato novo do zero.
