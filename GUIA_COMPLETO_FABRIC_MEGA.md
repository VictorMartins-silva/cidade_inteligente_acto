---
title: "GUIA COMPLETO FABRIC MEGA — Acto Cidade Inteligente"
tags:
  - ferramenta/fabric
  - mestre
  - tipo/referencia
aliases:
  - guia mega
  - documento universal
  - referencia completa
versao: "5.0 MEGA CONSOLIDADO"
data: "2026-05-04"
---

# GUIA COMPLETO FABRIC MEGA
## Acto Cidade Inteligente — Microsoft Fabric

**Versão:** 5.0 MEGA Consolidado  
**Data:** 04 de Maio de 2026  
**Público:** Toda a equipe (técnico, gestão, negócio)  
**Escopo:** Santos · Osasco · Mauá (Core) + 12 Municípios Benchmark  
**Status:** Documento Universal — responde qualquer pergunta sobre o projeto

---

## ÍNDICE NAVEGÁVEL

1. [Contexto de Negócio](#1-contexto-de-negócio)
2. [Arquitetura Técnica Geral](#2-arquitetura-técnica-geral)
3. [Santos — Documentação Completa](#3-santos--documentação-completa)
4. [Osasco — Documentação Completa](#4-osasco--documentação-completa)
5. [Mauá — Documentação Completa](#5-mauá--documentação-completa)
6. [Dados Públicos — IBGE / SIDRA / RAIS](#6-dados-públicos--ibge--sidra--rais)
7. [Outros Municípios](#7-outros-municípios)
8. [Módulo Acto — Documentação Técnica](#8-módulo-acto--documentação-técnica)
9. [Power BI — Catálogo Completo](#9-power-bi--catálogo-completo)
10. [Riscos Técnicos e Mitigações (R1–R9)](#10-riscos-técnicos-e-mitigações-r1r9)
11. [Roadmap e Plano de Ação](#11-roadmap-e-plano-de-ação)
12. [Padrões e Convenções](#12-padrões-e-convenções)
13. [Contatos e Responsabilidades](#13-contatos-e-responsabilidades)

---

## LOOKUP RÁPIDO

| Pergunta | Seção |
|---|---|
| Arquitetura geral do projeto | [§2](#2-arquitetura-técnica-geral) |
| O que cada notebook faz em Santos | [§3.4](#34-inventário-completo-de-notebooks--santos) |
| Pipelines do Data Factory | [§3.5](#35-pipelines-de-orquestração) |
| Nova arquitetura de tokens ([[Documentação_Fabric/Acto/nb_get_token_api.ipynb|nb_get_token_api]]) | [§8.8.1](#881-nb_get_token_api--gestão-centralizada-de-tokens) |
| SLA / Carta de Serviços (novo escopo) | [§11.1](#111-novo-escopo--sla--carta-de-serviços) |
| Notebooks de Osasco | [§4.2](#42-inventário-de-notebooks--osasco) |
| Dashboards Power BI | [§9](#9-power-bi--catálogo-completo) |
| Riscos críticos ativos | [§10](#10-riscos-técnicos-e-mitigações-r1r9) |
| Migrações pendentes Osasco/Mauá | [§4.3](#43-migrações-pendentes) / [§5.3](#53-migração-pendente) |
| Dados públicos IBGE/RAIS | [§6](#6-dados-públicos--ibge--sidra--rais) |
| Padrão de nomenclatura | [§12.1](#121-nomenclatura-de-notebooks) |
| SCD Type 2 | [§12.3](#123-scd-type-2--vigência-de-prazos) |
| Contatos da equipe | [§13](#13-contatos-e-responsabilidades) |

---

## 1. CONTEXTO DE NEGÓCIO

### 1.1 O que é a Plataforma Acto Cidade Inteligente

O projeto **Acto Cidade Inteligente** é uma plataforma de dados municipais desenvolvida pela **Acto** que coleta, transforma e disponibiliza dados operacionais de prefeituras brasileiras no **Microsoft Fabric**. O objetivo é fornecer **suporte à decisão em tempo real** para gestores públicos via dashboards Power BI.

O módulo **Acto** é o coração do sistema: ele coleta todas as **solicitações de serviço** feitas por cidadãos e processadas pelas secretarias municipais, expondo-as via API REST (Acto Gestão).

### 1.2 O que é uma "Solicitação"

Uma solicitação é qualquer pedido feito por um cidadão (ou agente interno) a uma secretaria municipal. Cada solicitação:
- Passa por **etapas** (análise → execução → finalização)
- Tem campos específicos do domínio (bairro, CPF, placa, etc.)
- Possui status: `Finalizado` / `Em Andamento` / `Cancelado`
- Pode ser feita por canal `Presencial` ou `Digital`

### 1.3 Municípios Atendidos

| Município                        | Status                         | Lakehouse                      | Notebooks | Domínios              |
| -------------------------------- | ------------------------------ | ------------------------------ | --------- | --------------------- |
| **Santos**                       | ✅ Produção                     | `lh_cidade_inteligente_santos` | ~37       | 10                    |
| **Osasco**                       | ✅ Produção (migração pendente) | `lh_cidade_inteligente_osasco` | 31        | 11                    |
| **Mauá**                         | ✅ Produção (migração pendente) | `lh_cidade_inteligente_maua`   | 4         | 2                     |
| **Dados Públicos**               | ✅ Fase 3 Concluída             | `lh_dados_publicos`            | 32        | IBGE/RAIS/CAGED/Censo |
| **Aparecida de Goiânia**         | 🔧 Em implantação              | —                              | —         | —                     |
| **São José do Rio Preto (SJRP)** | 🔧 Em implantação              | —                              | —         | —                     |

### 1.4 Secretarias e Domínios Ativos

#### Santos

| Secretaria | Sigla | Domínio | Exemplos de Serviços |
|---|---|---|---|
| Companhia de Engenharia de Tráfego | CET | Trânsito e Mobilidade | Credencial Idoso/PcD, Carga/Descarga, Estudo Tráfego |
| Secretaria de Planejamento e Regulação | SEPREF | Urbanismo e Fiscalização | Licença de Construção, Alvará, Fiscalização |
| Secretaria de Governo | SEGOV | Gestão Governamental | Serviços gerais |
| Secretaria de Infraestrutura | SEINFRA | Infraestrutura Urbana | Manutenção viária, iluminação |
| Ouvidoria | OUVIDORIA | Manifestações Cidadãs | Reclamações, sugestões, elogios |
| Obras | OBRAS/PDR | Obras Públicas | Acompanhamento de obras |

#### Osasco

| Secretaria | Sigla | Domínio | Exemplos de Serviços |
|---|---|---|---|
| Secretaria de Assistência Social | SAS | Assistência Social | Atendimento CRAS, CadÚnico, RMA, PBF |
| Secretaria de Trabalho e Renda | SETRE | Emprego e Renda | Atendimento ao Trabalhador, Bolsa Trabalho |

### 1.5 Indicadores Estratégicos de Negócio

| Nível       | Pergunta                                        | Tabela Gold                                                 |
| ----------- | ----------------------------------------------- | ----------------------------------------------------------- |
| Executivo   | Quantos atendimentos foram realizados este mês? | Todas as Gold — `COUNT(id_os)` por período                  |
| Executivo   | A prefeitura está mais digital?                 | `canal = Digital` % ao longo do tempo                       |
| Executivo   | Há backlog crescendo em algum setor?            | `status_fluxo = Em andamento` por período                   |
| Executivo   | Qual o tempo médio de atendimento?              | `AVG(data_finalizacao - data_criacao)`                      |
| Operacional | Quais serviços têm maior volume de OS?          | `servico × COUNT(id_os)`                                    |
| Operacional | Quais bairros geram mais demanda?               | `bairro × COUNT(id_os)`                                     |
| Operacional | Quais OS estão paradas em etapa?                | `etapa_atual × COUNT` onde `status_fluxo ≠ Finalizado`      |
| Analítico   | Como o SLA por etapa varia entre secretarias?   | `data_fim_etapa - data_inicio_etapa` por etapa e secretaria |

---

## 2. ARQUITETURA TÉCNICA GERAL

### 2.1 Padrão Medallion — 4 Camadas

```
┌─────────────────────────────────────────────────────────────┐
│                   FONTE OPERACIONAL                         │
│         (Acto Gestão API / CSV / FTP / BigQuery)           │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│          🔵 BRONZE (Raw)                                    │
│    CSV / Raw Parquet / Delta bruto — sem transformação     │
│    Pasta: /bronze/                                          │
└──────────────────────┬──────────────────────────────────────┘
                       │ (nb_ingest_* → ETL pipeline)
                       ▼
┌─────────────────────────────────────────────────────────────┐
│          🟢 SILVER (Cleaned)                                │
│    Parquet / Delta — deduplicado, tipado, validado         │
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
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                  POWER BI                                   │
│   Dashboards conectados via SQL Endpoint do Lakehouse      │
└─────────────────────────────────────────────────────────────┘
```

| Camada | Responsabilidade | Tecnologia |
|---|---|---|
| Bronze | Persistir payload bruto sem alteração | Delta Table, Data Factory |
| Silver | Limpeza, tipagem, normalização, SCD2 | PySpark / Python |
| Gold | Agregações, indicadores, modelo dimensional | PySpark / SQL |
| Gold+IA | Sentimento, scoring, ML enrichment | Cognitive Services |
| Consumo | Relatórios e dashboards | Power BI (DAX mínimo) |

### 2.2 Tecnologias Principais

| Componente | Tecnologia | Detalhe |
|---|---|---|
| Armazenamento | Delta Lake | Lakehouse por município |
| Bronze | CSV, Parquet | Raw data — sem transformação |
| Silver | Parquet | Cleaned, deduplicated, typed |
| Gold | Delta Tables | Business-ready (append/overwrite) |
| Orquestração | Data Factory / Pipelines | Agendadas, monitoradas |
| BI | Power BI | ~19 dashboards Santos + Osasco |
| IA/NLP | Azure Cognitive Services | Análise de sentimento em avaliações |
| Processamento | PySpark / Python Notebooks | Transformações, utilitários |

### 2.3 Coordenadas Globais do Workspace

| Parâmetro | Valor |
|---|---|
| **Workspace ID** | `96fe5a53-3a22-4443-8d0a-e2f6d61a2690` |
| **Capacidade** | Diamante (Premium) |
| **Região** | Brazil South |
| **SQL Endpoint (Dados Públicos)** | `ena6obg6j2cevcppw7dn7yu57a-knnp5frchjbujdik4l3nmgrgsa.datawarehouse.fabric.microsoft.com` |

### 2.4 Padrão de Caminhos ABFSS

```
abfss://96fe5a53-3a22-4443-8d0a-e2f6d61a2690@onelake.dfs.fabric.microsoft.com/<item-id>/Files/...
```

---

## 3. SANTOS — DOCUMENTAÇÃO COMPLETA

### 3.1 Coordenadas do Workspace Santos

| Parâmetro | Valor |
|---|---|
| **Lakehouse** | `lh_cidade_inteligente_santos` |
| **Workspace ID** | `96fe5a53-3a22-4443-8d0a-e2f6d61a2690` |
| **Capacidade** | Diamante (Premium) |
| **Domínios** | 10 (avaliacao, obras, cet, ouvidoria, carta_servicos, segov, seinfra, sepref, caged_santos, curso_motoristas) |
| **Notebooks Mapeados** | ~37 total (7 raiz + ~30 em domínios) |
| **Power BI Dashboards** | 19 (14 gerais + 5 de Obras) |
| **Status Geral** | ✅ Pronto para Produção (com mitigações) |
| **Última Verificação** | Sessão 4 — Abril 2026 |

### 3.2 Estrutura de Pastas — Santos

| Pasta | Tipo | Status | Obs. |
|---|---|---|---|
| **Santos** ⭐ | Pasta (subfolderId: 69166) | ✅ Mapeado completo | Foco desta documentação |
| ↳ **nbs** ⭐ | Pasta (subfolderId: 115750) | ✅ Mapeado v1.8 completo | 10 domínios + 7 utils |
| ↳ **bis** ⭐ | Pasta | ✅ 19 dashboards mapeados | BI / Relatórios |
| ↳ **pipelines** ⭐ | Pasta | ✅ Inventário completo | Orquestração |
| ↳ **modelos_semanticos** | Pasta | 🔧 Pendente | Modelos semânticos PBI |
| ↳ **nbs_analise** | Pasta | 🔧 Pendente | Análise exploratória |
| ↳ **lh_cidade_inteligente_santos** | Lakehouse | ✅ Ativo | Yuri Lucatelli Taba |
| ↳ **agent_santos_avaliacao_servicos** | Agente de Dados | ✅ Ativo | IA para avaliações |
| Aparecida de Goiânia | Pasta | 🔧 Pendente | Não mapeado |
| Mauá | Pasta | 🔧 Pendente | Não mapeado |
| Osasco | Pasta | 🔧 Pendente | Não mapeado |
| utils | Pasta | ⚠️ Consolidação pendente | Utilitários compartilhados |
| gestao_paineis | Relatório PBI | ✅ Ativo (Yuri) | Dashboard gerencial |

### 3.3 Status por Domínio — Santos

| Domínio | Notebooks | Status | Observação |
|---|---|---|---|
| ✅ Avaliação de Serviços | 3 | Operacional | Gold+IA com sentimento |
| ✅ Obras Públicas | 4 | Operacional | Token renovado via [[Documentação_Fabric/Acto/nb_get_token_api.ipynb|nb_get_token_api]] |
| ✅ CET / Tráfego | 4 | Operacional | Inclui Carga/Descarga |
| ✅ Curso de Motoristas | 2 | Operacional | Subpasta de CET |
| ✅ Manifestações Ouvidoria | 2 | Operacional | unionAll de 5 tabelas |
| ✅ Carta de Serviços | 3 | Operacional | Francisco/CSV em produção · Victor/API = projeto futuro |
| ✅ SEGOV | 1 | Operacional | 366 registros |
| ✅ SEINFRA | 1 | Operacional | 1.161 registros |
| ✅ SEPREF | 1 | Operacional | JSON payload externo |
| 🔴 CAGED Santos | 1 | Nunca executado | R9: hardcode IBGE errado |

### 3.4 Inventário Completo de Notebooks — Santos

#### 3.4.1 Notebooks Raiz (subfolderId: 115750)

| Notebook | Proprietário | Células | Saída Principal | Status |
|---|---|---|---|---|
| `nb_ingest_acto_santos` | Yuri | 2 (458 lin.) | CSV acto_prazo + Delta `tb_os_acto` | ✅ |
| `nb_ingest_dim_date` | Yuri | 2 | Delta `dim_date_1`, `dim_date_2` | ✅ |
| `nb_ingest_tb_aux_servicos` | Yuri | 1 (35 lin.) | Delta `tb_aux_servicos` + `tb_aux_regionais` | ✅ |
| `nb_utils_api_acto_gestao` | Yuri | 7 | Funções utilitárias API (no-write) | ✅ COMPLETO v1.6 |
| `nb_utils_api_acto_gestao_obras` | Victor | 16 | Funções utilitárias API obras | ✅ COMPLETO v1.4 |
| `nb_utils_ingest_acto_gestao` | — | 2 | Funções extração API | ✅ COMPLETO v1.7 |
| `nb_ingest_carta_servicos_santos` | Francisco | 3 | Delta `gold_carta_servicos` + atualizacoes | ✅ NOVO v1.8 ⚠️R1 |

#### 3.4.2 Avaliação de Serviços (subfolderId: 115751 — 3 NB)

| Camada | Notebook | Proprietário | Saída | Modo | Status |
|---|---|---|---|---|---|
| Silver | `nb_silver_santos_avaliacao` | Yuri | `silver_avaliacoes_servico.parquet` | overwrite | ✅ |
| Gold | `nb_gold_santos_avaliacao` | Yuri | `gold_avaliacoes_servico` (Delta) | overwrite | ✅ |
| Gold+IA | `nb_gold_santos_avaliacao_sentimento` | Victor | `gold_avaliacoes_servicos_sentimento` (Delta) | append | ✅ ⚠️R4 |

#### 3.4.3 Obras Públicas (3 NB raiz + SEONT)

| Notebook | Camada | Proprietário | Saída | Status |
|---|---|---|---|---|
| `nb_ingest_silver_acto_gestao_obras_santos` | Bronze→Silver | Yuri | `silver_acto_gestao_obras_santos_*.parquet` | ✅ Token renovado via [[Documentação_Fabric/Acto/nb_get_token_api.ipynb|nb_get_token_api]] |
| `nb_gold_acto_gestao_obras_santos` | Silver→Gold | Yuri | `gold_pdr_acompanhamentos_os` (Delta, OW) | ✅ |
| `nb_gold_acto_gestao_obras_santos_atividades` | Gold+IA | Victor | `gold_acto_gestao_obras_santos_atividades` | ✅ |
| `nb_gold_acto_gestao_obras_seont_os` *(SEONT)* | Gold | — | `gold_pdr_seont_os` | ✅ (sem pipeline) |

#### 3.4.4 CET (4 NB + subpasta curso_motoristas)

| Notebook | Domínio | Saída | Status |
|---|---|---|---|
| `nb_ingest_estrutura_cet` | CET — Estrutura | `tb_aux_estrutura_organizacional_cet` | ✅ (sem pipeline) |
| `nb_ingest_silver_cet_carga_descarga` | CET — Carga/Descarga | `silver_cet_carga_descarga_*.parquet` | ✅ ⚠️R4 |
| `nb_gold_acto_gestao_cet` | CET — Gold | `gold_cet_servicos` | ✅ |
| `nb_gold_acto_gestao_cet_carga_descarga` | CET — Carga/Descarga | `gold_cet_carga_descarga` | ✅ |
| `nb_ingest_santos_curso_motoristas` *(curso/)* | Curso Motoristas | `silver_solicitacoes` + `silver_etapas.parquet` | ✅ |
| `nb_silver_santos_curso_motoristas` *(curso/)* | Curso Motoristas | `gold_curso_motorista` (742 lin, 120 col) | ✅ com rowcount |

**Regras de negócio ativas (Curso Motoristas):**
- D1 = administrativo → excluído de aprovação e presença
- D8 = excluído dos dias válidos de aula
- Ausência inferida apenas para `status_fluxo = "Finalizado"`
- Estados de presença: Presente / Ausente / Pendente / Cancelado

#### 3.4.5 Carta de Serviços (3 NB + 2 subpastas)

| Notebook | Proprietário | Caminho | Status |
|---|---|---|---|
| `nb_ingest_carta_servicos_santos` | Francisco | `nbs/` (raiz) | ✅ **FONTE ÚNICA em produção** (CSV semanal) |
| `01_ingestao_cartas_servico` | Victor | `nbs/carta_servicos/gestao_prazo_sla/` | 🔲 Projeto futuro — auditoria via API |
| `02_ingestao_solicitacoes` | Victor | `nbs/carta_servicos/gestao_prazo_sla/` | 🔲 Projeto futuro — nunca executado em produção |
| `config_api_acto_atualizado` | — | `nbs/carta_servicos/gestao_prazo_sla/` | UTIL: tokens multi-município |
| `nb_utils_sla_santos` | — | `nbs/carta_servicos/gestao_prazo_sla/` | UTIL: funções SLA |

> **⚠️ R1: Dual Ingestion Conflict** — dois caminhos concorrentes sem fonte de verdade única. Ver §10.

#### 3.4.6 Manifestação Ouvidoria (2 NB)

| Notebook | Saída | Padrão especial |
|---|---|---|
| `nb_gold_acto_gestao_manifestacoes_ouvidoria` | `gold_manifestacoes_ouvidoria` | ⚠️R4 |
| `nb_gold_acto_gestao_ouvidoria_servicos` | `gold_ouvidoria_servicos` | unionAll de 5 tabelas Gold |

#### 3.4.7 Secretarias Simples (3 NB)

| Notebook | Saída | Registros |
|---|---|---|
| `nb_gold_acto_gestao_segov` | `gold_segov_servicos` | 366 |
| `nb_gold_acto_gestao_seinfra` | `gold_seinfra_servicos` | 1.161 |
| `nb_gold_acto_gestao_sepref` | `gold_sepref_servicos` | usa `import_json_payload()` — único com esse padrão |

#### 3.4.8 CAGED Santos (1 NB — nunca executado)

| Notebook | Status | Risco |
|---|---|---|
| `nb_ingest_caged_santos` | 🔴 Nunca executado | R9: IBGE hardcode `353440` (Osasco) em vez de `353845` (Santos) |

### 3.5 Pipelines de Orquestração

| Pipeline | Domínio | Agendamento | Proprietário | Status |
|---|---|---|---|---|
| `pl_ingest_acto_gestao_santos_avaliacoes_servicos` | Avaliação | Diário | Yuri | ✅ |
| `pl_ingest_obras_santos` | Obras | Diário | Yuri | ✅ Ativo |
| `pl_ingest_acto_gestao_santos_cet` | CET + Curso Motoristas | Diário | Yuri | ✅ |
| `pl_ingest_carta_servicos_santos` | Carta de Serviços | Semanal | Francisco | ✅ |
| `pl_ingest_acto_gestao_santos_manifestacoes_ouvidoria` | Manifestações | Diário | Yuri | ✅ |
| `pl_ingest_acto_gestao_santos_ouvidoria_servicos` | Ouvidoria Serviços | Diário | Yuri | ✅ |
| `pl_ingest_acto_gestao_santos_segov` | SEGOV | Diário | Yuri | ✅ |
| `pl_ingest_acto_gestao_santos_seinfra` | SEINFRA | Diário | Yuri | ✅ |
| `pl_ingest_acto_gestao_santos_sepref` | SEPREF | Diário | Yuri | ✅ |

**Pipeline padrão:** `Notebook Gold → RefreshSqlEndpoint → Refresh modelo PBI`

**Exceção — `pl_ingest_obras_santos`:** 9 atividades — Silver → Gold obras + Gold etapas (paralelo) → RefreshSqlEndpoint → 4× PBI refresh em paralelo.

#### Notebooks SEM pipeline (execução manual)

| Notebook | Saída |
|---|---|
| `nb_gold_santos_avaliacao_sentimento` | `gold_avaliacoes_servicos_sentimento` |
| `nb_ingest_estrutura_cet` | `tb_aux_estrutura_organizacional_cet` |
| `nb_ingest_acto_santos` | `tb_os_acto` |
| `nb_ingest_dim_date` | `dim_date_1`, `dim_date_2` |
| `nb_ingest_tb_aux_servicos` | `tb_aux_servicos`, `tb_aux_regionais` |

### 3.6 Grafo de Dependências entre Notebooks — Santos

#### Fluxo: Avaliação de Serviços

```
nb_utils_api_acto_gestao  ←──── nb_utils_ingest_acto_gestao ⚠️R7
        │
        ▼
nb_silver_santos_avaliacao
        │
        ▼
nb_gold_santos_avaliacao
        │
        ├──▶ nb_gold_santos_avaliacao_sentimento (append incremental ⚠️R4)
        │
        └──▶ [pl_ingest_acto_gestao_santos_avaliacoes_servicos]
```

#### Fluxo: Obras Públicas

```
nb_utils_ingest_acto_gestao ⚠️R7
nb_utils_api_acto_gestao_obras (login dinâmico)
        │
        ▼
nb_ingest_silver_acto_gestao_obras_santos  ✅ (token via nb_get_token_api)
        │
        ├──▶ nb_gold_acto_gestao_obras_santos
        │         │
        │         ├──▶ nb_gold_acto_gestao_obras_seont_os (sem pipeline)
        │         └──▶ [pl_ingest_obras_santos]
        │
        └──▶ nb_gold_acto_gestao_obras_etapas
                  └──▶ [pl_ingest_obras_santos] (paralelo com Gold obras)
```

#### Fluxo: CET + Curso de Motoristas

```
nb_utils_api_acto_gestao
        │
        ├──▶ nb_gold_acto_gestao_cet  →  gold_cet_servicos
        │
        └──▶ nb_ingest_santos_curso_motoristas (Bronze)
                  │
                  ▼
             nb_silver_santos_curso_motoristas
                  │
                  └──▶ gold_curso_motorista ✅ rowcount

nb_ingest_silver_cet_carga_descarga ⚠️R4
        └──▶ nb_gold_acto_gestao_cet_carga_descarga

[Tudo via pipeline: pl_ingest_acto_gestao_santos_cet]
```

#### Fluxo: Ouvidoria Agregadora

```
gold_sepref_servicos    ──┐
gold_seinfra_servicos   ──┤
gold_cet_servicos       ──┼──▶ nb_gold_acto_gestao_ouvidoria_servicos
gold_segov_servicos     ──┤         │
gold_manifestacoes_ouvidoria ─┘     └──▶ gold_ouvidoria_servicos (unionAll)
                                          │
                                          └──▶ [pl_ingest_ouvidoria_servicos]
```

#### Fluxo: Secretarias Simples

```
nb_utils_api_acto_gestao
        │
        ├──▶ nb_gold_acto_gestao_segov   →  gold_segov_servicos
        ├──▶ nb_gold_acto_gestao_seinfra →  gold_seinfra_servicos
        └──▶ nb_gold_acto_gestao_sepref  →  gold_sepref_servicos (usa import_json_payload())
```

### 3.7 Arquivos Auxiliares Críticos — Santos (R1)

| Arquivo | Usado em | Risco |
|---|---|---|
| `Files/acto/tb_aux.xlsx` (sheets: `aux_prazo`, `aux_regionais`) | `nb_ingest_acto_santos`, `nb_utils_api_acto_gestao` | SPF — path mudança quebra silenciosamente |
| `PMS_AuxiliarPDR.xlsx` | `nb_gold_acto_gestao_obras` | SPF |
| `raw_cadastro_carta/*.csv` | `nb_ingest_carta_servicos_santos` | SPF |
| `exportar_4.csv` | CSV canônico Carta de Serviços | 693 registros, `;`, UTF-8 BOM |

**Migração planejada:** substituir todos por Delta Tables no Lakehouse.

---

## 4. OSASCO — DOCUMENTAÇÃO COMPLETA

### 4.1 Coordenadas do Workspace Osasco

| Parâmetro | Valor |
|---|---|
| **Lakehouse** | `lh_cidade_inteligente_osasco` |
| **Notebooks** | 31 mapeados |
| **Domínios** | 11 |
| **Token API** | `TOKEN_OSASCO` (JWT) + `APP_ID_OSASCO` |
| **Objetivo do líder** | Migrar saídas CSV/Parquet → Delta Gold para Jorge replicar Dash Python no Power BI |
| **Revisão** | Abril de 2026 |

### 4.2 Inventário de Notebooks — Osasco

| # | Notebook | Domínio | Camada | Saída | Modo | Migração |
|---|---|---|---|---|---|---|
| 1 | `nb_ingest_atendimento_cras` | Assistência Social | Gold | `gold_atendimento_cras`, `gold_atendimento_cras_etapas` | overwrite | Não |
| 2 | `nb_append_pbf` | Assistência Social | Silver | `silver_pbf_sp` | append | Criar Gold Osasco |
| 3 | `nb_gold_pbf` | Assistência Social | Gold | `gold_pbf_municipios_selecionados` | overwrite (SQL) | Não |
| 4 | `nb_ingest_dump_pbf` | Assistência Social | Bronze | `dump_pbf_sp` | overwrite | Não |
| 5 | `nb_ingest_bronze_cad_unico` | Assistência Social | Bronze | `bronze_cad_unico_reg01…reg18` (12 tabelas) | append | Não |
| 6 | `nb_silver_cad_unico` | Assistência Social | Silver | `silver_cad_unico_reg01`, `reg04` | overwrite | Não |
| 7 | `nb_gold_cad_unico_pg` | Assistência Social | Gold | `gold_cad_unico_*` (12 tabelas) | overwrite | Não |
| 8 | `nb_ingest_acto_rma` | Assistência Social | Gold | `gold_rma_cras_*` (4 tabelas) | overwrite | Não |
| 9 | `nb_ingest_acto_rma_creas` | Assistência Social | Gold | `gold_rma_creas_indicadores` | overwrite | Não |
| 10 | `nb_ingest_osasco_bolsa_trabalho` | Bolsa Trabalho | Silver | `silver_bolsa_trabalho` | overwrite | Não |
| 11 | `nb_gold_bolsa_trabalho` | Bolsa Trabalho | Gold | `gold_bolsa_trabalho` | overwrite | Não |
| 12 | `nb_ingest_osasco_bpc` | BPC | Silver | Parquet `Files/silver_bpc/` | parquet | Não (Silver) |
| 13 | `nb_gold_osasco_bpc` | BPC | Gold | **escrita comentada** | — | **🔴 CRÍTICO** |
| 14 | `nb_append_caged` | CAGED | Silver | `silver_caged` | append | Não |
| 15 | `nb_gold_sql_caged` | CAGED | Gold | 5 tabelas `gold_caged_*` | overwrite | Não |
| 16 | `nb_ingest_caged_dump` | CAGED | Bronze | `dump_caged` | overwrite | Não |
| 17 | `nb_ingest_carta_servicos_osasco` | Carta Serviços | Gold | `gold_carta_servicos`, `gold_carta_servicos_atualizacoes` | overwrite | Não |
| 18 | `nb_ingest_acto_gestao_tempo_etapa_carta_servicos` | Carta Serviços | Gold | `gold_carta_servicos_tempo_etapa` | overwrite | Não |
| 19 | `nb_ingest_censo` | Censo / Demo | Gold | **10 arquivos CSV** `Files/gold_censo_demografico/` | CSV | **🟠 SIM** |
| 20 | `nb_ingest_populacao_sidra` | Censo / Demo | Gold | `gold_osasco_populacao_ibge` | overwrite | Não |
| 21 | `nb_ingest_pib_sidra` | Censo / Demo | Gold | `gold_osasco_pib_per_capita`, `gold_osasco_pib_categoria`, `gold_osasco_participacao_pib` | overwrite | Não |
| 22 | `nb_gold_populacao_densidade` | Censo / Demo | Gold | **1 arquivo CSV** `Files/gold_populacao_densidade/` | CSV | **🟠 SIM** |
| 23 | `nb_ingest_osasco_comexstat` | Comex | Gold | `gold_osasco_comexstat` | overwrite | Não |
| 24 | `nb_ingest_grid_obras` | Obras | Gold | `gold_alvaras_obras` | overwrite | Não |
| 25 | `nb_ingest_rais_bd` | RAIS | Raw | `raw_rais_estab_sp` (dump BigQuery) | overwrite | Não |
| 26 | `nb_append_rais_ftp` | RAIS | Raw | `raw_rais_estab_sp` (FTP 2024) | overwrite | Não |
| 27 | `nb_gold_rais` | RAIS | Gold | **2 arquivos CSV** `Files/gold_rais/` | CSV | **🟠 SIM** |
| 28 | `nb_ingest_infosiga_seg_viaria` | Segurança Viária | Silver | `silver_infosiga_pessoas`, `silver_infosiga_sinistros`, `silver_infosiga_veiculos` | overwrite | Não |
| 29 | `nb_gold_seguranca_viaria` | Segurança Viária | Gold | 4 tabelas Delta + 3 Parquet (duplicação) | overwrite | Remover Parquet |
| 30 | `nb_ingest_monitora_oz` | Segurança Pública | Gold | `gold_monitora_oz` | overwrite | Não |
| 31 | `nb_gold_osasco_seguranca_publica` | Segurança Pública | Gold | 4 tabelas `gold_seg_publica_*` | overwrite | Não |

**Total: 31 notebooks**

### 4.3 Migrações Pendentes

| Prioridade | Notebook | Problema | Ação |
|---|---|---|---|
| 🔴 CRÍTICO | `nb_gold_osasco_bpc` | Bloco de escrita Delta **completamente comentado** | Descomentar e ajustar `saveAsTable("gold_bpc_osasco")` |
| 🟠 Alto | `nb_ingest_censo` | 10 arquivos CSV em `Files/gold_censo_demografico/` | Substituir cada `to_csv()` por `saveAsTable("gold_censo_{tema}")` |
| 🟠 Alto | `nb_gold_rais` | 2 CSVs: `rais_anual.csv` e `gold_rais_tamanho_estabelecimento.csv` | Substituir `to_csv()` por `saveAsTable()` |
| 🟡 Médio | `nb_gold_populacao_densidade` | 1 CSV em `Files/gold_populacao_densidade/` | `saveAsTable("gold_populacao_densidade")` |
| 🟡 Médio | `nb_gold_seguranca_viaria` | Escreve Delta + Parquet redundante | Remover os `to_parquet()` |

### 4.4 Fontes de Dados Externas — Osasco

| Fonte | Domínio | Autenticação |
|---|---|---|
| API Acto Gestão | Bolsa Trabalho · Carta Serviços · CRAS · Monitora OZ | `TOKEN_OSASCO` (JWT) + `APP_ID_OSASCO` |
| Portal da Transparência | BPC · Bolsa Família | Pública |
| FTP MTE | CAGED · RAIS | Anônimo |
| Google BigQuery (Base dos Dados) | RAIS dump histórico | JSON credencial `Files/bd2024-*.json` |
| IBGE SIDRA / ipeadatapy | Censo · PIB · Densidade | Pública |
| INFOSIGA DETRAN SP | Segurança Viária | Pública |
| CadÚnico TXT (SEADS) | CadÚnico | Arquivo manual |

### 4.5 Arquivos Auxiliares Críticos — Osasco

| Arquivo | Usado em | Risco |
|---|---|---|
| `Files/cadastro_unico/cep_bairros.csv` | `nb_gold_cad_unico_pg` | JOIN CEP→bairro, quebra silenciosa se movido |
| `Files/obras/tb_aux_etapas_consideradas.xlsx` | `nb_ingest_grid_obras` | Lista de etapas consideradas |
| `Files/bd2024-444413-1084f2b9d765.json` | `nb_ingest_rais_bd` | Credencial BigQuery — arquivo único |
| `Files/metadata/bpc/controle_carga.csv` | `nb_ingest_osasco_bpc` | Controle incremental de carga |

### 4.6 Resumo por Domínio — Osasco

| Domínio | Qtd nbs | Tabelas Gold | Migração pendente |
|---|---|---|---|
| Assistência Social (CRAS · CadÚnico · RMA · PBF) | 9 | 21 | — |
| Bolsa Trabalho | 2 | 1 | — |
| BPC | 2 | **0** | 🔴 Escrita comentada |
| CAGED | 3 | 5 | — |
| Carta de Serviços | 2 | 3 | — |
| Censo / Demográfico | 4 | 3 + 10 CSVs | 🟠 10 CSVs → Delta |
| Comércio Exterior | 1 | 1 | — |
| Obras | 1 | 1 | — |
| RAIS | 3 | 0 + 2 CSVs | 🟠 2 CSVs → Delta |
| Segurança Pública | 2 | 5 | — |
| Segurança Viária | 2 | 4 | 🟡 Remover Parquet redundante |

---

## 5. MAUÁ — DOCUMENTAÇÃO COMPLETA

### 5.1 Coordenadas do Workspace Mauá

| Parâmetro | Valor |
|---|---|
| **Lakehouse** | `lh_cidade_inteligente_maua` |
| **Notebooks** | 4 |
| **Domínios** | Meio Ambiente · Planejamento Urbano |
| **Token API** | `TOKEN_MAUA` |

### 5.2 Inventário de Notebooks — Mauá

| # | Notebook | Domínio | Saída | Modo |
|---|---|---|---|---|
| 1 | `nb_ingest_maua_acto_gestao_ambiente` | Meio Ambiente | `gold_maua_meio_ambiente_solicitacoes`, `gold_maua_meio_ambiente_etapas` | overwrite Delta ✅ |
| 2 | `nb_ingest_maua_acto_gestao_plan_urbano` | Planejamento Urbano | 26 Parquet silver + etapas em `Files/silver_planejamento_urbano/` | **Parquet** ⚠️ |
| 3 | `nb_silver_maua_plan_urbano` | Planejamento Urbano | `gold_maua_pl_urbano` | overwrite Delta ✅ |
| 4 | `nb_silver_maua_etapas_tempo_plan_urbano` | Planejamento Urbano | tabela gold de tempo de etapa | overwrite Delta ✅ |

#### Detalhamento: `nb_ingest_maua_acto_gestao_ambiente`

- **Fonte:** API Acto Gestão · `TOKEN_MAUA`
- **Payload:** `Files/payload/payload_maua_meio_ambiente.json`
- **15 codCatalogos** de Meio Ambiente
- Funções: `extrair_tabela_acto_gestao()` → solicitações + etapas via `ObterTempoEtapaRelatorio`

#### Detalhamento: `nb_ingest_maua_acto_gestao_plan_urbano`

- **Fonte:** API Acto Gestão · `TOKEN_MAUA`
- **26 payloads individuais:** Deferimento, Habite-se, Alvarás (construção, demolição, reforma, muro, movimentação de terra, reconstrução), Certidões (uso do solo, medidas, numeração, informativa), Cadastro de documentos, Autorização de funcionamento, Regularização, Prorrogação, Substituição de projeto

### 5.3 Migração Pendente

| Arquivo | Descrição | Ação |
|---|---|---|
| `Files/silver_planejamento_urbano/silver_solicitacoes_maua{0-25}.parquet` | 26 Parquets — um por serviço | Refatorar para `saveAsTable()` Delta |
| `Files/silver_planejamento_urbano/silver_maua_pl_urbano_etapas.parquet` | Etapas consolidadas | Idem |
| `Files/silver_planejamento_urbano/silver_decisoes_plan_urbano.parquet` | Decisões deferido/indeferido | Idem |

### 5.4 Padrão de Ingestão — Mauá

```python
%run ./config_api_acto
TOKEN = TOKEN_MAUA
extrair_tabela_acto_gestao(arquivo="payload_maua_*.json", lista_cod_catalogo=[...])
```

Wrapper próprio: `nb_utils_maua_ingest_acto_gestao` em `utils/` com `extrair_tabela_acto_gestao()` adaptado para o endpoint de Mauá.

---

## 6. DADOS PÚBLICOS — IBGE / SIDRA / RAIS / CAGED

> **Última atualização:** 06/05/2026 tarde — Checklist de validação manual concluído (passos 0–9). `silver.rais` (571.904) · 9× `silver.censo_*` · 11× `gold.censo_*` gravados. `nb_checar_fontes` validado (6 fontes, 6 logs). `fetch_sidra_fabric` refatorado com `rename_columns` param. Pipeline pronta para run automatizado.

### 6.1 Coordenadas

| Parâmetro | Valor |
|---|---|
| **Lakehouse** | `lh_dados_publicos` *(recriado com schemas em 05/05/2026)* |
| **Workspace ID** | `96fe5a53-3a22-4443-8d0a-e2f6d61a2690` |
| **SQL Endpoint** | `ena6obg6j2cevcppw7dn7yu57a-knnp5frchjbujdik4l3nmgrgsa.datawarehouse.fabric.microsoft.com` |
| **Schemas** | `bronze` · `silver` · `gold` · `monitoramento` |
| **Cobertura** | 15 municípios · 3 clusters |
| **Modo de consumo PBI** | Direct Lake |
| **Padrão de escrita Gold** | `save_delta()` com V-Order obrigatório |
| **Fonte de Verdade** | `GUIA_MESTRE_DADOS_PUBLICOS` (v3.0) |

### 6.2 Clusters e Municípios

**Regra de negócio:** Clientes core têm dados completos; benchmarks são usados exclusivamente para comparação analítica nos dashboards (evolução populacional, ranking PIB, formalização).

| Cluster | Papel | Municípios | Código IBGE |
|---|---|---|---|
| **SANTOS** | ⭐ Core | Santos | `3548500` |
| **SANTOS** | Benchmark | São Vicente · Praia Grande · Guarujá · Cubatão | `3551009` · `3541000` · `3518701` · `3513504` |
| **OSASCO** | ⭐ Core | Osasco | `3534401` |
| **OSASCO** | Benchmark | São José dos Campos · Sorocaba · São Bernardo do Campo · Ribeirão Preto · Santo André · São Caetano do Sul | `3549904` · `3552205` · `3548708` · `3543402` · `3547809` · `3548807` |
| **MAUÁ** | ⭐ Core | Mauá | `3529401` |
| **MAUÁ** | Benchmark | Carapicuíba · Itapevi · Ribeirão Pires | `3510609` · `3522505` · `3543303` |

> `CLUSTERS` dict em `nb_utils_ibge` é a **única fonte de verdade** dos 15 municípios. OSASCO confirmado em 06/05 pelo painel legado (SJC, Sorocaba, SBC, Ribeirão Preto, Santo André, São Caetano). Área territorial dinâmica via `ingest_area_territorial()` (SIDRA t/1301) — sem hardcode.  
> Referência completa de municípios em `Files/municipio_names.csv` (40+ municípios, inclui municípios em implantação). ⚠️ OSASCO section do CSV ainda tem Taboão da Serra, Suzano, Mogi, Várzea Paulista — pendente correção para SJC, Sorocaba, SBC, Ribeirão Preto, Santo André.

### 6.3 Notebooks — Pipeline de Dados (12 notebooks)

| # | Notebook | Fonte | Saída | Dependência |
|---|---|---|---|---|
| 1 | `nb_utils_ibge` | — | `fetch_sidra_fabric`, `save_delta`, `CLUSTERS` | — |
| 2 | `nb_ingest_populacao_ibge` | SIDRA t/6579 | `bronze.ibge_populacao` → `silver.populacao` | **Rodar PRIMEIRO** |
| 3 | `nb_ingest_pib_ibge` | SIDRA t/5938 | `bronze.ibge_pib` + `bronze.ibge_pib_componentes` → `silver.pib` + `silver.pib_componentes` | Após #2 (per capita) |
| 4 | `nb_ingest_rais_bigquery` | BigQuery RAIS | `bronze.rais` → `silver.rais` *(+ nome_municipio via CSV + secao_cnae derivada)* | JSON BigQuery + `Files/municipio_names.csv` |
| 5 | `nb_ingest_caged` *(Yuri)* | BigQuery CAGED proto | `bronze.caged` → `silver.caged` | JSON BigQuery + `Files/municipio_names.csv` |
| 6 | `nb_gold_populacao` | `silver.populacao` | `gold.populacao` | Após #2 |
| 7 | `nb_gold_pib` | `silver.pib` + `silver.pib_componentes` | `gold.pib` | Após #3 |
| 8 | `nb_gold_mercado_trabalho` | `silver.rais` + `silver.caged` | `gold.mercado_trabalho` | Após #4, #5 |
| 9 | `nb_ingest_censo_ibge` | SIDRA (múltiplas tabelas) | 9× `silver.censo_*` | Pode rodar em paralelo com #6–7 |
| 10 | `nb_gold_censo_demografico` | `silver.censo_*` | 12× `gold.censo_*` + paridade | Após #9 |

> **Removidos em 05/05/2026:** `nb_ingest_cempre_ibge` (redundante com RAIS), `nb_ingest_censo_paridade_total` (incorporado ao #10), `nb_validacao_dados` (manual, descontinuado), `nb_analise_visual_gold` (manual, descontinuado).

### 6.4 Notebooks — Sistema de Monitoramento (nbs_caged/)

O sistema de monitoramento controla a disponibilidade e o ciclo de ingestão das fontes externas. Responsável principal: **Yuri** (CAGED); **Victor** (IBGE — extensão nova).

| Notebook | Responsável | Função | Saída |
|---|---|---|---|
| `nb_setup_monitoramento` | Yuri/Victor | Cria todas as tabelas do schema `monitoramento`. **Idempotente.** | `monitoramento.*` (4 tabelas) |
| `nb_ingest_calendario_caged` | Yuri | Popula calendário de divulgação do NOVO CAGED (MTE) | `monitoramento.calendario_divulgacao_caged` |
| `nb_checar_fontes` | Yuri/Victor | Verifica todas as fontes ativas via dispatch por `tipo_automacao` | `monitoramento.log_consulta_fonte` |
| `nb_checar_caged` | Yuri | Verifica FTP MTE — versão standalone (antecessor do `nb_checar_fontes`) | `monitoramento.log_consulta_fonte` |
| `nb_checar_ibge` | Victor | ~~Criar~~ **Não necessário** — lógica `sidra_api` absorvida pelo `nb_checar_fontes` (dispatch genérico) | — |
| `nb_ingest_caged_auto` | Yuri | Ingestão automática FTP + rebuild Gold CAGED | `silver.caged` · `gold.caged_*` |
| `nb_seed_log_historico` | Yuri | Executa uma vez após migração manual para inicializar o log | `monitoramento.log_ingestao_fonte` |

### 6.5 Catálogo de Tabelas — Dados Públicos

> Convenção pós-migração: `schema.nome` — schema carrega a camada, sem repetição no nome.

#### `bronze` — ingestão bruta
| Tabela | Fonte | Conteúdo |
|---|---|---|
| `bronze.ibge_populacao` | SIDRA t/6579 · v/9324 | População residente (raw) |
| `bronze.ibge_pib` | SIDRA t/5938 · v/37 | PIB total a preços correntes (raw) |
| `bronze.ibge_pib_componentes` | SIDRA t/5938 · v/513,517,6575,525,543 | Componentes VAB (raw) |
| `bronze.rais` | BigQuery `br_me_rais` | RAIS raw — 15 municípios SP · 2006–2024 |
| `bronze.caged` | BigQuery `br_me_caged` | CAGED agregado — 15 municípios SP · 2020–presente |

#### `silver` — limpo e padronizado
Schema canônico base: `id_municipio · nome_municipio · ano · indicador · valor`

| Tabela | Domínio | Conteúdo |
|---|---|---|
| `silver.populacao` | Demografia | `populacao_residente` por município e ano |
| `silver.pib` | Economia | `pib_total_r_mil` · `pib_per_capita_r` |
| `silver.pib_componentes` | Economia | VAB por setor CNAE (agropecuária, indústria, serviços, adm pública, impostos) |
| `silver.rais` | Trabalho | RAIS — 15 municípios · `nome_municipio` · `secao_cnae` (A–U) · `cnae_2` (divisão) · `tamanho_estabelecimento` · `vinculos_ativos` |
| `silver.caged` | Trabalho | CAGED — 15 municípios · mensal · `secao_cnae` · `saldo_movimentacao` |
| `silver.censo_piramide_2022` | Censo | Pirâmide etária — sexo × faixa |
| `silver.censo_envelhecimento` | Censo | Índice de envelhecimento — t/9756 · 2010+2022 |
| `silver.censo_pop_historica` | Censo | Pop. por sexo e faixa — 2000+2010 — t/1552 |
| `silver.censo_frequencia_escola` | Censo | Frequência escolar 6–17 anos — t/10058 |
| `silver.censo_domicilios_raca` | Censo | Domicílios por tipo e cor/raça — t/6893 |
| `silver.censo_renda_2010` | Censo | Renda domiciliar per capita 2010 — t/3578 |
| `silver.censo_renda_2022` | Censo | Renda domiciliar per capita 2022 — t/10296 |
| `silver.censo_fecundidade` | Censo | Fecundidade — t/10076 · 2010+2022 |
| `silver.censo_urbana_rural_sidra` | Censo | Pop. urbana/rural — SIDRA t/9605 · 2022 |

#### `gold` — Direct Lake / Power BI
| Tabela | Domínio | Conteúdo |
|---|---|---|
| `gold.populacao` | Demografia | Pop. + variação YoY + cluster |
| `gold.pib` | Economia | PIB total · per capita · ranking · % VAB por setor |
| `gold.mercado_trabalho` | Trabalho unificado | RAIS (estoque) + CAGED (fluxo mensal) — 371.728 registros |
| `gold.censo_piramide_populacao` | Censo | + flag ativa/inativa |
| `gold.censo_envelhecimento` | Censo | Por cor/raça — 2010 + 2022 |
| `gold.censo_genero` | Censo | Proporção por sexo |
| `gold.censo_dependencia_demografica` | Censo | Razão ativa/inativa |
| `gold.censo_frequenta_escola` | Censo | Agrupado por nível de ensino |
| `gold.censo_domicilios` | Censo | Por tipo e raça |
| `gold.censo_renda` | Censo | Distribuição por faixa — 2010 vs 2022 |
| `gold.censo_fecundidade` | Censo | Total (filtro por cor/raça = Total) |
| `gold.censo_populacao_urbana_rural` | Censo | Evolução urbana/rural histórica |
| `gold.censo_alfabetizacao` | Censo | SIDRA t/9542 direto |
| `gold.censo_urbana_rural` | Censo | SIDRA t/9605 direto |
| `gold.censo_migracao` | Censo | SIDRA t/9843 direto |
| `gold.censo_territorio` | Censo | Densidade demográfica — dinâmico (SIDRA t/1301) |
| `gold.caged_saldo_movimentacao_anual` | CAGED (Yuri) | Saldo × seção CNAE × mês |
| `gold.caged_saldo_secao` | CAGED (Yuri) | Saldo + salário por seção CNAE |
| `gold.caged_media_idade` | CAGED (Yuri) | Média de idade por admissões/demissões |
| `gold.caged_media_salario` | CAGED (Yuri) | Salário médio por seção CNAE |
| `gold.caged_saldo_idade` | CAGED (Yuri) | Saldo por faixa etária |

#### `monitoramento` — controle operacional de fontes
| Tabela | Conteúdo |
|---|---|
| `monitoramento.config_fontes` | Registro de todas as fontes ativas com `tipo_automacao` e parâmetros |
| `monitoramento.log_consulta_fonte` | Log de cada verificação — `novo_dado_disponivel`, `resultado_consulta` |
| `monitoramento.log_ingestao_fonte` | Log de cada ingestão — `status_ingestao`, `rows_ingested`, `erro` |
| `monitoramento.status_fontes_painel` | Status executivo por fonte — alimenta painel de operação |
| `monitoramento.calendario_divulgacao_caged` | Calendário de divulgação do NOVO CAGED (MTE) — 2026 |

### 6.6 Sistema de Monitoramento — Arquitetura

```
pl_monitoramento (diário)
    │
    ├── nb_checar_fontes          ← verifica todas as fontes via dispatch
    │       ├── CAGED      → tipo_automacao = "calendario" (FTP MTE)
    │       ├── SSP        → tipo_automacao = "http_head"
    │       ├── IBGE_*     → tipo_automacao = "sidra_api"   ← NOVO (Victor)
    │       └── RAIS_BQ    → tipo_automacao = "bigquery_check" ← NOVO (Victor)
    │
    └── Se novo_dado_disponivel:
            CAGED → nb_ingest_caged_auto (Yuri)
            IBGE  → nb_ingest_*_ibge   (Victor)
```

**Fontes registradas em `monitoramento.config_fontes`:**

| `fonte_id` | `tipo_automacao` | Periodicidade | Responsável |
|---|---|---|---|
| `CAGED` | `calendario` | Mensal | Yuri |
| `SSP_CRIMINAIS` | `http_head` | Mensal | — |
| `SSP_PRODUTIVIDADE` | `http_head` | Mensal | — |
| `IBGE_POPULACAO` | `sidra_api` | Anual | Victor |
| `IBGE_PIB` | `sidra_api` | Anual | Victor |
| `RAIS_BIGQUERY` | `bigquery_check` | Anual | Victor |

### 6.7 Pipeline `pl_monitoramento_ingest` — Arquitetura (atualizado 06/05)

```
Checar Fontes
    ├── If CAGED          → True: nb_ingest_caged_auto          (existente)
    ├── If SSP            → True: nb_ingest_ssp_auto            (existente)
    ├── If IBGE_POPULACAO → True: nb_ingest_populacao_ibge → nb_gold_populacao   (novo)
    ├── If IBGE_PIB       → True: nb_ingest_pib_ibge → nb_gold_pib               (novo)
    └── If RAIS_BIGQUERY  → True: nb_ingest_rais_bigquery → nb_gold_mercado_trabalho (novo)
                          ↓ (todos convergem)
               nb_atualizar_status_painel
```

Expressões If (Fabric Pipeline Expression Language):
- IBGE_POPULACAO: `@equals(json(activity('Checar Fontes').output.result.exitValue).IBGE_POPULACAO.novo_dado_disponivel, true)`
- IBGE_PIB: `@equals(json(activity('Checar Fontes').output.result.exitValue).IBGE_PIB.novo_dado_disponivel, true)`
- RAIS_BIGQUERY: `@equals(json(activity('Checar Fontes').output.result.exitValue).RAIS_BIGQUERY.novo_dado_disponivel, true)`

### 6.8 Bugs corrigidos — `nb_utils_ibge` / pipeline IBGE

| Data | Bug | Causa | Fix |
|---|---|---|---|
| 06/05 manhã | `DELTA_INVALID_CHARACTERS_IN_COLUMN_NAMES` | `fetch_sidra_fabric` renomeava colunas com headers SIDRA descritivos (ex: `Nível Territorial (Código)`) que o Delta rejeita | Removido o `df_pd.rename(columns=headers)` — short codes preservados |
| 06/05 manhã | `UNRESOLVED_COLUMN D1C` | Após rename, colunas viraram `Município_Código` etc., incompatíveis com `col("D1C")` das células silver | Mesmo fix acima |
| 06/05 manhã | `RecursionError: maximum recursion depth exceeded` | Monkey-patch `requests.get = lambda` em `nb_utils_ibge` envolvia em lambda a cada `%run` | Removido monkey-patch; `verify=False, timeout=120` direto em `requests.get(url, ...)` |
| 06/05 manhã | `NameError: df_silver is not defined` | `nb_ingest_pib_ibge` usava `df_silver.pib = ...` como namespace inexistente | Substituído por variável `df_silver_pib` |
| 06/05 tarde | `secao_cnae DESCONHECIDO: 571.904 (100%)` em `silver.rais` | `cnae_2` no BigQuery é código de CLASSE CNAE (5 dígitos, ex: 10937 = classe 1093-7), não divisão (2 dígitos). `secao_cnae_expr` esperava divisão | Fix: `lpad(col("cnae_2"), 5, "0").substr(1, 2).cast("int")` extrai primeiros 2 dígitos como divisão |
| 06/05 tarde | Colunas silver censo com short codes (`d1n`, `d2n`, `v`) | `processar_extração_sidra` aplicava `to_snake_case` nos short codes (que permanecem `d1n`) em vez dos nomes descritivos | Adicionado `rename_columns=False` (default) em `fetch_sidra_fabric`; censo usa `rename_columns=True` + simplificação `grupo_de_idade` → `idade` |
| 06/05 tarde | `Duplicate column names` após rename SIDRA | Chaves SIDRA são UPPERCASE (`NC`, `D1C`); `k.endswith('c')` (lowercase) nunca era True → sem sufixo `_codigo` → `NC` e `NN` viravam ambos `nivel_territorial` | Fix: checar `'(Código)' in v` no valor descritivo antes de aplicar `to_snake_case` |
| 06/05 tarde | `CANNOT_DETERMINE_TYPE` em `nb_checar_fontes` | `log_rows` com valores `None` — Spark não infere tipo | Fix: `pd.DataFrame(log_rows).fillna("")` como intermediário antes de `createDataFrame` |

### 6.9 Status por Domínio

| Domínio | Fonte | Status | Próxima ação |
|---|---|---|---|
| **Demografia** | IBGE SIDRA | ✅ Estabilizado — `gold.populacao` | — |
| **Economia** | IBGE SIDRA | ✅ Estabilizado — `gold.pib` | — |
| **Trabalho — Estoque** | RAIS BigQuery | ✅ `silver.rais` · join validado | — |
| **Trabalho — Fluxo** | CAGED BigQuery | ✅ `silver.caged` · 297k registros | Yuri migrar para FTP |
| **Censo Demográfico** | IBGE SIDRA | ✅ 15 tabelas Gold concluídas | — |
| **Monitoramento IBGE** | SIDRA API | ✅ Implementado — `nb_checar_fontes` dispatch `sidra_api` + `bigquery_check` | — |
| **Segurança Pública** | SSP-SP | 🔍 Em estruturação | — |
| **Power BI** | Direct Lake | 🟣 Pendente — modelo semântico | Semana 09/05 |

### 6.8 Bugs Identificados — Pendentes de Correção (nbs_caged/)

> Responsável: **Yuri** — não modificar sem alinhamento.

| Bug | Notebook | Detalhe | Impacto |
|---|---|---|---|
| ❌ Schema errado no calendário | `nb_checar_caged` | Lê `config.caged_calendario_divulgacao` — deveria ser `monitoramento.calendario_divulgacao_caged` | CAGED check falha |
| ❌ Tabela sem schema | `nb_checar_caged` | Verifica `silver_caged` sem schema — deveria ser `silver.caged` | Após migração: erro |
| ❌ Tabelas Gold sem schema | `nb_ingest_caged_auto` | Salva `gold_caged_saldo_*` sem schema — deveria ser `gold.caged_*` | Após migração: erro |
| ❌ Tabelas Silver sem schema | `nb_ingest_caged_auto` · `nb_seed_log_historico` | Lê/salva `silver_caged` sem schema | Após migração: erro |
| ❌ ABFSS path com item ID antigo | `nb_ingest_caged_auto` | Path hardcoded com item ID do LH antigo (`66918002-...`) — precisa atualizar para novo LH | Falha ao ler aux_tables |

### 6.9 Alertas Técnicos

> **CEMPRE:** SIDRA t/3421 exige `v/708` (não `666`) e `c12762` (não `693`). Layout de colunas muda com classificação.

> **PIB per capita:** Calculado como `(pib_total * 1000) / populacao`. `nb_ingest_pib_ibge` **deve rodar APÓS** `nb_ingest_populacao_ibge`.

> **BigQuery — credencial:** `Files/bd2024-444413-1084f2b9d765.json` usado por `nb_ingest_rais_bigquery` e `nb_ingest_caged`. Precisa ser reuploado no novo LH antes de executar qualquer notebook BigQuery.

> **Fabric Environment — `env_dados_publicos`** (criado 06/05): pacotes `google-cloud-bigquery`, `pyarrow`, `db-dtypes`, `ipeadatapy` pré-instalados. Vinculado a `nb_checar_fontes`, `nb_ingest_rais_bigquery`, `nb_ingest_censo_ibge`. Notebooks **não devem ter `%pip install`** — o Environment garante as dependências em modo pipeline e interativo.

> **aux_tables/ no novo LH:** `nb_ingest_caged_auto` (Yuri) lê arquivos de `Files/aux_tables/` (CNAE, CBO, dicionário). Reuploar no novo LH e atualizar o path ABFSS hardcoded.

> **`nb_ingest_censo_paridade_total` eliminado:** lógica incorporada em `nb_gold_censo_demografico` como seções 9–12. Não existe mais como notebook separado.

---

## 7. OUTROS MUNICÍPIOS

### 7.1 Aparecida de Goiânia

- **Status:** Em implantação — sem notebooks mapeados ainda
- **Caminho Fabric:** Acto Cidade Inteligente > Aparecida de Goiânia
- **Ação:** Atualizar quando notebooks forem disponibilizados

### 7.2 São José do Rio Preto (SJRP)

- **Status:** Em implantação — sem notebooks mapeados ainda
- **Caminho Fabric:** Acto Cidade Inteligente > SJRP
- **Ação:** Atualizar quando notebooks forem disponibilizados

---

## 8. MÓDULO ACTO — DOCUMENTAÇÃO TÉCNICA

### 8.1 Funções Utilitárias Centrais

#### `nb_utils_api_acto_gestao` — Funções API Gestão

| Função | Papel |
|---|---|
| `fetch_tabela()` | Chamada HTTP à API Acto Gestão com paginação |
| `adicionar_etapa_atual()` | Adiciona etapa atual às solicitações — espera coluna `'Nº Solicitação\|1'` |
| `adicionar_etapa_atual_2()` | Idem, mas espera coluna `'Nº Solicitação'` — formatos **não intercambiáveis** |
| `harmonizar_nome_bairros()` | Normaliza nomes de bairros |
| `ajustar_nome_colunas()` | Padroniza nomes de colunas |
| `import_json_payload()` | Importa payload JSON externo (usado apenas por SEPREF) |

> **Atenção:** `adicionar_etapa_atual()` vs `adicionar_etapa_atual_2()` — endpoints diferentes retornam formatos diferentes. Validar coluna de entrada antes de usar.

#### `nb_utils_api_acto_gestao_obras` — Funções API Obras

- Login dinâmico (renovação automática de token)
- 16 células mapeadas
- Usado por: `nb_ingest_silver_acto_gestao_obras_santos`

#### `nb_utils_ingest_acto_gestao` — Funções Extração

- Funções de extração via API
- **⚠️ R7:** Chama `raise_for_status()` sem `try/except` — falhas de API propagam silenciosamente para as cadeias de avaliacao_servicos e curso_motoristas

### 8.2 Tokens por Município

| Município | Token | Variável |
|---|---|---|
| Santos (serviços) | JWT | `TOKEN_SANTOS` |
| Santos (obras) | JWT | `TOKEN_SANTOS_OBRAS` — renovado via `nb_get_token_api` (tenant `santos_obras`) |
| Osasco | JWT | `TOKEN_OSASCO` |
| Mauá | JWT | `TOKEN_MAUA` |

**Arquivo de configuração multi-município:** `config_api_acto_atualizado` em `nbs/carta_servicos/gestao_prazo_sla/`

### 8.3 Padrão de Payload API

```python
{
  "codCatalogo": <int>,       # Código do catálogo de serviço
  "codigos_etapa": [<int>],   # Lista de etapas a extrair
  "dataInicio": "DD/MM/AAAA",
  "dataFim": "DD/MM/AAAA"
}
```

### 8.4 Códigos de Catálogo (codCatalogo) por Domínio — Santos

| Domínio | codCatalogos (referência) |
|---|---|
| CET — Credencial Idoso/PcD | Ver `nb_gold_acto_gestao_cet` |
| CET — Carga/Descarga | Ver `nb_gold_acto_gestao_cet_carga_descarga` |
| SEGOV | Ver `nb_gold_acto_gestao_segov` |
| SEINFRA | Ver `nb_gold_acto_gestao_seinfra` |
| SEPREF | Ver `nb_gold_acto_gestao_sepref` (via JSON payload externo) |
| Manifestações Ouvidoria | Ver `nb_gold_acto_gestao_manifestacoes_ouvidoria` |
| Obras | Ver `nb_utils_api_acto_gestao_obras` |
| Mauá Meio Ambiente | 15 codCatalogos em `payload_maua_meio_ambiente.json` |
| Mauá Planejamento Urbano | 26 payloads individuais em `nb_ingest_maua_acto_gestao_plan_urbano` |
| Osasco CRAS | `payload_osasco_atendimento_cras.json` |

### 8.5 Funções Duplicadas a Consolidar (R2)

As seguintes funções aparecem em múltiplos notebooks:

| Função | Notebooks com duplicata | Plano |
|---|---|---|
| `ajustar_nome_colunas()` | múltiplos | Criar `nb_utils_shared`, migrar com `%run` |
| `harmonizar_nome_bairros()` | múltiplos | Idem |
| `mapa_bairros` | múltiplos | Idem |

### 8.6 Cálculo de Tempo de Atendimento

```
tempo_atendimento = data_finalizacao - data_criacao
```

- Unidade: minutos (SETRE/Osasco), horas ou dias (CET/SEPREF)
- **Apenas para OS finalizadas** — OS em andamento não entram na média
- `null` quando `data_finalizacao` é nulo

### 8.7 Regras de Negócio — Status de Solicitação

| Status | Significado | Ação no Dashboard |
|---|---|---|
| `Finalizado` | OS concluída | Incluir em métricas de throughput |
| `Em Andamento` | OS em processamento | Backlog ativo — monitorar envelhecimento |
| `Cancelado` | OS cancelada | Excluir de KPIs de produtividade; manter para taxa de cancelamento |

### 8.8 Nova Arquitetura Acto — Módulo Unificado Multi-Município

> **Pasta:** `Acto/nbs/` · **Status:** Em produção (4 fontes ativas)
>
> Esta é a arquitetura de **segunda geração** do módulo Acto. Substitui o padrão antigo de notebooks por município com um pipeline parametrizado, token centralizado e schema EAV unificado. Os notebooks da pasta `Santos/nbs/` continuam em produção e **não foram migrados** — coexistem com a nova arquitetura.

#### Comparativo: Arquitetura Antiga vs. Nova

| Aspecto | Antiga (Santos/nbs/) | Nova (Acto/nbs/) |
|---|---|---|
| Token | Hardcoded por notebook | `nb_get_token_api` — cache em memória, multi-município |
| Bronze | 1 NB por domínio (ingestão + transformação misturadas) | `nb_bronze_acto_gestao` parametrizado via `mssparkutils.notebook.run()` |
| Schema | Colunas fixas por domínio | EAV: `fato_solicitacoes` + `fato_campos` (melt) + `fato_etapas` |
| Silver | Inexistente ou por domínio | Silver unificado: UNION de todos os municípios/fontes |
| Gold | 1 NB por domínio com extração embutida | 1 NB por domínio lendo da Silver unificada via pivot |
| Orquestração | Pipeline Data Factory por domínio | Loop Python sobre lista de `fontes` |

---

#### 8.8.1 `nb_get_token_api` — Gestão Centralizada de Tokens

**Localização:** `Acto/nb_get_token_api.ipynb`

Centraliza a obtenção e renovação de tokens JWT para todos os municípios com **cache em memória** — evita chamadas redundantes ao endpoint de login.

```python
TOKEN_URL = "https://app-shared-prd-apiloginunico-002.codeciphers.com/ccloginunico/v2/Token"
```

**Tenants configurados:**

| Tenant | Base URL | param_login | Credenciais |
|---|---|---|---|
| `santos` | `gestaosantosdigital.acto.net.br` | `5103` | `ACTO_SANTOS_USER` / `ACTO_SANTOS_SENHA` |
| `santos_obras` | `gestaoaprovasantos.acto.net.br` | `3997` | `ACTO_OSASCO_USER` / `ACTO_OSASCO_SENHA` |
| `osasco` | `gestaoosascodigital.acto.net.br` | `4861` | `ACTO_OSASCO_USER` / `ACTO_OSASCO_SENHA` |
| `maua` | `gestaomaua.acto.net.br` | `3736` | `ACTO_OSASCO_USER` / `ACTO_OSASCO_SENHA` |

**Lógica de cache:**
```python
def get_acto_token(tenant, env_user, env_senha) -> str:
    # Retorna token cacheado se não expirou (margem de 60s)
    # Caso expirado: POST para TOKEN_URL com grant_type=password
    # Armazena em _token_cache[tenant] com expires_at
```

**Como usar nos notebooks:**
```python
%run ./nb_get_token_api
TOKEN_SANTOS = get_acto_token("santos", ACTO_USER, ACTO_SENHA)
TOKEN_OSASCO = get_acto_token("osasco", ACTO_USER, ACTO_SENHA)
```

---

#### 8.8.2 `nb_utils_request_api` — Funções HTTP Centrais

**Localização:** `Acto/nbs/utils/nb_utils_request_api.ipynb`

Contém todas as funções de acesso à API Acto Gestão. Carregado via `%run ./nb_utils_request_api`.

| Função | Assinatura | Descrição |
|---|---|---|
| `make_headers(token)` | `str → dict` | Monta cabeçalho `Authorization: Bearer {token}` |
| `import_json_payload(path_json)` | `str → str` | Lê JSON do lakehouse e serializa para string |
| `get_codCatalogo_from_payload(path_json)` | `str → list[int]` | Extrai lista única de `codCatalogo` do payload |
| `fetch_dados_etapa(codigos, token)` | `list, str → DataFrame` | POST para `ObterTempoEtapaRelatorio` |
| `fetch_dados_solicitacoes(payload_str, token)` | `str, str → DataFrame` | POST para `VisualizarDadosIntermediarios` |
| `clean_col_name(col)` | `str → str` | Remove sufixo `\|N`, normaliza snake_case sem acentos |
| `consolidar_colunas_duplicadas(df)` | `DataFrame → DataFrame` | Coalesce de colunas com mesmo nome semântico |
| `extrair_tabela_acto_gestao(path_payload, token)` | `str, str → tuple[df, df]` | **Função principal** — retorna `(df_solicitacoes, df_etapas)` |

**Endpoints da API:**

| Endpoint | Uso |
|---|---|
| `POST /api/Tabela/VisualizarDadosIntermediarios` | Solicitações por payload |
| `POST /api/RelatoriosEtapa/ObterTempoEtapaRelatorio` | Tempo por etapa por codCatalogos |

---

#### 8.8.3 `nb_bronze_acto_gestao` — Bronze Parametrizado

**Localização:** `Acto/nbs/nbs_bronze/nb_bronze_acto_gestao.ipynb`

Notebook genérico que recebe parâmetros via `mssparkutils.notebook.run()` e gera 3 tabelas Bronze para qualquer fonte.

**Parâmetros de entrada:**

| Parâmetro | Exemplo | Descrição |
|---|---|---|
| `PAYLOAD_PATH` | `/lakehouse/default/Files/payloads/payload_santos_cet.json` | Caminho do payload no lakehouse |
| `TOKEN` | `eyJ...` | Token JWT do município |
| `ID_FONTE` | `santos_cet` | Identificador único da fonte (sufixo das tabelas) |
| `MUNICIPIO` | `Santos` | Metadado de município |
| `SECRETARIA` | `CET` | Metadado de secretaria |
| `UNIDADE_ORGANIZACIONAL` | `CET` | Metadado de unidade |

**Tabelas geradas (schema EAV):**

| Tabela | Schema principal | Descrição |
|---|---|---|
| `bronze.fato_solicitacoes_{ID_FONTE}` | `id_os, servico, status_fluxo, data_criacao, data_finalizacao, municipio, secretaria, ...` | Uma linha por OS — campos principais |
| `bronze.fato_campos_{ID_FONTE}` | `id_os, servico, campo, valor, municipio, secretaria, origem, data_carga` | Formato melt/EAV — campos específicos do domínio |
| `bronze.fato_etapas_{ID_FONTE}` | `id_os, etapa, data_inicio_etapa, data_fim_etapa, municipio, secretaria, ...` | Uma linha por etapa |

> **Por que EAV?** Cada domínio tem colunas diferentes (bairro, cpf, placa, CNPJ…). O formato melt elimina colunas esparsas e permite um único schema Bronze para todos os domínios.

---

#### 8.8.4 `nb_bronze_orquestracao` — Orquestrador Bronze

**Localização:** `Acto/nbs/nbs_bronze/nb_bronze_orquestracao.ipynb`

Obtém tokens e itera sobre a lista de fontes, chamando `nb_bronze_acto_gestao` para cada uma.

**Fontes ativas (2026-05):**

```python
fontes = [
    {"id_fonte": "santos_cet",                  "municipio": "Santos", "secretaria": "CET",   "token": TOKEN_SANTOS},
    {"id_fonte": "santos_sepref",               "municipio": "Santos", "secretaria": "SEPREF","token": TOKEN_SANTOS},
    {"id_fonte": "osasco_atendimento_cras",     "municipio": "Osasco", "secretaria": "SAS",   "token": TOKEN_OSASCO},
    {"id_fonte": "osasco_atendimento_trabalhador","municipio": "Osasco","secretaria": "SETRE", "token": TOKEN_OSASCO},
]
```

**Fluxo de execução:**
```
nb_bronze_orquestracao
    │── %run nb_get_token_api
    │── TOKEN_SANTOS = get_acto_token("santos", ...)
    │── TOKEN_OSASCO = get_acto_token("osasco", ...)
    └── para cada fonte em fontes:
            mssparkutils.notebook.run("nb_bronze_acto_gestao", args={...})
                └── %run nb_utils_request_api
                └── extrair_tabela_acto_gestao(PAYLOAD_PATH, TOKEN)
                └── write_bronze() → 3 tabelas Delta
```

---

#### 8.8.5 `nb_silver_acto_gestao` — Silver Unificado Multi-Município

**Localização:** `Acto/nbs/nbs_silver/nb_silver_acto_gestao.ipynb`

Faz UNION de todas as tabelas Bronze por sufixo e salva em Silver unificado.

```python
FONTES = ["santos_cet", "santos_sepref", "osasco_atendimento_cras", "osasco_atendimento_trabalhador"]

silver_map = {
    "silver.fato_solicitacoes": union_bronze("fato_solicitacoes", FONTES),
    "silver.fato_campos":       union_bronze("fato_campos",       FONTES),
    "silver.fato_etapas":       union_bronze("fato_etapas",       FONTES),
}
```

Aplica `cast_date_cols()` para tipagem de datas antes de salvar em Delta.

---

#### 8.8.6 Notebooks Gold — Pivot por Domínio

Cada Gold filtra da Silver unificada pela(s) fonte(s) do domínio e faz **pivot** de `fato_campos` para reconstruir as colunas específicas.

**Padrão de leitura Gold:**
```python
# 1. Solicitações do domínio
df_sol = spark.table("silver.fato_solicitacoes").filter(col("fonte").isin(FONTES_DOMINIO))

# 2. Pivot dos campos específicos
df_pivot = spark.table("silver.fato_campos")
    .filter(col("campo").isin(CAMPOS_DOMINIO))
    .groupBy("id_os").pivot("campo", CAMPOS_DOMINIO).agg(first("valor"))

# 3. Última etapa de cada OS
df_etapas = spark.table("silver.fato_etapas")
    .groupBy("id_os").agg(max("etapa").alias("etapa_atual"), max("data_fim_etapa"))

# 4. Join
df_gold = df_sol.join(df_pivot, "id_os", "left").join(df_etapas, "id_os", "left")
```

**Notebooks Gold ativos:**

| Notebook | Fonte | Campos pivotados | Tabela Gold |
|---|---|---|---|
| `nb_gold_santos_cet` | `santos_cet` | 20 campos (bairro, canal, cpf, placa…) | `gold_fato_solicitacoes_cet` |
| `nb_gold_santos_sepref` | `santos_sepref` | 9 campos (bairro, canal, cpf, nome_logradouro…) | `gold_fato_solicitacoes_sepref` |
| `nb_gold_osasco_atendimento_cras` | `osasco_atendimento_cras` | — | `gold_osasco_atendimento_cras` |
| `nb_gold_osasco_atendimento_trabalhador` | `osasco_atendimento_trabalhador` | — | `gold_osasco_atendimento_trabalhador` |

**Orquestrador Gold:** `_nb_gold_orquestracao` — chama os Gold notebooks via `%run`.

---

#### 8.8.7 Fluxo Completo da Nova Arquitetura

```
TOKENS
  nb_get_token_api
  └── get_acto_token(tenant) → TOKEN_SANTOS, TOKEN_OSASCO

BRONZE (por fonte)
  nb_bronze_orquestracao
  └── para cada fonte:
        nb_bronze_acto_gestao (parametrizado)
          └── nb_utils_request_api → extrair_tabela_acto_gestao()
                ├── bronze.fato_solicitacoes_{fonte}
                ├── bronze.fato_campos_{fonte}        ← EAV
                └── bronze.fato_etapas_{fonte}

SILVER (unificado)
  nb_silver_acto_gestao
  └── UNION de todas as fontes
        ├── silver.fato_solicitacoes
        ├── silver.fato_campos
        └── silver.fato_etapas

GOLD (por domínio)
  _nb_gold_orquestracao
  ├── nb_gold_santos_cet         → gold_fato_solicitacoes_cet
  ├── nb_gold_santos_sepref      → gold_fato_solicitacoes_sepref
  ├── nb_gold_osasco_atendimento_cras       → gold_osasco_atendimento_cras
  └── nb_gold_osasco_atendimento_trabalhador → gold_osasco_atendimento_trabalhador
```

#### 8.8.8 Para Adicionar Nova Fonte

1. Criar `Files/payloads/payload_{municipio}_{dominio}.json` no Lakehouse
2. Adicionar entrada em `fontes` no `nb_bronze_orquestracao`
3. Adicionar `id_fonte` à lista `FONTES` no `nb_silver_acto_gestao`
4. Criar `nb_gold_{municipio}_{dominio}` com os `CAMPOS_DOMINIO` corretos
5. Adicionar chamada ao `_nb_gold_orquestracao`

---

## 9. POWER BI — CATÁLOGO COMPLETO

### 9.1 Inventário Geral

| Família | Painéis | Padronizado | Status |
|---|---|---|---|
| F1 — Acompanhamento de Serviços | 5 | Sim | ✅ Ativo |
| F2 — Manifestações de Ouvidoria | 5 | Sim | ✅ Ativo |
| F3 — Avaliação de Serviços | 1 | Parcial | ✅ Ativo |
| F4 — Carta de Serviços | 1 | Diferente | ✅ Ativo |
| F5 — Obras / PDR I | 5 | Não | ⚠️ Pipeline parado desde 11/03/2025 |
| F6 — Curso de Motorista | 2 | Diferente | ✅ Ativo |
| **Total** | **19** | | |

### 9.2 F1 — Acompanhamento de Serviços por Secretaria (5 painéis)

| Secretaria | Arquivo PBI | Tabela Gold | Status |
|---|---|---|---|
| SEGOV | `acompanhamento_servicos_segov` | `gold_segov_servicos` | ✅ |
| SEINFRA | `acompanhamento_servicos_seinfra` | `gold_seinfra_servicos` | ✅ |
| CET | `acompanhamento_servicos_cet` | `gold_cet_servicos` + `gold_cet_carga_descarga` | ✅ |
| SEPREF | `acompanhamento_servicos_sepref` | `gold_sepref_servicos` | ✅ |
| OUVIDORIA | `acompanhamento_servicos_ouvidoria` | `gold_ouvidoria_servicos` | ✅ |

**KPIs de OS em Aberto:** Total de Solicitações · Em Atendimento · Pendentes · % Prazo Vencido · % Dentro do Prazo · % Vence Hoje  
**KPIs de OS Finalizadas:** Total Finalizadas · Tempo Médio · % dentro do SLA  
**Tabela de acompanhamento:** status por unidade executora  
**Gráficos:** volume por período, distribuição por bairro, canal digital/presencial

### 9.3 F2 — Manifestações de Ouvidoria (5 painéis)

| Dashboard | Escopo | Tabela Gold | Status |
|---|---|---|---|
| `acompanhamento_servicos_manif_ouvidoria` | Geral | `gold_manifestacoes_ouvidoria` | ✅ |
| `acompanhamento_servicos_manif_ouvidoria_cet` | CET | `gold_manifestacoes_ouvidoria` | ✅ |
| `acompanhamento_servicos_manif_ouvidoria_segov` | SEGOV | `gold_manifestacoes_ouvidoria` | ✅ |
| `acompanhamento_servicos_manif_ouvidoria_seinfra` | SEINFRA | `gold_manifestacoes_ouvidoria` | ✅ |
| `acompanhamento_servicos_manif_ouvidoria_sepref` | SEPREF | `gold_manifestacoes_ouvidoria` | ✅ |

### 9.4 F3 — Avaliação de Serviços (1 painel)

| Dashboard | Tabelas | Detalhe | Status |
|---|---|---|---|
| `acompanhamento_avaliacao_servicos` | `gold_avaliacoes_servico` + `gold_avaliacoes_servicos_sentimento` | KPIs em estrelas (0–5★), sem SLA de prazo | ✅ |

> Template diferente dos demais — sem watermark. IA de sentimento via Cognitive Services.

### 9.5 F4 — Carta de Serviços (1 painel)

| Dashboard | Tabelas | Status |
|---|---|---|
| `acompanhamento_carta_servicos` | `gold_carta_servicos` | ✅ (Proprietário: Yuri) |

### 9.6 F5 — Obras / PDR I (5 painéis — ⚠️ Pipeline parado)

| Dashboard | Escopo | Tabelas Gold | Status |
|---|---|---|---|
| `pbi_obras_santos_acomp_solicitacoes` | Acompanhamento geral | `gold_pdr_acompanhamentos_os` | ⚠️ Dados obsoletos |
| `pbi_obras_santos_pdr` | PDR I | `gold_pdr_acompanhamentos_os` | ⚠️ Dados obsoletos |
| `pbi_obras_santos_seman_acomp_solicitacoes` | SEMAN | `gold_pdr_acompanhamentos_os` | ⚠️ Dados obsoletos |
| `pbi_santos_obras_seont_os` | SEONT | `gold_pdr_seont_os` | ⚠️ Dados obsoletos |
| `pbi_obras_santos_atividades` | Atividades | `gold_acto_gestao_obras_santos_atividades` | ⚠️ Dados obsoletos |

**Status:** `pl_ingest_obras_santos` ✅ operacional — token renovado via `nb_get_token_api` (R5 resolvido).

### 9.7 F6 — Curso de Motorista (2 painéis)

| Dashboard | Escopo | Tabela Gold | Status |
|---|---|---|---|
| `acompanhamento_servicos_curso_motorista` | Geral | `gold_curso_motorista` | ✅ |
| `acompanhamento_servicos_curso_motorista_cet` | CET | `gold_curso_motorista` | ✅ |

### 9.8 Padrão Visual InMov (F1/F2)

| Elemento | Especificação |
|---|---|
| Watermark | `"Desenvolvido por InMov - Copyright Prefeitura Municipal de Santos..."` |
| Fonte título | SegoeUI-Bold · 25pt · branco |
| KPI | 27pt |
| Rodapé | 7.5pt |

### 9.9 Mapa Domínio → Pipeline → Painel

| Domínio | Notebook Gold | Tabela Gold | Painel PBI | Pipeline |
|---|---|---|---|---|
| Avaliação | `nb_gold_santos_avaliacao` + `sentimento` | `gold_avaliacoes_servico` + `sentimento` | `acomp_avaliacao_servicos` | `pl_ingest_acto_gestao_santos_avaliacoes_servicos` |
| Obras | `nb_gold_acto_gestao_obras` + `etapas` + `seont_os` | `gold_pdr_*` + `gold_obras_tempo_etapa` | `pbi_obras_santos_*` (4+1) | `pl_ingest_obras_santos` ✅ |
| CET | `nb_gold_acto_gestao_cet` + `carga_descarga` | `gold_cet_servicos` + `gold_cet_carga_descarga` | `acomp_servicos_cet` | `pl_ingest_acto_gestao_santos_cet` |
| Curso Motorista | `nb_silver_santos_curso_motoristas` | `gold_curso_motorista` | `acomp_servicos_curso_motorista` (2) | `pl_ingest_acto_gestao_santos_cet` |
| Manifestações | `nb_gold_acto_gestao_manifestacoes_ouvidoria` | `gold_manifestacoes_ouvidoria` | `acomp_servicos_manif_ouvidoria_*` (5) | `pl_ingest_acto_gestao_santos_manifestacoes_ouvidoria` |
| Ouvidoria Serviços | `nb_gold_acto_gestao_ouvidoria_servicos` | `gold_ouvidoria_servicos` (unionAll 5) | `acomp_servicos_ouvidoria` | `pl_ingest_acto_gestao_santos_ouvidoria_servicos` |
| SEGOV | `nb_gold_acto_gestao_segov` | `gold_segov_servicos` (366 reg.) | `acomp_servicos_segov` | `pl_ingest_acto_gestao_santos_segov` |
| SEINFRA | `nb_gold_acto_gestao_seinfra` | `gold_seinfra_servicos` (1.161 reg.) | `acomp_servicos_seinfra` | `pl_ingest_acto_gestao_santos_seinfra` |
| SEPREF | `nb_gold_acto_gestao_sepref` | `gold_sepref_servicos` | `acomp_servicos_sepref` | `pl_ingest_acto_gestao_santos_sepref` |
| Carta de Serviços | `nb_ingest_carta_servicos_santos` | `gold_carta_servicos` | `acomp_carta_servicos` | `pl_ingest_carta_servicos_santos` |
| CAGED | `nb_ingest_caged_santos` | — | — | — ⚠️ R9 NUNCA executar |

### 9.10 Power BI — Catálogo Osasco (24 painéis)

> Referência completa com tópicos, dimensões e canvas: [[Documentação_Fabric/Osasco/MAPEAMENTO_PAINEIS_PBI_OSASCO]]  
> Gerado por extração PyMuPDF em 11/05/2026.

#### Inventário por Eixo

| # | Arquivo PDF | Eixo | Páginas | Tabela(s) Gold | Status Canvas |
|---|---|---|---|---|---|
| 1 | `bi_osasco_cad_unico.pdf` | Assistência Social | 1 | `gold_cad_unico_*` (12) | ⚠️ 1920×3915pt |
| 2 | `bi_osasco_rma_cras.pdf` | Assistência Social | 3 | `gold_rma_cras_*` (4) | ❌ P1=4× maior |
| 3 | `bi_osasco_rma_creas.pdf` | Assistência Social | 7 | `gold_rma_creas_indicadores` | ✅ Uniforme |
| 4 | `bi_osasco_atendimento_cras.pdf` | Assistência Social | 3 | `gold_atendimento_cras` | ⚠️ Alturas mistas |
| 5 | `bi_osasco_atendimento_trabalhador.pdf` | Assistência Social | 3 | `gold_osasco_atendimento_trabalhador` | ⚠️ Alturas mistas |
| 6 | `bi_osasco_programa_bolsa_familia.pdf` | Assistência Social | 1 | `gold_pbf_municipios_selecionados` | ⚠️ 1920×3015pt |
| 7 | `bi_osasco_programa_bolsa_trabalho.pdf` | Assistência Social | 2 | `gold_bolsa_trabalho` | ⚠️ Alturas mistas |
| 8 | `bi_osasco_mapas_vulnerabilidade.pdf` | Assistência Social | 5 | `gold_cad_unico_*` + `gold_pbf_*` | ✅ Uniforme |
| 9 | `bi_osasco_pib.pdf` | Des. Econômico | 1 | `gold_osasco_pib_*` (3) | ⚠️ Largura ≠ |
| 10 | `bi_osasco_caged.pdf` | Des. Econômico | 1 | `gold_caged_*` (5) | ⚠️ 960×2603pt |
| 11 | `bi_osasco_empresas.pdf` | Des. Econômico | 1 | CSV `Files/gold_rais/` | ⚠️ 1920×2415pt |
| 12 | `bi_osasco_ri_comercio_exterior.pdf` | Rel. Internacionais | 1 | `gold_osasco_comexstat` | ⚠️ 1920×3990pt |
| 13 | `bi_osasco_demografia_populacao.pdf` | Censo / Demo | 1 | `gold_osasco_populacao_ibge` | ⚠️ 960×1890pt |
| 14 | `bi_osasco_demografia_envelhecimento.pdf` | Censo / Demo | 1 | `gold_osasco_populacao_ibge` | ✅ 960×570pt |
| 15 | `bi_osasco_demografia_fecundidade.pdf` | Censo / Demo | 1 | CSV `gold_censo_demografico/` | ✅ 960×561pt |
| 16 | `bi_osasco_seguranca_publica.pdf` | Segurança | 1 | `gold_seg_publica_*` (4) | ❌ 1920×6015pt |
| 17 | `bi_osasco_seguranca_viaria.pdf` | Segurança | 1 | `gold_seguranca_viaria` (4) | ⚠️ 1920×3015pt |
| 18 | `bi_osasco_inscricoes_monitora_oz.pdf` | Segurança | 3 | `gold_monitora_oz` | ⚠️ Largura mista |
| 19 | `acompanhamento_alvara_obras_osasco.pdf` | Des. Urbano | 3 | `gold_alvaras_obras` | ❌ 3 alturas ≠ |
| 20 | `bi_osasco_mapas_loteamento_zoneamento.pdf` | Des. Urbano | 2 | — (mapa estático) | ✅ Uniforme |
| 21 | `bi_osasco_cadoz_h1n1.pdf` | Saúde | 2 | CadOZ local | ❌ Alturas ≠ |
| 22 | `atividades_aquaticas.pdf` | Esporte e Lazer | 1 | — (pendente mapeamento) | ⚠️ 960×1665pt |
| 23 | `carta_servicos_osasco.pdf` | Gov. e Cidadania | 3 | `gold_carta_servicos` (3) | ⚠️ Alturas mistas |
| 24 | `rma_cras.pdf` | Assistência Social | 6 | `gold_rma_cras_*` | ⚠️ Predecessor (#2) |

#### 9.10.1 Linhagem Completa — Osasco

| Painel | Camada Bronze | Camada Silver | Tabela Gold | Migração Escalável |
|---|---|---|---|---|
| CadÚnico (#1, #8) | `bronze_cad_unico_*` | `silver_cad_unico_*` | `gold_cad_unico_*` (12) | — |
| RMA/CRAS (#2, #24) | API Acto | — | `gold_rma_cras_*` (4) | — |
| RMA/CREAS (#3) | API Acto | — | `gold_rma_creas_indicadores` | — |
| Atend. CRAS (#4) | `bronze.fato_sol_cras` | `silver.fato_sol` | `gold_atendimento_cras` | — |
| Atend. Trabalhador (#5) | `bronze.fato_sol_trab` | `silver.fato_sol` | `gold_osasco_atendimento_trabalhador` | — |
| Bolsa Família (#6) | `dump_pbf_sp` | `silver_pbf_sp` | `gold_pbf_municipios_selecionados` | Vulnerabilidade Regional |
| Bolsa Trabalho (#7) | API Acto | `silver_bolsa_trabalho` | `gold_bolsa_trabalho` | — |
| PIB (#9) | SIDRA API | — | `gold_osasco_pib_*` | ✅ `lh_dados_publicos.gold.pib` |
| CAGED (#10) | `dump_caged` | `silver_caged` | `gold_caged_*` (5) | 🔄 `gold.mercado_trabalho` |
| Empresas (#11) | `raw_rais_estab_sp` | — | **CSV** `Files/gold_rais/` | 🟠 Delta pendente |
| Comex (#12) | COMEXSTAT | — | `gold_osasco_comexstat` | — (local) |
| Demo/Pop (#13, #14) | SIDRA API | — | `gold_osasco_populacao_ibge` | ✅ `gold.populacao` |
| Fecundidade (#15) | SIDRA Censo | — | **CSV** `gold_censo_demografico/` | ✅ `gold.censo_fecundidade` |
| Seg. Pública (#16) | Monitora OZ | — | `gold_seg_publica_*` (4) | — |
| Seg. Viária (#17) | InfoSiga | `silver_infosiga_*` | Delta (4) + Parquet redundante | 🟡 Remover Parquet |
| Monitora OZ (#18) | API Acto | — | `gold_monitora_oz` | — |
| Alvarás/Obras (#19) | Grid Acto | — | `gold_alvaras_obras` | — |
| Carta Serviços (#23) | API Acto | — | `gold_carta_servicos` (3) | — |

#### 9.10.2 Auditoria de Canvas — Problemas Prioritários

| Prioridade | Painel | Problema | Ação |
|---|---|---|---|
| 🔴 Alta | `bi_osasco_rma_cras.pdf` | P1 = 1920×2715pt (4× maior que P2-P3) — cliente reportou | P1: Formato → Tamanho → 960×728pt |
| 🔴 Alta | `acompanhamento_alvara_obras_osasco.pdf` | 3 alturas distintas: 1890/1349/1595pt | Padronizar todas as páginas |
| 🔴 Alta | `bi_osasco_seguranca_publica.pdf` | Canvas 6015pt de altura (1 só página) | Quebrar em abas ou reduzir |
| 🟠 Média | `bi_osasco_cadoz_h1n1.pdf` | P1=2415pt / P2=1095pt | Padronizar altura |
| 🟠 Média | `bi_osasco_inscricoes_monitora_oz.pdf` | Largura muda: P1=1920 / P2-3=960 | Padronizar largura |

---

## 10. RISCOS TÉCNICOS E MITIGAÇÕES (R1–R9)

### Matriz Geral de Riscos

| ID | Risco | Severidade | Domínio | Status | Responsável |
|---|---|---|---|---|---|
| **R5** | ~~401 Unauthorized em obras~~ | ~~🔴 CRÍTICO~~ | Obras | ✅ **Resolvido** | — |
| **R9** | IBGE hardcode errado CAGED | 🔴 CRÍTICO | CAGED Santos | ❌ Ativo | Victor ou Yuri |
| **R1** | Dual-path Carta de Serviços | ~~🔴 CRÍTICO~~ 🟢 Esclarecido | Carta de Serviços | ✅ **Fonte única definida** | — |
| **R2** | tb_aux.xlsx Single Point of Failure | 🟠 Médio | Geral | ⚠️ Ativo | — |
| **R3** | Funções duplicadas em múltiplos NB | 🟠 Médio | Geral | ⚠️ Ativo | — |
| **R4** | Overwrite vs. Append inconsistente | 🟠 Médio | Avaliacao Gold + CET | ⚠️ Ativo | — |
| **R6** | Tokens com curto prazo de expiração | 🟠 Médio | Geral | ⚠️ Ativo | — |
| **R7** | `raise_for_status()` sem try/except | 🟢 Baixo | Utils Extração | ⚠️ Parcial | — |
| **R8** | 13 test users hardcoded | 🟢 Baixo | Geral | ⚠️ Ativo | — |

---

### 10.1 R5 — Obras — 401 Unauthorized ✅ RESOLVIDO

> [!success] Risco encerrado
> O modelo antigo de token manual (`TOKEN_SANTOS_OBRAS` hardcoded) foi substituído pela nova arquitetura de `nb_get_token_api`, que renova tokens automaticamente via login programático. O pipeline de obras está operacional.

**Situação anterior:** Pipeline `pl_ingest_obras_santos` falhava com erro 401 desde 11/03/2025 devido a token expirado.

**Resolução:** Migração para `nb_get_token_api` com tenant `santos_obras`:
```python
%run ./nb_get_token_api
TOKEN_SANTOS_OBRAS = get_acto_token("santos_obras", ACTO_USER, ACTO_SENHA)
# Token renovado automaticamente com cache em memória — sem expiração manual
```

**Status atual:** `pl_ingest_obras_santos` ✅ Ativo · Dashboards F5 atualizados

---

### 10.2 R9 — CAGED — IBGE Hardcode Errado

**Problema:** Notebook `nb_ingest_caged_santos` refere IBGE code **353440** (Osasco) em vez de **353845** (Santos). Notebook **nunca foi executado** em produção.

**Impacto:**
- Se executado sem correção, será ingerido dados de Osasco, não Santos
- Análise de emprego/desemprego incorreta para Santos

**Correção:**
```python
# ERRADO (atual):
CODIGO_MUNICIPIO = 353440  # Osasco

# CORRETO:
CODIGO_MUNICIPIO = 353845  # Santos
```

**Responsável:** Victor ou Yuri  
**Target Prazo:** 3–5 dias

---

### 10.3 R1 — Carta de Serviços — Fonte Única Definida ✅ ESCLARECIDO

> [!success] Risco esclarecido
> A situação foi definida: Francisco/CSV é a fonte única em produção. Victor/API é um projeto separado de melhoria com objetivo de auditoria — não há conflito.

**Situação atual — dois papéis distintos:**

| Notebook | Proprietário | Papel | Status |
|---|---|---|---|
| `nb_ingest_carta_servicos_santos` | Francisco | **PRODUÇÃO** — fonte única, CSV semanal | ✅ Em execução |
| `01_ingestao_cartas_servico` + `02_ingestao_solicitacoes` | Victor | **PROJETO FUTURO** — ingestão via API Acto para auditoria e rastreabilidade | 🔲 Em desenvolvimento |

**Objetivo do projeto Victor/API:** Complementar o processo do Francisco com dados da API Acto Gestão para permitir reconciliação e auditoria — não substituir. Quando concluído, ambos coexistirão com papéis distintos.

**Decisão de arquitetura:** Não arquivar os notebooks de Victor — são desenvolvimento ativo de nova funcionalidade.

**Responsável:** Victor + Francisco + Yuri  
**Target Prazo:** 2–3 semanas

---

### 10.4 R2 — Arquivos Auxiliares (Single Points of Failure)

**Problema:** Arquivos Excel/CSV referenciados por múltiplos notebooks. Uma mudança de path quebra silenciosamente os pipelines.

| Arquivo | Usado em |
|---|---|
| `Files/acto/tb_aux.xlsx` | `nb_ingest_acto_santos`, `nb_utils_api_acto_gestao` |
| `PMS_AuxiliarPDR.xlsx` | `nb_gold_acto_gestao_obras` |
| `raw_cadastro_carta/*.csv` | `nb_ingest_carta_servicos_santos` |

**Mitigação:** Migrar todos para Delta Tables no Lakehouse.

---

### 10.5 R3 — Duplicação de Funções Utilitárias

**Problema:** `ajustar_nome_colunas()`, `harmonizar_nome_bairros()`, `mapa_bairros` aparecem em múltiplos notebooks.

**Fix:** Criar `nb_utils_shared` e migrar todas as ocorrências para `%run ./nb_utils_shared`.

---

### 10.6 R4 — Overwrite vs. Append Inconsistente

**Problema:**
- `nb_gold_santos_avaliacao` usa `overwrite`
- `nb_gold_santos_avaliacao_sentimento` usa `append`

Se Gold base é reescrito e sentimento falha, IDs ficam silenciosamente desalinhados.

**Mitigação:** Definir padrão — recomendação: append + SCD Type 2 para histórico em Gold avaliação.

---

### 10.7 R6 — Tokens Curto Prazo de Expiração

**Problema:** Tokens Acto que expiram em dias (não semanas). Pipelines falham silenciosamente após expiração.

**Mitigação:** Implementar token refresh automático ou usar MSI (Managed Identity) se possível.

---

### 10.8 R7 — `raise_for_status()` Sem try/except

**Problema:** `nb_utils_ingest_acto_gestao` chama `raise_for_status()` diretamente sem `try/except`. Falhas de API propagam silenciosamente para as cadeias de avaliacao_servicos e curso_motoristas.

**Fix:** Adicionar tratamento de exceção em todas as chamadas de API.

---

### 10.9 R8 — 13 Test Users Hardcoded

**Problema:** 13 usuários de teste hardcoded em função `remover_registros_teste`. Qualquer usuário teste novo não é filtrado automaticamente.

**Mitigação:** Migrar lista para tabela de configuração Delta.

---

## 11. ROADMAP E PLANO DE AÇÃO

### 11.1 Novo Escopo — SLA / Carta de Serviços

#### Contexto

O maior risco de confiabilidade atual é a **ausência de versionamento dos prazos**. Quando uma carta de serviço tem seu prazo alterado, solicitações históricas são recalculadas com o novo prazo, corrompendo retrospectivamente os indicadores.

**Solução:** SCD Type 2 na dimensão de cartas de serviço.

#### Análise da Fonte de Dados (CSV exportar_4)

| # | Coluna | Tipo | Observação |
|---|---|---|---|
| 0 | `DATA DE ATUALIZAÇÃO` | Datetime | Formato `DD/MM/AAAA HH:MM` |
| 1 | `Nome:` | String | Nome do serviço — chave de join fuzzy |
| 2 | `Categoria:` | String | 14 categorias mapeadas |
| 3 | `Público alvo` | String | Descritivo livre — não usado em SLA |
| 4 | `Dados e documentos requeridos:` | String (multiline) | ⚠️ Causa quebra de CSV |
| 5 | `Formas de consulta ao andamento:` | String (multiline) | ⚠️ Causa quebra de CSV |
| 6 | `Secretaria Responsável` | String | 32 secretarias únicas |
| 7 | `Data-Hora da inserção/atualização` | Date | Formato `DD/MM/AAAA` |
| 8 | `ID do serviço:` | String/Int | ⚠️ 3 registros com ID nulo (0,4%) |
| 9 | `Área executora:` | String | Hierarquia: Secretaria — Seção |
| 10 | `Prazo para conclusão:` | Integer | ⚠️ 39 registros sem prazo (5,6%) |
| 11 | `Medida do prazo:` | Enum | Dias (68%), Dias úteis (30%), Nulo (2,2%) |
| 12 | `Canal do serviço online:` | URL / String | Link Acto Digital |

**Totais:** 693 registros · 13 colunas · Delimitador: `;` · Encoding: UTF-8 BOM

**Diagnóstico de qualidade:**

| Problema | Severidade | Quantidade | Tratamento |
|---|---|---|---|
| Campos multiline | 🔴 Alta | Todos | `csv.reader` com `quotechar='"'` + CRLF handling |
| IDs nulos | 🟡 Média | 3 (0,4%) | Isolar em tabela de rejeição |
| Prazos nulos | 🟡 Média | 39 (5,6%) | Marcar como `sem_sla_definido` |
| Dias vs. Dias úteis | 🔴 Alta | 207 reg. dias úteis | Flag `is_dias_uteis BOOLEAN`; cálculo bifurcado |
| Sem versionamento | 🔴 Crítica | 100% | **SCD Type 2** — core do projeto |

#### Schema — `gold_dim_cartas_servico_vigencia`

| Coluna | Tipo | Papel | Descrição |
|---|---|---|---|
| `sk_carta` | INTEGER | PK | Chave surrogate — identificador de versão |
| `id_servico` | STRING | NK | Chave natural — ID do serviço no Acto |
| `nm_servico` | STRING | | Nome do serviço normalizado |
| `ds_secretaria` | STRING | | Secretaria responsável |
| `nr_prazo` | INTEGER | | Quantidade de dias do prazo |
| `is_dias_uteis` | BOOLEAN | | `True` = dias úteis; `False` = dias corridos |
| `dt_inicio_vigencia` | DATE | **SCD2** | Data em que esta versão passou a valer |
| `dt_fim_vigencia` | DATE | **SCD2** | `9999-12-31` se registro ativo |
| `is_atual` | BOOLEAN | **SCD2** | `True` = versão vigente |
| `dt_carga` | TIMESTAMP | Auditoria | Timestamp da ingestão |

#### Roadmap de Execução — Novo Escopo SLA

| Fase | Título | Notebooks / Entregas | Status |
|---|---|---|---|
| F1 | Consolidação Bronze | `nb_ingest_acto_santos`<br>`nb_ingest_santos_curso_motoristas` | ✅ Concluído |
| F2 | Consolidação Silver/Gold Existente | `nb_silver_santos_avaliacao`<br>`nb_gold_santos_avaliacao`<br>`nb_gold_santos_avaliacao_sentimento`<br>`nb_silver_santos_curso_motoristas` | ✅ Concluído |
| F3 | Ingestão Cartas de Serviço | `nb_ingest_cartas_servico` → `bronze_cartas_servico` | 🔲 A fazer |
| F4 | Silver — Limpeza e SCD2 | `nb_silver_cartas_servico` → `silver_cartas_servico` (SCD2)<br>`nb_silver_solicitacoes_sla` → `silver_solicitacoes` | 🔲 A fazer |
| F5 | Gold — Dimensão e Fato | `nb_gold_dim_cartas_vigencia` → `gold_dim_cartas_servico_vigencia`<br>`nb_gold_fato_solicitacoes` → `gold_fato_solicitacoes` | 🔲 A fazer |
| F6 | Gold — Indicadores SLA + Power BI | `nb_gold_sla_indicadores` → `gold_sla_indicadores`<br>Configuração Power BI (DAX: `%SLA`, `dias_atraso`, `status`) | 🔲 A fazer |

#### Dependências de Execução — Novo Escopo

```
nb_ingest_cartas_servico
    → nb_silver_cartas_servico
        → nb_gold_dim_cartas_vigencia ──────────────┐
                                                    ↓
nb_ingest_acto_santos                    nb_gold_sla_indicadores
    → nb_silver_solicitacoes_sla                    ↑
        → nb_gold_fato_solicitacoes ────────────────┘
```

### 11.2 Checklist de Ações — Crítico (Sprint Imediato)

| # | Ação | Esforço | Responsável | Prazo |
|---|---|---|---|---|
| ~~1~~ | ~~Renovar TOKEN_SANTOS_OBRAS (R5)~~ | ~~🟢 Baixo~~ | ~~Yuri~~ | ✅ **Resolvido** — [[Documentação_Fabric/Acto/nb_get_token_api.ipynb|nb_get_token_api]] |
| 2 | Corrigir IBGE hardcode CAGED: `353440` → `353845` (R9) | 🟢 Baixo | Victor ou Yuri | 3–5 dias |
| 3 | Renomear `gold_curso_motorista` → `nb_gold_santos_curso_motorista` | 🟢 Baixo | — | Imediato |
| 4 | Definir fonte canônica Carta de Serviços (R1): usar `exportar_4.csv` | 🟢 Baixo | Victor+Francisco | 1 semana |
| 5 | Criar `nb_ingest_cartas_servico`: ler CSV com quotechar, tratar multiline | 🟡 Médio | Victor | 1–2 semanas |
| 6 | Criar `nb_silver_cartas_servico`: limpeza, tipagem, rejeição de IDs nulos | 🔴 Alto | Victor | 2 semanas |
| 7 | Implementar SCD Type 2 em `nb_silver_cartas_servico` | 🔴 Alto | Victor | 2 semanas |
| 8 | Criar `nb_silver_solicitacoes_sla`: ingestão e padronização | 🔴 Alto | Victor | 2 semanas |
| 9 | Criar `nb_gold_dim_cartas_vigencia`: dimensão versionada | 🔴 Alto | Victor | 3 semanas |
| 10 | Criar `nb_gold_fato_solicitacoes`: join com vigência (dt_abertura entre dt_inicio e dt_fim) | 🔴 Alto | Victor | 3 semanas |
| 11 | Criar `nb_gold_sla_indicadores`: `%_no_prazo`, `dias_atraso_medio`, status por secretaria | 🟡 Médio | Victor | 4 semanas |
| 12 | Configurar pipeline Data Factory para nova cadeia SLA | 🟡 Médio | Yuri | 4 semanas |
| 13 | Construir relatório Power BI consumindo `gold_sla_indicadores` | 🟡 Médio | Victor | 5 semanas |

### 11.3 Backlog — Próximo Mês (Riscos Médios)

| Ação | Risco | Descrição |
|---|---|---|
| Migrar `tb_aux.xlsx` → Delta table | R2 | Consolidar em `tb_aux_master`, remover dependência Excel |
| Refatorar funções duplicadas → `nb_utils_shared` | R3 | Criar shared library |
| Padronizar Overwrite vs. Append — adotar SCD Type 2 | R4 | Append + versionamento para Gold avaliação |
| Implementar token refresh automático | R6 | MSI ou lógica de refresh em utils |
| Inventariar modelos semânticos | — | Mapeamento de `nbs/modelos_semanticos/` |
| Migrar CSV→Delta no Osasco | — | BPC, Censo (10 tabelas), RAIS (2 tabelas) |
| Migrar Parquet→Delta no Mauá | — | 28 Parquets do Planejamento Urbano |

### 11.4 Backlog — Q2/Q3 2026

- Completar mapeamento `nb_utils_ingest_acto_gestao`
- Auditoria de test users hardcoded (R8)
- Consolidar payload em `adicionar_etapa_atual` (2 variantes coexistem)
- Documentação SLAs Power BI (template InMov v4 para todos os 19 dashboards)
- Estruturação `nbs_analise` (análise exploratória)
- Implementar monitoramento automatizado de falhas de auth

---

## 12. PADRÕES E CONVENÇÕES

### 12.1 Nomenclatura de Notebooks

**Padrão:** `nb_{camada}_{municipio}_{dominio}`

| Aspecto | Valor | Exemplos |
|---|---|---|
| Prefixo | `nb_` | Obrigatório |
| Camada | `ingest` / `bronze` / `silver` / `gold` / `utils` | `nb_gold_santos_avaliacao` |
| Município | `_santos_` / `_osasco_` / `_maua_` | `nb_silver_santos_avaliacao` |
| Domínio | `_avaliacao` / `_obras` / `_cet` / etc. | `nb_gold_santos_avaliacao_sentimento` |

**Violação conhecida:** `gold_curso_motorista` — falta `nb_` e município. Renomear para `nb_gold_santos_curso_motorista`.

### 12.2 Pipeline Padrão

```
Notebook Gold → RefreshSqlEndpoint → Refresh modelo PBI
```

**Exceção:** `pl_ingest_obras_santos` — 9 atividades: Silver → Gold obras + Gold etapas (paralelo) → RefreshSqlEndpoint → 4× PBI refresh em paralelo.

### 12.3 SCD Type 2 — Vigência de Prazos

```sql
-- Join CORRETO (preserva histórico):
SELECT s.*, d.nr_prazo, d.is_dias_uteis
FROM silver_solicitacoes s
LEFT JOIN gold_dim_cartas_servico_vigencia d
    ON  s.id_servico       = d.id_servico
    AND s.dt_abertura     >= d.dt_inicio_vigencia
    AND s.dt_abertura      < d.dt_fim_vigencia

-- Join INCORRETO (corrompe histórico):
-- ON d.is_atual = True  ← aplica prazo atual a dados históricos
```

**Nunca** fazer join apenas por `is_atual = True`.

### 12.4 Modo de Escrita — Regras

| Situação | Modo recomendado |
|---|---|
| Recarga completa diária (Gold de secretaria simples) | `overwrite` com `overwriteSchema=true` |
| Append incremental com análise histórica | `append` |
| Dimensão com histórico de versões | SCD Type 2 (colunas `dt_inicio_vigencia`, `dt_fim_vigencia`, `is_atual`) |

### 12.5 Validação de Rowcount (Padrão)

```python
# Antes de qualquer escrita em Delta:
before_count = spark.sql("SELECT COUNT(*) FROM {tabela_gold}").collect()[0][0]

# ... lógica de transformação ...

df.write.mode("overwrite").saveAsTable("{tabela_gold}")
after_count = spark.sql("SELECT COUNT(*) FROM {tabela_gold}").collect()[0][0]
assert after_count > 0, "Escrita resultou em tabela vazia"
assert after_count >= before_count * 0.90, f"Queda de rowcount suspeita: {before_count} → {after_count}"
```

Referência de implementação correta: `nb_silver_santos_curso_motoristas` com `assert len(df) > threshold`.

### 12.6 Padrão de Ingestão via API

```python
%run ./nb_utils_api_acto_gestao
%run ./nb_utils_ingest_acto_gestao

TOKEN = TOKEN_SANTOS  # ou TOKEN_OSASCO, TOKEN_MAUA
df = fetch_tabela(token=TOKEN, codCatalogo=123, codigos_etapa=[1,2,3], dataInicio="01/01/2024", dataFim="31/12/2024")
df = adicionar_etapa_atual(df)  # ou adicionar_etapa_atual_2() conforme endpoint
```

### 12.7 CSV Canônico — Carta de Serviços

- **Arquivo:** `exportar_4.csv` (693 registros, delimitador `;`, UTF-8 BOM)
- **Descartar:** `cadastro_carta_de_servico.csv` — conteúdo idêntico, fonte duplicada
- **Leitura:** `csv.reader` com `quotechar='"'` + CRLF handling para campos multiline

---

## 13. CONTATOS E RESPONSABILIDADES

| Pessoa | Papel | Responsabilidades |
|---|---|---|
| **Yuri Lucatelli Taba** | Arquiteto Principal | Arquitetura, base ingestion, pipelines gerais, PBI `acompanhamento_carta_servicos` |
| **Victor Martins da Silva** | Tech Lead — Obras + IA | Domínio Obras completo, notebooks sentimento, SLA/Carta de Serviços (novo escopo), suporte técnico |
| **Francisco Jorge Leandro** | Especialista Carta de Serviços | Pipeline CSV carta_servicos (em produção), `nb_ingest_carta_servicos_santos` |

### Responsabilidades por Domínio — Santos

| Domínio | Proprietário |
|---|---|
| Avaliação de Serviços (Silver + Gold) | Yuri |
| Avaliação Sentimento (Gold+IA) | Victor |
| Obras (pipeline completo) | Yuri |
| Obras SEONT + Atividades | Victor |
| CET + Curso de Motoristas | Yuri |
| Manifestações Ouvidoria | Yuri |
| SEGOV / SEINFRA / SEPREF | Yuri |
| Carta de Serviços (CSV pipeline) | Francisco |
| SLA / Carta (novo escopo, SCD2) | Victor |
| CAGED Santos (pendente) | Victor ou Yuri |

---

## HISTÓRICO DE VERSÕES DO DOCUMENTO

| Versão | Data | Escopo |
|---|---|---|
| 1.0 | Mar/2026 | avaliacao_servicos — Silver / Gold / Sentimento |
| 1.2 | Mar/2026 | Notebooks raiz nbs/ (5 notebooks) |
| 1.3 | Abr/2026 | pl_ingest_obras_santos + observações arquiteturais |
| 1.4 | Abr/2026 | NB3/NB4 obras, nb_utils_api obras, novos riscos |
| 1.5 | Abr/2026 | [[Documentação_Fabric/Santos/nbs/nb_utils_api_acto_gestao.ipynb|nb_utils_api_acto_gestao]] COMPLETO |
| 1.6 | Abr/2026 | [[Documentação_Fabric/Santos/nbs/avaliacao_servicos/nb_silver_santos_avaliacao.ipynb|nb_silver_santos_avaliacao]], 3 pipelines, 2 novos riscos |
| 1.7 | Abr/2026 | [[Documentação_Fabric/utils/nb_utils_ingest_acto_gestao.ipynb|nb_utils_ingest_acto_gestao]] + Protótipo Curso de Motoristas |
| 1.8 | Abr/2026 | Sessão 4: CET, obras, ouvidoria, segov, seinfra, sepref, caged, carta, PBI. R9 novo. |
| 2.0 | 15/Abr/2026 | Referência Técnica Consolidada Santos v2.0 |
| **3.0 MEGA** | **01/Mai/2026** | **Documento Universal — todos os municípios, negócio, técnico, riscos, roadmap, PBI, padrões** |

---

**Documento Universal — Acto Cidade Inteligente · Microsoft Fabric**  
**Versão 3.0 MEGA · 01 de Maio de 2026**  
**Status: ✅ REFERÊNCIA COMPLETA DO PROJETO**


sequenceDiagram
    participant Master as 🧠 Pipeline Mestre
    participant Check as 🔍 Notebook Checar Fontes
    participant Sub_SSP as 🛡️ Sub-Pipeline SSP
    participant Sub_CAGED as 💼 Sub-Pipeline CAGED
    participant DB as 🗄️ Lakehouse (Gold)

    Master->>Check: Iniciar (Trigger 08h)
    Check-->>Master: Retorna JSON {SSP: true, CAGED: false}
    
    par Paralelo
        Master->>Sub_SSP: Invoke (Params: NOVO_DADO=true)
        Sub_SSP->>Sub_SSP: Executa Logica Interna (If True)
        Sub_SSP->>DB: Grava gold.seguranca_publica
    and
        Master->>Sub_CAGED: Invoke (Params: NOVO_DADO=false)
        Sub_CAGED->>Sub_CAGED: Ignora Execução (If False)
    end

    Master->>Master: nb_atualizar_status_painel
