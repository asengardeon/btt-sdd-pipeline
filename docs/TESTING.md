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
  implementações fake dos ports (ex.: um repositório em memória feito só para teste, ou uma
  implementação real simples como `InMemoryTaskRepository` quando ela já serve ao propósito).
  Rápidos, determinísticos, sem rede/disco/banco real.
- **Integração** (`tests/integration/`): testam uma implementação real de um port (ex.: um
  repositório que fala com um banco de verdade, ainda que em container de teste) contra o
  contrato que o port promete. Quando o adapter fala com um serviço gerenciado de nuvem (AWS S3/
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
- **E2E** (`tests/e2e/`): testam o fluxo completo através de um adapter de entrada real (CLI,
  HTTP), exercitando o caminho ponta a ponta que o usuário realmente percorre.

## Frontend (quando aplicável)

Mesmo TDD, mesma pirâmide, mapeados em `frontend/tests/` — componentes/serviços testados com um
dublê do contrato de API (`docs/ARCHITECTURE.md`, seção Frontend) no lugar de rede real. Sem
camada de e2e "de verdade" cross-stack obrigatória por padrão; se a feature justificar, um e2e
que sobe backend+frontend juntos é uma decisão do `architect` a registrar no TRD (seção "Plano de
testes").

## O gate de cobertura de 80%

- **Por pacote**: `src/` e, se existir, `frontend/` têm cada um seu próprio gate de 80% — não é
  uma média combinada. Um pacote não pode compensar a cobertura baixa do outro.
- Aplicado automaticamente no CI (`.github/workflows/ci.yml`): o job de testes falha o pipeline
  se a cobertura de qualquer pacote ficar abaixo de 80%.
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

O exemplo em `src/`/`tests/` é backend-only (sem `frontend/`) e usa `pytest` + `coverage`:

```bash
pytest --cov=src --cov-report=term-missing --cov-fail-under=80
```

Configuração em `pyproject.toml`. Ao adotar outra stack, troque este comando e o job
correspondente em `.github/workflows/ci.yml` — o gate de 80% e a estrutura de pastas de teste
continuam os mesmos independente da linguagem.
