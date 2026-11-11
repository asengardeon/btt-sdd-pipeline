# Pré-requisitos externos do plano

Gatilho: ao montar o plano de implementação (passo 4 do núcleo), antes de apresentá-lo ao usuário.

Condição: o plano depende de algo fora do repositório — credencial local de registry privado,
permissão de pacote ou de CI sobre um repositório, tag ou release publicado de uma dependência,
ferramenta local instalada.

Ação:

1. Liste cada item na seção "Riscos" do plano, sob o título "Pré-requisitos externos". Se não há
   nenhum, escreva "Nenhum pré-requisito externo".
2. Verifique cada item **você mesmo**, com um comando barato, antes de invocar o agente. Exemplos:
   consultar o pacote no registry (`npm view <pacote> version`, `composer show`), `gh api` sobre a
   permissão de acesso do pacote ou da ação, `gh release view <tag>`, `<ferramenta> --version`.
3. Para o que faltar, inclua a ação pedida ao usuário no mesmo `AskUserQuestion` que aprova o plano.
   Não despache o agente com um pré-requisito conhecido como ausente: ele para em segundos e a
   espera humana volta a correr depois, com o agente já parado.
4. Registre no plano o comando e o resultado de cada verificação.
