---
status: validado
atualizado: "2026-07-22"
dono: coordenador
---

# Visao Geral da Plataforma

## Escopo

Plataforma Acto Cidade Inteligente com Microsoft Fabric para ingestao, transformacao e analytics municipal, conectando operacao, indicadores e consumo em Power BI.

Municipios em foco atual:

- Santos (operacao principal)
- Osasco (frentes ativas de dados publicos e social)
- Maua (frente com menor volume e evolucao controlada)

## Topologia base

Fonte -> Bronze -> Silver -> Gold -> SQL Endpoint/Semantic Model -> Power BI

Extensao arquitetural em evolucao:

- Gold+IA para enriquecimentos analiticos orientados a produto, sem quebrar rastreabilidade da cadeia Gold.

## Principios

- Logica de negocio preferencialmente no Gold
- Padroes compartilhados em instrucoes e utilitarios
- Mudancas de alto impacto com revisao e rastreabilidade
- Validacao de qualidade antes de publicacao

## Padrões transversais

- nomenclatura de notebooks por camada, municipio e dominio
- separacao clara entre ingestao, tratamento e publicacao
- validacao de rowcount antes de escrita em tabela de consumo
- preferencia por tabela Delta no Gold para consumo estavel

## Responsabilidades macro

- Engenharia de Dados: qualidade de carga, padroes de transformacao e governanca de pipeline
- BI: consistencia semantica, padrao visual e criterios de publicacao
- Operacao de projeto: priorizacao de backlog e validacao com stakeholders

## Riscos estruturais conhecidos

- dependencia de fontes externas e mudanca de schema
- credenciais e governanca de acesso
- falha silenciosa em orquestracao sem alerta
- divergencia entre numero de notebook e painel sem reconciliacao

## Referencias

- GUIA_MESTRE_COPILOT.md
- doc/00_MAPA.md
- _DADOS_LOCAIS_HISTORICO/Santos/Referencia_Tecnica_Fabric_Santos_v2_0.md
