# Riscos operacionais de deploy não óbvios

Gatilho: a fatia muda algo em CD/deploy/infra que não é só "deploy roda depois do CI verde" —
contrato de API consumido por cliente já implantado, novo proxy/sidecar entre app e serviço
remoto, PR marcado `CONFLICTING`, ou plano que toca mutação real de infra/geração de carga.

## Janela de quebra de contrato entre fatias

Fatia torna obrigatório um campo antes opcional/ausente numa rota já ativa, consumida por um
cliente já implantado que ainda não foi atualizado para enviá-lo (`docs/ENGINEERING-PILLARS.md`,
seção "Disponibilidade", "Janelas de quebra de contrato entre fatias" do TRD): antes de aprovar,
verifique se os gates de deploy automático relevantes desta stack já estão ativos (`gh variable
list`, ou o mecanismo equivalente documentado em `docs/STACK.md`/`cd.yml`). Se estiverem, isso é
**achado bloqueante**, não uma nota informativa de coordenação de deploy — exija antes do merge
(a) um default retrocompatível nesta mesma fatia, ou (b) confirmação explícita do usuário, via
`AskUserQuestion`, de que aceita conscientemente a janela de quebra em produção. Já aconteceu de
verdade: esse cenário foi identificado e registrado como "pendência de coordenação, não de
código" (achado não-bloqueante) sem checar se os gates de deploy automático já estavam ligados —
estavam, o merge disparou CI/CD automaticamente, e todo login por senha em produção passou a
falhar até um hotfix horas depois.

## Novo proxy/sidecar/cache local entre a aplicação e um serviço antes remoto

(ex.: PgBouncer na frente de um Postgres gerenciado, um sidecar de service mesh, um Redis local na
frente de um Redis gerenciado) exige reavaliar toda configuração de segurança de transporte que
assumia esse serviço como remoto — TLS/SSL (`sslmode`/equivalente), autenticação, timeouts.
Normalmente essa configuração precisa ficar condicional ao destino real da conexão (local vs.
remoto), não um valor fixo herdado de quando só existia o hop remoto. Já aconteceu numa sessão
real: introduzir PgBouncer via buildpack manteve `sslmode=require` fixo, correto para o Postgres
remoto mas incompatível com a nova conexão loopback local ao PgBouncer — só descoberto depois do
merge, em produção, com ~20 minutos de outage.

## PR `CONFLICTING`

Se o PR que você está revisando/aprovando aparecer como `CONFLICTING` (`gh pr view --json
mergeable`), nunca presuma que é só defasagem de `main` sem investigar — rode `git merge-tree`
(ou equivalente, um merge de três vias sem tocar o working tree) para confirmar se é conflito
real de conteúdo (duas edições sobrepostas no mesmo trecho, ex.: `specs/<slug>/prd.md` editado por
um hotfix/`/sdd-amend` concorrente) ou só um merge trivial que `gh` ainda não recalculou. Nunca
resolva um conflito real de conteúdo sozinho — pare e relate ao usuário com o diagnóstico (quais
branches/commits colidem, no quê).

## Bloqueio do classificador de modo automático

Sinalize de antemão, no próprio plano, qualquer etapa que provavelmente será bloqueada pelo
classificador de modo automático desta sessão. Mutação real de infraestrutura/config vars de
produção e geração deliberada de tráfego/carga (ex.: múltiplos logins concorrentes para validar
esgotamento de conexão) são tipicamente bloqueadas para orquestrador e subagentes, exigindo
execução manual do usuário ou uma regra de permissão explícita. Já aconteceu numa sessão real: um
plano de hotfix de infra só descobriu esse bloqueio **durante a execução**, depois de comandos já
terem falhado — não antecipado no plano apresentado ao usuário antes de começar. Ao montar
qualquer plano que envolva essas duas categorias, inclua no próprio texto apresentado via
`AskUserQuestion`: "as etapas X e Y provavelmente serão bloqueadas pelo modo automático desta
sessão e vão precisar que você mesmo rode os comandos, ou libere uma regra de permissão — quer
fazer isso agora ou seguimos e eu aviso quando chegar lá?".
