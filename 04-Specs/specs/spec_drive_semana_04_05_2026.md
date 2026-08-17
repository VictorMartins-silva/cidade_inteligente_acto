---
title: "Spec Drive — Semana 04/05/2026"
tags:
  - tipo/spec
  - tema/dados-publicos
  - mercado-trabalho
  - censo
  - migracao-lakehouse
  - monitoramento-ibge
revisao: "2026-05-07"
---

# Spec Drive — Semana de Trabalho (04/05/2026)
## Projeto: Painel de Dados Públicos (Santos · Osasco · Mauá)

**Contexto:** Finalizamos com sucesso a migração técnica para a arquitetura **Schema-Aware (v3.0)**. O Lakehouse `lh_dados_publicos` agora está organizado em schemas funcionais (`bronze`, `silver`, `gold`, `monitoramento`). A Fase 3.5 foi concluída com a entrega de dimensões auxiliares e a ingestão completa da Segurança Pública (SSP).

---

## 📊 Estado Atual do Lakehouse (07/05/2026)

| Schema | Status | Conteúdo Principal |
|---|---|---|
| `bronze` | ✅ | Tabelas brutas IBGE, RAIS e CAGED. |
| `silver` | ✅ | **SSP (491k linhas)** · População · PIB · RAIS · Caged · Censo · **dim_municipio** · **dim_calendario**. |
| `gold` | ✅ | 12 tabelas Censo (incluindo paridade) · PIB per capita · Mercado Trabalho (RAIS+CAGED). |
| `monitoramento`| ✅ | Pipeline `pl_monitoramento_ingest` com agendamento diário ativo. |
| `dbo` | 🗑️ | Tabelas antigas (silver_ssp_*) removidas após migração bem-sucedida. |

---

## 📅 Roadmap Detalhado — Estado em 07/05/2026

```mermaid
gantt
    title Roadmap — Dados Públicos IBGE/SIDRA
    dateFormat YYYY-MM-DD
    axisFormat %d/%m
    todayMarker on

    section Fase 1 · Infraestrutura
    "Protótipo local (pandas)"             :done, p1, 2026-04-05, 2026-04-14
    "nb_utils_ibge"                        :done, p2, 2026-04-14, 2026-04-19
    "nb_ingest_populacao_ibge"             :done, p3, 2026-04-16, 2026-04-21
    "nb_ingest_pib_ibge"                   :done, p4, 2026-04-18, 2026-04-23
    "nb_ingest_cempre_ibge"                :done, p5, 2026-04-19, 2026-04-24
    "Pipeline pl_ingest_dados_publicos"    :done, p6, 2026-04-21, 2026-04-25
    "Validação + correção bugs"            :done, p7, 2026-04-23, 2026-04-26
    "nb_gold_populacao + nb_gold_pib"      :done, p8, 2026-04-24, 2026-04-28

    section Fase 2 · RAIS + Mercado de Trabalho
    "nb_ingest_rais_bigquery"              :done, f2a, 2026-04-28, 2026-05-02
    "nb_ingest_caged (BigQuery proto)"     :done, f2b, 2026-05-04, 2026-05-05
    "nb_gold_mercado_trabalho"             :done, f2c, 2026-05-04, 2026-05-05
    "Refatoração CAGED FTP — Yuri"         :active, f2d, 2026-04-28, 2026-05-20

    section Fase 3 · Censo Demográfico
    "nb_ingest_censo_ibge (15 municípios)" :done, f3a, 2026-05-04, 2026-05-05
    "nb_gold_censo_demografico (12 steps)" :done, f3b, 2026-05-04, 2026-05-05

    section Fase 3.5 · Migração LH + Monitoramento
    "Recriar lh_dados_publicos c/ schemas" :done, f35a, 2026-05-05, 2026-05-05
    "Migrar notebooks + schema-qualify"    :done, f35b, 2026-05-05, 2026-05-06
    "Monitoramento IBGE + Environment"     :done, f35c, 2026-05-06, 2026-05-07

    section Fase 4 · Power BI Direct Lake
    "gold.dim_municipio + dim_calendario"  :done, f4a, 2026-05-07, 2026-05-07
    "Migração SSP dbo → silver"            :done, f4b, 2026-05-07, 2026-05-07
    "Modelo semântico Direct Lake"         :active, f4c, 2026-05-09, 2026-05-15
    "Dashboard comparativo municípios"     :f4d, 2026-05-15, 2026-05-22
```

---

## 📋 Tabela de Status de Fases

| Fase | Nome | Status | Entregáveis Principais |
|---|---|---|---|
| 1 | Infraestrutura | ✅ | Lakehouse c/ Schemas, Utils IBGE, Clusters. |
| 2 | Mercado de Trabalho | ✅ | Ingestão RAIS/CAGED, Gold Mercado Trabalho. |
| 3 | Censo Demográfico | ✅ | Ingestão SIDRA, Gold Censo com 12 visões. |
| **3.5** | **Migração & Monitoramento**| ✅ | **Schemas migrados**, Monitoramento IBGE ativo. |
| 4 | Power BI / Semântica | 🔵 | dim_municipio/calendario (✅), SSP (✅), Modelo Direct Lake (Semana 12/05). |
| 5 | Dashboards Especializados | 🔲 | `nb_gold_osasco_seguranca_publica`. |

---

## 🏛️ Regras de Governança e Semântica

### 📅 Dimensão Calendário (`silver.dim_calendario`)
- **Regra de Join:** Para fatos mensais (CAGED, SSP), utilizar a coluna `ano_mes`. Para fatos anuais (PIB, População), utilizar a coluna `ano`.
- **Granularidade:** Mensal (1970–2030). Contempla `decada` e `periodo_label` para filtros históricos.

### 📍 Dimensão Município (`silver.dim_municipio`)
- **Filtro de Aplicação:** Utilize a coluna `papel` para distinguir entre "Cliente Core" e "Benchmark".
- **Join:** Sempre via `id_municipio` (7 dígitos IBGE).

---

## 📂 Catálogo de Tabelas Gold (Consumo BI)

| Tabela | Domínio | Descrição |
|---|---|---|
| `gold.populacao` | Demografia | População total e variação anual. |
| `gold.pib` | Economia | PIB Total e Per Capita. |
| `gold.mercado_trabalho` | Trabalho | Estoque (RAIS) e Fluxo (CAGED). |
| `gold.censo_piramide_populacao` | Censo | Estrutura etária por sexo. |
| `gold.censo_territorio` | Território | Área e Densidade Demográfica. |
| `gold.censo_renda` | Social | Renda domiciliar comparativa. |

---

## 🔵 Próximos Passos (Fase 4 & 5)
1. 🔵 Criar modelo semântico Direct Lake no Power BI Service (Semana 12/05).
2. 🔵 Desenvolver `nb_gold_osasco_seguranca_publica` para análise de criminalidade.
3. 🔲 Cruzamento de dados de Renda (Censo) com Segurança (SSP) por território.

---

## Links Rápidos

| O que precisar | Onde encontrar |
|---|---|
| Spec mestre (roadmap completo) | [[spec_drive_dados_publicos\|Spec Drive Dados Públicos]] |
| Spec semana seguinte | [[spec_drive_semana_11_05_2026\|Spec 11/05/2026]] |
| Mapeamento técnico tabelas | [[Documentação_Fabric/Dados Públicos/Mapeamento_Tecnico_Dados_Publicos\|Mapeamento Técnico]] |

---
*Spec Drive · Acto Cidade Inteligente · Atualizado em 07/05/2026*
