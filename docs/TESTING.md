# Testes: TDD, pirâmide de testes e o gate de cobertura de 80%

## TDD (red-green-refactor)

Todo código de produção neste repositório nasce assim:

1. **Red** — escreva o teste que expressa o comportamento esperado. Rode e confirme que ele
   falha (se passar de primeira, ou o teste está errado, ou o comportamento já existia).
2. **Green** — escreva o mínimo de código de produção necessário para o teste passar. Não
   adiante implementação de comportamento que ainda não tem teste.
3. **Refactor** — com os testes verdes como rede de segurança, elimine duplicação, melhore nomes,
   simplifique — sem mudar comportamento observável.

Isso é responsabilidade do agente `senior-developer` (`.claude/agents/senior-developer.md`) em
todo `/sdd-implement`.

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
  repositório que fala com um banco de verdade, ainda que em container de teste) contra o
  contrato que o port promete.
- **E2E** (`tests/e2e/`): testam o fluxo completo através de um adapter de entrada real (CLI,
  HTTP), exercitando o caminho ponta a ponta que o usuário realmente percorre.

## O gate de cobertura de 80%

- Aplicado automaticamente no CI (`.github/workflows/ci.yml`): o job de testes falha o pipeline
  se a cobertura ficar abaixo de 80%.
- Verificado manualmente pelo agente `qa-engineer` antes de qualquer aprovação
  (`.claude/agents/qa-engineer.md`).
- 80% é um **piso**, não uma meta a maximizar às custas de testes triviais/sem valor (ex.: testar
  um getter que só retorna um atributo). Cobertura alta com testes fracos é pior que cobertura no
  limite com testes que realmente verificam comportamento — o QA verifica isso lendo os testes,
  não só o número.
- Se um trecho de código é genuinamente difícil de cobrir, isso é tratado como **sinal de
  design**: normalmente significa que uma responsabilidade de infraestrutura vazou para dentro do
  domínio/aplicação, ou que um caso de uso está fazendo coisa demais. A correção correta costuma
  ser revisar o TRD com o `architect`, não forçar um teste artificial.

## Comando de referência (exemplo Python deste repositório)

O exemplo em `src/`/`tests/` usa `pytest` + `coverage`:

```bash
pytest --cov=src --cov-report=term-missing --cov-fail-under=80
```

Configuração em `pyproject.toml`. Ao adotar outra stack, troque este comando e o job
correspondente em `.github/workflows/ci.yml` — o gate de 80% e a estrutura de pastas de teste
continuam os mesmos independente da linguagem.
