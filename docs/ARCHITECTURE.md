# Arquitetura: Ports & Adapters, SOLID, Clean Code

Este documento explica os princípios de arquitetura que todo código gerado neste repositório
deve seguir. É a referência que o `architect` usa para desenhar o TRD e que
`backend-developer`/`frontend-developer` usam para implementar.

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
  o domínio e os casos de uso não mudam uma linha. O mesmo vale para adapters que falam com
  serviços de nuvem gerenciados (S3, DynamoDB, Blob Storage etc.): em dev/teste a implementação
  aponta para [floci](https://floci.io) simulando o provedor localmente, em produção aponta para o
  provedor real — só a implementação injetada do port muda (`docs/STACK.md`, "Simulação de nuvem
  local").
- **Foco de revisão**: bugs de regra de negócio ficam isolados em `domain`/`application`; bugs de
  integração ficam isolados em `adapters`.

## Contenção de falha em mecanismos que reagem a falha (observabilidade/alerta)

Um mecanismo de "alerte quando algo der errado" (log, alerta de erro crítico, notificação de
incidente) tem uma propriedade estrutural fácil de esquecer: sua própria dependência (cache,
banco, fila, API externa) frequentemente está degradada **exatamente no mesmo incidente** que o
erro original que ele deveria reportar — banco fora do ar é causa comum tanto do erro de aplicação
quanto da falha do mecanismo de throttle/alerta que também depende do banco. Não é um edge case
raro; é o cenário correlacionado mais provável de ativar o próprio mecanismo.

Daí a necessidade de **duas camadas ortogonais de contenção**, não um `try/catch` superficial no
ponto de entrada:

1. **No ponto de entrada do mecanismo** (ex.: o handler de exceção que primeiro recebe o erro
   original) — qualquer falha do mecanismo de alerta em si nunca pode impedir o tratamento normal
   do erro original.
2. **Em cada adapter de saída que o mecanismo usa** (ex.: o throttle, o sender de e-mail) — cada
   um precisa conter sua própria falha e devolver um resultado seguro (nunca lançar), porque o
   próprio mecanismo pode ser chamado de múltiplos pontos de entrada no futuro.

A própria ação de "logar que a contenção aconteceu" (para auditoria de "por que o alerta não
disparou?") também precisa estar protegida — não é decorativo: se o logger em si falhar (ex.:
canal de log indisponível), isso também não pode escapar.

**Contra-exemplo** (sem contenção, o caminho que falha na raiz): um `CriticalErrorReporter` recebe
a exceção original e chama `NotifyCriticalError`, que consulta um throttle baseado em cache antes
de enviar o e-mail. Se o cache estiver indisponível — o cenário mais correlacionado com "há um
erro crítico real acontecendo" —, a exceção *nova* do throttle escapa do pipeline de tratamento,
mascarando a exceção *original* por completo: nem log, nem alerta saem para o erro real.

**Exemplo corrigido** (dupla camada): o handler que primeiro recebe a exceção original envolve a
chamada inteira ao mecanismo de alerta num `try/catch` que nunca propaga — na pior falha, o erro
original ainda segue o tratamento normal. Dentro do mecanismo, o adapter de throttle contém a
própria falha de cache e devolve um resultado seguro (ex.: "não suprimir", preferindo alerta
duplicado a alerta perdido) em vez de lançar; e o log de auditoria da própria contenção está
dentro do mesmo `try/catch` que não propaga.

Qualquer projeto que implemente observabilidade/alerta tem essa mesma armadilha estrutural — não é
específica de uma stack. `architect` desenha com essa dupla camada desde o TRD sempre que a tarefa
envolver um mecanismo que reage a falha; `backend-developer`/`frontend-developer` escrevem o teste
de contenção (storage indisponível, dependência externa lançando) como parte obrigatória do TDD,
não como extra — ver `.claude/agents/backend-developer.md`, regra inegociável sobre adapters de
observabilidade/alerta.

## Frontend (quando a feature inclui UI)

Quando uma feature tem frontend, `frontend/` é um diretório irmão de `src/`, com sua própria
separação de responsabilidade — não é uma imposição de ports & adapters completo (seria
over-engineering para a maioria das UIs), mas segue o mesmo espírito:

- `frontend/src/components/` — UI. Não fala com rede diretamente.
- `frontend/src/services/` — a camada que fala com a API, implementando o contrato definido no
  TRD (seção "Contrato Frontend↔Backend"). É o equivalente frontend de um adapter de saída: os
  componentes dependem de uma abstração de `service` (injetável/substituível por um dublê em
  teste), nunca de detalhe de transporte HTTP.
- `frontend/tests/` — testes de componente/serviço, espelhando `frontend/src/`.

O contrato do TRD é o que desacopla `frontend-developer` de `backend-developer`: cada um
implementa contra o contrato, não contra a implementação real do outro lado — o que permite os
dois desenvolverem em paralelo (`frontend-developer` usa um `service` dublê que respeita o
contrato até o endpoint real existir). Agnóstico de framework, como o resto deste documento —
qualquer framework de UI se encaixa nessa separação componente/serviço.

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
`specs/0001-example-task-management/code-examples.md` para um exemplo documentado desses
princípios aplicados (o código executável correspondente não existe mais neste repositório).
