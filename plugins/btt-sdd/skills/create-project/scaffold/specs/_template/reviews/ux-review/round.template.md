<!-- sdd-format-version: 2 -->
# UX Review — <Nome da Feature> — <F-N ou hotfix-<data>>

> PR desta fatia: <link do Pull Request revisado>
> Método desta rodada: `<verificação ao vivo (navegação real) | leitura de código, sem automação de navegador disponível>`
> Data: <data>

Um arquivo por rodada — nunca edite o arquivo de uma rodada já aprovada e mergeada; crie um novo
para a próxima rodada (`MICRO-CONTEXT.md` do pipeline, seção 2). Acrescente a linha
correspondente em `INDEX.md` ao criar este arquivo.

## Veredito geral desta rodada

**Aprovado / Aprovado com ressalvas / Reprovado**

## 2. Consistência e padrões

Tokens/componentes do design system (`docs/DESIGN-SYSTEM.md`, se existir) seguidos, ou padrão ad
hoc introduzido sem justificativa? Achado (arquivo/componente, esperado, observado, severidade) ou
"sem achados".

## 3. Visibilidade do estado do sistema e prevenção de erro

Ação destrutiva/irreversível com confirmação; estados de carregamento/vazio/erro com feedback
visual próprio. Achado ou "sem achados".

## 4. Controle e liberdade do usuário / navegabilidade

Saída clara de todo fluxo (cancelar/voltar); convenções de navegação (ex.: logo → home);
alinhamento de navegação global entre viewports. Achado ou "sem achados".

## 5. Consciência de estado/ciclo de vida

Ações condicionadas a um estado do domínio (ex.: "ativo" vs. "encerrado") adaptadas/ocultadas
corretamente. Achado ou "sem achados".

## 6. Robustez de conteúdo gerado pelo usuário

Fallback visual para upload/mídia quebrada. Achado ou "sem achados".

## 7. Hierarquia de informação

Peso visual de ações condizente com risco/privilégio (ex.: conta pessoal vs. administração).
Achado ou "sem achados".

## 8. Alvo de toque/acessibilidade básica

Tamanho mínimo de alvo interativo, contraste, navegação por teclado/foco visível. Achado ou "sem
achados", ou "não verificável nesta rodada" com o motivo (ex.: sem automação de navegador
disponível).

Achados desta rodada entram direto na tabela de Achados de `tracking.md` — "sem achados"
explícito se nenhuma área acusou nada nesta rodada.
