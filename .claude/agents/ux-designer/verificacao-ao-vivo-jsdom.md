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

Um padrão comum que produz esse falso positivo: uma classe utilitária como `empty:hidden`, usada
para esconder uma região de anúncio (`role="status"`) enquanto ela está vazia (em vez de desmontar
o elemento, para não deixar um `gap` órfão no layout), só some da árvore de acessibilidade quando
essa regra de fato está presente no documento consultado. Sem compilá-la e injetá-la, `getByRole
('status')` no jsdom continua encontrando o elemento mesmo vazio, mascarando exatamente o
mecanismo que a correção deveria garantir — ela **nunca** está na árvore antes de ter conteúdo.
Quando esse componente é o único canal de anúncio da página, esse falso negativo esconde a
ausência completa de anúncios, não uma falha parcial.

Vale para qualquer projeto com CSS utilitário (Tailwind, UnoCSS, CSS Modules com composição): a
relação entre classe escrita no código e regra que existe no documento **não é lida, é
compilada**. A contrapartida do outro lado é do `qa-engineer` (`.claude/agents/qa-engineer.md`):
asseverar sobre o **CSS publicado** do build, porque o extrator varre o arquivo inteiro —
comentários incluídos — e o fonte não decide o que existe em produção.
