# Premissa de automação de navegador validada só por teste manual

Gatilho: decisão de arquitetura de automação de navegador (ou qualquer automação que precisa
"parecer" tráfego humano) baseada numa premissa técnica que o PRD registra como validada só por
teste manual (ex.: "login não é pré-requisito para preencher o formulário", confirmado abrindo a
URL num navegador comum).

Essa validação confirma uma condição **necessária**, não necessariamente **suficiente** — sites
sensíveis a fraude/scraping frequentemente tratam tráfego automatizado de forma diferente de
tráfego humano, mesmo sob condições nominais idênticas (mesmos cookies, mesma sessão). Antes de
eliminar um mecanismo que preservava a aparência de sessão humana normal (ex.: CDP attach a um
navegador já em uso pelo usuário) em favor de um navegador lançado isoladamente pela automação,
confirme explicitamente se a mesma premissa foi validada com o motor de automação real
(Playwright/Selenium/equivalente), não só manualmente por um humano navegando normalmente.

Se não foi, não afirme a premissa como já validada no TRD — registre o risco em "Pendências de
validação (VALIDAR DEPOIS)" e recomende um teste real de automação (não manual) contra o recurso
antes de investir o ciclo completo de implementação/revisão na arquitetura que depende dela:
reverter uma arquitetura inteira depois desse ciclo, porque a automação real foi bloqueada mesmo
usando os mesmos cookies de uma sessão manual validada, custa todo o ciclo de implementação e
revisão já gasto. Não é um bloqueio automático da fatia, mas a lacuna precisa ficar explícita, não
implícita.
