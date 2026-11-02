# Verificação ao vivo em vez de só ler código

Gatilho: revisão pós-implementação, passo 3 do Processo ("Verificação ao vivo").

Sempre que o ambiente desta sessão tiver automação de navegador disponível (ex.: ferramentas MCP
como `claude-in-chrome`, ou equivalente), **prefira navegar o fluxo real numa sessão de teste a
inferir comportamento só pelo JSX/CSS/template** — vários achados relevantes de usabilidade (mídia
corrompida sem fallback visual, ação que deveria mudar de aparência num certo estado do domínio,
navegação desalinhada num viewport específico) só aparecem usando o app de verdade, não lendo o
diff. Quando essa automação não estiver disponível nesta invocação, siga com leitura de código e
**registre explicitamente essa limitação** no `ux-review.md` (seção 1, "Método desta rodada") —
nunca apresente um veredito baseado só em leitura estática como equivalente a uma verificação ao
vivo.

## Em DOM sem engine de estilo (jsdom e equivalentes), a classe escrita no JSX não mede nada

Quando a rodada roda em jsdom e o veredito depende de **visibilidade, presença na árvore de
acessibilidade, ordem de foco ou geometria**, a asserção só vale se a regra de CSS relevante for
**compilada com a toolchain do projeto e injetada no documento** antes da consulta. Sem isso, o
veredito daquela área é declarado explicitamente como **não medido** — nunca como "sem achados": o
jsdom é ignorante sobre o CSS do projeto, então a asserção passa e o que ela afirma é falso.

Já aconteceu de verdade, e é por isso que este parágrafo não é zelo. Uma correção passou a
renderizar uma região de anúncio (`role="status"`) "sempre montada", com a classe `empty:hidden`
para não deixar um `gap` órfão no layout. **Quatro artefatos** passaram a afirmar essa garantia
(seção 11 do TRD, docblock do componente, `code-review.md`, `POST-MERGE-VALIDATION.md`), a suíte
ficou verde, e **nenhuma das três etapas de revisão seguintes pegou nada por leitura**. A
reverificação de UX pegou porque compilou `empty:hidden` com o Tailwind daquele repositório e
injetou a regra no jsdom antes de consultar: com a regra presente, `getByRole('status')` devolve
**0** enquanto a região está vazia — ou seja, ela **nunca está na árvore de acessibilidade antes
de ter conteúdo**, que é exatamente o mecanismo que a correção existia para eliminar. Agravante
medido: aquele desfecho tinha um **único** canal de anúncio.

Vale para qualquer projeto com CSS utilitário (Tailwind, UnoCSS, CSS Modules com composição): a
relação entre classe escrita no código e regra que existe no documento **não é lida, é
compilada**. A contrapartida do outro lado é do `qa-engineer` (`agents/qa-engineer.md`): asseverar
sobre o **CSS publicado** do build, porque o extrator varre o arquivo inteiro — comentários
incluídos — e o fonte não decide o que existe em produção.
