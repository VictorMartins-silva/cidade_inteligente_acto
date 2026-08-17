---
title: Índice Osasco — Notebooks
tags: ["tipo/indice", "municipio/osasco", "ferramenta/fabric", "tipo/notebook"]
municipio: Osasco
aliases: ["osasco", "index osasco", "notebooks osasco"]
description: "Índice de todos os notebooks e projetos do município de Osasco"
status: "ativo"
---
# Osasco — Índice de Notebooks

> [[_mapa-do-vault]] → [[Projetos/osasco-ozmundi]]

---

## Assistência Social

- [[Documentação_Fabric/Osasco/nbs/assistencia_social/atendimento_cras/nb_ingest_atendimento_cras.ipynb|nb_ingest_atendimento_cras]]
- [[Documentação_Fabric/Osasco/nbs/assistencia_social/bolsa_familia/nb_ingest_dump_pbf.ipynb|nb_ingest_dump_pbf]]
- [[Documentação_Fabric/Osasco/nbs/assistencia_social/bolsa_familia/nb_append_pbf.ipynb|nb_append_pbf]]
- [[Documentação_Fabric/Osasco/nbs/assistencia_social/bolsa_familia/nb_gold_pbf.ipynb|nb_gold_pbf]]
- [[Documentação_Fabric/Osasco/nbs/assistencia_social/cad_unico/nb_ingest_bronze_cad_unico.ipynb|nb_ingest_bronze_cad_unico]]
- [[Documentação_Fabric/Osasco/nbs/assistencia_social/cad_unico/nb_silver_cad_unico.ipynb|nb_silver_cad_unico]]
- [[Documentação_Fabric/Osasco/nbs/assistencia_social/cad_unico/nb_gold_cad_unico_pg.ipynb|nb_gold_cad_unico_pg]]
- [[Documentação_Fabric/Osasco/nbs/assistencia_social/rma/nb_ingest_acto_rma.ipynb|nb_ingest_acto_rma]]
- [[Documentação_Fabric/Osasco/nbs/assistencia_social/rma/nb_ingest_acto_rma_creas.ipynb|nb_ingest_acto_rma_creas]]

---

## Bolsa Trabalho

- [[Documentação_Fabric/Osasco/nbs/bolsa_trabalho/nb_ingest_osasco_bolsa_trabalho.ipynb|nb_ingest_osasco_bolsa_trabalho]]
- [[Documentação_Fabric/Osasco/nbs/bolsa_trabalho/nb_gold_bolsa_trabalho.ipynb|nb_gold_bolsa_trabalho]]

---

## BPC

- [[Documentação_Fabric/Osasco/nbs/bpc/nb_ingest_osasco_bpc.ipynb|nb_ingest_osasco_bpc]]
- [[Documentação_Fabric/Osasco/nbs/bpc/nb_gold_osasco_bpc.ipynb|nb_gold_osasco_bpc]]

---

## CAGED

- [[Documentação_Fabric/Osasco/nbs/caged/nb_ingest_caged_dump.ipynb|nb_ingest_caged_dump]]
- [[Documentação_Fabric/Osasco/nbs/caged/nb_append_caged.ipynb|nb_append_caged]]
- [[Documentação_Fabric/Osasco/nbs/caged/nb_gold_sql_caged.ipynb|nb_gold_sql_caged]]

---

## Carta de Serviços

- [[Documentação_Fabric/Osasco/nbs/carta_servicos/nb_ingest_carta_servicos_osasco.ipynb|nb_ingest_carta_servicos_osasco]]
- [[Documentação_Fabric/Osasco/nbs/carta_servicos/nb_ingest_acto_gestao_tempo_etapa_carta_servicos.ipynb|nb_ingest_acto_gestao_tempo_etapa_carta_servicos]]

---

## Censo / Dados Demográficos

- [[Documentação_Fabric/Osasco/nbs/censo/nb_ingest_censo.ipynb|nb_ingest_censo]]
- [[Documentação_Fabric/Osasco/nbs/censo/nb_ingest_populacao_sidra.ipynb|nb_ingest_populacao_sidra]]
- [[Documentação_Fabric/Osasco/nbs/censo/nb_ingest_pib_sidra.ipynb|nb_ingest_pib_sidra]]
- [[Documentação_Fabric/Osasco/nbs/censo/nb_gold_populacao_densidade.ipynb|nb_gold_populacao_densidade]]

---

## Comércio Exterior (COMEX)

- [[Documentação_Fabric/Osasco/nbs/comex/nb_ingest_osasco_comexstat.ipynb|nb_ingest_osasco_comexstat]]

---

## Obras

- [[Documentação_Fabric/Osasco/nbs/obras/nb_ingest_grid_obras.ipynb|nb_ingest_grid_obras]]

---

## RAIS

- [[Documentação_Fabric/Osasco/nbs/rais/nb_ingest_rais_bd.ipynb|nb_ingest_rais_bd]]
- [[Documentação_Fabric/Osasco/nbs/rais/nb_append_rais_ftp.ipynb|nb_append_rais_ftp]]
- [[Documentação_Fabric/Osasco/nbs/rais/nb_gold_rais.ipynb|nb_gold_rais]]

Documentação: [[Documentação_Fabric/Osasco/Demografico_RAIS — Documentação Técnica|Demográfico RAIS]]

---

## Segurança Viária

- [[Documentação_Fabric/Osasco/nbs/seguraca_viaria/nb_ingest_infosiga_seg_viaria.ipynb|nb_ingest_infosiga_seg_viaria]]
- [[Documentação_Fabric/Osasco/nbs/seguraca_viaria/nb_gold_seguranca_viaria.ipynb|nb_gold_seguranca_viaria]]

---

## Segurança Pública

- [[Documentação_Fabric/Osasco/nbs/seguranca_publica/nb_ingest_monitora_oz.ipynb|nb_ingest_monitora_oz]]
- [[Documentação_Fabric/Osasco/nbs/seguranca_publica/nb_gold_osasco_seguranca_publica.ipynb|nb_gold_osasco_seguranca_publica]]

---

## Geolocalização de Dados Criminais SSP-SP

📍 **Novo Projeto:** Mapeamento de registros criminais com enriquecimento geográfico

Documentação & Notebooks:
- [[Documentação_Fabric/Osasco/geo_osasco_ssp_dados_criminais|Geo Osasco — SSP Dados Criminais]] ← 📖 **Documentação Principal**
- Notebooks de desenvolvimento: `c:\Users\victor.silva\Desktop\PROJETOS\Mapeamento_fabric\geo_osasco\`
  - `nb_utils_geo_osasco.ipynb` — Utilitário geo (poligono_osasco, filtrar_para_osasco)
  - `nb_gold_osasco_ssp_dados_criminais_geo.ipynb` — Gold Principal (1.2M → X linhas)
  - `nb_gold_osasco_ssp_criminais_geo.ipynb` — Gold Alternativo (5.1M → Y linhas)
  - `nb_gold_osasco_flagrantes_mapa.ipynb` — Gold Flagrantes

| Aspecto | Detalhes |
|---------|----------|
| **Lakehouse** | `lh_dados_publicos` |
| **Silver** | `silver.ssp_dados_criminais` (~1.2M) ou `silver.ssp_criminais` (~5.1M) |
| **Gold** | `gold.osasco_ssp_dados_criminais_geo` (Osasco + bairro_geo) |
| **Utilitário** | `nb_utils_geo_osasco` (shapefile 60 bairros) |
| **Validações** | Bbox, cobertura bairro_geo ≥80%, série temporal, top naturezas |
| **Status** | ✅ Em desenvolvimento |

---

## Painéis Power BI (24 painéis)

> [[Documentação_Fabric/Osasco/MAPEAMENTO_PAINEIS_PBI_OSASCO|Mapeamento Completo de Painéis PBI — Osasco]]

| Eixo | Painéis |
| --- | --- |
| Assistência Social | CadÚnico · RMA/CRAS · RMA/CREAS · Atend. CRAS · Atend. Trabalhador · Bolsa Família · Bolsa Trabalho · Mapas Vulnerabilidade |
| Desenvolvimento Econômico | PIB · CAGED · Empresas |
| Relações Internacionais | Comércio Exterior |
| Censo / Demográfico | População · Envelhecimento · Fecundidade |
| Segurança Pública e Viária | Ocorrências · Segurança Viária · Inscrições Monitora OZ |
| Desenvolvimento Urbano | Alvarás/Obras · Loteamento/Zoneamento |
| Saúde | CadOZ H1N1 |
| Esporte e Lazer | Atividades Aquáticas |
| Governo e Cidadania | Carta de Serviços |

---

## Mapas / GeoJSON

Pipeline geoespacial local para todos os painéis com visuais de mapa.

- [[Documentação_Fabric/Osasco/Possibilidades_Geolocalizacao_VMC_O|Possibilidades de Geolocalização (VMC)]] — diagnóstico completo: 11 tabelas geo, 6 GeoJSON, roadmap de painéis
- [[Documentação_Fabric/Osasco/mapas-ssp-osasco|Pipeline Mapas SSP Osasco]] — SSP + Shape Map + Azure Maps
- [[Documentação_Fabric/Osasco/mapas_loteamento_zoneamento|Painel Loteamento / Zoneamento]] — spec, estado atual, checklist
- [[Documentação_Fabric/Osasco/guia_pbi_mapas_completo|Guia PBI — Mapas Urbanos (6 sub-abas)]] — passo a passo completo + protótipo visual
- [[Documentação_Fabric/Osasco/guia_pbi_loteamento_zoneamento|Guia PBI — Loteamento / Zoneamento (v1)]] — guia original (2 abas)

**Arquivos prontos (EPSG:4326):** `Mapas_SSP_Osasco/geojson/` · `Mapas_SSP_Osasco/tabelas_pbi/`

| Camada | GeoJSON | Tabela | Chave | Layer ID |
| --- | --- | --- | --- | --- |
| Limite Municipal | `limite_municipal_osasco.json` | — | — | #1 |
| Quadras 2019 | `quadras_osasco.json` | `tb_quadras.csv` | `chave_qd` | #4 |
| Bairros | `bairros_osasco.json` | — | `NOME_NORM` | #89 |
| Loteamento | `loteamento_osasco.json` | `tb_loteamento.csv` | `NOME_LOTEAMENTO` | #90 |
| Zoneamento 1978 | `zoneamento_1978_osasco.json` | `tb_zoneamento_1978.csv` | `zona` | #111 |
| Zoneamento 2024 | `mancha_zoneamento_osasco.json` | `tb_mancha_zoneamento.csv` | `ZONA_2024` | #117 |
| Macrozoneamento | `macrozoneamento_osasco.json` | `tb_macrozoneamento.csv` | `SIGLA` | — |
| CRAS | `assistencia_cras_osasco.json` | — | `CRAS` | — |

---

## Documentação Técnica

- [[Documentação_Fabric/Osasco/Mapeamento Técnico de Notebooks — Osasco|Mapeamento Técnico Osasco]]
- [[Documentação_Fabric/Osasco/exploracao-local-carta-servicos-2026-08-10/investigacao-variacao-cartas-servico-osasco|Investigacao - variacao cartas de servico Osasco (2026-08-10)]]
- [[Documentação_Fabric/Osasco/Demografico_RAIS — Documentação Técnica|Demográfico RAIS]]
- [[Documentação_Fabric/Osasco/MAPEAMENTO_PAINEIS_PBI_OSASCO|Mapeamento Painéis PBI Osasco]]
- [[Documentação_Fabric/doc/DETALHAMENTO_OSASCO_MAUA|Detalhamento Osasco/Mauá]]
- [[Documentação_Fabric/Osasco/analise_incompatibilidade_ssp_criminais_geo_bi_seguranca|Análise — Incompatibilidade ssp_criminais_geo vs dados_criminais (bi_osasco_seguranca_publica)]]

---

## Reuniões

- [[Reunioes/2026-03-30-osasco-reuniao-semanal]]
- [[Reunioes/2026-04-01-osasco-reuniao]]
