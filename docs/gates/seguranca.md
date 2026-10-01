# Segurança (`security-engineer`)

> Parte de `docs/QUALITY-GATES.md` (índice). Gate crítico: o que está marcado aqui
> **bloqueia mesmo** — não é sugestão, é a definição do que "pronto" significa.

- [ ] **Critério objetivo para segurança obrigatória, mesmo numa correção pontual pequena** (fora
  do fluxo normal de fatia — ex. `/sdd-hotfix`, `docs/POST-MERGE-VALIDATION.md`, ou qualquer ajuste
  que o orquestrador considerou "pequeno demais" para o pipeline completo): `security-engineer`
  roda sempre que o diff tocar **qualquer um** dos itens abaixo, independente do tamanho da
  mudança — nunca uma decisão de "merece ou não" reavaliada caso a caso pelo orquestrador:
  - Autenticação (login, criação/validação de sessão, emissão/verificação de token/credencial).
  - Autorização (checagem de permissão/papel, controle de acesso a recurso).
  - Gestão de sessão (criação, expiração, invalidação, armazenamento de sessão).
  - Dados pessoais/sensíveis (PII, credencial, dado financeiro/saúde, qualquer campo que já exija
    tratamento especial em `security-review.md` de outra feature).
  - Qualquer ponto de entrada que aceita um identificador externo (e-mail, identidade de SSO,
    token, ID de usuário de terceiro) vindo de fora do sistema.
  Fora desses casos, a decisão de acionar segurança numa correção pontual pequena continua a
  critério do orquestrador (mas registrada, nunca implícita).
- [ ] Superfície de ataque/fronteiras de confiança identificadas para a feature.
- [ ] Cada categoria do OWASP Top 10 tem avaliação (aplicável com achado, ou não aplicável com
  justificativa) — nunca em branco.
- [ ] **Nenhum dado atribuível a pessoa real em artefato de spec, teste, dublê/mock, comentário ou
  XML doc** — o valor observado numa medição ao vivo entra no repositório já substituído por
  equivalente não atribuível, preservando a assinatura do incidente (contagem de dígitos, zeros à
  esquerda, máscara aplicada, qual validação ele passa ou falha), nunca a identidade do titular
  (`docs/TESTING.md`, seção "Valor medido ao vivo entra no repositório já substituído por equivalente
  não atribuível"). Inclui o caminho menos visível: a **instrução passada a um agente**, que não é
  arquivo nenhum e é por onde o dado real costuma entrar. Não presuma que um identificador bem
  formado num teste é placeholder sintético — confira o dígito verificador: já aconteceu de verdade,
  e dados reais do operador alcançaram seis arquivos, dois de código de produção.
- [ ] Nenhum segredo em texto claro na aplicação (código, config, log).
- [ ] Autenticação/autorização revisada em todo caminho relevante, quando a feature tem noção de
  identidade/permissão.
- [ ] Toda fronteira de confiança (CLI, request, evento) valida entrada antes de usar.
- [ ] Dependências novas/alteradas checadas por vulnerabilidade conhecida, dentro do que as
  ferramentas disponíveis permitem verificar.
- [ ] `security-review.md` referencia o PR e a fatia desta rodada.
- [ ] Na fatia final que fecha o spec (nenhuma fatia pendente na decomposição de tarefas do TRD),
  a revisão é sempre completa nas 6 áreas — nunca fast-path — cobrindo o diff acumulado desde a
  última revisão registrada como `completo` na tabela "Histórico de aprovações por fatia", não só
  o diff desta última fatia isolada.
- [ ] `security-review.md` commitado (só esse arquivo, nunca `git add -A`/`.`) e enviado (push) na
  branch do PR pelo próprio `security-engineer` antes de devolver o resultado.
