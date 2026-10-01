# Testes: TDD, pirâmide de testes e o gate de cobertura de 80%

## TDD (red-green-refactor)

Todo código de produção neste repositório nasce assim:

1. **Red** — escreva o teste que expressa o comportamento esperado. Rode e confirme que ele falha
  (se passar de primeira, ou o teste está errado, ou o comportamento já existia).
2. **Green** — escreva o mínimo de código de produção necessário para o teste passar. Não adiante
  implementação de comportamento que ainda não tem teste.
3. **Refactor** — com os testes verdes como rede de segurança, elimine duplicação, melhore nomes,
  simplifique — sem mudar comportamento observável.

Isso é responsabilidade de `backend-developer` (`agents/backend-developer.md`) e, quando a feature
tem UI, `frontend-developer` (`agents/frontend-developer.md`), em todo `/btt-sdd:implement`.

## Pirâmide de testes mapeada em ports & adapters

```
        ▲
       /e2e\        poucos — fluxo completo por um adapter de entrada real
      /------\
     /integr. \     médios — adapter de saída contra dependência real/containerizada
    /----------\
   /   unit     \   muitos — domain e application, com dublês (fakes/stubs) dos ports
  /--------------\
```

- **Unitários** (`tests/unit/`): testam `domain` e `application/use_cases` isoladamente, usando
  implementações fake dos ports (ex.: um repositório em memória feito só para teste, ou uma
  implementação real simples como `InMemoryTaskRepository` quando ela já serve ao propósito).
  Rápidos, determinísticos, sem rede/disco/banco real.
- **Integração** (`tests/integration/`): testam uma implementação real de um port (ex.: um
  repositório que fala com um banco de verdade, ainda que em container de teste) contra o contrato
  que o port promete. Quando o adapter fala com um serviço gerenciado de nuvem (AWS S3/
  DynamoDB/SQS, Azure Blob Storage, GCP Cloud Storage, OCI Object Storage), a dependência
  "containerizada" é [floci](https://floci.io) (ver `docs/STACK.md`, seção "Simulação de nuvem
  local") — nunca a conta real de nuvem, nem um mock do SDK que não valida o comportamento real do
  serviço.

### Simulação de nuvem em testes de integração (floci)

```bash
# sobe o emulador AWS localmente (porta 4566) e aponta o SDK para ele
docker run -d --rm -p 4566:4566 floci/floci:latest
export AWS_ENDPOINT_URL=http://localhost:4566   # ou variável equivalente do SDK da stack em uso

# roda só os testes de integração que dependem do serviço de nuvem
pytest tests/integration -k s3   # exemplo — adapte ao serviço/stack real
```

Em CI (`.github/workflows/ci.yml`), floci sobe como um serviço efêmero do próprio job — nunca como
dependência externa de rede. Em produção, o mesmo port é implementado pelo adapter real contra o
provedor de nuvem de verdade; a troca é só a implementação injetada (Liskov,
`docs/ARCHITECTURE.md`), nunca uma checagem de ambiente dentro do caso de uso.
- **E2E** (`tests/e2e/`): testam o fluxo completo através de um adapter de entrada real (CLI, HTTP),
  exercitando o caminho ponta a ponta que o usuário realmente percorre.

## Frontend (quando aplicável)

Mesmo TDD, mesma pirâmide, mapeados em `frontend/tests/` — componentes/serviços testados com um
dublê do contrato de API (`docs/ARCHITECTURE.md`, seção Frontend) no lugar de rede real. Sem camada
de e2e "de verdade" cross-stack obrigatória por padrão; se a feature justificar, um e2e que sobe
backend+frontend juntos é uma decisão do `architect` a registrar no TRD (seção "Plano de testes").

**"E2E do fluxo humano" sem harness de browser real contra backend real.** Se este projeto não tem
uma suíte de e2e de browser disponível contra um backend real (nenhum harness documentado aqui ou em
`docs/STACK.md`), uma tarefa de TRD descrita como "e2e do fluxo humano" não pode presumir
implicitamente esse tipo de suíte — o `architect` (`agents/architect.md`, seção "Plano de testes de
alto nível") já especifica o mecanismo de verificação alternativo esperado (ex.: um teste de
integração HTTP encadeando os endpoints reais envolvidos, sem dublê, como prova do fluxo)
diretamente na tarefa, em vez de deixar para quem implementa decidir ou perguntar no meio da fatia.

### Armadilha conhecida: `testPathIgnorePatterns` do Jest com `<rootDir>` e path com segmento iniciado por ponto

Se o TRD decidir Jest como test runner do frontend (`docs/STACK.md`), evite usar `<rootDir>` como
prefixo literal em padrões regex de exclusão de path (`testPathIgnorePatterns`,
`modulePathIgnorePatterns`) — ex. `['<rootDir>/e2e/']` ou a variante com classe de caractere
agnóstica de SO (`'<rootDir>[\/]e2e[\/]'`). No Windows, quando o caminho absoluto de `rootDir`
contém um segmento de diretório iniciado por ponto logo após um separador (ex.:
`.claude/worktrees/<id>/...`, a convenção deste pipeline para isolamento de working tree entre
agentes concorrentes — `docs/GIT-WORKFLOW.md`), a função que o `jest-config` usa para normalizar
esses padrões como regex mal-escapa o separador que antecede esse segmento, quebrando o casamento do
restante do caminho — o arquivo que deveria estar excluído é carregado mesmo assim, **falha
silenciosa** (sem erro, sem warning). Não reproduz em Linux (onde o CI normalmente roda), então
passa despercebido no CI e só quebra localmente para devs Windows e para agentes de revisão deste
pipeline rodando isolados em `.claude/worktrees/<id>`.

Prefira casar só o nome do segmento de diretório, em qualquer posição do caminho, sem `<rootDir>`
como prefixo:

```js
testPathIgnorePatterns: ['[\/]\.next[\/]', '[\/]node_modules[\/]', '[\/]e2e[\/]'],
```

(sem caminho absoluto literal na entrada, não há o que a normalização interna do Jest
mal-interprete). Achado real, levou 3 rodadas de QA para diagnosticar numa sessão anterior — ver
issue de origem para o diagnóstico completo com scripts de reprodução.

## Preferência por Docker/emuladores locais em vez de produção real

Todo teste automatizado que depende de infraestrutura (banco, filas, storage, serviço de nuvem
gerenciado) ou de navegação (e2e via browser automation) roda, sempre que possível, contra
Docker/emuladores locais — nunca contra o ambiente de produção real:

- **Serviço de nuvem gerenciado** (S3, filas, etc.): emulador local (`docs/STACK.md`, seção
  "Simulação de nuvem local") — nunca a conta real de produção.
- **Banco/filas/dependências próprias do projeto**: container de teste (`docker-compose.yml`,
  `infra/docker/`, `agents/sre.md`, seção "Docker de desenvolvimento local") — nunca o banco de
  produção.
- **Testes de navegação** (e2e via browser automation): sobem a aplicação localmente (Docker ou
  equivalente) e navegam contra esse ambiente controlado — nunca contra a URL de produção real, o
  que arrisca poluir dados reais e torna o resultado do teste dependente de rede/disponibilidade
  externa.

Produção real é reservada para o **teste geral obrigatório ao final de cada spec**
(`docs/POST-MERGE-VALIDATION.md`) e para validações pontuais que genuinamente não podem ser
simuladas (ex.: confirmar que um add-on de terceiro foi provisionado de verdade, DNS propagou) —
nunca para a suíte automatizada do dia a dia. Se um teste "precisa" de produção para passar de forma
repetível, isso é sinal de que falta um emulador/container equivalente, não motivo para apontar o
teste para produção.

## Fidelidade do dublê derivado de captura real: página inteira e locator estrito

Um mock construído a partir de uma captura do sistema real (DOM de uma página, resposta de uma API,
layout de arquivo) só é evidência válida **para o que a captura inclui**. Duas regras, as duas vindas
do mesmo incidente real:

- **A captura inclui a página/resposta inteira, não só o fragmento de interesse.** Capturar apenas o
  formulário (ou apenas o objeto que importa) produz um dublê onde o elemento procurado é único **por
  construção** — e um teste verde contra ele não disse nada sobre o sistema real, onde o mesmo seletor
  pode casar com mais de um elemento.
- **Teste que exercita clique/interação usa a API estrita de locator** — a que **falha** quando o
  seletor casa com mais de um elemento —, nunca o atalho que resolve para "o primeiro que casar"
  (ex.: `page.click("<seletor>")`). Com a API não estrita, ambiguidade de seletor nunca vira erro:
  vira **interação silenciosa no elemento errado**, que é indistinguível de falha transitória.

Já aconteceu de verdade, e passou por **seis specs**: `form button[type='submit']` casava com **2**
elementos na página real — o primeiro era a lupa de busca do cabeçalho do site, dentro de outro
`<form>` —, e a automação nunca clicou no botão da feature. Nenhuma submissão jamais aconteceu, e o
desfecho sempre parecia um erro transitório genérico, retentado 5 vezes. O dublê vinha de uma captura
só do fragmento do formulário, sem o cabeçalho do site; ali havia um único `<form>`, então o seletor
era inequívoco. **O dado que fecha o argumento**: quando o dublê passou a servir a vizinhança do site
por padrão, os testes de caminho feliz **que já existiam** passaram a falhar contra o código antigo,
com a mensagem literal dos logs de produção — a suíte que já existia teria pego o defeito desde
sempre, se o dublê tivesse a mesma ambiguidade do sistema real.

Corolário, válido além de DOM: captura de fragmento ⟹ o dublê não pode decidir ambiguidade de
seletor ⟹ a interação precisa ser por locator estrito, para que ambiguidade vire falha alta em vez
de silêncio.

## O gate de cobertura de 80%

- **Por pacote**: `src/` e, se existir, `frontend/` têm cada um seu próprio gate de 80% — não é uma
  média combinada. Um pacote não pode compensar a cobertura baixa do outro.
- Aplicado automaticamente no CI (`.github/workflows/ci.yml`, criado pelo `sre` junto com a
  primeira feature implementada): o job de testes falha o pipeline se a
  cobertura de qualquer pacote ficar abaixo de 80%.
- Verificado manualmente pelo agente `qa-engineer` antes de qualquer aprovação
  (`agents/qa-engineer.md`).
- 80% é um **piso**, não uma meta a maximizar às custas de testes triviais/sem valor (ex.: testar um
  getter que só retorna um atributo). Cobertura alta com testes fracos é pior que cobertura no
  limite com testes que realmente verificam comportamento — o QA verifica isso lendo os testes, não
  só o número.
- Se um trecho de código é genuinamente difícil de cobrir, isso é tratado como **sinal de design**:
  normalmente significa que uma responsabilidade de infraestrutura vazou para dentro do
  domínio/aplicação, ou que um caso de uso está fazendo coisa demais. A correção correta costuma ser
  revisar o TRD com o `architect`, não forçar um teste artificial.

## Instabilidade de teste: classe da asserção, não constante de tempo

**Ajustar a constante de tempo de uma asserção instável não é correção — é adiamento.** Já foi
medido ao vivo: a mesma asserção, com a constante **20× maior**, caiu no primeiro CI sob contenção.
As duas correções legítimas são:

1. **Relocar** a asserção para o nível em que ela não depende de tempo — tipicamente o unitário, com
   dublê no lugar do recurso real.
2. Quando ela precisa mesmo rodar contra o recurso real, **trocar a dependência de relógio por um
   sinal explícito controlado pelo teste**: o teste libera o passo, em vez de torcer para ele caber
   numa janela.

**Classifique antes de contar.** Ao registrar uma ocorrência de instabilidade (em
`docs/LESSONS-LEARNED.md` ou num artefato de revisão), diga de qual população ela é:

- **(a) Contenção** — há **timeout no rastro**. Não é corrigível por reescrita do teste; é ambiente.
- **(b) Asserção presa a relógio** — **falha de asserção, sem timeout**: `Assert.Equal`/`Assert.Single`
  sobre valor que depende de quanto tempo algo levou (contagem de tentativas via navegador, coleção
  produzida por *debounce*, janela de atraso). **Corrigível**, e comprovadamente.

Um contador que soma as duas faz a instabilidade parecer intratável e desencoraja a correção da
metade que tem conserto: numa entrada real com 27 ocorrências, **cerca de um terço** era (b). A
assinatura de (b) é fácil de perder — várias ocorrências se manifestaram como falha de contagem de
tentativas, e procurar só por "timeout" no rastro deixa a ocorrência passar.

**Asserção sobre valor derivado de tempo nasce no nível unitário.** Contagem de tentativas, tamanho
de coleção produzida por *debounce*, ordem observada por janela — o custo medido da alternativa é
claro: 22 testes unitários novos custaram **0 s** de suíte (490 ms contra 492 ms, dentro do ruído),
enquanto 18 de integração custaram **36 s**. 316 testes unitários rodam em 451 ms, determinísticos.

## Reaproveitamento do artefato de cobertura entre etapas

Rodar a suíte completa com cobertura é caro (tempo e, quando uma sessão do Claude Code lê o
resultado, tokens). Ela só precisa rodar **uma vez por commit**, não uma vez por etapa do pipeline:

- `backend-developer`/`frontend-developer` rodam a suíte completa com cobertura ao final da trilha
  (`agents/backend-developer.md`, `agents/frontend-developer.md`) e gravam o resultado em
  `specs/<slug>/coverage/<fatia>-<trilha>.md`, a partir de
  `specs/_template/coverage-summary.template.md`, com o commit SHA do momento da execução.
- Qualquer etapa seguinte que precise de evidência de teste/cobertura (hoje, principalmente o
  `qa-engineer`) **lê esse arquivo em vez de rodar a suíte de novo**, desde que o campo `Commit`
  nele bata com o **commit mais recente que tocou `src/`/`frontend/` na branch do PR** (`git log -1
  --format=%H -- src/ frontend/`) — **nunca o HEAD literal da branch** (`git rev-parse HEAD`). Como
  cada etapa do pipeline (`code-review` → `qa` → `security` → `sre`) commita seu próprio relatório
  em Markdown antes da etapa seguinte rodar, o HEAD sempre avança por um commit docs-only entre uma
  verificação de frescor e a próxima — comparar contra o HEAD literal nunca bate a partir da segunda
  etapa de revisão em diante, forçando reexecução completa da suíte mesmo quando nenhum código
  mudou. Comparar contra o último commit que efetivamente tocou código é o sinal correto de que nada
  mudou desde a geração — a suíte completa já rodou contra exatamente esse código.
- Se o arquivo não existe, ou o `Commit` gravado é diferente desse último commit que tocou
  `src/`/`frontend/` (alguém commitou uma mudança de código depois — ex.: uma correção em resposta a
  um achado de code review), quem precisa da evidência roda a suíte completa com cobertura e
  **regrava o arquivo** com o novo commit — para que a etapa seguinte também possa reaproveitar, em
  vez de cada etapa refazer a mesma checagem de novo.
- Isso não substitui os testes tocados por incremento durante o TDD (rápidos, parciais, rodados a
  cada red-green-refactor) — só evita repetir a rodada completa final entre backend/frontend-
  developer, `qa-engineer`, e qualquer etapa futura que também precise da evidência.
- **Uma rodada de correção de achado cujo diff não toca `src/`/`frontend/`** (só acrescenta casos de
  teste, só ajusta doc/comentário) não move esse último commit que tocou código — a suíte completa
  já rodou contra exatamente o código que continua lá. Nesse caso a validação local pode ser
  escopada aos módulos afetados, com o **CI do PR verde no commit final** como gate real, desde que
  a rodada declare no relatório o que rodou localmente e o que foi delegado ao CI
  (`skills/implement/SKILL.md`, seção "Retomando para corrigir achados de revisão", passo 3a).
  Correção que toca comportamento de produção não entra nessa exceção: ali a suíte completa local
  continua obrigatória, e o `Commit` do artefato de cobertura precisa ser regravado.

**Nunca use o relatório bruto (HTML, especialmente) como fonte para preencher o resumo, e nunca cole
o relatório bruto inteiro no artefato.** Gere o relatório num formato legível por máquina que a
stack em uso ofereça (`term-missing`, XML, JSON, `lcov.info` — o que o comando de teste já produzir)
e extraia dali só os números agregados por pacote e, quando abaixo do gate de 80%, a lista de
arquivos/linhas não cobertas em faixas compactas (`42-47, 63`), nunca uma lista linha-a-linha de
arquivo já coberto. Um relatório HTML custa muito mais para ler/parsear (visual, verboso, pensado
para navegador) do que o texto/XML/JSON que a mesma ferramenta já gera junto — prefira sempre a
saída estruturada.

## Build/empacotamento real como parte da suíte completa (quando há trilha de frontend/artefato de build)

Lint, checagem de tipos e teste automatizado não são a suíte completa quando a fatia tem uma trilha
que produz um **artefato de build/empacotamento real** (frontend compilado, pacote distribuível,
imagem — o que a stack decidida no TRD/`docs/STACK.md` gerar para produção). Já aconteceu de um
defeito passar por duas rodadas de `code-reviewer` e duas de `qa-engineer` — só lint/tipo/teste
unitário rodaram — e só ser pego depois pelo `sre`, várias execuções de CI adiante, porque nenhuma
das etapas anteriores reproduziu o **comando de build/empacotamento real** da stack em uso.

- **O que roda**: o comando que reproduz o artefato de build/produção real desta stack — não um
  "modo dev"/watch, não só `tsc --noEmit`/checagem de tipos isolada. Qual comando é esse nunca é
  hardcoded neste template — é o que `docs/STACK.md` do projeto documentar como comando de
  build/empacotamento de produção (definido pelo `architect` ao decidir a stack, mesma lógica do
  comando de teste/cobertura acima).
- **Quando é obrigatório**: toda fatia cuja trilha inclui frontend, ou qualquer trilha que gera um
  artefato de build/empacotamento distinto do código-fonte (não é o caso de uma trilha backend-only
  sem etapa de build/empacotamento própria além dos testes).
- **Quem roda e onde fica registrado**: `backend-developer`/`frontend-developer` rodam esse comando
  junto da suíte completa ao final da trilha (mesmo momento da seção acima) e registram o resultado
  em `specs/<slug>/coverage/<fatia>-<trilha>.md` (campo "Build/empacotamento" do template) —
  evidência reaproveitada por `code-reviewer`/`qa-engineer` do mesmo jeito que a cobertura, contanto
  que o `Commit` gravado bata com o HEAD atual da branch. Se o arquivo não existe, ou o commit está
  desatualizado, quem precisar da evidência (`code-reviewer`/ `qa-engineer`) roda o comando de
  build/empacotamento você mesmo antes de aprovar — nunca aprova uma fatia com trilha de
  frontend/build sem essa evidência (atual ou reexecutada).
- **Isso é definição do agente, não depende de lições aprendidas.** `docs/gates/implementacao.md`, `docs/gates/code-review.md` e `docs/gates/qa.md` e `agents/code-reviewer.md`/ `agents/qa-engineer.md`
  já exigem isso diretamente — não fica condicionado a `docs/LESSONS-LEARNED.md` ter uma entrada
  sobre o assunto numa sessão futura.

## Comando de referência

Este projeto ainda não tem stack definida — o comando exato de teste/cobertura (`pytest`,
`jest`, `go test`, etc.) é decidido pelo `architect` no primeiro TRD e documentado aqui pelo
`backend-developer`/`frontend-developer` quando o projeto ganhar sua primeira implementação. A
estrutura de pastas de teste e o gate de 80% continuam os mesmos independente da linguagem.
