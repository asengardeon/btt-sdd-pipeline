# Asseverar sobre o CSS publicado do build, não sobre o fonte

Gatilho: a fatia depende de uma classe de CSS utilitário para uma garantia observável
(visibilidade, presença na árvore de acessibilidade, geometria) — passo 2b-bis do Processo.

Procure a regra pelo nome da classe nos arquivos de CSS que o build produziu (presença quando a
garantia depende dela existir, **ausência** quando depende de ela ter sido removida). O fonte não
decide o que existe em produção: o extrator de utilitário varre o arquivo **inteiro, comentários
incluídos**, então citar o nome literal de uma classe antiga no comentário que explica a mudança
**mantém a regra morta dela no CSS de produção** — e, do outro lado, uma classe que o código
escreve pode não gerar regra nenhuma.

Já aconteceu de verdade, nas duas direções, na mesma fatia: `empty:hidden` apareceu com contagem
**0** nos dois arquivos de CSS do build, enquanto quatro artefatos afirmavam a garantia que ela
deveria dar e a suíte ficava verde; e um comentário citando a classe antiga preservou a regra que
a mudança existia para eliminar.

A contrapartida do outro lado é do `ux-designer` (`agents/ux-designer.md`): em jsdom, compilar e
injetar a regra antes de consultar.
