# SRE Review — <Nome da Feature> — <F-N ou hotfix-<data>>

> PR desta fatia: <link do Pull Request>
> Data: <data>

Um arquivo por rodada — nunca edite o arquivo de uma rodada já aprovada e mergeada; crie um novo
para a próxima rodada (`docs/MICRO-CONTEXT.md`, seção 2). Acrescente a linha correspondente em
`INDEX.md` ao criar este arquivo. Boa parte do checklist abaixo tende a se repetir sem mudança
entre fatias da mesma feature — quando não houver mudança relevante desde a última fatia
aprovada, diga isso explicitamente em vez de preencher evidência idêntica sem necessidade.

## Veredito geral desta rodada

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

### Proteção de `main` (GitHub Flow, ver `docs/GIT-WORKFLOW.md`)

Uma linha por sub-condição de propósito: um item único agregando as seis esconde a que falha atrás
de um ✅ (`docs/gates/governanca.md`). Sub-condição que falha vira achado, não observação na evidência.

- [ ] Push direto em `main` bloqueado
- [ ] PR obrigatório antes do merge
- [ ] Status checks do CI obrigatórios
- [ ] Checks obrigatórios em modo `strict` (branch atualizada com `main` antes do merge)
- [ ] Force-push e deleção de `main` bloqueados
- [ ] Proteção aplicada também a administradores (`enforce_admins`) — a única camada aqui que não
  depende de um agente obedecer

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

Achados/pendências desta rodada entram direto na tabela de Pendências de `tracking.md` — "sem
achados" explícito se nenhuma área acusou nada nesta rodada.
