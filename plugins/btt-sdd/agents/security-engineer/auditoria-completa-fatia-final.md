# Auditoria completa obrigatória na fatia final (nunca fast path)

Gatilho: antes de aplicar o fast path por área, ao revisar qualquer fatia — verifique se é a
última pendente da feature.

Verifique na tabela "Decomposição de tarefas e dependências" do TRD se esta é a **última fatia
pendente da feature** (nenhuma outra fatia da tabela ainda não implementada/mergeada depois
desta). Se for, o fast path não se aplica a nenhuma área — mesmo que o `git diff --stat` desta
fatia isolada não toque nada relevante, revise as 6 áreas por completo. Nesse caso, a base do
diff não é só a fatia anterior: procure na tabela "Histórico de aprovações por fatia" (já
existente neste `security-review.md`) a linha mais recente com `Profundidade = completo`, use o
`Commit` registrado ali como base (`git diff <esse-commit>...HEAD`) — cobrindo tudo que foi
fast-pathed desde a última auditoria de verdade, não só o que mudou nesta última fatia. Se
nenhuma linha anterior tiver `Profundidade = completo`, use a base da própria feature (primeiro
commit da branch, ou `main`), que já é o comportamento padrão de uma primeira fatia.

**"Completo" significa confirmar objetivamente, não reescrever a narrativa inteira.** Para uma
área cujo diff acumulado (calculado acima) comprovadamente não toca nenhum arquivo relevante,
"revisar por completo" significa confirmar isso com um comando real (`git diff --stat` ou
equivalente) e registrar o veredito em uma linha citando esse comando como evidência — não
reescrever do zero a investigação inteira em prosa só porque é a fatia final. Prosa detalhada de
investigação continua obrigatória só para a(s) área(s) que o diff efetivamente toca.

**Registre os arquivos de entrada lidos.** Na fatia final, o artefato desta rodada traz uma seção
"Arquivos de entrada lidos" com um item por arquivo que a instrução mandou ler (plano da fatia,
casos de uso, qualidade, plano de testes e tarefas do TRD, investigações citadas, relatórios das
etapas anteriores): o caminho e, para cada um, "lido" ou "não lido" com o motivo. O veredito de
auditoria completa só vale com todos os itens lidos. Com algum "não lido", o veredito é
"incompleto", sem aprovação, e o agente lista o que falta (issue #742, `asengardeon/btt-sdd-
pipeline`). Varredura de ferramenta (segredos, dependências, análise estática, mutações) não
substitui essa leitura.
