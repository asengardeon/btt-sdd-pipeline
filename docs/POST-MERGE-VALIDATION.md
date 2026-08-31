# Validação manual pós-merge contra produção real

Checklist leve para quando o orquestrador (ou o `sre`) precisa confirmar, contra o ambiente de
produção real, algo que não dá para validar só com testes automatizados — ex.: um add-on
provisionado, um DNS propagado, um e-mail transacional realmente entregue, uma variável de
ambiente aplicada no deploy. Isso não é uma etapa nova do pipeline SDD (`docs/SDD-WORKFLOW.md`
continua com as mesmas 7 etapas + 1 condicional) — é o procedimento a seguir sempre que uma fatia
`infra`/`ambos (validação)` (`.claude/skills/sdd-implement/SKILL.md`, passo 2b-bis) ou um item
"VALIDAR DEPOIS" pede confirmação contra o mundo real depois do merge.

## Antes de validar

- Confirme que o deploy que você vai validar já aconteceu de verdade — não presuma que o merge
  disparou o deploy; confira logs/CLI do provedor (`heroku releases`, `wrangler deployments list`,
  equivalente) ou o dashboard do provedor.
- Identifique o que, especificamente, está sendo validado — um item `QA-N`/`TRD-N` concreto, não
  "ver se está tudo funcionando". Se não há um item específico, é sinal de que isso deveria ter
  sido um critério de aceite no PRD/TRD, não uma checagem solta.

## Como validar

- **Sessão autenticada real**, quando a validação depende de login: use as credenciais reais do
  usuário (nunca invente/mocke uma sessão) — via browser automation quando a superfície é web, ou
  via CLI do provedor quando a superfície é infraestrutura.
- **Confirme o deploy efetivo**, não só "o comando rodou sem erro": leia logs do serviço, rode o
  comando de status/health do provedor, ou exercite o caminho funcional de ponta a ponta (mesmo
  princípio do `sre`, `docs/QUALITY-GATES.md`, seção SRE — "validado com build + subida reais").
- **DNS/certificados**: confirme propagação de verdade (`dig`/`nslookup`, ou o painel do provedor
  de DNS), não só que o registro foi criado.
- **Dados de teste criados durante a validação são removidos ao final** — nunca deixe um registro,
  e-mail de teste, ou objeto de storage criado só para confirmar o fluxo poluindo o ambiente de
  produção real.

## Depois de validar

- **Feche o ciclo do "VALIDAR DEPOIS"**: se a validação confirma um item que estava marcado como
  pendente em `qa-report.md`/`trd.md`/outro artefato, rode `/sdd-amend` para marcar esse item como
  "validado" — nunca deixe isso implícito (`.claude/skills/sdd-implement/SKILL.md`, seção
  "Validação manual pós-merge contra produção real"). Sem esse passo, `/sdd-pending` continua
  listando o item como pendente mesmo depois de confirmado de verdade.
- Se a validação revelar um problema real (não só uma dúvida esclarecida), trate como um achado
  normal: registre e volte à etapa do pipeline responsável por corrigi-lo — não corrija
  silenciosamente por fora do fluxo.
