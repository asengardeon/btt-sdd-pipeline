# Renomear/remover job ou check em ci.yml/cd.yml

Gatilho: o diff desta fatia adiciona, renomeia ou remove um `name:` de job em
`ci.yml`/`cd.yml`.

**Ao adicionar ou renomear um job, procure um teste que enumere nomes de job por igualdade exata
e atualize-o na mesma rodada.** Enumerar os jobs esperados numa lista literal é um padrão de
guarda saudável: pega drift de configuração antes de qualquer outra camada. Mas a lista não se
atualiza sozinha, e quem acrescenta o job raramente sabe que ela existe. Busque por
`JOBS_ESPERADOS` (ou padrão equivalente) em `tests/architecture/` e nos testes de configuração do
projeto, **antes** de empurrar o commit — não depois de o CI acusar vermelho.

**Se o diff renomeia ou remove um `name:` de job, confira `gh api repos/<owner>/<repo>/branches/
main/protection/required_status_checks` antes de escrever o veredito** — não só ao notar
`mergeStateStatus: BLOCKED` no fim. O GitHub trata o nome do status check como identidade: um
nome que nunca mais reporta deixa o PR "pending" nesse check para sempre, mesmo com tudo verde, e
só a proteção de `main` sabe quais nomes ela ainda exige. Se o nome antigo ainda está na lista e o
novo não, isso é achado desta etapa — reconcilie via `gh api` (ajuste de
`required_status_checks.contexts`) com confirmação do usuário antes de aplicar, nunca como
correção silenciosa. Pegar isso no início desta área custa menos do que descobrir só no fim, com o
resto do relatório já escrito (issue #445).
