---
title: Diagramas — Módulo Acto (Nova Versão)
date: 2026-05-01
tags:
  - ferramenta/fabric
  - tipo/referencia
  - tema/etl-elt
projeto: acto-cidade-inteligente
fonte: documentacao-interna
status: ativo
---
# Diagramas — Módulo Acto (Nova Versão)

> Todos os diagramas em formato Mermaid para uso em Obsidian, GitHub ou qualquer renderer Mermaid.  
> **Atualizado:** 2026-05-01

---

## 1. Arquitetura Geral — Visão Completa

```mermaid
graph TB
    subgraph "Cidadão"
        CID[Cidadão / Solicitante]
    end

    subgraph "Acto Gestão (SaaS)"
        ACTO[Plataforma Acto Gestão<br/>acto.net.br]
        API_AUTH[API Login Único<br/>OAuth2 Token]
        API_DATA[API Dados<br/>VisualizarDadosIntermediarios]
        API_ETAPA[API Etapas<br/>ObterTempoEtapaRelatorio]
    end

    subgraph "Microsoft Fabric"
        subgraph "Lakehouse: lh_solicitacoes_acto"
            PAYLOADS["/Files/payloads/<br/>payload_*.json"]
            BRONZE_S["bronze.fato_solicitacoes_*"]
            BRONZE_C["bronze.fato_campos_*"]
            BRONZE_E["bronze.fato_etapas_*"]
            SILVER_S["silver.fato_solicitacoes"]
            SILVER_C["silver.fato_campos"]
            SILVER_E["silver.fato_etapas"]
            GOLD["gold.*<br/>Tabelas de consumo"]
        end

        subgraph "Notebooks"
            NB_TOKEN[nb_get_token_api]
            NB_ORQ_B[nb_bronze_orquestracao]
            NB_BRZ[nb_bronze_acto_gestao]
            NB_UTILS[nb_utils_request_api]
            NB_SIL[nb_silver_acto_gestao]
            NB_ORQ_G[_nb_gold_orquestracao]
            NB_GOLD_1["nb_gold_santos_cet"]
            NB_GOLD_2["nb_gold_santos_sepref"]
            NB_GOLD_3["nb_gold_osasco_*"]
        end

        PIPE[Pipeline: pl_ingest_acto]
        SQL[SQL Analytics Endpoint]
    end

    subgraph "Consumo"
        PBI[Power BI<br/>Dashboard]
    end

    CID --> ACTO
    ACTO --> API_DATA & API_ETAPA
    NB_TOKEN --> API_AUTH
    API_AUTH -->|JWT| NB_ORQ_B
    NB_ORQ_B -->|loop| NB_BRZ
    NB_BRZ --> API_DATA & API_ETAPA
    NB_BRZ -->|"%run"| NB_UTILS
    PAYLOADS --> NB_BRZ
    NB_BRZ --> BRONZE_S & BRONZE_C & BRONZE_E
    NB_SIL --> SILVER_S & SILVER_C & SILVER_E
    NB_ORQ_G --> NB_GOLD_1 & NB_GOLD_2 & NB_GOLD_3
    NB_GOLD_1 & NB_GOLD_2 & NB_GOLD_3 --> GOLD
    GOLD --> SQL --> PBI

    PIPE -.->|orquestra| NB_ORQ_B
    PIPE -.-> NB_SIL
    PIPE -.-> NB_ORQ_G
    PIPE -.-> SQL

    style CID fill:#4CAF50,stroke:#333,color:#fff
    style ACTO fill:#673AB7,stroke:#333,color:#fff
    style BRONZE_S fill:#cd7f32,stroke:#333,color:#fff
    style BRONZE_C fill:#cd7f32,stroke:#333,color:#fff
    style BRONZE_E fill:#cd7f32,stroke:#333,color:#fff
    style SILVER_S fill:#c0c0c0,stroke:#333
    style SILVER_C fill:#c0c0c0,stroke:#333
    style SILVER_E fill:#c0c0c0,stroke:#333
    style GOLD fill:#ffd700,stroke:#333
    style PBI fill:#FF9800,stroke:#333,color:#fff
```

---

## 2. Pipeline `pl_ingest_acto` — Fluxo de Execução

```mermaid
graph LR
    A["1. nb_bronze_orquestracao<br/>━━━━━━━━━━━━━<br/>• Gera tokens (OAuth2)<br/>• Loop por 4 fontes<br/>• Chama nb_bronze_acto_gestao<br/>  com parâmetros<br/>━━━━━━━━━━━━━<br/>~4 min"]

    B["2. nb_silver_acto_gestao<br/>━━━━━━━━━━━━━<br/>• Union de todas as<br/>  fontes Bronze<br/>• Cast de datas<br/>• Grava 3 tabelas Silver<br/>━━━━━━━━━━━━━<br/>~1 min"]

    C["3. _nb_gold_orquestracao<br/>━━━━━━━━━━━━━<br/>• Executa notebooks<br/>  Gold via %run<br/>• Pivot de campos<br/>• Métricas calculadas<br/>━━━━━━━━━━━━━<br/>~2 min"]

    D["4. RefreshSqlEndpoint<br/>━━━━━━━━━━━━━<br/>• Atualiza metastore<br/>  SQL do Lakehouse<br/>━━━━━━━━━━━━━<br/>~1 min"]

    E["5. Refresh PBI<br/>━━━━━━━━━━━━━<br/>• Refresh do modelo<br/>  semântico Direct Lake<br/>━━━━━━━━━━━━━<br/>~2 min"]

    A --> B --> C --> D --> E

    style A fill:#cd7f32,stroke:#333,color:#fff
    style B fill:#c0c0c0,stroke:#333
    style C fill:#ffd700,stroke:#333
    style D fill:#4682b4,stroke:#333,color:#fff
    style E fill:#2e8b57,stroke:#333,color:#fff
```

---

## 3. Fluxo de Dados Bronze — Detalhamento

```mermaid
graph TD
    subgraph "nb_bronze_orquestracao"
        CRED["Credenciais (user/senha)"]
        TOKENS["get_acto_token()"]
        LOOP["for fonte in fontes:"]
    end

    subgraph "nb_bronze_acto_gestao (parametrizado)"
        PARAMS["Parâmetros:<br/>PAYLOAD_PATH, TOKEN,<br/>ID_FONTE, MUNICIPIO,<br/>SECRETARIA, UO"]
        EXTRACT["extrair_tabela_acto_gestao()"]
        SPLIT["Separação em 3 DataFrames"]
        META["Injeção de metadados<br/>(municipio, secretaria, UO)"]
        WRITE["write_bronze()"]
    end

    subgraph "Tabelas Bronze"
        T1["bronze.fato_solicitacoes_{ID_FONTE}<br/>━━━━<br/>Cabeçalho da OS: id_os, servico,<br/>status_fluxo, datas, solicitante"]
        T2["bronze.fato_campos_{ID_FONTE}<br/>━━━━<br/>Campos variáveis em EAV:<br/>id_os, campo, valor"]
        T3["bronze.fato_etapas_{ID_FONTE}<br/>━━━━<br/>Tempos por etapa:<br/>id_os, etapa, datas"]
    end

    CRED --> TOKENS
    TOKENS --> LOOP
    LOOP -->|"mssparkutils.notebook.run()"| PARAMS
    PARAMS --> EXTRACT
    EXTRACT --> SPLIT
    SPLIT --> META
    META --> WRITE
    WRITE --> T1 & T2 & T3

    style TOKENS fill:#ff9,stroke:#333
    style T1 fill:#cd7f32,stroke:#333,color:#fff
    style T2 fill:#cd7f32,stroke:#333,color:#fff
    style T3 fill:#cd7f32,stroke:#333,color:#fff
```

---

## 4. Modelo de Dados (Estrela) — Silver & Gold

```mermaid
erDiagram
    FATO_SOLICITACOES {
        string id_os PK
        string servico
        string status_fluxo
        timestamp data_criacao
        timestamp data_finalizacao
        string solicitante
        string municipio
        string secretaria
        string unidade_organizacional
        string origem
        timestamp data_carga
    }

    FATO_CAMPOS {
        string id_os FK
        string servico
        string campo
        string valor
        string municipio
        string secretaria
        string unidade_organizacional
        string origem
        timestamp data_carga
    }

    FATO_ETAPAS {
        string id_os FK
        string etapa
        timestamp data_criacao
        timestamp data_finalizacao
        timestamp data_inicio_etapa
        timestamp data_fim_etapa
        timestamp data_atender_etapa
        string municipio
        string secretaria
        string unidade_organizacional
        string origem
        timestamp data_carga
    }

    GOLD_CET {
        string id_os PK
        string servico
        string status_fluxo
        timestamp data_criacao
        timestamp data_finalizacao
        string solicitante
        string bairro
        string canal
        string cpf
        string nome
        string placa_do_veiculo
        string etapa_atual
        timestamp data_fim_ultima_etapa
    }

    FATO_SOLICITACOES ||--o{ FATO_CAMPOS : "id_os"
    FATO_SOLICITACOES ||--o{ FATO_ETAPAS : "id_os"
    FATO_SOLICITACOES ||--|| GOLD_CET : "pivot + join"
```

---

## 5. Comparativo: Versão Legada vs. Nova Versão

```mermaid
graph LR
    subgraph "VERSÃO LEGADA"
        direction TB
        L_TOKEN["config_api_acto<br/>Token HARDCODED<br/>❌ Expira manual"]
        L_NB1["nb_gold_acto_gestao_cet<br/>Extrai + Transforma + Grava"]
        L_NB2["nb_gold_acto_gestao_sepref<br/>Extrai + Transforma + Grava"]
        L_NB3["nb_gold_acto_gestao_segov<br/>Extrai + Transforma + Grava"]
        L_NB4["...N notebooks Gold"]
        L_PIPE1["pl_ingest_santos_cet"]
        L_PIPE2["pl_ingest_santos_sepref"]
        L_PIPE3["pl_ingest_santos_segov"]

        L_TOKEN --> L_NB1 & L_NB2 & L_NB3
        L_NB1 --> L_PIPE1
        L_NB2 --> L_PIPE2
        L_NB3 --> L_PIPE3
    end

    subgraph "NOVA VERSÃO"
        direction TB
        N_TOKEN["nb_get_token_api<br/>OAuth2 Automático<br/>✅ Cache + Renovação"]
        N_ORQ["nb_bronze_orquestracao<br/>Loop parametrizado"]
        N_BRZ["nb_bronze_acto_gestao<br/>1 notebook genérico"]
        N_SIL["nb_silver_acto_gestao<br/>Union consolidado"]
        N_GOLD["Gold por domínio<br/>(pivot da Silver)"]
        N_PIPE["pl_ingest_acto<br/>1 pipeline único"]

        N_TOKEN --> N_ORQ
        N_ORQ --> N_BRZ
        N_BRZ --> N_SIL
        N_SIL --> N_GOLD
        N_ORQ & N_SIL & N_GOLD --> N_PIPE
    end

    style L_TOKEN fill:#f44336,stroke:#333,color:#fff
    style N_TOKEN fill:#4CAF50,stroke:#333,color:#fff
    style L_PIPE1 fill:#FF9800,stroke:#333,color:#fff
    style L_PIPE2 fill:#FF9800,stroke:#333,color:#fff
    style L_PIPE3 fill:#FF9800,stroke:#333,color:#fff
    style N_PIPE fill:#2196F3,stroke:#333,color:#fff
```

---

## 6. Ciclo de Vida da Solicitação (Business Flow)

```mermaid
stateDiagram-v2
    [*] --> Aberta: Cidadão solicita serviço
    Aberta --> EmAnalise: Triagem pela secretaria
    EmAnalise --> EmExecucao: Aprovado para execução
    EmAnalise --> Cancelado: Negado / Duplicado
    EmExecucao --> Finalizado: Serviço concluído
    EmExecucao --> Cancelado: Cancelado durante execução
    Finalizado --> [*]
    Cancelado --> [*]

    note right of Aberta
        status_fluxo = "Em Andamento"
        data_criacao = agora
    end note

    note right of Finalizado
        status_fluxo = "Finalizado"
        data_finalizacao = agora
    end note

    note right of Cancelado
        status_fluxo = "Cancelado"
    end note
```

---

## 7. Fluxo de Autenticação OAuth2

```mermaid
sequenceDiagram
    participant ORQ as nb_bronze_orquestracao
    participant TOKEN as nb_get_token_api
    participant CACHE as _token_cache (memória)
    participant AUTH as API Login Único<br/>(CodeCiphers)
    participant API as API Acto Gestão

    ORQ->>TOKEN: get_acto_token("santos", user, senha)
    TOKEN->>CACHE: Token em cache e válido?

    alt Cache válido (expires_at > now + 60s)
        CACHE-->>TOKEN: Token JWT cacheado
        TOKEN-->>ORQ: Token JWT
    else Cache expirado ou ausente
        TOKEN->>AUTH: POST /Token<br/>(username, password, app_id, param_login)
        AUTH-->>TOKEN: { access_token, expires_in }
        TOKEN->>CACHE: Salva token + expires_at
        TOKEN-->>ORQ: Token JWT novo
    end

    ORQ->>API: POST /VisualizarDadosIntermediarios<br/>Authorization: Bearer {token}
    API-->>ORQ: JSON com solicitações
```

---

## 8. Mapa de Fontes e Tabelas

```mermaid
graph LR
    subgraph "Fontes (Payloads)"
        P1[payload_santos_cet.json]
        P2[payload_santos_sepref_consolidado.json]
        P3[payload_osasco_atendimento_cras.json]
        P4[payload_osasco_atendimento_trabalhador.json]
    end

    subgraph "Bronze (por fonte)"
        B1["bronze.fato_solicitacoes_santos_cet<br/>bronze.fato_campos_santos_cet<br/>bronze.fato_etapas_santos_cet"]
        B2["bronze.fato_solicitacoes_santos_sepref<br/>bronze.fato_campos_santos_sepref<br/>bronze.fato_etapas_santos_sepref"]
        B3["bronze.fato_solicitacoes_osasco_atendimento_cras<br/>bronze.fato_campos_osasco_atendimento_cras<br/>bronze.fato_etapas_osasco_atendimento_cras"]
        B4["bronze.fato_solicitacoes_osasco_atendimento_trabalhador<br/>bronze.fato_campos_osasco_atendimento_trabalhador<br/>bronze.fato_etapas_osasco_atendimento_trabalhador"]
    end

    subgraph "Silver (consolidado)"
        S["silver.fato_solicitacoes<br/>silver.fato_campos<br/>silver.fato_etapas"]
    end

    subgraph "Gold (por domínio)"
        G1[gold_fato_solicitacoes_cet]
        G2[gold_fato_solicitacoes_sepref]
        G3["gold.osasco_atendimento_cras"]
        G4["gold.osasco_atendimento_trabalhador"]
    end

    P1 --> B1
    P2 --> B2
    P3 --> B3
    P4 --> B4
    B1 & B2 & B3 & B4 --> S
    S --> G1 & G2 & G3 & G4

    style B1 fill:#cd7f32,stroke:#333,color:#fff
    style B2 fill:#cd7f32,stroke:#333,color:#fff
    style B3 fill:#cd7f32,stroke:#333,color:#fff
    style B4 fill:#cd7f32,stroke:#333,color:#fff
    style S fill:#c0c0c0,stroke:#333
    style G1 fill:#ffd700,stroke:#333
    style G2 fill:#ffd700,stroke:#333
    style G3 fill:#ffd700,stroke:#333
    style G4 fill:#ffd700,stroke:#333
```

---

## 9. Roadmap de Migração (Legado → Nova Versão)

```mermaid
gantt
    title Roadmap — Migração para Nova Versão Acto
    dateFormat YYYY-MM-DD
    axisFormat %d/%m

    section Concluído
    Token automático (nb_get_token_api)          :done, t1, 2026-04-24, 2026-04-27
    Bronze parametrizado (nb_bronze_acto_gestao)  :done, t2, 2026-04-24, 2026-04-27
    Orquestrador Bronze (4 fontes)               :done, t3, 2026-04-27, 2026-04-27
    Silver consolidado (union)                   :done, t4, 2026-04-27, 2026-04-28
    Gold CET + SEPREF (Santos)                   :done, t5, 2026-04-23, 2026-04-28
    Gold CRAS + SETRE (Osasco)                   :done, t6, 2026-04-27, 2026-04-29
    Pipeline pl_ingest_acto                      :done, t7, 2026-04-28, 2026-05-01

    section Em andamento
    Descomentar saveAsTable (Gold CET/SEPREF)    :active, t8, 2026-05-01, 2026-05-03
    Completar _nb_gold_orquestracao              :active, t9, 2026-05-01, 2026-05-03
    Migrar credenciais para Key Vault            :active, t10, 2026-05-01, 2026-05-08

    section Próximos
    Migrar SEGOV Santos                          :        t11, 2026-05-05, 2026-05-08
    Migrar SEINFRA Santos                        :        t12, 2026-05-05, 2026-05-08
    Migrar Ouvidoria Santos                      :        t13, 2026-05-08, 2026-05-12
    Migrar Obras Santos                          :        t14, 2026-05-08, 2026-05-15
    Migrar Mauá (4 notebooks)                    :        t15, 2026-05-12, 2026-05-16
    Desativar pipelines legados                  :        t16, 2026-05-16, 2026-05-20
```

---

## 10. Topologia de Lakehouses

```mermaid
graph TB
    subgraph "Workspace: Acto Cidade Inteligente"
        subgraph "NOVO"
            LH_ACTO["lh_solicitacoes_acto<br/>━━━━━━━━━━━━━<br/>Bronze: fato_* por fonte<br/>Silver: fato_* consolidado<br/>Gold: por domínio<br/>Files: payloads/*.json"]
        end

        subgraph "LEGADO (ainda ativo)"
            LH_SANTOS["lh_cidade_inteligente_santos<br/>━━━━━━━━━━━━━<br/>gold_cet_servicos<br/>gold_segov_servicos<br/>gold_obras_*<br/>...37 notebooks"]
            LH_OSASCO["lh_cidade_inteligente_osasco<br/>━━━━━━━━━━━━━<br/>...31 notebooks"]
            LH_MAUA["lh_cidade_inteligente_maua<br/>━━━━━━━━━━━━━<br/>...4 notebooks"]
        end

        subgraph "DADOS PÚBLICOS"
            LH_PUB["lh_dados_publicos<br/>━━━━━━━━━━━━━<br/>IBGE/SIDRA + RAIS + CAGED"]
        end
    end

    LH_ACTO -.->|"substitui gradualmente"| LH_SANTOS
    LH_ACTO -.->|"substitui gradualmente"| LH_OSASCO
    LH_ACTO -.->|"substitui gradualmente"| LH_MAUA

    style LH_ACTO fill:#4CAF50,stroke:#333,color:#fff
    style LH_SANTOS fill:#FF9800,stroke:#333,color:#fff
    style LH_OSASCO fill:#FF9800,stroke:#333,color:#fff
    style LH_MAUA fill:#FF9800,stroke:#333,color:#fff
    style LH_PUB fill:#2196F3,stroke:#333,color:#fff
```
