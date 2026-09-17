---
name: status
description: Utilitário do pipeline SDD. Use quando o usuário perguntar em que estágio está uma feature, ou quiser um panorama de todas as features em specs/. Não aciona nenhum agente — só lê o estado atual dos artefatos.
allowed-tools: Bash(${CLAUDE_SKILL_DIR}/scripts/sdd-status.sh *) PowerShell(${CLAUDE_SKILL_DIR}/scripts/sdd-status.ps1 *)
---

# /btt-sdd:status

Não aciona nenhum agente — é um utilitário de leitura.

## Onde ficam os docs de governança citados nesta skill

Referências como `docs/GIT-WORKFLOW.md`, `docs/QUALITY-GATES.md`, `docs/TESTING.md`,
`docs/ENGINEERING-PILLARS.md`, `docs/ARCHITECTURE.md`, `docs/SDD-WORKFLOW.md`,
`docs/FILE-GUIDE.md` e `docs/POST-MERGE-VALIDATION.md` nesta skill apontam para os docs genéricos
deste pipeline — **não são copiados para dentro de cada projeto que o usa**. Resolva-os a partir
de onde esta própria skill está instalada (o "Base directory" desta invocação, dentro do plugin
`btt-sdd`): esses docs estão em `docs/` na raiz **deste plugin instalado**, atualizado
automaticamente a cada `claude plugin update` — não no projeto onde você está trabalhando agora.
Se o projeto atual também tiver um `docs/<nome>.md` próprio (`STACK.md`, `BASELINE.md`,
`LESSONS-LEARNED.md`, `adr/`), esse é conteúdo do projeto, não deste plugin — não confunda os
dois.

## Passos

1. **Prefira o script auxiliar em vez de ler cada artefato inteiro** (economiza tokens): rode
   `${CLAUDE_SKILL_DIR}/scripts/sdd-status.sh [slug]` (bash) ou
   `${CLAUDE_SKILL_DIR}/scripts/sdd-status.ps1 [-Slug <slug>]` (PowerShell), escolhendo o
   interpretador disponível no ambiente — o script roda a partir de onde estiver instalado (não
   depende de estar na raiz do projeto), mas lê `specs/`/`docs/` relativos ao diretório de
   trabalho atual, que deve ser a raiz do projeto. Ele já devolve, por feature: etapa atual,
   próximo comando, contagem de pendências VALIDAR DEPOIS, e se alguma etapa posterior "requer
   revalidação".
2. Apresente a tabela retornada pelo script diretamente ao usuário (traduza/formate se útil, mas
   não recalcule do zero).
3. **Só leia os artefatos manualmente** (fallback) se o script falhar, ou se uma linha vier
   marcada como "veredito não identificado"/"rascunho, não aprovado" e o usuário pedir detalhe.
4. Se `args` traz um slug específico, passe-o como argumento do script (evita processar features
   que não interessam); senão, rode sem argumento para ver todas.
5. Para o detalhe de uma pendência específica, aponte o usuário para `/btt-sdd:pending` em
   vez de listar tudo aqui.

### Fallback sem o script (comportamento anterior)

1. Liste os diretórios em `specs/` (exceto `_template`).
2. Para cada um, verifique a presença de: `prd.md`, `trd.md`, `code-review.md`, `qa-report.md`,
   `security-review.md`, `sre-review.md`, e se há código/testes associados em `src/`/`tests/`
   referenciando a feature.
3. Apresente uma tabela curta: feature | etapa atual | próximo comando a rodar | pendências
   VALIDAR DEPOIS | etapas "requer revalidação". A etapa atual é a última etapa concluída; o
   próximo comando é a skill seguinte na ordem
   `sdd-prd → sdd-trd → sdd-implement → sdd-code-review → sdd-qa → sdd-security → sdd-sre`.
4. Conte, por feature, quantos itens com status "pendente" existem nas seções "Pendências de
   validação (VALIDAR DEPOIS)" de cada artefato.
5. Verifique se algum artefato tem uma entrada no "Log de revisões" marcando uma etapa posterior
   como "requer revalidação" (produzido por `/btt-sdd:amend`) e sinalize isso — não trate
   como etapa concluída até a revalidação acontecer.
6. Se um `code-review.md`, `qa-report.md`, `security-review.md` ou `sre-review.md` existir com
   veredito reprovado, sinalize isso explicitamente em vez de tratar como etapa concluída.
