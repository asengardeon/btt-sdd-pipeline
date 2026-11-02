# Exceções ao reportar/regravar `coverage/<fatia>-backend.md`

Gatilho: passo 5 da Fase 2 — commit adicional depois de reportar a trilha como pronta, ou tarefa
sem código de produção.

## Exceção: commit adicional só de documentação

Se depois de reportar a trilha como pronta você ainda precisar commitar de novo nessa branch
(ex.: corrigindo um achado de code review), rode a suíte completa de novo ao final e regrave esse
arquivo com o novo commit — nunca deixe um resumo apontando para um commit antigo.

**Exceção: se o commit adicional é só documentação** (ex.: um ajuste de texto em
`docs/`/`specs/`, sem tocar código-fonte nem teste), não é preciso rodar a suíte de novo **nem
tocar no artefato**: como o campo `Commit` é o último commit que tocou código, ele não se move
num commit docs-only — continua correto sozinho (isso evita forçar `code-reviewer`/`qa-engineer`
a reexecutar a suíte inteira só por um metadado desatualizado, sem incerteza real sobre o código
— já causou reverificação redundante em duas fatias seguidas de uma sessão real).

## Exceção irmã: tarefa que não produziu código de produção

Se a própria tarefa não produziu código de produção (tarefa de investigação/spike medida contra
código descartável, tarefa de ferramental, tarefa docs-only), a suíte completa continua
**obrigatória** — provar que nada quebrou não depende de ter havido linha nova a cobrir —, mas o
registro vai para o **artefato da própria tarefa** (uma seção "Estado da suíte ao final desta
tarefa", com o mesmo commit SHA e a mesma reconciliação nominal de falhas do passo 5a), e
`coverage/<fatia>-backend.md` **não ganha rodada nova** nem é criado por causa dela.

Dois motivos, ambos mecânicos: o campo `Commit` é o último commit que tocou código e uma tarefa
sem código de produção não o move — o artefato existente continua correto sozinho, e uma rodada
declarando "0 linhas novas" induz revisor a reexecutar a suíte por um metadado que não se moveu;
e a tabela de histórico desse arquivo é disputada com a trilha que roda em paralelo, então
escrever ali uma rodada que não mede código novo é conflito mecânico de merge de graça — o mesmo
que a coluna Status do TRD já causou.

O registro não fica invisível: `qa-engineer` e `security-engineer` já varrem os artefatos de
tarefa de investigação da spec. Neste mesmo momento, comente a transição para `implementado` na
Issue GitHub associada, se houver — **mas não edite a coluna Status do TRD para `implementado`
aqui**: duas trilhas terminando em paralelo e editando a mesma tabela na última task já causou um
conflito mecânico real de merge nessa coluna. Quem promove a tabela para `implementado` é o
orquestrador de `/sdd-implement`, numa única passada, depois de confirmar as duas trilhas
integradas (passo 5 dessa skill).
