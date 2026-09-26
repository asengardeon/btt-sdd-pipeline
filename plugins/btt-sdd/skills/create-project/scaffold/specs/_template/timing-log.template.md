# Log de tempo de execução — <slug>

Registro append-only do tempo que cada etapa desta spec levou — invocação de agente **e** trabalho
conduzido pelo próprio orquestrador (ver "Trabalho conduzido pelo orquestrador" abaixo) —, preenchido pelo
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

## Trabalho conduzido pelo orquestrador (sem agente)

**`orquestrador (sem agente)` é um valor legítimo da coluna `Agente`** — não uma convenção
improvisada na hora. Registre uma linha assim sempre que o trabalho da etapa foi conduzido por quem
orquestra, sem invocar agente nenhum:

- **Tarefa de investigação executada sem agente** — ex.: navegar um sistema externo ao vivo para
  capturar a estrutura real (DOM, payload, layout de arquivo) que o TRD supôs.
- **Rodadas de `AskUserQuestion`** que custaram tempo real de relógio entre duas invocações —
  coleta de decisões de produto ou técnicas, não a espera passiva por uma aprovação (essa é o caso
  da seção acima).
- **Intermediação de plano/pergunta de subagente isolado** — apresentar ao usuário o que o agente
  não conseguiu perguntar e retomá-lo (`/btt-sdd:implement`, passos 4c e 5b; `/btt-sdd:sre`, passo 4b).

```
| 2026-09-25T14:02:11Z | Implementação | orquestrador (sem agente) | F-1 | 14m09s (investigação ao vivo do DOM real — tarefa T-1; derrubou o seletor desenhado no TRD) |
```

**Por que isso não é burocracia:** a retrospectiva de fatia lê este arquivo para achar etapas
anormalmente lentas. Sem essas linhas, ela lê uma série que **subestima** sistematicamente as
etapas conduzidas pelo orquestrador e **superestima** as conduzidas por agente. Já aconteceu de uma
etapa de PRD com 13m30s de agente ter ~23 min de trabalho de orquestrador invisível no log — duas
rodadas de `AskUserQuestion` com 7 decisões de produto e uma investigação que **reescreveu a
motivação da spec**, ou seja, a atividade de maior valor da etapa, sem linha nenhuma.

| Início (UTC)          | Etapa           | Agente               | Fatia | Duração |
|------------------------|-----------------|-----------------------|-------|---------|
| <AAAA-MM-DDThh:mm:ssZ> | <PRD/TRD/Implementação/Code review/QA/Segurança/SRE> | <nome do agente, ou `orquestrador (sem agente)`> | <F-N ou —> | <XmYs> |
