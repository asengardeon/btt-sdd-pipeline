<!-- sdd-format-version: 2 -->
# TRD — <Nome da Feature> — Arquitetura

> Seções 3-5, 7, 9 do TRD (`INDEX.md` tem o núcleo e a navegação para os demais arquivos).

## 3. Visão de arquitetura

Como a feature se encaixa em ports & adapters (`docs/ARCHITECTURE.md`):

```
[adapter de entrada] → [caso de uso] → [port] ← [adapter de saída]
                              ↓
                        [domínio]
```

Descreva os componentes reais desta feature nesse diagrama. Se a feature inclui frontend, indique
também onde ele entra (consumindo o adapter de entrada via o contrato de `contract.md`, seção 8).

## 3b. Mínima mudança arquitetural (condicional)

Só no modo `mínima mudança` (`architect/minima-mudanca.md`); em outro modo, apague esta seção.

| Peça nova | Componente existente mais próximo que ela imita | Por que o existente não basta |
|---|---|---|
| <peça> | <componente> | <motivo> |

**Impacto no legado e nos produtos atuais**

| Repositório/módulo | Tocado | Não tocado | Risco de regressão |
|---|---|---|---|

Consumidores do que está sendo alterado: <conhecidos e desconhecidos, cada um `[medido]` ou
`[não medido]`>.

## 4. Modelo de domínio

Entidades, value objects, invariantes e regras de negócio — sem menção a framework/infra.

## 5. Ports (contratos)

Para cada port novo/alterado:

### `<NomeDoPort>`

- Responsabilidade única: <...>
- Métodos: `<assinatura>` → <retorno/erros esperados>
- Quem implementa (adapter de saída): <...>
- Quem consome (caso de uso): <...>

## 7. Adapters

### Entrada

- `<AdapterDeEntrada>`: responsabilidade, como aciona o(s) caso(s) de uso. Implementado pelo
  `backend-developer`.

### Saída

- `<AdapterDeSaida>`: responsabilidade, qual port implementa, dependências externas reais.
  Implementado pelo `backend-developer`.

## 9. Modelo de dados / contratos externos

Schema, payloads de API, formato de eventos — o que for aplicável (além do contrato de
`contract.md`, seção 8, se houver).
