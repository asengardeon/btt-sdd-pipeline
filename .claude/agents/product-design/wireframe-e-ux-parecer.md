# Wireframe/protótipo e parecer de UX (feature com UI)

Gatilho: a feature tem UI — preenchendo as seções "Wireframes/Protótipos de tela" e "Parecer de
UX (`ux-designer`)" do PRD (passos 3c/3d do Processo).

## Wireframe/protótipo

O orquestrador de `/sdd-prd` (passo 2b daquela skill) já oferece ao usuário ver opções de
wireframe/protótipo antes de você escrever as histórias em detalhe, usando ferramentas
(`Artifact`, skill `design`) que você não tem — ele te passa o resultado (opção escolhida com
referência do Artifact, o caminho do arquivo `.dc.html` salvo em `specs/<slug>/wireframes/`, o
status do sistema de design usado — `docs/DESIGN-SYSTEM.md` já existia, foi estabelecido nesta
rodada, ou o usuário optou por não estabelecer um agora —, recusa explícita, ou "não aplicável").
Preencha a seção "Wireframes/Protótipos de tela" do PRD com esse resultado tal como recebido —
incluindo os campos "Arquivo salvo" e "Sistema de design usado" — nunca inventando um
link/caminho/status que você não recebeu.

Se você estiver rodando fora desse fluxo orquestrado (invocação avulsa, sem esse resultado) e a
feature tem UI, você mesmo pode oferecer via `AskUserQuestion` se o usuário quer ver opções agora,
e se quer estabelecer um sistema de design quando `docs/DESIGN-SYSTEM.md` não existir (mesma
lógica do passo 2b de `/sdd-prd`) — mas só prossiga com a geração se tiver acesso a
`Artifact`/skill `design` nesta sessão, e nesse caso salve o(s) arquivo(s)-fonte em
`specs/<slug>/wireframes/` você mesmo (`Write`) antes de preencher a seção; caso não tenha acesso
a essas ferramentas, registre a seção como "não oferecido nesta sessão (ferramentas
indisponíveis)" e siga sem bloquear o PRD por isso.

Se a feature não tem UI, marque a seção como "não aplicável".

## Parecer de UX

O orquestrador de `/sdd-prd` (passo 2b) também te passa o parecer de navegabilidade/usabilidade
que `ux-designer` deu em modo consultoria (por opção de wireframe, ou sobre a descrição textual
das telas se o usuário recusou ver wireframes) — transcreva esse parecer tal como recebido, nunca
reformulando para "soar melhor" nem descartando uma observação por parecer menor. Isso é
informativo, não um veredito: não trate uma observação de `ux-designer` como bloqueio à aprovação
do PRD, é insumo para a decisão do usuário.

Se a feature não tem UI, ou você está rodando fora do fluxo orquestrado sem esse resultado
disponível, marque a subseção como "não aplicável" — nunca invente um parecer que não recebeu.
