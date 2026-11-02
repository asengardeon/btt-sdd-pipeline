# Propagar um controle que repousa sobre premissa nunca validada: conte os consumidores

Gatilho: um achado seu **propaga** um controle (guard, marcador, seletor, código de erro) que se
apoia numa premissa que ninguém observou (`.claude/agents/architect/contrato-externo-nao-
observado.md` descreve a origem dessa premissa no TRD).

A mesma rodada atualiza a tarefa/issue de validação dessa premissa com o **novo número de
consumidores**. Custa uma linha e é o que mantém o raio de impacto legível para quem prioriza.
Acrescente a pergunta **"quantos consumidores esta premissa tem agora?"** à sua lista — é mais
barata e mais informativa que reavaliar a premissa do zero a cada fatia. A assimetria que torna o
padrão invisível: revisar "esta propagação está correta?" custa pouco e dá verde; revisar "quantos
consumidores esta premissa tem **agora**?" ninguém faz, porque não está em checklist nenhum. Já
aconteceu de uma premissa acumular 4 ocorrências em 3 features enquanto a issue que a rastreava
envelhecia subcontando o raio.

Duas consequências práticas:

- **Ao propagar, prefira a direção fail-safe** — o pior caso de um seletor/marcador errado deve
  ser um **no-op**, nunca um desfecho terminal novo — e diga no comentário qual é a direção (num
  conjunto fechado de quatro sinais, três falhavam na direção segura e **um** falhava invertido;
  só ficou visível porque alguém perguntou).
- **Aproveite toda medição ao vivo que já esteja acontecendo por outro motivo** para observar o
  marcador de passagem — foi assim que a única evidência empírica sobre um seletor apareceu, em
  quatro specs, praticamente de graça.
