#!/usr/bin/env python3
"""Detecta deriva entre as duas cópias do pipeline neste repositório.

O pipeline existe duas vezes: a cópia da raiz (`.claude/agents/`, `.claude/skills/`, `docs/`,
`specs/_template/`), distribuída via junction de diretório, e a cópia empacotada em
`plugins/btt-sdd/`, distribuída via `claude plugin install`. Editar a raiz não atualiza o plugin
(`plugins/btt-sdd/README.md`, "⚠️ Isto é uma cópia, não um link") — e nada, até este script,
verificava se a replicação aconteceu.

Este script compara par a par, normalizando as adaptações legítimas (namespace de comando,
caminho de agente/skill, referência a doc, nome de skill no frontmatter) e ignorando quebra de
linha, e falha apontando o arquivo e o bloco divergente.

Três registros explícitos, nenhum silencioso:

- REGULARES — adaptações que aparecem em muitos arquivos (a mesma informação escrita para o canal
  de distribuição de cada cópia), colapsadas a um token comum nos dois lados.
- DELIBERADAS — divergências específicas de um arquivo. Cada âncora é verificada contra os dois
  lados: se ela deixar de existir, o script falha por "allowlist desatualizada" em vez de deixar de
  comparar em silêncio.
- `plugin-sync-baseline.txt` — deriva que já existia quando este script nasceu, pendente de
  ressincronização. O gate falha só em deriva NOVA, para valer desde o primeiro dia; um par da
  baseline que voltou a estar em dia também falha, obrigando a linha a sair do arquivo.

Uso:
    python scripts/check-plugin-sync.py            # compara tudo
    python scripts/check-plugin-sync.py docs       # só um grupo (docs, agents, skills, templates)

Saída: código 0 se não há deriva nova, 1 se há deriva nova, allowlist desatualizada ou baseline
desatualizada.
"""

from __future__ import annotations

import difflib
import re
import sys
from pathlib import Path

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

RAIZ = Path(__file__).resolve().parent.parent
PLUGIN = RAIZ / "plugins" / "btt-sdd"
BASELINE = Path(__file__).resolve().parent / "plugin-sync-baseline.txt"

# --------------------------------------------------------------------------------------------------
# Divergências deliberadas, por arquivo da raiz.
#
# "pular": o arquivo do plugin é escrito para outro público e não é uma cópia — não comparar.
# "trocas": pares (texto da raiz, texto do plugin) aplicados antes de comparar. Ambos os lados são
#           conferidos: âncora ausente = allowlist desatualizada, não divergência tolerada.
# --------------------------------------------------------------------------------------------------
DELIBERADAS: dict[str, dict] = {
    "docs/FILE-GUIDE.md": {
        "pular": (
            "a cópia do plugin descreve o projeto que INSTALOU o plugin "
            "('os agentes não vivem neste projeto — vêm do plugin'), não este repositório"
        ),
    },
    "docs/SDD-WORKFLOW.md": {
        # A seção final fecha o doc de formas diferentes: a raiz aponta a feature de exemplo deste
        # repositório, o plugin orienta quem acabou de rodar `/btt-sdd:create-project`.
        "cortes": [("## Exemplo completo", "## Primeira feature deste projeto")],
    },
    "docs/TESTING.md": {
        # A seção final dá o comando de teste/cobertura: a raiz mostra o exemplo Python deste
        # repositório, o plugin explica que a stack ainda não foi decidida.
        "cortes": [("## Comando de referência (exemplo Python deste repositório)",
                    "## Comando de referência")],
        "trocas": [
            (
                "- Aplicado automaticamente no CI (`.github/workflows/ci.yml`): o job de testes",
                "- Aplicado automaticamente no CI (`.github/workflows/ci.yml`, criado pelo `sre` "
                "junto com a primeira feature implementada): o job de testes",
            ),
        ],
    },
    ".claude/skills/create-project/SKILL.md": {
        # Como resolver o caminho do scaffold depende do canal: pela raiz deste repositório, ou como
        # pasta irmã do SKILL.md dentro do plugin instalado. A frase sobre este repositório não
        # manter cópia própria do scaffold também só faz sentido aqui.
        "trocas": [
            (
                "todo o conteúdo de `plugins/btt-sdd/skills/create-project/scaffold/` (caminho "
                "relativo à raiz do repositório onde este arquivo `SKILL.md` vive, ou seja "
                "`../../../plugins/btt-sdd/skills/create-project/scaffold/` a partir daqui, de onde "
                "quer que esta skill esteja instalada)",
                "todo o conteúdo da pasta `scaffold/` deste plugin (a pasta irmã deste arquivo "
                "`SKILL.md`, dentro de onde quer que o plugin `btt-sdd` esteja instalado)",
            ),
            (
                "eles vivem em `plugins/btt-sdd/docs/` (ou, via junction, na raiz deste "
                "repositório), lidos diretamente pelos agentes/skills a partir de onde estão "
                "instalados",
                "eles vivem em `docs/` na raiz deste plugin instalado, lidos diretamente pelos "
                "agentes/skills a partir de lá",
            ),
            (
                "Este repositório não mantém uma cópia própria do scaffold em "
                "`«skills»«cmd:create-project»/` — a cópia do plugin é a única fonte, mesma usada "
                "por uma instalação standalone do plugin (ver `plugins/btt-sdd/README.md`). Se o "
                "usuário deu um nome de projeto",
                "Se o usuário deu um nome de projeto",
            ),
        ],
    },
    ".claude/skills/sdd-hotfix/SKILL.md": {
        # `specs/_template/oneshot.template.md` existe só neste repositório (ver SEM_EQUIVALENTE) —
        # não há o que referenciar do lado do plugin.
        "trocas": [
            (
                "pare e migre para o fluxo completo em vez de continuar aqui (mesmo espírito de "
                "`specs/_template/oneshot.template.md`).",
                "pare e migre para o fluxo completo em vez de continuar aqui.",
            ),
        ],
    },
    "docs/ARCHITECTURE.md": {
        "trocas": [
            (
                "Veja `docs/TESTING.md` para como TDD e cobertura se encaixam nessa arquitetura, e "
                "`specs/0001-example-task-management/code-examples.md` para um exemplo documentado "
                "desses princípios aplicados (o código executável correspondente não existe mais "
                "neste repositório).",
                "Veja `docs/TESTING.md` para como TDD e cobertura se encaixam nessa arquitetura.",
            ),
        ],
    },
}

# Conteúdo deliberadamente exclusivo da raiz — não existe equivalente no plugin, por design.
SEM_EQUIVALENTE = {
    ".claude/skills/repo-issues/SKILL.md": "manutenção deste repositório sobre si mesmo",
    "docs/BOOTSTRAP-PROMPT.md": "prompt de bootstrap deste repositório",
    "docs/STACK.md": "stack deste projeto, não conteúdo do pipeline",
    "specs/_template/oneshot.template.md": "template usado só por este repositório",
}


# --------------------------------------------------------------------------------------------------
# Adaptações regulares que aparecem em muitos arquivos — colapsadas a um token comum nos dois lados,
# em vez de repetidas arquivo por arquivo em DELIBERADAS. Cada uma corresponde a um item documentado
# em `plugins/btt-sdd/README.md`, seção "⚠️ Isto é uma cópia, não um link".
# --------------------------------------------------------------------------------------------------
def flex(padrao: str) -> re.Pattern:
    """Compila um padrão tolerante a quebra de linha: cada espaço literal casa qualquer espaço.

    As duas cópias quebram as linhas em pontos diferentes (foram escritas à mão), então uma frase
    que atravessa a quebra não casaria com um padrão que exige um espaço só.
    """
    return re.compile(padrao.replace(" ", r"\s+"))


REGULARES: list[tuple[re.Pattern, str]] = [
    # O parágrafo "onde os docs de governança vivem" difere por canal de distribuição (junction
    # global x pacote do plugin instalado) — é a mesma informação adaptada, não deriva.
    (re.compile(r"Referências como `«doc:.*?(?=\n\n)", re.DOTALL), "«nota:onde-os-docs-vivem»"),
    # Referência cruzada a um agente ou a uma skill: a raiz usa o caminho com o prefixo `.claude/`,
    # o plugin usa o caminho relativo à raiz do pacote — **e nada mais na frase muda**
    # (`plugins/btt-sdd/README.md`, item 3 da lista de replicação). Por isso basta uma regra por
    # tipo: a preposição e o resto da frase são comparados literalmente, dos dois lados.
    #
    # A issue #290 ressincronizou 8 pares que divergiam só por reescritas dessa referência ("siga o
    # mesmo processo descrito no agente `x`" x "siga `agents/x.md`"). Cada variante exigia sua própria
    # regra aqui, e uma regra que engole prosa em volta do nome não distingue reescrita de conteúdo
    # perdido. Se aparecer uma variante nova, o certo é padronizar o texto — não acrescentar regra.
    (flex(r"`«agents»/([a-z-]+)\.md`"), r"«agente-ref:\1»"),
    (flex(r"`«skill:([a-z-]+)»/SKILL\.md`"), r"«skill-ref:\1»"),
    # Dentro do scaffold, um doc do pipeline é referenciado como "<DOC> do pipeline" para
    # distingui-lo de um doc do próprio projeto.
    (flex(r"(«doc:[A-Z-]+»`?) do pipeline"), r"\1"),
    # "padrão/docs de governança deste pipeline" (raiz) x "...deste plugin" (pacote): o mesmo
    # referente, nomeado pelo canal de distribuição de cada cópia.
    (flex(r"(gen[ée]ricos|governança|padrão) d(?:o|este) (?:pipeline|plugin)"),
     r"\1 «da-distribuicao»"),
    # Artefato de quebra de linha: quebrar a linha logo depois de uma barra deixa um espaço espúrio
    # quando o parágrafo é achatado ("navegabilidade/" + "usabilidade"). Não é diferença de
    # conteúdo — as duas cópias quebram as linhas em pontos diferentes porque foram escritas à mão.
    (re.compile(r"/[ \t]*\n[ \t]*"), "/"),
]


def canonizar(texto: str) -> str:
    """Reduz as adaptações legítimas das duas cópias a uma forma neutra comum."""
    t = texto
    # Skills: `.claude/skills/sdd-<n>/SKILL.md` (raiz) e `skills/<n>/SKILL.md` (plugin).
    t = re.sub(r"(?:\.claude/skills/sdd-|(?<![\w/.:-])skills/)([a-z][a-z-]*)/SKILL\.md",
               r"«skill:\1»/SKILL.md", t)
    t = re.sub(r"(?:\.claude/skills/sdd-|(?<![\w/.:-])skills/)([a-z][a-z-]*)/",
               r"«skill:\1»/", t)
    t = re.sub(r"\.claude/skills/sdd-([a-z][a-z-]*)", r"«skill:\1»", t)
    t = t.replace(".claude/skills/", "«skills»/").replace("`skills/`", "`«skills»/`")
    # Agentes: `.claude/agents/<n>.md` (raiz) e `agents/<n>.md` (plugin).
    t = t.replace(".claude/agents/", "«agents»/")
    t = re.sub(r"(?<![\w/.:-])agents/", "«agents»/", t)
    # Comandos: `/sdd-<n>` (raiz) e `/btt-sdd:<n>` (plugin); `/create-project` nos dois formatos.
    t = t.replace("/btt-sdd:create-project", "«cmd:create-project»")
    t = re.sub(r"(?<![\w:-])/create-project", "«cmd:create-project»", t)
    t = re.sub(r"/btt-sdd:([a-z][a-z-]*)", r"«cmd:\1»", t)
    t = re.sub(r"(?<![\w:-])/sdd-([a-z][a-z-]*)", r"«cmd:\1»", t)
    # Docs do pipeline: `docs/TESTING.md` (raiz/projeto) e `TESTING.md` (dentro do scaffold).
    t = re.sub(r"(?:docs/)?(GIT-WORKFLOW|QUALITY-GATES|TESTING|ENGINEERING-PILLARS|ARCHITECTURE"
               r"|SDD-WORKFLOW|FILE-GUIDE|POST-MERGE-VALIDATION)\.md", r"«doc:\1»", t)
    # Nome da skill no frontmatter: `name: sdd-<n>` (raiz) e `name: <n>` (plugin).
    t = re.sub(r"(?m)^name: sdd-([a-z][a-z-]*)\s*$", r"name: \1", t)
    for padrao, token in REGULARES:
        t = padrao.sub(token, t)
    return t


def achatar(texto: str) -> str:
    """Colapsa todo espaço em branco — a comparação é agnóstica de quebra de linha.

    Colapsa também o espaço logo depois de uma barra: as duas cópias quebram as linhas em pontos
    diferentes, e uma quebra depois de `/` vira um espaço espúrio ao achatar o parágrafo.
    """
    return re.sub(r"/ +", "/", re.sub(r"\s+", " ", texto)).strip()


def blocos(texto: str) -> list[str]:
    """Quebra em blocos legíveis (parágrafo, item de lista, linha de tabela, heading)."""
    saida: list[str] = []
    atual: list[str] = []
    for linha in texto.split("\n"):
        nua = linha.strip()
        novo_bloco = nua == "" or re.match(r"^(#{1,6}\s|\||```|(?:[-*+]|\d+\.)\s)", nua)
        if novo_bloco and atual:
            saida.append(" ".join(atual))
            atual = []
        if nua:
            atual.append(nua)
    if atual:
        saida.append(" ".join(atual))
    return [achatar(b) for b in saida]


def pares() -> list[tuple[str, Path, Path, str]]:
    """(grupo, arquivo da raiz, arquivo do plugin, rótulo) para cada par a comparar."""
    p: list[tuple[str, Path, Path, str]] = []
    for doc in sorted((RAIZ / "docs").glob("*.md")):
        alvo = PLUGIN / "docs" / doc.name
        if alvo.exists():
            p.append(("docs", doc, alvo, f"docs/{doc.name}"))
    for agente in sorted((RAIZ / ".claude" / "agents").glob("*.md")):
        p.append(("agents", agente, PLUGIN / "agents" / agente.name,
                  f".claude/agents/{agente.name}"))
    for skill in sorted((RAIZ / ".claude" / "skills").glob("*/SKILL.md")):
        nome = skill.parent.name
        alvo_nome = nome[4:] if nome.startswith("sdd-") else nome
        p.append(("skills", skill, PLUGIN / "skills" / alvo_nome / "SKILL.md",
                  f".claude/skills/{nome}/SKILL.md"))
    scaffold = PLUGIN / "skills" / "create-project" / "scaffold" / "specs" / "_template"
    for tpl in sorted((RAIZ / "specs" / "_template").glob("*.md")):
        p.append(("templates", tpl, scaffold / tpl.name, f"specs/_template/{tpl.name}"))
    return p


def comparar(rotulo: str, origem: Path, alvo: Path) -> list[str]:
    """Devolve a lista de problemas deste par (vazia = em dia)."""
    regra = DELIBERADAS.get(rotulo, {})
    if "pular" in regra:
        return []
    if not alvo.exists():
        if rotulo in SEM_EQUIVALENTE:
            return []
        return [f"{rotulo}: sem equivalente no plugin ({alvo.relative_to(RAIZ)} não existe). "
                f"Replique o arquivo, ou registre a exceção em SEM_EQUIVALENTE deste script."]

    texto_raiz = canonizar(origem.read_text(encoding="utf-8"))
    texto_plugin = canonizar(alvo.read_text(encoding="utf-8"))

    problemas: list[str] = []
    for marcador_raiz, marcador_plugin in regra.get("cortes", []):
        for texto, marcador, lado in ((texto_raiz, marcador_raiz, "raiz"),
                                      (texto_plugin, marcador_plugin, "plugin")):
            if canonizar(marcador) not in texto:
                problemas.append(f"{rotulo}: allowlist desatualizada — o marcador de corte da "
                                 f"{lado} não existe mais: {marcador[:70]!r}")
        if problemas:
            return problemas
        texto_raiz = texto_raiz[:texto_raiz.index(canonizar(marcador_raiz))]
        texto_plugin = texto_plugin[:texto_plugin.index(canonizar(marcador_plugin))]

    for de, para in regra.get("trocas", []):
        de_c, para_c = achatar(canonizar(de)), achatar(canonizar(para))
        if de_c not in achatar(texto_raiz):
            problemas.append(f"{rotulo}: allowlist desatualizada — a âncora da raiz não existe "
                             f"mais: {de[:70]!r}")
        if para_c not in achatar(texto_plugin):
            problemas.append(f"{rotulo}: allowlist desatualizada — a âncora do plugin não existe "
                             f"mais: {para[:70]!r}")
    if problemas:
        return problemas

    plano_raiz, plano_plugin = achatar(texto_raiz), achatar(texto_plugin)
    for de, para in regra.get("trocas", []):
        plano_raiz = plano_raiz.replace(achatar(canonizar(de)), achatar(canonizar(para)), 1)
    if plano_raiz == plano_plugin:
        return []

    # Divergiu: reporta os blocos, que é o que dá para agir.
    blocos_raiz = blocos(texto_raiz)
    blocos_plugin = blocos(texto_plugin)
    toleradas = [(achatar(canonizar(d)), achatar(canonizar(p))) for d, p in regra.get("trocas", [])]
    detalhe: list[str] = []
    for linha in difflib.unified_diff(blocos_raiz, blocos_plugin, lineterm="", n=0):
        if linha.startswith(("---", "+++", "@@")):
            continue
        corpo = linha[1:].strip()
        if any(corpo in de or corpo in para or de in corpo or para in corpo
               for de, para in toleradas):
            continue
        lado = "raiz  " if linha.startswith("-") else "plugin"
        detalhe.append(f"    {lado} | {corpo[:150]}")
    if not detalhe:
        detalhe = ["    (divergência abaixo do nível de bloco — compare os dois arquivos "
                   "diretamente)"]
    return [f"{rotulo}: divergente de {alvo.relative_to(RAIZ)}"] + detalhe[:12]


def carregar_baseline() -> dict[str, str]:
    """Pares já divergentes hoje, com o motivo — o gate falha só em deriva NOVA.

    Cada linha é `<rótulo> # <motivo>`. Um par listado aqui que voltou a estar em dia também falha:
    a linha precisa sair do arquivo, senão a baseline vira um tapete debaixo do qual varrer deriva.
    """
    conhecidas: dict[str, str] = {}
    if not BASELINE.exists():
        return conhecidas
    for linha in BASELINE.read_text(encoding="utf-8").splitlines():
        linha = linha.strip()
        if not linha or linha.startswith("#"):
            continue
        rotulo, _, motivo = linha.partition("#")
        conhecidas[rotulo.strip()] = motivo.strip()
    return conhecidas


def main() -> int:
    grupos = set(sys.argv[1:]) or None
    conhecidas = carregar_baseline()
    novas: list[str] = []
    ja_conhecidas: list[str] = []
    resolvidas: list[str] = []
    comparados = 0
    pulados: list[str] = []
    for grupo, origem, alvo, rotulo in pares():
        if grupos and grupo not in grupos:
            continue
        if "pular" in DELIBERADAS.get(rotulo, {}):
            pulados.append(f"{rotulo} ({DELIBERADAS[rotulo]['pular']})")
            continue
        if not alvo.exists() and rotulo in SEM_EQUIVALENTE:
            pulados.append(f"{rotulo} ({SEM_EQUIVALENTE[rotulo]})")
            continue
        comparados += 1
        problemas = comparar(rotulo, origem, alvo)
        if problemas and rotulo in conhecidas:
            ja_conhecidas.append(f"{rotulo} — {conhecidas[rotulo]}")
        elif problemas:
            novas.extend(problemas)
        elif rotulo in conhecidas:
            resolvidas.append(rotulo)

    print(f"Pares comparados: {comparados}")
    for p in pulados:
        print(f"  ignorado por divergência deliberada: {p}")
    if ja_conhecidas:
        print(f"\nDeriva já conhecida, registrada em {BASELINE.name} "
              f"({len(ja_conhecidas)} arquivo(s)) — pendente de ressincronização:")
        for p in ja_conhecidas:
            print(f"  {p}")
    if resolvidas:
        print(f"\nBaseline desatualizada — estes pares voltaram a estar em dia. Remova a linha "
              f"correspondente de {BASELINE.name}:")
        for p in resolvidas:
            print(f"  {p}")
    if novas:
        print(f"\nDeriva NOVA ({sum(1 for p in novas if not p.startswith('    '))} arquivo(s)):\n")
        for p in novas:
            print(p if p.startswith("    ") else f"  {p}")
        print("\nReplique a mudança para a cópia que ficou atrás (`plugins/btt-sdd/README.md`, "
              "\"⚠️ Isto é uma cópia, não um link\"). Se a divergência for deliberada, registre-a "
              f"em DELIBERADAS deste script; se for deriva antiga a tratar depois, em {BASELINE.name}"
              " — nunca deixe passar sem registro.")
    if novas or resolvidas:
        return 1
    print("\nNenhuma deriva nova." if ja_conhecidas else "\nAs duas cópias estão em dia.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
