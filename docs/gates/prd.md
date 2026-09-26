# PRD

> Parte de `docs/QUALITY-GATES.md` (índice). Gate crítico: o que está marcado aqui
> **bloqueia mesmo** — não é sugestão, é a definição do que "pronto" significa.

- [ ] Todo critério de aceite é verificável por um terceiro sem contexto adicional (idealmente
  Gherkin).
- [ ] Seção "Fora de escopo" preenchida explicitamente.
- [ ] Seção "Indicadores técnicos a observar" preenchida (volumetria, segurança, legal) — mesmo
  que a resposta seja "nenhum indicador relevante", isso precisa estar escrito, não implícito.
- [ ] Se a feature tem UI, o usuário foi consultado (via `AskUserQuestion`, `/sdd-prd` passo 2b)
  sobre ver opções de wireframe/protótipo antes do PRD — aceite ou recusa, nunca silenciado; seção
  "Wireframes/Protótipos de tela" preenchida de acordo (ou "não aplicável" se a feature não tem UI).
  Se opções foram geradas, o(s) arquivo(s)-fonte `.dc.html` estão salvos em
  `specs/<slug>/wireframes/` (não só a URL do Artifact) — para conferência futura mesmo se o
  Artifact publicado não estiver mais acessível. Se `docs/DESIGN-SYSTEM.md` ainda não existir neste
  projeto, o usuário foi consultado sobre estabelecer um antes de gerar as opções (aceite ou
  recusa, nunca silenciado) — campo "Sistema de design usado" preenchido de acordo.
- [ ] **Se a feature tem alteração de UI de verdade** (mesmo gate do bullet acima), `ux-designer`
  foi acionado em modo consultoria (`.claude/agents/ux-designer.md`, seção "Pré-condição (modo
  consultoria de PRD)") — independente de o usuário ter topado ver wireframes ou não — e a
  subseção "Parecer de UX" do PRD está preenchida com o parecer recebido, "sem observações
  relevantes", ou "não aplicável" só quando a feature genuinamente não tem UI. Esse parecer é
  informativo, nunca um veredito — não é gate de aprovação em si, só precisa estar registrado.
- [ ] Aprovação explícita do usuário registrada.
