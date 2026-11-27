# Relatório final: seção "Divergências do TRD para emenda"

Gatilho: ao devolver o relatório da trilha de backend (ou de uma parte dela), com o código divergindo do desenho do TRD em algum ponto.

**Liste cada divergência numa seção final do relatório chamada "Divergências do TRD para
emenda"**, nunca em prosa solta. Um item por divergência, com cinco campos: (1) arquivo e seção do
TRD afetados; (2) o que o TRD dizia; (3) o que ficou no código; (4) o motivo; (5) a prova (teste,
comando ou commit). Exemplos de divergência: nome de método trocado por regra de arquitetura,
exceção de gatilho por tabela, política de timeout em duas fases.

Sem divergência, escreva a seção com "nenhuma". O orquestrador entrega essa lista ao `architect`
como entrada direta da emenda (`/sdd-amend`, passo 1c), sem reescrevê-la (issue #740,
`asengardeon/btt-sdd-pipeline`).
