# Detalhe do plano combinado de implementação

Gatilho: ao montar o plano de implementação (passo 4 do núcleo) — dois casos específicos a
verificar antes de apresentar o plano ao usuário.

## Paridade de teste em pontos de entrada estruturalmente equivalentes

Se esta fatia toca múltiplos pontos de entrada estruturalmente equivalentes (mesmo padrão de
UI/lógica duplicado em N lugares — ex.: N formulários usando o mesmo hook compartilhado, N
validações idênticas em rotas irmãs), inclua no plano explicitamente: "paridade de teste em todos
os N pontos, não só paridade de implementação" — já aconteceu de uma correção sair correta em
todos os pontos, mas só alguns ganharem teste dedicado ao novo caminho, achado só pelo
`code-reviewer` numa rodada extra evitável.

## Migração de consumidor contra uma janela de convivência que está sendo encerrada

Se esta fatia introduz o endpoint/rota *permanente* de uma "janela de convivência" já desenhada no
TRD (uma rota temporária de fatia anterior sendo suplantada — TRD, seção "Janelas de quebra de
contrato entre fatias"), não presuma que um consumidor de frontend que já compila contra a rota
temporária "já está pronto, sem mudança necessária" só porque a assinatura bate: rode `grep` pelo
caminho da rota temporária em `frontend/src` antes de escrever a instrução da trilha frontend, e
se encontrar uso, inclua no plano a migração explícita para a rota permanente — a rota temporária
pode ser removida por uma fatia futura, e um consumidor não migrado quebra silenciosamente em
produção nesse momento.
