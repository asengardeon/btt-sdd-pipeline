# Segurança (`security-engineer`)

> Parte de `docs/QUALITY-GATES.md` (índice). Gate crítico: o que está marcado aqui
> **bloqueia mesmo** — não é sugestão, é a definição do que "pronto" significa.

- [ ] **Critério objetivo para segurança obrigatória, mesmo numa correção pontual pequena** (fora do
  fluxo normal de fatia — ex. `/btt-sdd:hotfix`, `docs/POST-MERGE-VALIDATION.md`, ou qualquer ajuste
  que o orquestrador considerou "pequeno demais" para o pipeline completo): `security-engineer` roda
  sempre que o diff tocar **qualquer um** dos itens abaixo, independente do tamanho da mudança —
  nunca uma decisão de "merece ou não" reavaliada caso a caso pelo orquestrador:
  - Autenticação (login, criação/validação de sessão, emissão/verificação de token/credencial).
  - Autorização (checagem de permissão/papel, controle de acesso a recurso).
  - Gestão de sessão (criação, expiração, invalidação, armazenamento de sessão).
  - Dados pessoais/sensíveis (PII, credencial, dado financeiro/saúde, qualquer campo que já exija
    tratamento especial em `security-review.md` de outra feature).
  - Qualquer ponto de entrada que aceita um identificador externo (e-mail, identidade de SSO, token,
    ID de usuário de terceiro) vindo de fora do sistema. Fora desses casos, a decisão de acionar
    segurança numa correção pontual pequena continua a critério do orquestrador (mas registrada,
    nunca implícita).
- [ ] **A aprovação de code review vigente cobre o HEAD atual da branch.** Não basta
  `code-review.md` existir aprovado: `git diff --name-only <sha da rodada que aprovou>..HEAD --
  <diretórios de produção>` tem de ser **vazio**. Se não for, esta etapa não começa — roda-se uma
  rodada de code review escopada ao delta, numa instância nova, antes de prosseguir. A checagem de
  sincronia que as skills já fazem é contra `main` (`git rev-list --count HEAD..origin/main`) e
  **não cobre este caso**: o que avançou foi a própria branch da fatia, depois do carimbo. Isso
  acontece no caminho normal, não num desvio — a etapa 4b roda depois da 4 e **gera código de
  produção**, então correções de achados de UX aceitas pelo usuário atravessam duas etapas com um
  carimbo que já não corresponde ao código. Já aconteceu de verdade: 5 arquivos de produção e 824
  inserções depois do sha aprovado, dois commits de correção de UX sem rodada nenhuma de revisão —
  a rodada escopada ao delta **reprovou**, achando um bloqueante (um `useEffect` dependendo do
  **valor** e não da **transição**, roubando o foco a cada volta à tela) e um 5º sinal de plataforma
  sem nenhuma menção em `specs/`, `docs/` ou código. Foi pego só porque o `qa-engineer` inventou a
  checagem por iniciativa própria — ela não estava escrita em lugar nenhum. O custo da checagem é
  um comando.
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
- [ ] Na fatia final que fecha o spec (nenhuma fatia pendente na decomposição de tarefas do TRD), a
  revisão é sempre completa nas 6 áreas — nunca fast-path — cobrindo o diff acumulado desde a última
  revisão registrada como `completo` na tabela "Histórico de aprovações por fatia", não só o diff
  desta última fatia isolada.
- [ ] **A linha desta rodada existe em `specs/<slug>/timing-log.md` e nomeia uma única etapa.** Etapa
  cujo trabalho de orquestrador foi zero registra `0m` com justificativa — nunca nenhuma linha; e
  uma linha que nomeia duas etapas ("Segurança + code review") deixa uma das duas com zero minuto
  atribuível, então duas etapas que rodaram em paralelo são duas linhas com o mesmo horário de
  início. Em agente **retomado**, o valor registrado é a **diferença** contra a notificação anterior
  do mesmo agente, nunca o contador bruto — crescimento monotônico entre rodadas é a assinatura de
  contador cumulativo desde a criação (`specs/_template/timing-log.template.md`, seções "O que a
  coluna 'Duração' mede" e "Uma linha por etapa, sempre"). A retrospectiva de fatia lê este arquivo
  como evidência concreta de performance, e os três defeitos de medição empurram na **mesma
  direção**: superestimam as etapas de agente e subestimam as do orquestrador — numa fatia medida,
  29% do esforço era de orquestrador.
- [ ] `security-review.md` commitado (só esse arquivo, nunca `git add -A`/`.`) e enviado (push) na
  branch do PR pelo próprio `security-engineer` antes de devolver o resultado.
