# Preâmbulo dos agentes do pipeline

Todo agente deste pipeline (`architect`, `backend-developer`, `code-reviewer`, `qa-engineer`,
`security-engineer`, `sre`, `ux-designer`, `product-design`, `codebase-archaeologist`,
`frontend-developer`, `tech-writer`) lê este arquivo antes de começar. Ele existe porque o que
está aqui valia para todos e estava copiado dentro de cada um — e a cópia já divergiu sozinha
pelo menos uma vez (`docs/FILE-GUIDE.md`, sobre este arquivo).

Nada aqui substitui os gates: cada agente declara no próprio arquivo os 2-4 arquivos de
`docs/gates/` que valem para a etapa dele.

## Onde ficam os docs de governança citados nos arquivos deste pipeline

Referências como `docs/GIT-WORKFLOW.md`, `docs/QUALITY-GATES.md`, `docs/gates/*.md`,
`docs/TESTING.md`, `docs/ENGINEERING-PILLARS.md`, `docs/ARCHITECTURE.md`, `docs/SDD-WORKFLOW.md`,
`docs/FILE-GUIDE.md` e `docs/POST-MERGE-VALIDATION.md` apontam para os docs genéricos deste
pipeline — **não são copiados para dentro de cada projeto que o usa**. Eles vivem junto da
distribuição do próprio pipeline: se você foi carregado via junction global
(`.claude/agents/<seu-nome>.md` apontando para este repositório, `CLAUDE.md`, seção "Distribuição
global"), esses docs estão em `docs/` na raiz **deste mesmo repositório** — não necessariamente no
projeto onde você está trabalhando agora. Se o projeto atual também tiver um `docs/<nome>.md`
próprio (`STACK.md`, `DESIGN-SYSTEM.md`, `BASELINE.md`, `LESSONS-LEARNED.md`, `adr/`), esse é
conteúdo do projeto, não deste pipeline — não confunda os dois. Se não conseguir determinar de
onde você foi carregado, pergunte a quem te invocou.

## `docs/PROJECT-CONVENTIONS.md`: leia antes de começar, se existir

É o canal pelo qual cada projeto registra como particulariza este pipeline — modelo de workflow de
Git, estrutura de pastas, nomenclatura, gate de cobertura próprio, etapas que aquele projeto não
roda. Trate cada entrada relevante à sua etapa como **restrição que se sobrepõe ao padrão
genérico** do pipeline, exatamente como você já trata `docs/LESSONS-LEARNED.md`. Onde uma convenção
do projeto conflita com uma instrução genérica sua, a convenção do projeto vence — e você registra
isso no seu artefato citando o arquivo ("fora do escopo por `docs/PROJECT-CONVENTIONS.md`"), nunca
"por instrução do usuário nesta rodada": a segunda forma é a marca de uma regra que chegou por
prompt, que não é auditável e não sobrevive à invocação seguinte. Ausência do arquivo é normal e
não é um problema — significa que o projeto segue o padrão genérico. Limite: uma convenção de
projeto **não** desliga um gate crítico de `docs/gates/governanca.md` (ex.: dispensar revisão de
segurança, baixar cobertura mínima sem decisão registrada); se parecer que é o caso, pergunte em
vez de aplicar.

**Ao citar um artefato de investigação como base de uma ressalva, verifique a marcação
`[medido]`/`[inferido]` da frase que você está usando** (`agents/architect.md`, item 1c). Uma
ressalva apoiada em `[inferido]` declara isso — e, quando a medição for barata e o ambiente
estiver à mão, propor medi-la sai mais barato que carregar a ressalva por três fatias.
