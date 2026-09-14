# Log de tempo de execução — <slug>

Registro append-only do tempo que cada invocação de agente levou nesta spec — preenchido pelo
**orquestrador** de cada skill (`/sdd-prd`, `/sdd-trd`, `/sdd-implement`, `/sdd-code-review`,
`/sdd-qa`, `/sdd-security`, `/sdd-sre`), nunca pelos agentes em si (eles não têm visibilidade do
próprio horário de início/fim do ponto de vista de quem os invocou). Uma linha por invocação —
nunca sobrescreva uma linha já registrada, mesmo numa retomada/correção.

Consumido pela retrospectiva de fatia do `sre` (`.claude/agents/sre.md`, seção "Retrospectiva da
fatia") para identificar etapas anormalmente lentas ou padrões de custo de tempo entre fatias.

| Início (UTC)          | Etapa           | Agente               | Fatia | Duração |
|------------------------|-----------------|-----------------------|-------|---------|
| <AAAA-MM-DDThh:mm:ssZ> | <PRD/TRD/Implementação/Code review/QA/Segurança/SRE> | <nome do agente> | <F-N ou —> | <XmYs> |
