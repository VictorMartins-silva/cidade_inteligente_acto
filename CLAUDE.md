# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Context

This is a **Microsoft Fabric / PySpark** data engineering project for the **Município de Santos** (Acto Cidade Inteligente). All notebooks run inside a Fabric workspace (`lh_cidade_inteligente_santos`, Workspace ID: `96fe5a53-3a22-4443-8d0a-e2f6d61a2690`). There are no build or test commands — code is developed locally as `.ipynb` files and deployed to Fabric manually.

## Architecture — Medallion (Bronze → Silver → Gold)

```
Fonte (Acto API / CSV)
    ↓ Data Factory
  Bronze  (Delta Tables — payload bruto)
    ↓ PySpark/Python
  Silver  (limpeza, tipagem, normalização, SCD Type 2)
    ↓ PySpark/SQL
  Gold    (dimensões, fatos, indicadores — consumo Power BI)
    ↓
  Power BI (DAX mínimo — lógica de negócio fica no Gold)
```

All data lands in `lh_cidade_inteligente_santos`. Files/auxiliary tables use ABFSS paths:
`abfss://96fe5a53-3a22-4443-8d0a-e2f6d61a2690@onelake.dfs.fabric.microsoft.com/<item-id>/Files/...`

## Notebook Naming Convention

`nb_{camada}_{municipio}_{dominio}` — e.g., `nb_gold_santos_avaliacao`

- Camada values: `ingest`, `bronze`, `silver`, `gold`, `utils`
- Known violation: `gold_curso_motorista` (missing `nb_` prefix and municipality) — should be renamed to `nb_gold_santos_curso_motorista`

## Key Utility Notebooks (used via `%run`)

| Notebook | Role |
|---|---|
| `nb_utils_api_acto_gestao` | Central API client — `fetch_tabela()`, `adicionar_etapa_atual()`, `harmonizar_nome_bairros()`, `ajustar_nome_colunas()` |
| `nb_utils_api_acto_gestao_obras` | API client for obras (dynamic login) |
| `nb_utils_ingest_acto_gestao` | Extraction utilities — **no try/except** (active risk R7) |
| `carta_servicos/gestao_prazo_sla/config_api_acto_atualizado` | Multi-municipality token config |

## Known Active Issues (do not ignore)

- **R5 — CRITICAL:** `nb_ingest_silver_acto_gestao_obras_santos` has been getting HTTP 401 since 11/03/2025. The obras pipeline (Gold obras, Gold etapas, SEONT, 4 PBI reports) is entirely stopped. Fix: add `try/except HTTPError 401 → login_acto_gestao_obras() → retry` in `nb_utils_api_acto_gestao_obras`.
- **R9 — CRITICAL:** `nb_ingest_caged_santos` has `CODIGO_OSASCO = 353440` hardcoded instead of `CODIGO_SANTOS = 353845`. Do not activate this notebook until corrected.
- **R7:** `nb_utils_ingest_acto_gestao` calls `raise_for_status()` directly without `try/except`. API failures propagate silently to `avaliacao_servicos` and `curso_motoristas` chains.
- **R3:** `nb_gold_santos_avaliacao` uses `overwrite`; `nb_gold_santos_avaliacao_sentimento` uses `append`. If Gold base is rewritten and sentimento fails, IDs become silently misaligned.
- **R4:** Several notebooks write DataFrames without rowcount assertions before `to_parquet()`/`saveAsTable()`. Reference correct pattern: `nb_silver_santos_curso_motoristas` uses `assert len(df) > threshold`.

## Two Conflicting Payload Formats — `adicionar_etapa_atual` vs `_2`

- `adicionar_etapa_atual()` expects column `'Nº Solicitação|1'`
- `adicionar_etapa_atual_2()` expects column `'Nº Solicitação'`
- Which endpoint returns which format is not documented. When modifying these functions, validate the input column name before joining.

## Auxiliary Files (Single Points of Failure — R1)

These files are Excel/CSV — a path change silently breaks pipelines:

| File | Used in |
|---|---|
| `Files/acto/tb_aux.xlsx` (sheets: `aux_prazo`, `aux_regionais`) | `nb_ingest_acto_santos`, `nb_utils_api_acto_gestao` |
| `PMS_AuxiliarPDR.xlsx` | `nb_gold_acto_gestao_obras` |
| `raw_cadastro_carta/*.csv` | `nb_ingest_carta_servicos_santos` |

Planned migration: replace all with Delta Tables in the Lakehouse.

## Duplicated Functions (R2)

`ajustar_nome_colunas()`, `harmonizar_nome_bairros()`, and `mapa_bairros` appear in multiple notebooks. The planned fix is creating `nb_utils_shared` and replacing duplicates with `%run ./nb_utils_shared`. When editing these functions, update all occurrences.

## SCD Type 2 — Carta de Serviços / SLA (New Scope)

The SLA join **must** use `dt_abertura` between `dt_inicio_vigencia` and `dt_fim_vigencia`. Never join only on `is_atual = True` — that applies the current deadline to all historical requests, corrupting retrospective indicators.

```sql
LEFT JOIN gold_dim_cartas_servico_vigencia d
    ON  s.id_servico   = d.id_servico
    AND s.dt_abertura >= d.dt_inicio_vigencia
    AND s.dt_abertura  < d.dt_fim_vigencia
```

CSV source: `exportar_4.csv` is canonical (693 records, delimiter `;`, UTF-8 BOM). Discard `cadastro_carta_de_servico.csv` — identical content, duplicate source.

## Pipeline Standard

Most pipelines follow: `Notebook Gold → RefreshSqlEndpoint → Refresh modelo PBI`. The exception is `pl_ingest_obras_santos` (9 activities): Silver → Gold obras + Gold etapas (parallel) → RefreshSqlEndpoint → 4× PBI refresh in parallel.

Notebooks without any identified pipeline (manual execution only): `nb_gold_acto_gestao_obras_seont_os`, `nb_ingest_estrutura_cet`.

---

## Ver Também

- [[_mapa-do-vault]] — índice geral do vault
- [[Conhecimento/Fabric/fabric-workspace-acto-cidade-inteligente|fabric-workspace-acto-cidade-inteligente]] — workspace completo Acto Cidade Inteligente
- [[Conhecimento/Fabric/pipeline-acto-santos-fabric|pipeline-acto-santos-fabric]] — fluxo Data Factory + notebooks
- [[Projetos/acto-santos-pipeline]] — projeto ACTO Santos


### Arquitetura Modular (Master-Sub)

O esquema abaixo demonstra como a **Pipeline Mestre** atua como um orquestrador central, delegando a execução para sub-pipelines independentes. Isso remove a poluição visual e permite que cada domínio (SSP, IBGE, CAGED) tenha seu próprio ciclo de vida.

---

### 🔄 Comparativo de Fluxo

|Elemento|Como é hoje (Monólito)|Como ficaria (Desacoplado)|
|---|---|---|
|**Visão Geral**|Uma única pipeline com 4 blocos `If` gigantes.|Uma pipeline mestre com 4 ícones de `Invoke Pipeline`.|
|**Passagem de Dados**|`Activity('Checar Fontes').output` direto no `If`.|Parâmetros passados via `@json()` para a sub-pipeline.|
|**Controle de Erro**|Se um `If` trava, a visualização do erro é misturada.|Se o SSP falha, a sub-pipeline de SSP fica vermelha, a Mestre segue.|
|**Reprocessamento**|Requer rodar tudo ou forçar parâmetros na Mestre.|Você abre a `pl_ingest_caged` e roda apenas ela.|

---

### 📝 Resumo Técnico da Mudança

1. **Pipeline Mestre (`pl_monitoramento_master`):**
    - Contém apenas o notebook `Checar Fontes`.
    - Invoca as sub-pipelines em paralelo.
    - Finaliza com o `nb_atualizar_status_painel` (lendo os logs do Lakehouse).
2. **Sub-Pipelines (ex: `pl_ingest_ssp`):**
    - Recebem parâmetros como `ANO`, `CONSULTA_ID` e `NOVO_DADO`.
    - Contêm a lógica interna: `If (NOVO_DADO) -> Ingestão -> Gold`.
    - Podem ser agendadas ou disparadas isoladamente.