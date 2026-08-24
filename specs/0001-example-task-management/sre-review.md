# SRE Review — Gestão simples de tarefas (exemplo do pipeline SDD)

> Autor: agente `sre`
> QA report: `specs/0001-example-task-management/qa-report.md`
> PR: não aplicável — feature commitada diretamente em `main` no commit inicial, antes da política
> de GitHub Flow (ver `docs/GIT-WORKFLOW.md`, "Exceção histórica")
> Data: 2026-08-24

## 1. Veredito geral

**Aprovado com ressalvas** — Docker foi validado de fato (build + execução real, ver seção 4).
Terraform segue sem validação de execução real neste ambiente (ver seção 5/7) — é a única
ressalva restante, e não bloqueia o uso do template, só um `apply` real desta infraestrutura
ilustrativa.

## 2. CI

- [x] Lint roda no pipeline (`ruff check src tests` em `.github/workflows/ci.yml`)
- [x] Testes rodam no pipeline (`pytest --cov=src ...`)
- [x] Gate de cobertura 80% aplicado e falha o build se violado (`fail_under = 80` em
      `pyproject.toml`, lido automaticamente pelo `pytest-cov`)
- [x] Pipeline falha rápido (cada step para o workflow se falhar; lint roda antes dos testes)

Evidência: `ci.yml` validado como YAML sintaticamente correto (`yaml.safe_load`); comandos de
lint e teste executados localmente neste ambiente com sucesso (18 testes, 98.44% de cobertura,
lint sem apontamentos — ver `qa-report.md`).

## 3. CD

- [x] Deploy só roda após CI verde (`cd.yml` dispara por `workflow_run` do workflow `CI`
      concluído em `main`, não por `push` direto)
- [x] `terraform apply` gated (`terraform plan` roda em job separado, salva o plano como
      artefato, e o job de `apply` usa um GitHub `environment` — que exige aprovação manual
      quando configurado com required reviewers no repositório)
- [x] Estratégia de rollback documentada: reaplicar a task definition/imagem anterior via novo
      `workflow_dispatch` apontando `container_image` para a tag anterior (tags são imutáveis no
      ECR — `image_tag_mutability = "IMMUTABLE"` em `main.tf`)
- [ ] `main` protegida (GitHub Flow): **não verificado** — é configuração das settings do
      repositório no GitHub, fora do controle de arquivos versionados; nada a validar localmente
      neste momento (o repositório nem tem remote configurado ainda)

Evidência: `cd.yml` validado como YAML sintaticamente correto.

## 4. Docker

- [x] Build multi-stage, imagem final mínima (estágio `builder` com toolchain de instalação;
      estágio `runtime` copia só o venv e o `src/`, base `python:3.11-slim`)
- [x] Processo roda como usuário não-root (`appuser`, uid 1000)
- [x] Sem segredo hardcoded na imagem ou no `Dockerfile`
- [ ] Healthcheck: **N/A** — a aplicação de exemplo é uma CLI de execução curta, não um serviço
      de longa duração; não há processo para healthcheck verificar

Evidência: **build e execução validados de fato** (Docker Desktop iniciado pelo usuário durante a
revisão).
- `docker build -f infra/docker/Dockerfile -t projeto-base-ia-example:test .` — sucesso, imagem
  final com 220MB.
- `docker run --rm projeto-base-ia-example:test create "teste via docker"` — executou o comando
  corretamente.
- `docker run --rm --entrypoint whoami projeto-base-ia-example:test` → `appuser` — confirma
  execução como usuário não-root.
- `docker compose -f infra/docker/docker-compose.yml up --build` — subiu, rodou `list`, saiu com
  código 0.
- Container novo (`list`) retornou `no tasks`, como esperado: a persistência é em memória e não
  atravessa execuções — comportamento correto conforme o TRD (fora de escopo: persistência real).

## 5. Terraform

- [x] Estado remoto configurado (esqueleto em `backend.tf`, comentado com instrução para
      preencher bucket/tabela de lock reais antes do primeiro `init`)
- [x] Variáveis sensíveis marcadas `sensitive = true` (`app_secrets` em `variables.tf`; segredos
      efetivos ficam em Secrets Manager, nunca em variável de ambiente em texto claro no
      Terraform)
- [ ] `terraform plan` limpo: **não verificado** — Terraform CLI não está instalado neste
      ambiente, então `terraform init`/`validate`/`plan` não puderam ser executados de fato
- [x] Recursos versionados/tagueados de forma consistente (`default_tags` no provider em
      `main.tf`, aplicado a todos os recursos)
- [x] Módulos reutilizáveis (`infra/terraform/modules/ecs-service/`) em vez de duplicação entre
      ambientes

Evidência/observação: HCL escrito e revisado manualmente, mas **não passou por
`terraform validate`** neste ambiente. Recomendação: rodar `terraform init && terraform validate`
localmente (ou deixar o CI fazer isso — considere adicionar um job de `terraform validate` ao
`ci.yml` quando o repositório passar a ter infraestrutura real gerenciada, o que ainda não é o
caso desta feature de exemplo).

## 6. Observabilidade

- [x] A feature de exemplo não tem requisito de observabilidade no TRD além da própria saída da
      CLI (aplicação de execução curta, sem estado persistente real) — nada pendente aqui.

## 7. Pendências

| # | Item                                                              | Responsável | Bloqueia release? |
|---|---------------------------------------------------------------------|---------------|----------------------|
| 1 | ~~Confirmar `docker build` com sucesso~~ — feito nesta revisão (seção 4) | — | Resolvido |
| 2 | Rodar `terraform init && terraform validate` antes de qualquer `plan`/`apply` real | usuário | Sim, antes de qualquer apply real |

Item 1 resolvido nesta revisão. O item 2 não bloqueia o uso do template/pipeline SDD em si — só
bloqueia um `apply` real da infraestrutura ilustrativa em `infra/terraform/`.

## 8. Pendências de validação (VALIDAR DEPOIS)

Nenhuma nova. A verificação de proteção de `main` (seção 3) não é um item VALIDAR DEPOIS — é uma
ação de configuração de repositório que cabe ao usuário/administrador quando houver um remote
GitHub configurado, listada na tabela de pendências acima (item 2 é sobre Terraform; a proteção
de `main` ainda não tem número próprio porque depende de existir um remote primeiro).

## 9. Log de revisões

| Data       | Autor                 | O que mudou                                                        | Motivo                                                                 | Etapas revalidadas |
|------------|------------------------|------------------------------------------------------------------------|----------------------------------------------------------------------------|------------------------|
| 2026-08-24 | sessão Claude Code      | Adicionado item de verificação de proteção de `main` à seção CD; adicionadas as seções "Pendências de validação" e este log; adicionado campo PR ao cabeçalho | Alinhamento com o novo template após reforço de governança do pipeline (GitHub Flow) | Nenhuma — veredito original não mudou |

## 10. Próximo passo

Feature de exemplo pronta como referência do pipeline. Para features reais, resolva as pendências
acima antes de considerar o SRE review daquela feature aprovado sem ressalvas.
