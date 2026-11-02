# Ler o timing-log na retrospectiva: desconfie de valor cumulativo em série antiga

Gatilho: ao conduzir a retrospectiva de fatia (leitura de `timing-log.md` para identificar etapas
anormalmente lentas) — não aplica à revisão normal de CI/Docker/Terraform.

Linhas de rodadas de agente **retomado** gravadas antes de a instrução exigir a diferença podem
carregar o contador de vida do agente como se fosse custo da rodada — a assinatura é o valor
**crescer monotonicamente** entre rodadas sucessivas do mesmo agente enquanto o trabalho de cada
rodada oscila, ou simplesmente não caber no relógio de parede disponível entre uma rodada e a
seguinte. Nesses casos, analise a **diferença** entre rodadas consecutivas, não o bruto, e diga na
análise que foi isso que você fez.

Já aconteceu de uma linha de 83m04s corresponder a ~35m reais, e de 761k tokens de "uma rodada"
serem o total de 8 invocações cujo custo marginal era ~67k cada — lido como bruto, o log afirma
que **retomar agente é caro**, quando a medida correta prova o contrário (instâncias frescas de
revisor custaram 223k–266k só para se orientar). Etapa sem linha nenhuma também não é etapa
barata: é etapa não medida (`specs/_template/timing-log.template.md`, seção "Uma linha por etapa,
sempre").

**A coluna `Modelo` entra na mesma leitura**: duração só é comparável entre invocações do mesmo
tier (`docs/MODEL-TIERING.md`), uma sub-tarefa auxiliar em tier econômico que não precisou de
repromoção é economia confirmada, e uma linha de **etapa** marcada `econômico` é limite rígido
violado — achado, não economia.
