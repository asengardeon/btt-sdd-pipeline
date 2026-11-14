# Configuração persistente que liga comportamento: a ordem do deploy não é a ordem dos commits

Gatilho: uma tarefa liga um comportamento por configuração persistente (variável de ambiente de
plataforma, flag, segredo) e o plano diz algo como "a configuração entra por último" para garantir
que as pré-condições (limpeza, correção de segurança) já estejam no código.

Essa garantia vale só para a ordem dos **commits**. O que importa é a ordem de **execução do
deploy**: a variável pode ser gravada por um passo anterior ao push do código, e como é persistente
ela sobrevive a rollback e a falha da release.

Ação, na decomposição de tarefas:

1. Descreva a ordem de execução do deploy, passo a passo (ex.: config → código → release → config),
   e diga em que ponto o comportamento novo passa a valer.
2. Descreva o rollback: a configuração não volta sozinha. Diga quem a reverte e em que passo.
3. Descreva a guarda contra release falha e contra rerun do workflow (idempotência).
4. Marque como **premissa não medida** cada suposição sobre a plataforma de deploy (ex.: o push
   falha quando a release phase falha; o formato da descrição da release). Diga como verificá-la no
   primeiro deploy e faça a guarda **falhar fechada** quando a premissa não se confirmar.

Sem isso, o defeito aparece só no code review ou na segurança, e a correção reabre as etapas
seguintes.
