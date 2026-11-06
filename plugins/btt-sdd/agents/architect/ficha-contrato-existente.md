# Ficha de contrato existente por alvo (spec de migração ou paridade)

Gatilho: `Tipo de spec: migração/paridade` no cabeçalho do PRD, ou o argumento `--paridade` em
`/btt-sdd:trd`. Vale para spec que reescreve, move ou substitui algo que já existe e pede paridade
funcional. Em outra spec, não crie o arquivo.

Crie `trd/existing-contract.md` (a partir de `specs/_template/trd/existing-contract.template.md`)
e adicione a linha dele na tabela "Arquivos deste TRD" do `INDEX.md`. Uma ficha por **alvo** (tela,
endpoint, comando, job) listado no PRD, com estes campos:

| Campo | Conteúdo |
|---|---|
| Interface de entrada e saída | endpoints e verbos, formato de entrada e de saída |
| Autorização | o que a interface exige e se bate com o que o cliente atual usa |
| Regras de negócio | validações e invariantes, inclusive valores fixos no código |
| Efeitos colaterais | leituras que gravam, eventos publicados, integrações externas |
| Cliente atual | o que ele chama, destino após a ação, rotas e parâmetros adicionais |
| Testes existentes | quais, ou "nenhum" |

## Evidência

Marque cada linha `[medido]` (lido no arquivo, com o caminho), `[inferido]` ou `[não medido]`.
`[medido]` vale para o que o arquivo declara e você leu (rota, verbo, valor fixo, ausência de teste).
Comportamento em execução deduzido da leitura do código, sem rodar, é `[inferido]`; o que você não
viu em lugar nenhum é `[não medido]`. Todo `[não medido]` vem com o teste barato que o resolve. Ler
código aponta onde medir; não prova comportamento em execução.

## Alvo sem teste

A **primeira tarefa** do alvo na decomposição é um **teste de caracterização**: fixa o
comportamento atual, só adiciona teste e não altera o sistema. A tarefa de implementação do alvo
depende dela. Sem oráculo, a paridade não se prova.

## Muitos alvos

O levantamento pode ser feito em paralelo por grupo de alvos, com sub-tarefas isoladas que
devolvem só as fichas (`docs/MODEL-TIERING.md`); você consolida em `existing-contract.md`.
