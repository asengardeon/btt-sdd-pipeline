# Hooks como guarda determinística

Skill e instrução de agente **orientam** — um agente que lê a regra e decide seguir. Hook do Claude
Code **bloqueia** — o comando nem executa. Este doc cobre quando vale reforçar uma regra já escrita
neste pipeline com um hook, e dois exemplos concretos prontos para adaptar.

## Quando vale um hook, e quando não vale

Reforce com hook só a regra que **já é absoluta neste pipeline, sem exceção legítima a julgar** —
`main` nunca recebe commit direto (`docs/GIT-WORKFLOW.md`, regra 1), por exemplo. Regra que depende
de contexto ("essa mudança de design está certa?", "este achado é bloqueante?") fica em skill ou
instrução de agente — um hook só vê o comando, nunca o julgamento por trás dele.

## Onde registrar

`.claude/settings.json` do projeto (versionado, revisável como qualquer outro arquivo) para hooks
que a equipe decide e pode ajustar. Managed settings (fora do controle de quem roda a sessão) só
para a política que nenhum engenheiro deve conseguir afrouxar — normalmente decisão de quem
administra a organização, não deste pipeline.

## Exemplo 1 — bloqueia commit/push direto em `main`/`master`

```bash
#!/bin/bash
# .claude/hooks/block-main-write.sh — PreToolUse em Bash
cmd=$(jq -r '.tool_input.command // ""' < /dev/stdin)
branch=$(git branch --show-current 2>/dev/null)
if [[ "$branch" == "main" || "$branch" == "master" ]] && [[ "$cmd" =~ ^git[[:space:]]+commit ]]; then
  echo "Commit direto em '$branch' bloqueado — toda mudança entra via PR (docs/GIT-WORKFLOW.md, regra 1)." >&2
  exit 2
fi
if [[ "$cmd" =~ ^git[[:space:]]+push.*[[:space:]](main|master)([[:space:]]|$) ]]; then
  echo "Push direto para main/master bloqueado — abra PR (docs/GIT-WORKFLOW.md, regra 1)." >&2
  exit 2
fi
exit 0
```

```json
{
  "hooks": {
    "PreToolUse": [
      { "matcher": "Bash", "hooks": [{ "type": "command", "command": ".claude/hooks/block-main-write.sh" }] }
    ]
  }
}
```

## Exemplo 2 — bloqueia edição de arquivo de teste sem sinalização explícita

TDD exige corrigir o código ao reagir a uma falha, nunca o teste (`docs/TESTING.md`). Um hook não
distingue "corrigindo um bug" de "escrevendo um teste novo de propósito" — por isso o bloqueio por
padrão exige uma variável de ambiente explícita para liberar, em vez de tentar inferir a intenção:

```bash
#!/bin/bash
# .claude/hooks/guard-test-edit.sh — PreToolUse em Edit/Write
file=$(jq -r '.tool_input.file_path // ""' < /dev/stdin)
if [[ "$file" =~ (^|/)(tests?|__tests__)/ || "$file" =~ \.(test|spec)\.[a-zA-Z0-9]+$ ]]; then
  if [[ -z "$ALLOW_TEST_EDIT" ]]; then
    echo "Edição de arquivo de teste bloqueada sem ALLOW_TEST_EDIT=1 — defina a variável só quando a tarefa é escrever/atualizar teste de propósito (TDD red, teste novo), nunca para 'destravar' uma correção de bug." >&2
    exit 2
  fi
fi
exit 0
```

A sessão/orquestrador exporta `ALLOW_TEST_EDIT=1` só na janela em que a tarefa é genuinamente sobre
teste — nunca como configuração permanente, senão o hook perde o efeito.

## Quando propor isto num projeto

`sre` (`docs/gates/sre.md`) oferece este reforço ao configurar CI/CD de um projeto novo, ou ao
revisar a infraestrutura de um já existente. Decisão de adotar (e quais regras reforçar) é
registrada em `docs/PROJECT-CONVENTIONS.md`, com aprovação explícita do usuário — nunca aplicado
sem essa confirmação, pelo mesmo motivo de qualquer mudança real de infraestrutura
(`agents/sre.md`, "Plano antes de executar, sempre").

## Limite

Hook reforça uma regra já escrita — nunca é a primeira vez que a regra existe. Documente a decisão
no artefato de origem (`docs/GIT-WORKFLOW.md`, `docs/TESTING.md`) antes de reforçá-la aqui; um hook
sem regra documentada por trás é uma restrição sem explicação para quem a encontra.
