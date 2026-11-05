# Detalhe do plano combinado de implementação

Gatilho: ao montar o plano de implementação (passo 4 do núcleo) — três casos específicos a
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

## Roteiro de navegador full-stack numa tarefa de trilha "ambos" precisa de dono nomeado

Se a tarefa combina sub-partes de responsabilidade diferente (ex.: unit backend, integração
backend, componente frontend, roteiro de navegador ponta a ponta) sob a trilha "ambos", um roteiro
de navegador full-stack (ex.: Playwright) não pertence inequivocamente a nenhuma das duas — ao
contrário de unit/integração (claramente backend) ou componente (claramente frontend). Atribua
esse roteiro explicitamente a UMA das duas trilhas na própria instrução de invocação (ex.:
"frontend-developer: você também escreve o roteiro de Playwright, porque ele precisa do servidor
de desenvolvimento do frontend de pé") — nunca deixe como "ambos decidem entre si": os dois
agentes não se comunicam durante a execução paralela e não têm como negociar quem cobre o quê. Já
aconteceu de verdade, duas vezes em specs diferentes do mesmo projeto: na primeira, o roteiro só
foi escrito porque um dos dois agentes notou a lacuna por acaso antes de terminar; na segunda,
nenhum dos dois escreveu, e a ausência só foi percebida pelo orquestrador ao integrar as duas
trilhas já depois das duas sessões terminadas — exigindo uma invocação nova e isolada só para essa
peça (issue #620, `asengardeon/btt-sdd-pipeline`).
