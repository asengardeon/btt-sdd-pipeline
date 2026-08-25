# TRD — <Nome da Feature>

> Status: rascunho | em revisão | aprovado
> Autor: agente `architect`
> PRD relacionado: `specs/<slug>/prd.md`
> ADRs relacionados: (link, se houver)

## 1. Contexto

Resumo de uma frase do problema (ver PRD) e a abordagem técnica escolhida.

## 2. Stack Tecnológica

Decidida **antes** de qualquer coisa abaixo que dependa dela (nunca implícita dentro de
Ports/Adapters/Modelo de dados). Ver processo de decisão em `.claude/agents/architect.md`.

- **Linguagem/runtime**: <...>
- **Framework principal**: <... ou "nenhum">
- **Persistência**: <... ou "nenhuma">
- **Gerenciador de pacotes**: <...>
- **Proveniência desta decisão**: `<reaproveitada de docs/STACK.md deste projeto / reaproveitada
  do harness global ~/.claude/stack-defaults.md, confirmada com o usuário / decidida nesta sessão
  com o usuário>`

Se esta é a primeira vez que a stack foi decidida neste projeto, `docs/STACK.md` foi
criado/atualizado com o mesmo conteúdo — próximas features reaproveitam a partir de lá.

## 3. Visão de arquitetura

Como a feature se encaixa em ports & adapters (`docs/ARCHITECTURE.md`):

```
[adapter de entrada] → [caso de uso] → [port] ← [adapter de saída]
                              ↓
                        [domínio]
```

Descreva os componentes reais desta feature nesse diagrama. Se a feature inclui frontend, indique
também onde ele entra (consumindo o adapter de entrada via o contrato da seção 8).

## 4. Modelo de domínio

Entidades, value objects, invariantes e regras de negócio — sem menção a framework/infra.

## 5. Ports (contratos)

Para cada port novo/alterado:

### `<NomeDoPort>`

- Responsabilidade única: <...>
- Métodos: `<assinatura>` → <retorno/erros esperados>
- Quem implementa (adapter de saída): <...>
- Quem consome (caso de uso): <...>

## 6. Casos de uso

Mapeamento explícito de critério de aceite (PRD) → caso de uso:

| Critério de aceite (PRD) | Caso de uso                | Ports usados |
|---------------------------|-----------------------------|--------------|
| US-1 cenário X             | `<NomeDoCasoDeUso>`         | `<Port>`     |

## 7. Adapters

### Entrada

- `<AdapterDeEntrada>`: responsabilidade, como aciona o(s) caso(s) de uso. Implementado pelo
  `backend-developer`.

### Saída

- `<AdapterDeSaida>`: responsabilidade, qual port implementa, dependências externas reais.
  Implementado pelo `backend-developer`.

## 8. Contrato Frontend↔Backend (API)

Preencher só se a feature inclui frontend. Isso é o que permite `backend-developer` e
`frontend-developer` desenvolverem em paralelo sem esperar um pelo outro — cada um implementa
contra este contrato, não contra a implementação real do outro lado.

- **Aplicável?** `<sim / não aplicável, porque é uma feature só de backend ou só de frontend>`
- **Endpoints/mensagens**: `<método + rota, ou nome do evento/mensagem>`
- **Request**: `<schema do payload de entrada>`
- **Response**: `<schema do payload de saída, incluindo casos de sucesso>`
- **Formato de erro padrão**: `<estrutura de erro, códigos usados>`
- **Autenticação/autorização**: `<mecanismo, se houver, ou "nenhuma">`
- **ADR relacionado**: `<link, se este contrato estabelece uma convenção reutilizável por todo o
  app — senão "nenhum, decisão local desta feature">`

## 9. Modelo de dados / contratos externos

Schema, payloads de API, formato de eventos — o que for aplicável (além do contrato da seção 8,
se houver).

## 10. Pilares de engenharia de software

Cada pilar exige resposta explícita — "não se aplica, porque X" é uma resposta válida; em branco
não é. Detalhe conceitual de cada pilar em `docs/ENGINEERING-PILLARS.md`.

- **Performance**: <latência/throughput esperado, ou "não se aplica, porque..."`>
- **Escalabilidade**: <a feature introduz estado em memória do processo? aguenta múltiplas
  instâncias? ou "não se aplica, porque..."`>
- **Resiliência**: <para cada dependência externa nova: timeout/retry/circuit breaker/fallback
  definidos, ou "não se aplica, porque..."`>
- **Disponibilidade**: <impacto se esta feature ficar indisponível — crítico/degradação
  aceitável/irrelevante — e por quê`>
- **Observabilidade** (logs/métricas mínimas): <o que precisa ser logado/medido nas fronteiras de
  adapter para diagnosticar problema em produção`>
- **Manutenibilidade**: <desvio deliberado de SOLID/Clean Code (`docs/ARCHITECTURE.md`), se
  houver, com justificativa; senão "nenhum desvio"`>
- **Impacto em infraestrutura para o SRE revisar:** <fila? cache? novo serviço? escalonamento?
  ou "nenhum">
- **Indicadores técnicos herdados do PRD** (seção "Indicadores técnicos a observar" do
  `prd.md`): para cada um (volumetria, segurança, legal), a decisão tomada aqui ou a justificativa
  de por que foi adiada — nunca ignorado silenciosamente. O indicador de segurança é aprofundado
  depois pelo agente `security-engineer` (`/sdd-security`); aqui só a decisão de design de alto
  nível que o afeta (ex.: precisa de autenticação? qual dado é sensível?).

## 11. Plano de testes (alto nível)

- Unitário: quais componentes de domínio/aplicação, com quais dublês de port.
- Integração: quais adapters, contra o quê (ex.: banco em memória/container de teste).
- E2E: quais fluxos ponta a ponta.
- Frontend (se aplicável): componentes/serviços testados com dublê do contrato da seção 8.
- Meta de cobertura: 80% por pacote (`src/` e, se aplicável, `frontend/` — ver `docs/TESTING.md`).

## 12. Riscos e trade-offs

Riscos técnicos identificados e a decisão tomada (com justificativa).

## 13. Decomposição de tarefas e dependências

Ponto de partida: a seção "Ordem de valor / dependências entre histórias" do PRD (visão de
produto). Aqui a decomposição é técnica, por tarefa, incluindo dependências que só a arquitetura
revela.

| ID   | Tarefa                    | Trilha                    | Depende de | Issue GitHub |
|------|------------------------------|------------------------------|---------------|------------------|
| T-1  | <descrição da tarefa>         | backend / frontend / ambos    | nenhuma        | `<#N ou "não espelhada">` |

Se houver remote GitHub configurado e autenticado, o `architect` pergunta ao usuário (depois do
TRD aprovado) se quer espelhar esta tabela como GitHub Issues — nunca cria issues sem confirmação
explícita.

## 14. Controle de versão (GitHub Flow)

- Branch: `feature/<NNNN-slug>` — única para a feature inteira, mesmo quando full-stack.
- PR: <link, preenchido quando existir>
- Se full-stack: `backend-developer` trabalha em `src/`+`tests/`, `frontend-developer` em
  `frontend/`, ambos na mesma branch — árvores de diretório separadas evitam conflito de merge.

## 15. Pendências de validação (VALIDAR DEPOIS)

| ID     | Pergunta                          | Contexto                              | Status              |
|--------|--------------------------------------|-------------------------------------------|------------------------|
| TRD-1  | <pergunta que ficou sem resposta>     | <por que essa pergunta importa>            | pendente / validado |

## 16. Log de revisões

| Data | Autor | O que mudou | Motivo | Etapas revalidadas |
|------|-------|--------------|--------|-----------------------|

## 17. Aprovação

- [ ] Aprovado por: <usuário> em <data>
