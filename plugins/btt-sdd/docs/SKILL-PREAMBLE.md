# Preâmbulo das skills do pipeline

Toda skill `/sdd-*` (e `/create-project`) lê este arquivo antes de começar. Ele existe porque o
que está aqui valia para todas e estava copiado dentro de cada uma — 15 cópias do primeiro bloco,
8 do segundo, mais as duas cópias da distribuição.

O equivalente para os agentes é `docs/AGENT-PREAMBLE.md`; a diferença entre os dois é só como cada
um resolve o próprio caminho de instalação.

## Onde ficam os docs de governança citados nas skills deste pipeline

Referências como `docs/GIT-WORKFLOW.md`, `docs/QUALITY-GATES.md`, `docs/gates/*.md`,
`docs/TESTING.md`, `docs/ENGINEERING-PILLARS.md`, `docs/ARCHITECTURE.md`, `docs/SDD-WORKFLOW.md`,
`docs/FILE-GUIDE.md`, `docs/POST-MERGE-VALIDATION.md` e `docs/MODEL-TIERING.md` apontam para os
docs genéricos deste pipeline — **não são copiados para dentro de cada projeto que o usa**.
Resolva-os a partir de onde a própria skill está instalada (o "Base directory" da invocação): se
for `.claude/skills/<esta-skill>/` apontando para este repositório via junction global
(`CLAUDE.md`, seção "Distribuição global"), esses docs estão em `docs/` na raiz **deste mesmo
repositório** — não necessariamente no projeto onde você está trabalhando agora. Se o projeto
atual também tiver um `docs/<nome>.md` próprio (`STACK.md`, `DESIGN-SYSTEM.md`, `BASELINE.md`,
`LESSONS-LEARNED.md`, `adr/`), esse é conteúdo do projeto, não deste pipeline — não confunda os
dois.

## E de onde vêm os templates de `specs/_template/`

Mesma regra dos docs acima: resolva `<nome>.template.md` a partir da **instalação da skill**, não
da cópia dentro do projeto — no pacote do plugin,
`skills/create-project/scaffold/specs/_template/`; via junction global, `specs/_template/` na raiz
do repositório do pipeline.

O motivo é que a cópia do projeto foi escrita no dia em que ele nasceu e **congela ali**: correção
de template aceita depois nunca chega a um projeto já existente — o inverso do desejado, já que
projeto maduro é o que mais roda fatia. Já custou caro duas vezes na mesma spec: a seção "Trabalho
conduzido pelo orquestrador" do `timing-log.template.md` foi reinventada à mão, em prosa, na fatia
seguinte à que a criou; e a coluna "`!` no título do PR" do `trd.template.md` não existia no TRD do
projeto, então a quebra de contrato teve de ser pega pelo `sre` no ato do merge — exatamente o
cenário que aquela coluna existe para eliminar.

Use o `specs/_template/<nome>.template.md` **do projeto** apenas quando ele existir **e** divergir
por decisão registrada em `docs/PROJECT-CONVENTIONS.md` — isso é override deliberado, não o caminho
padrão. Se o projeto simplesmente não tem o template (comum para os mais recentes, como
`ux-review.template.md` num projeto criado antes da etapa 4b existir), use o da instalação sem
cerimônia: não é lacuna a reportar.
