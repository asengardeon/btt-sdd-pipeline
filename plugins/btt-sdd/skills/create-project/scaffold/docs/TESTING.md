# Testes: TDD, pirâmide de testes e o gate de cobertura de 80%

## TDD (red-green-refactor)

Todo código de produção neste repositório nasce assim:

1. **Red** — escreva o teste que expressa o comportamento esperado. Rode e confirme que ele
   falha (se passar de primeira, ou o teste está errado, ou o comportamento já existia).
2. **Green** — escreva o mínimo de código de produção necessário para o teste passar. Não
   adiante implementação de comportamento que ainda não tem teste.
3. **Refactor** — com os testes verdes como rede de segurança, elimine duplicação, melhore nomes,
   simplifique — sem mudar comportamento observável.

Isso é responsabilidade de `backend-developer` (`.claude/agents/backend-developer.md`) e, quando a
feature tem UI, `frontend-developer` (`.claude/agents/frontend-developer.md`), em todo
`/sdd-implement`.

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
  dublês dos ports. Rápidos, determinísticos, sem rede/disco/banco real.
- **Integração** (`tests/integration/`): testam uma implementação real de um port (ex.: um
  repositório que fala com um banco de verdade, ainda que em container de teste) contra o
  contrato que o port promete.
- **E2E** (`tests/e2e/`): testam o fluxo completo através de um adapter de entrada real (CLI,
  HTTP), exercitando o caminho ponta a ponta que o usuário realmente percorre.

## Frontend (quando aplicável)

Mesmo TDD, mesma pirâmide, mapeados em `frontend/tests/` — componentes/serviços testados com um
dublê do contrato de API (`docs/ARCHITECTURE.md`, seção Frontend) no lugar de rede real. Sem
camada de e2e "de verdade" cross-stack obrigatória por padrão; se a feature justificar, um e2e
que sobe backend+frontend juntos é uma decisão do `architect` a registrar no TRD.

## O gate de cobertura de 80%

- **Por pacote**: `src/` e, se existir, `frontend/` têm cada um seu próprio gate de 80% — não é
  uma média combinada. Um pacote não pode compensar a cobertura baixa do outro.
- Aplicado automaticamente no CI (`.github/workflows/ci.yml`, criado pelo `sre` junto com a
  primeira feature implementada): o job de testes falha o pipeline se a cobertura de qualquer
  pacote ficar abaixo de 80%.
- Verificado manualmente pelo agente `qa-engineer` antes de qualquer aprovação.
- 80% é um **piso**, não uma meta a maximizar às custas de testes triviais/sem valor. Cobertura
  alta com testes fracos é pior que cobertura no limite com testes que realmente verificam
  comportamento — o QA verifica isso lendo os testes, não só o número.
- Se um trecho de código é genuinamente difícil de cobrir, isso é tratado como **sinal de
  design**: normalmente significa que uma responsabilidade de infraestrutura vazou para dentro do
  domínio/aplicação. A correção correta costuma ser revisar o TRD com o `architect`, não forçar
  um teste artificial.

## Reaproveitamento do artefato de cobertura entre etapas

Rodar a suíte completa com cobertura é caro (tempo e, quando uma sessão do Claude Code lê o
resultado, tokens). Ela só precisa rodar **uma vez por commit**, não uma vez por etapa do
pipeline:

- `backend-developer`/`frontend-developer` rodam a suíte completa com cobertura ao final da
  trilha (`.claude/agents/backend-developer.md`, `.claude/agents/frontend-developer.md`) e gravam
  o resultado em `specs/<slug>/coverage/<fatia>-<trilha>.md`, a partir de
  `specs/_template/coverage-summary.template.md`, com o commit SHA do momento da execução.
- Qualquer etapa seguinte que precise de evidência de teste/cobertura (hoje, principalmente o
  `qa-engineer`) **lê esse arquivo em vez de rodar a suíte de novo**, desde que o campo `Commit`
  nele bata com o HEAD atual da branch do PR (`git rev-parse HEAD`). Isso é o próprio sinal de que
  nada mudou desde a geração — a suíte completa já rodou contra exatamente esse código.
- Se o arquivo não existe, ou o `Commit` gravado é diferente do HEAD atual (alguém commitou depois
  — ex.: uma correção em resposta a um achado de code review), quem precisa da evidência roda a
  suíte completa com cobertura e **regrava o arquivo** com o novo commit — para que a etapa
  seguinte também possa reaproveitar, em vez de cada etapa refazer a mesma checagem de novo.
- Isso não substitui os testes tocados por incremento durante o TDD (rápidos, parciais, rodados a
  cada red-green-refactor) — só evita repetir a rodada completa final entre backend/frontend-
  developer, `qa-engineer`, e qualquer etapa futura que também precise da evidência.

**Nunca use o relatório bruto (HTML, especialmente) como fonte para preencher o resumo, e nunca
cole o relatório bruto inteiro no artefato.** Gere o relatório num formato legível por máquina que
a stack em uso ofereça (`term-missing`, XML, JSON, `lcov.info` — o que o comando de teste já
produzir) e extraia dali só os números agregados por pacote e, quando abaixo do gate de 80%, a
lista de arquivos/linhas não cobertas em faixas compactas (`42-47, 63`), nunca uma lista
linha-a-linha de arquivo já coberto. Um relatório HTML custa muito mais para ler/parsear (visual,
verboso, pensado para navegador) do que o texto/XML/JSON que a mesma ferramenta já gera junto —
prefira sempre a saída estruturada.

## Comando de referência

Este projeto ainda não tem stack definida — o comando exato de teste/cobertura (`pytest`,
`jest`, `go test`, etc.) é decidido pelo `architect` no primeiro TRD e documentado aqui pelo
`backend-developer`/`frontend-developer` quando o projeto ganhar sua primeira implementação. A
estrutura de pastas de teste e o gate de 80% continuam os mesmos independente da linguagem.
