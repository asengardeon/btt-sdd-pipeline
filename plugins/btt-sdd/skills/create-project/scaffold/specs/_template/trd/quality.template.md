<!-- sdd-format-version: 2 -->
# TRD — <Nome da Feature> — Qualidade (pilares de engenharia, riscos e trade-offs)

> Seções 10 e 12 do TRD (`INDEX.md` tem o núcleo e a navegação para os demais arquivos).

## 10. Pilares de engenharia de software

Cada pilar exige resposta explícita — "não se aplica, porque X" é uma resposta válida; em branco
não é. Detalhe conceitual de cada pilar em `docs/ENGINEERING-PILLARS.md`.

- **Performance**: <latência/throughput esperado, ou "não se aplica, porque..."`>
- **Escalabilidade**: <a feature introduz estado em memória do processo? aguenta múltiplas
  instâncias? ou "não se aplica, porque..."`>
- **Resiliência**: <para cada dependência externa nova: timeout/retry/circuit breaker/fallback
  definidos, ou "não se aplica, porque..."`>
- **Disponibilidade**: <impacto se esta feature ficar indisponível — crítico/degradação
  aceitável/irrelevante — e por quê`>
- **Observabilidade** (logs/métricas mínimas): <o que precisa ser logado/medido nas fronteiras de
  adapter para diagnosticar problema em produção`>
- **Manutenibilidade**: <desvio deliberado de SOLID/Clean Code (`docs/ARCHITECTURE.md`), se
  houver, com justificativa; senão "nenhum desvio"`>
- **Impacto em infraestrutura para o SRE revisar:** <fila? cache? novo serviço? escalonamento?
  ou "nenhum">
- **Indicadores técnicos herdados do PRD** (seção "Indicadores técnicos a observar" do PRD, seção
  9 — `prd/INDEX.md` ou `prd.md`, conforme o formato da spec): para cada um (volumetria,
  segurança, legal), a decisão tomada aqui ou a justificativa de por que foi adiada — nunca
  ignorado silenciosamente. O indicador de segurança é aprofundado depois pelo agente
  `security-engineer` (`/sdd-security`); aqui só a decisão de design de alto nível que o afeta
  (ex.: precisa de autenticação? qual dado é sensível?).

## 12. Riscos e trade-offs

Riscos técnicos identificados e a decisão tomada (com justificativa).

**Toda afirmação sobre comportamento concreto de biblioteca de terceiro ou de runtime** — tipo de
exceção lançada, limite numérico, formato gravado, o que um `catch` captura — vem marcada como
**`[medido]`** (com a versão da biblioteca e como foi medido) ou **`[não medido]`** (hipótese vinda
de leitura de documentação/código, a verificar por quem depender dela). Afirmações desse tipo
*parecem* factuais e não convidam à verificação; a marcação é o que transforma uma armadilha
silenciosa em item acionável, a custo praticamente zero para quem escreve.

O mesmo vale para a decisão registrada ao lado do risco: dizer que algo "vira falha daquela linha"
(ou qualquer outra alegação de **contenção**) é uma afirmação sobre o próprio código — **cite o
ponto onde a contenção acontece**. Se ninguém conseguir citar o ponto, a contenção provavelmente
não existe.

| Risco | Impacto | Decisão / mitigação | Evidência |
|-------|---------|---------------------|-----------|
| <risco> | <impacto real, não o suposto> | <decisão, citando o ponto de contenção quando alegar contenção> | `[medido]` (biblioteca X vN, como) ou `[não medido]` |
