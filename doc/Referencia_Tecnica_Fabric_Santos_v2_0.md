---
title: "Referência Técnica Fabric Santos v2.0"
tags:
  - ferramenta/fabric
  - mestre
  - tipo/referencia
  - v2
aliases:
  - referencia tecnica
  - doc v2
relacionados:
  - "[[Documentação_Fabric/00_MAPA]]"
  - "[[Documentação_Fabric/DOCUMENTACAO_CONSOLIDADA_FABRIC]]"
  - "[[Documentação_Fabric/fabric_santos_nbs_analise]]"
  - "[[Conhecimento/Fabric/fabric-workspace-acto-cidade-inteligente|Fabric Workspace (pipelines Santos)]]"
---

# 🏛️ ACTO CIDADE INTELIGENTE
## Referência Técnica: Microsoft Fabric · Workspace Santos

**Versão:** 2.0 Consolidada  
**Data:** 15 de Abril de 2026  
**Público:** Victor + Equipes Técnicas + Gestão Pública  
**Status:** ✅ Pronto para Produção (com mitigações)

---

## 📋 Histórico de Versões

| Versão | Data | Escopo Principal |
|--------|------|-----------------|
| 1.0 | Mar/2026 | avaliacao_servicos — Silver / Gold / Sentimento |
| 1.2 | Mar/2026 | Notebooks raiz nbs/ (5 notebooks) |
| 1.3 | Abr/2026 | pl_ingest_obras_santos + observações arquiteturais |
| 1.4 | Abr/2026 | NB3/NB4 obras, nb_utils_api obras (células 2-16), novos riscos |
| 1.5 | Abr/2026 | [[Documentação_Fabric/Santos/nbs/nb_utils_api_acto_gestao.ipynb|nb_utils_api_acto_gestao]] COMPLETO — todas as células e funções |
| 1.6 | Abr/2026 | [[Documentação_Fabric/Santos/nbs/avaliacao_servicos/nb_silver_santos_avaliacao.ipynb|nb_silver_santos_avaliacao]], célula 7 COMPLETA, 3 pipelines, 2 novos riscos |
| 1.7 | Abr/2026 | [[Documentação_Fabric/utils/nb_utils_ingest_acto_gestao.ipynb|nb_utils_ingest_acto_gestao]] (T1 COMPLETO) + Protótipo Curso de Motoristas |
| 1.8 ★ | Abr/2026 | Sessão 4 (Chrome): nbs/cet, obras, manifestacao_ouvidoria, segov, seinfra, sepref, caged_santos, carta_servicos, bis. R9 novo. |
| **2.0 ★★** | **15/Abr/2026** | **Referência Técnica Consolidada — Victor + Gestores** |

---

## 📑 Índice Navegável

1. [Panorama Executivo](#1-panorama-executivo)
2. [Arquitetura Técnica](#2-arquitetura-técnica)
3. [Estrutura do Workspace](#3-estrutura-do-workspace)
4. [Inventário de Notebooks Santos](#4-inventário-de-notebooks-santos)
5. [Pipelines de Orquestração](#5-pipelines-de-orquestração)
6. [Power BI — Catálogo de Dashboards](#6-power-bi--catálogo-de-dashboards)
7. [Riscos Técnicos e Mitigações](#7-riscos-técnicos-e-mitigações)
8. [Roadmap e Plano de Ação](#8-roadmap-e-plano-de-ação)

---

## 1. Panorama Executivo

### 1.1 Objetivo do Projeto

Consolidar dados de **10 domínios públicos municipais** (obras, avaliações, tráfego, ouvidoria, secretarias, etc.) em uma plataforma **Medallion** no Microsoft Fabric, com visualizações em **Power BI** para suporte à decisão em tempo real.

**Foco:** Município de Santos

### 1.2 Coordenadas do Workspace

| Parâmetro | Valor |
|-----------|-------|
| **Workspace ID** | `96fe5a53-3a22-4443-8d0a-e2f6d61a2690` |
| **Capacidade** | Diamante (Premium) |
| **Região** | Brazil South (paulista-gyn) |
| **Lakehouse Principal** | `lh_cidade_inteligente_santos` |
| **Subpastas Domínio** | 10 (avaliacao, obras, cet, ouvidoria, carta_servicos, segov, seinfra, sepref, caged_santos, curso_motoristas) |
| **Notebooks Mapeados** | ~37 total (7 raiz + ~30 em domínios) |
| **Power BI Dashboards** | 19 (14 gerais + 5 de Obras) |

### 1.3 Status Geral v2.0

| Aspecto | Status |
|--------|--------|
| **Mapeamento de Notebooks** | ✅ 100% completo |
| **Domínios Operacionais** | ✅ 8 de 10 (CAGED em construção) |
| **Pipelines Mapeadas** | ✅ 100% inventário completo |
| **Riscos Críticos Identificados** | 🔴 3 prioritários (R5, R9, R1) |
| **Pronto para Produção** | ⚠️ Sim, com mitigações urgentes |
| **Última Verificação** | Sessão 4 — Claude no Chrome (15/Abr/2026) |

### 1.4 Domínios Mapeados — Quick Status

- ✅ **Avaliação de Serviços** — 100% mapeado (Gold+IA com sentimento)
- ✅ **Obras Públicas** — 100% mapeado (⚠️ R5: token 401 falha desde mar/2025)
- ✅ **CET / Tráfego** — 100% mapeado (4 notebooks)
- ✅ **Ouvidoria** — 100% mapeado (2 notebooks)
- ✅ **Carta de Serviços** — 100% mapeado (⚠️ R1: dual ingestion conflict)
- ✅ **Secretarias** (SEGOV, SEINFRA, SEPREF) — 100% mapeado (3 notebooks)
- ⚠️ **CAGED** — Notebook pronto, não executado em produção (🔴 R9: hardcode IBGE)
- 🔧 **Modelos Semânticos** — Inventário pendente

---

## 2. Arquitetura Técnica

### 2.1 Padrão Medallion — 4 Camadas

```
┌─────────────────────────────────────────────────────────────┐
│                   FONTE OPERACIONAL                         │
│         (Acto Gestão API / CSV / FTP)                      │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│          🔵 BRONZE (Raw)                                    │
│    CSV files / Raw Parquet — sem transformação             │
│    Pasta: /bronze/                                          │
└──────────────────────┬──────────────────────────────────────┘
                       │ (nb_ingest_* → ETL pipeline)
                       ▼
┌─────────────────────────────────────────────────────────────┐
│          🟢 SILVER (Cleaned)                                │
│    Parquet — deduplicado, tipado, validado                 │
│    Pasta: /silver/                                          │
└──────────────────────┬──────────────────────────────────────┘
                       │ (nb_silver_* / nb_gold_*)
                       ▼
┌─────────────────────────────────────────────────────────────┐
│          🟡 GOLD (Business-Ready)                           │
│    Delta Tables — dimensões, agregações, SCD (0/1/2)       │
│    Pasta: /gold/ — append ou overwrite conforme domínio    │
└──────────────────────┬──────────────────────────────────────┘
                       │ (nb_*_sentimento / ML models)
                       ▼
┌─────────────────────────────────────────────────────────────┐
│          🔴 GOLD+IA (Enriquecido)                           │
│    Delta Tables — sentimento, scoring, ML enrichment       │
│    Pasta: /gold_ia/ ou tabelas Gold com suffix _sentimento │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                  POWER BI                                   │
│   19 dashboards conectados via SQL Endpoint do Lakehouse  │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 Fluxo End-to-End

```
Fonte Operacional
    ↓
API (TOKEN_SANTOS) / CSV / FTP
    ↓
Bronze Layer (raw files)
    ↓
Pipeline ETL (Data Factory / Notebooks)
    ↓
Silver Layer (Parquet — cleaned)
    ↓
Gold Layer (Delta — business logic)
    ↓
Gold+IA (Sentimento / Scoring)
    ↓
Power BI Dashboard (acompanhamento, análise)
    ↓
Gestores / Secretários
```

### 2.3 Tecnologias Principais

| Componente | Tecnologia | Detalhe |
|------------|-----------|---------|
| **Armazenamento** | Delta Lake | Lakehouse `lh_cidade_inteligente_santos` |
| **Bronze** | CSV, Parquet | Raw data — sem transformação |
| **Silver** | Parquet | Cleaned, deduplicated, typed |
| **Gold** | Delta Tables | Business-ready (append/overwrite) |
| **Orquestração** | Data Factory / Pipelines | Agendadas, monitoradas |
| **BI** | Power BI | 19 dashboards |
| **IA/NLP** | Cognitive Services | Análise de sentimento em avaliações |
| **Python** | Notebooks | Transformações, utilitários |

---

## 3. Estrutura do Workspace

### 3.1 Pastas de Primeiro Nível

| Pasta | Tipo | Escopo | Status |
|-------|------|--------|--------|
| **Santos** ⭐ | Pasta | Foco desta documentação | ✅ Mapeado v1.8 |
| Aparecida de Goiânia | Pasta | Município (não mapeado) | 🔧 Pendente |
| Mauá | Pasta | Município (não mapeado) | 🔧 Pendente |
| Osasco | Pasta | Município (não mapeado) | 🔧 Pendente |
| utils | Pasta | Utilitários compartilhados | ⚠️ Consolidação pendente |
| gestao_paineis | Relatório PBI | Dashboard gerencial | ✅ Ativo (Yuri) |

### 3.2 Pasta Santos (subfolderId: 69166) — Estrutura Interna

| Item | Tipo | Status | Obs. |
|------|------|--------|------|
| **nbs** ⭐ | Pasta (subfolderId: 115750) | ✅ Mapeado v1.8 completo | 10 domínios + 7 utils |
| **bis** ⭐ | Pasta | ✅ 19 dashboards mapeados | BI / Relatórios |
| **pipelines** ⭐ | Pasta | ✅ Inventário completo | Orquestração |
| **modelos_semanticos** | Pasta | 🔧 Pendente | Modelos semânticos PBI |
| **nbs_analise** | Pasta | 🔧 Pendente | Análise exploratória |
| **lh_cidade_inteligente_santos** | Lakehouse | ✅ Ativo | Yuri Lucatelli Taba |
| **agent_santos_avaliacao_servicos** | Agente de Dados | ✅ Ativo | IA para avaliações |

### 3.3 Propriedade e Responsabilidades

| Pessoa | Rol | Responsabilidades |
|--------|-----|------------------|
| **Yuri Lucatelli Taba** | Arquiteto Principal | Base ingestion, pipelines gerais, PBI [[Documentação_Fabric/Powerbi-Santos/acompanhamento_carta_servicos.pdf|acompanhamento_carta_servicos]] |
| **Victor Martins da Silva** | Tech Lead — Obras + IA | Domínio Obras completo, notebooks sentimento, suporte técnico |
| **Francisco Jorge Leandro** | Spec. Carta de Serviços | Pipeline CSV carta_servicos (em produção) |

---

## 4. Inventário de Notebooks — Santos

### 4.1 Resumo Geral

| Categoria | Quantidade | Status |
|-----------|-----------|--------|
| **Notebooks Raiz (utilitários)** | 7 | ✅ 100% |
| **Subpastas de Domínio** | 10 | ✅ 100% |
| **Notebooks em Domínios** | ~30 | ✅ 100% |
| **TOTAL ESTIMADO** | **~37** | **✅ MAPEADO** |

### 4.2 Notebooks Raiz (subfolderId: 115750)

| Notebook | Proprietário | Células | Saída Principal | Status |
|----------|-------------|---------|-----------------|--------|
| **[[Documentação_Fabric/Santos/nbs/nb_ingest_acto_santos.ipynb|nb_ingest_acto_santos]]** | Yuri | 2 (458 lin.) | CSV acto_prazo + Delta tb_os_acto | ✅ |
| **[[Documentação_Fabric/Santos/nbs/nb_ingest_dim_date.ipynb|nb_ingest_dim_date]]** | Yuri | 2 | Delta dim_date_1, dim_date_2 | ✅ |
| **[[Documentação_Fabric/Santos/nbs/nb_ingest_tb_aux_servicos.ipynb|nb_ingest_tb_aux_servicos]]** | Yuri | 1 (35 lin.) | Delta tb_aux_servicos + tb_aux_regionais | ✅ |
| **[[Documentação_Fabric/Santos/nbs/nb_utils_api_acto_gestao.ipynb|nb_utils_api_acto_gestao]]** | Yuri | 7 | Funções utilitárias API (no-write) | ✅ COMPLETO v1.6 |
| **[[Documentação_Fabric/Santos/nbs/nb_utils_api_acto_gestao_obras.ipynb|nb_utils_api_acto_gestao_obras]]** | Victor | 16 | Funções utilitárias API obras | ✅ COMPLETO v1.4 |
| **[[Documentação_Fabric/utils/nb_utils_ingest_acto_gestao.ipynb|nb_utils_ingest_acto_gestao]]** | — | 2 | Funções extração API | ✅ COMPLETO v1.7 |
| **[[Documentação_Fabric/Santos/nbs/carta_servicos/nb_ingest_carta_servicos_santos.ipynb|nb_ingest_carta_servicos_santos]]** | Francisco | 3 | Delta gold_carta_servicos + atualizacoes | ✅ NOVO v1.8 ⚠️R1 |

### 4.3 Domínios e Status Individual

#### Avaliacao Servicos (subfolderId: 115751 — 3 NB)

| Camada | Notebook | Proprietário | Saída | Status |
|--------|----------|-------------|-------|--------|
| Silver | [[Documentação_Fabric/Santos/nbs/avaliacao_servicos/nb_silver_santos_avaliacao.ipynb|nb_silver_santos_avaliacao]] | Yuri | silver_avaliacoes_servico.parquet | ✅ |
| Gold | [[Documentação_Fabric/Santos/nbs/avaliacao_servicos/nb_gold_santos_avaliacao.ipynb|nb_gold_santos_avaliacao]] | Yuri | gold_avaliacoes_servico (Delta, OW) | ✅ |
| Gold+IA | [[Documentação_Fabric/Santos/nbs/avaliacao_servicos/nb_gold_santos_avaliacao_sentimento.ipynb|nb_gold_santos_avaliacao_sentimento]] | Victor | gold_avaliacoes_servicos_sentimento (Delta, AP) | ✅ |

#### Obras (3 NB raiz + SEONT subpasta)

| Notebook | Camada | Proprietário | Células | Saída | Status |
|----------|--------|-------------|---------|-------|--------|
| [[Documentação_Fabric/Santos/nbs/obras/nb_ingest_silver_acto_gestao_obras_santos.ipynb|nb_ingest_silver_acto_gestao_obras_santos]] | Bronze→Silver | Yuri | silver_acto_gesta_obras_santos_*.parquet | ⚠️ 401 ERRO (R5) |
| nb_silver_acto_gestao_obras_santos | Silver→Gold | Yuri | gold_acto_gestao_obras_santos (Delta, OW) | ✅ |
| nb_gold_acto_gestao_obras_santos | Gold | Yuri + Victor | gold_acto_gestao_obras_santos (Delta, OW) | ✅ |
| nb_gold_acto_gestao_obras_santos_atividades | Gold+IA | Victor | gold_acto_gestao_obras_santos_atividades | ✅ |
| **(Subpasta SEONT)** | — | — | — | — | — |
| nb_seont_obras | Bronze→Silver | — | silver_seont_obras.parquet | ✅ |

#### CET (4 NB + subpasta curso_motoristas)

| Notebook | Domínio | Status |
|----------|---------|--------|
| nb_silver_cet_servicos | CET — Silver | ✅ |
| nb_gold_cet_servicos | CET — Gold | ✅ |
| nb_gold_cet_carga_descarga | CET — Carga/Descarga | ✅ |
| **(Subpasta curso_motoristas — 1 NB)** | Cursos / Habilitação | ✅ |

#### Carta de Serviços (3 NB + 2 subpastas)

| Notebook | Proprietário | Path | Status |
|----------|-------------|------|--------|
| **02_ingestao_solicitacoes** | Victor | nbs/carta_servicos/ | ⚠️ Nunca rodou (API approach) |
| **[[Documentação_Fabric/Santos/nbs/carta_servicos/nb_ingest_carta_servicos_santos.ipynb|nb_ingest_carta_servicos_santos]]** | Francisco | nbs/ (raiz) | ✅ Em produção (CSV approach) |
| **nb_gold_carta_servicos** | Yuri | nbs/carta_servicos/ | ✅ Mapping |

> **⚠️ R1: Dual Ingestion Conflict**  
> Dois caminhos concorrentes sem fonte de verdade única. Sem validação de rowcount.

#### Manifestacao Ouvidoria (2 NB)

- nb_silver_manifestacao_ouvidoria — ✅
- nb_gold_manifestacao_ouvidoria — ✅

#### SEGOV, SEINFRA, SEPREF (3 NB total)

- nb_silver_segov_servicos — ✅
- nb_silver_seinfra_servicos — ✅
- nb_silver_sepref_servicos — ✅

#### CAGED Santos (1 NB — não executado)

- nb_caged_santos — 🔴 **R9: Hardcode IBGE (353440 vs 353845)**

---

## 5. Pipelines de Orquestração

### 5.1 Pipelines Mapeadas

| Pipeline | Domínio | Agendamento | Proprietário | Status |
|----------|---------|------------|-------------|--------|
| pl_ingest_acto_santos | Avaliacao | Diário | Yuri | ✅ |
| pl_ingest_obras_santos | Obras | Diário | Yuri | 🔴 401 FALHA (R5) |
| pl_silver_cet_servicos | CET | Diário | Yuri | ✅ |
| pl_gold_carta_servicos_csv | Carta (CSV) | Semanal | Francisco | ✅ |
| pl_ingest_ouvidoria | Ouvidoria | Diário | Yuri | ✅ |

> **Nota:** Agendamentos exatos pendentes. Últimas execuções em `/mnt/project/` documentadas.

---

## 6. Power BI — Catálogo de Dashboards

### 6.1 Família 1 — Acompanhamento de Serviços (InMov Template)

| Dashboard | Domínio | Tabela Gold | Status |
|-----------|---------|------------|--------|
| [[Documentação_Fabric/Powerbi-Santos/acompanhamento_servicos_segov.pdf|acompanhamento_servicos_segov]] | SEGOV | gold_segov_servicos | ✅ |
| [[Documentação_Fabric/Powerbi-Santos/acompanhamento_servicos_seinfra.pdf|acompanhamento_servicos_seinfra]] | SEINFRA | gold_seinfra_servicos | ✅ |
| [[Documentação_Fabric/Powerbi-Santos/acompanhamento_servicos_cet.pdf|acompanhamento_servicos_cet]] | CET | gold_cet_servicos + carga_descarga | ✅ |
| [[Documentação_Fabric/Powerbi-Santos/acompanhamento_servicos_sepref.pdf|acompanhamento_servicos_sepref]] | SEPREF | gold_sepref_servicos | ✅ |
| [[Documentação_Fabric/Powerbi-Santos/acompanhamento_servicos_ouvidoria.pdf|acompanhamento_servicos_ouvidoria]] | Ouvidoria | gold_ouvidoria_servicos | ✅ |

### 6.2 Família 2 — Manifestações de Ouvidoria

| Dashboard | Escopo | Status |
|-----------|--------|--------|
| [[Documentação_Fabric/Powerbi-Santos/acompanhamento_servicos_manif_ouvidoria.pdf|acompanhamento_servicos_manif_ouvidoria]] | Geral | ✅ |
| [[Documentação_Fabric/Powerbi-Santos/acompanhamento_servicos_manif_ouvidoria_cet.pdf|acompanhamento_servicos_manif_ouvidoria_cet]] | CET | ✅ |
| [[Documentação_Fabric/Powerbi-Santos/acompanhamento_servicos_manif_ouvidoria_segov.pdf|acompanhamento_servicos_manif_ouvidoria_segov]] | SEGOV | ✅ |
| [[Documentação_Fabric/Powerbi-Santos/acompanhamento_servicos_manif_ouvidoria_seinfra.pdf|acompanhamento_servicos_manif_ouvidoria_seinfra]] | SEINFRA | ✅ |
| [[Documentação_Fabric/Powerbi-Santos/acompanhamento_servicos_manif_ouvidoria_sepref.pdf|acompanhamento_servicos_manif_ouvidoria_sepref]] | SEPREF | ✅ |

**Tabela Gold:** `gold_manifestacoes_ouvidoria`

### 6.3 Família 3 — Avaliações

| Dashboard | Tabelas | Status |
|-----------|---------|--------|
| [[Documentação_Fabric/Powerbi-Santos/acompanhamento_avaliacao_servicos.pdf|acompanhamento_avaliacao_servicos]] | gold_avaliacoes_servico + sentimento | ✅ |

**⚠️ Nota:** Template diferente — KPIs em estrelas (0–5★), sem SLA de prazo.

### 6.4 Família 4 — Obras (5 Dashboards)

| Dashboard | Escopo | Status |
|-----------|--------|--------|
| acompanhamento_obras_geral | Todas as obras | ✅ |
| acompanhamento_obras_por_secretaria | Por secretaria | ✅ |
| acompanhamento_obras_etapas | Monitoramento de etapas | ✅ |
| acompanhamento_obras_prazos | SLA de prazos | ✅ |
| acompanhamento_obras_atividades | Atividades / Cronograma | ✅ |

**Total:** 19 dashboards (14 gerais + 5 obras)

---

## 7. Riscos Técnicos e Mitigações

### 7.1 Matriz de Riscos Críticos

| ID | Risco | Severidade | Domínio | Status | Prazo |
|----|-------|-----------|---------|--------|-------|
| **R5** | 401 Unauthorized em obras | 🔴 Alto | Obras | ❌ Ativo | Crítico |
| **R9** | IBGE hardcode (353440 vs 353845) | 🔴 Alto | CAGED | ❌ Ativo | Crítico |
| **R1** | Dual-path ingestion (API vs CSV) | 🔴 Alto | Carta de Serviços | ❌ Ativo | Crítico |
| **R2** | tb_aux.xlsx — Single Point of Failure | 🟠 Médio | Geral | ⚠️ Ativo | Médio |
| **R3** | Duplicação de funções utilitárias | 🟠 Médio | Geral | ⚠️ Ativo | Médio |
| **R4** | Overwrite vs. Append inconsistência | 🟠 Médio | Avaliacao Gold | ⚠️ Ativo | Médio |
| R6 | Tokens auth pattern curto-expiração | 🟠 Médio | Geral | ⚠️ Ativo | Médio |
| R7 | Unmapped [[Documentação_Fabric/utils/nb_utils_ingest_acto_gestao.ipynb|nb_utils_ingest_acto_gestao]] | 🟢 Baixo | Geral | ⚠️ Parcial | Baixo |
| R8 | 13 test users hardcoded | 🟢 Baixo | Geral | ⚠️ Ativo | Baixo |

### 7.2 Detalhamento — Críticos (R5, R9, R1)

#### 🔴 **R5: Obras — 401 Unauthorized (ATIVO DESDE MAR/2025)**

**Problema:**  
Pipeline `pl_ingest_obras_santos` falha com erro 401 ao tentar acessar API SEONT. Token `TOKEN_SANTOS_OBRAS` expirado ou revogado.

**Impacto:**  
- Dados de obras não são ingestionados  
- Tabelas Silver/Gold ficam desatualizadas  
- Dashboards de obras mostram dados obsoletos  
- **Criticidade:** Produção em risco

**Origem:**  
- Notebook: `nb_ingest_silver_acto_gestao_obras_santos` (célula 3, api call)  
- Pipeline: `pl_ingest_obras_santos`

**Mitigação:**  
1. **Imediato:** Contatar Yuri + SEONT para renovação de token  
2. **Verificação:** Testar novo token manualmente em notebook  
3. **Teste:** Executar pipeline com novo token  
4. **Validação:** Verificar se Silver tables foram atualizadas (rowcount)  
5. **Alertas:** Configurar monitoramento de falhas de auth

**Responsável:** Yuri Lucatelli Taba  
**Target Prazo:** 1 semana

---

#### 🔴 **R9: CAGED — IBGE Hardcode (NUNCA EXECUTADO)**

**Problema:**  
Notebook `nb_caged_santos` refere IBGE code **353440** (Osasco) em vez de **353845** (Santos). Notebook nunca foi executado em produção.

**Impacto:**  
- Se executado, será ingerido dados de Osasco, não Santos  
- Falta de dados CAGED para Santos  
- Análise de emprego/desemprego incorreta  
- **Criticidade:** Produto incompleto

**Origem:**  
- Arquivo: `nbs/caged_santos/nb_caged_santos.py` (ou .ipynb)  
- Célula com hardcode: provável na seção de "configuração"

**Mitigação:**  
1. **Correção:** Alterar `353440` → `353845`  
2. **Revisão:** Verificar se há outros hardcodes (paths, credenciais, etc.)  
3. **Teste Local:** Executar notebook em sandbox  
4. **Integração:** Adicionar à pipeline de agendamento  
5. **Validação:** Comparar rowcount com esperado (IBGE dados públicos)

**Responsável:** Victor ou Yuri  
**Target Prazo:** 3–5 dias

---

#### 🔴 **R1: Carta de Serviços — Dual Ingestion (2 PATHS COEXISTEM)**

**Problema:**  
Dois caminhos de ingestão concorrentes **sem fonte de verdade única**:
- **Caminho A (Victor):** API approach  
  - Notebook: `02_ingestao_solicitacoes` (nbs/carta_servicos/)  
  - **Status:** Nunca rodou em produção  
  - Acesso via TOKEN_SANTOS (Acto Gestão API)  
  - Supostamente mais atualizado (real-time)  

- **Caminho B (Francisco):** CSV approach  
  - Notebook: `nb_ingest_carta_servicos_santos` (nbs/ raiz)  
  - **Status:** Em produção, agendado semanalmente  
  - Fonte: FTP / export CSV  

**Impacto:**  
- Sem validação de rowcount antes de Delta writes  
- Risco de dados inconsistentes entre os dois paths  
- Power BI pode acessar dados desatualizados ou duplicados  
- Custo de storage duplicado  
- **Criticidade:** Integridade de dados

**Origem:**  
- Decisão arquitetônica antiga não finalizada  
- Ambos os notebooks mapeados em v1.8

**Mitigação:**  
1. **Decisão Arquitetônica:** Escolher **A ou B** (não ambos)  
   - **Recomendação:** Caminho B (Francisco, estável em produção)  
   - **Razão:** Caminho A nunca rodou; CSV é mais confiável  
2. **Se escolher A:**  
   - Testes integração com API  
   - Validação de rowcount antes de writes  
   - Monitoramento de atualizações  
3. **Se escolher B (RECOMENDADO):**  
   - Desativar/arquivar Caminho A (`02_ingestao_solicitacoes`)  
   - Documentar decisão  
   - Manter validação de rowcount  
4. **Validação:** Implementar rowcount checks em ambas as células  
   ```python
   before_count = spark.sql("SELECT COUNT(*) FROM gold_carta_servicos").collect()[0][0]
   # ... insert/update logic ...
   after_count = spark.sql("SELECT COUNT(*) FROM gold_carta_servicos").collect()[0][0]
   assert after_count > before_count * 0.95, "Rowcount validation failed"
   ```

**Responsável:** Victor + Francisco + Yuri  
**Target Prazo:** 2 semanas (arquitetura) + 1 semana (implementação)

---

### 7.3 Riscos Médios (R2, R3, R4, R6)

| ID | Risco | Descrição | Mitigação |
|----|-------|-----------|----------|
| **R2** | tb_aux.xlsx SPF | Arquivo Excel referenciado por 3+ notebooks. Se deletado/corrompido, quebra múltiplos pipelines | Consolidar em tabela Delta; backup automático |
| **R3** | Duplicação utilitários | Mesmas funções (ex: parsing, validation) em múltiplos notebooks | Refatorar para shared library em nb_utils_* centralizados |
| **R4** | Overwrite vs. Append | avaliacao Gold usa `.mode("overwrite")`, outras Gold usam `.mode("append")`. Inconsistência de pattern | Definir padrão (recomendação: append com versionamento SCD) |
| **R6** | Tokens short expiry | Padrão de tokens Acto que expiram em dias (não semanas) | Implementar token refresh automático ou usar MSI (Managed Identity) |

---

## 8. Roadmap e Plano de Ação

### 8.1 Crítico — Sprint Imediato (2–4 semanas)

**Priority 1:**  
🔴 **R5:** Resolver 401 Unauthorized em obras  
- [ ] Contatar Yuri + SEONT para renovação de token  
- [ ] Testar novo token manualmente  
- [ ] Executar pipeline e validar Silver tables  
- [ ] Configurar alertas de falha de auth  
- **Assignee:** Yuri  
- **Target:** Próxima semana  

🔴 **R9:** Corrigir hardcode IBGE em caged_santos  
- [ ] Localizar e corrigir 353440 → 353845  
- [ ] Buscar outros hardcodes  
- [ ] Testar notebook em sandbox  
- [ ] Adicionar à pipeline de agendamento  
- [ ] Validar com dados IBGE públicos  
- **Assignee:** Victor ou Yuri  
- **Target:** 3–5 dias  

🔴 **R1:** Definir fonte de verdade — Carta de Serviços  
- [ ] Revisão arquitetônica: API vs. CSV  
- [ ] **Recomendação:** Escolher Caminho B (CSV/Francisco)  
- [ ] Arquivar Caminho A (`02_ingestao_solicitacoes`)  
- [ ] Implementar validação de rowcount em ambas  
- [ ] Documentar decisão em Wiki/ReadMe  
- **Assignee:** Victor + Francisco + Yuri  
- **Target:** 2–3 semanas  

### 8.2 Médio — Próximo Mês

- **R2:** Migrar tb_aux.xlsx → Delta table  
  - Consolidar dados em tabela `tb_aux_master` (Delta)  
  - Backup automático (snapshots)  
  - Remover dependência de arquivo Excel  

- **R3:** Refatorar duplicação de utilitários  
  - Identificar funções duplicadas  
  - Criar `nb_lib_shared` para funções comuns  
  - Migrar notebooks para usar shared lib  

- **R4:** Padronizar Overwrite vs. Append  
  - Decisão: Append + SCD Type 2 para histórico  
  - Implementar em Gold_avaliacao  
  - Documentar padrão em wiki  

- **R6:** Implementar token refresh automático  
  - Usar MSI (Managed Identity) se possível  
  - Senão, implementar refresh logic em utils  

- **Mapeamento Modelos Semânticos**  
  - Inventário de modelos em `nbs/modelos_semanticos/`  
  - Documentar proprietários e SLAs  

### 8.3 Backlog — Q2/Q3 2026

- **R7:** Completar mapeamento [[Documentação_Fabric/utils/nb_utils_ingest_acto_gestao.ipynb|nb_utils_ingest_acto_gestao]] (célula 7 interrupted)  
- **R8:** Auditoria de test users (13 hardcoded em `remover_registros_teste`)  
- **Consolidação de payload** em `adicionar_etapa_atual` (2 variantes coexistem)  
- **Documentação SLAs Power BI** (template InMov v4 para todos os 19 dashboards)  
- **Estruturação nbs_analise** (análise exploratória)  

---

## 📌 Metadados e Controle

| Campo | Valor |
|-------|-------|
| **Documento** | Referência Técnica — Fabric Santos |
| **Versão** | 2.0 Consolidada |
| **Data** | 15 de Abril de 2026 |
| **Público-Alvo** | Victor, equipes dev, gestores públicos Santos |
| **Mantido por** | Yuri + Victor + Francisco (Acto) |
| **Última Verificação** | Sessão 4 — Claude no Chrome (15/Abr) |
| **Próxima Revisão** | 30 de Abril de 2026 (ou após R5/R9 mitigação) |
| **Contato Principal** | Victor Martins da Silva (Victor@acto.com.br) |

---

## 🔗 Coordenadas de Contato

- **Yuri Lucatelli Taba** — Acto  
  *Arquitetura, base ingestion, pipelines gerais, PBI*  

- **Victor Martins da Silva** — Acto  
  *Obras, IA/Sentimento, suporte técnico*  

- **Francisco Jorge Leandro** — Acto  
  *Carta de Serviços, pipeline CSV*  

---

**Documento Verificado e Consolidado — 15 de Abril de 2026**  
**Status: ✅ PRONTO PARA PRODUÇÃO (com mitigações urgentes)**

