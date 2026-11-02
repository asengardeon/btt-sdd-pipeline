<!-- sdd-format-version: 2 -->
# PRD — <Nome da Feature> — Histórias de usuário

> Seções 6-7 do PRD (`INDEX.md` tem o núcleo e a navegação para os demais arquivos).

## 6. Histórias de usuário e critérios de aceite

### US-1: <título curto>

Como <persona>, eu quero <ação>, para que <benefício>.

**Critérios de aceite:**

```gherkin
Cenário: <nome>
  Dado <contexto>
  Quando <ação>
  Então <resultado esperado>
```

(Repita para cada história. Cada critério de aceite deve ser verificável por um terceiro sem
contexto adicional — isso vira o checklist literal do QA.)

## 7. Wireframes/Protótipos de tela (quando a feature tem UI)

Preenchido só quando a feature tem tela(s) nova(s) ou mudança visual relevante em tela existente.
Antes de escrever as histórias de usuário em detalhe, `/sdd-prd` oferece ao usuário ver 2-3 opções
de wireframe/protótipo de baixa fidelidade das telas principais para escolher a direção que achar
mais interessante — uma exploração visual rápida para alinhar direção cedo, não o desenho técnico
de UI final (isso continua com `architect`/`frontend-developer` no TRD/implementação).

- **Oferecido ao usuário?** `<sim / não aplicável (feature sem UI)>`
- **Sistema de design usado**: `<"docs/DESIGN-SYSTEM.md" (já existia) / "docs/DESIGN-SYSTEM.md"
  (estabelecido nesta rodada) / "paleta neutra padrão — usuário optou por não estabelecer um
  sistema de design agora" / "não aplicável (wireframes não oferecidos)">`
- **Opções apresentadas**: `<link do Artifact com as opções, ou "nenhuma — usuário preferiu seguir
  direto para o PRD">`
- **Opção escolhida**: `<qual opção, e por quê, se o usuário comentou>`
- **Arquivo salvo**: `specs/<slug>/wireframes/<nome-descritivo>.dc.html` — a fonte local das
  opções geradas, salva junto da spec para conferência futura mesmo se o Artifact publicado não
  estiver mais acessível (republique esse arquivo via Artifact para ver de novo). `<preencher ou
  "não aplicável">`
- **Parecer de UX (`ux-designer`)**: consultoria de navegabilidade/usabilidade coletada por
  `/sdd-prd` (passo 2b) antes das histórias serem escritas em detalhe — por opção de wireframe
  quando houve mais de uma, ou sobre a descrição textual das telas/fluxos quando o usuário optou
  por não ver wireframes. Informativo, não um veredito — não bloqueia a aprovação do PRD.
  `<transcrever o parecer recebido, "sem observações relevantes", ou "não aplicável (feature sem
  alteração de UI)">`
