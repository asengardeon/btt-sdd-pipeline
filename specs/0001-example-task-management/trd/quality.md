<!-- sdd-format-version: 2 -->
# TRD — Gestão simples de tarefas (exemplo do pipeline SDD) — Qualidade (pilares de engenharia, riscos e trade-offs)

> Seções 10 e 12 do TRD (`INDEX.md` tem o núcleo e a navegação para os demais arquivos).

## 10. Pilares de engenharia de software

- **Performance**: não se aplica — dataset trivial, em memória, latência irrelevante para o
  propósito de exemplo/demonstração.
- **Escalabilidade**: não se aplica — a feature não introduz estado compartilhado entre
  instâncias; `InMemoryTaskRepository` é deliberadamente per-processo (fora de escopo:
  persistência real, ver PRD).
- **Resiliência**: não se aplica — nenhuma dependência externa (sem rede, sem chamada a serviço
  de terceiro), logo não há timeout/retry/circuit breaker a definir.
- **Disponibilidade**: irrelevante — é uma CLI de execução curta e local, não um serviço de longa
  duração; não há SLA/uptime a definir.
- **Observabilidade** (logs/métricas mínimas): a saída da própria CLI (`_format_task`) já serve
  como log mínimo suficiente para este exemplo; não há necessidade de logging estruturado ou
  métricas para uma CLI local de demonstração.
- **Manutenibilidade**: nenhum desvio de SOLID/Clean Code (`docs/ARCHITECTURE.md`) — a
  implementação segue ports & adapters estritamente, como o restante do repositório.
- **Impacto em infraestrutura para o SRE revisar:** nenhum além do Dockerfile/CI padrão do
  template — não há serviço de longa duração nem recurso de nuvem específico exigido por esta
  feature.
- **Indicadores técnicos herdados do PRD**: volumetria trivial, sem indicador de segurança e sem
  indicador legal (ver seção 9 do PRD, `prd/INDEX.md`) — nenhum dos três exige decisão técnica
  adicional além do que já está desenhado (repositório em memória, sem rede, sem dado pessoal). O
  indicador de segurança é aprofundado em
  `specs/0001-example-task-management/security-review.md`.

## 12. Riscos e trade-offs

- Repositório em memória não persiste entre execuções da CLI — aceito, é o escopo explícito do
  PRD (fora de escopo: persistência real).
