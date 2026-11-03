#!/usr/bin/env bash
# Confirma mecanicamente que o passo 9 de .claude/skills/sdd-migrate/SKILL.md (esvaziar o corpo
# do arquivo legado, mantendo só título + banner de migração) foi de fato executado — em vez de
# depender de quem roda a migração lembrar de fazer isso sozinho.
#
# Uso: scripts/check-legacy-emptied.sh <arquivo-legado>
# Saída: "OK" e exit 0 se só título + banner sobram; senão lista as linhas extras e exit 1.
#
# Nasceu da issue #602 (asengardeon/btt-sdd-pipeline): todas as execuções anteriores de
# /sdd-migrate num projeto consumidor fizeram a transformação para v2 corretamente, mas nenhuma
# esvaziou o arquivo legado — 75 arquivos com ~78.700 linhas de conteúdo original duplicado atrás
# do banner, só percebido por auditoria manual. O passo 9 ser só prosa, sem verificação própria,
# permitiu a lacuna silenciosa em toda execução anterior.

FILE="$1"
if [ -z "$FILE" ]; then
  echo "Uso: check-legacy-emptied.sh <arquivo-legado>"
  exit 2
fi
if [ ! -f "$FILE" ]; then
  echo "Arquivo não encontrado: $FILE"
  exit 2
fi

awk -v file="$FILE" '
  NR == 1 && /^#[[:space:]]/ { next }   # título
  /^[[:space:]]*$/ { next }              # linha vazia
  /^>/ { next }                          # linha do banner (blockquote)
  { n++; extra[n] = NR ": " $0 }
  END {
    if (n > 0) {
      print "FALHOU — conteúdo extra além de título/banner em " file ":"
      for (i = 1; i <= n; i++) print "  " extra[i]
      exit 1
    }
    print "OK — só título + banner em " file
  }
' "$FILE"
