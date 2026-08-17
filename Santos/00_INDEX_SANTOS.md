---
title: Índice Santos — Notebooks
tags: ["tipo/indice", "municipio/santos", "ferramenta/fabric", "tipo/notebook"]
municipio: Santos
aliases: ["santos", "index santos", "notebooks santos"]
description: "Índice de todos os notebooks e projetos do município de Santos"
status: "ativo"
---
# Santos — Índice de Notebooks

> [[_mapa-do-vault]] → [[Conhecimento/Fabric/fabric-workspace-acto-cidade-inteligente|Workspace Santos]]

---

## Utils e Ingestão Base

- [[Documentação_Fabric/Santos/nbs/nb_ingest_acto_santos.ipynb|nb_ingest_acto_santos]] — ingestão principal da API Acto
- [[Documentação_Fabric/Santos/nbs/nb_utils_api_acto_gestao.ipynb|nb_utils_api_acto_gestao]] — funções reutilizáveis da API
- [[Documentação_Fabric/Santos/nbs/nb_utils_api_acto_gestao_obras.ipynb|nb_utils_api_acto_gestao_obras]] — funções para obras
- [[Documentação_Fabric/Santos/nbs/nb_ingest_dim_date.ipynb|nb_ingest_dim_date]] — dimensão de datas
- [[Documentação_Fabric/Santos/nbs/nb_ingest_tb_aux_servicos.ipynb|nb_ingest_tb_aux_servicos]] — ⚠️ carga tb_aux.xlsx (SPOF)

---

## Avaliação de Serviços

Projeto: [[Projetos/sentimento-avaliacao-acto]]

- [[Documentação_Fabric/Santos/nbs/avaliacao_servicos/nb_silver_santos_avaliacao.ipynb|nb_silver_santos_avaliacao]] — Silver
- [[Documentação_Fabric/Santos/nbs/avaliacao_servicos/nb_gold_santos_avaliacao.ipynb|nb_gold_santos_avaliacao]] — Gold
- [[Documentação_Fabric/Santos/nbs/avaliacao_servicos/nb_gold_santos_avaliacao_sentimento.ipynb|nb_gold_santos_avaliacao_sentimento]] — Gold+IA (sentimento Groq)

---

## Obras Públicas — SEONT

Documentação: [[Documentação_Fabric/Santos/obras/Processo Obras Santos]] | Bugs: [[Documentação_Fabric/Santos/obras/ESP_DRIVE_OS_MULTIPLAS_ETAPAS]]

- [[Documentação_Fabric/Santos/nbs/obras/nb_ingest_silver_acto_gestao_obras_santos.ipynb|nb_ingest_silver_acto_gestao_obras_santos]] — Silver obras ⚠️ R5: parado desde 11/03/2025 (HTTP 401)
- [[Documentação_Fabric/Santos/nbs/obras/nb_gold_acto_gestao_obras.ipynb|nb_gold_acto_gestao_obras]] — Gold base PDR
- [[Documentação_Fabric/Santos/nbs/obras/nb_gold_acto_gestao_obras_etapas.ipynb|nb_gold_acto_gestao_obras_etapas]] — Gold etapas
- [[Documentação_Fabric/Santos/nbs/obras/SEONT/nb_gold_acto_gestao_obras_seont_os.ipynb|nb_gold_acto_gestao_obras_seont_os]] — Gold SEONT (~202 OS)

### Análise de Process Mining

- [[Santos/nbs_analise/process_mining_obras_santos|Process Mining — Projeto Urbanístico]] — análise de fluxo real vs teórico, ghost stages, retrabalho e proposta de reforma (concluído 2026-05-13)
  - Notebook: `pm4py/nb_process_mining_obras_santos.ipynb`
  - Relatório HTML: `pm4py/relatorio_process_mining_santos.html`
  - Achados: 43,7% retrabalho · 5 ghost stages · cluster SEONT = 68% dos loops

---

## Carta de Serviços / SLA

Projeto: [[Projetos/carta-servicos/carta-servicos-sla|carta-servicos-sla]]

- [[Documentação_Fabric/Santos/nbs/carta_servicos/nb_ingest_carta_servicos_santos|nb_ingest_carta_servicos_santos]]

---

## Manifestações Ouvidoria

- [[Documentação_Fabric/Santos/nbs/manifestação_ouvidoria/nb_gold_acto_gestao_manifestacoes_ouvidoria.ipynb|nb_gold_acto_gestao_manifestacoes_ouvidoria]]
- [[Documentação_Fabric/Santos/nbs/manifestação_ouvidoria/nb_gold_acto_gestao_ouvidoria_servicos.ipynb|nb_gold_acto_gestao_ouvidoria_servicos]]

---

## CET — Trânsito e Motoristas

- [[Documentação_Fabric/Santos/nbs/cet/nb_ingest_estrutura_cet.ipynb|nb_ingest_estrutura_cet]]
- [[Documentação_Fabric/Santos/nbs/cet/nb_ingest_silver_cet_carga_descarga.ipynb|nb_ingest_silver_cet_carga_descarga]]
- [[Documentação_Fabric/Santos/nbs/cet/nb_gold_acto_gestao_cet.ipynb|nb_gold_acto_gestao_cet]]
- [[Documentação_Fabric/Santos/nbs/cet/nb_gold_acto_gestao_cet_carga_descarga.ipynb|nb_gold_acto_gestao_cet_carga_descarga]]
- [[Documentação_Fabric/Santos/nbs/cet/curso_motoristas/nb_ingest_santos_curso_motoristas.ipynb|nb_ingest_santos_curso_motoristas]]
- [[Documentação_Fabric/Santos/nbs/cet/curso_motoristas/nb_silver_santos_curso_motoristas.ipynb|nb_silver_santos_curso_motoristas]]

---

## Secretarias (SEGOV / SEINFRA / SEPREF)

- [[Documentação_Fabric/Santos/nbs/segov/nb_gold_acto_gestao_segov.ipynb|nb_gold_acto_gestao_segov]]
- [[Documentação_Fabric/Santos/nbs/seinfra/nb_gold_acto_gestao_seinfra.ipynb|nb_gold_acto_gestao_seinfra]]
- [[Documentação_Fabric/Santos/nbs/sepref/nb_gold_acto_gestao_sepref.ipynb|nb_gold_acto_gestao_sepref]]

---

## Documentação Técnica

- [[Documentação_Fabric/doc/DOCUMENTACAO_CONSOLIDADA_FABRIC|Documentação Consolidada Fabric]]
- [[Documentação_Fabric/doc/fabric_santos_nbs_analise|Análise de Dependências (R1–R9)]]
- [[Documentação_Fabric/doc/Mapeamento Técnico de Notebooks — Município de Santos|Mapeamento Técnico de Notebooks]]
