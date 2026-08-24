# SRE Review — <Nome da Feature>

> Autor: agente `sre`
> QA report: `specs/<slug>/qa-report.md`
> Data:

## 1. Veredito geral

**Aprovado / Aprovado com ressalvas / Reprovado**

## 2. CI

- [ ] Lint roda no pipeline
- [ ] Testes rodam no pipeline
- [ ] Gate de cobertura 80% aplicado e falha o build se violado
- [ ] Pipeline falha rápido e com mensagem clara

Evidência/observações:

## 3. CD

- [ ] Deploy só roda após CI verde
- [ ] `terraform apply` gated (plan revisável, aprovação manual quando aplicável)
- [ ] Estratégia de rollback documentada

Evidência/observações:

## 4. Docker

- [ ] Build multi-stage, imagem final mínima
- [ ] Processo roda como usuário não-root
- [ ] Sem segredo hardcoded na imagem
- [ ] Healthcheck definido (se aplicável)

Evidência/observações:

## 5. Terraform

- [ ] Estado remoto configurado
- [ ] Variáveis sensíveis marcadas `sensitive`
- [ ] `terraform plan` limpo, sem drift inesperado
- [ ] Recursos versionados/tagueados de forma consistente

Evidência/observações:

## 6. Observabilidade

- [ ] Logs/métricas mínimas definidas no TRD estão implementadas

Evidência/observações:

## 7. Pendências (se aprovado com ressalvas ou reprovado)

| # | Item | Responsável | Bloqueia release? |
|---|------|--------------|---------------------|

## 8. Próximo passo

Se aprovado: feature pronta para release. Caso contrário: itens acima devem ser resolvidos antes.
