# Por que a base de diff nunca é um SHA salvo direto

Gatilho: dúvida sobre por que usar `git merge-base` em vez do SHA salvo numa tabela, ou sobre o
que "completo" significa numa auditoria de fatia final.

Este repositório prefere *squash merge* (`docs/GIT-WORKFLOW.md`): o merge de uma fatia vira um
único commit novo em `main`, diferente de qualquer commit que existia na branch da fatia antes do
merge. Isso significa que o SHA registrado na coluna `Commit` da tabela "Histórico de aprovações
por fatia" (capturado como "HEAD no momento da revisão", ou seja **antes** do merge) deixa de ser
ancestral de `main` depois do squash — usá-lo direto como base de `git diff` produz uma base
incorreta (recua até antes da fatia inteira, mostrando um diff gigante e errado). Já aconteceu
numa sessão real: o agente só percebeu porque `git merge-base --is-ancestor` deu falso, exigindo
uma investigação extra não prevista.

- Para o **fast path** (só precisa da fatia imediatamente anterior), **sempre** use `git
  merge-base HEAD main` como base — nunca o SHA salvo em nenhuma tabela. `merge-base HEAD main`
  já calcula a divergência real entre a branch atual e `main` sem depender de nenhum commit salvo
  em texto, então é sempre correto independente de squash.
- Para a **auditoria completa** (precisa acumular tudo que foi fast-pathed desde a última
  auditoria de verdade, que pode ser várias fatias atrás), o SHA salvo na tabela *pode* ser
  necessário (é o único jeito de alcançar uma fatia mais antiga que a imediatamente anterior).
  Antes de usá-lo, confirme a ancestralidade (`git merge-base --is-ancestor <commit> main`, código
  de saída 0 = ainda ancestral, pode usar direto como base). Se não for mais ancestral (caso
  comum, já que esse SHA é capturado antes do merge), localize o commit de squash correspondente
  em `main` a partir do PR daquela mesma linha da tabela (coluna `PR`): `git log --oneline --grep
  "#<N>" main` (ou `gh pr view <N> --json mergeCommit -q .mergeCommit.oid` se o remote GitHub
  estiver acessível), e use esse commit de squash como base. Se nenhuma das duas formas encontrar
  o commit (histórico reescrito, PR de outro repositório), trate como se nenhuma fatia anterior
  tivesse `Profundidade = completo`.

**"Completo" significa confirmar objetivamente, não reescrever a narrativa inteira.** Para uma
área cujo diff acumulado (calculado acima) comprovadamente não toca nenhum arquivo relevante,
"revisar por completo" significa confirmar isso com um comando real (`git diff --stat` ou
equivalente) e registrar o veredito em uma linha citando esse comando como evidência — não
reescrever do zero a investigação inteira em prosa só porque é a fatia final. Prosa detalhada de
investigação continua obrigatória só para a(s) área(s) que o diff efetivamente toca.
