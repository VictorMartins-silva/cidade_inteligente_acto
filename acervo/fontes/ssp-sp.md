---
status: validado
atualizado: "2026-07-22"
dono: engenharia-dados
---

# Fonte - SSP SP

## Origem

Dados criminais da Secretaria de Seguranca Publica de Sao Paulo.

- mantenedor: SSP-SP
- recorte operacional no projeto: municipio de Osasco

## Formato

Dataset com ocorrencias, localizacao e tipificacao.

Campos estruturais usados no consumo atual:

- data_ocorrencia
- natureza_apurada
- latitude
- longitude
- ano_bo
- municipio

## Periodicidade

Conforme rotina definida no projeto Geo Osasco.

## Lakehouse alvo

- lh_dados_publicos

## Camadas

- Bronze: coleta de dados brutos
- Silver: limpeza e padronizacao
- Gold: enriquecimento geoespacial e consumo BI

## Tabelas tecnicas em uso

- silver.ssp_dados_criminais
- silver.ssp_criminais
- gold.osasco_ssp_dados_criminais_geo
- gold.osasco_ssp_criminais_geo

## Regras de qualidade operacionais

- validacao de coordenadas dentro do bbox de Osasco
- cobertura minima de bairro_geo: 80%
- validacao de volume antes de publicacao em Gold

## Dependencia geoespacial

- arquivo de apoio: Files/geo/bairros_osasco.json
- funcao utilitaria de filtro espacial em geo_osasco/nb_utils_geo_osasco.ipynb

## Restricoes LGPD

Tratar campos sensiveis e evitar exposicao indevida em relatorios.

## Referencia tecnica

- geo_osasco/OBSIDIAN_CONEXAO.md (fonte pessoal, não versionada)
- Documentação_Fabric/Osasco/geo_osasco_ssp_dados_criminais.md (fonte pessoal, não versionada)
