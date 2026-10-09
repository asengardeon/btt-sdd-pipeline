# Escrita dos artefatos (vale para todas as etapas que escrevem artefato)

> Parte de `docs/QUALITY-GATES.md` (índice). Gate crítico: o que está marcado aqui
> **bloqueia mesmo** — não é sugestão, é a definição do que "pronto" significa.

Só os itens **verificáveis** das regras adotadas da ASD-STE100 estão aqui. O raciocínio, os itens
de julgamento (que não bloqueiam) e o mecanismo de glossário estão em `docs/WRITING-STYLE.md`.

Cobre a prosa dos artefatos de `specs/<slug>/`, de `docs/`/`README.md`/`docs/adr/`, e os
comentários e docstrings de código. **Não** cobre mensagem de commit, corpo de PR nem corpo de
issue — exclusão deliberada, registrada em `docs/WRITING-STYLE.md`.

- [ ] **Uma ideia por frase.** Duas afirmações independentes são duas frases.
- [ ] **Frase dentro do limite: 20 palavras em texto de procedimento, 25 em texto descritivo.**
  Procedimento é toda instrução a executar (passo de skill, item de gate, critério de aceite).
- [ ] **Voz ativa onde existe agente identificável.** Passiva só quando o agente é irrelevante ou
  desconhecido de verdade.
- [ ] **Tempo simples** — presente, passado ou futuro simples. Sem perífrase nem condicional
  empilhado.
- [ ] **Um termo por conceito e um conceito por termo.** Vale no artefato e entre os artefatos da
  mesma spec. Colisão confirmada em dois artefatos vira entrada em `docs/GLOSSARY.md`
  (`docs/WRITING-STYLE.md`, seção "Um termo por conceito"). O termo já registrado lá vence.
- [ ] **Procedimento em imperativo, numerado, uma instrução por item.** Item com duas instruções é
  dividido em dois.
- [ ] **Nenhum estilo telegráfico.** Nenhum artigo, preposição ou verbo omitido para encurtar.
- [ ] **Verbo em vez de nominalização** quando as duas formas dizem o mesmo.
- [ ] **Nenhuma negação dupla.**
- [ ] **Divisão nunca apaga fato.** Divida a frase acima do limite. Nunca a resuma com perda de
  conteúdo. A narrativa de incidente concreto ("já aconteceu de verdade: ...") é a evidência de por
  que a regra existe. Este gate nunca é motivo para removê-la. Seção mais longa é resultado
  aceitável; fato perdido não é.
- [ ] **Divergência entre a regra e a clareza fica registrada, não resolvida em silêncio.** Às
  vezes seguir um item à risca deixa o texto menos claro. Nesse caso, o artefato traz a forma mais
  clara e uma linha dizendo por quê (`docs/gates/governanca.md`, "nenhuma suposição não
  documentada").
- [ ] **Achado de escrita não bloqueia por gosto de redação.** Uma etapa de revisão levanta achado
  desta classe só contra um item desta lista, e cita qual. Os itens de julgamento de
  `docs/WRITING-STYLE.md` orientam sem bloquear — nenhum deles sustenta um achado.
