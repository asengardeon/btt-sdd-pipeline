# Revisão de código (`code-reviewer`)

> Parte de `docs/QUALITY-GATES.md` (índice). Gate crítico: o que está marcado aqui
> **bloqueia mesmo** — não é sugestão, é a definição do que "pronto" significa.

- [ ] Nenhuma violação de fronteira ports & adapters (domain/application sem import de infra)
  aprovada sem ressalva.
- [ ] Princípios SOLID avaliados de forma funcional (import de fato, não intenção declarada).
- [ ] Qualidade dos próprios testes avaliada (fragilidade, falso positivo) — cobertura numérica é
  do QA, não desta etapa.
- [ ] Se full-stack: contrato Frontend↔Backend do TRD checado como implementado exatamente pelos
  dois lados.
- [ ] Débito técnico introduzido está sinalizado explicitamente (pelo dev ou pela revisão) — débito
  silencioso não documentado é achado bloqueante.
- [ ] **Fatia que estende um guard/regra de autorização já implementado por uma fatia anterior
  (ex.: de "só autor" para "autor OU organizador/admin") renomeia os testes cujo nome descreve o
  comportamento que a nova fatia inverte — não só altera a asserção.** Um teste chamado
  `test_rejects_organizer` cuja asserção passou a esperar sucesso em vez de recusa é uma inversão
  semântica silenciosa: o nome descreve um comportamento que já não é mais verdade. Confirme
  também, via grep pelo nome antigo do teste no restante da suíte, que nenhuma referência órfã
  (import, chamada direta, menção em comentário) ficou para trás. Achado bloqueante se algum teste
  tocado pela fatia mantiver um nome que descreve o comportamento anterior.
- [ ] Se a fatia tem trilha de frontend, ou gera qualquer outro artefato de build/empacotamento
  distinto do código-fonte, o comando de build/empacotamento real de produção (`docs/STACK.md`)
  foi verificado (reaproveitado do arquivo de cobertura da fatia ou reexecutado nesta rodada) antes
  de aprovar — nunca aprovado só com base em lint/tipo/teste unitário nesse caso
  (`docs/TESTING.md`, seção "Build/empacotamento real como parte da suíte completa").
- [ ] Se esta rodada gravou revisão nova no "Log de revisões" do TRD, as seções 9 (contrato
  observável), 13 (decomposição/Status) e 14 (controle de versão por fatia) foram reconciliadas —
  não só a seção que a revisão editou. São as seções que as etapas seguintes leem como contrato.
- [ ] Se o TRD marca esta fatia como portadora de uma quebra de contrato (seção "Janelas de quebra
  de contrato entre fatias", coluna "`!` no título do PR"), o título do PR tem `!` antes dos
  dois-pontos (ou o rodapé `BREAKING CHANGE:` no corpo) — checagem de um caractere, três etapas
  antes do SRE (`docs/GIT-WORKFLOW.md`, seção "Quebra de contrato e o título do PR"). Uma quebra
  encontrada no diff que o TRD **não** declarou é achado por si só.
- [ ] `code-review.md` existe, referencia o PR e a fatia desta rodada, e cada área de revisão tem
  veredito com evidência (arquivo/linha) ou "sem achados".
- [ ] `code-review.md` commitado (só esse arquivo, nunca `git add -A`/`.`) e enviado (push) na
  branch do PR pelo próprio `code-reviewer` antes de devolver o resultado.

**Nota sobre a amostragem acidental.** As execuções redundantes descritas abaixo funcionam, sem
ninguém ter planejado, como amostragem de flakiness: rodar a mesma suíte N vezes sobre o mesmo
código é um teste de repetição, e teste de repetição acha asserção instável. Já aconteceu de os dois
runs vermelhos de uma fatia serem justamente commits só de documentação — e de um deles ter achado o
bloqueante do code review. Suprimi-las (pela receita de short-circuit, ou por uma cadência
condicional) exige um substituto **deliberado**, fora do caminho crítico de qualquer PR, ou o
projeto troca um amostrador barato-mas-acidental por nenhum amostrador.

**Nota sobre o custo de CI desta exigência** (vale igualmente para `ux-review.md`, `qa-report.md`,
`security-review.md`, `sre-review.md`, `timing-log.md` e as rodadas de correção): como cada etapa
commita e envia seu artefato na branch da fatia, **depois que o código para de mudar a branch ainda
recebe uma dezena de commits de documentação pura**, cada um disparando o CI completo no PR. Isso é
consequência estrutural do pipeline, não descuido — e é por isso que existe a receita de
short-circuit de docs-only na seção "SRE / CI-CD / Infra" abaixo. Não resolva isso deixando de
commitar o artefato: o artefato na branch é o que torna a revisão auditável.
