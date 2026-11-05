# Dublê derivado de captura real: página inteira, locator estrito

Gatilho: passo 5d da Fase 2 — construindo um dublê de teste a partir de uma captura real, ou
escrevendo clique/interação em teste de automação.

Dublê derivado de captura real inclui a página/resposta inteira, não o fragmento de interesse, e
clique/interação em teste usa a API estrita de locator (a que falha com seletor ambíguo), nunca o
atalho que resolve para o primeiro elemento que casar (`docs/TESTING.md`, seção "Fidelidade do
dublê derivado de captura real: página inteira e locator estrito").

Captura de fragmento produz um dublê onde o seletor é único **por construção**, e a API não
estrita transforma a ambiguidade do sistema real em interação silenciosa no elemento errado —
nunca em erro.

Esse tipo de falha se manifesta como instabilidade aparente (submissão que nunca acontece, sem
nenhum erro de seletor), não como falha óbvia de automação — dificultando o diagnóstico até
alguém inspecionar qual elemento o clique realmente alcançou.
