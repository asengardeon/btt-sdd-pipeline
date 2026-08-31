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

## Preferência por Docker/emuladores locais em vez de produção real

Todo teste automatizado que depende de infraestrutura (banco, filas, storage, serviço de nuvem
gerenciado) ou de navegação (e2e via browser automation) roda, sempre que possível, contra
Docker/emuladores locais — nunca contra o ambiente de produção real:

- **Serviço de nuvem gerenciado** (S3, filas, etc.): emulador local (`docs/STACK.md`, seção
  "Simulação de nuvem local") — nunca a conta real de produção.
- **Banco/filas/dependências próprias do projeto**: container de teste (`docker-compose.yml`,
  `infra/docker/`, `.claude/agents/sre.md`, seção "Docker de desenvolvimento local") — nunca o
  banco de produção.
- **Testes de navegação** (e2e via browser automation): sobem a aplicação localmente (Docker ou
  equivalente) e navegam contra esse ambiente controlado — nunca contra a URL de produção real, o
  que arrisca poluir dados reais e torna o resultado do teste dependente de rede/disponibilidade
  externa.

Produção real é reservada para o **teste geral obrigatório ao final de cada spec**
(`docs/POST-MERGE-VALIDATION.md`) e para validações pontuais que genuinamente não podem ser
simuladas (ex.: confirmar que um add-on de terceiro foi provisionado de verdade, DNS propagou) —
nunca para a suíte automatizada do dia a dia. Se um teste "precisa" de produção para passar de
forma repetível, isso é sinal de que falta um emulador/container equivalente, não motivo para
apontar o teste para produção.

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

## Comando de referência

Este projeto ainda não tem stack definida — o comando exato de teste/cobertura (`pytest`,
`jest`, `go test`, etc.) é decidido pelo `architect` no primeiro TRD e documentado aqui pelo
`backend-developer`/`frontend-developer` quando o projeto ganhar sua primeira implementação. A
estrutura de pastas de teste e o gate de 80% continuam os mesmos independente da linguagem.
