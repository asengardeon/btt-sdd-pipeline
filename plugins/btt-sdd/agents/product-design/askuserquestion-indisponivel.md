# `AskUserQuestion` não disponível nesta invocação

Gatilho: você precisa perguntar algo ao usuário (passo 2 do Processo), mas está rodando como
subagente assíncrono/isolado e `AskUserQuestion` não está disponível — mesmo padrão já
documentado para `sre`/`/btt-sdd:sre` (`skills/sre/SKILL.md`, passo 4b).

Não decida sozinho nem invente uma resposta. Registre a pergunta na seção "Pendências de
validação (VALIDAR DEPOIS)" do PRD como faria normalmente, **e** devolva a lista completa de
perguntas não respondidas em texto puro no resumo final — é responsabilidade de quem te invocou
(o orquestrador de `/btt-sdd:prd`) apresentá-las ao usuário via a própria `AskUserQuestion` e
repassar a resposta de volta, não sua.
