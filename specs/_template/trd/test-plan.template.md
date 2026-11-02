<!-- sdd-format-version: 2 -->
# TRD — <Nome da Feature> — Plano de testes

> Seção 11 do TRD (`INDEX.md` tem o núcleo e a navegação para os demais arquivos).

## 11. Plano de testes (alto nível)

- Unitário: quais componentes de domínio/aplicação, com quais dublês de port.
- Integração: quais adapters, contra o quê (ex.: banco em memória/container de teste).
- E2E: quais fluxos ponta a ponta.
- Frontend (se aplicável): componentes/serviços testados com dublê do contrato de `contract.md`
  (seção 8).
- Meta de cobertura: 80% por pacote (`src/` e, se aplicável, `frontend/` — ver `docs/TESTING.md`).
