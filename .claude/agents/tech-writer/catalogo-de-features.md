# `docs/FEATURES.md`: catálogo de comportamento e features da aplicação

Gatilho: o usuário pede documentação do que a aplicação **faz** — comportamento observável,
features implementadas, "o que o sistema sabe fazer hoje" — não documentação de processo do
pipeline (isso é `docs/DOCS-MAP.md`, `tech-writer/mapa-de-documentacao.md`) nem documentação de
arquitetura interna (isso é ADR/`docs/ARCHITECTURE.md`).

## Diferença de público: isto é documentação de produto, não de processo

`docs/FEATURES.md` é escrito para quem usa ou integra com a aplicação — nunca assuma que quem lê
já conhece PRD, TRD, ou qualquer terminologia interna do pipeline SDD. Descreva comportamento em
linguagem de usuário/sistema ("ao criar uma tarefa com título vazio, o sistema rejeita a
operação e retorna um erro claro"), não em linguagem de processo ("US-1 tem veredito ✅ no
qa-report"). O critério de aceite do PRD é a **fonte**, não o **texto final** — traduza, não
copie a tabela de critérios verbatim.

## Estrutura exata do arquivo

```markdown
# Features e comportamentos — <nome do projeto>

Catálogo do que a aplicação faz de verdade, derivado das histórias de usuário de cada PRD e dos
casos de uso de cada TRD, **conferido contra o código real** (nunca copiado do PRD/TRD sem
verificação — um critério de aceite aprovado em QA é starting point, não prova de
implementação atual: código muda depois do QA aprovar uma fatia). Gerado/atualizado por
`tech-writer` (`/sdd-docs`).

Atualizado em: <AAAA-MM-DD>

## <Nome da feature> (`specs/<slug>/`)

### <Nome do comportamento/capacidade, em linguagem de produto>

<Parágrafo em prosa: o que o usuário/sistema faz, em que condição, o que acontece em caso de
erro/borda relevante — não uma lista telegráfica de critérios de aceite.>

| Status | Evidência |
|---|---|
| Implementado / Parcial / Planejado (sem código ainda) | `<arquivo de teste ou código que confirma>` |

<Repita a subseção "Nome do comportamento" para cada agrupamento coerente de critérios de
aceite da mesma feature — não necessariamente um por US; critérios relacionados (ex.: "criar
tarefa" + "rejeitar título vazio" + "rejeitar título duplicado") formam um comportamento só.>
```

## Processo de geração

1. **Para cada spec em `specs/*/`** (exclua `_template`) que tenha `prd.md` aprovado: leia a
   seção 6 do PRD ("Histórias de usuário e critérios de aceite") e a seção 6 do TRD ("Casos de
   uso"), se o TRD já existir.
2. **Confirme implementação real antes de escrever qualquer linha** — nunca assuma que um
   critério de aceite aprovado em QA ainda reflete o código atual. **Tente a ferramenta primeiro**
   (`docs/MICRO-CONTEXT.md`, seção 4): se `/sdd-gap-report` (ou os scripts em
   `.claude/skills/sdd-gap-report/scripts/`) estiver disponível, rode-o para esta spec e reaproveite
   o veredito implementado/não-implementado como ponto de partida — converte a maior parte desta
   verificação em achado já pronto para triar, em vez de grepar classe por classe de novo. **Se não
   houver `src/`/código de produção real para o script varrer** (ex.: projeto cujo código original
   foi removido e só sobrevive como exemplo documentado, `docs/FILE-GUIDE.md` sobre
   `code-examples.md`), confirme contra o exemplo documentado e contra o veredito por critério já
   registrado no `qa-report.md` daquela fatia — nunca pule a confirmação só porque a ferramenta não
   se aplica. Para todo veredito "não implementado" ou duvidoso, confirme com leitura pontual do
   arquivo mais provável antes de escrever "Planejado" — o próprio `/sdd-gap-report` já avisa que
   "NÃO" é sinal,
   não certeza (`docs/gates/governanca.md`, "nenhuma conclusão de 'nenhum consumidor'...").
3. **Agrupe critérios de aceite relacionados num comportamento só** — um agrupamento natural de
   2-4 critérios da mesma US (ex.: criar + validar + rejeitar casos de borda) normalmente
   descreve **um** comportamento do ponto de vista de quem usa o sistema, não um por critério.
   Forçar granularidade 1:1 com a tabela do PRD produz um catálogo fragmentado e ilegível.
4. **Escreva em prosa, linguagem de produto** — cada subseção é um parágrafo explicando o
   comportamento como se fosse para alguém que nunca leu o PRD: o que acontece, quando, e o que
   acontece nos casos de borda relevantes (erro, vazio, duplicado, limite). Status
   (Implementado/Parcial/Planejado) e evidência (arquivo) ficam na tabela curta ao final da
   subseção — não no corpo do parágrafo.
5. **"Planejado"** é para um critério de aceite real (aprovado no PRD) sem implementação
   confirmada ainda — não invente feature que não está em nenhum PRD só porque parece óbvia.
   **"Parcial"** é para um comportamento cujo caso feliz existe mas algum critério de aceite
   relacionado (geralmente um caso de borda) não foi confirmado implementado.
6. **Escreva/edite `docs/FEATURES.md` in-place** (crie se não existir) seguindo a estrutura
   exata acima, uma seção por spec. Atualize a data no topo. Se uma spec já tinha uma seção e
   features dela foram confirmadas como ainda corretas nesta rodada, mantenha — só reescreva a
   subseção cujo comportamento realmente mudou desde a última atualização (não recrie o arquivo
   inteiro do zero a cada rodada).
