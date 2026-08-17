---
title: "Spec Drive — Semana 25/05/2026"
tags:
  - tipo/spec
  - tema/obras
  - tema/migracao
  - tema/santos
revisao: "2026-05-25"
---

# Spec Drive — Semana 25/05/2026 · Migração Obras Santos + Novo Painel

**Contexto geral:** Semana focada em obras. A fonte `santos_obras` já está ativa no Bronze/Silver do novo modelo (`lh_solicitacoes_acto`). O que falta é consertar a Gold existente, criar os notebooks que faltam e, por último, construir o novo painel solicitado pela Kelly (OS #962592). A sequência responde ao problema visível no Fabric hoje: `gold.santos_obras` com 94 colunas e praticamente tudo NULL.

---

## 📍 Estado Atual (25/05/2026)

| Tabela / Notebook | Status | Problema |
|---|---|---|
| `silver.fato_solicitacoes` (santos_obras) | ✅ 11.729 OS | `servico` e `data_criacao` **NULL** em todas as linhas |
| `silver.fato_etapas` (santos_obras) | ✅ 91.003 etapas | OK |
| `silver.fato_campos` (santos_obras) | ✅ 54.504 campos | OK |
| `gold.santos_obras` | ⚠️ Existe, 94 cols | NULLs generalizados — ver Bloco 0 |
| `gold.obras_acompanhamentos_os` | ❌ Não existe | Notebook criado mas não rodado ainda |
| `gold.obras_tempo_etapa` | ❌ Não existe | Notebook não criado |
| `gold.obras_seont_os` | ❌ Não existe | Notebook não criado |
| Pipeline obras no `pl_ingest_acto` | ❌ Fora | Nenhum Gold de obras no orquestrador |
| 4 painéis PBI de obras | 🔴 Parados | Dados congelados desde 11/03/2025 |

---

## 🔴 Bloco 0 — Diagnosticar e corrigir `gold.santos_obras`

> **Sintoma observado:** `gold.santos_obras` tem 1.000+ linhas, mas `servico` e `data_criacao` são NULL em todas. As 82 colunas EAV pivotadas também estão quase 100% NULL.

### 0.1 — Investigar `servico` NULL no Silver

O campo `servico` em `silver.fato_solicitacoes` para `santos_obras` está NULL. Provável causa: a API de Obras retorna o nome do serviço como campo EAV (em `fato_campos`), não no cabeçalho padrão da solicitação. Confirmar no Fabric:

```python
# Checar servico na Silver de solicitacoes
from pyspark.sql.functions import col

display(
    spark.table("silver.fato_solicitacoes")
    .filter(col("fonte") == "santos_obras")
    .select("id_os", "servico", "data_criacao", "status_fluxo")
    .limit(20)
)

# Checar se servico aparece nos campos EAV
display(
    spark.table("silver.fato_campos")
    .filter(col("fonte") == "santos_obras")
    .filter(col("campo").rlike("(?i)(servic|nomeservico|tipo)"))
    .groupBy("campo", "valor")
    .count()
    .orderBy(col("count").desc())
    .limit(30)
)
```

- [ ] **0.1** Confirmar se `servico` está NULL em `silver.fato_solicitacoes` para todos os obras
- [ ] **0.2** Identificar em qual campo EAV (`fato_campos`) o nome do serviço aparece
- [ ] **0.3** Confirmar se `data_criacao` também está NULL — pode ser mesma causa

### 0.2 — Corrigir `nb_gold_santos_obras`

Com base no diagnóstico:

- [ ] **0.4** Se `servico` vier do EAV: adicionar ao pivot de `fato_campos` o campo identificado e usar como `servico` no Gold
- [ ] **0.5** Remover da lista `CAMPOS` os 5 campos de etapa (`etapasdatacriacao`, `etapasdataexefim`, `etapasetapa`, `etapasexecutor`, `etapasstatus`) — estes vêm de `fato_etapas`, não do EAV
- [ ] **0.6** Corrigir o join de `etapa_atual`: substituir `spark_max("etapa")` (alfabético) por `spark_max` por `data_inicio_etapa DESC` (última etapa por data)
- [ ] **0.7** Executar notebook e confirmar:
  - `servico` preenchido para a maioria das OS
  - `data_criacao` populada
  - Colunas `etapas*` ausentes do schema final
  - Rowcount > 11.000

---

## 🟡 Bloco 1 — Conectar `nb_gold_santos_obras_acompanhamento` ao Orquestrador

> Notebook já existe e está funcional. Só falta o `%run`.

- [ ] **1.1** Em `_nb_gold_orquestracao.ipynb`, adicionar:
  ```python
  %run ./nb_gold_santos_obras_acompanhamento
  ```
- [ ] **1.2** Rodar o orquestrador completo — confirmar que `gold.obras_acompanhamentos_os` é criada (~11.300 OS)
- [ ] **1.3** Validar: `zona` preenchida ~44%, `bairro_consolidado` preenchido ~46%, `aux_setor_responsavel` ~94%

> [!note] Taxa de bairro baixa
> 54% das OS de obras não têm bairro — comportamento herdado do legado. Serviços de inscrição de profissional não têm endereço. Ver `zona_aplicavel`.

---

## 🟡 Bloco 2 — Adicionar `zona_aplicavel` e `analista_responsavel`

Dois campos faltando em `nb_gold_santos_obras_acompanhamento`:

- [ ] **2.1** Adicionar `zona_aplicavel`: 0 para os 5 serviços sem endereço físico (inscrição/renovação de profissional, providência)
- [ ] **2.2** Adicionar `analista_responsavel` via EAV — campo `"esta solicitacao devera ser analisada por"`:
  ```python
  df_analista = (
      spark.table("silver.fato_campos")
      .filter(col("fonte") == FONTE)
      .filter(col("campo").rlike("(?i)esta solicitacao devera ser analisada"))
      .groupBy("id_os")
      .agg(first("valor").alias("analista_responsavel"))
  )
  ```
- [ ] **2.3** Esperado: ~3–5% preenchido (só após distribuição pela chefia SEONT). Comportamento normal.
- [ ] **2.4** Re-rodar notebook e confirmar schema atualizado

---

## 🟡 Bloco 3 — Criar `nb_gold_santos_obras_tempo_etapa`

Porta o legado `nb_gold_acto_gestao_obras_etapas` para a nova arquitetura Silver EAV. Grain: **OS × Etapa** (91.003 linhas esperadas).

```python
FONTE = "santos_obras"
AUX_PATH = "/lakehouse/default/Files/acto/PMS_AuxiliarPDR.xlsx"

# Carregar Silver etapas
df_etapas = (
    spark.table("silver.fato_etapas")
    .filter(col("fonte") == FONTE)
    .withColumn("duracao_dias_preciso",
        datediff(col("data_fim_etapa"), col("data_inicio_etapa")).cast("float"))
    .withColumn("duracao_dias_int",
        col("duracao_dias_preciso").cast("int"))
)

# Merge AuxiliarPDR — aux_setor_responsavel e aux_pdr por etapa
aux_etapas = spark.createDataFrame(pd.read_excel(AUX_PATH, sheet_name="Etapas"))
df_gold = df_etapas.join(aux_etapas, df_etapas.etapa == aux_etapas.etapa_pad, "left")

assert df_gold.count() > 80_000, "Volume abaixo do esperado"
df_gold.write.mode("overwrite").format("delta").saveAsTable("gold.obras_tempo_etapa")
```

- [ ] **3.1** Criar notebook `nb_gold_santos_obras_tempo_etapa.ipynb` com o código acima
- [ ] **3.2** Executar e confirmar rowcount ~91.003 (vs 71.500 do legado — novo modelo tem mais dados)
- [ ] **3.3** Adicionar `%run ./nb_gold_santos_obras_tempo_etapa` no orquestrador

---

## 🟡 Bloco 4 — Criar `nb_gold_santos_obras_seont`

Deriva de `gold.obras_acompanhamentos_os` com lógica SEONT. Portado do legado `nb_gold_acto_gestao_obras_seont_os`.

```python
SETORES_SEONT = {"SEONT", "SEONT-Chefia", "SEONT-Chefia (D.O)", "SEONT CHEFIA"}

df_seont = (
    spark.table("gold.obras_acompanhamentos_os")
    .filter(col("aux_setor_responsavel").isin(SETORES_SEONT))
    .withColumn("flag_seont", lit(1))
    .withColumn("executor_responsavel",
        when(col("executor_atual").isNotNull(), col("executor_atual"))
        .otherwise(col("analista_responsavel")))
    .withColumn("flag_etapa_aprov",
        when(upper(col("etapa_atual")).contains("ANALISADA POR"), 1).otherwise(0).cast("int"))
)

assert df_seont.count() > 200
df_seont.write.mode("overwrite").format("delta").saveAsTable("gold.obras_seont_os")
```

- [ ] **4.1** Criar `nb_gold_santos_obras_seont.ipynb`
- [ ] **4.2** Executar — esperado ~250–300 OS (vs 202 no legado — mais dados no novo Silver)
- [ ] **4.3** Adicionar `%run ./nb_gold_santos_obras_seont` no orquestrador **após** `nb_gold_santos_obras_acompanhamento`

---

## 🔵 Bloco 5 — Pipeline + Reconexão PBI

Com todos os Golds de obras funcionando, conectar ao pipeline e reconectar os 4 painéis.

- [ ] **5.1** No `pl_ingest_acto`, adicionar refresh dos 4 painéis de obras **após** o `RefreshSqlEndpoint` existente:
  - `pbi_obras_santos_acomp_solicitacoes`
  - `pbi_obras_santos_seman_acomp_solicitacoes`
  - `pbi_obras_santos_pdr`
  - `pbi_santos_obras_seont_os`
- [ ] **5.2** Reconectar cada painel PBI à nova tabela (`gold.obras_*` no `lh_solicitacoes_acto`) — validar com Jorge/Kelly que o schema é compatível
- [ ] **5.3** Rodar pipeline ponta a ponta — confirmar execução completa sem erros

---

## 🟢 Bloco 6 — [ÚLTIMO] Novo Painel: Aprovações por Bairro, Etapa e Pavimento

> OS #962592 · Kelly Araujo Simões · Criticidade: Média

Só inicia após Blocos 0–5 estarem concluídos e pipeline funcionando.

Spec detalhada: [[SPEC_DRIVE_PAINEL_OBRAS_PAVIMENTOS]]

Passos resumidos:
- [ ] **6.1** Explorar Silver EAV para confirmar campos de `pavimentos` e `area` (script na spec)
- [ ] **6.2** Criar `nb_gold_santos_obras_pavimentos` — grain OS × Etapa, com bairro + zona + pavimentos + area
- [ ] **6.3** Adicionar ao orquestrador
- [ ] **6.4** Criar painel PBI com matriz bairro × ano, slicers de etapa/serviço/pavimentos e `DISTINCTCOUNT(id_os)`
- [ ] **6.5** Validar com Kelly o exemplo: empreendimentos > 10 pav aprovados por bairro 2023–2026

---

## 📅 Planejamento da Semana (25–30/05/2026)

| Dia | Tarefa | Bloco | Prioridade |
|---|---|---|---|
| Seg 25/05 | Diagnóstico `servico` NULL no Silver de obras | B0.1–0.3 | 🔴 Alta |
| Seg 25/05 | Corrigir `nb_gold_santos_obras` + validar | B0.4–0.7 | 🔴 Alta |
| Ter 26/05 | Conectar `acompanhamentos_os` ao orquestrador + validar | B1 | 🔴 Alta |
| Ter 26/05 | Adicionar `zona_aplicavel` e `analista_responsavel` | B2 | 🟡 Média |
| Qua 27/05 | Criar e validar `nb_gold_santos_obras_tempo_etapa` | B3 | 🟡 Média |
| Qua 27/05 | Criar e validar `nb_gold_santos_obras_seont` | B4 | 🟡 Média |
| Qui 28/05 | Pipeline ponta a ponta + reconexão PBI (4 painéis) | B5 | 🔴 Alta |
| Sex 29/05 | Exploração campos EAV (pavimentos, area) + Gold novo | B6.1–6.3 | 🟢 Normal |
| Sex 29/05 | Painel PBI novo — protótipo visual | B6.4 | 🟢 Normal |

---

## ⚠️ Riscos da Semana

| Risco | Impacto | Mitigação |
|---|---|---|
| `servico` NULL no Silver pode ser problema de ingestão (Bronze → Silver) | Bloquearia todos os Golds de obras | Investigar Bloco 0 antes de qualquer outra coisa |
| `PMS_AuxiliarPDR.xlsx` no novo LH pode não existir ainda | Quebra `obras_acompanhamentos_os` e `tempo_etapa` | `os.path.exists()` antes de rodar; se ausente, copiar o arquivo |
| Reconexão PBI exige validação de schema com Jorge/Kelly | Pode gerar retrabalho se schema não bate | Fazer comparação de colunas antes de reconectar |
| Campos `pavimentos` e `area` podem não existir no EAV de obras | Bloco 6 fica inviável sem eles | Exploração no B6.1 é go/no-go para o novo painel |

---

## 🔗 Referências

- [[SPEC_DRIVE_MIGRACAO_OBRAS]] — plano detalhado de migração (8 blocos) — código completo
- [[SPEC_DRIVE_PAINEL_OBRAS_PAVIMENTOS]] — spec do novo painel (OS #962592)
- [[DOCUMENTACAO_TECNICA_ACTO]] — arquitetura do novo módulo Acto
- [[SCHEMA_LAKEHOUSE_ACTO]] — schema de todas as tabelas Silver/Gold

---

*Spec Drive · Acto Cidade Inteligente · Criado em 25/05/2026*
