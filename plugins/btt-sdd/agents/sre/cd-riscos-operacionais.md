# Riscos operacionais de deploy não óbvios

Gatilho: a fatia muda algo em CD/deploy/infra que não é só "deploy roda depois do CI verde" —
contrato de API consumido por cliente já implantado, novo proxy/sidecar entre app e serviço
remoto, PR marcado `CONFLICTING`, ou plano que toca mutação real de infra/geração de carga, ou
qualquer comando de CLI (inclusive só leitura/diagnóstico) contra um app de produção real.

## Janela de quebra de contrato entre fatias

Fatia torna obrigatório um campo antes opcional/ausente numa rota já ativa, consumida por um
cliente já implantado que ainda não foi atualizado para enviá-lo (`docs/ENGINEERING-PILLARS.md`,
seção "Disponibilidade", "Janelas de quebra de contrato entre fatias" do TRD): antes de aprovar,
verifique se os gates de deploy automático relevantes desta stack já estão ativos (`gh variable
list`, ou o mecanismo equivalente documentado em `docs/STACK.md`/`cd.yml`). Se estiverem, isso é
**achado bloqueante**, não uma nota informativa de coordenação de deploy — exija antes do merge
(a) um default retrocompatível nesta mesma fatia, ou (b) confirmação explícita do usuário, via
`AskUserQuestion`, de que aceita conscientemente a janela de quebra em produção.

## Novo proxy/sidecar/cache local entre a aplicação e um serviço antes remoto

(ex.: PgBouncer na frente de um Postgres gerenciado, um sidecar de service mesh, um Redis local na
frente de um Redis gerenciado) exige reavaliar toda configuração de segurança de transporte que
assumia esse serviço como remoto — TLS/SSL (`sslmode`/equivalente), autenticação, timeouts.
Normalmente essa configuração precisa ficar condicional ao destino real da conexão (local vs.
remoto), não um valor fixo herdado de quando só existia o hop remoto.

## PR `CONFLICTING`

Se o PR que você está revisando/aprovando aparecer como `CONFLICTING` (`gh pr view --json
mergeable`), nunca presuma que é só defasagem de `main` sem investigar — rode `git merge-tree`
(ou equivalente, um merge de três vias sem tocar o working tree) para confirmar se é conflito
real de conteúdo (duas edições sobrepostas no mesmo trecho, ex.: o PRD — `specs/<slug>/prd/` ou
`prd.md` — editado por um hotfix/`/btt-sdd:amend` concorrente) ou só um merge trivial que `gh`
ainda não recalculou. Nunca
resolva um conflito real de conteúdo sozinho — pare e relate ao usuário com o diagnóstico (quais
branches/commits colidem, no quê).

## Bloqueio do classificador de modo automático

Sinalize de antemão, no próprio plano, qualquer etapa que provavelmente será bloqueada pelo
classificador de modo automático desta sessão. Mutação real de infraestrutura/config vars de
produção e geração deliberada de tráfego/carga (ex.: múltiplos logins concorrentes para validar
esgotamento de conexão) são tipicamente bloqueadas para orquestrador e subagentes, exigindo
execução manual do usuário ou uma regra de permissão explícita. Ao montar
qualquer plano que envolva essas duas categorias, inclua no próprio texto apresentado via
`AskUserQuestion`: "as etapas X e Y provavelmente serão bloqueadas pelo modo automático desta
sessão e vão precisar que você mesmo rode os comandos, ou libere uma regra de permissão — quer
fazer isso agora ou seguimos e eu aviso quando chegar lá?".

**O bloqueio não distingue leitura de mutação** — qualquer comando de CLI contra um app de
produção real (`heroku run`/`heroku <verbo> --app <app-real>` ou equivalente) tende a cair no mesmo
bloqueio, mesmo quando é só diagnóstico somente-leitura (ex.: `heroku run "php -v && php -m"` para
listar módulos carregados, `heroku builds --app <app>` para listar builds — nenhum dos dois muta
nada). Antecipe isso no plano para **qualquer** comando contra o app real de produção, não só para
mutação/geração de carga. Um comando bloqueado repetido consome o limite de 3 tentativas de
`docs/gates/governanca.md` antes de escalar — antecipar no plano evita gastar esse limite
descobrindo na prática (issue #609).
