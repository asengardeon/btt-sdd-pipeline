# Code Review — <Nome da Feature>

> Autor: agente `code-reviewer`
> TRD: `specs/<slug>/trd.md`
> Fatia revisada nesta rodada: `<F-1, ou "única — feature não fatiada">`
> PR desta fatia: <link do Pull Request revisado>
> Data:

Este documento é editado in-place a cada fatia (nunca recriado do zero) — ver seção "Histórico de
aprovações por fatia" abaixo para o veredito de fatias anteriores já mergeadas.

## 1. Veredito geral (fatia desta rodada)

**Aprovado / Aprovado com ressalvas / Reprovado**

### Histórico de aprovações por fatia

Uma linha por rodada de revisão (uma por fatia) — nunca sobrescreva o veredito de uma fatia já
aprovada e mergeada, acrescente uma linha nova.

| Fatia | PR      | Veredito | Data |
|-------|---------|----------|------|
| F-1   | `<link>` | `<veredito>` | `<data>` |

## 2. Ports & Adapters / regra da dependência

`domain` livre de import externo? `application` depende só de ports? Adapters sem vazar detalhe
de infraestrutura para dentro? Liste violações encontradas (arquivo/linha) ou "sem achados".

## 3. SOLID

Responsabilidade única, extensão por composição, ports pequenos e específicos, casos de uso
dependendo de abstração. Liste violações encontradas (arquivo/linha) ou "sem achados".

## 4. Clean code

Nomes, tamanho de função, código morto/comentado, duplicação, comentários desnecessários ou
faltando onde havia um *porquê* não óbvio. Liste achados (arquivo/linha) ou "sem achados".

## 5. Qualidade dos testes

Testes frágeis (acoplados a implementação, não a comportamento), testes que não falham quando
deveriam, cobertura de caso de borda relevante ausente no nível de design do teste (não é
contagem de cobertura — isso é do QA). Liste achados (arquivo/linha) ou "sem achados".

## 6. Contrato Frontend↔Backend (se full-stack)

Backend implementa exatamente o que o TRD prometeu; frontend consome exatamente isso. "Não se
aplica" se a feature é backend-only ou frontend-only.

## 7. Tratamento de erros e casos de borda

Erros esperados tratados explicitamente, exceções não silenciadas sem motivo, casos de borda
óbvios (vazio/nulo/limite) não quebram o fluxo. Liste achados (arquivo/linha) ou "sem achados".

## 8. Débito técnico introduzido

Atalhos, TODOs, simplificações deliberadas — sinalizados pelo dev ou identificados aqui. Débito
não documentado é achado bloqueante; débito documentado com justificativa é ressalva.

## 9. Achados (se reprovado ou aprovado com ressalvas)

| # | Arquivo:linha | Problema | Sugestão | Severidade |
|---|-----------------|----------|----------|------------|

## 10. Pendências de validação (VALIDAR DEPOIS)

| ID    | Pergunta                          | Contexto                              | Status              |
|-------|--------------------------------------|-------------------------------------------|------------------------|
| CR-1  | <pergunta que ficou sem resposta>     | <por que essa pergunta importa>            | pendente / validado |

## 11. Log de revisões

| Data | Autor | O que mudou | Motivo | Etapas revalidadas |
|------|-------|--------------|--------|-----------------------|

## 12. Próximo passo

`/sdd-qa` (se aprovado, para esta fatia) ou `/sdd-implement` (se reprovado, com os achados acima).
