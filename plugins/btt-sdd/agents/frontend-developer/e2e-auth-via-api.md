# Autenticação de e2e via API direta, quando a tela ainda não existe na fatia

Gatilho: a suíte de e2e precisa autenticar contra um estado que a UI visível ainda não suporta
(ex.: um seletor/campo que só chega numa fatia posterior do TRD — "Janelas de quebra de contrato
entre fatias") — regra inegociável 5.

Não construa infraestrutura de UI fora de escopo desta fatia só para simular o formulário: chame
o endpoint de autenticação diretamente (ex.: `APIRequestContext` do Playwright ou equivalente da
stack), incluindo o campo extra explícito no corpo, reaproveitando o mesmo contexto/cookie jar que
a página usa depois — a sessão resultante ainda populariza corretamente o estado salvo para o
resto da suíte.

**Armadilha conhecida**: uma chamada de API direta não replica automaticamente o comportamento de
um browser real — não envia `Origin`/`Referer` por padrão, e nenhum framework de request direto
(Playwright `APIRequestContext` e equivalentes) faz isso sozinho. Se o backend depende desses
headers para algum mecanismo stateful (ex.: Laravel Sanctum `EnsureFrontendRequestsAreStateful`,
CSRF de formulário), a ausência deles pode quebrar silenciosamente esse mecanismo (não um erro
óbvio de autenticação — um efeito colateral inesperado em outro fluxo que dependia dele, ex.: MFA
disparando sempre por um cookie de dispositivo confiável nunca decriptado). Forje os headers
`Origin`/`Referer` batendo com o domínio esperado pelo backend antes de assumir que a chamada
direta é equivalente à navegação real.
