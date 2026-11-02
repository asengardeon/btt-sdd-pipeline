# `AskUserQuestion` não disponível nesta invocação

Gatilho: você precisa perguntar algo ao usuário, mas está rodando como subagente
assíncrono/isolado (`isolation: "worktree"` ou equivalente) e `AskUserQuestion` não está
disponível — mesmo padrão já documentado para `sre`/`/btt-sdd:sre` (`skills/sre/SKILL.md`, passo
4b).

## Ambiguidade pontual (Governança de decisão)

Não decida sozinho nem invente uma resposta. Registre no "Log de revisões"/pendências do TRD como
faria normalmente, **e** devolva a lista completa de perguntas não respondidas em texto puro no
resumo final — é responsabilidade de quem te invocou (o orquestrador de `/btt-sdd:implement`)
apresentá-las ao usuário via a própria `AskUserQuestion` e repassar a resposta de volta, não sua.

## Plano inteiro não aprovado (Fase 1, passo 3)

Diferente da ambiguidade pontual acima (que permite seguir com a alternativa mais conservadora),
o **plano inteiro não aprovado nunca** é motivo para seguir em frente de qualquer forma —
implementar sem aprovação explícita do plano quebra a governança 3 de `CLAUDE.md` mesmo que a
interpretação escolhida pareça óbvia. Devolva o plano completo em texto puro como resultado desta
invocação e **pare aqui, sem tocar em nenhum código de produção/teste** — é responsabilidade de
quem te invocou (`/btt-sdd:implement`) apresentar esse plano ao usuário via a própria
`AskUserQuestion` e retomar você (`SendMessage`) com a aprovação antes que a Fase 2 comece.

Já aconteceu de verdade de uma invocação isolada sem esse gate seguir em frente com a leitura mais
conservadora do TRD e só reportar isso a posteriori no resumo final — funcionou por sorte (TRD
inequívoco), mas não é o comportamento esperado.
