---
status: rascunho
atualizado: "2026-07-22"
dono: coordenador
valido-ate: "2026-08-31"
---

# Projeto - Geo Osasco

## Objetivo

Entregar visao geoespacial consistente de ocorrencias criminais para consumo em painel.

## Escopo funcional

- recortar eventos criminais para limite geografico de Osasco
- enriquecer ocorrencias com bairro_geo por spatial join
- disponibilizar base Gold pronta para analise espacial no Power BI

## Status atual

Em desenvolvimento com base Gold georreferenciada e pendencias de homologacao final.

Concluido nesta fase:

- pipeline Bronze -> Silver -> Gold estabilizado
- utilitario geoespacial reutilizavel implementado
- validacao de cobertura geoespacial registrada (meta minima atendida)

## Proxima acao

Fechar validacao funcional de filtros e consistencia final no painel.

## Ocorrencias

- divergencia historica por grafia de bairro em campo textual
- necessidade de priorizar uso de bairro_geo para visualizacao final
- necessidade de validar performance do painel com volume real

## Decisoes locais

- usar dados georreferenciados como referencia principal para analise por bairro
- manter duas tabelas Gold com finalidades diferentes (tipificacao detalhada e cobertura ampla)

## Pendencias externas

- confirmacao de stakeholders sobre publicacao e operacao continua

## Fontes e artefatos relacionados

- fonte: acervo/fontes/ssp-sp.md
- notebook utilitario: geo_osasco/nb_utils_geo_osasco.ipynb (fonte pessoal, não versionada)
- notebook Gold principal: geo_osasco/nb_gold_osasco_ssp_dados_criminais_geo.ipynb (fonte pessoal, não versionada)
