# Padrões de desenho a verificar em cenários específicos

Cinco verificações independentes, cada uma com gatilho próprio — leia só a seção cujo gatilho
bate com a tarefa atual.

## Isolamento de teste contra serviço com estado

Gatilho: a stack decidida usa algum serviço com estado em testes de integração (banco de dados,
fila, cache, emulador de nuvem local) **e** este projeto pode ter agentes concorrentes rodando
essa suíte em worktrees isolados (`docs/GIT-WORKFLOW.md`, seção "Isolamento de arquivos não é
isolamento de serviços com estado" — cenário padrão deste pipeline sempre que uma fatia usa
`backend-developer`/`frontend-developer` em paralelo com etapas de revisão, ou múltiplas fatias/
specs em paralelo).

Decida e registre em `docs/STACK.md` o mecanismo concreto de isolamento entre execuções
concorrentes contra esse serviço — nunca deixe implícito, esperando que alguém perceba a lacuna só
quando a contenção já aconteceu. Ex.: nome de banco/schema derivado do diretório do worktree ou da
branch (`<projeto>_test_<id-do-worktree>`), ou um container efêmero por execução. Só pergunte ao
usuário via `AskUserQuestion` se houver mais de uma opção razoável para esta stack; senão, proponha
o padrão óbvio da stack e registre a proveniência. Se `docs/STACK.md` já tem essa decisão de uma
feature anterior, reaproveite sem perguntar de novo.

## Port/guard de autorização resolvido por parâmetro de contexto

Gatilho: todo port/guard que resolve autorização ou identidade por um parâmetro de contexto
(`tenantId`, `workspaceId`, `accountId`, etc.).

Pergunte explicitamente "este parâmetro representa identidade do requisitante ou escopo
operacional da ação? Eles podem divergir algum dia?" antes de aceitar um único parâmetro para os
dois papéis. Quando não há nenhum mecanismo de troca de contexto no design atual (impersonação,
"operar como", multi-workspace), os dois valores coincidem "de graça" — até uma fatia futura
introduzir exatamente esse mecanismo, e a confusão implícita vira um bug de autorização real (já
aconteceu: um `tenantId` único usado tanto para resolver o membro requisitante quanto para o
contexto da sessão quebrou quando uma fatia posterior introduziu impersonação entre tenants). Se a
feature já tem ou pode vir a ter esse mecanismo, desenhe o port com dois parâmetros desde o início
(ex.: `assertCanAdminister(requestingMemberId, targetContextId)`), mesmo que hoje sempre coincidam.

## Citar precedente como "já correto" sem reler o código real

Gatilho: antes de escrever no TRD que um mecanismo existente "já é correto por design" ou "já
resolvido" citando um precedente (ADR, spec anterior).

Verifique `docs/LESSONS-LEARNED.md`, se existir, por qualquer entrada cujo "Padrão observado"
descreva uma classe de bug que se aplicaria a esse mesmo mecanismo — não só ao caso de uso do
precedente citado. Se houver entrada aplicável (mesmo com poucas ocorrências), isso é sinal para
reler o código real do mecanismo específico sendo referenciado (não só confiar no precedente)
antes de registrar a afirmação como fato. Já aconteceu de verdade: uma nota do TRD afirmou
categoricamente que um guard "já recebia identidade e escopo como parâmetros separados, correto
desde uma spec anterior" — mas o código real do guard ainda resolvia identidade via contexto de
tenant, exatamente o padrão já catalogado com 2 ocorrências prévias na mesma entrada de
`docs/LESSONS-LEARNED.md`; virou a 3ª ocorrência do mesmo bug, descoberta só na revisão de
código/segurança em vez de na própria fase de TRD.

## Remoção de valor de enum/tipo usado para classificar dados já persistidos

Gatilho: alguma tarefa da decomposição remove um valor de enum/tipo usado para classificar dados
já persistidos (não só remover um caso de uso ou rota — um enum de status, tipo de
alerta/notificação, categoria etc. que pode aparecer em linhas já gravadas).

Confira explicitamente a auto-consistência antes de aprovar o TRD: esse valor pode aparecer em
dados já persistidos? Se sim, decida explicitamente entre (a) manter o valor válido só para
leitura de histórico, sem nenhum caminho de emissão novo, ou (b) migrar/purgar os dados existentes
antes de remover o valor por completo — nunca afirme as duas coisas ("remover por completo" e
"nenhuma migração de dados necessária") no mesmo parágrafo sem reconciliar. Registre a decisão na
seção "Riscos e trade-offs" (seção 12). Já aconteceu de verdade: um TRD instruiu remover um valor
de enum de tipo de alerta "por completo" no mesmo parágrafo em que afirmava "nenhuma migração de
dados necessária" — as duas frases eram estruturalmente incompatíveis (remover o valor faria o
adapter de leitura lançar erro ao hidratar qualquer registro já persistido com esse tipo), só
percebido pelo `backend-developer` durante a implementação, não durante o desenho do TRD.

## Exportação para CSV/planilha a partir de campo de texto livre do usuário

Gatilho: alguma tarefa da decomposição grava CSV/planilha (`fputcsv` ou biblioteca equivalente de
geração de spreadsheet) a partir de um campo de texto livre escolhido por um usuário/titular (ex.:
nome de pessoa, descrição, comentário).

Documente explicitamente na seção "Riscos e trade-offs" (seção 12) o risco de injeção de fórmula
em CSV (CWE-1236): um valor começando com `=`, `+`, `-`, `@`, tab ou retorno de carro é interpretado
como fórmula por planilhas (Excel, Google Sheets, LibreOffice) ao abrir o arquivo exportado, não só
como texto. A mitigação recomendada é prefixar/escapar a célula cujo primeiro caractere cair nesse
conjunto antes de escrevê-la — mesmo nível de proatividade que você já aplica a XSS em template
HTML ou a SQL injection em query cru, não algo reservado para a revisão de segurança descobrir
depois da implementação. Já aconteceu de verdade: numa fatia de exportação de relatório em CSV, a
seção de riscos do TRD cobriu performance e extensões de runtime, mas não esse padrão — só
percebido na revisão de segurança, via reprodução ao vivo com um payload `=HYPERLINK(...)`, depois
de uma rodada inteira de implementação já ter sido feita sem a mitigação (issue #610,
`asengardeon/btt-sdd-pipeline`).

## Campo de schema externo sem fonte clara nos objetos internos

Gatilho: ao preencher a seção 9 ("Modelo de dados / contratos externos") — schema JSON de CLI,
payload de API, formato de evento.

Confirme explicitamente que todo campo exigido nesse schema externo tem fonte clara nos objetos
internos já definidos nas seções 6 (casos de uso) e 7 (adapters): ou o campo existe no DTO de
retorno do caso de uso correspondente, ou está marcado deliberadamente como "resolvido na borda do
adapter de entrada, não no domínio/aplicação" (ex.: obtido via `git rev-parse HEAD` direto no
adapter CLI, por analogia a um campo irmão já resolvido assim). Não aprove o TRD com um campo do
schema externo sem uma dessas duas respostas — a lacuna vira uma parada de fase do
`backend-developer` no meio da implementação, consumindo uma rodada inteira de `AskUserQuestion`
que já poderia estar resolvida aqui. Já aconteceu de verdade: a seção 6 de um TRD definia o DTO de
retorno de um caso de uso sem o campo `headSha`, mas a seção 9 exigia esse campo sempre presente no
JSON de saída — o TRD já tratava corretamente o mesmo campo num comando irmão (nota explícita de
resolução na borda do adapter), só não replicou a mesma nota para o comando que travou.
