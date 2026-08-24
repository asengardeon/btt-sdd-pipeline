# Security Review — Gestão simples de tarefas (exemplo do pipeline SDD)

> Autor: agente `security-engineer`
> QA report: `specs/0001-example-task-management/qa-report.md`
> PR: não aplicável — feature commitada diretamente em `main` no commit inicial, antes da política
> de GitHub Flow (ver `docs/GIT-WORKFLOW.md`, "Exceção histórica")
> Data: 2026-08-24

## 1. Veredito geral

**Aprovado**

## 2. Superfície de ataque (resumo)

Única fronteira de confiança: os argumentos de linha de comando (`create <título>`,
`complete <id>`) passados ao `TaskCLI.run` (`src/adapters/inbound/cli.py`). Sem rede, sem
arquivo, sem variável de ambiente lida pela aplicação. Superfície de ataque mínima por design —
CLI local, execução curta, sem persistência entre execuções.

## 3. OWASP Top 10 (aplicado ao que existe)

| Categoria                                 | Aplicável? | Avaliação                              |
|---------------------------------------------|--------------|-------------------------------------------|
| Injeção                                      | Não          | Nenhum comando de shell, SQL ou similar é construído a partir de entrada do usuário — `argparse` só popula atributos Python, sem `eval`/`exec`/subprocess. |
| Quebra de autenticação                        | Não          | Não há autenticação nesta feature (CLI local, uso pessoal, fora de escopo por PRD). |
| Exposição de dados sensíveis                  | Não          | Nenhum dado sensível é processado ou armazenado (título de tarefa é o único dado, não classificado como sensível pelo PRD). |
| Controle de acesso quebrado                    | Não          | Sem múltiplos usuários/permissões — fora de escopo por PRD. |
| Configuração insegura                          | Não          | Sem configuração externa (arquivo de config, variável de ambiente) para a aplicação errar. |
| Componentes com vulnerabilidade conhecida       | Não (ver seção 7) | Sem dependências de runtime além da stdlib Python — ver seção 7 para dependências de dev. |
| Falhas de log/monitoramento de segurança         | Não          | Não se aplica — CLI local sem requisito de auditoria de segurança (ver `docs/ENGINEERING-PILLARS.md`/TRD seção 8, "Observabilidade"). |

## 4. Gestão de segredos

Nenhum segredo na aplicação — não há credencial, token, chave de API ou dado similar em código,
config ou log. `_format_task` não expõe nada além do próprio conteúdo da tarefa (título/status).

## 5. Autenticação / autorização

Não se aplica — a feature não tem noção de identidade/permissão, e o PRD marca
autenticação/múltiplos usuários explicitamente como fora de escopo.

## 6. Validação de entrada

Única fronteira: argumentos de CLI. `Task.__post_init__` (`src/domain/task.py`) rejeita título
vazio/em branco (`EmptyTaskTitleError`) antes de qualquer persistência — validado no domínio, não
no adapter, então vale para qualquer adapter de entrada futuro, não só a CLI atual.
`CompleteTaskUseCase` rejeita id inexistente (`TaskNotFoundError`) antes de qualquer efeito.
Nenhuma entrada é usada sem passar por essas validações.

## 7. Dependências

Runtime: nenhuma (só stdlib Python). Dev (`pyproject.toml`): `pytest`, `pytest-cov`, `ruff` —
ferramentas de desenvolvimento amplamente usadas, não embarcadas na imagem de produção (ver
`infra/docker/Dockerfile`, estágio `runtime` só copia o venv de produção). Recomendação para
projetos reais construídos a partir deste template: configurar um scanner de dependências (ex.:
`pip-audit`) no `ci.yml` — não implementado aqui porque não foi pedido para esta rodada e esta
feature de exemplo não tem dependência de runtime a escanear.

## 8. Achados

Nenhum.

## 9. Pendências de validação (VALIDAR DEPOIS)

Nenhuma.

## 10. Log de revisões

| Data       | Autor            | O que mudou    | Motivo                                                        | Etapas revalidadas |
|------------|-------------------|------------------|-------------------------------------------------------------------|------------------------|
| 2026-08-24 | sessão Claude Code | Criação deste artefato | Adição do agente `security-engineer` (etapa 5) ao pipeline SDD | Nenhuma — primeira versão |

## 11. Próximo passo

`/sdd-sre`.
