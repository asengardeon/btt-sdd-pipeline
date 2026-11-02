# Code Review — <Nome da Feature> — <F-N ou hotfix-<data>>

> PR desta fatia: <link do Pull Request revisado>
> Data: <data>

Um arquivo por rodada — nunca edite o arquivo de uma rodada já aprovada e mergeada; crie um novo
para a próxima rodada (`docs/MICRO-CONTEXT.md`, seção 2). Acrescente a linha correspondente em
`INDEX.md` ao criar este arquivo.

## Veredito geral desta rodada

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

## 9. Build/empacotamento real (se a fatia tem trilha de frontend ou gera artefato próprio)

Resultado do comando de build/empacotamento real de produção (`docs/STACK.md`), reaproveitado de
`specs/<slug>/coverage/<fatia>-<trilha>.md` ou reexecutado nesta rodada — `docs/TESTING.md`, seção
"Build/empacotamento real como parte da suíte completa". "Não aplicável" se a fatia é backend-only
sem etapa de empacotamento própria além dos testes.

## Outros achados (áreas 1, 9-16 de `.claude/agents/code-reviewer.md`)

Qualquer achado das demais áreas de revisão (binding de DI reaproveitado, propagação de campo
novo, limitação arquitetural, quebra de contrato, condição de corrida, etc.) entra aqui, ou direto
na tabela de Achados de `tracking.md` — "sem achados" explícito se nenhuma dessas áreas acusou
nada nesta rodada.
