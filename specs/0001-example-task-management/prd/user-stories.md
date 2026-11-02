<!-- sdd-format-version: 2 -->
# PRD — Gestão simples de tarefas (exemplo do pipeline SDD) — Histórias de usuário

> Seções 6-7 do PRD (`INDEX.md` tem o núcleo e a navegação para os demais arquivos).

## 6. Histórias de usuário e critérios de aceite

### US-1: Criar tarefa

Como usuário, eu quero criar uma tarefa com um título, para que ela apareça na minha lista de
pendências.

```gherkin
Cenário: Criar tarefa com título válido
  Dado que não existe nenhuma tarefa com o título "Escrever TRD"
  Quando eu crio uma tarefa com o título "Escrever TRD"
  Então a tarefa é criada com status "pendente"

Cenário: Tentar criar tarefa sem título
  Quando eu tento criar uma tarefa com título vazio
  Então a criação é rejeitada e nenhuma tarefa é persistida
```

### US-2: Listar tarefas

Como usuário, eu quero ver todas as minhas tarefas e seus status, para saber o que falta fazer.

```gherkin
Cenário: Listar quando não há tarefas
  Dado que não existe nenhuma tarefa
  Quando eu listo as tarefas
  Então recebo uma mensagem indicando que não há tarefas

Cenário: Listar tarefas existentes
  Dado que existem tarefas pendentes e concluídas
  Quando eu listo as tarefas
  Então vejo todas elas com seus respectivos status
```

### US-3: Concluir tarefa

Como usuário, eu quero marcar uma tarefa como concluída, para acompanhar meu progresso.

```gherkin
Cenário: Concluir tarefa existente
  Dado uma tarefa pendente
  Quando eu marco essa tarefa como concluída
  Então o status dela passa a ser "concluída"

Cenário: Concluir tarefa já concluída
  Dado uma tarefa já concluída
  Quando eu tento marcar essa tarefa como concluída novamente
  Então a operação é rejeitada com um erro claro

Cenário: Concluir tarefa inexistente
  Quando eu tento concluir uma tarefa com um id que não existe
  Então recebo um erro indicando que a tarefa não foi encontrada
```

## 7. Wireframes/Protótipos de tela (quando a feature tem UI)

Não aplicável — esta versão do PRD, anterior à introdução desta seção no template, não tinha
este conteúdo documentado. A feature em si também não tem UI (CLI local, ver seção 5 do PRD,
"Fora de escopo": "Interface gráfica ou API HTTP").
