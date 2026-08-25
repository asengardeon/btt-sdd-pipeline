# Code Review — <Nome da Feature>

> Autor: agente `code-reviewer`
> TRD: `specs/<slug>/trd.md`
> PR: <link do Pull Request revisado>
> Data:

## 1. Veredito geral

**Aprovado / Aprovado com ressalvas / Reprovado**

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

`/sdd-qa` (se aprovado) ou `/sdd-implement` (se reprovado, com os achados acima).
