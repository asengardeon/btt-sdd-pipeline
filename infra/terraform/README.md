# Terraform — esqueleto de infraestrutura

Este diretório é um **esqueleto ilustrativo**, não uma infraestrutura pronta para aplicar. Ele
mostra a organização esperada (estado remoto, variáveis sensíveis marcadas, módulos reutilizáveis,
tags padronizadas) para quando uma feature real do pipeline SDD precisar de infraestrutura de
nuvem — o exemplo `0001-example-task-management` é uma CLI local e não precisa de nada disto.

Provider usado como ilustração: AWS (ECR + ECS Fargate, um padrão comum para publicar um serviço
containerizado). Ao adotar outro provedor, troque `main.tf`/`modules/` mantendo a mesma
organização: `versions.tf` (constraints), `backend.tf` (estado remoto), `variables.tf` (entradas,
com `sensitive = true` onde aplicável), `main.tf` (composição de módulos), `outputs.tf` (saídas),
`modules/` (componentes reutilizáveis entre ambientes).

Antes de rodar `terraform apply` de verdade:

1. Configure o backend real em `backend.tf` (bucket/tabela de lock, ou o equivalente do seu
   provedor) — nunca use state local em produção.
2. Preencha `variables.tf`/um arquivo `*.tfvars` com os valores do ambiente.
3. Rode `terraform plan` e revise antes de `apply` — o agente `sre` (`.claude/agents/sre.md`)
   nunca aplica infraestrutura sem confirmação explícita do usuário.
