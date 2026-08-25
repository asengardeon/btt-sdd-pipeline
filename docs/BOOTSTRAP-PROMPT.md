# Prompt de bootstrap — replicar as mecânicas do SDD em outro projeto

> Use este prompt quando quiser criar um projeto novo com as mesmas mecânicas deste pipeline
> (etapas, gates, governança, arquitetura), mas **sem** depender dos agentes/skills instalados
> deste repositório (ex.: outro computador, outra ferramenta, ou repassar para outra pessoa).
> Se você está numa sessão do Claude Code neste computador, com os agentes globais disponíveis,
> use `/create-project` em vez disto — ele já faz o mesmo processo interativamente.
>
> Cole o bloco abaixo numa sessão nova, no diretório vazio do novo projeto.

```
Quero que você me ajude a bootstrapar um novo projeto de software seguindo um fluxo de
Spec-Driven Development (SDD). Antes de escrever qualquer código, monte a estrutura abaixo e
siga estas regras em toda interação futura neste projeto.

## Pipeline (cada etapa só começa com o artefato aprovado da etapa anterior)

0. [condicional] Se o projeto já tem código legado sem documentação de baseline, primeiro
   documente o sistema como ele é hoje (as-is, sem corrigir nada) num arquivo docs/BASELINE.md.
1. PRD — transforme meu pedido informal num Product Requirements Document: visão geral,
   problema, personas, objetivos, fora de escopo, histórias de usuário com critérios de aceite
   em Gherkin (Dado/Quando/Então), métricas de sucesso, indicadores técnicos (volumetria,
   segurança, legal/compliance) e ordem de valor entre histórias. Salve em specs/<slug>/prd.md.
2. TRD — só depois do PRD aprovado por mim: desenho técnico em ports & adapters, decisão de
   stack tecnológica explícita (nunca implícita), contrato Frontend↔Backend (se houver UI),
   decomposição de tarefas com dependências, plano de testes, e resposta explícita aos pilares
   de engenharia (performance, escalabilidade, resiliência, disponibilidade, observabilidade,
   manutenibilidade). Salve em specs/<slug>/trd.md.
3. Implementação — só depois do TRD aprovado: código de produção via TDD estrito
   (red-green-refactor), nunca implementação antes do teste. Backend em src/ (domain →
   application → adapters, dependência sempre apontando para dentro), frontend (se houver) numa
   pasta separada, consumindo o backend só pelo contrato do TRD. Uma branch por feature, PR
   aberto em modo draft desde o primeiro commit.
4. Revisão de código — um revisor sênior avalia ports & adapters, SOLID, clean code e qualidade
   dos testes (não critério de aceite, isso é QA). Reporta achados, não corrige.
5. QA — valida objetivamente cada critério de aceite do PRD, roda a suíte completa, verifica
   gate de cobertura mínima de 80% por pacote.
6. Segurança — revisão OWASP Top 10, gestão de segredos, autenticação/autorização, validação de
   entrada, dependências vulneráveis.
7. SRE — valida CI/CD, containerização e infraestrutura como código antes do deploy.

## Regras de governança (valem sempre)

- Nenhuma suposição silenciosa: toda ambiguidade que mudaria um artefato é uma pergunta direta
  a mim, nunca uma escolha implícita sua. Se eu não souber responder agora, "validar depois" é
  uma opção válida — registre como pendência e siga com a alternativa mais conservadora.
- Nunca repita a mesma ação/pergunta mais de 3 vezes seguidas sem sucesso. Na 3ª falha, pare e
  me escale o que foi tentado, por que falhou, e sua recomendação.
- Planeje antes de executar: para qualquer etapa que gera código ou mexe em infraestrutura real,
  apresente o plano e peça minha aprovação explícita antes de agir.
- Artefatos aprovados são editados in-place quando algo muda depois — nunca recriados do zero.
- Git = GitHub Flow: branch principal sempre implantável, uma branch por feature, PR obrigatório,
  merge só depois de código+QA+segurança+SRE aprovados.
- Decisões técnicas relevantes (troca de padrão, escolha de tecnologia, trade-off de arquitetura)
  viram um ADR documentado.

## Estrutura de pastas

specs/<slug>/ (prd.md, trd.md, code-review.md, qa-report.md, security-review.md, sre-review.md),
src/ (domain, application, adapters), tests/ (unit, integration, e2e), frontend/ (se houver UI),
infra/ (docker, terraform), docs/ (arquitetura, workflow, gates de qualidade, testes).

## Princípios de código não negociáveis

Ports & Adapters (hexagonal), SOLID, Clean Code (funções pequenas, nomes que revelam intenção,
sem comentário explicando o óbvio, sem código morto, sem abstração especulativa), TDD estrito,
cobertura mínima de 80% por pacote.

Comece perguntando: (1) qual é a ideia/problema do projeto, (2) se já existe código legado a
documentar primeiro, (3) se a stack tecnológica já está decidida ou deve ser proposta por você.
Não escreva nenhum código antes do PRD estar aprovado por mim.
```
