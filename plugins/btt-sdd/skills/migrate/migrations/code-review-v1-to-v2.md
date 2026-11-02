# `code-review`: v1 (arquivo único) → v2 (split físico por rodada)

Regra de migração carregada por `/sdd-migrate <slug> code-review` quando a instância real está
em v1. Ver `docs/MICRO-CONTEXT.md`, seção 3, para o mecanismo genérico (marcador de versão,
registro de migrações) e seção 2 para o formato de destino.

## Detecção

- **Origem (v1)**: `specs/<slug>/code-review.md` existe; marcador `<!-- sdd-format-version: 1
  -->` ou ausente (specs escritas antes da convenção de marcador existir — tratadas como v1 por
  padrão).
- **Destino (v2)**: `specs/<slug>/reviews/code-review/INDEX.md` existe. Se já existir, recuse —
  esta spec/artefato já foi migrado.

## O que é preservado e o que não é

**Preservado por completo** (as tabelas de v1 já eram append-only):
- "Histórico de aprovações por fatia" inteira.
- "10. Achados" (`# | Fatia | Arquivo:linha | Problema | Sugestão | Severidade | Status`).
- "11. Pendências de validação (VALIDAR DEPOIS)".
- "12. Log de revisões".

**Não recuperável, por limitação do próprio v1 — não desta migração**: o conteúdo das áreas 2–9
(Ports & Adapters, SOLID, Clean code, Qualidade dos testes, Contrato FE/BE, Tratamento de erros,
Débito técnico, Build/empacotamento) era sobrescrito a cada rodada em v1 — só a rodada mais
recente sobrevive no arquivo no momento da migração. Marque `Arquivo = —` em toda linha do
histórico anterior à rodada vigente.

## Passos de transformação

1. Leia `specs/<slug>/code-review.md` por completo. Identifique (pelo título exato de cada
   seção, nunca só pela posição) a tabela de Histórico, a tabela de Achados (seção 10), a tabela
   VALIDAR DEPOIS (seção 11), a tabela de Log (seção 12), e o conteúdo das áreas 2–9 da rodada
   vigente (a última linha do Histórico).
2. Crie `specs/<slug>/reviews/code-review/INDEX.md` a partir de
   `specs/_template/reviews/code-review/index.template.md` (marcador `v2` herdado do template):
   copie a tabela de Histórico linha por linha; acrescente a coluna `Arquivo` (`F-<N>.md`/
   `hotfix-<data>.md` na última linha, `—` nas demais); preencha "Próximo passo" com o mesmo
   texto da seção 13 do arquivo legado.
3. Crie `specs/<slug>/reviews/code-review/tracking.md` a partir de
   `specs/_template/reviews/code-review/tracking.template.md`: copie as três tabelas (Achados,
   VALIDAR DEPOIS, Log) linha por linha, sem alterar valores.
4. Crie `specs/<slug>/reviews/code-review/<identificador-da-rodada-vigente>.md` a partir de
   `specs/_template/reviews/code-review/round.template.md`: veredito geral = valor da última
   linha do Histórico; copie o conteúdo das áreas 2–9 verbatim, sem resumir.
5. Adicione o banner de migração no topo do arquivo legado (texto exato no núcleo da skill,
   passo 7) — nunca delete nem mova o arquivo original.
