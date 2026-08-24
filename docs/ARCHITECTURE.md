# Arquitetura: Ports & Adapters, SOLID, Clean Code

Este documento explica os princípios de arquitetura que todo código gerado neste repositório
deve seguir. É a referência que o `architect` usa para desenhar o TRD e que o `senior-developer`
usa para implementar.

## Ports & Adapters (arquitetura hexagonal)

A ideia central: **a lógica de negócio não sabe nem se importa** com banco de dados, frameworks
web, filas de mensagens ou qualquer detalhe de infraestrutura. Infraestrutura é um detalhe
plugável em torno do núcleo, não o contrário.

```
                         ┌─────────────────────────────┐
   adapters/inbound      │        application           │      adapters/outbound
  (dirigem a app)         │  (casos de uso + ports)      │      (dirigidos pela app)
┌──────────────┐          │  ┌────────────────────────┐  │        ┌──────────────────┐
│  HTTP / CLI /  │ ──────▶ │  │  use_cases/            │  │ ──────▶│ implementações    │
│  evento        │         │  │    depende de ports/    │  │        │ concretas de       │
└──────────────┘          │  └───────────┬────────────┘  │        │ port (DB, API,     │
                          │              │                │        │ fila, etc.)        │
                          │              ▼                │        └──────────────────┘
                          │  ┌────────────────────────┐  │
                          │  │        domain/          │  │
                          │  │  entidades, regras de    │  │
                          │  │  negócio, sem framework  │  │
                          │  └────────────────────────┘  │
                          └─────────────────────────────┘
```

**Regra da dependência**: setas sempre apontam para dentro. `domain` não conhece `application`
nem `adapters`. `application` conhece `domain` e define *ports* (interfaces) — mas nunca importa
uma implementação concreta de `adapters`. `adapters` conhece `application` (para implementar
ports ou acionar casos de uso) e pode conhecer bibliotecas externas — é aqui, e só aqui, que
framework/SQL/HTTP client aparecem.

### Mapeamento neste repositório

- `src/domain/` — entidades e regras de negócio puras. Zero import de `application` ou
  `adapters`, zero import de biblioteca de infraestrutura.
- `src/application/ports/` — interfaces que a aplicação precisa da infraestrutura (ex.:
  `TaskRepository`). Definidas pelo que o caso de uso precisa, não pelo que uma tecnologia
  específica oferece.
- `src/application/use_cases/` — orquestram domínio + ports para cumprir um critério de aceite.
  Recebem as implementações de port por injeção (construtor/parâmetro), nunca instanciam um
  adapter concreto internamente.
- `src/adapters/inbound/` — o que aciona os casos de uso: controllers HTTP, comandos de CLI,
  handlers de evento/fila.
- `src/adapters/outbound/` — o que implementa os ports: repositórios de banco de dados, clientes
  de API externa, publicadores de fila.

### Por que isso importa na prática

- **Testabilidade**: casos de uso são testados com dublês (fakes/stubs) dos ports, sem precisar
  de banco/rede real — testes unitários rápidos e determinísticos.
- **Substituibilidade**: trocar Postgres por outro banco, ou REST por gRPC, é trocar um adapter —
  o domínio e os casos de uso não mudam uma linha.
- **Foco de revisão**: bugs de regra de negócio ficam isolados em `domain`/`application`; bugs de
  integração ficam isolados em `adapters`.

## SOLID aplicado

- **Single Responsibility**: um caso de uso faz uma coisa (`CreateTask`, não
  `TaskServiceThatDoesEverything`). Um port representa uma responsabilidade (`TaskRepository`
  cuida de persistência de `Task`, não também de notificação).
- **Open/Closed**: comportamento novo entra como um novo adapter ou uma nova implementação de
  port, não como mais um `if` dentro de um caso de uso existente.
- **Liskov Substitution**: qualquer implementação de um port (ex.: `InMemoryTaskRepository` vs.
  `PostgresTaskRepository`) deve ser intercambiável sem que o caso de uso perceba diferença de
  comportamento observável.
- **Interface Segregation**: ports pequenos e específicos por caso de uso — evite uma interface
  "repositório genérico" com dezenas de métodos que a maioria dos consumidores não usa.
- **Dependency Inversion**: `application` depende de abstrações (`ports`) que ela mesma define;
  `adapters` depende de `application`, nunca o contrário.

## Clean Code — regras práticas

- Funções pequenas, um nível de abstração por função.
- Nomes que dizem o que a coisa é/faz sem precisar de comentário (`is_overdue()`, não
  `check(t)`).
- Sem duplicação: se a mesma lógica aparece duas vezes, extraia.
- Sem código morto, sem parâmetro/flag que nada usa ainda "para o futuro".
- Comentário só quando existe um *porquê* não óbvio (uma decisão contraintuitiva, um workaround
  específico, uma invariante que não é visível no código). Nunca um comentário que só repete o
  que a linha já diz.

Veja `docs/TESTING.md` para como TDD e cobertura se encaixam nessa arquitetura, e
`specs/0001-example-task-management/` para um exemplo real desses princípios aplicados.
