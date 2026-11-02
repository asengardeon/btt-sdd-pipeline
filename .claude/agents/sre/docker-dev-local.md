# Docker de desenvolvimento local

Gatilho: o usuário pede "ambiente Docker local", "rodar sem instalar [linguagem/runtime]", ou
equivalente — mesmo sem QA/segurança aprovados para nenhuma feature. Caso de uso distinto de
Docker de produção (área "Docker" do núcleo) — não segue o mesmo checklist (não precisa
multi-stage nem imagem mínima; o objetivo é developer experience, não deploy).

## Estrutura

- Um `docker-compose.yml` na raiz do projeto, um serviço por processo (banco, backend, frontend,
  emuladores de nuvem). `infra/docker/<serviço>/Dockerfile` por serviço quando precisar de build
  customizado.
- Código-fonte montado via bind mount (reflete edição local sem rebuild); dependências compiladas
  (`vendor/`, `node_modules/`) em volume nomeado *separado*, nunca herdadas do bind mount — um
  `composer install`/`npm install` rodado no host (Windows/Mac) gera binários incompatíveis com o
  container Linux.
- Prefira emuladores locais de serviço de nuvem gerenciado em vez de exigir credencial real do dev
  (ver `docs/STACK.md`, "Simulação de nuvem local") — mas **nunca** presuma que uma ferramenta de
  terceiro citada pelo usuário é a que você já conhece só porque os detalhes técnicos batem
  (porta, contagem de serviços, convenções). Verifique a legitimidade de forma independente
  (repositório oficial, publicador, documentação própria) antes de referenciar a imagem num
  `docker-compose.yml` — não é action item, é bloqueante: pare e pergunte ao usuário se não
  conseguir verificar sozinho.
- `.dockerignore` por serviço com código próprio (`vendor`, `node_modules`, `.env`, artefatos de
  build) — mas lembre que `.dockerignore` só afeta o *build* da imagem, não o bind mount em tempo
  de execução: uma pasta de build gerada anteriormente fora do Docker (ex. `.next/`, `vendor/`)
  ainda presente no host sobrepõe o container via bind mount e pode quebrar a aplicação de forma
  enganosa (erro parece de código, é de ambiente sujo).
- Documente a decisão em `docs/STACK.md` (seção "Ferramentas de desenvolvimento local" ou
  equivalente) — deixe explícito que é dev-only e que a arquitetura de produção não muda — e no
  `README.md` (como subir, portas, limitações conhecidas).
- Nunca defina credencial real (AWS, SSO, etc.) no `docker-compose.yml`; variáveis sensíveis
  continuam vindo do `.env` de cada dev, vazias/opcionais, como no fluxo sem Docker.

## Validação — sempre real, nunca só sintaxe

`docker compose config` valida sintaxe, não funcionamento. Este ambiente é também a base que
`docs/TESTING.md` (seção "Preferência por Docker/emuladores locais em vez de produção real")
espera que testes de infraestrutura/navegação usem — mantenha-o funcional de verdade. Antes de
reportar como pronto:

1. **Antes de subir**, verifique conflito de porta/container/processo órfão de sessões anteriores
   (`docker ps -a`, e no host: processo nativo escutando a mesma porta — ex. um `npm run dev` ou
   `php artisan serve` deixado rodando fora do Docker). Um container pode subir "saudável" sem o
   mapeamento de porta ter sido publicado de verdade se a porta já estava ocupada no host — isso
   não gera erro visível, só silenciosamente não funciona do lado de fora.
2. Faça o build de verdade (`docker compose build`) e suba (`docker compose up`) — não presuma
   que `docker compose config` é suficiente.
3. Exercite o caminho funcional real que a infra existe para viabilizar — não só "o container
   subiu": chame o endpoint, grave e leia um objeto no emulador de storage, rode uma migration e
   confira o resultado, etc.
4. Ao terminar de validar, teardown completo — incluindo qualquer processo que você mesmo tenha
   rodado fora do Docker durante a investigação. Um processo ou container de teste esquecido
   rodando quebra a próxima subida de quem usar o ambiente depois de você, de um jeito difícil de
   diagnosticar.
