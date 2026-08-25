# Fluxo de Git: GitHub Flow aplicado ao pipeline SDD

Este repositório usa **GitHub Flow**: um único branch de longa duração (`main`, sempre
implantável), uma branch curta por feature, Pull Request obrigatório para voltar a `main`. Sem
`develop`, sem `release/*`, sem branches de longa duração além de `main`.

## Regras

1. **`main` é sempre implantável.** Ninguém commita direto nela. Toda mudança entra via PR.
2. **Uma branch por feature/spec**, criada a partir de `main` atualizada, com o nome
   `feature/<NNNN-slug>` — reaproveitando o número e o slug já usados em `specs/<NNNN-slug>/`
   (ex.: spec `specs/0002-relatorio-mensal` → branch `feature/0002-relatorio-mensal`). Isso deixa
   o vínculo spec ↔ código ↔ branch ↔ PR rastreável só pelo nome. Quando a feature é full-stack, é
   **uma única branch/PR** — `backend-developer` trabalha em `src/`+`tests/`,
   `frontend-developer` em `frontend/`, cada um só na sua árvore de diretório, o que evita
   conflito de merge entre os dois trabalhando em paralelo.
3. **PR aberto cedo**, como *draft*, assim que o primeiro commit da implementação existe — não só
   no final. Isso deixa o CI rodando continuamente contra a branch (`ci.yml` já dispara em
   `pull_request`) e dá visibilidade do progresso.
4. **Revisão de código, QA, segurança e SRE revisam contra o PR**, não contra código local solto:
   `code-review.md`, `qa-report.md`, `security-review.md` e `sre-review.md` da feature referenciam
   o número/link do PR.
5. **Merge só depois de revisão de código, QA, segurança e SRE aprovados** e CI verde (lint +
   testes + gate de cobertura 80%). Preferência por *squash merge* — um commit por feature em
   `main`, histórico linear e legível.
6. **`main` protegida** nas configurações do repositório GitHub (fora do controle de arquivos
   versionados, é responsabilidade de quem administra o repo — normalmente o agente `sre` valida
   isso, não configura sozinho):
   - Push direto bloqueado.
   - PR obrigatório antes de mergear.
   - Status checks obrigatórios: o job de lint/teste/cobertura do `ci.yml`.
   - Sem force-push em `main`.
7. **Merge para `main` dispara CD.** `cd.yml` já dispara por `workflow_run` do `CI` concluído com
   sucesso em `main` — nenhuma mudança de workflow é necessária para isso funcionar, só a
   configuração de branch protection acima.

## Mapeamento no pipeline SDD

| Etapa                | Ação de Git                                                                 |
|-----------------------|-------------------------------------------------------------------------------|
| `/sdd-prd`, `/sdd-trd` | Nenhuma — são documentos em `specs/`, ainda não há código/branch.             |
| `/sdd-implement`       | Cria `feature/<NNNN-slug>` a partir de `main`; abre PR draft no primeiro commit; commita incrementalmente (um commit por ciclo TDD ou por incremento coerente). Se full-stack, `backend-developer` e `frontend-developer` commitam na mesma branch em paralelo. |
| `/sdd-code-review`      | Roda contra a branch/PR; referencia o PR no `code-review.md`.                 |
| `/sdd-qa`               | Roda contra a branch/PR; referencia o PR no `qa-report.md`.                   |
| `/sdd-security`         | Roda contra a branch/PR; referencia o PR no `security-review.md`.             |
| `/sdd-sre`              | Revisa CI/CD/infra; se aprovado, marca o PR como pronto para review humano/merge. |
| Merge do PR             | Feito pelo usuário (ou por quem tiver permissão) depois dos aprovados acima — não é um passo automático de nenhum agente. Dispara CD. |

## Por que não usar `/sdd-amend` para reescrever histórico

Uma emenda a um artefato já aprovado (`/sdd-amend`, ver `docs/SDD-WORKFLOW.md`) nunca reescreve
commits já feitos em uma branch de feature — ela adiciona um novo commit registrando a mudança
(commits de correção fazem parte do histórico normal do PR). O log de revisões dentro do próprio
artefato (`prd.md`/`trd.md`/etc.) é o registro de *por que* mudou; o git log é o registro de
*quando*.
