# PRD — Gestão simples de tarefas (exemplo do pipeline SDD)

> Status: aprovado
> Autor: agente `product-design`
> Relacionado: nenhum (primeira feature do repositório)

## 1. Visão geral

Uma feature mínima de gestão de tarefas — criar, listar e concluir tarefas — usada como exemplo
de referência do pipeline SDD deste repositório, ponta a ponta.

## 2. Problema

Este repositório é um template. Sem um exemplo real de código, os agentes e os templates ficam
abstratos demais para servir de referência de "nível de detalhe esperado". Uma feature pequena,
mas completa, resolve isso.

## 3. Usuários / Personas

Desenvolvedor(a) usando o repositório via linha de comando para gerenciar uma lista de tarefas
pessoal simples.

## 4. Objetivos

- Permitir criar uma tarefa com um título.
- Permitir listar todas as tarefas e seu status (pendente/concluída).
- Permitir marcar uma tarefa como concluída.

## 5. Fora de escopo

- Persistência em disco/banco de dados real (o exemplo usa um repositório em memória).
- Edição ou remoção de tarefas.
- Autenticação/múltiplos usuários.
- Interface gráfica ou API HTTP (o exemplo expõe apenas uma CLI).

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

## 7. Métricas de sucesso

N/A — feature de exemplo, não vai a produção real. O "sucesso" aqui é servir de referência clara
para o pipeline SDD.

## 8. Suposições

- Cada tarefa tem um identificador único gerado pelo sistema (usuário não escolhe o id).
- Não há prazo/data associada à tarefa nesta versão.

## 9. Questões em aberto

Nenhuma — escopo fechado propositalmente para servir de exemplo.

## 10. Aprovação

- [x] Aprovado por: asengardeons@hotmail.com em 2026-08-24
