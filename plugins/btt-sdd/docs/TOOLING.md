# TOOLING.md — ferramentas recomendadas para economia de tokens

Todo agente e toda skill deste pipeline passam boa parte do tempo rodando comandos de shell —
`git diff`/`git log`, suíte de testes, lint, `gh pr view` — cuja saída bruta entra inteira no
contexto de quem chamou. Numa spec com várias fatias e várias etapas de revisão, esse custo se
repete a cada invocação: é o mesmo tipo de desperdício que `docs/MODEL-TIERING.md` resolve para
escolha de modelo, só que para tamanho de saída em vez de tamanho de modelo.

## O que é o rtk

[rtk](https://github.com/rtk-ai/rtk) (Rust Token Killer) é um binário que intercepta chamadas de
shell do Claude Code e comprime a saída de mais de 100 comandos comuns — `git status`/`diff`/`log`,
suítes de teste (`pytest`, `go test`, `npm test`, `cargo test`), linters, `docker ps`, comandos de
nuvem — antes de ela chegar ao contexto do agente. A redução típica é de 60-90% no tamanho da
saída, sem mudar o resultado do comando: o que muda é só o quanto dele entra no contexto.

## Como ele se integra (transparente, por hook)

A forma recomendada de instalação (`rtk init -g`) registra um hook `PreToolUse` no Claude Code:
toda chamada da ferramenta Bash passa a ser reescrita para o equivalente `rtk <comando>`
automaticamente, sem que nenhum agente precise saber que o rtk existe. Isso cobre qualquer agente
e qualquer skill deste pipeline — incluindo subagentes invocados em paralelo
(`backend-developer`/`frontend-developer`) e agentes rodando em worktree isolado
(`docs/GIT-WORKFLOW.md`, seção "Isolamento de working tree entre agentes concorrentes") — porque o
hook vive na configuração do Claude Code, não na sessão ou no agente individual.

**Importante:** o hook só intercepta a ferramenta Bash. Ferramentas nativas (`Read`, `Grep`,
`Glob`) não passam por ele — já são compactas pelo próprio desenho do Claude Code.

## Convenção para agentes e skills deste pipeline

1. **Não dependa do rtk para funcionar.** Todo comando deste pipeline continua correndo
   normalmente, com ou sem rtk instalado — a ferramenta é uma otimização de custo, nunca uma
   dependência funcional. Nenhum passo de nenhuma skill bloqueia por rtk ausente.
2. **Ao montar um comando cuja saída pode ser grande** (suíte de testes completa, `git diff`/`git
   log` sem filtro, lint sobre o repositório inteiro, `docker ps`) — se o binário `rtk` estiver
   disponível no ambiente (`command -v rtk` / `where rtk`) e o hook não estiver claramente ativo
   (ambiente novo, CI, container efêmero), prefira invocar `rtk <comando>` explicitamente em vez do
   comando puro. Com o hook já configurado isso é redundante mas inofensivo (`rtk` detecta e não
   comprime duas vezes); sem o hook, é o que garante o ganho mesmo assim.
3. **Nunca troque o comando por uma versão que mudaria o resultado** (ex.: truncar manualmente a
   saída de um teste, ou adicionar `| head` para "economizar") — isso é diferente de rtk, que
   comprime preservando o sinal (falhas completas, sucesso colapsado em contagem). Truncar à mão
   pode esconder exatamente a falha que a etapa precisa ver.
4. **Diagnóstico rápido**: neste repositório (`btt-sdd-pipeline`), `python scripts/check-rtk.py`
   reporta se o binário está instalado e se o hook parece configurado para esta instalação do
   Claude Code — útil ao investigar por que uma sessão está consumindo mais tokens do que o
   esperado em etapas com muito comando de shell (QA, SRE, revisão de código). Esse script não é
   distribuído com o plugin nem com projetos criados via `/create-project` (não é código de
   produção de nenhum deles) — qualquer projeto pode usar os comandos que o próprio rtk já expõe
   para o mesmo diagnóstico: `rtk --version` e `rtk gain`.

## Orientação para projetos que usam este pipeline

Esta convenção não é só para manter o próprio pipeline — qualquer projeto criado via
`/create-project` ou que instale o plugin `btt-sdd` herda o mesmo padrão de uso intenso de Bash
(testes, lint, Git) em `/sdd-implement`, `/sdd-code-review`, `/sdd-qa`, `/sdd-security`, `/sdd-sre`.
Recomenda-se instalar e configurar o rtk **uma vez por máquina** (não por projeto — o hook é global
ao Claude Code):

```bash
brew install rtk                              # macOS / Linux
winget install rtk-ai.rtk                     # Windows
curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh

rtk init -g                                    # registra o hook global do Claude Code
rtk gain                                       # confirma que está funcionando (painel de economia)
```

Isso é uma recomendação, não um gate — nenhuma etapa deste pipeline falha ou bloqueia por rtk
ausente, e nenhum PRD/TRD precisa mencioná-lo. É puramente uma otimização de custo de sessão.
