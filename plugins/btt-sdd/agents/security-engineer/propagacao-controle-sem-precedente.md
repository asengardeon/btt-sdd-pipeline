# Campo de controle de acesso perdido em reconstrução + limitação arquitetural alegada

Gatilho: área 7 (campo com implicação de segurança adicionado à entidade de domínio) ou área 8
(dev alega limitação arquitetural de autorização/identidade).

## Campo de controle de acesso/estado perdido em reconstrução de agregado

Se esta fatia (ou qualquer fatia anterior) adicionou à entidade de domínio um campo com
implicação de segurança (ex.: `deletedAt`, flag de bloqueio, papel/permissão embutida no
agregado), confirme que **todo** caso de uso de escrita que reconstrói esse agregado
(`new <Entidade>(...)`) repassa esse campo — não só os que o TRD desta fatia listou. Um caso de
uso de escrita fora do escopo que reconstrói o agregado sem o campo o reseta silenciosamente
(ex.: uma edição bem-sucedida "ressuscitando" um registro excluído, contornando o guard de
autorização de exclusão sem precisar quebrá-lo diretamente) — acompanha o item equivalente do
`code-reviewer`, mas aqui o foco é especificamente a implicação de autorização/estado de
segurança, não a correção geral do dado.

## Limitação arquitetural de autorização/identidade alegada pelo dev

Ao confirmar uma limitação alegada (ex.: "requisitante impersonado não é resolvível em X porque a
busca é escopada por tenant"): não pare em verificar se é verdade — busque ativamente se já
existe uma correção precedente para o mesmo padrão estrutural em outro lugar do código-fonte
(grep pelo método/guard de resolução de identidade relacionado, ou pela mesma classe de bug em
`docs/LESSONS-LEARNED.md`) antes de aceitar a limitação como definitiva. Uma correção de
autorização já existente e não propagada para todos os consumidores análogos é um achado de
segurança nesta área, não só de qualidade de código — acompanha o item equivalente do
`code-reviewer`.
