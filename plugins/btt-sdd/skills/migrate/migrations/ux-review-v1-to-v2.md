# `ux-review`: v1 (arquivo único) → v2 (split físico por rodada)

Regra de migração carregada por `/sdd-migrate <slug> ux-review` quando a instância real está em
v1. Ver `docs/MICRO-CONTEXT.md`, seção 3, para o mecanismo genérico (marcador de versão, registro
de migrações) e seção 2 para o formato de destino.

## Detecção

- **Origem (v1)**: `specs/<slug>/ux-review.md` existe; marcador `<!-- sdd-format-version: 1 -->`
  ou ausente (specs escritas antes da convenção de marcador existir — tratadas como v1 por
  padrão).
- **Destino (v2)**: `specs/<slug>/reviews/ux-review/INDEX.md` existe. Se já existir, recuse —
  esta spec/artefato já foi migrado.

## O que é preservado e o que não é

**Preservado por completo** (as tabelas de v1 já eram append-only):
- "Histórico de aprovações por fatia" inteira (inclui `Método`).
- "10. Pendências de validação (VALIDAR DEPOIS)".
- "11. Log de revisões".

**Caso especial — "9. Achados" não é append-only em v1.** Diferente dos outros 4 stages, a
tabela de achados de `ux-review.md` (`# | Arquivo/componente | Esperado | Observado |
Severidade`) **não acumula entre rodadas** no formato legado — só mostra os achados da rodada
vigente, sem colunas `Fatia`/`Status`. Ao migrar, preencha `Fatia` com o identificador da rodada
vigente e `Status = aberto` em cada linha — a tabela migrada vira o ponto de partida do
acumulado em `tracking.md` a partir de agora, não uma reconstrução de achados de rodadas
anteriores (que nunca existiram nessa tabela em primeiro lugar).

**Não recuperável, por limitação do próprio v1 — não desta migração**: o conteúdo das áreas 2–8
(Consistência, Visibilidade de estado, Controle/navegabilidade, Consciência de ciclo de vida,
Robustez de conteúdo do usuário, Hierarquia de informação, Alvo de toque/acessibilidade) era
sobrescrito a cada rodada em v1 — só a rodada mais recente sobrevive no arquivo no momento da
migração. Marque `Arquivo = —` em toda linha do histórico anterior à rodada vigente.

## Passos de transformação

1. Leia `specs/<slug>/ux-review.md` por completo. Identifique (pelo título exato de cada seção,
   nunca só pela posição) a tabela de Histórico, a tabela de Achados (seção 9 — ver caso especial
   acima), a tabela VALIDAR DEPOIS (seção 10), a tabela de Log (seção 11), e o conteúdo das áreas
   2–8 da rodada vigente (a última linha do Histórico).
2. Crie `specs/<slug>/reviews/ux-review/INDEX.md` a partir de
   `specs/_template/reviews/ux-review/index.template.md` (marcador `v2` herdado do template):
   copie a tabela de Histórico linha por linha, sem alterar `Método`; acrescente a coluna
   `Arquivo` (`F-<N>.md`/`hotfix-<data>.md` na última linha, `—` nas demais); preencha "Próximo
   passo" com o mesmo texto da seção 12 do arquivo legado.
3. Crie `specs/<slug>/reviews/ux-review/tracking.md` a partir de
   `specs/_template/reviews/ux-review/tracking.template.md`: copie a tabela de Achados
   adicionando `Fatia`/`Status` conforme o caso especial acima; copie VALIDAR DEPOIS e Log linha
   por linha, sem alterar valores.
4. Crie `specs/<slug>/reviews/ux-review/<identificador-da-rodada-vigente>.md` a partir de
   `specs/_template/reviews/ux-review/round.template.md`: veredito geral = valor da última linha
   do Histórico; copie o conteúdo das áreas 2–8 verbatim, sem resumir.
5. Adicione o banner de migração no topo do arquivo legado (texto exato no núcleo da skill, passo
   7) — nunca delete nem mova o arquivo original.
