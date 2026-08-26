---
name: amend
description: Emenda um artefato do pipeline SDD já aprovado (PRD, TRD, código/implementação, code review, QA report, security review ou SRE review) sem reiniciar o pipeline do zero. Use quando o usuário quiser mudar uma decisão já aprovada, resolver um item "VALIDAR DEPOIS", ou corrigir algo em uma etapa anterior sem refazer as etapas seguintes que não são afetadas.
---

# /btt-sdd:amend

Edita um artefato **in-place**, nunca recria do zero, e propaga a mudança só para as etapas
realmente afetadas — sem exigir refazer o pipeline inteiro. É a resposta a "preciso mudar algo já
aprovado sem voltar da primeira etapa".

## Passos

1. Identifique a feature (slug) e qual artefato muda: `prd.md`, `trd.md`, a implementação em
   `src/`/`tests/`, `code-review.md`, `qa-report.md`, `security-review.md` ou `sre-review.md`. Se
   `args` não deixar claro, pergunte ao usuário (use `/btt-sdd:pending` primeiro se a emenda é
   para resolver um item VALIDAR DEPOIS específico e o usuário não lembrar qual).

2. Edite o artefato **in-place** com a mudança pedida — nunca gere um novo arquivo nem reescreva o
   documento inteiro do zero. Se a mudança resolve um item da seção "Pendências de validação
   (VALIDAR DEPOIS)", marque o item como "validado" em vez de removê-lo (mantém o histórico de
   que aquela dúvida existiu e foi resolvida).

3. Registre a mudança na seção "Log de revisões" do artefato editado: data, autor (você, como
   agente, citando a instrução do usuário), o que mudou, motivo.

4. Determine as etapas posteriores afetadas usando a ordem fixa do pipeline
   (PRD → TRD → implementação → revisão de código → QA → segurança → SRE, ver
   `docs/SDD-WORKFLOW.md`):
   - Mudou o PRD? TRD, implementação, revisão de código, QA, segurança e SRE dessa feature podem
     precisar de revalidação — avalie item por item da mudança se ela realmente afeta cada etapa
     seguinte (uma correção de texto sem mudança de critério de aceite pode não afetar nada a
     jusante).
   - Mudou o TRD? Implementação, revisão de código, QA e segurança podem precisar de revalidação;
     SRE só se a mudança envolve infraestrutura.
   - Mudou a implementação? Revisão de código, QA e segurança precisam de revalidação.
   - Mudou a revisão de código? Normalmente só QA precisa reconferir se a correção não introduziu
     regressão.
   - Mudou QA, segurança ou SRE? Normalmente não afeta etapas anteriores (que já estavam
     aprovadas) nem precisa reabrir nada além do próprio relatório.

5. Para cada etapa afetada, registre no "Log de revisões" do respectivo artefato downstream que
   ela **"requer revalidação"** (não apague o conteúdo existente, só sinalize) e informe ao
   usuário quais comandos (`/btt-sdd:trd`, `/btt-sdd:implement`, `/btt-sdd:code-review`,
   `/btt-sdd:qa`, `/btt-sdd:security`, `/btt-sdd:sre`) precisam ser rodados de novo —
   só esses, não o pipeline inteiro.

6. Etapas **não** afetadas continuam aprovadas como estavam — não peça reaprovação delas.

## Quando usar sem agente dedicado

Esta skill não aciona um subagente próprio — você mesmo (a sessão atual) faz a edição seguindo os
passos acima, já que é uma operação pontual sobre um artefato existente, não a geração de um
artefato novo do zero.
