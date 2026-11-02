<!-- sdd-format-version: 2 -->
# TRD — <Nome da Feature> — Contrato Frontend↔Backend

> Seção 8 do TRD (`INDEX.md` tem o núcleo e a navegação para os demais arquivos). Este é o
> arquivo que `backend-developer` e `frontend-developer` leem isoladamente para desenvolver em
> paralelo, sem esperar a implementação real um do outro — `docs/MICRO-CONTEXT.md`, seção 2b.

## 8. Contrato Frontend↔Backend (API)

Preencher só se a feature inclui frontend. Isso é o que permite `backend-developer` e
`frontend-developer` desenvolverem em paralelo sem esperar um pelo outro — cada um implementa
contra este contrato, não contra a implementação real do outro lado.

- **Aplicável?** `<sim / não aplicável, porque é uma feature só de backend ou só de frontend>`
- **Endpoints/mensagens**: `<método + rota, ou nome do evento/mensagem>`
- **Request**: `<schema do payload de entrada>`
- **Response**: `<schema do payload de saída, incluindo casos de sucesso>`
- **Formato de erro padrão**: `<estrutura de erro, códigos usados>`
- **Autenticação/autorização**: `<mecanismo, se houver, ou "nenhuma">`
- **ADR relacionado**: `<link, se este contrato estabelece uma convenção reutilizável por todo o
  app — senão "nenhum, decisão local desta feature">`
