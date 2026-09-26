# SRE / CI-CD / Infra

> Parte de `docs/QUALITY-GATES.md` (índice). Gate crítico: o que está marcado aqui
> **bloqueia mesmo** — não é sugestão, é a definição do que "pronto" significa.

- [ ] CI roda lint + testes + gate de cobertura em todo PR.
- [ ] **Desperdício de CI quantificado em minutos faturáveis, não só em relógio** — repositório
  privado ou público (`gh api repos/<owner>/<repo> --jq .private`), multiplicador do runner lido do
  `runs-on` (`ubuntu` 1×, `windows` 2×, `macos` 10×), e o total `minutos × multiplicador`. Em
  repositório público a recomendação é de latência, não de custo, e isso muda a urgência.
- [ ] **Sob cadência condicional, o estado do CI reportado distingue "suíte executada" de "suíte
  pulada".** Toda etapa que afirma no seu artefato que o CI cobre o código atual inspecionou os
  passos do run, não só `conclusion` — e, quando os passos caros ficaram `skipped`, apontou qual run
  executou a suíte e provou que o código não mudou desde ele. Verde de run pulado nunca é reportado
  como "código validado".
- [ ] **Cadência de CI conferida contra `docs/PROJECT-CONVENTIONS.md`.** Padrão (arquivo ausente
  ou sem essa seção): suíte completa a cada push. Se o projeto registra `ci-antes-do-merge`, o
  `ci.yml` roda a suíte completa quando o PR **não é draft** (e em push para a branch base) e
  reporta sucesso em segundos enquanto o PR é draft — com o gate nos **passos**, nunca no job nem no
  gatilho, senão o *required status check* nunca reporta e o PR fica bloqueado para sempre (mesma
  armadilha do `paths-ignore`). O `sre` nunca adota essa cadência por conta própria: ela é opt-in do
  projeto (`agents/sre.md`, área "CI").
- [ ] `ci.yml` pula lint/testes/build numa mudança só de documentação **comparando `HEAD` com o
  último run verde desta branch** — nunca por `paths`/`paths-ignore` no gatilho, que deixa um PR só
  de documentação bloqueado para sempre quando o job é *required status check* (o workflow não
  dispara, o GitHub nunca reporta status), nem por diff contra o tip de `main`, que num PR de código
  sempre acusa `src/` e por isso nunca dispara o short-circuit. Receita completa e a medição que a
  justifica em `.claude/agents/sre.md`, área "CI". Falha em qualquer etapa da checagem → roda a
  suíte (direção de falha segura).
- [ ] Se este projeto tem hoje `paths`/`paths-ignore` no gatilho de um check obrigatório, isso é
  reportado como achado — é a forma que #146 pediu e que a medição depois mostrou ser errada, não
  uma configuração a preservar.
- [ ] `main` protegida: sem push direto, PR obrigatório, status checks obrigatórios (verificado,
  não necessariamente configurado pelo agente — configuração real é do administrador do repo).
- [ ] Deploy só roda após CI verde.
- [ ] Se a fatia torna obrigatório um campo antes opcional/ausente numa rota já ativa consumida
  por um cliente já implantado que ainda não foi atualizado para enviá-lo, e os gates de deploy
  automático relevantes já estão ligados: bloqueante até haver um default retrocompatível nesta
  fatia, ou confirmação explícita do usuário aceitando a janela de quebra em produção — nunca uma
  nota não-bloqueante de coordenação de deploy (`.claude/agents/sre.md`, área "CD e GitHub Flow").
- [ ] Nenhuma alteração de infraestrutura real (`terraform apply`) roda sem plano revisado
  (`terraform plan`) e aprovação explícita do usuário.
- [ ] Docker: build multi-stage, imagem mínima, usuário não-root, sem segredo hardcoded.
- [ ] Se a entrega inclui ambiente de desenvolvimento local (`docker-compose.yml`): validado com
  build + subida reais (não só `docker compose config`), exercitando pelo menos um caminho
  funcional de ponta a ponta (não só "o container subiu"); ambiente verificado livre de
  containers/processos órfãos de sessões anteriores antes de subir; teardown completo (incluindo
  qualquer processo iniciado fora do Docker durante a validação) ao final.
- [ ] Terraform: estado remoto configurado, variáveis sensíveis marcadas `sensitive`.
- [ ] Nenhum segredo em texto claro em código, workflow, Dockerfile ou arquivo Terraform.
- [ ] Na fatia final que fecha o spec (nenhuma fatia pendente na decomposição de tarefas do TRD),
  a revisão é sempre completa no checklist — nunca fast-path — cobrindo o diff acumulado desde a
  última revisão registrada como `completo` na tabela "Histórico de aprovações por fatia", não só
  o diff desta última fatia isolada.
- [ ] `sre-review.md` (e qualquer ajuste de `infra/`/`.github/workflows/` desta rodada)
  commitados (arquivos explícitos, nunca `git add -A`/`.`) e enviados (push) na branch do PR pelo
  próprio `sre` antes de devolver o resultado.
- [ ] Se a fatia foi aprovada e tem issues do GitHub associadas a tarefas cobertas por ela,
  `sre` documentou a resolução em cada uma (`gh issue comment`, resumo + link do PR e dos
  artefatos de revisão) antes de finalizar — a issue fecha sozinha quando a fatia mergear, via
  `Closes #N` já incluído no PR pelo `backend-developer`/`frontend-developer`.
