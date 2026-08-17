---
status: rascunho
atualizado: "2026-07-22"
dono: coordenador
valido-ate: "2026-08-31"
---

# Projeto - Acto Santos

## Objetivo

Sustentar e evoluir cadeia de dados Santos no Fabric com consistencia entre notebooks e paineis.

## Escopo de execucao

- manutencao e evolucao dos fluxos Bronze, Silver e Gold
- estabilidade de pipelines com refresh de consumo
- convergencia entre regra de negocio no Gold e indicadores em BI

## Status atual

Em producao com backlog ativo de estabilizacao e padronizacao.

## Proxima acao

Executar plano de estabilizacao por frentes:

1. consolidar observabilidade de pipelines criticos
2. padronizar validacao pre-write e consistencia de escrita
3. alinhar dependencias entre notebooks e paineis priorizados

## Ocorrencias

- divergencias pontuais entre camada Gold e painel
- dependencia de arquivos auxiliares em alguns fluxos
- variacao de padrao entre notebooks equivalentes

## Decisoes locais

- priorizar investigacao ponta a ponta antes de mudanca de codigo em incidente cross-camada
- concentrar regra de negocio em Gold e reduzir compensacao em camada de painel

## Pendencias externas

- confirmacoes funcionais com stakeholders de negocio

## Referencias operacionais

- acervo/engenharia-dados/catalogo-notebooks-santos.md
- acervo/engenharia-dados/catalogo-pipelines-santos.md
- acervo/bi/catalogo-paineis-santos.md
- acervo/consumo-sql-endpoint.md (contratos de consumo por familia de painel)
