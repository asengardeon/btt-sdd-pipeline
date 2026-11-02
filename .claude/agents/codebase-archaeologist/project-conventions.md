# `docs/PROJECT-CONVENTIONS.md` — particularidades do projeto vs. padrão do pipeline

Gatilho: `/sdd-project-conventions` (sob demanda, a qualquer momento), `/create-project` (uma vez,
ao final do scaffold, para semear a identidade inicial do projeto), ou de forma oportunista
sempre que você já está rodando por causa de `/sdd-baseline` (aproveite a inspeção que já está
fazendo em vez de repeti-la depois).

Responsabilidade separada de `docs/BASELINE.md` — não confunda as duas. `BASELINE.md` descreve **o
sistema em si** (o que faz, stack, arquitetura real). `PROJECT-CONVENTIONS.md` descreve **como este
projeto específico particulariza o próprio pipeline** — não o produto, mas o processo: modelo de
workflow de Git, estrutura de pastas, nomenclatura, ou qualquer outra convenção onde este projeto
diverge do padrão genérico definido pelos docs de governança do pipeline (`docs/GIT-WORKFLOW.md`,
`docs/FILE-GUIDE.md` etc. — resolvidos a partir de onde você foi carregado, ver seção do núcleo).

**Esse arquivo é lido por todos os agentes do pipeline** (`architect`, `backend-developer`,
`frontend-developer`, `code-reviewer`, `ux-designer`, `qa-engineer`, `security-engineer`, `sre`),
como restrição que se sobrepõe ao padrão genérico. Escreva pensando nisso: cada entrada precisa ser
acionável por um agente que não participou da conversa em que a convenção foi decidida — o que muda,
para qual etapa, e (quando houver) o porquê em uma linha. Uma entrada vaga ("o time prefere um
processo mais leve") não dá para aplicar; uma entrada concreta ("teste de mutação não roda por
fatia — no máximo uma vez ao final da spec, e só quando pedido") dá.

## Processo

1. Leia os docs de governança genéricos do pipeline (git workflow, estrutura de arquivos) a partir
   de onde você foi carregado — nunca do projeto atual, que não os tem copiados.
2. Observe o estado real deste projeto: `git log --oneline --all` e nomes de branch já usados
   (convenção de prefixo realmente seguida vs. a documentada), estrutura de pastas real (`Glob`
   raso na raiz e em `src/`/`frontend/`/`docs/`, quando existirem), e qualquer outra convenção
   visível (nomenclatura de commits, organização de testes) que destoe do padrão genérico.
3. Registre **só as divergências** — nunca repita o que já é o padrão do pipeline sem alteração.
   Se o projeto segue o padrão genérico em tudo (comum logo após `/create-project`, antes de
   qualquer branch real existir), não crie o arquivo — relate "nenhuma particularidade a registrar
   ainda" e pare. Isso é um resultado válido, não uma falha.
4. Toda divergência cuja intenção não é óbvia (proposital vs. acidental) vira `AskUserQuestion`,
   com "VALIDAR DEPOIS" como opção — mesmo limite de 3 tentativas do restante do pipeline.
5. Se houver algo a registrar, escreva/atualize `docs/PROJECT-CONVENTIONS.md` com seções mínimas:
   **Git workflow** (o que diverge do `docs/GIT-WORKFLOW.md` genérico), **Estrutura do projeto** (o
   que diverge do `docs/FILE-GUIDE.md` genérico), **Cadência de CI** (só se divergir do padrão —
   ex.: `ci-antes-do-merge`, a suíte completa rodando só quando o PR sai do draft, imediatamente
   antes do merge, em vez de a cada push; `.claude/agents/sre/ci-cadencia-e-custo.md` tem a
   receita e o trade-off),
   **Outras particularidades** (nomenclatura, testes etc., só se houver), **Pendências de validação
   (VALIDAR DEPOIS)** e **Log de revisões**. Se o arquivo já existe, edite in-place e registre a
   mudança no log — nunca recrie do zero.
