# Log de tempo de execução — <slug>

Registro append-only do tempo que cada invocação de agente levou nesta spec — preenchido pelo
**orquestrador** de cada skill (`/sdd-prd`, `/sdd-trd`, `/sdd-implement`, `/sdd-code-review`,
`/sdd-qa`, `/sdd-security`, `/sdd-sre`), nunca pelos agentes em si (eles não têm visibilidade do
próprio horário de início/fim do ponto de vista de quem os invocou). Uma linha por invocação —
nunca sobrescreva uma linha já registrada, mesmo numa retomada/correção.

Consumido pela retrospectiva de fatia do `sre` (`.claude/agents/sre.md`, seção "Retrospectiva da
fatia") para identificar etapas anormalmente lentas ou padrões de custo de tempo entre fatias.

## O que a coluna "Duração" mede

**Tempo de trabalho do(s) agente(s) da invocação — não wall-clock bruto do início ao fim.** A
diferença aparece sempre que a invocação inclui uma pausa que não é trabalho de agente nenhum, e o
caso mais comum é a **espera por aprovação humana**: um agente que devolve o plano da Fase 1 e fica
parado até o usuário responder (`/sdd-implement`, passo 5b) pode acumular horas de wall-clock sem
nenhum trabalho acontecendo. Nesse caso, registre a **soma das durações reais das invocações de
subagente envolvidas** (o `duration_ms` que cada notificação de conclusão de subagente já reporta),
e acrescente uma nota parentética explícita dizendo o que ficou de fora:

```
| 2026-09-22T03:47:59Z | Implementação | backend-developer | F-3 | 27m58s (tempo de trabalho do agente, exclui a espera de aprovação do usuário entre Fase 1 e Fase 2 — gap real de wall-clock foi maior) |
```

Sem essa distinção, a linha registra o tempo de resposta do usuário como se fosse custo do
pipeline, e a retrospectiva que lê este arquivo conclui que a etapa foi anormalmente lenta quando
não foi. A nota parentética não é opcional quando a exclusão acontece: quem ler o log depois
precisa entender a diferença sem adivinhar. Já aconteceu de verdade: um gap de aprovação de mais de
10h teria virado uma linha "Implementação | 10h+" se a instrução tivesse sido seguida como
wall-clock puro.

O inverso também vale: **nunca "limpe" um número medido**. Se a duração foi de fato dominada por
trabalho lento (ou por uma espera que o próprio agente escolheu fazer), registre o valor medido e
explique a causa na nota — inventar um número arredondado corrompe a série histórica tanto quanto
deixar o outlier sem explicação.

| Início (UTC)          | Etapa           | Agente               | Fatia | Duração |
|------------------------|-----------------|-----------------------|-------|---------|
| <AAAA-MM-DDThh:mm:ssZ> | <PRD/TRD/Implementação/Code review/QA/Segurança/SRE> | <nome do agente> | <F-N ou —> | <XmYs> |
