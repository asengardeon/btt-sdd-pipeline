# Investigação de acesso a recursos privados: meça também as ações (`uses:`)

Gatilho: o TRD tem (ou precisa de) uma tarefa de investigação de acesso a recursos privados da
organização — pacote de registry privado, repositório privado — que o CI vai consumir.

Ação: a tarefa mede **cada forma de consumo** que o CI vai usar, não só a leitura do pacote. Para
cada `uses:` externo (ação composta ou workflow reutilizável publicado em outro repositório
privado da mesma organização), o artefato da investigação registra, como `[medido]`:

1. A configuração de acesso de Actions do repositório que publica a ação
   (`gh api repos/<dono>/<repo>/actions/permissions/access`). O valor `none` impede o consumo por
   outro repositório.
2. O resultado de um workflow de sonda, numa branch descartável, que usa a ação de verdade. O passo
   "Set up job" é onde o erro `repository not found` aparece quando o acesso falta.

Sem essa medição, a ação entra no CI como premissa, e a falha só aparece no QA da fatia. Se a
medição mostrar acesso negado, o TRD escolhe a alternativa (ex.: ação pública equivalente, com o
registro configurado no passo) antes de a fatia começar.
