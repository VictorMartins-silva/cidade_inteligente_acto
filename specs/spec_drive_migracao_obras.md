---
title: "Spec Drive — Migração Obras Santos → Módulo Acto"
tags:
  - tipo/spec-drive
  - tema/migracao
  - tema/obras
  - tema/santos
status: ativo
revisao: "2026-05-21"
---

# Spec Drive — Migração Obras Santos → Módulo Acto

> **Escopo:** Migrar os 4 painéis de Obras Santos (`gold_pdr_acompanhamentos_os`, `gold_obras_tempo_etapa`, `gold_obras_seont_os`) do lakehouse legado `lh_cidade_inteligente_santos` para o novo módulo Acto (`lh_solicitacoes_acto`)  
> **Pipeline de destino:** `pl_ingest_acto`  
> **Fonte:** `santos_obras` — já ativa no Bronze/Silver (`TOKEN_SANTOS_OBRAS`)  
> **Atualizado:** 2026-05-21

---

## Contexto

O pipeline legado de Obras (`pl_ingest_obras_santos`, 9 atividades) está parado desde **11/03/2025** por HTTP 401 (`TOKEN_SANTOS_OBRAS`). Os 4 painéis PBI de obras estão com dados congelados. A fonte `santos_obras` já foi migrada para a nova arquitetura EAV — Bronze e Silver estão populados no novo módulo. O que falta é a camada Gold e a reconexão dos painéis.

### Mapeamento legado → novo

| Tabela legada (`lh_cidade_inteligente_santos`) | Tabela nova (`lh_solicitacoes_acto`) | Notebook novo |
|---|---|---|
| `gold_pdr_acompanhamentos_os` (~10.300 OS) | `gold.obras_acompanhamentos_os` | `nb_gold_santos_obras_acompanhamento` ✅ criado |
| `gold_obras_tempo_etapa` (~71.500 etapas) | `gold.obras_tempo_etapa` | `nb_gold_santos_obras_tempo_etapa` ❌ falta criar |
| `gold_obras_seont_os` (~263 OS) | `gold.obras_seont_os` | `nb_gold_santos_obras_seont` ❌ falta criar |
| — (sem equivalente) | `gold.fato_solicitacoes_obras` | `nb_gold_santos_obras` ✅ ativo |

### O que simplifica com o modelo EAV

| Regra legada | Complexidade legada | Nova arquitetura |
|---|---|---|
| bfill horizontal de ~375 colunas | `df.bfill(axis=1)` em pandas | **Eliminada** — `fato_campos` já tem 1 linha/campo |
| Consolidação de colunas duplicadas | `consolidar_colunas_duplicadas()` em 375 cols | **Eliminada** — Silver normaliza na ingestão |
| Strip de sufixos `\|N` das colunas | Regex em 375 colunas | **Eliminada** — `clean_col_name()` na Silver |
| 11 colunas "Esta solicitação deverá ser analisada por" → bfill → analista | bfill + drop_duplicates | `fato_campos WHERE campo LIKE 'Esta solicitacao%'` → `first("valor")` |
| flag_etapa_aprov (28 variantes de "ANALISADA POR") | 28 strings normalizadas via NFD | `fato_etapas WHERE etapa LIKE '%ANALISADA POR%'` |
| bairro_consolidado — coalesce de N colunas laterais | coalesce de colunas com nomes variáveis | `fato_campos WHERE campo = 'Bairro'` → `first("valor")` |

### Risco ativo na migração

> **R1 — PMS_AuxiliarPDR.xlsx:** `nb_gold_santos_obras_acompanhamento` ainda usa `pd.read_excel()` para mapear bairro→zona e etapa→aux_setor_responsavel. Esse arquivo é ponto único de falha. A Etapa 3 deste spec elimina esse risco.

---

## Estado Atual dos Notebooks de Obras

| Notebook | Tabela | Status |
|---|---|---|
| `nb_gold_santos_obras` | `gold.fato_solicitacoes_obras` | ✅ Ativo, 82 campos EAV pivotados — tem problema (ver Bloco 0) |
| `nb_gold_santos_obras_acompanhamento` | `gold.obras_acompanhamentos_os` | ✅ Criado e funcional — ❌ **ausente do orquestrador** |
| `nb_gold_santos_obras_seont` | `gold.obras_seont_os` | ❌ Não existe |
| `nb_gold_santos_obras_tempo_etapa` | `gold.obras_tempo_etapa` | ❌ Não existe |

---

## Bloco 0 — Corrigir `nb_gold_santos_obras` (problema atual)

O notebook atual inclui na lista `CAMPOS` os campos `etapasdatacriacao`, `etapasdataexefim`, `etapasetapa`, `etapasexecutor`, `etapasstatus` — campos de etapa que eram retornados pela API como EAV mas que agora existem estruturados em `silver.fato_etapas`. São redundantes. O join de etapa com `spark_max("etapa")` também está errado (max alfabético, não por data).

`gold.fato_solicitacoes_obras` deve ser uma tabela de referência pura (campos legais, CNPJ, logradouro, profissional). A lógica de etapa fica em `obras_acompanhamentos_os`.

- [ ] **0.1** Em `nb_gold_santos_obras`, remover da lista `CAMPOS` os 5 campos: `etapasdatacriacao`, `etapasdataexefim`, `etapasetapa`, `etapasexecutor`, `etapasstatus`
- [ ] **0.2** Remover o bloco de join com `df_etapas` (o que usa `spark_max("etapa")`)
- [ ] **0.3** Executar o notebook manualmente e confirmar que `gold.fato_solicitacoes_obras` é criada sem erros
- [ ] **0.4** Verificar rowcount > 0 e que as colunas `etapas*` sumiram do schema

---

## Bloco 1 — Conectar `obras_acompanhamentos_os` ao Orquestrador

> **Risco:** zero. O notebook existe e está funcional. Esta tarefa só adiciona o `%run`.

- [ ] **1.1** Em `nbs/nbs_gold/_nb_gold_orquestracao.ipynb`, adicionar após `%run ./nb_gold_santos_obras`:
  ```python
  %run ./nb_gold_santos_obras_acompanhamento
  ```
- [ ] **1.2** Executar `_nb_gold_orquestracao` completo e confirmar que `gold.obras_acompanhamentos_os` é criada/atualizada sem erro
- [ ] **1.3** Verificar no log: rowcount ~10.300 OS, zona preenchida ~94%, aux_setor_responsavel ~94%

> [!note] `nb_gold_santos_obras_acompanhamento` lê de `silver.fato_solicitacoes`, `silver.fato_campos` e `silver.fato_etapas` — independente de `fato_solicitacoes_obras`. Pode rodar em paralelo, mas `%run` é sequencial por design.

---

## Bloco 2 — Corrigir `zona_aplicavel` e adicionar `analista_responsavel`

Duas pendências em `nb_gold_santos_obras_acompanhamento`:
1. `zona_aplicavel` está hardcoded como `1` — 5 serviços sem relevância geográfica precisam receber `0`
2. `analista_responsavel` não está na tabela — necessário para o painel SEONT e para o executor_responsavel cascade

- [ ] **2.1** Em `nb_gold_santos_obras_acompanhamento`, na célula de colunas calculadas, substituir `zona_aplicavel = lit(1)` por:
  ```python
  SERVICOS_SEM_ZONA = {
      "INSCRIÇÃO DE PESSOA FÍSICA",
      "INSCRIÇÃO DE PESSOA JURÍDICA",
      "RENOVAÇÃO DE PESSOA FÍSICA",
      "RENOVAÇÃO DE PESSOA JURÍDICA",
      "PROVIDÊNCIA",
  }
  df_gold = df_gold.withColumn(
      "zona_aplicavel",
      F.when(
          normalizar_udf(F.col("servico")).isin([normalizar(s) for s in SERVICOS_SEM_ZONA]),
          F.lit(0)
      ).otherwise(F.lit(1)).cast("int")
  )
  ```
- [ ] **2.2** Adicionar leitura de `analista_responsavel` via EAV (após o bloco de campos `fato_campos`):
  ```python
  df_analista = (
      spark.table("silver.fato_campos")
      .filter(F.col("fonte") == FONTE)
      .filter(F.col("campo").rlike("(?i)esta solicitacao devera ser analisada"))
      .groupBy("id_os")
      .agg(F.first("valor").alias("analista_responsavel"))
  )
  ```
- [ ] **2.3** Adicionar o join `df_gold = df_gold.join(df_analista, "id_os", "left")` no bloco de joins principais
- [ ] **2.4** Adicionar `"analista_responsavel"` na lista `COLUNAS_FINAIS`
- [ ] **2.5** Adicionar linha na célula de validação:
  ```python
  n_analista = df_gold.filter(F.col("analista_responsavel").isNotNull()).count()
  print(f"analista_responsavel:      {n_analista:,} ({n_analista/n_total*100:.1f}%)")
  ```
  > Esperado: ~3–5% de preenchimento. Comportamento normal — campo preenchido só pós-distribuição pela chefia SEONT.
- [ ] **2.6** Executar o notebook e confirmar que a tabela atualiza com as duas novas colunas

---

## Bloco 3 — Migrar PMS_AuxiliarPDR.xlsx → Delta Tables (elimina R1)

O `pd.read_excel()` é ponto único de falha. Este bloco cria duas Delta Tables no lakehouse e atualiza o notebook para lê-las.

- [ ] **3.1** Criar notebook `nb_ingest_obras_aux_pdr` em `nbs/nbs_gold/`:
  ```python
  import pandas as pd

  AUX_PDR_PATH = "/lakehouse/default/Files/acto/PMS_AuxiliarPDR.xlsx"

  # Sheet Zona_Bairros → gold.dim_pdr_zonas_bairros
  df_zonas = pd.read_excel(AUX_PDR_PATH, sheet_name="Zona_Bairros")
  spark.createDataFrame(df_zonas).write.mode("overwrite").format("delta").saveAsTable("gold.dim_pdr_zonas_bairros")

  # Sheet Etapas → gold.dim_pdr_etapas_setor
  df_etapas = pd.read_excel(AUX_PDR_PATH, sheet_name="Etapas")
  spark.createDataFrame(df_etapas).write.mode("overwrite").format("delta").saveAsTable("gold.dim_pdr_etapas_setor")
  ```
- [ ] **3.2** Executar `nb_ingest_obras_aux_pdr` manualmente e confirmar:
  - `gold.dim_pdr_zonas_bairros`: ~122 registros, colunas `bairro_norm` e `zona`
  - `gold.dim_pdr_etapas_setor`: ~185 registros, colunas `etapa_norm` e `aux_setor_responsavel`
- [ ] **3.3** Em `nb_gold_santos_obras_acompanhamento`, substituir o bloco `aux-pdr` inteiro:
  ```python
  df_zona = spark.table("gold.dim_pdr_zonas_bairros")
  df_aux_etapas = spark.table("gold.dim_pdr_etapas_setor")
  ```
- [ ] **3.4** Executar `nb_gold_santos_obras_acompanhamento` e confirmar rowcounts idênticos
- [ ] **3.5** Adicionar `nb_ingest_obras_aux_pdr` ao `_nb_gold_orquestracao` **antes** de `nb_gold_santos_obras_acompanhamento`:
  ```python
  %run ./nb_ingest_obras_aux_pdr
  %run ./nb_gold_santos_obras_acompanhamento
  ```
  > [!warning] `nb_ingest_obras_aux_pdr` deve ser o primeiro notebook de obras — as demais dependem das dims.

---

## Bloco 4 — Criar `nb_gold_santos_obras_seont`

Deriva de `gold.obras_acompanhamentos_os`. Implementa toda a lógica SEONT: filtro de setores, flag_chefia, executor_responsavel cascade, flag_etapa_aprov.

- [ ] **4.1** Criar `nbs/nbs_gold/nb_gold_santos_obras_seont.ipynb` com os seguintes blocos:

  **Parâmetros:**
  ```python
  TABELA_ORIGEM = "gold.obras_acompanhamentos_os"
  TABELA_DESTINO = "gold.obras_seont_os"
  SETORES_SEONT = {"SEONT", "SEONT-Chefia", "SEONT-Chefia (D.O)", "SEONT CHEFIA"}
  SETORES_CHEFIA = {"SEONT-Chefia", "SEONT-Chefia (D.O)"}
  ```

  **Filtro e flags:**
  ```python
  df_seont = (
      spark.table(TABELA_ORIGEM)
      .filter(F.col("aux_setor_responsavel").isin(SETORES_SEONT))
      .withColumn("flag_chefia",
          F.when(F.col("aux_setor_responsavel").isin(SETORES_CHEFIA), 1).otherwise(0).cast("int")
      )
      .withColumn("executor_responsavel",
          F.when(F.col("executor_atual").isNotNull(), F.col("executor_atual"))
           .otherwise(F.col("analista_responsavel"))
      )
      .withColumn("flag_etapa_aprov",
          F.when(F.upper(F.col("etapa_atual")).contains("ANALISADA POR"), 1).otherwise(0).cast("int")
      )
  )
  ```

  **Schema final** (22 colunas):
  ```python
  COLUNAS_FINAIS = [
      "n_da_solicitacao", "servico", "status", "data_criacao", "data_finalizacao",
      "solicitante", "titulo_profissional", "etapa_atual", "executor_atual",
      "executor_responsavel", "analista_responsavel", "flag_multiplas_etapas",
      "aux_setor_responsavel", "flag_chefia", "flag_etapa_aprov",
      "data_etapa_inicio", "data_etapa_fim", "dias_na_etapa",
      "zona", "bairro_consolidado", "zona_aplicavel",
  ]
  ```

  **Validação antes do write:**
  ```python
  n_total = df_seont.count()
  assert n_total > 0, "gold.obras_seont_os vazio — verificar filtro SEONT"
  print(f"Total OS SEONT: {n_total}")  # Esperado: ~263
  ```

- [ ] **4.2** Executar manualmente e confirmar ~263 OS, executor_responsavel 100%, analista_responsavel ~4–5%
- [ ] **4.3** Adicionar ao `_nb_gold_orquestracao` **após** `nb_gold_santos_obras_acompanhamento`:
  ```python
  %run ./nb_gold_santos_obras_seont
  ```

---

## Bloco 5 — Criar `nb_gold_santos_obras_tempo_etapa`

Uma linha por etapa por OS. Alimenta o painel PDR I (produtividade por executor/setor).

- [ ] **5.1** Criar `nbs/nbs_gold/nb_gold_santos_obras_tempo_etapa.ipynb`:

  ```python
  FONTE = "santos_obras"
  TABELA_DESTINO = "gold.obras_tempo_etapa"

  df_etapas = (
      spark.table("silver.fato_etapas")
      .filter(F.col("fonte") == FONTE)
      .select("id_os", "etapa", "executor", "status", "data_inicio_etapa", "data_fim_etapa")
      .withColumn("duracao_dias_int",
          F.when(F.col("data_fim_etapa").isNotNull(),
              F.datediff(F.to_date("data_fim_etapa"), F.to_date("data_inicio_etapa"))
          ).otherwise(
              F.datediff(F.current_date(), F.to_date("data_inicio_etapa"))
          )
      )
  )

  normalizar_udf = F.udf(lambda s: unicodedata.normalize("NFD", str(s or "")).encode("ascii", "ignore").decode("ascii").upper().strip(), "string")

  df_aux = spark.table("gold.dim_pdr_etapas_setor")
  df_etapas = (
      df_etapas
      .withColumn("etapa_norm", normalizar_udf(F.col("etapa")))
      .join(df_aux, "etapa_norm", "left")
      .drop("etapa_norm")
  )

  df_sol = spark.table("silver.fato_solicitacoes").filter(F.col("fonte") == FONTE).select("id_os", "servico")
  df_etapas = df_etapas.join(df_sol, "id_os", "left")
  ```

  **Validação:**
  ```python
  n_total = df_etapas.count()
  assert n_total > 0, "gold.obras_tempo_etapa vazio"
  n_aux = df_etapas.filter(F.col("aux_setor_responsavel").isNotNull()).count()
  print(f"Total etapas:          {n_total:,}")  # Esperado: ~91.003 (novo) vs ~71.500 (legado)
  print(f"aux_setor_responsavel: {n_aux:,} ({n_aux/n_total*100:.1f}%)")  # Esperado: ~94%
  ```

- [ ] **5.2** Executar manualmente e confirmar rowcount > 70.000 etapas
- [ ] **5.3** Adicionar ao `_nb_gold_orquestracao` após `nb_ingest_obras_aux_pdr`

---

## Bloco 6 — Registrar Tabelas Novas no SQL Endpoint

- [ ] **6.1** Na 1ª execução após os Blocos 1–5, editar `pl_ingest_acto` → `"recreateTables": true`
- [ ] **6.2** Executar a pipeline completa
- [ ] **6.3** Confirmar 4 tabelas no SQL Endpoint: `obras_acompanhamentos_os`, `obras_seont_os`, `obras_tempo_etapa`, `fato_solicitacoes_obras`
- [ ] **6.4** Reverter `"recreateTables"` para `false`

---

## Bloco 7 — Reconectar os 4 Painéis Power BI

> [!warning] Validar compatibilidade de schema com Jorge antes de reconectar. Nomes de colunas mudaram (ex: `n_solicitacao` → `n_da_solicitacao`).

| Painel PBI | Tabela legada | Tabela nova | Responsável |
|---|---|---|---|
| Acomp. Solicitações — Obras | `gold_pdr_acompanhamentos_os` | `gold.obras_acompanhamentos_os` | Jorge |
| Acomp. Solicitações — SEMAN | `gold_pdr_acompanhamentos_os` (filtrado) | `gold.obras_acompanhamentos_os` | Jorge |
| PDR I — Produtividade | `gold_obras_tempo_etapa` | `gold.obras_tempo_etapa` | Jorge |
| SEONT — Analistas por Zona | `gold_obras_seont_os` | `gold.obras_seont_os` | Jorge |

- [ ] **7.1** Levantar schema atual de cada tabela legada (colunas, tipos)
- [ ] **7.2** Comparar com schema das novas tabelas — documentar diferenças
- [ ] **7.3** Para cada painel: redirecionar semantic model para `lh_solicitacoes_acto`
- [ ] **7.4** Ajustar medidas DAX com nomes alterados
- [ ] **7.5** Validar visualmente os 4 painéis
- [ ] **7.6** Adicionar 4 atividades `PBISemanticModelRefresh` na pipeline
- [ ] **7.7** Atualizar `pipelines/pl_inest_acto.json` local

---

## Bloco 8 — Validação End-to-End

- [ ] **8.1** Executar `pl_ingest_acto` completo — todas as atividades `Succeeded`
- [ ] **8.2** Rowcounts esperados: `obras_acompanhamentos_os` > 10k OS · `obras_tempo_etapa` > 70k etapas · `obras_seont_os` > 200 OS
- [ ] **8.3** Cobertura: `zona` > 90% · `aux_setor_responsavel` > 90% · `executor_responsavel` 100%
- [ ] **8.4** 4 painéis PBI atualizando automaticamente após pipeline
- [ ] **8.5** Desativar ou arquivar `pl_ingest_obras_santos`

---

## Ordem de execução final (`_nb_gold_orquestracao`)

```python
# Pré-requisito: dims auxiliares
%run ./nb_ingest_obras_aux_pdr           # Bloco 3

# Gold Obras (independentes entre si)
%run ./nb_gold_santos_obras              # Bloco 0 — referência
%run ./nb_gold_santos_obras_acompanhamento  # Blocos 1/2 — painel principal
%run ./nb_gold_santos_obras_tempo_etapa  # Bloco 5 — painel PDR

# Gold SEONT (depende de obras_acompanhamentos_os)
%run ./nb_gold_santos_obras_seont        # Bloco 4 — painel analistas
```

---

## Referências

- [[SPEC_DRIVE_OBRAS_MIGRACAO]] — diagnóstico técnico e schema de referência (versão anterior)
- [[SPEC_DRIVE_ROADMAP_MIGRACAO]] — spec geral migração Santos
- [[ESP_DRIVE_OS_MULTIPLAS_ETAPAS]] — análise do bug de múltiplas etapas
- [[f5_obras_paineis_funcionamento]] — documentação de negócio dos painéis
