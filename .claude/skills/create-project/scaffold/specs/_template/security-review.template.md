# Security Review — <Nome da Feature>

> Autor: agente `security-engineer`
> QA report: `specs/<slug>/qa-report.md`
> PR: <link do Pull Request>
> Data:

## 1. Veredito geral

**Aprovado / Aprovado com ressalvas / Reprovado**

## 2. Superfície de ataque (resumo)

Fronteiras de confiança desta feature (entrada de usuário, chamada externa, arquivo, variável de
ambiente) e por que cada uma é ou não uma superfície de risco.

## 3. OWASP Top 10 (aplicado ao que existe)

| Categoria                                 | Aplicável? | Avaliação                              |
|---------------------------------------------|--------------|-------------------------------------------|
| Injeção                                      |              |                                             |
| Quebra de autenticação                        |              |                                             |
| Exposição de dados sensíveis                  |              |                                             |
| Controle de acesso quebrado                    |              |                                             |
| Configuração insegura                          |              |                                             |
| Componentes com vulnerabilidade conhecida       |              |                                             |
| Falhas de log/monitoramento de segurança         |              |                                             |

(Toda linha precisa de avaliação — "não aplicável" com justificativa é uma resposta válida, em
branco não é.)

## 4. Gestão de segredos

Segredos hardcoded em código/config/log? Segredos via variável de ambiente/secret manager?

## 5. Autenticação / autorização

Se a feature tem noção de identidade/permissão: onde é verificada, e se todo caminho relevante
passa por essa verificação. Se não se aplica, diga por quê.

## 6. Validação de entrada

Toda fronteira de confiança (CLI, request, evento) valida antes de usar? Liste as fronteiras e o
que valida cada uma.

## 7. Dependências

Pacotes novos/alterados no manifesto de dependências, e qualquer vulnerabilidade conhecida
identificável com as ferramentas disponíveis. Se não há scanner automatizado no CI, recomende
(sem implementar aqui).

## 8. Achados (se reprovado ou aprovado com ressalvas)

| # | Área | Esperado | Observado | Severidade |
|---|------|----------|-----------|------------|

## 9. Pendências de validação (VALIDAR DEPOIS)

| ID     | Pergunta                          | Contexto                              | Status              |
|--------|--------------------------------------|-------------------------------------------|------------------------|
| SEC-1  | <pergunta que ficou sem resposta>     | <por que essa pergunta importa>            | pendente / validado |

## 10. Log de revisões

| Data | Autor | O que mudou | Motivo | Etapas revalidadas |
|------|-------|--------------|--------|-----------------------|

## 11. Próximo passo

`/sdd-sre` (se aprovado) ou `/sdd-implement` (se reprovado, com os achados acima).
