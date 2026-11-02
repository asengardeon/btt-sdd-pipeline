# Dosagem do custo de validação de uma correção pontual

Gatilho: ao decidir o alcance da validação (suíte completa vs. escopada) de uma correção de
achado de revisão.

**Dose o custo de validação pelo alcance real da correção — simétrico à dosagem de contexto da
mensagem de retomada.** Rodar a suíte completa local continua sendo o padrão **sempre que a
correção toca comportamento de produção**. Mas se o diff da correção **não toca nenhum arquivo de
`src/`/`frontend/`** (ex.: só acrescenta casos de teste, só ajusta um comentário/doc), ou toca
apenas código que a suíte rápida cobre integralmente, a validação local pode ser **escopada aos
módulos afetados** — desde que **o CI do PR fique verde no commit final**, que é o gate real. Se
escopar, o relatório da rodada declara explicitamente o que foi rodado localmente, o que foi
delegado ao CI, e por quê — a omissão dessa declaração é que transforma escopar em atalho
silencioso.

Já aconteceu de verdade: uma rodada de correção que mudou **3 `InlineData` num arquivo de teste e
um comentário**, zero linhas de comportamento, foi a etapa mais longa da fatia inteira (41m14s,
mais que a implementação) — gasta rodando duas vezes uma suíte de integração com navegador real
que a correção não podia afetar, ambas vermelhas por flakiness de ambiente. Na mesma fatia, os
mesmos testes passaram verdes de primeira nos dois runs de CI em runner dedicado, sem rerun: em
ambiente de desenvolvimento contendido, o CI é o sinal **mais** confiável, não menos. Isso não vale
como desculpa para pular validação de uma correção que mexe em produção — ali a suíte completa
local continua obrigatória antes de empurrar para o CI.

**E essa suíte completa obrigatória é a da trilha afetada, nunca a das duas.** Numa fatia
full-stack, uma correção que toca só `src/` exige a suíte completa de backend; a de frontend — com
navegador real e comando de build, as rodadas mais caras do pipeline — **não roda**, e o artefato
`coverage/<fatia>-frontend.md` continua válido como está, porque o frescor da evidência é por
trilha (`docs/TESTING.md`, bullet "O frescor é por trilha, nunca global"). O inverso vale igual. A
exceção é o caminho **compartilhado** pelas duas trilhas (contrato gerado, pacote comum, esquema):
ali as duas suítes rodam, porque o código que as duas consomem mudou de fato.
