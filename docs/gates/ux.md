# UX / Usabilidade (`ux-designer`, condicional)

> Parte de `docs/QUALITY-GATES.md` (índice). Gate crítico: o que está marcado aqui
> **bloqueia mesmo** — não é sugestão, é a definição do que "pronto" significa.

- [ ] **Critério objetivo para UX review obrigatória**: sempre que o diff da fatia tocar alguma
  tela/fluxo com superfície de UI perceptível pelo usuário final (layout, navegação, visibilidade
  condicional de controles, estado vazio/erro, conteúdo de mídia) — nunca uma decisão de "merece
  ou não" reavaliada caso a caso. Fatia 100% backend/infra sem nenhuma tela afetada marca a etapa
  como "não aplicável", registrado em `ux-review.md` sob o heading padronizado `## Decisão: UX
  review pulado (justificado)`, nunca simplesmente omitida.
- [ ] `code-review.md` com veredito aprovado (ou aprovado com ressalvas aceitas pelo usuário) —
  sem isso, a UX review não começa.
- [ ] Cada uma das 7 áreas de revisão (consistência e padrões; visibilidade do estado do sistema e
  prevenção de erro; controle/liberdade do usuário e navegabilidade; consciência de estado/ciclo
  de vida do domínio; robustez de conteúdo gerado pelo usuário; hierarquia de informação; alvo de
  toque/acessibilidade básica) tem veredito com evidência ou "sem achados" — nunca em branco.
- [ ] O método usado nesta rodada (verificação ao vivo via automação de navegador, ou leitura de
  código na ausência dela) está documentado em `ux-review.md` — um veredito baseado só em leitura
  estática nunca é apresentado como equivalente a uma verificação ao vivo.
- [ ] `ux-review.md` referencia o PR e a fatia desta rodada.
- [ ] `ux-review.md` commitado (só esse arquivo, nunca `git add -A`/`.`) e enviado (push) na
  branch do PR pelo próprio `ux-designer` antes de devolver o resultado.
