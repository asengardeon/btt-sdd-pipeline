---
name: gap-report
description: Utilitário do pipeline SDD. Use quando o usuário perguntar o que ainda falta implementar de uma feature, pedir para comparar o TRD com o código real, ou quiser saber quais casos de uso da seção 6 do TRD já existem em código vs. só desenhados. Não aciona nenhum agente — só compara o TRD com src/(e frontend/, quando existir).
allowed-tools: Bash(${CLAUDE_SKILL_DIR}/scripts/sdd-gap-report.sh *) PowerShell(${CLAUDE_SKILL_DIR}/scripts/sdd-gap-report.ps1 *)
---

# /btt-sdd:gap-report

Não aciona nenhum agente — é um utilitário de leitura, como `/btt-sdd:status` e
`/btt-sdd:pending`, mas no nível de **caso de uso individual** em vez de etapa do pipeline:
responde "o que desta feature já está implementado de verdade, e o que ainda é só desenho no
TRD".

## Passos

1. **Prefira o script auxiliar em vez de reler o TRD inteiro e grepar classe por classe
   manualmente** (economiza tokens e tool calls): rode
   `${CLAUDE_SKILL_DIR}/scripts/sdd-gap-report.sh <slug> [caminho-busca ...]` (bash) ou
   `${CLAUDE_SKILL_DIR}/scripts/sdd-gap-report.ps1 -Slug <slug> [-SearchPaths <caminho1>,<caminho2>,...]`
   (PowerShell) — o script roda a partir de onde estiver instalado, mas lê `specs/<slug>/trd.md` e
   o código relativos ao diretório de trabalho atual, que deve ser a raiz do projeto.
2. `<slug>` é obrigatório — sem TRD para comparar não há gap a reportar; se o usuário não deu um
   slug, rode `/btt-sdd:status` primeiro para descobrir qual feature ele quer, ou pergunte.
3. Por padrão o script busca em `src/` e, se existir, `frontend/`. **Se o projeto usa outra
   convenção de pastas** (ex.: `src/app/Application/UseCases/` num projeto Laravel, ou um
   monorepo com múltiplos pacotes), ou se o resultado padrão vier com muito ruído/`NÃO` que você
   sabe estarem errados, passe o(s) caminho(s) certo(s) como argumento extra — não é preciso editar
   o script.
4. Apresente a tabela retornada (caso de uso | critério de aceite/US | implementado sim/não |
   arquivo de evidência) diretamente ao usuário.
5. **"NÃO" é um sinal, não uma certeza** — é grep de nome de classe, não um parser de AST. Antes de
   afirmar "isto não foi implementado", especialmente se o veredito for usado para decidir algo
   importante (ex.: bloquear um merge), confirme com uma leitura pontual do arquivo mais provável
   ou um grep adicional — o rodapé do próprio script já avisa isso. Casos comuns de falso "NÃO":
   caso de uso renomeado depois do TRD, ou implementado num caminho fora das raízes de busca
   usadas.
6. Cruze com `/btt-sdd:status` quando fizer sentido: um caso de uso "sim" (implementado) não
   significa necessariamente QA/segurança já aprovaram — isso é o veredito de `qa-report.md`/
   `security-review.md`, que este script não lê.
7. **Só leia o TRD manualmente** (fallback abaixo) se o script falhar, ou se a saída disser que
   nenhuma linha foi reconhecida na seção 6 (a tabela fugiu do formato padrão).

### Fallback sem o script (comportamento anterior)

1. Leia `specs/<slug>/trd.md`, seção 6 ("Casos de uso") — tabela "Critério de aceite (PRD) | Caso
   de uso | Ports usados".
2. Para cada linha, grep pelo nome de classe do caso de uso em `src/` (e `frontend/`, se
   existir e a feature tiver UI) para confirmar se existe implementação.
3. Apresente uma tabela: caso de uso | critério de aceite (US) | implementado (sim/não) | arquivo
   onde foi encontrado.
