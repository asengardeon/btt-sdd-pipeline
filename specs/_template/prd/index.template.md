<!-- sdd-format-version: 3 -->
# PRD — <Nome da Feature> — Índice

> Status: rascunho | em revisão | aprovado
> Autor: agente `product-design`
> Relacionado: (link para specs anteriores, se houver)
> Modo arquitetural: padrão | mínima mudança (opcional; `mínima mudança` pede ao `architect` o
> modo de `architect/minima-mudanca.md`)

Núcleo pequeno, sempre lido por completo — identidade da feature, escopo, objetivos e os
indicadores que o `architect` precisa antes de decidir arquitetura (`docs/MICRO-CONTEXT.md`,
seção 2b). O conteúdo que cresce por natureza (histórias de usuário, ordem de valor entre fatias,
pendências e log de revisões) vive nos arquivos-filho deste diretório, lidos só quando a tarefa
realmente pedir — ver "Arquivos deste PRD" ao final. **Cada seção abaixo mantém o número que tinha
no PRD de arquivo único** — uma referência a "seção 6 do PRD" em qualquer agente/skill continua
válida, só mudando de arquivo (`user-stories.md`, neste caso).

## 1. Visão geral

Uma a três frases: o que é a feature e por que ela existe agora.

**Escopo: uma spec é uma feature de usuário.** Nomeie aqui, em uma linha, o **objetivo de usuário
único** que esta spec atende. Se o pedido original reunia mais de um, registre a sequência de specs
em que ele foi quebrado e qual é a posição desta — ex.: "2ª de 3: `0007-convite-de-membro`,
**`0008-permissao-por-papel`**, `0009-auditoria-de-acesso`". A spec seguinte da sequência só começa
depois desta fechar, igual ao que já vale entre fatias. Critério de quebra e o custo que ele evita:
`.claude/agents/product-design.md`, passo 1b.

## 2. Problema

Qual problema real do usuário/negócio isto resolve. Evite descrever a solução aqui — só o
problema.

## 3. Usuários / Personas

Quem usa isso e em que contexto.

## 4. Objetivos

- Objetivo mensurável 1
- Objetivo mensurável 2

## 5. Fora de escopo

O que explicitamente NÃO está incluído nesta feature (evita escopo implícito mal-entendido).

## 8. Métricas de sucesso

Como saberemos que a feature funcionou depois de lançada.

## 9. Indicadores técnicos a observar

Não é papel do PRD decidir arquitetura, mas é papel do PRD **sinalizar** o que pode ter peso
técnico significativo, para o `architect` endereçar no TRD. Preencha cada item mesmo que a
resposta seja "nenhum" — não deixe implícito.

- **Volumetria**: ordem de grandeza de dados/tráfego esperado (registros, requisições/segundo,
  crescimento esperado). `<preencher ou "nenhum indicador relevante">`
- **Segurança**: envolve dado sensível/pessoal, autenticação, autorização, ou superfície de
  ataque nova? `<preencher ou "nenhum indicador relevante">`
- **Legal/compliance**: implica LGPD/GDPR, retenção de dados, contrato com terceiro, ou
  regulação específica do domínio? `<preencher ou "nenhum indicador relevante">`

## Arquivos deste PRD

| Arquivo | Seções | Conteúdo | Leia quando |
|---|---|---|---|
| `user-stories.md` | 6-7 | Histórias de usuário, critérios de aceite (gherkin), wireframes/protótipos de tela | Sempre, antes de qualquer decisão de design/implementação — é o contrato de comportamento verificável pelo QA |
| `value-order.md` | 10 | Ordem de valor / dependências entre histórias (fatias verticais de entrega) | Ao decompor em TRD (`architect`) ou escolher a próxima fatia (`/sdd-implement`) |
| `tracking.md` | 11-12 | Pendências VALIDAR DEPOIS + log de revisões | Ao rodar `/sdd-pending`/`/sdd-amend`, ou investigar o histórico de uma mudança |

## 13. Aprovação

- [ ] Aprovado por: <usuário> em <data>
