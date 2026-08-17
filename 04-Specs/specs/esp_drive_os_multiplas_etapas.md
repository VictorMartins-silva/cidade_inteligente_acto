---
title: "ESP-Drive — OS com Múltiplas Etapas Ativas (Obras Santos)"
tags:
  - tipo/spec
  - tema/obras
  - tema/santos
  - bug
  - etapas
status: implementado (na migração EAV) — continuidade em andamento
revisao: "2026-07-17"
---

> [!important] Atualização 17/07/2026 — design implementado no módulo EAV novo, com continuidade
> O diagnóstico e as soluções propostas aqui (seção 3.1: não dropar etapas abertas, gerar N linhas por OS; 3.2: cascade de `executor_responsavel`; 3.5: `zona_aplicavel`) foram implementados no **módulo novo EAV** (`nb_gold_santos_obras_acompanhamento` e `nb_gold_santos_obras_seont`, `Acto Cidade Inteligente/Acto/`), não no pipeline legado que este documento original tinha como alvo — ver [[spec_drive_paridade_gold_obras]] (Bloco 2/3) para a implementação real e [[spec_drive_paridade_gold_obras]] Bloco 6 para uma investigação de continuidade (15-17/07/2026) que achou um caso adicional não coberto aqui: OS cuja etapa SEONT fecha de vez e sobra só uma etapa `Usuário`/`Sistema` — a OS "some" do painel SEONT porque não sobra nenhuma linha com `flag_seont=1`, não porque o filtro de exclusão erre. Esse caso ainda está em aberto (decisão de negócio pendente, ver Bloco 6.3 do spec de paridade).

# ESP-DRIVE — Obras Santos: Correções e Ajustes no Pipeline Fabric

**Projeto:** Painel de Acompanhamento de Obras — Prefeitura de Santos  
**Data:** 2026-04-08  
**Autor:** Victor Silva  
**Status:** Revisado pós-exploração das tabelas Gold

---

## 📊 OS sem zona — detalhamento por OS

| OS     | Serviço                                          | Etapa Atual                               | Setor Responsável  |
| ------ | ------------------------------------------------ | ----------------------------------------- | ------------------ |
| 454316 | INSCRIÇÃO DE PROFISSIONAL (PESSOA FÍSICA)        | REGISTRO DA PUBLICIDADE DO DIARIO OFICIAL | SEONT-Chefia (D.O) |
| 452424 | INSCRIÇÃO EMPRESA/PROFISSIONAL (PESSOA JURÍDICA) | REGISTRO DA PUBLICIDADE DO DIARIO OFICIAL | SEONT-Chefia (D.O) |
| 463659 | INSCRIÇÃO DE PROFISSIONAL (PESSOA FÍSICA)        | REGISTRO DA PUBLICIDADE DO DIARIO OFICIAL | SEONT-Chefia (D.O) |
| 463666 | INSCRIÇÃO DE PROFISSIONAL (PESSOA FÍSICA)        | REGISTRO DA PUBLICIDADE DO DIARIO OFICIAL | SEONT-Chefia (D.O) |
| 507267 | CONSTRUÇÃO NOVAS DE EDIFICAÇÕES - SOBREPOSTA     | REGISTRO DA PUBLICIDADE DO DIARIO OFICIAL | SEONT-Chefia (D.O) |
| 545587 | INSCRIÇÃO DE PROFISSIONAL (PESSOA FÍSICA)        | REGISTRO DA PUBLICIDADE DO DIARIO OFICIAL | SEONT-Chefia (D.O) |
| 675525 | INSCRIÇÃO DE PROFISSIONAL (PESSOA FÍSICA)        | REGISTRO DA PUBLICIDADE DO DIARIO OFICIAL | SEONT-Chefia (D.O) |
| 885986 | REFORMA E/OU LEGALIZAÇÃO                         | SEONT CHEFIA - DISTRIBUIÇÃO               | SEONT-Chefia       |
| 890492 | REFORMA E/OU LEGALIZAÇÃO                         | DELIBERAÇÃO SEONT                         | SEONT-Chefia       |
| 895994 | REFORMA E/OU LEGALIZAÇÃO                         | DELIBERAÇÃO SEONT                         | SEONT-Chefia       |
| 897551 | REFORMA E/OU LEGALIZAÇÃO                         | SEONT CHEFIA - DISTRIBUIÇÃO               | SEONT-Chefia       |
| 900438 | REFORMA E/OU LEGALIZAÇÃO                         | SEONT CHEFIA - DISTRIBUIÇÃO               | SEONT-Chefia       |
| 903053 | REFORMA E/OU LEGALIZAÇÃO                         | SEONT - PRÉ ANÁLISE TECNICA               | SEONT              |
| 903497 | REFORMA E/OU LEGALIZAÇÃO                         | DELIBERAÇÃO SEONT                         | SEONT-Chefia       |
| 907161 | REFORMA E/OU LEGALIZAÇÃO                         | SEONT CHEFIA - DISTRIBUIÇÃO               | SEONT-Chefia       |
| 916491 | REFORMA E/OU LEGALIZAÇÃO                         | SEONT CHEFIA - DISTRIBUIÇÃO               | SEONT-Chefia       |
| 916784 | REFORMA E/OU LEGALIZAÇÃO                         | SEONT CHEFIA - DISTRIBUIÇÃO               | SEONT-Chefia       |
| 917351 | PROVIDÊNCIA                                      | REGISTRO DA PUBLICIDADE DO DIARIO OFICIAL | SEONT-Chefia (D.O) |
| 926379 | REFORMA E/OU LEGALIZAÇÃO                         | SEONT - ANÁLISE TECNICA                   | SEONT              |

## 🔎 Observações

- Concentração relevante em:
    - **SEONT CHEFIA - DISTRIBUIÇÃO**
    - **REGISTRO DA PUBLICIDADE DO DIARIO OFICIAL**
- Indício de problema:
    - ausência de zona já na entrada do processo
    - ou falha antes das etapas técnicas

---

## 💡 Possível análise futura

- Verificar tempo parado por etapa sem zona
- Identificar origem da OS (quem abriu)
- Cruzar com SLA e atraso

## 1. Contexto do Projeto

### 1.1 Arquitetura do Pipeline

```
┌─────────────────────────────────────────────────────┐
│  Camada Bronze (API Externa)                        │
│  API Acto Gestão / Obras                            │
└────────────────────────┬────────────────────────────┘
                         │ Ingestão
┌────────────────────────▼────────────────────────────┐
│  Camada Silver (Parquet)                            │
│  nb_ingest_silver_acto_gestao_obras_santos          │
│  ├── silver_solicitacoes.parquet                    │
│  └── silver_etapas.parquet                         │
└────────────────────────┬────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────┐
│  Camada Gold (Delta Tables)                         │
│  nb_gold_acto_gestao_obras                          │
│  └── gold_pdr_acompanhamentos_os  ◄── TABELA BASE  │
│        ├── nb_gold_acto_gestao_obras_seont_os        │
│        │   └── gold_obras_seont_os                  │
│        └── nb_gold_acto_gestao_etapas               │
│            └── gold_obras_tempo_etapa               │
└────────────────────────┬────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────┐
│  Consumo e Visualização                             │
│  Refresh SQL Endpoint → Modelos Semânticos PBI      │
│  └── Dashboards / Relatórios                        │
└─────────────────────────────────────────────────────┘
```

### 1.2 Notebooks e Tabelas

| Notebook | Entrada | Saída | Consumidor |
|---|---|---|---|
| `nb_ingest_silver_acto_gestao_obras_santos` | API Acto Gestão | 2 Parquets (Silver) | Notebooks Gold |
| `nb_gold_acto_gestao_obras` | Silver + AuxiliarPDR.xlsx | `gold_pdr_acompanhamentos_os` | Gerência (todos os serviços/OS) |
| `nb_gold_acto_gestao_obras_seont_os` | `gold_pdr_acompanhamentos_os` + Silver | `gold_obras_seont_os` | Painel SEONT |
| `nb_gold_acto_gestao_etapas` | Silver + API (por OS) | `gold_obras_tempo_etapa` | Painel tempo por etapa |

### 1.3 Estado Atual das Tabelas Gold (exploração 2026-04-08)

#### `gold_pdr_acompanhamentos_os` — 18 colunas, ~10.954 linhas

| Status | Linhas |
|---|---|
| Finalizado | 6.964 |
| Em atendimento | 2.604 |
| Cancelado | 1.112 |
| Pendente atendimento | 274 |

Principais nulos: `Executor` 99%, `Etapa` 99%, `titulo_profissional` 82,5%, `zona` 56,5%, `bairro_consolidado` 54,6%.

#### `gold_obras_seont_os` — 20 colunas, 202 OS

| Etapa | Total |
|---|---|
| REGISTRO DA PUBLICIDADE DO DIARIO OFICIAL | 67 |
| SEONT - ANÁLISE TECNICA - CONFERÊNCIA DOS DADOS | 60 |
| DELIBERAÇÃO SEONT | 37 |
| SEONT CHEFIA - DISTRIBUIÇÃO | 11 |
| demais | 27 |

`executor_responsavel` nulo em 60/202 (30%). `zona` nula em 24/202 (12%).

### 1.4 Lógica Atual de Determinação da Etapa Atual

No notebook `nb_gold_acto_gestao_obras`, a função `adicionar_etapa_atual_2()` define qual é a etapa vigente de cada OS através de uma seleção de **uma única linha por OS**:

```python
df_etapas["etapa_aberta"] = df_etapas["dataEtapaFim"].isna()

df_etapa_atual = (
    df_etapas
    .sort_values(
        by=["seqFluxo", "etapa_aberta", "dataAtenderEtapa"],
        ascending=[True, False, False]
    )
    .drop_duplicates(subset="seqFluxo", keep="first")  # ← CAUSA DO BUG
)
```

### 1.5 Lógica do Painel SEONT (`nb_gold_acto_gestao_obras_seont_os`)

#### 1.5.1 Extração do Analista Responsável por Zona

O formulário de OS possui campos para analista por zona geográfica (Z1, Z2, Z3). A técnica `bfill` horizontal consolida as variantes em `analista_responsavel`:

```python
cols_analista = [c for c in df_solicitacoes.columns if "ANALISADA POR" in normalizar(c)]
df_analistas["analista_responsavel"] = df_analistas[cols_analista].bfill(axis=1).iloc[:, 0]
```

> **Volume atual:** apenas 3,5% das OS têm `analista_responsavel` preenchido — esperado, pois o campo só é preenchido após a distribuição pela chefia SEONT.

#### 1.5.2 Cálculo do `flag_seont`

```python
SETORES_SEONT = {"SEONT", "SEONT-Chefia", "SEONT-Chefia (D.O)", "SEONT CHEFIA"}
df["flag_seont"] = df["aux_setor_responsavel"].str.strip().isin(SETORES_SEONT).astype(int)
```

#### 1.5.3 Cálculo do `executor_responsavel`

```python
mask_seont    = df["flag_seont"] == 1
mask_executor = df["executor_atual"].notna() & (df["executor_atual"].str.strip() != "")

df["executor_responsavel"] = df["executor_atual"].where(
    mask_seont & mask_executor,
    other=df["analista_responsavel"]   # ← fallback incorreto para não-SEONT
)
```

#### 1.5.4 Filtro Final

```python
df_seont = df[df["flag_seont"] == 1]  # 202 registros (estado atual)
```

---

## 2. Problemas Identificados

### 2.1 Bug Principal — OS com Múltiplas Etapas Ativas Simultâneas

#### Descrição

Algumas OS aparecem com **mais de uma etapa com `dataEtapaFim = NULL`** ao mesmo tempo:

| Etapa | Setor Responsável | `dataEtapaFim` |
|---|---|---|
| COMUNICAR INICIO DE OBRAS | Usuário/Sistema | NULL |
| SEONT - ANÁLISE TÉCNICA - CONFERÊNCIA DOS DADOS | **SEONT** | NULL |
| ETAPA RESUMO | Sistema | NULL |

**Exemplo confirmado:** OS 325698 (PLU-000023/2025-P).

#### Por Que as OS Somem do Painel SEONT

O `drop_duplicates` mantém apenas **uma** das etapas abertas. Se essa etapa não for SEONT:

```
OS 325698 → etapa_atual = "ETAPA RESUMO"
          → aux_setor_responsavel = "Sistema"
          → flag_seont = 0
          → OS excluída do painel SEONT ← PROBLEMA
```

#### Impacto

- Analistas da SEONT não visualizam OS que estão na sua fila.
- Carga de trabalho incompleta no painel gerencial.
- Não há sinalização — a OS simplesmente desaparece.

#### Causa Raiz

O pipeline assume `1 OS = 1 etapa ativa`. O Acto Gestão, em alguns fluxos, abre etapas em paralelo sem fechar as anteriores (`1 OS = N etapas ativas`).

---

### 2.2 Colunas Artefato em `gold_pdr_acompanhamentos_os`

As colunas `Executor` e `Etapa` (capitalizadas, 99% nulas) não constam no ESP original e não são consumidas por nenhum painel. São artefatos de versão anterior do pipeline e devem ser removidas.

---

### 2.3 `etapa_atual` com Variante por Espaço

A etapa "SEONT - PRÉ ANÁLISE TECNICA" aparece com duas variantes na tabela (provavelmente espaço extra ou encoding diferente), gerando duplicata lógica na distribuição. Necessita normalização com `str.strip()`.

---

### 2.4 OS sem Zona — Dois Padrões Distintos

A exploração identificou 24 OS em `gold_obras_seont_os` com `zona = NULL`, divididas em dois padrões:

#### Padrão A — Serviços sem relevância geográfica (8 OS) — comportamento esperado

| Serviço | Etapa | Setor | OS |
|---|---|---|---|
| INSCRIÇÃO DE PROFISSIONAL (PESSOA FÍSICA) | REGISTRO DA PUBLICIDADE DO D.O. | SEONT-Chefia (D.O) | 5 |
| INSCRIÇÃO EMPRESA/PROFISSIONAL (PESSOA JURÍDICA) | REGISTRO DA PUBLICIDADE DO D.O. | SEONT-Chefia (D.O) | 1 |
| PROVIDÊNCIA | REGISTRO DA PUBLICIDADE DO D.O. | SEONT-Chefia (D.O) | 1 |
| CONSTRUÇÃO NOVAS DE EDIFICAÇÕES | REGISTRO DA PUBLICIDADE DO D.O. | SEONT-Chefia (D.O) | 1 |

Esses serviços são de cadastro/registro profissional ou publicação — não têm endereço de obra. `zona = NULL` é correto para eles. São tratados pela SEONT-Chefia (D.O.) de forma centralizada.

**Ação:** marcar `zona_aplicavel = 0` no pipeline para esses serviços, evitando alarmes falsos de qualidade de dados.

#### Padrão B — REFORMA E/OU LEGALIZAÇÃO sem bairro mapeado (16 OS) — gap real

| Etapa | Setor | OS |
|---|---|---|
| SEONT CHEFIA - DISTRIBUIÇÃO | SEONT-Chefia | 11 |
| DELIBERAÇÃO SEONT | SEONT-Chefia | 3 |
| SEONT - ANÁLISE TECNICA | SEONT | 1 |
| SEONT - PRÉ ANÁLISE TECNICA | SEONT | 1 |

OS de reforma têm localização física — `zona = NULL` indica que o `bairro_consolidado` está nulo ou o bairro não consta no de-para do `AuxiliarPDR.xlsx`.

**Ação:** verificar `bairro_consolidado` das 16 OS. Se bairro preenchido → atualizar `AuxiliarPDR.xlsx`. Se bairro nulo → investigar origem no Silver.

---

## 3. Soluções Propostas

### 3.1 Correção Principal — Múltiplas Etapas Abertas

**Notebook:** `nb_gold_acto_gestao_obras` — Célula 5, função `adicionar_etapa_atual_2()`

**Princípio:** não dropar etapas abertas. Manter uma linha por etapa aberta; fallback de 1 linha apenas para OS sem nenhuma etapa aberta (finalizadas).

```python
df_etapas["etapa_aberta"] = df_etapas["dataEtapaFim"].isna()

# Todas as etapas abertas
df_etapas_abertas = df_etapas[df_etapas["etapa_aberta"]].copy()

# OS sem etapa aberta → fallback: última etapa fechada
os_com_etapa_aberta = set(df_etapas_abertas["seqFluxo"])
df_fallback = (
    df_etapas[~df_etapas["seqFluxo"].isin(os_com_etapa_aberta)]
    .sort_values(["seqFluxo", "dataAtenderEtapa"], ascending=[True, False])
    .drop_duplicates(subset="seqFluxo", keep="first")
)

df_etapa_atual = pd.concat([df_etapas_abertas, df_fallback], ignore_index=True)

# Flag de observabilidade
contagem = df_etapas_abertas.groupby("seqFluxo").size().reset_index(name="qtd_etapas_abertas")
df_etapa_atual = df_etapa_atual.merge(contagem, on="seqFluxo", how="left")
df_etapa_atual["qtd_etapas_abertas"] = df_etapa_atual["qtd_etapas_abertas"].fillna(1).astype(int)
df_etapa_atual["flag_multiplas_etapas"] = (df_etapa_atual["qtd_etapas_abertas"] > 1).astype(int)
```

**Impacto na tabela:**

| Situação | Linhas por OS (hoje) | Linhas por OS (após fix) |
|---|---|---|
| 1 etapa aberta (normal) | 1 | 1 |
| 3 etapas abertas (bug) | 1 | 3 |
| 0 etapas abertas (finalizada) | 1 | 1 |

---

### 3.2 Correção do `executor_responsavel` e Limpeza do `analista_responsavel`

**Notebook:** `nb_gold_acto_gestao_obras_seont_os` — após cálculo do `flag_seont`

Com múltiplas etapas, linhas não-SEONT receberiam `executor_responsavel = analista_responsavel` — incorreto. A lógica correta:

```python
# Limpar analista_responsavel fora das etapas SEONT
df.loc[df["flag_seont"] == 0, "analista_responsavel"] = pd.NA

# executor_responsavel por tipo de etapa
mask_seont    = df["flag_seont"] == 1
mask_executor = (
    df["executor_atual"].notna()
    & (df["executor_atual"].astype(str).str.strip() != "")
)

df["executor_responsavel"] = pd.NA

# SEONT com executor → executor_atual
df.loc[mask_seont & mask_executor,  "executor_responsavel"] = \
    df.loc[mask_seont & mask_executor,  "executor_atual"]

# SEONT sem executor → analista por zona
df.loc[mask_seont & ~mask_executor, "executor_responsavel"] = \
    df.loc[mask_seont & ~mask_executor, "analista_responsavel"]

# Não-SEONT → executor_atual apenas (sem fallback para analista)
df.loc[~mask_seont, "executor_responsavel"] = \
    df.loc[~mask_seont, "executor_atual"]
```

Resultado esperado para OS 325698 (antes do filtro final):

| Linha | etapa_atual | analista_responsavel | executor_responsavel |
|---|---|---|---|
| 1 | COMUNICAR INICIO DE OBRAS | NULL | executor_atual ou NULL |
| 2 | SEONT - ANÁLISE TÉCNICA - CONF. DOS DADOS | ZANIA MEIRELES | ZANIA MEIRELES* |
| 3 | ETAPA RESUMO | NULL | executor_atual ou NULL |

*`executor_atual` se já atribuído; caso contrário `analista_responsavel`.

---

### 3.3 Remoção das Colunas Artefato

**Notebook:** `nb_gold_acto_gestao_obras` — célula de salvar tabela, antes do `write.format("delta")`

```python
df = df.drop(columns=["Executor", "Etapa"], errors="ignore")
```

---

### 3.4 Normalização do `etapa_atual`

**Notebook:** `nb_gold_acto_gestao_obras` — após montar o df final

```python
df["etapa_atual"] = df["etapa_atual"].str.strip()
```

---

### 3.5 Tratamento de Zona para Serviços sem Relevância Geográfica

**Notebook:** `nb_gold_acto_gestao_obras` ou `nb_gold_acto_gestao_obras_seont_os`

```python
SERVICOS_SEM_ZONA = {
    "INSCRIÇÃO DE PROFISSIONAL (PESSOA FÍSICA)",
    "INSCRIÇÃO EMPRESA/PROFISSIONAL (PESSOA JURÍDICA)",
    "RENOVAÇÃO DE CADASTRO PROFISSIONAL PESSOA FÍSICA",
    "RENOVAÇÃO DE CADASTRO EMPRESA/PROFISSIONAL (PESSOA JURÍDICA)",
    "PROVIDÊNCIA",
}

df["zona_aplicavel"] = (~df["servico"].isin(SERVICOS_SEM_ZONA)).astype(int)
```

`zona_aplicavel = 0` indica que `zona = NULL` é comportamento esperado para aquele serviço.

---

### 3.6 Correção do Mapeamento de Bairro→Zona (AuxiliarPDR.xlsx)

**Ação manual + pipeline:**

1. Extrair `bairro_consolidado` das 16 OS de REFORMA E/OU LEGALIZAÇÃO sem zona.
2. Verificar quais bairros não constam no de-para do `AuxiliarPDR.xlsx`.
3. Atualizar a planilha com os bairros faltantes e suas zonas.
4. Re-executar o pipeline para propagar a correção.

---

### 3.7 Propagação de `flag_multiplas_etapas`

**`nb_gold_acto_gestao_obras_seont_os`** — `COLUNAS_FINAIS`:

```python
COLUNAS_FINAIS = [
    # ... colunas existentes ...
    "flag_multiplas_etapas",  # ← adicionar
    "zona_aplicavel",         # ← adicionar
]
```

---

### 3.8 Resumo das Mudanças por Notebook

| Notebook | Localização | Tipo | Mudança |
|---|---|---|---|
| `nb_gold_acto_gestao_obras` | Célula 5 — `adicionar_etapa_atual_2()` | **Correção principal** | Não dropar etapas abertas; fallback apenas para OS finalizadas |
| `nb_gold_acto_gestao_obras` | Célula salvar tabela | **Limpeza** | Remover colunas artefato `Executor` e `Etapa` |
| `nb_gold_acto_gestao_obras` | Após montar df | **Normalização** | `str.strip()` em `etapa_atual` |
| `nb_gold_acto_gestao_obras` | Após merge de zona | **Novo campo** | Criar `zona_aplicavel` por tipo de serviço |
| `nb_gold_acto_gestao_obras_seont_os` | Após cálculo `flag_seont` | **Limpeza** | Zerar `analista_responsavel` para `flag_seont = 0` |
| `nb_gold_acto_gestao_obras_seont_os` | Célula `executor_responsavel` | **Correção de regra** | Etapas não-SEONT usam apenas `executor_atual` |
| `nb_gold_acto_gestao_obras_seont_os` | `COLUNAS_FINAIS` | **Adição** | Incluir `flag_multiplas_etapas` e `zona_aplicavel` |
| `AuxiliarPDR.xlsx` | Aba de-para bairro→zona | **Dado** | Adicionar bairros das 16 OS de Reforma sem zona |

**O que NÃO muda:**

| Componente | Motivo |
|---|---|
| Ingestão Silver | Problema está na camada Gold |
| Lógica de bairros e zonas (join) | Independente de quantidade de etapas |
| Cálculo de `flag_seont` | Funciona linha a linha |
| Cálculo de `flag_etapa_aprov` | Idem |
| Cálculo de `dias_na_etapa` | Calculado por linha de etapa |
| Merge com analistas por zona (join) | O join não muda; apenas o que fazemos com o resultado |
| Demais painéis (PDR, acompanhamento geral) | Sem alteração no comportamento |

---

## 4. Comportamento Esperado Após as Correções

### Painel da Gerência (`gold_pdr_acompanhamentos_os`)

OS 325698 aparecerá com **3 linhas**, `flag_multiplas_etapas = 1`:

| n_da_solicitacao | etapa_atual | aux_setor_responsavel | executor_atual | flag_multiplas_etapas |
|---|---|---|---|---|
| 325698 | COMUNICAR INICIO DE OBRAS | Usuário | (executor ou NULL) | 1 |
| 325698 | SEONT - ANÁLISE TÉCNICA - CONF. DOS DADOS | SEONT | (executor ou NULL) | 1 |
| 325698 | ETAPA RESUMO | Sistema | (executor ou NULL) | 1 |

### Painel SEONT (`gold_obras_seont_os`)

OS 325698 aparecerá com **1 linha** (filtro `flag_seont = 1`):

| n_da_solicitacao | etapa_atual | analista_responsavel | executor_responsavel | flag_seont | flag_multiplas_etapas |
|---|---|---|---|---|---|
| 325698 | SEONT - ANÁLISE TÉCNICA - CONF. DOS DADOS | ZANIA MEIRELES | ZANIA MEIRELES | 1 | 1 |

---

## 5. Plano de Validação

### 5.1 Testes de Regressão

| Caso | Critério de Aceite |
|---|---|
| OS com 1 etapa aberta (normal) | 1 linha, comportamento idêntico ao atual |
| OS finalizada (0 etapas abertas) | 1 linha (fallback última etapa) |
| OS com 3 etapas abertas (bug) | 3 linhas; `flag_multiplas_etapas = 1` |
| OS 325698 no painel SEONT | `flag_seont = 1`, etapa SEONT, `analista_responsavel = ZANIA MEIRELES` |
| Serviços sem zona por natureza | `zona_aplicavel = 0`, sem alarme de qualidade |
| REFORMA E/OU LEGALIZAÇÃO | `zona` preenchida após atualização do AuxiliarPDR |
| Colunas `Executor` e `Etapa` | Ausentes da tabela gold |
| `etapa_atual` | Sem variantes por espaço extra |

### 5.2 Queries de Validação

```sql
-- 1. OS com múltiplas etapas na tabela base
SELECT
    n_da_solicitacao,
    COUNT(*)                      AS linhas,
    MAX(flag_multiplas_etapas)    AS flag_multiplas
FROM gold_pdr_acompanhamentos_os
GROUP BY n_da_solicitacao
HAVING COUNT(*) > 1
ORDER BY linhas DESC;

-- 2. Caso específico no painel SEONT
SELECT
    n_da_solicitacao,
    etapa_atual,
    aux_setor_responsavel,
    flag_seont,
    flag_multiplas_etapas,
    executor_responsavel
FROM gold_obras_seont_os
WHERE n_da_solicitacao = 325698;

-- 3. Volume de OS afetadas pelo bug (antes e depois)
SELECT
    flag_multiplas_etapas,
    COUNT(DISTINCT n_da_solicitacao) AS os_distintas,
    COUNT(*)                         AS total_linhas
FROM gold_pdr_acompanhamentos_os
GROUP BY flag_multiplas_etapas;

-- 4. Verificar ausência das colunas artefato
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'gold_pdr_acompanhamentos_os'
  AND COLUMN_NAME IN ('Executor', 'Etapa');
-- esperado: 0 linhas

-- 5. Verificar etapa_atual sem espaços duplicados
SELECT etapa_atual, COUNT(*) AS total
FROM gold_pdr_acompanhamentos_os
WHERE etapa_atual LIKE '%PRÉ ANÁLISE%'
GROUP BY etapa_atual;
-- esperado: 1 única variante

-- 6. OS sem zona com zona_aplicavel = 1 (gaps reais)
SELECT servico, bairro_consolidado, COUNT(*) AS total
FROM gold_obras_seont_os
WHERE zona IS NULL AND zona_aplicavel = 1
GROUP BY servico, bairro_consolidado
ORDER BY total DESC;
```

---

## 6. Riscos e Mitigações

| Risco | Mitigação |
|---|---|
| Visuais PBI com `COUNTROWS` duplicam OS com múltiplas etapas | Substituir por `DISTINCTCOUNT(n_da_solicitacao)` nas medidas DAX afetadas |
| Painel da gerência mostrando a mesma OS N vezes sem contexto | Adicionar `flag_multiplas_etapas` como indicador visual (ícone de alerta) |
| Remoção de `Executor`/`Etapa` quebrar relatório existente | Verificar se algum relatório PBI referencia essas colunas antes de remover |
| Bairros novos não mapeados futuramente | Adicionar validação no pipeline: logar bairros sem zona para revisão periódica |

---

## 7. Escopo Fora deste ESP-DRIVE

- Correção no workflow do Acto Gestão para não abrir etapas em paralelo (responsabilidade da equipe de configuração).
- Ajuste de medidas DAX nos painéis Power BI (tarefa separada pós-deploy).
- Investigação do motivo de `bairro_consolidado` nulo nas OS de Reforma (pode ser dado faltante na API).

---

## Referências

- [[SPEC_DRIVE_MIGRACAO_OBRAS]] — plano de implementação da migração (novo modelo EAV)
- [[Documentação_Fabric/Santos/obras/Processo Obras Santos|Processo Obras Santos]] — documentação geral do processo
