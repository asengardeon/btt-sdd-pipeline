# PRD — <Nome da Feature>

> Status: rascunho | em revisão | aprovado
> Autor: agente `product-design`
> Relacionado: (link para specs anteriores, se houver)

## 1. Visão geral

Uma a três frases: o que é a feature e por que ela existe agora.

## 2. Problema

Qual problema real do usuário/negócio isto resolve. Evite descrever a solução aqui — só o
problema.

## 3. Usuários / Personas

Quem usa isso e em que contexto.

## 4. Objetivos

- Objetivo mensurável 1
- Objetivo mensurável 2

## 5. Fora de escopo

O que explicitamente NÃO está incluído nesta feature (evita escopo implícito mal-entendido).

## 6. Histórias de usuário e critérios de aceite

### US-1: <título curto>

Como <persona>, eu quero <ação>, para que <benefício>.

**Critérios de aceite:**

```gherkin
Cenário: <nome>
  Dado <contexto>
  Quando <ação>
  Então <resultado esperado>
```

(Repita para cada história. Cada critério de aceite deve ser verificável por um terceiro sem
contexto adicional — isso vira o checklist literal do QA.)

## 7. Métricas de sucesso

Como saberemos que a feature funcionou depois de lançada.

## 8. Indicadores técnicos a observar

Não é papel do PRD decidir arquitetura, mas é papel do PRD **sinalizar** o que pode ter peso
técnico significativo, para o `architect` endereçar no TRD. Preencha cada item mesmo que a
resposta seja "nenhum" — não deixe implícito.

- **Volumetria**: ordem de grandeza de dados/tráfego esperado (registros, requisições/segundo,
  crescimento esperado). `<preencher ou "nenhum indicador relevante">`
- **Segurança**: envolve dado sensível/pessoal, autenticação, autorização, ou superfície de
  ataque nova? `<preencher ou "nenhum indicador relevante">`
- **Legal/compliance**: implica LGPD/GDPR, retenção de dados, contrato com terceiro, ou
  regulação específica do domínio? `<preencher ou "nenhum indicador relevante">`

## 9. Ordem de valor / dependências entre histórias

Visão de produto (não técnica) de que história depende de outra — o `architect` usa isso como
ponto de partida para a decomposição técnica no TRD, que pode adicionar dependências que só a
arquitetura revela.

| História | Depende de       | Motivo                          |
|-----------|---------------------|-------------------------------------|
| US-1      | nenhuma              | ponto de entrada da feature          |

## 10. Pendências de validação (VALIDAR DEPOIS)

Toda ambiguidade que o usuário não soube/quis responder agora, registrada aqui em vez de virar
suposição silenciosa. Resolvida via `/sdd-amend` quando o usuário pedir a revisão.

| ID     | Pergunta                          | Contexto                              | Status              |
|--------|--------------------------------------|-------------------------------------------|------------------------|
| PRD-1  | <pergunta que ficou sem resposta>     | <por que essa pergunta importa>            | pendente / validado |

## 11. Log de revisões

Preenchido pelo `/sdd-amend` a cada mudança neste PRD depois de aprovado — nunca recrie o
documento do zero para registrar uma mudança.

| Data | Autor | O que mudou | Motivo | Etapas revalidadas |
|------|-------|--------------|--------|-----------------------|

## 12. Aprovação

- [ ] Aprovado por: <usuário> em <data>
