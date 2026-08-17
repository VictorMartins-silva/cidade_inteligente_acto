---
status: validado
atualizado: "2026-07-22"
dono: engenharia-dados
---

# Fonte - RAIS via BigQuery

## Origem

Base dos Dados (BigQuery) para dados de emprego e renda.

## Formato

Tabelas consultadas via SQL em ambiente BigQuery.

## Periodicidade

Conforme atualizacao oficial da fonte e janelas do projeto.

## Lakehouse alvo

- lh_dados_publicos

## Camadas

- Bronze: extracao da consulta
- Silver: padronizacao de tipos e chaves
- Gold: indicadores comparaveis por municipio/periodo

## Restricoes LGPD

Dados agregados e uso conforme politicas da fonte.

## Referencia tecnica

- GUIA_MESTRE_DADOS_PUBLICOS.md (fonte pessoal, não versionada)
- Acto Cidade Inteligente/Dados Publicos/DOCUMENTACAO_TECNICA.md (fonte pessoal, não versionada)
