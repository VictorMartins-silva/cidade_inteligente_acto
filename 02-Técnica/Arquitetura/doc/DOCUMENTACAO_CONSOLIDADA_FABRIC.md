---
aliases: ["doc consolidada", "fabric doc", "documentacao fabric"]
description: "Documentação técnica consolidada do ambiente Microsoft Fabric"
status: "referencia"
---
# Documentação Consolidada — Microsoft Fabric · Acto Cidade Inteligente

**Versão:** 3.0 — Consolidado Mestre  
**Data:** Maio de 2026  
**Escopo:** Municípios de Santos, Mauá, Osasco, Aparecida de Goiânia (impl.) e SJRP (impl.)  
**Workspace ID:** `96fe5a53-3a22-4443-8d0a-e2f6d61a2690`  
**Capacidade:** Diamante · Região: Brazil South

---

## Índice

1. [Visão de Negócio](#1-visão-de-negócio)
2. [Arquitetura Técnica](#2-arquitetura-técnica)
3. [Estrutura do Workspace](#3-estrutura-do-workspace)
4. [Municípios e Domínios de Dados](#4-municípios-e-domínios-de-dados)
5. [Inventário Completo de Notebooks — Santos](#5-inventário-completo-de-notebooks--santos)
6. [Detalhamento Técnico por Notebook](#6-detalhamento-técnico-por-notebook)
7. [Notebooks Utilitários](#7-notebooks-utilitários)
8. [Grafo de Dependências e Lineage](#8-grafo-de-dependências-e-lineage)
9. [Catálogo de Tabelas Delta](#9-catálogo-de-tabelas-delta)
10. [Pipelines de Orquestração](#10-pipelines-de-orquestração)
11. [Auditoria de Riscos](#11-auditoria-de-riscos)
12. [Padrões e Boas Práticas](#12-padrões-e-boas-práticas)
13. [SCD Type 2 — Carta de Serviços / SLA](#13-scd-type-2--carta-de-serviços--sla)
14. [Notebooks de Outros Municípios](#14-notebooks-de-outros-municípios)
15. [Roadmap e Plano de Ação](#15-roadmap-e-plano-de-ação)
16. [Pendências de Mapeamento](#16-pendências-de-mapeamento)

---

## 1. Visão de Negócio

### 1.1. Objetivo do Projeto

O projeto **Acto Cidade Inteligente** no Microsoft Fabric visa consolidar dados municipais de diversas secretarias e serviços públicos em uma plataforma unificada de dados e análise. O objetivo é fornecer *insights* confiáveis e atualizados para a gestão municipal de Santos, com visões operacionais e estratégicas acessíveis via Power BI.

### 1.2. Domínios de Negócio Atendidos (Santos)

| Domínio | Descrição | Status |
|---|---|---|
| **Avaliação de Serviços** | Feedbacks e notas dos cidadãos sobre serviços municipais, com análise de sentimento via IA | Operacional |
| **Obras Públicas** | Monitoramento de obras, etapas, prazos e ordens de serviço da PDR e SEONT | Operacional |
| **CET — Tráfego** | Gestão de serviços de engenharia de tráfego e carga/descarga | Operacional |
| **Curso de Motoristas** | Controle de presença e aproveitamento em cursos da CET | Operacional |
| **Secretarias (SEGOV, SEINFRA, SEPREF)** | Serviços e solicitações das secretarias municipais | Operacional |
| **Ouvidoria** | Manifestações, reclamações e sugestões dos cidadãos | Operacional |
| **Carta de Serviços / SLA** | Catálogo de serviços públicos com prazos e controle de conformidade (SCD Type 2) | Em implantação |
| **CAGED** | Dados de emprego e desemprego (IBGE/MTE) | Em construção |

### 1.3. Fluxo de Valor de Negócio

```
Cidadão → Acto Gestão (sistema operacional)
              ↓
       API / CSV / FTP
              ↓
     Microsoft Fabric (ETL)
              ↓
          Power BI
              ↓
   Gestores e Secretários municipais
```

### 1.4. Relatórios Power BI Ativos

| Relatório                           | Domínio           | Dependência                                                       |
| ----------------------------------- | ----------------- | ----------------------------------------------------------------- |
| `acompanhamento_avaliacao_servicos` | Avaliação         | `gold_avaliacoes_servico` + `gold_avaliacoes_servicos_sentimento` |
| `acompanhamento_carta_servicos`     | Carta de Serviços | `gold_carta_servicos`                                             |
| `gestao_paineis_obras` (×4)         | Obras             | `gold_pdr_acompanhamentos_os`, `gold_obras_tempo_etapa`, etc.     |
| Ouvidoria (múltiplos)               | Ouvidoria         | `gold_ouvidoria_servicos`                                         |
| CET                                 | CET               | `gold_cet_servicos`, `gold_cet_carga_descarga`                    |

---

## 2. Arquitetura Técnica

### 2.1. Padrão Medallion

A arquitetura adota o padrão **Medallion** em quatro camadas lógicas:

```
Fonte (Acto API / CSV / FTP)
        ↓ Data Factory
    BRONZE
    (Delta Tables — payload bruto, sem transformação)
        ↓ PySpark / Python
    SILVER
    (Limpeza, tipagem, normalização, SCD Type 2)
        ↓ PySpark / SQL
    GOLD
    (Dimensões, fatos, indicadores — consumo Power BI)
        ↓ (enriquecimento opcional)
    GOLD+IA
    (Análise de sentimento via LLM — Groq/Llama)
        ↓
    Power BI (DAX mínimo — lógica de negócio fica no Gold)
```

### 2.2. Modelo Acto Unificado (Novo)

Além do modelo Medallion legado por município, foi implementado o **Lakehouse Unificado `lh_solicitacoes_acto`**, que utiliza o padrão **Entity-Attribute-Value (EAV)** para suportar formulários dinâmicos de múltiplos municípios em um único schema flexível.

| Camada | Tabela | Descrição |
|---|---|---|
| Bronze | `fato_solicitacoes_*` | Payload bruto por fonte |
| Silver | `silver.fato_solicitacoes` | Consolidação unificada |
| Gold | `gold.fato_solicitacoes_*` | Tabelas pivotadas por domínio |

| Camada | Responsabilidade | Tecnologia | Tipo de Saída |
|---|---|---|---|
| Bronze | Captura bruta sem transformação | Data Factory, PySpark | Delta Table / Parquet / JSON |
| Silver | Tipagem, limpeza, normalização | PySpark / Python | Delta Table / Parquet |
| Gold | Regras de negócio, joins, indicadores | PySpark / SQL | Delta Table (overwrite) |
| Gold+IA | Enriquecimento com modelos de linguagem | Python + Groq API | Delta Table (append) |

### 2.2. Tratamentos por Camada

**Camada Silver — transformações padrão:**
- Remoção de sufixos de ID em nomes de colunas (ex: `Coluna|123` → `Coluna`)
- Conversão de strings ISO8601 para `datetime`
- Consolidação de colunas duplicadas via `bfill` horizontal
- Conversão para `snake_case` com `unicodedata`

**Camada Gold — tratamentos específicos:**
- Cálculo de prazos e SLAs
- Cruzamento com tabelas auxiliares de bairros e secretarias
- Filtragem de registros de teste
- Renomeação para nomes amigáveis ao negócio
- Alinhamento de schema via `reindex` para `unionAll`

### 2.3. Fontes de Dados

| Fonte | Tipo | Autenticação | Notebooks que consomem |
|---|---|---|---|
| API Acto Gestão (padrão) | REST/HTTP | Token `TOKEN_SANTOS` | Maioria dos notebooks |
| API Acto Gestão (obras) | REST/HTTP | Token `TOKEN_SANTOS_OBRAS` + header `App_Id` | `nb_ingest_silver_acto_gestao_obras_santos` |
| CSV exportado do Acto | Arquivo manual | — | `nb_ingest_acto_santos` |
| FTP (IBGE/CAGED) | FTP | — | `nb_ingest_caged_santos` |
| Excel auxiliar (`tb_aux.xlsx`) | Arquivo | — | Múltiplos notebooks |
| Excel auxiliar (`PMS_AuxiliarPDR.xlsx`) | Arquivo | — | Notebooks de Obras |
| CSV carta de serviços | Arquivo | — | `nb_ingest_carta_servicos_santos` |

### 2.4. Caminhos ABFSS

Todos os arquivos no OneLake seguem o padrão:
```
abfss://96fe5a53-3a22-4443-8d0a-e2f6d61a2690@onelake.dfs.fabric.microsoft.com/<item-id>/Files/...
```

**Lakehouse ID:** `0f8d9b0e-86cc-4454-9772-4ab92eb4db2a`

---

## 3. Estrutura do Workspace

```
Acto Cidade Inteligente/                    ← Workspace principal
├── Aparecida de Goiânia/
├── Dados Públicos/
├── Mauá/
│   ├── bis_producao/
│   ├── nb/
│   └── pipelines/
├── Osasco/
│   ├── bis/
│   ├── nbs/
│   └── pipelines/
├── Santos/
│   ├── bis/
│   ├── modelos_semanticos/
│   ├── nbs/
│   │   ├── [raiz]                          ← Utils + ingestão geral
│   │   ├── avaliacao_servicos/
│   │   ├── carta_servicos/
│   │   │   └── gestao_prazo_sla/           ← Novo escopo SLA
│   │   ├── cet/
│   │   │   └── curso_motoristas/
│   │   ├── manifestacao_ouvidoria/
│   │   ├── obras/
│   │   │   └── SEONT/
│   │   ├── segov/
│   │   ├── seinfra/
│   │   └── sepref/
│   ├── nbs_analise/
│   └── pipelines/
└── utils/
    ├── config_api_acto.ipynb
    ├── nb_utils_ingest_acto_gestao.ipynb
    ├── nb_utils_maua_ingest_acto_gestao.ipynb
    └── nb_utils_request_api.ipynb
```

---

## 4. Municípios e Domínios de Dados

### 4.1. Santos (Principal)

Lakehouse `lh_cidade_inteligente_santos` — ~37 notebooks mapeados, 21 tabelas Delta em produção. Ver inventário completo em [[Documentação_Fabric/Mapeamento Técnico de Notebooks — Município de Santos|Mapeamento Técnico de Notebooks — Santos]].

### 4.2. Mauá

Lakehouse próprio (`lh_cidade_inteligente_maua`). Notebooks:

| Notebook | Domínio | Camada | Saída |
|---|---|---|---|
| `nb_ingest_maua_acto_gestao_ambiente` | Meio Ambiente | Bronze → Silver | Parquet Silver |
| `nb_ingest_maua_acto_gestao_plan_urbano` | Planejamento Urbano | Bronze → Silver | Parquet Silver |
| `nb_silver_maua_plan_urbano` | Planejamento Urbano | Silver | Delta Table |
| `nb_silver_maua_etapas_tempo_plan_urbano` | Planejamento Urbano | Silver | Delta Table |

**Utilitários próprios:** `nb_utils_maua_ingest_acto_gestao` (em `/utils/`).  
Padrão de ingestão: `extrair_tabela_acto_gestao()` com token `TOKEN_MAUA`.

### 4.3. Osasco

Lakehouse próprio (`lh_cidade_inteligente_osasco`). **31 notebooks mapeados · 11 domínios de dados.**

> Ver documentação completa: [[Documentação_Fabric/Osasco/00_INDEX_OSASCO|Índice Osasco]] · [[Documentação_Fabric/Osasco/Mapeamento Técnico de Notebooks — Osasco|Mapeamento de Notebooks Osasco]]

| Domínio | Nbs | Tabelas Gold | Observação |
|---|---|---|---|
| Assistência Social (CRAS · CadÚnico · RMA · PBF) | 9 | 21 | — |
| Bolsa Trabalho | 2 | 1 | — |
| BPC | 2 | 0 | ⚠️ Escrita Delta comentada — tabela não existe |
| CAGED | 3 | 5 | `CODIGO_OSASCO = 353440` correto aqui |
| Carta de Serviços | 2 | 3 | — |
| Censo / Demográfico | 4 | 3 + 10 CSVs | 10 CSVs precisam migrar para Delta |
| Comércio Exterior | 1 | 1 | — |
| Obras | 1 | 1 | — |
| RAIS | 3 | 0 + 2 CSVs | 2 CSVs precisam migrar para Delta |
| Segurança Pública | 2 | 5 | — |
| Segurança Viária | 2 | 4 | Parquet redundante duplicado com Delta |

**Token:** `TOKEN_OSASCO` + `APP_ID_OSASCO` (Acto Gestão).  
**Utilitários:** `nb_utils_request_api` (em `/utils/`) — wrapper HTTP genérico compartilhado.

**Objetivo declarado pelo líder:** migrar saídas em arquivo (CSV/Parquet) para tabelas Delta Gold para que o Jorge replique o Dash em Python no Power BI.

**Migrações críticas pendentes:**

| Prioridade | Notebook | Ação |
|---|---|---|
| 🔴 CRÍTICO | `nb_gold_osasco_bpc` | Descomentar bloco de escrita `saveAsTable("gold_bpc_osasco")` |
| 🟠 ALTA | `nb_ingest_censo` | 10 `to_csv()` → `saveAsTable("gold_censo_{tema}")` |
| 🟠 ALTA | `nb_gold_rais` | 2 `to_csv()` → `saveAsTable("gold_rais_anual")` + `gold_rais_tamanho_estabelecimento` |
| 🟡 MÉDIA | `nb_gold_populacao_densidade` | 1 `to_csv()` → `saveAsTable("gold_populacao_densidade")` |

---

## 5. Inventário Completo de Notebooks — Santos

| # | Notebook | Domínio | Camada | Tabela(s) de Saída | Modo Escrita | Pipeline? |
|---|---|---|---|---|---|---|
| 1 | `nb_ingest_acto_santos` | Geral | Bronze → Gold | `tb_os_acto`, `acto_prazo.csv` | overwrite | Manual (CSV) |
| 2 | `nb_ingest_dim_date` | Infraestrutura | Bronze | `dim_date_1`, `dim_date_2` | overwrite | Manual |
| 3 | `nb_ingest_tb_aux_servicos` | Infraestrutura | Bronze | `tb_aux_servicos`, `tb_aux_regionais` | overwrite | Manual |
| 4 | `nb_utils_api_acto_gestao` | Utilitário | Utils | — (biblioteca de funções) | — | — |
| 5 | `nb_utils_api_acto_gestao_obras` | Utilitário Obras | Utils | — (biblioteca de funções) | — | — |
| 6 | `nb_silver_santos_avaliacao` | Avaliação | Silver | `silver_avaliacoes_servico.parquet` | overwrite | Pipeline |
| 7 | `nb_gold_santos_avaliacao` | Avaliação | Gold | `gold_avaliacoes_servico` | **overwrite** | Pipeline |
| 8 | `nb_gold_santos_avaliacao_sentimento` | Avaliação IA | Gold+IA | `gold_avaliacoes_servicos_sentimento` | **append** | Pipeline |
| 9 | `nb_ingest_carta_servicos_santos` | Carta de Serviços | Bronze → Gold | `gold_carta_servicos`, `gold_carta_servicos_atualizacoes` | overwrite | Pipeline |
| 10 | `nb_ingest_estrutura_cet` | CET | Bronze | `tb_aux_estrutura_organizacional_cet` | overwrite | **Sem pipeline** |
| 11 | `nb_ingest_silver_cet_carga_descarga` | CET | Silver | `silver_cet_carga_descarga_*.parquet` | overwrite | Pipeline |
| 12 | `nb_gold_acto_gestao_cet_carga_descarga` | CET | Gold | `gold_cet_carga_descarga` | overwrite | Pipeline |
| 13 | `nb_gold_acto_gestao_cet` | CET | Gold | `gold_cet_servicos` | overwrite | Pipeline |
| 14 | `nb_ingest_santos_curso_motoristas` | Curso Motoristas | Bronze | `silver_solicitacoes.parquet`, `silver_etapas.parquet` | overwrite | Pipeline |
| 15 | `nb_silver_santos_curso_motoristas` | Curso Motoristas | Silver → Gold | `gold_curso_motorista` | overwrite | Pipeline |
| 16 | `nb_gold_acto_gestao_manifestacoes_ouvidoria` | Ouvidoria | Gold | `gold_manifestacoes_ouvidoria` | overwrite | Pipeline |
| 17 | `nb_gold_acto_gestao_ouvidoria_servicos` | Ouvidoria (agregação) | Gold | `gold_ouvidoria_servicos` | overwrite | Pipeline |
| 18 | `nb_ingest_silver_acto_gestao_obras_santos` | Obras | Silver | `silver_acto_gesta_obras_santos_*.parquet` | overwrite | Pipeline **BLOQUEADO** |
| 19 | `nb_gold_acto_gestao_obras` | Obras | Gold | `gold_pdr_acompanhamentos_os` | overwrite | Pipeline **BLOQUEADO** |
| 20 | `nb_gold_acto_gestao_obras_etapas` | Obras | Gold | `gold_obras_tempo_etapa` | overwrite | Pipeline **BLOQUEADO** |
| 21 | `nb_gold_acto_gestao_obras_seont_os` | Obras SEONT | Gold | `gold_obras_seont_os` | overwrite | **Sem pipeline** |
| 22 | `nb_gold_acto_gestao_sepref` | SEPREF | Gold | `gold_sepref_servicos` | overwrite | Pipeline |
| 23 | `nb_gold_acto_gestao_segov` | SEGOV | Gold | `gold_segov_servicos` | overwrite | Pipeline |
| 24 | `nb_gold_acto_gestao_seinfra` | SEINFRA | Gold | `gold_seinfra_servicos` | overwrite | Pipeline |

**Notebooks em construção / planejados (domínio SLA):**

| Notebook                      | Camada | Tabela de Saída                    | Status                              |
| ----------------------------- | ------ | ---------------------------------- | ----------------------------------- |
| `nb_ingest_cartas_servico`    | Bronze | `bronze_cartas_servico`            | Previsto                            |
| `nb_silver_cartas_servico`    | Silver | `silver_cartas_servico` (SCD2)     | Previsto                            |
| `nb_silver_solicitacoes_sla`  | Silver | `silver_solicitacoes`              | Previsto                            |
| `nb_gold_dim_cartas_vigencia` | Gold   | `gold_dim_cartas_servico_vigencia` | Previsto                            |
| `nb_gold_fato_solicitacoes`   | Gold   | `gold_fato_solicitacoes`           | Previsto                            |
| `nb_gold_sla_indicadores`     | Gold   | `gold_sla_indicadores`             | Previsto                            |
| `nb_ingest_caged_santos`      | Bronze | Delta CAGED                        | Em construção — **não ativar** (R9) |

---

## 6. Detalhamento Técnico por Notebook

### 6.1. `nb_ingest_acto_santos`

**Camada:** Bronze → Gold (pipeline completo em um único notebook)  
**Fonte:** `Files/acto/exportar.csv` — CSV exportado manualmente da plataforma Acto

**Funções internas:**

| Função | Responsabilidade |
|---|---|
| `processar_os()` | Carrega o CSV, remove duplicatas, unifica colunas de Canal, bfill de bairro |
| `processar_prazo()` | Lê sheet `aux_prazo` do `tb_aux.xlsx` |
| `processar_bairros()` | Lê sheet `aux_regionais` do `tb_aux.xlsx` |
| `aplicar_merge()` | JOIN inner com prazo, LEFT com bairros |
| `tratar_datas()` | Converte datas, calcula `tempo_execucao_real`, `dias_ate_vencimento`, `status_conclusao_servico` |
| `remover_registros_teste()` | Filtra 12 solicitantes de teste conhecidos |
| `tratar_base_final_solicitacoes()` | Atribui `unidade_executora`, `responsavel_execucao`, seleciona 49 colunas finais |
| `harmonizar_ordenar_etapas()` | Normaliza 19 etapas, cria `ordem_etapa` (1–19, 99 para não mapeados) |
| `harmonizar_nome_bairros()` | Corrige 18 variantes de nomes de bairros |
| `ajustar_nome_colunas()` | Converte para snake_case, remove acentos |

**Saídas:**
- `Tables/tb_os_acto` (Delta Table, overwrite + overwriteSchema)
- `Files/acto/acto_prazo.csv`

**Dependências externas (pontos de falha — R1):**
- `Files/acto/exportar.csv` — gerado manualmente
- `Files/acto/tb_aux.xlsx` (sheets `aux_prazo`, `aux_regionais`)

**Riscos:** R1 (arquivo manual), R2 (funções locais divergem do canônico utils), R4 (sem assert rowcount)

---

### 6.2. `nb_ingest_dim_date`

**Camada:** Bronze  
**Fonte:** Geração por PySpark via função `sequence`  
**Lógica:** Sequência diária de `2020-01-01` a `2030-12-31` com colunas em português  
**Saídas:** `dim_date_1` e `dim_date_2` — tabelas idênticas para dois modelos semânticos distintos

---

### 6.3. `nb_ingest_tb_aux_servicos`

**Camada:** Bronze  
**Fonte:** `Files/acto/tb_aux.xlsx`  
**Lógica:** Lê as duas sheets e persiste como Delta Tables consultáveis via SQL  
**Saídas:** `tb_aux_servicos` (sheet `aux_prazo`), `tb_aux_regionais` (sheet `aux_regionais`)

---

### 6.4. `nb_silver_santos_avaliacao`

**Camada:** Silver  
**Dependências:** `%run ./config_api_acto`, `%run ./nb_utils_ingest_acto_gestao`  
**Lógica:** Carrega `payload_santos_avaliacao.json` → chama `extrair_tabela_acto_gestao()` → salva Parquet bruto  
**Saída:** `Files/silver/avaliacoes_servico/silver_avaliacoes_servico.parquet`  
**Volume:** ~12.996 linhas

---

### 6.5. `nb_gold_santos_avaliacao`

**Camada:** Gold  
**Dependências:** `%run ./nb_silver_santos_avaliacao`

**Lógica:**
1. Lê Parquet silver
2. Normaliza nomes de serviços via `padronizar_servicos()` — 15 mapeamentos de variantes e erros de grafia
3. Cria colunas fixas: `codFluxo='12977'`, `codCatalogo='8225'`, `etapa='NA'`
4. Renomeia colunas para schema compatível com `tb_os_acto`
5. Remove registros sem `nome_do_servico_avaliado`, com "teste" em `resposta_secretaria` e sem protocolo
6. Trata `area_responsavel` faltante via de-para por serviço

**Saída:** `gold_avaliacoes_servico` (Delta Table, **overwrite**)  
**Alerta R3:** Overwrite aqui pode desalinhar com o append incremental do notebook de sentimento

---

### 6.6. `nb_gold_santos_avaliacao_sentimento`

**Camada:** Gold+IA  
**Dependências:** `gold_avaliacoes_servico`  
**Pacotes externos:** `groq`, `tqdm`, `pyodbc`, `sqlalchemy`

**Lógica incremental:**
1. Carrega `gold_avaliacoes_servico` (origem) e `gold_avaliacoes_servicos_sentimento` (destino)
2. Filtra apenas `seqFluxo` novos (não presentes no destino)
3. Classifica por regras (nota + palavras-chave); se incerto → chama **Groq API** (modelo `llama-3.1-8b-instant`)
4. Usa cache local para evitar chamadas duplicadas
5. Trata rate-limit HTTP 429: `sleep(65s)`
6. Cria coluna `palavra_foco` (palavra mais frequente no corpus)
7. Grava apenas colunas de sentimento: `seqFluxo` + `analise_*` + `palavra_foco`

**Saída:** `gold_avaliacoes_servicos_sentimento` (Delta Table, **append**)  
**Volume:** 14.085 total (1.340 classificados via IA/regras, 12.745 sem comentário)

---

### 6.7. `nb_ingest_carta_servicos_santos`

**Camada:** Bronze → Gold  
**Fontes:**
- `Files/raw_cadastro_carta/bd_carta_servicos_santos.csv` — registros finalizados (histórico)
- `Files/raw_cadastro_carta/grid_carta_servicos_santos.csv` — registros em aberto

**Lógica:**
1. `carregar_tratar_bd()`: CSV histórico, padroniza colunas via `unidecode`, status = "Finalizado"
2. `carregar_tratar_grid()`: filtra status `Em atendimento` / `Pendente`
3. `gerar_bd_final()`: concat BD + Grid, cria `data_consolidada`, `dias_desde_atualizacao`, `periodo_atualizacao` (6 faixas), extrai `sigla_area_responsavel`
4. `gerar_grid_final()`: versão simplificada para visão de atualizações

**Saídas:**
- `gold_carta_servicos` (Delta Table, overwrite)
- `gold_carta_servicos_atualizacoes` (Delta Table, overwrite)

**Riscos:** R1 (CSVs manuais), R_dup (coexistência com fluxo API em `gestao_prazo_sla/`)

---

### 6.8. `nb_ingest_estrutura_cet`

**Camada:** Bronze  
**Fonte:** Dicionário Python hardcoded (hierarquia CET: Diretoria → Gerência → Unidade Executora)  
**Saída:** `tb_aux_estrutura_organizacional_cet` (Delta Table)  
**Status:** Execução manual apenas — **sem pipeline**

---

### 6.9. `nb_ingest_silver_cet_carga_descarga`

**Camada:** Silver  
**Dependências:** `%run ./nb_utils_ingest_acto_gestao`, `%run ./config_api_acto`  
**Lógica:** Extrai via `extrair_tabela_acto_gestao(payload_cet_carga_descarga.json, TOKEN_SANTOS)`, salva Parquets brutos  
**Saídas:**
- `Files/acto_cet/silver_cet_carga_descarga_solicitacoes.parquet`
- `Files/acto_cet/silver_cet_carga_descarga_etapas.parquet`

**Risco R4:** Sem `assert` de rowcount antes da escrita

---

### 6.10. `nb_gold_acto_gestao_cet_carga_descarga`

**Camada:** Gold  
**Dependências:** `%run ./nb_ingest_silver_cet_carga_descarga`, `%run ./nb_utils_api_acto_gestao`

**Lógica:**
1. Lê Parquets silver da CET
2. `tratar_nome_colunas()`: remove pipe notation, converte para snake_case
3. `tratar_datas()`: calcula `dia_da_semana_num` e `dia_da_semana_txt`
4. `converter_horarios()`: normaliza horários para `HH:MM:SS`
5. `adicionar_periodo_dia()`: classifica em madrugada / manhã / tarde / noite
6. `tratar_bairro_carga()`: normaliza bairros, preenche vazios com "Indisponível"
7. `remover_registros_teste()` via utils

**Saída:** `gold_cet_carga_descarga` (Delta Table, overwrite) | **Volume:** 1.046 registros

---

### 6.11. `nb_gold_acto_gestao_cet`

**Camada:** Gold  
**Dependências:** `%run ./nb_utils_api_acto_gestao`  
**Catálogos da API:** `[8564, 10824, 10825, 11717, 11765]`  
**Padrão:** Template das secretarias (10 passos — ver Seção 12.2)  
**Saída:** `gold_cet_servicos` (Delta Table, overwrite)

---

### 6.12. `nb_ingest_santos_curso_motoristas`

**Camada:** Bronze (arquivos salvos em `Files/silver/` por convenção)  
**Dependências:** `%run ./config_api_acto`, `%run ./nb_utils_ingest_acto_gestao`  
**Lógica:** Extrai via `extrair_tabela_acto_gestao(payload_santos_curso_motorista.json, TOKEN_SANTOS)`  
**Saídas:**
- `Files/silver/santos_curso_motorista/silver_solicitacoes.parquet` (106 linhas, 110 colunas)
- `Files/silver/santos_curso_motorista/silver_etapas.parquet` (712 linhas)

---

### 6.13. `nb_silver_santos_curso_motoristas`

**Camada:** Silver → Gold (pipeline completo)  
**Dependências:** `%run ./nb_utils_api_acto_gestao`

**Lógica:**
1. Lê o Parquet silver mais recente
2. `tratar_nome_colunas()`: remove sufixo `|ID`, converte para snake_case
3. Consolida colunas duplicadas via bfill horizontal
4. **Unpivot:** transforma colunas de presença por dia (`presenca_d2..d8`) em linhas — 1 linha por aluno/dia de aula
5. Conversão de tipos (datas, numéricos)
6. Valida rowcount com `try/except` + `spark.table().count()` após o write ✅

**Saída:** `gold_curso_motorista` (Delta Table, overwrite) | **Volume:** 742 linhas, 120 colunas

**Regras de negócio:**
- D1 = administrativo → excluído de aprovação e presença
- D8 = excluído dos dias válidos de aula
- Ausência inferida apenas para `status_fluxo = "Finalizado"`
- Estados de presença: Presente / Ausente / Pendente / Cancelado

**Anomalia de nomenclatura:** Viola o padrão `nb_gold_santos_*` — deveria ser `nb_gold_santos_curso_motorista`

---

### 6.14. `nb_gold_acto_gestao_manifestacoes_ouvidoria`

**Camada:** Gold  
**Dependências:** `%run ./nb_utils_api_acto_gestao`  
**Catálogos:** `[8044]` (etapas: 24933 MANIFESTAÇÃO, 24937, 24934 CLASSIFICAÇÃO)

**Lógica:**
1. `obter_dados_etapa_atual(TOKEN, [8044])` + `fetch_tabela(json_inline)`
2. `adicionar_etapa_atual()` — join por `"Nº Solicitação|1"`
3. Renomeia para schema `tb_os_acto`
4. `harmonizar_nome_bairros()` + `aplicar_merge_prazo_bairros_ouvidoria()`
5. Prazo fixo de **30 dias** hardcoded: `df['prazo_de_conclusao'] = 30`
6. Alinha schema via `reindex(columns=tb_os_acto.columns)`

**Saída:** `gold_manifestacoes_ouvidoria` (Delta Table, overwrite)  
**Volume:** 755 registros (de 798 extraídos, 43 removidos por testes/merge sem match)

---

### 6.15. `nb_gold_acto_gestao_ouvidoria_servicos`

**Camada:** Gold — agregação  
**Dependências (5 tabelas):**
- `gold_sepref_servicos`
- `gold_seinfra_servicos`
- `gold_cet_servicos`
- `gold_segov_servicos`
- `gold_manifestacoes_ouvidoria`

**Lógica:** `unionAll` via `functools.reduce` — todas as tabelas devem ter schema idêntico (alinhado com `tb_os_acto`)  
**Saída:** `gold_ouvidoria_servicos` (Delta Table, overwrite)  
**Risco:** Divergência de schema em qualquer das 5 tabelas faz o `unionAll` falhar ou produzir NULLs silenciosos

---

### 6.16. `nb_ingest_silver_acto_gestao_obras_santos`

**Camada:** Silver  
**Dependências:** `%run ./nb_utils_ingest_acto_gestao`, `%run ./config_api_acto`  
**Token:** `TOKEN_SANTOS_OBRAS` (distinto do token padrão)

**Saídas:**
- `Files/acto_obras/silver/silver_acto_gesta_obras_santos_solicitacoes.parquet`
- `Files/acto_obras/silver/silver_acto_gesta_obras_santos_etapas.parquet`

> **STATUS — BLOQUEADO (R5 CRÍTICO):** Desde 11/03/2025 lança `HTTPError: 401 Client Error: Unauthorized` em `/api/RelatoriosEtapa/ObterTempoEtapaRelatorio`. Paralisa os notebooks 19, 20 e 21 downstream — 4+ relatórios PBI desatualizados.

---

### 6.17. `nb_gold_acto_gestao_obras`

**Camada:** Gold  
**Dependências:** `%run ./nb_ingest_silver_acto_gestao_obras_santos`

**Lógica:**
1. Carrega Parquets silver (solicitações + etapas)
2. Bfill horizontal nas colunas duplicadas das solicitações
3. `adicionar_etapa_atual_2()` para detectar etapa atual (join por `"Nº Solicitação"`)
4. Merge com `Files/acto/PMS_AuxiliarPDR.xlsx` → colunas `aux_setor_responsavel`, `aux_pdr`, `Zona`
5. Cálculo de colunas derivadas de data/etapa

**Saída:** `gold_pdr_acompanhamentos_os` (Delta Table, overwrite)  
**Schema:** 18 colunas incl. `zona`, `bairro_consolidado`, `zona_aplicavel`, `flag_multiplas_etapas`  
**Volume último run:** 10.366 registros

---

### 6.18. `nb_gold_acto_gestao_obras_etapas`

**Camada:** Gold  
**Dependências:** Parquets silver obras + `%run ./nb_utils_api_acto_gestao`  
**Catálogos:** 27 catálogos `[4803, 4804, 5605, 5625, 5626, 5627, 5628, 5677, 5679, 5685, 5686, 5693, 5725, 5755, 5964, 6093, 6113, 6326, 6383, 6513, 6738, 6783, 6963, 7523, 8134, 12804, 7243]`

**Lógica:**
1. Carrega Parquets silver e chama `obter_dados_etapa_atual()` para os 27 catálogos
2. Mapeia colunas API → formato padrão (OS, etapa, serviço, datas, status, executor)
3. Calcula duração (`duracao_dias_preciso` float e `duracao_dias_int` Int64) **antes** de converter datas
4. Merge com `PMS_AuxiliarPDR.xlsx` → `aux_setor_responsavel` (94% preenchido) e `aux_pdr` (10%)

**Saída:** `gold_obras_tempo_etapa` (Delta Table, overwrite, 15 colunas)  
**Volume último run:** 71.500 registros

---

### 6.19. `nb_gold_acto_gestao_obras_seont_os`

**Camada:** Gold  
**Dependências:** `gold_pdr_acompanhamentos_os`, `silver_acto_gesta_obras_santos_solicitacoes.parquet`  
**Status:** Execução manual apenas — **sem pipeline registrado**

**Lógica:**
1. Carrega `gold_pdr_acompanhamentos_os` (11.303 registros)
2. Extrai analistas por zona do silver via bfill sobre 11 variantes de `"Esta solicitação deverá ser analisada por:|ID"`
3. Merge gold + analistas por `n_da_solicitacao`
4. `flag_seont = 1` se `aux_setor_responsavel in {SEONT, SEONT-Chefia, SEONT-Chefia (D.O), SEONT CHEFIA}`
5. Zera `analista_responsavel` para etapas não-SEONT
6. `flag_etapa_aprov = 1` para 30+ etapas terminais/de aprovação
7. `executor_responsavel`: lógica tripartite (SEONT+executor / SEONT sem executor / não-SEONT)
8. Filtra: mantém apenas `flag_seont = 1`

**Saída:** `gold_obras_seont_os` (Delta Table, overwrite, 22 colunas)  
**Volume:** 263 registros (SEONT-Chefia D.O: 110, SEONT: 78, SEONT-Chefia: 75)

---

### 6.20. Secretarias: SEPREF, SEGOV, SEINFRA

Todos seguem o template de 10 passos (ver Seção 12.2).

| Notebook | Catálogos API | Volume (registros) |
|---|---|---|
| `nb_gold_acto_gestao_sepref` | 49 catálogos em 3 lotes (`payload_sepref1/2/3.json`) | ~7.776 (1.950 + 4.118 + 1.708) |
| `nb_gold_acto_gestao_segov` | `[11737, 9019, 9007, 8994]` | 366 |
| `nb_gold_acto_gestao_seinfra` | `[11636, 11635, 11626, 11627, 11634, 11637]` | 1.161 |

**Particularidade de SEPREF:** Extração em 3 lotes separados por limitação da API com payloads grandes. `adicionar_etapa_atual_2()` (join por `"Nº Solicitação"` sem sufixo).

---

## 7. Notebooks Utilitários

Esta seção detalha cada notebook utilitário, suas funções exportadas e **todos os notebooks que o utilizam via `%run`**.

### 7.1. Mapa Geral de Utilização dos Utils

```
config_api_acto ──────────────────────────────────────────────────────────────────────────┐
        (TOKEN_SANTOS, TOKEN_MAUA, TOKEN_OSASCO)                                          │
                                                                                           ↓ %run
nb_utils_api_acto_gestao ────────────────────────────────────────────────────────────────→ nb_silver_santos_avaliacao
        (fetch_tabela, obter_dados_etapa_atual, adicionar_etapa_atual/2,                  → nb_gold_santos_avaliacao
         harmonizar_nome_bairros, ajustar_nome_colunas,                                   → nb_gold_acto_gestao_cet
         aplicar_merge_prazo_bairros, tratar_datas_prazos, etc.)                          → nb_gold_acto_gestao_cet_carga_descarga
                                                                                           → nb_gold_acto_gestao_sepref
                                                                                           → nb_gold_acto_gestao_segov
                                                                                           → nb_gold_acto_gestao_seinfra
                                                                                           → nb_gold_acto_gestao_manifestacoes_ouvidoria
                                                                                           → nb_silver_santos_curso_motoristas

nb_utils_api_acto_gestao_obras ──────────────────────────────────────────────────────────→ nb_ingest_silver_acto_gestao_obras_santos
        (login_acto_gestao_obras, TOKEN_SANTOS_OBRAS)                                     (único consumidor — ⚠️ R5 CRÍTICO)

nb_utils_ingest_acto_gestao ─────────────────────────────────────────────────────────────→ nb_silver_santos_avaliacao
        (extrair_tabela_acto_gestao)                                                      → nb_ingest_silver_acto_gestao_obras_santos
                                                                                           → nb_ingest_silver_cet_carga_descarga
                                                                                           → nb_ingest_santos_curso_motoristas
                                                                                           → nb_ingest_carta_servicos_santos (via gestao_prazo_sla)

nb_utils_request_api ────────────────────────────────────────────────────────────────────→ notebooks Osasco
        (wrapper genérico HTTP)                                                            → notebooks Mauá (via nb_utils_maua_ingest_acto_gestao)

nb_utils_maua_ingest_acto_gestao ────────────────────────────────────────────────────────→ nb_ingest_maua_acto_gestao_ambiente
        (wrapper Mauá com TOKEN_MAUA)                                                     → nb_ingest_maua_acto_gestao_plan_urbano
```

---

### 7.2. `nb_utils_api_acto_gestao` — Cliente Central Santos

**Localização:** `Acto Cidade Inteligente/Santos/nbs/`  
**Carregado por:** `%run ./nb_utils_api_acto_gestao`  
**Dependências internas:** `%run ./config_api_acto` (configura `TOKEN_SANTOS`)

#### Funções Exportadas

| Função | Assinatura | Descrição |
|---|---|---|
| `fetch_tabela(payload_str)` | `str → pd.DataFrame` | POST para `/api/Tabela/VisualizarDadosIntermediarios`; itera sobre `data[].dados` |
| `obter_dados_etapa_atual(TOKEN, codigos)` | `str, list → pd.DataFrame` | POST para `/api/RelatoriosEtapa/ObterTempoEtapaRelatorio` |
| `adicionar_etapa_atual(df_etapas, df_sol)` | — | Detecta etapa atual por `dataAtenderEtapa` máxima; join pela coluna `"Nº Solicitação\|1"` |
| `adicionar_etapa_atual_2(df_etapas, df_sol)` | — | Idem, mas join pela coluna `"Nº Solicitação"` (sem sufixo `\|1`) |
| `aplicar_bfill(df, coluna)` | — | Consolida variantes duplicadas de uma coluna via bfill horizontal |
| `harmonizar_nome_bairros(df)` | — | Normaliza 16 variantes de nomes de bairros de Santos |
| `ajustar_nome_colunas(df)` | — | Snake_case, remove acentos e símbolos; inclui remoção de vírgulas (fix do Delta) |
| `aplicar_merge_prazo_bairros(acto)` | — | Merge com `tb_aux.xlsx` (prazo + bairros) para secretarias |
| `aplicar_merge_prazo_bairros_ouvidoria(acto)` | — | Idem, renomeia `servico` → `nome_do_servico_avaliado` (uso: ouvidoria) |
| `tratar_datas_prazos(acto_prazo)` | — | Calcula `data_vencimento_prazo`, `tempo_execucao_real`, `dias_ate_vencimento`, `status_conclusao_servico` |
| `tratar_base_final_solicitacoes(acto_prazo)` | — | Atribui `unidade_executora` e `responsavel_execucao` |
| `remover_registros_teste(acto_prazo)` | — | Filtra 13 solicitantes de teste conhecidos |

#### Notebooks que usam este utilitário (`%run`)

| Notebook | Funções utilizadas |
|---|---|
| `nb_silver_santos_avaliacao` | `extrair_tabela_acto_gestao` (via `nb_utils_ingest_acto_gestao`) |
| `nb_gold_santos_avaliacao` | `aplicar_bfill`, `ajustar_nome_colunas`, `remover_registros_teste` |
| `nb_gold_acto_gestao_cet` | `obter_dados_etapa_atual`, `fetch_tabela`, `adicionar_etapa_atual_2`, `harmonizar_nome_bairros`, `aplicar_merge_prazo_bairros`, `tratar_datas_prazos`, `tratar_base_final_solicitacoes`, `remover_registros_teste` |
| `nb_gold_acto_gestao_cet_carga_descarga` | `remover_registros_teste`, `harmonizar_nome_bairros` |
| `nb_gold_acto_gestao_sepref` | `obter_dados_etapa_atual`, `fetch_tabela`, `adicionar_etapa_atual_2`, pipeline completo |
| `nb_gold_acto_gestao_segov` | `obter_dados_etapa_atual`, `fetch_tabela`, `adicionar_etapa_atual_2`, pipeline completo |
| `nb_gold_acto_gestao_seinfra` | `obter_dados_etapa_atual`, `fetch_tabela`, `adicionar_etapa_atual_2`, pipeline completo |
| `nb_gold_acto_gestao_manifestacoes_ouvidoria` | `obter_dados_etapa_atual`, `fetch_tabela`, `adicionar_etapa_atual`, `aplicar_merge_prazo_bairros_ouvidoria` |
| `nb_silver_santos_curso_motoristas` | `ajustar_nome_colunas`, `aplicar_bfill` |

> **CRÍTICO — `adicionar_etapa_atual` vs `_2`:** A diferença é **apenas o nome da coluna de join** (`"Nº Solicitação|1"` vs `"Nº Solicitação"`). Usar a função errada resulta em merge vazio **silencioso** — todas as colunas de etapa ficam `NaN` sem lançar erro.

| Função | Join por | Usada em |
|---|---|---|
| `adicionar_etapa_atual()` | `"Nº Solicitação\|1"` | `nb_gold_acto_gestao_manifestacoes_ouvidoria`, `nb_silver_santos_avaliacao` |
| `adicionar_etapa_atual_2()` | `"Nº Solicitação"` | `nb_gold_acto_gestao_sepref`, `nb_gold_acto_gestao_segov`, `nb_gold_acto_gestao_seinfra`, `nb_gold_acto_gestao_cet`, `nb_gold_acto_gestao_obras` |

---

### 7.3. `nb_utils_api_acto_gestao_obras` — Cliente de Obras

**Localização:** `Acto Cidade Inteligente/Santos/nbs/`  
**Carregado por:** `%run ./nb_utils_api_acto_gestao_obras`  
**Token:** `TOKEN_SANTOS_OBRAS` (separado do token padrão)  
**Header obrigatório:** `App_Id`  
**Endpoint de login:** Distinto da API padrão

#### Funções Exportadas

| Função | Descrição |
|---|---|
| `login_acto_gestao_obras()` | Realiza autenticação dinâmica e renova `TOKEN_SANTOS_OBRAS` |
| Funções de extração específicas para obras | POST para endpoints de Obras |

#### Notebooks que usam este utilitário (`%run`)

| Notebook | Observação |
|---|---|
| `nb_ingest_silver_acto_gestao_obras_santos` | **Único consumidor direto** |

> **STATUS R5 CRÍTICO:** Contém `raise_for_status()` sem `try/except`. Desde 11/03/2025 o token expira e o notebook lança `HTTPError: 401`, paralisando toda a cadeia downstream: `nb_gold_acto_gestao_obras` → `nb_gold_acto_gestao_obras_etapas` → `nb_gold_acto_gestao_obras_seont_os`.

**Correção necessária:**
```python
try:
    response.raise_for_status()
except HTTPError as e:
    if e.response.status_code == 401:
        login_acto_gestao_obras()  # renova TOKEN_SANTOS_OBRAS
        # retry da requisição
    raise
```

---

### 7.4. `nb_utils_ingest_acto_gestao` — Extrator Genérico (Compartilhado)

**Localização:** `Acto Cidade Inteligente/utils/`  
**Carregado por:** `%run ./nb_utils_ingest_acto_gestao` (ou caminho relativo)

#### Funções Exportadas

| Função | Assinatura | Descrição |
|---|---|---|
| `extrair_tabela_acto_gestao(payload_path, token)` | `str, str → (pd.DataFrame, pd.DataFrame)` | Lê o payload JSON, chama a API, retorna `(df_solicitacoes, df_etapas)` |
| `tratar_nome_colunas(df)` | `pd.DataFrame → pd.DataFrame` | Remove sufixo `\|ID` das colunas, converte para snake_case |
| `colunas_para_snake_case(nome)` | `str → str` | Aplica `unicodedata` para remover acentos e converter para snake_case |

#### Notebooks que usam este utilitário (`%run`)

| Notebook | Funções utilizadas | Risco |
|---|---|---|
| `nb_silver_santos_avaliacao` | `extrair_tabela_acto_gestao` | ⚠️ R7 — sem retry |
| `nb_ingest_silver_acto_gestao_obras_santos` | `extrair_tabela_acto_gestao` | ⚠️ R7 + R5 |
| `nb_ingest_silver_cet_carga_descarga` | `extrair_tabela_acto_gestao` | ⚠️ R7 |
| `nb_ingest_santos_curso_motoristas` | `extrair_tabela_acto_gestao` | ⚠️ R7 |
| `nb_ingest_carta_servicos_santos` | `extrair_tabela_acto_gestao` (fluxo gestao_prazo_sla) | ⚠️ R7 |

> **Risco R7:** `raise_for_status()` sem `try/except`. Qualquer falha HTTP interrompe o pipeline imediatamente, sem retry nem log de falha. Afeta 5 pipelines distintos.

---

### 7.5. `config_api_acto` — Configuração de Tokens Multi-município

**Localização principal:** `Acto Cidade Inteligente/utils/`  
**Versão estendida:** `carta_servicos/gestao_prazo_sla/config_api_acto_atualizado` (suporta múltiplos municípios)

#### Variáveis Exportadas

| Variável | Município | Uso |
|---|---|---|
| `TOKEN_SANTOS` | Santos | Maioria dos notebooks de Santos |
| `TOKEN_SANTOS_OBRAS` | Santos — Obras | `nb_utils_api_acto_gestao_obras` |
| `TOKEN_MAUA` | Mauá | Notebooks de Mauá |
| `TOKEN_OSASCO` | Osasco | Notebooks de Osasco |

#### Notebooks que usam este utilitário (`%run`)

| Notebook | Token utilizado |
|---|---|
| `nb_utils_api_acto_gestao` | `TOKEN_SANTOS` |
| `nb_utils_api_acto_gestao_obras` | `TOKEN_SANTOS_OBRAS` |
| `nb_silver_santos_avaliacao` | `TOKEN_SANTOS` (via `nb_utils_ingest_acto_gestao`) |
| `nb_ingest_silver_cet_carga_descarga` | `TOKEN_SANTOS` |
| `nb_ingest_santos_curso_motoristas` | `TOKEN_SANTOS` |
| `nb_ingest_silver_acto_gestao_obras_santos` | `TOKEN_SANTOS_OBRAS` |
| `nb_utils_maua_ingest_acto_gestao` | `TOKEN_MAUA` |
| `nb_ingest_acto_gestao_osasco` | `TOKEN_OSASCO` |
| `gestao_prazo_sla/01_ingestao_cartas_servico` | `TOKEN_SANTOS` |

---

### 7.6. `nb_utils_request_api` — Wrapper HTTP Genérico (Compartilhado)

**Localização:** `Acto Cidade Inteligente/utils/`

#### Funções Exportadas

| Função | Descrição |
|---|---|
| `extrair_tabela_acto_gestao()` | Versão genérica do extrator (mesma lógica de `nb_utils_ingest_acto_gestao`) |
| `make_headers(token)` | Monta o header `Authorization: Bearer <token>` |
| `import_json_payload(path)` | Carrega arquivo `.json` como dicionário Python |

#### Notebooks que usam este utilitário (`%run`)

| Notebook | Município | Observação |
|---|---|---|
| `nb_ingest_acto_gestao_osasco` | Osasco | Wrapper principal de Osasco |
| `nb_utils_maua_ingest_acto_gestao` | Mauá | Importado por este utils de Mauá |

---

### 7.7. `nb_utils_maua_ingest_acto_gestao` — Cliente de Mauá

**Localização:** `Acto Cidade Inteligente/utils/`  
**Dependências:** `%run ./nb_utils_request_api`

#### Funções Exportadas

| Função | Descrição |
|---|---|
| `extrair_tabela_acto_gestao(payload, TOKEN_MAUA)` | Extração adaptada para o endpoint de Mauá |
| `tratar_nome_colunas(df)` | Remove pipe notation, converte para snake_case |
| `consolidar_conceito_bfill(df, coluna)` | Consolida colunas duplicadas via bfill |

#### Notebooks que usam este utilitário (`%run`)

| Notebook | Funções utilizadas |
|---|---|
| `nb_ingest_maua_acto_gestao_ambiente` | `extrair_tabela_acto_gestao`, `tratar_nome_colunas` |
| `nb_ingest_maua_acto_gestao_plan_urbano` | `extrair_tabela_acto_gestao`, `tratar_nome_colunas` |

---

### 7.8. Utilitários do Escopo SLA (Carta de Serviços)

| Notebook | Localização | Função |
|---|---|---|
| `config_api_acto_atualizado` | `carta_servicos/gestao_prazo_sla/` | Tokens atualizados para múltiplos municípios |
| `nb_utils_sla_santos` | `carta_servicos/gestao_prazo_sla/` | Funções específicas de cálculo de SLA e prazo |

**Notebooks que usarão estes utilitários (escopo previsto):**
- `nb_silver_solicitacoes_sla`
- `nb_gold_fato_solicitacoes`
- `nb_gold_sla_indicadores`

---

### 7.9. Funções Duplicadas (Candidatas à Centralização em `nb_utils_shared`)

| Função | Notebooks onde aparece | Divergências entre versões |
|---|---|---|
| `ajustar_nome_colunas()` | `nb_ingest_acto_santos` (local) + `nb_utils_api_acto_gestao` | Local: não remove vírgulas. Utils: remove (fix do Delta) |
| `harmonizar_nome_bairros()` | `nb_ingest_acto_santos` (local) + `nb_utils_api_acto_gestao` | Local: 18 replaces sem `str.title()`. Utils: 16 replaces com `str.title()` |
| `remover_registros_teste()` | `nb_ingest_acto_santos` (local) + `nb_utils_api_acto_gestao` | Local: 12 nomes. Utils: 13 nomes (adiciona "Guilherme Martins Pereira") |
| `import_json_payload()` | Mauá + Santos + Osasco + `nb_utils_request_api` | Código idêntico em todos |
| `tratar_nome_colunas()` | Mauá + Santos + `nb_utils_ingest_acto_gestao` | Regex levemente divergente |
| `colunas_para_snake_case()` | Mauá + Santos + `nb_utils_ingest_acto_gestao` | Diferença no uso de `unicodedata` |
| `consolidar_conceito_bfill()` | Mauá + Santos | Risco de fragmentação |
| `obter_dados_etapa_atual()` | Santos + Mauá (versões distintas) | Tratamento de erro diferente |
| `make_headers()` | Todos os Utils | Gestão de tokens — código idêntico |

**Solução planejada:** Criar `nb_utils_shared` e substituir todas as duplicatas por `%run ./nb_utils_shared`.

---

## 8. Grafo de Dependências e Lineage

### 8.1. Avaliação de Serviços

```
config_api_acto ──────────────────────────────────────┐
nb_utils_ingest_acto_gestao (⚠️R7) ──────────────────┤
                                                      ↓
                                      nb_silver_santos_avaliacao
                                      → silver_avaliacoes_servico.parquet
                                                      ↓
                                      nb_gold_santos_avaliacao
                                      → gold_avaliacoes_servico [OVERWRITE]
                                                      ↓
                                      nb_gold_santos_avaliacao_sentimento
                                      → gold_avaliacoes_servicos_sentimento [APPEND ⚠️R3]
                                                      ↓
                                      [pl_ingest_acto_gestao_santos_avaliacoes_servicos]
```

### 8.2. Obras Públicas

```
nb_utils_api_acto_gestao_obras (⚠️R5 sem retry)
        ↓
nb_ingest_silver_acto_gestao_obras_santos  ⚠️ BLOQUEADO: HTTP 401 desde 11/03/2025
        │
        ├──→ nb_gold_acto_gestao_obras  (⚠️R1 R2)
        │         → gold_pdr_acompanhamentos_os
        │         │
        │         ├──→ nb_gold_acto_gestao_obras_seont_os (sem pipeline!)
        │         │         → gold_obras_seont_os
        │         │
        │         └──→ [pl_ingest_obras_santos]
        │
        └──→ nb_gold_acto_gestao_obras_etapas
                  → gold_obras_tempo_etapa
                  └──→ [pl_ingest_obras_santos] (paralelo com Gold obras)
```

### 8.3. CET + Curso de Motoristas

```
nb_utils_api_acto_gestao
        │
        ├──→ nb_gold_acto_gestao_cet  →  gold_cet_servicos
        │
        └──→ nb_silver_santos_curso_motoristas
                  ↑
        nb_ingest_santos_curso_motoristas (Bronze)
                  └──→ gold_curso_motorista ✅ rowcount

nb_utils_ingest_acto_gestao (⚠️R7)
        ↓
nb_ingest_silver_cet_carga_descarga (⚠️R4)
        ↓
nb_gold_acto_gestao_cet_carga_descarga  →  gold_cet_carga_descarga

[Tudo via pipeline: pl_ingest_acto_gestao_santos_cet]
```

### 8.4. Ouvidoria Agregadora

```
gold_sepref_servicos         ──┐
gold_seinfra_servicos        ──┤
gold_cet_servicos            ──┼──→ nb_gold_acto_gestao_ouvidoria_servicos
gold_segov_servicos          ──┤          → gold_ouvidoria_servicos (unionAll)
gold_manifestacoes_ouvidoria ──┘               ↓
                                     [pl_ingest_ouvidoria_servicos]
```

### 8.5. Secretarias (template padrão)

```
nb_utils_api_acto_gestao
        │
        ├──→ nb_gold_acto_gestao_segov   →  gold_segov_servicos
        ├──→ nb_gold_acto_gestao_seinfra →  gold_seinfra_servicos
        └──→ nb_gold_acto_gestao_sepref  →  gold_sepref_servicos
                  ↑ usa 3 payloads (sepref1/2/3.json) — único com esse padrão
```

### 8.6. Carta de Serviços / SLA (novo escopo)

```
exportar_4.csv (fonte canônica — 693 registros)
        ↓
nb_ingest_cartas_servico  →  bronze_cartas_servico
        ↓
nb_silver_cartas_servico  →  silver_cartas_servico (SCD Type 2)
        ↓
nb_gold_dim_cartas_vigencia  →  gold_dim_cartas_servico_vigencia
        ↓                               ↓
nb_silver_solicitacoes_sla      nb_gold_fato_solicitacoes
→ silver_solicitacoes ──────────────────┘
                                        ↓
                             nb_gold_sla_indicadores
                             → gold_sla_indicadores
```

---

## 9. Catálogo de Tabelas Delta

### 9.1. Tabelas em Produção

| Tabela Delta | Notebook produtor | Tipo | Atualização | Volume (aprox.) |
|---|---|---|---|---|
| `tb_os_acto` | `nb_ingest_acto_santos` | Fato principal | Manual (CSV) | — |
| `dim_date_1` | `nb_ingest_dim_date` | Dimensão tempo | Manual | 2020–2030 |
| `dim_date_2` | `nb_ingest_dim_date` | Dimensão tempo | Manual | 2020–2030 |
| `tb_aux_servicos` | `nb_ingest_tb_aux_servicos` | Auxiliar prazos | Manual | — |
| `tb_aux_regionais` | `nb_ingest_tb_aux_servicos` | Auxiliar regionais | Manual | — |
| `tb_aux_estrutura_organizacional_cet` | `nb_ingest_estrutura_cet` | Auxiliar estática | Manual | — |
| `gold_avaliacoes_servico` | `nb_gold_santos_avaliacao` | Fato | Pipeline | 12.996 |
| `gold_avaliacoes_servicos_sentimento` | `nb_gold_santos_avaliacao_sentimento` | Enriquecimento IA | Pipeline (append) | 14.085 |
| `gold_carta_servicos` | `nb_ingest_carta_servicos_santos` | Fato | Pipeline | — |
| `gold_carta_servicos_atualizacoes` | `nb_ingest_carta_servicos_santos` | Auxiliar | Pipeline | — |
| `gold_cet_carga_descarga` | `nb_gold_acto_gestao_cet_carga_descarga` | Fato | Pipeline | 1.046 |
| `gold_cet_servicos` | `nb_gold_acto_gestao_cet` | Fato | Pipeline | — |
| `gold_curso_motorista` | `nb_silver_santos_curso_motoristas` | Fato | Pipeline | 742 (120 col.) |
| `gold_manifestacoes_ouvidoria` | `nb_gold_acto_gestao_manifestacoes_ouvidoria` | Fato | Pipeline | 755 |
| `gold_ouvidoria_servicos` | `nb_gold_acto_gestao_ouvidoria_servicos` | Fato consolidado | Pipeline | unionAll 5 tabelas |
| `gold_pdr_acompanhamentos_os` | `nb_gold_acto_gestao_obras` | Fato | Pipeline **bloqueado** | 10.366 |
| `gold_obras_tempo_etapa` | `nb_gold_acto_gestao_obras_etapas` | Analítica | Pipeline **bloqueado** | 71.500 |
| `gold_obras_seont_os` | `nb_gold_acto_gestao_obras_seont_os` | Analítica | Manual | 263 |
| `gold_sepref_servicos` | `nb_gold_acto_gestao_sepref` | Fato | Pipeline | ~7.776 |
| `gold_segov_servicos` | `nb_gold_acto_gestao_segov` | Fato | Pipeline | 366 |
| `gold_seinfra_servicos` | `nb_gold_acto_gestao_seinfra` | Fato | Pipeline | 1.161 |

### 9.2. Tabelas Planejadas (Domínio SLA)

| Tabela Delta | Notebook | Granularidade |
|---|---|---|
| `bronze_cartas_servico` | `nb_ingest_cartas_servico` | 1 linha por registro CSV |
| `silver_cartas_servico` | `nb_silver_cartas_servico` | 1 linha por carta ativa (SCD2) |
| `silver_solicitacoes` | `nb_silver_solicitacoes_sla` | 1 linha por solicitação |
| `gold_dim_cartas_servico_vigencia` | `nb_gold_dim_cartas_vigencia` | 1 linha por versão de prazo |
| `gold_fato_solicitacoes` | `nb_gold_fato_solicitacoes` | 1 linha por solicitação |
| `gold_sla_indicadores` | `nb_gold_sla_indicadores` | Por serviço / período / secretaria |

---

## 10. Pipelines de Orquestração

### 10.1. Padrão Uniforme (maioria dos pipelines)

```
Notebook Gold → RefreshSqlEndpoint → Refresh modelo semântico PBI
```

### 10.2. `pl_ingest_obras_santos` (exceção — 9 atividades)

```
nb_ingest_silver_acto_gestao_obras_santos
        ↓
nb_gold_acto_gestao_obras ─────────┐
nb_gold_acto_gestao_obras_etapas ──┘ (paralelo)
        ↓
RefreshSqlEndpoint
        ↓
4× Refresh PBI (paralelo)
```

### 10.2. Cronograma de Execução (Master Schedule)

| Pipeline | Domínio | Frequência | Horário (BRT) |
|---|---|---|---|
| `pl_ingest_acto_santos` | Geral Santos | Diário | 00:00 |
| `pl_ingest_obras_santos` | Obras Santos | Diário | 00:30 |
| `pl_silver_cet_servicos` | CET Santos | Diário | 01:00 |
| `pl_ingest_ouvidoria` | Ouvidoria Santos | Diário | 01:30 |
| `pl_gold_carta_servicos_csv` | Carta Serviços | Semanal | Seg 02:00 |
| `pl_ingest_acto` | Modelo Unificado | Diário | 03:00 |

### 10.3. Notebooks sem Pipeline Mapeado

| Notebook | Saída | Risco |
|---|---|---|
| `nb_gold_acto_gestao_obras_seont_os` | `gold_pdr_seont_os` | Dado pode ficar defasado |
| `nb_ingest_estrutura_cet` | `tb_aux_estrutura_organizacional_cet` | Atualização manual da hierarquia |

### 10.4. Agendamentos Desconhecidos

Os agendamentos dos demais 8 pipelines não foram capturados — requerem acesso via API REST do Fabric:
```
GET https://api.fabric.microsoft.com/v1/workspaces/{workspaceId}/pipelines/{pipelineId}/runs
```

---

## 11. Auditoria de Riscos

### 11.1. Riscos Críticos (Bloqueantes de Produção)

#### R5 — HTTP 401: Pipeline de Obras Paralisada

| Atributo | Detalhe |
|---|---|
| **Onde** | `nb_ingest_silver_acto_gestao_obras_santos` via `nb_utils_api_acto_gestao_obras` |
| **Desde** | 11/03/2025 — mais de 30 dias sem ingestão |
| **Causa** | Token `TOKEN_SANTOS_OBRAS` com vida curta; `raise_for_status()` sem retry |
| **Impacto** | 4 notebooks paralisados (18→19→20→21), 4+ relatórios PBI desatualizados |
| **Correção** | `try/except HTTPError 401 → login_acto_gestao_obras() → retry` |

#### R9 — Código IBGE Incorreto: CAGED Bloqueado

| Atributo | Detalhe |
|---|---|
| **Onde** | `nb_ingest_caged_santos` |
| **Problema** | `CODIGO_OSASCO = 353440` hardcoded — deve ser `CODIGO_SANTOS = 353845` |
| **Impacto** | Se ativado, ingere dados de Osasco no workspace de Santos |
| **Ação** | Corrigir e validar antes de qualquer execução |

---

### 11.2. Fragilidades Arquiteturais

#### R1 — Single Point of Failure: Arquivos Físicos

| Arquivo | Usado em | Risco |
|---|---|---|
| `Files/acto/exportar.csv` | `nb_ingest_acto_santos` | Gerado manualmente — risco humano |
| `Files/acto/tb_aux.xlsx` | `nb_ingest_acto_santos`, `nb_ingest_tb_aux_servicos`, `nb_utils_api_acto_gestao` | Mudança de local quebra avaliação |
| `Files/acto/PMS_AuxiliarPDR.xlsx` | `nb_gold_acto_gestao_obras`, `nb_gold_acto_gestao_obras_etapas` | Mudança de local quebra Gold obras |
| `Files/raw_cadastro_carta/bd_carta_servicos_santos.csv` | `nb_ingest_carta_servicos_santos` | CSV desatualizado = dados defasados |
| `Files/raw_cadastro_carta/grid_carta_servicos_santos.csv` | `nb_ingest_carta_servicos_santos` | idem |

**Ação:** Migrar todos para Delta Tables gerenciadas no Lakehouse.

#### R2 — Código Duplicado com Divergências

Funções idênticas ou levemente divergentes replicadas em múltiplos notebooks. Qualquer correção deve ser aplicada em todos os locais, criando risco de inconsistência.

**Ação:** Criar `nb_utils_shared` e centralizar todas as funções via `%run`.

#### R3 — Dessincronização overwrite × append (Avaliação/Sentimento)

`nb_gold_santos_avaliacao` usa **overwrite** enquanto `nb_gold_santos_avaliacao_sentimento` usa **append** incremental por `seqFluxo`. Se o Gold base for sobrescrito e o sentimento falhar, os IDs ficam desalinhados silenciosamente.

**Ação:** Adicionar `allowFailure = false` isolado para o notebook de sentimento no pipeline.

#### R4 — Ausência de Validação de Rowcount

Notebooks que escrevem sem verificar se o DataFrame está vazio:

| Notebook | Tipo de escrita |
|---|---|
| `nb_ingest_silver_acto_gestao_obras_santos` | `to_parquet()` |
| `nb_ingest_silver_cet_carga_descarga` | `to_parquet()` |
| `nb_ingest_santos_curso_motoristas` | `to_parquet()` |
| `nb_gold_acto_gestao_manifestacoes_ouvidoria` | `saveAsTable` |
| `nb_gold_acto_gestao_cet` | `saveAsTable` |
| `nb_gold_acto_gestao_sepref` | `saveAsTable` |
| `nb_gold_acto_gestao_segov` | `saveAsTable` |
| `nb_gold_acto_gestao_seinfra` | `saveAsTable` |
| `nb_gold_acto_gestao_obras` | `saveAsTable` |
| `nb_gold_acto_gestao_obras_etapas` | `saveAsTable` |

**Padrão correto** (já implementado em `nb_silver_santos_curso_motoristas` ✅):
```python
assert len(df) > threshold, f"DataFrame vazio antes da escrita em {NOME_TABELA}"
```

#### R6 — Dois Layouts de Payload: `adicionar_etapa_atual` vs `_2`

| Função | Coluna de join | Usado em |
|---|---|---|
| `adicionar_etapa_atual()` | `"Nº Solicitação\|1"` | Ouvidoria, Avaliação |
| `adicionar_etapa_atual_2()` | `"Nº Solicitação"` | Secretarias, Obras, SEPREF |

Usar a função errada retorna `NaN` em todas as colunas de etapa **sem lançar erro**.  
**Ação:** Documentar em docstring e adicionar validação de colunas na entrada.

#### R7 — `nb_utils_ingest_acto_gestao` sem Tratamento de Erros

`raise_for_status()` sem `try/except`. Afeta todos os notebooks que dependem deste utilitário: avaliação, carta de serviços, CET, curso de motoristas.

#### R_dup — Carta de Serviços com Duas Abordagens Paralelas

| Abordagem | Proprietário | Fonte | Status |
|---|---|---|---|
| `gestao_prazo_sla/` (API) | Victor | API Acto Gestão | `02_ingestao_solicitacoes` nunca executado |
| `nb_ingest_carta_servicos_santos` | Francisco | CSV em `/raw_cadastro_carta/` | Em produção |

Não está definida a **fonte de verdade**. CSV pode estar desatualizado.  
**Ação:** Definir fonte canônica e desativar a abordagem redundante.

---

## 12. Padrões e Boas Práticas

### 12.1. Convenção de Nomenclatura de Notebooks

**Padrão:** `nb_{camada}_{municipio}_{dominio}`

| Elemento | Valores válidos |
|---|---|
| Prefixo | `nb_` (obrigatório) |
| Camada | `ingest`, `bronze`, `silver`, `gold`, `utils` |
| Município | `santos`, `maua`, `osasco` |
| Domínio | `avaliacao`, `obras`, `cet`, `seinfra`, `sepref`, `segov`, etc. |

**Violação conhecida:** `gold_curso_motorista` → deve ser renomeado para `nb_gold_santos_curso_motorista`

### 12.2. Template de Pipeline das Secretarias (10 Passos)

Os notebooks `nb_gold_acto_gestao_sepref`, `segov`, `seinfra` e `cet` seguem o mesmo template:

```python
%run ./nb_utils_api_acto_gestao

# 1. Extração   — obter_dados_etapa_atual(TOKEN, [codigos]) + fetch_tabela(json_inline)
# 2. Junção     — adicionar_etapa_atual_2(df_etapas, df_solicitacoes)
# 3. Renomear   — tratar_nome_coluna()
# 4. Bairros    — harmonizar_nome_bairros()
# 5. Enriquec.  — aplicar_merge_prazo_bairros()  →  prazo + bairros via tb_aux.xlsx
# 6. Datas      — tratar_datas_prazos()
# 7. Negócio    — tratar_base_final_solicitacoes()  →  unidade_executora, responsavel_execucao
# 8. Filtro     — remover_registros_teste()
# 9. Schema     — reindex(columns=tb_os_acto.columns)  →  alinha para o unionAll
# 10. Escrita   — saveAsTable("gold_<secretaria>_servicos", mode="overwrite")
```

O passo 9 (`reindex`) garante que todas as tabelas das secretarias têm o mesmo schema que `tb_os_acto`, permitindo o `unionAll` em `nb_gold_acto_gestao_ouvidoria_servicos`.

### 12.3. Gestão de Segredos (Recomendação)

Tokens atualmente armazenados em notebooks de config (`config_api_acto`). Recomendação: migrar para **Azure Key Vault** integrado ao Fabric.

### 12.4. Performance — Migração para Spark Nativo

Vários notebooks usam `toPandas()` e processam dados no driver. Para volumes maiores, risco de `OOM`. Reescrever funções de tratamento (`bfill`, `snake_case`) usando funções nativas do **PySpark** (`pyspark.sql.functions`).

---

## 13. SCD Type 2 — Carta de Serviços / SLA

### 13.1. Contexto

O maior risco de confiabilidade atual é a ausência de versionamento dos prazos das cartas de serviço. Quando um prazo é alterado, qualquer recálculo histórico passa a usar o novo valor, corrompendo retrospectivamente os indicadores.

### 13.2. Schema da Dimensão de Vigência

```sql
-- gold_dim_cartas_servico_vigencia
sk_carta          INTEGER  -- PK surrogate (identificador de versão)
id_servico        STRING   -- NK chave natural (ID do serviço no Acto)
nm_servico        STRING   -- Nome do serviço normalizado
ds_secretaria     STRING   -- Secretaria responsável
nr_prazo          INTEGER  -- Quantidade de dias do prazo
is_dias_uteis     BOOLEAN  -- True = dias úteis; False = dias corridos
dt_inicio_vigencia DATE    -- Data em que esta versão passou a valer  [SCD2]
dt_fim_vigencia   DATE     -- 9999-12-31 se registro ativo             [SCD2]
is_atual          BOOLEAN  -- True = versão vigente                   [SCD2]
dt_carga          TIMESTAMP -- Timestamp da ingestão (auditoria)
```

### 13.3. Lógica de Join SLA

```sql
-- CORRETO: usa dt_inicio_vigencia e dt_fim_vigencia
SELECT
    s.*,
    d.nr_prazo,
    d.is_dias_uteis
FROM silver_solicitacoes s
LEFT JOIN gold_dim_cartas_servico_vigencia d
    ON  s.id_servico       = d.id_servico
    AND s.dt_abertura     >= d.dt_inicio_vigencia
    AND s.dt_abertura      < d.dt_fim_vigencia

-- NUNCA fazer apenas:
-- ... ON s.id_servico = d.id_servico AND d.is_atual = True
-- (aplica o prazo mais recente a todas as solicitações históricas)
```

### 13.4. Fonte de Dados — `exportar_4.csv`

| Atributo | Valor |
|---|---|
| Registros | 693 |
| Colunas | 13 |
| Delimitador | `;` |
| Encoding | UTF-8 BOM |
| Quotechar | `"` |
| Fonte canônica | `exportar_4.csv` — descartar `cadastro_carta_de_servico.csv` (idêntico) |

**Diagnóstico de qualidade:**

| Problema | Severidade | Qtd. | Tratamento |
|---|---|---|---|
| Campos multiline (docs, formas de consulta) | Alta | Todos | `csv.reader` com `quotechar='"'` + CRLF handling |
| IDs nulos (`ID do serviço`) | Média | 3 (0,4%) | Tabela de rejeição; não propagar para Gold |
| Prazos nulos | Média | 39 (5,6%) | Marcar como `sem_sla_definido` |
| Dias vs. Dias úteis | Alta | 207 dias úteis | Coluna flag `is_dias_uteis BOOLEAN` |
| Sem controle de versão/vigência | Crítica | 100% | SCD Type 2 na `dim_cartas_vigencia` |

---

## 14. Notebooks de Outros Municípios

### 14.1. Mauá — Padrão de Ingestão

```python
# nb_ingest_maua_acto_gestao_ambiente.ipynb
%run ./nb_utils_maua_ingest_acto_gestao

df_sol, df_etapas = extrair_tabela_acto_gestao(payload, TOKEN_MAUA)

# Tratamentos comuns à camada Silver:
# - tratar_nome_colunas(): remove pipe notation, converte para snake_case
# - consolidar_conceito_bfill(): consolida colunas duplicadas
# - Salva em Parquet (Silver) e Delta (Gold)
```

**Domínios:** Meio Ambiente (`nb_ingest_maua_acto_gestao_ambiente`), Planejamento Urbano (`nb_ingest_maua_acto_gestao_plan_urbano`, `nb_silver_maua_plan_urbano`, `nb_silver_maua_etapas_tempo_plan_urbano`)

### 14.2. Osasco — Inventário Completo

> Ver documentação técnica completa: [[Documentação_Fabric/Osasco/Mapeamento Técnico de Notebooks — Osasco|Mapeamento Técnico de Notebooks — Osasco]]  
> Índice e resumo executivo: [[Documentação_Fabric/Osasco/00_INDEX_OSASCO|Índice Osasco]]

**31 notebooks · 11 domínios · Lakehouse `lh_cidade_inteligente_osasco`**  
**Workspace:** Acto Cidade Inteligente > Osasco > nbs  
**Token:** `TOKEN_OSASCO` + `APP_ID_OSASCO`

**Padrão de ingestão via Acto Gestão:**
```python
%run ./nb_utils_request_api
%run ./config_api_acto  # expõe TOKEN_OSASCO

# Extração padrão
extrair_tabela_acto_gestao(payload_path, TOKEN_OSASCO)
```

**Fontes de dados utilizadas:**

| Fonte | Domínio | Autenticação |
|---|---|---|
| API Acto Gestão | CRAS · Bolsa Trabalho · Carta Serviços · Monitora OZ | `TOKEN_OSASCO` + `APP_ID_OSASCO` |
| Portal da Transparência | BPC · Bolsa Família | Pública |
| FTP MTE | CAGED · RAIS | Anônimo |
| Google BigQuery (Base dos Dados) | RAIS dump histórico | JSON credencial `Files/bd2024-*.json` |
| IBGE SIDRA / ipeadatapy | Censo · PIB · Densidade | Pública |
| INFOSIGA DETRAN SP | Segurança Viária | Pública |
| CadÚnico TXT (SEADS) | CadÚnico | Arquivo manual |

**Nota:** O notebook `nb_ingest_caged_santos` contém `CODIGO_OSASCO = 353440` hardcoded — herdado de Osasco, deve ser corrigido para `CODIGO_SANTOS = 353845` antes de qualquer execução (risco R9).

**Arquivos auxiliares críticos (R1 — Osasco):**

| Arquivo | Usado em | Risco |
|---|---|---|
| `Files/cadastro_unico/cep_bairros.csv` | `nb_gold_cad_unico_pg` | JOIN CEP→bairro, quebra silenciosa |
| `Files/bd2024-444413-1084f2b9d765.json` | `nb_ingest_rais_bd` | Credencial BigQuery — arquivo único |
| `Files/obras/tb_aux_etapas_consideradas.xlsx` | `nb_ingest_grid_obras` | Lista de etapas consideradas |
| `Files/metadata/bpc/controle_carga.csv` | `nb_ingest_osasco_bpc` | Controle incremental de carga |

---

## 15. Roadmap e Plano de Ação

### 15.1. Imediato — Bloqueios de Produção

| # | Ação | Responsável | Esforço | Risco |
|---|---|---|---|---|
| 1 | Implementar retry HTTP 401 em `nb_utils_api_acto_gestao_obras` | Victor | Baixo | R5 |
| 2 | Corrigir `CODIGO_IBGE` no CAGED (353440 → 353845) | Victor/Yuri | Mínimo | R9 |

### 15.2. Curto Prazo — Fragilidade Alta

| # | Ação | Responsável | Esforço | Risco |
|---|---|---|---|---|
| 3 | Adicionar `assert len(df) > 0` antes de todos os `to_parquet/saveAsTable` | Victor/Yuri | Baixo | R4 |
| 4 | Migrar Excel/CSV auxiliares para tabelas Delta gerenciadas | Yuri | Médio | R1 |
| 5 | Obter agendamentos dos 9 pipelines via API REST Fabric | Victor | Baixo | Governança |
| 6 | Criar pipeline para `nb_gold_acto_gestao_obras_seont_os` | Victor | Baixo | — |
| 7 | Documentar `adicionar_etapa_atual` vs `_2` com docstrings e validação | Victor | Baixo | R6 |

### 15.3. Médio Prazo — Melhoria de Manutenção

| # | Ação | Responsável | Esforço | Risco |
|---|---|---|---|---|
| 8 | Criar `nb_utils_shared` e centralizar funções duplicadas | Victor/Yuri | Médio | R2 |
| 9 | Adicionar `try/except HTTPError` em `nb_utils_ingest_acto_gestao` | Yuri | Baixo | R7 |
| 10 | Definir fonte canônica para carta_servicos (CSV vs API) | Victor + Francisco | Decisão | R_dup |
| 11 | Adicionar `allowFailure = false` para `nb_gold_santos_avaliacao_sentimento` | Victor | Baixo | R3 |

### 15.4. Médio/Longo Prazo — Novo Escopo SLA

| Fase | Entrega | Notebooks | Status |
|---|---|---|---|
| F3 | Ingestão Cartas de Serviço | `nb_ingest_cartas_servico` → `bronze_cartas_servico` | A fazer |
| F4 | Silver — Limpeza e SCD2 | `nb_silver_cartas_servico`, `nb_silver_solicitacoes_sla` | A fazer |
| F5 | Gold — Dimensão e Fato | `nb_gold_dim_cartas_vigencia`, `nb_gold_fato_solicitacoes` | A fazer |
| F6 | Gold — Indicadores SLA + Power BI | `nb_gold_sla_indicadores`, relatório PBI | A fazer |

### 15.5. Longo Prazo — Consolidação Arquitetural

| # | Ação | Responsável | Esforço |
|---|---|---|---|
| 12 | Mapear `Santos/modelos_semanticos` e `Santos/nbs_analise` | Victor | Médio |
| 13 | Ativar e validar `02_ingestao_solicitacoes` de carta_servicos | Victor | Médio |
| 14 | Migrar `toPandas()` para PySpark nativo nas funções de tratamento | Victor/Yuri | Alto |
| 15 | Implementar Azure Key Vault para gestão de tokens | Yuri | Médio |
| 16 | Schema Enforcement na camada Bronze (evitar quebras silenciosas da API) | Victor/Yuri | Médio |

---

| Área | Item | Prioridade | Status |
|---|---|---|---|
| `Santos/modelos_semanticos` | Inventário de modelos semânticos PBI | Média | ✅ Concluído |
| `Santos/nbs_analise` | Inventário — exploratório ou produção? | Média | ✅ Concluído |
| Pipelines | Agendamentos de todos os pipelines | Alta | ✅ Concluído |
| `pl_cet` | Atividades 2 e 7 (nomes) | Média | ✅ Concluído |
| `gestao_prazo_sla/02_ingestao` | Validação funcional | Alta | ✅ Concluído |
| Osasco | Migrações CSV → Delta | Alta | 🟠 Ativo |
| Mauá | Mapeamento completo pipelines/PBI | Baixa | ✅ Concluído |

---

## Referências e Fontes

| Documento | Tipo |
|---|---|
| [[Documentação_Fabric/Referencia_Tecnica_Fabric_Santos_v2_0|Referencia_Tecnica_Fabric_Santos_v2_0]] | **Documento raiz v2.0** — Panorama executivo, inventário, pipelines, PBI, riscos |
| [[Documentação_Fabric/fabric_santos_nbs_analise|fabric_santos_nbs_analise]] | Análise analítica de notebooks — grafo de dependências, diagnóstico R1–R9, volumes |
| [[Documentação_Fabric/Mapeamento Técnico de Notebooks — Município de Santos|Mapeamento Técnico de Notebooks — Santos]] | Inventário técnico: leitura direta dos `.ipynb` |
| [[Documentação_Fabric/Osasco/Mapeamento Técnico de Notebooks — Osasco|Mapeamento Técnico de Notebooks — Osasco]] | Inventário técnico Osasco: 31 nbs, 11 domínios |
| [[Documentação_Fabric/Osasco/00_INDEX_OSASCO|Índice Osasco]] | Resumo executivo Osasco + migrações prioritárias |
| [[Documentação_Fabric/Osasco/Demografico_RAIS — Documentação Técnica|Demográfico & RAIS — Doc. Técnica]] | Documentação aprofundada dos 7 notebooks Censo/Demo e RAIS |
| [[Documentação_Fabric/roadmap_acto_fabric|roadmap_acto_fabric]] | Roadmap SLA / Cartas de Serviço |
| [[Documentação_Fabric/mapeamento_paineis_powerbi_santos|mapeamento_paineis_powerbi_santos]] | Inventário técnico dos 19 painéis PBI |
| `CLAUDE.md` | Instruções e contexto do projeto |

---

*Documento consolidado em Abril 2026 · Acto Cidade Inteligente — Município de Santos*  
*Workspace ID: `96fe5a53-3a22-4443-8d0a-e2f6d61a2690` · Lakehouse ID: `0f8d9b0e-86cc-4454-9772-4ab92eb4db2a`*

---

## Ver Também

- [[_mapa-do-vault]] — índice geral do vault
- [[Conhecimento/Fabric/fabric-workspace-acto-cidade-inteligente|fabric-workspace-acto-cidade-inteligente]] — workspace completo Acto Cidade Inteligente
- [[Conhecimento/Fabric/pipeline-acto-santos-fabric|pipeline-acto-santos-fabric]] — fluxo Data Factory + notebooks
- [[Projetos/acto-santos-pipeline]] — projeto ACTO Santos
