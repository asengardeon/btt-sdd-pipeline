# Resumo de cobertura — <slug> / <fatia> / <trilha>

> Gerado por: `<backend-developer|frontend-developer|qa-engineer>`
> Branch: `<nome-da-branch>`
> Commit: `<sha completo do HEAD no momento da execução>`
> Gerado em: `<data/hora>`
> Comando executado: `<comando de lint + teste/cobertura da stack em uso>`

Este arquivo é a **evidência condensada** de uma execução real da suíte completa com cobertura —
não um relatório bruto (nunca cole aqui o HTML/XML/JSON original, nem um dump linha-a-linha de
arquivo 100% coberto). Extraia só o que muda uma decisão de aprovação: números agregados e as
lacunas abaixo do gate. Qualquer etapa seguinte que precise desta evidência **lê este arquivo em
vez de rodar a suíte de novo**, contanto que o campo `Commit` acima seja igual ao HEAD atual da
branch (ver `TESTING.md` do pipeline, seção "Reaproveitamento do artefato de cobertura entre etapas"). Se
divergir, quem precisar da evidência roda a suíte e regrava este arquivo — nunca segue com um
número desatualizado.

## Resultado da suíte

| Métrica              | Resultado |
|-----------------------|-----------|
| Testes                | `<N passaram, M falharam, K pulados>` |
| Lint                  | `<sem erros / N erros>` |
| Build/empacotamento   | `<sucesso / falhou — comando: <comando real de build/produção da stack, docs/STACK.md> | "não aplicável — trilha sem artefato de build/empacotamento próprio">` |

## Cobertura agregada (por pacote)

| Pacote     | Linhas | Branches | Gate | Status |
|------------|--------|----------|------|--------|
| `<src/ ou frontend/>` | `__%` | `__%` | 80% | ✅/❌ |

## Lacunas (só arquivos abaixo de 80%, ou com trecho relevante não coberto)

Omita esta seção (ou deixe "nenhuma") quando todo arquivo tocado está ≥ 80% — não liste arquivo já
coberto só para ser exaustivo.

| Arquivo | Cobertura | Linhas não cobertas |
|---------|-----------|----------------------|
| `<caminho/arquivo>` | `__%` | `<ex.: 42-47, 63>` |

## Observações

`<qualquer nota curta que mude a leitura do número acima — ex.: "trecho não coberto é código morto
sinalizado no code review", "falha intermitente confirmada em 3 execuções">` — ou "nenhuma".
