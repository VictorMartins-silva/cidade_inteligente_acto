---
title: Detalhamento Técnico — Município de Santos
date: 2026-05-20
tags:
  - municipio/santos
  - ferramenta/fabric
  - tipo/referencia
projeto: acto-santos
fonte: documentacao-interna
status: ativo
---
# Detalhamento Técnico — Município de Santos

## 1. Inventário Completo de Notebooks

| # | Notebook | Domínio | Camada | Tabela(s) de Saída |
|---|---|---|---|---|
| 1 | `nb_ingest_acto_santos` | Geral | Bronze → Gold | `tb_os_acto`, `acto_prazo.csv` |
| 2 | `nb_ingest_dim_date` | Infra | Bronze | `dim_date_1`, `dim_date_2` |
| 6 | `nb_silver_santos_avaliacao` | Avaliação | Silver | `silver_avaliacoes_servico.parquet` |
| 7 | `nb_gold_santos_avaliacao` | Avaliação | Gold | `gold_avaliacoes_servico` |
| 8 | `nb_gold_santos_avaliacao_sentimento` | IA | Gold+IA | `gold_avaliacoes_servicos_sentimento` |
| 12 | `nb_gold_acto_gestao_cet_carga_descarga` | CET | Gold | `gold_cet_carga_descarga` |
| 13 | `nb_gold_acto_gestao_cet` | CET | Gold | `gold_cet_servicos` |
| 15 | `nb_silver_santos_curso_motoristas` | Curso | Silver → Gold | `gold_curso_motorista` |
| 16 | `nb_gold_acto_gestao_manifestacoes_ouvidoria` | Ouvidoria | Gold | `gold_manifestacoes_ouvidoria` |
| 17 | `nb_gold_acto_gestao_ouvidoria_servicos` | Ouvidoria | Gold | `gold_ouvidoria_servicos` |
| 18 | `nb_ingest_silver_acto_gestao_obras_santos` | Obras | Silver | `silver_acto_obras.parquet` |
| 19 | `nb_gold_acto_gestao_obras` | Obras | Gold | `gold_pdr_acompanhamentos_os` |
| 20 | `nb_gold_acto_gestao_obras_etapas` | Obras | Gold | `gold_obras_tempo_etapa` |
| 23 | `nb_gold_acto_gestao_segov` | SEGOV | Gold | `gold_segov_servicos` |
| 24 | `nb_gold_acto_gestao_seinfra` | SEINFRA | Gold | `gold_seinfra_servicos` |

## 2. Detalhamento CET (Trânsito)
- **Logica:** Mapeia 30+ códigos de catálogo.
- **Utils:** Utiliza `nb_utils_api_acto_gestao` para harmonização de bairros e cálculo de SLA de execução.

## 3. Detalhamento Obras
- **Riscos:** R5 (Bloqueio 401).
- **Zonificacao:** SEONT opera em Z1, Z2 e Z3.
- **Tabelas:** `gold_pdr_acompanhamentos_os` é a fonte primária para os 4 dashboards de obras.
