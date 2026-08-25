# Oneshot — <Nome da tarefa>

> Uso: mudanças pequenas e de baixo risco (bugfix simples, ajuste pontual, tarefa técnica óbvia)
> que não justificam passar pelo pipeline completo (PRD → TRD → implementação → code review → QA
> → segurança → SRE) nem acionar os agentes dedicados de cada etapa. Preenchido e executado numa
> única sessão, sem agente — se a tarefa crescer em complexidade ou risco durante a execução, pare
> e migre para o fluxo completo (`/sdd-prd`) em vez de continuar aqui.

## 1. O que precisa ser feito

Uma a três frases: o problema/pedido e o resultado esperado.

## 2. Escopo

O que está incluído. O que explicitamente NÃO está incluído.

## 3. Critérios de aceite

```gherkin
Cenário: <nome>
  Dado <contexto>
  Quando <ação>
  Então <resultado esperado>
```

## 4. Abordagem técnica

O essencial: onde mexer, o que muda, alguma decisão relevante. Sem seção própria por pilar de
engenharia — só o que é preciso dizer para alguém implementar sem ambiguidade.

## 5. Tarefas

- [ ] Tarefa 1 (com teste)
- [ ] Tarefa 2 (com teste)

## 6. Definição de pronto

- [ ] Critérios de aceite da seção 3 verificados
- [ ] Testes automatizados cobrindo o que mudou, suíte passando
- [ ] Lint sem erros
- [ ] Sem violação óbvia de segurança (segredo exposto, entrada não validada)

## 7. Notas / riscos

Qualquer suposição assumida ou risco aceito ao pular o pipeline completo.
