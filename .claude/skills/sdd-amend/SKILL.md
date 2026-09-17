---
name: sdd-amend
description: Emenda um artefato do pipeline SDD já aprovado (PRD, TRD, código/implementação, code review, QA report, security review ou SRE review) sem reiniciar o pipeline do zero. Use quando o usuário quiser mudar uma decisão já aprovada, resolver um item "VALIDAR DEPOIS", ou corrigir algo em uma etapa anterior sem refazer as etapas seguintes que não são afetadas.
---

# /sdd-amend

Edita um artefato **in-place**, nunca recria do zero, e propaga a mudança só para as etapas
realmente afetadas — sem exigir refazer o pipeline inteiro. É a resposta a "preciso mudar algo já
aprovado sem voltar da primeira etapa".

## Onde ficam os docs de governança citados nesta skill

Referências como `docs/GIT-WORKFLOW.md`, `docs/QUALITY-GATES.md`, `docs/TESTING.md`,
`docs/ENGINEERING-PILLARS.md`, `docs/ARCHITECTURE.md`, `docs/SDD-WORKFLOW.md`,
`docs/FILE-GUIDE.md` e `docs/POST-MERGE-VALIDATION.md` nesta skill apontam para os docs genéricos
deste pipeline — **não são copiados para dentro de cada projeto que o usa**. Resolva-os a partir
de onde esta própria skill está instalada (o "Base directory" desta invocação): se for
`.claude/skills/<esta-skill>/` apontando para este repositório via junction global (`CLAUDE.md`,
seção "Distribuição global"), esses docs estão em `docs/` na raiz **deste mesmo repositório** —
não necessariamente no projeto onde você está trabalhando agora. Se o projeto atual também tiver
um `docs/<nome>.md` próprio (`STACK.md`, `BASELINE.md`, `LESSONS-LEARNED.md`, `adr/`), esse é
conteúdo do projeto, não deste pipeline — não confunda os dois.

## Passos

1. Identifique a feature (slug) e qual artefato muda: `prd.md`, `trd.md`, a implementação em
   `src/`/`tests/`, `code-review.md`, `qa-report.md`, `security-review.md` ou `sre-review.md`. Se
   `args` não deixar claro, pergunte ao usuário (use `/sdd-pending` primeiro se a emenda é para
   resolver um item VALIDAR DEPOIS específico e o usuário não lembrar qual).

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
   usuário quais comandos (`/sdd-trd`, `/sdd-implement`, `/sdd-code-review`, `/sdd-qa`,
   `/sdd-security`, `/sdd-sre`) precisam ser rodados de novo — só esses, não o pipeline inteiro.

5b. **Ao fechar uma flag "requer revalidação"** (depois de rodar de novo o comando indicado no
   passo 5 e a etapa ter sido revalidada de verdade): a entrada de log que registra o fechamento
   **nunca deve recitar a frase-gatilho entre aspas** (ex.: nunca escreva algo como "fechando a
   pendência 'TRD requer revalidação'") — `/sdd-status`/`/sdd-pending` detectam a flag por texto
   livre (`grep`/regex procurando "requer revalida" em qualquer linha de log com data), então uma
   entrada de fechamento que cita a frase original é lida como uma **nova** ocorrência não
   resolvida, mais recente que a última aprovação formal — a flag nunca se resolve sozinha. Em vez
   disso: descreva a resolução sem repetir esse texto (ex.: "TRD revisado e reconfirmado contra a
   mudança do PRD") **e** garanta que o artefato-alvo (TRD ou PRD, seção "Aprovação") tem uma linha
   formal `(Re)aprovado por... em <AAAA-MM-DD>` com data posterior à da flag original — é essa
   linha, não a entrada de log, que `/sdd-status` usa para confirmar que a flag foi mesmo resolvida.

6. Etapas **não** afetadas continuam aprovadas como estavam — não peça reaprovação delas.

## Quando usar sem agente dedicado

Esta skill não aciona um subagente próprio — você mesmo (a sessão atual) faz a edição seguindo os
passos acima, já que é uma operação pontual sobre um artefato existente, não a geração de um
artefato novo do zero.
