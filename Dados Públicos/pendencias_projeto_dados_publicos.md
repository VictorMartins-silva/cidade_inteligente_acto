---
title: Pendências e Próximos Passos — Dados Públicos
date: 2026-07-01
tags:
  - ferramenta/fabric
  - tema/dados-publicos
  - tipo/projeto
projeto: dados-publicos
fonte: documentacao-interna
status: ativo
---
# 📝 Pendências e Próximos Passos: Dados Públicos

Este documento lista as frentes de trabalho concluídas, em andamento e futuras para o projeto de Dados Públicos no Microsoft Fabric.

---

## 🗺️ 1. Mapas Geo SSP — lh_dados_publicos

> Plano detalhado e resultados: [[Documentação_Fabric/Dados Públicos/spec_drive_semana_30_06_2026|Spec Semana 30/06]]

### Concluído em 30/06/2026

- [x] Levantamento: 10 tabelas `silver.ssp_*` com lat/lon confirmadas
- [x] Upload GeoJSON → `lh_dados_publicos/Files/geo/` (11 arquivos: bairros, loteamento, zoneamento, CRAS, etc.)
- [x] `nb_utils_geo_osasco` subido ao Fabric (`nbs/nbs_geo/`)
- [x] `nb_gold_osasco_ssp_criminais_geo` → **62.322 registros** · 100% bairro_geo · 2022–2026 ✅ **tabela de produção**
- [x] ~~`nb_gold_osasco_ssp_dados_criminais_geo`~~ — **descartado**: `ssp_dados_criminais` só tem 2022; `natureza_apurada` mais preciso mas sem valor sem série histórica. `ssp_criminais_geo` cobre tudo com 2022–2026.

### Em andamento

- [ ] **Power BI** — conectar `gold.osasco_ssp_criminais_geo` ao modelo e criar visual Azure Maps
    - Tabela única: `gold.osasco_ssp_criminais_geo` (única de produção)
    - Filtros: `ano_estatistica`, `mes_estatistica`, `bairro_geo`, `descr_conduta`
    - Páginas: Mapa de pontos · Mapa de calor · Crimes por bairro

### Próximos notebooks P2 — semana seguinte

> Template: copiar `nb_gold_osasco_ssp_criminais_geo`, trocar `TABELA_SILVER`, `TABELA_GOLD` e `COL_MUNICIPIO = "nome_municipio_circ"`

- [ ] `nb_gold_osasco_ssp_prisoes_geo` — `silver.ssp_prisoes` (416k linhas)
- [ ] `nb_gold_osasco_ssp_presos_geo` — `silver.ssp_presos_apreendidos` (495k linhas)
- [ ] `nb_gold_osasco_ssp_entorpecentes_geo` — `silver.ssp_entorpecentes` (348k linhas)
- [ ] `nb_gold_osasco_ssp_flagrantes_geo` — `silver.ssp_flagrantes` (254k linhas)

### Fix futuro

- [ ] NaN/Infinity nos Silver SSP — impede SQL Endpoint (Spark lê sem problema, não bloqueia Gold)
- [ ] `silver.osasco_seg_viaria_sinistros` — lat/lon como varchar, requer fix no Silver antes de usar

---

## 🏗️ 2. Ingestão de Novos Domínios (Fase 3.5)

| Domínio | Fonte | Status | Observação |
| :--- | :--- | :--- | :--- |
| **Segurança Pública** | SSP-SP | ✅ Silver OK | 10 tabelas `silver.ssp_*` · Gold geo criadas (P1) |
| **Tabelas Auxiliares** | dim_municipio / dim_calendario | ✅ Concluído | Dimensões para joins cross-domain |
| **Segurança Viária** | InfoSiga | 🔲 Planejado | lat/lon como varchar — requer fix no Silver |
| **Desenv. Humano** | MDS (CadÚnico) | 🔲 Planejado | Média prioridade |
| **Educação (IDEP)** | QEdu / Inep | 🔲 Futuro | Baixa prioridade |

---

## ⚙️ 3. Automação e Operações

- [x] **Agendamento:** Pipeline `pl_monitoramento_ingest` operacional ✅
- [x] **Ambiente:** `env_dados_publicos` com deps BigQuery/Ipeadata ✅
- [ ] **Pipeline geo:** criar `pl_geo_ssp_osasco` para re-execução agendada dos Gold geo
- [ ] **Transição CAGED FTP:** Yuri consolidar troca BigQuery → FTP MTE
- [ ] **Documentação de Linhagem:** grafo de dependências no Purview ou MEGA Guia

---

## 📊 4. Visualização e Semântica (Fase 4)

- [ ] **Modelo Semântico (Import mode):** Unificar Censo, Mercado Trabalho, SSP e Território
- [ ] **Dashboard Demográfico:** Pirâmide etária e indicadores de envelhecimento
- [ ] **Dashboard Econômico:** Evolução do PIB e Empregos Formais
- [ ] **Cruzamentos Cross-Domain:** Renda vs Escolaridade

---

*Atualizado em 30/06/2026.*
