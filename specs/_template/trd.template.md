# TRD — <Nome da Feature>

> Status: rascunho | em revisão | aprovado
> Autor: agente `architect`
> PRD relacionado: `specs/<slug>/prd.md`
> ADRs relacionados: (link, se houver)

## 1. Contexto

Resumo de uma frase do problema (ver PRD) e a abordagem técnica escolhida.

## 2. Visão de arquitetura

Como a feature se encaixa em ports & adapters (`docs/ARCHITECTURE.md`):

```
[adapter de entrada] → [caso de uso] → [port] ← [adapter de saída]
                              ↓
                        [domínio]
```

Descreva os componentes reais desta feature nesse diagrama.

## 3. Modelo de domínio

Entidades, value objects, invariantes e regras de negócio — sem menção a framework/infra.

## 4. Ports (contratos)

Para cada port novo/alterado:

### `<NomeDoPort>`

- Responsabilidade única: <...>
- Métodos: `<assinatura>` → <retorno/erros esperados>
- Quem implementa (adapter de saída): <...>
- Quem consome (caso de uso): <...>

## 5. Casos de uso

Mapeamento explícito de critério de aceite (PRD) → caso de uso:

| Critério de aceite (PRD) | Caso de uso                | Ports usados |
|---------------------------|-----------------------------|--------------|
| US-1 cenário X             | `<NomeDoCasoDeUso>`         | `<Port>`     |

## 6. Adapters

### Entrada

- `<AdapterDeEntrada>`: responsabilidade, como aciona o(s) caso(s) de uso.

### Saída

- `<AdapterDeSaida>`: responsabilidade, qual port implementa, dependências externas reais.

## 7. Modelo de dados / contratos externos

Schema, payloads de API, formato de eventos — o que for aplicável.

## 8. Requisitos não funcionais

- Performance: <...ou N/A>
- Segurança: <...ou N/A>
- Observabilidade (logs/métricas mínimas): <...>
- **Impacto em infraestrutura para o SRE revisar:** <fila? cache? novo serviço? escalonamento?
  ou "nenhum">
- **Indicadores técnicos herdados do PRD** (seção "Indicadores técnicos a observar" do
  `prd.md`): para cada um (volumetria, segurança, legal), a decisão tomada aqui ou a justificativa
  de por que foi adiada — nunca ignorado silenciosamente.

## 9. Plano de testes (alto nível)

- Unitário: quais componentes de domínio/aplicação, com quais dublês de port.
- Integração: quais adapters, contra o quê (ex.: banco em memória/container de teste).
- E2E: quais fluxos ponta a ponta.
- Meta de cobertura: 80% (padrão do repositório, ver `docs/TESTING.md`).

## 10. Riscos e trade-offs

Riscos técnicos identificados e a decisão tomada (com justificativa).

## 11. Controle de versão (GitHub Flow)

- Branch: `feature/<NNNN-slug>`
- PR: <link, preenchido quando existir>

## 12. Pendências de validação (VALIDAR DEPOIS)

| ID     | Pergunta                          | Contexto                              | Status              |
|--------|--------------------------------------|-------------------------------------------|------------------------|
| TRD-1  | <pergunta que ficou sem resposta>     | <por que essa pergunta importa>            | pendente / validado |

## 13. Log de revisões

| Data | Autor | O que mudou | Motivo | Etapas revalidadas |
|------|-------|--------------|--------|-----------------------|

## 14. Aprovação

- [ ] Aprovado por: <usuário> em <data>
