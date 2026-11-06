# Fase 0: leitura crítica do PRD (readiness)

Gatilho: sempre, antes de desenhar qualquer coisa do TRD (processo, passo 0).

Leia o PRD inteiro e liste as decisões técnicas que dependem de informação que o PRD não dá.
Classifique cada lacuna:

| Classe | Critério | O que fazer |
|---|---|---|
| **Bloqueante** | Muda a arquitetura **e** tem alto custo de reversão: modelo de dados, contrato público, segurança, custo de infraestrutura | Pergunta ao usuário, em lote |
| **Assumível** | Existe um padrão razoável e reverter é barato | Registra a premissa e segue |
| **Técnica** | É decisão do próprio TRD, não do PRD | Decida no TRD |

Regra de corte: só volta ao PRD o que tem alto custo de reversão. O resto vira premissa.

Itens que o PRD deve responder, como lista de checagem das lacunas: volume e escala; requisito não
funcional com número; permissões e papéis; regras de negócio e casos de borda; integrações e dono
do contrato; dados (origem, dono, sensibilidade, ciclo de vida); compatibilidade com o legado;
comportamento em falha; fora de escopo.

## Saída

1. Mostre ao usuário um relatório curto: lacunas por classe, uma linha cada. Não grave arquivo
   novo.
2. Devolva **todas** as perguntas bloqueantes numa única `AskUserQuestion` (até 4 por chamada;
   agrupe o excedente na chamada seguinte), nunca uma a uma. "VALIDAR DEPOIS" segue sendo opção
   válida.
3. Anote cada lacuna assumível como premissa: ID `PRM-<n>`, o padrão escolhido e o impacto se a
   premissa estiver errada. Grave-as em "Premissas assumidas" (`trd/tracking.md`, seção 15b) ao
   criar o `tracking.md` no passo 11, pois ele ainda não existe nesta fase.
4. Daqui em diante, toda decisão do TRD cita o requisito do PRD que a motiva. Decisão sem requisito
   de origem entra como premissa ou como lacuna, nunca como decisão firme.
