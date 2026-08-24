# Pilares de engenharia de software

Referência que o `architect` usa para preencher a seção "Pilares de engenharia de software" do
TRD (`specs/_template/trd.template.md`). Cada pilar precisa de uma resposta explícita no TRD —
mesmo que seja "não se aplica, porque X" — nunca implícita. Segurança tem seu próprio agente
dedicado (`security-engineer`, ver `docs/QUALITY-GATES.md`) e não é tratada aqui; manutenibilidade
é, em grande parte, consequência de SOLID/Clean Code, já cobertos em `docs/ARCHITECTURE.md`.

## Performance

O que "rápido o suficiente" significa para esta feature (latência aceitável, throughput
esperado)? Isso normalmente vem dos "Indicadores técnicos" do PRD (volumetria). Em ports &
adapters, o lugar mais comum de gargalo é o adapter de saída (I/O de rede/disco) — o caso de uso
em si, sem I/O, raramente é o problema.

## Escalabilidade

O sistema aguenta crescer (mais dados, mais usuários, mais carga) sem redesenho? Casos de uso sem
estado (não guardam estado entre chamadas) são a base para escalar horizontalmente — o estado
fica no adapter de saída (banco, cache), que escala independentemente. Pergunte: essa feature
introduz algum estado guardado em memória do processo que impediria rodar múltiplas instâncias?

## Resiliência

O que acontece quando uma dependência externa (chamada por um adapter de saída) falha, atrasa, ou
fica indisponível? Padrões a considerar explicitamente: timeout (nunca esperar indefinidamente),
retry com backoff (para falhas transitórias), circuit breaker (para parar de bater numa
dependência que já está claramente fora do ar), fallback/degradação graciosa (o sistema continua
útil de algum jeito, ou falha de forma previsível e comunicada). Nem toda feature precisa de todos
— mas cada dependência externa nova precisa de uma resposta.

## Disponibilidade

Qual o impacto se esta feature ficar indisponível — impacto crítico, degradação aceitável, ou
irrelevante? Isso informa decisões do `sre` (réplicas, health checks, estratégia de rollback em
`docs/GIT-WORKFLOW.md`/`cd.yml`) — o TRD só precisa declarar a expectativa, não implementar a
infraestrutura.

## Observabilidade

Como alguém vai saber, em produção, que esta feature está funcionando (ou não)? Estrutura mínima
esperada: logs estruturados nas fronteiras de adapter (entrada e saída), métricas para o que for
crítico de acompanhar (contagem, latência, taxa de erro), e — quando a complexidade justificar —
tracing entre componentes. Isso vira o "requisito de observabilidade" que o TRD já pede e o
`senior-developer` implementa.

## Manutenibilidade

Coberta estruturalmente por SOLID, Clean Code e a separação ports & adapters
(`docs/ARCHITECTURE.md`) — o TRD só precisa registrar aqui um desvio deliberado desses princípios,
se houver, com justificativa (ex.: uma simplificação aceita conscientemente para o escopo atual).

## Como isso aparece no TRD

Cada pilar acima vira uma subseção da seção 8 ("Pilares de engenharia de software") do TRD,
respondida especificamente para a feature em questão — não uma cópia genérica deste documento.
