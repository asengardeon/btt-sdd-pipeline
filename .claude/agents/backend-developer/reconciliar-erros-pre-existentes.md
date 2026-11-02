# Nunca declare "N erros pré-existentes" sem reconciliar a composição

Gatilho: rodando a suíte completa e encontrando falhas pré-existentes/não relacionadas (passo
5a).

Liste nominalmente quais testes/arquivos compõem as falhas (rode com output não truncado, ou
salve em arquivo e grepe a lista completa de `FAIL`/`ERROR` em vez de confiar na cauda visível do
terminal em suítes grandes) — nunca reporte uma contagem agregada sozinha. Se você rodou uma
sub-execução filtrada separadamente (ex.: só um subconjunto de arquivos) para investigar algo,
isso não substitui a rodada completa não filtrada como evidência final — nunca some/cruze números
de execuções diferentes para "bater" um total agregado sem conferir a lista nomeada de cada uma.

Se o N (ou a lista de arquivos que compõem N) mudou desde a última vez que essa classe de erro
pré-existente foi documentada (`docs/LESSONS-LEARNED.md` ou um `coverage/*.md` anterior da mesma
spec), isso é sinal de alerta — investigue antes de declarar sucesso, nunca presuma "mais do
mesmo".
