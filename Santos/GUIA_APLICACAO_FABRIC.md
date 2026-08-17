---
title: "Guia de Aplicação das Mudanças — Microsoft Fabric"
date: 2026-04-08
tags:
  - tipo/guia
  - ferramenta/fabric
  - municipio/santos
  - projeto/obras-santos
projeto: obras-santos
---

# Guia de Aplicação das Mudanças — Microsoft Fabric
**Projeto:** Painel de Acompanhamento de Obras — Santos  
**Data:** 2026-04-08  
**Referência:** [[Documentação_Fabric/Santos/obras/ESP_DRIVE_OS_MULTIPLAS_ETAPAS|ESP_DRIVE_OS_MULTIPLAS_ETAPAS]]

---

## Pré-requisitos

- Acesso ao workspace `lh_cidade_inteligente_santos` no Fabric com permissão de execução de notebooks
- Nenhum refresh agendado ativo durante a execução

---

## Passo 0 — Verificação prévia (sem ação necessária)

**Diagnóstico confirmado (2026-04-08):** as 16 OS de REFORMA E/OU LEGALIZAÇÃO com `zona = NULL` têm `bairro_consolidado = NULL` na tabela gold. Os bairros **existem no Acto Gestão** (ex: OS 916491 → BOQUEIRÃO) e o `AuxiliarPDR.xlsx` já os mapeia corretamente (BOQUEIRÃO → Z1).

**Causa:** o campo `Bairro` foi retornado como nulo pela API no momento da última ingestão Silver — preenchido no sistema posteriormente.

**Não é necessário alterar `AuxiliarPDR.xlsx` nem código.** Re-executar o pipeline completo já resolve.

> OS de serviços sem zona por natureza (INSCRIÇÃO DE PROFISSIONAL, PROVIDÊNCIA etc.) continuam com `zona = NULL` esperado — marcadas com `zona_aplicavel = 0`.

---

## Passo 1 — Abrir o Fabric e localizar os notebooks

1. Acessar [Microsoft Fabric](https://fabric.microsoft.com)
2. Navegar até o workspace **Acto Cidade Inteligente**
3. Localizar os notebooks na seção **Itens**:
   - `nb_gold_acto_gestao_obras`
   - `nb_gold_acto_gestao_obras_seont_os`

---

## Passo 2 — Atualizar `nb_gold_acto_gestao_obras`

Este notebook produz a tabela base `gold_pdr_acompanhamentos_os`.

### 2.1 Substituir o conteúdo das células alteradas

As alterações já foram aplicadas no arquivo local. Para aplicar no Fabric:

**Opção A — Upload do arquivo**
1. No Fabric, abrir o notebook `nb_gold_acto_gestao_obras`
2. Clicar em **"..."** → **Importar notebook** ou usar a opção de atualizar via OneLake
3. Fazer upload do arquivo `nb_gold_acto_gestao_obras.ipynb` atualizado

**Opção B — Edição manual célula por célula**  
Abrir o notebook no Fabric e substituir manualmente o conteúdo das células conforme abaixo.

---

#### Célula 5 — `adicionar_etapa_atual_2()` — CORREÇÃO PRINCIPAL

**Localizar** o trecho atual:
```python
df_etapa_atual = (
    df_etapas
    .sort_values(
        by=["seqFluxo", "etapa_aberta", "dataAtenderEtapa"],
        ascending=[True, False, False]
    )
    .drop_duplicates(subset="seqFluxo", keep="first")
)
```

**Substituir por:**
```python
# Todas as etapas abertas (pode ser N por OS)
df_etapas_abertas = df_etapas[df_etapas["etapa_aberta"]].copy()

# OS sem nenhuma etapa aberta → fallback: última etapa fechada
os_com_etapa_aberta = set(df_etapas_abertas["seqFluxo"])
df_fallback = (
    df_etapas[~df_etapas["seqFluxo"].isin(os_com_etapa_aberta)]
    .sort_values(["seqFluxo", "dataAtenderEtapa"], ascending=[True, False])
    .drop_duplicates(subset="seqFluxo", keep="first")
)

df_etapa_atual = pd.concat([df_etapas_abertas, df_fallback], ignore_index=True)

# Flag de observabilidade
contagem = (
    df_etapas_abertas
    .groupby("seqFluxo")
    .size()
    .reset_index(name="qtd_etapas_abertas")
)
df_etapa_atual = df_etapa_atual.merge(contagem, on="seqFluxo", how="left")
df_etapa_atual["qtd_etapas_abertas"]    = df_etapa_atual["qtd_etapas_abertas"].fillna(1).astype(int)
df_etapa_atual["flag_multiplas_etapas"] = (df_etapa_atual["qtd_etapas_abertas"] > 1).astype(int)

os_multiplas = df_etapa_atual[df_etapa_atual["flag_multiplas_etapas"] == 1]["seqFluxo"].nunique()
print(f"   OS com múltiplas etapas abertas: {os_multiplas}")
print(f"   Total linhas de etapa geradas:   {len(df_etapa_atual):,}")
```

**Também na mesma célula**, na seleção de colunas (passo 3 da função), alterar:
```python
# DE:
colunas = ["seqFluxo", "etapa", "executor"]

# PARA:
colunas = ["seqFluxo", "etapa", "executor", "flag_multiplas_etapas"]
```

---

#### Célula 11 — Salvar tabela — ADICIONAR ANTES DO SAVE

Inserir **antes** do bloco `spark.createDataFrame(df)`:

```python
# Normalização: remover espaços extras do etapa_atual
if "etapa_atual" in df.columns:
    df["etapa_atual"] = df["etapa_atual"].astype(str).str.strip()

# Remover colunas artefato (99% nulas, fora do schema)
df = df.drop(columns=["Executor", "Etapa"], errors="ignore")

# Criar zona_aplicavel: 0 para serviços sem relevância geográfica
SERVICOS_SEM_ZONA = {
    "INSCRIÇÃO DE PROFISSIONAL (PESSOA FÍSICA)",
    "INSCRIÇÃO EMPRESA/PROFISSIONAL (PESSOA JURÍDICA)",
    "RENOVAÇÃO DE CADASTRO PROFISSIONAL PESSOA FÍSICA",
    "RENOVAÇÃO DE CADASTRO EMPRESA/PROFISSIONAL (PESSOA JURÍDICA)",
    "PROVIDÊNCIA",
}
if "servico" in df.columns:
    df["zona_aplicavel"] = (~df["servico"].isin(SERVICOS_SEM_ZONA)).astype(int)
else:
    df["zona_aplicavel"] = 1

print(f"✓ etapa_atual normalizado")
print(f"✓ Colunas artefato removidas (Executor, Etapa)")
print(f"✓ zona_aplicavel criado — serviços sem zona: {(df['zona_aplicavel'] == 0).sum():,}")
```

---

### 2.2 Executar o notebook

1. Clicar em **Executar tudo** (Run All)
2. Verificar os prints esperados:
   ```
   OS com múltiplas etapas abertas: N   ← deve ser > 0 se houver OS com bug
   Total linhas de etapa geradas:   X   ← deve ser > total de OS distintas
   ✓ etapa_atual normalizado
   ✓ Colunas artefato removidas (Executor, Etapa)
   ✓ zona_aplicavel criado
   ✓ Tabela gold_pdr_acompanhamentos_os salva com sucesso
   ```

### 2.3 Validação pós-execução

Executar no SQL Analytics Endpoint do Santos:

```sql
-- Verificar OS com múltiplas etapas (deve retornar > 0 linhas)
SELECT n_da_solicitacao, COUNT(*) AS linhas, MAX(flag_multiplas_etapas) AS flag
FROM gold_pdr_acompanhamentos_os
GROUP BY n_da_solicitacao
HAVING COUNT(*) > 1
ORDER BY linhas DESC;

-- Verificar ausência dos artefatos
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'gold_pdr_acompanhamentos_os'
  AND COLUMN_NAME IN ('Executor', 'Etapa');
-- esperado: 0 linhas

-- Verificar etapa_atual sem variantes por espaço
SELECT etapa_atual, COUNT(*) AS total
FROM gold_pdr_acompanhamentos_os
WHERE etapa_atual LIKE '%PRÉ ANÁLISE%'
GROUP BY etapa_atual;
-- esperado: 1 única variante
```

---

## Passo 3 — Atualizar `nb_gold_acto_gestao_obras_seont_os`

Este notebook produz `gold_obras_seont_os` (painel SEONT). **Executar somente após o Passo 2 concluído com sucesso.**

### 3.1 Aplicar as células alteradas

**Opção A — Upload** (mesmo procedimento do Passo 2)

**Opção B — Edição manual**

---

#### Célula 8 — `flag_seont` — ADICIONAR LIMPEZA DO ANALISTA

Após o bloco de cálculo do `flag_seont`, **inserir**:

```python
# Limpar analista_responsavel para etapas não-SEONT
# O analista por zona (Z1/Z2/Z3) é exclusivo da SEONT.
if "analista_responsavel" in df.columns:
    df.loc[df["flag_seont"] == 0, "analista_responsavel"] = pd.NA
    print(f"   analista_responsavel zerado em etapas não-SEONT")
```

---

#### Célula 10 — `executor_responsavel` — SUBSTITUIÇÃO COMPLETA

**Substituir** o bloco atual por:

```python
# ============================================================
# executor_responsavel — regra por tipo de etapa:
#   SEONT com executor → executor_atual
#   SEONT sem executor → analista_responsavel (zona)
#   Não-SEONT          → executor_atual apenas (sem fallback)
# ============================================================
print("👤 Calculando executor_responsavel...")

mask_seont = df["flag_seont"] == 1
mask_executor = (
    df["executor_atual"].notna()
    & (df["executor_atual"].astype(str).str.strip() != "")
    & (df["executor_atual"].astype(str).str.strip().str.upper() != "NAN")
)

df["executor_responsavel"] = pd.NA

df.loc[mask_seont & mask_executor,  "executor_responsavel"] = \
    df.loc[mask_seont & mask_executor,  "executor_atual"]

df.loc[mask_seont & ~mask_executor, "executor_responsavel"] = \
    df.loc[mask_seont & ~mask_executor, "analista_responsavel"]

df.loc[~mask_seont, "executor_responsavel"] = \
    df.loc[~mask_seont, "executor_atual"]

preenchidos = df["executor_responsavel"].notna().sum()
nulos       = df["executor_responsavel"].isna().sum()
print(f"   preenchido: {preenchidos:,} ({preenchidos/len(df)*100:.1f}%)")
print(f"   nulo:       {nulos:,} ({nulos/len(df)*100:.1f}%)")
print("\n✅ Colunas derivadas calculadas!")
```

---

#### Célula 13 — `COLUNAS_FINAIS` — ADICIONAR DUAS COLUNAS

Na lista `COLUNAS_FINAIS`, **adicionar ao final**:

```python
COLUNAS_FINAIS = [
    # ... colunas existentes mantidas ...
    "flag_seont",
    "flag_etapa_aprov",
    "flag_multiplas_etapas",   # ← NOVO
    "zona_aplicavel",           # ← NOVO
]
```

---

### 3.2 Executar o notebook

1. Clicar em **Executar tudo**
2. Verificar prints esperados:
   ```
   analista_responsavel zerado em etapas não-SEONT
   executor_responsavel preenchido: X  
   📊 Total após filtro SEONT: 202+ registros
   ✅ Schema final (22 colunas)
   Tabela gold_obras_seont_os salva com sucesso!
   ```

### 3.3 Validação pós-execução

```sql
-- OS 325698 deve aparecer no painel SEONT
SELECT n_da_solicitacao, etapa_atual, analista_responsavel,
       executor_responsavel, flag_seont, flag_multiplas_etapas
FROM gold_obras_seont_os
WHERE n_da_solicitacao = 325698;

-- OS sem zona por tipo (gap real vs esperado)
SELECT zona_aplicavel, zona,
       COUNT(*) AS total
FROM gold_obras_seont_os
WHERE zona IS NULL
GROUP BY zona_aplicavel, zona
ORDER BY zona_aplicavel;
-- zona_aplicavel=0 → esperado (sem alarme)
-- zona_aplicavel=1 → gap real (deve diminuir após AuxiliarPDR atualizado)

-- Verificar 22 colunas no schema
SELECT COUNT(*) AS total_colunas
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'gold_obras_seont_os';
```

---

## Passo 4 — Atualizar refresh agendado

Se os notebooks têm refresh agendado no Fabric (Data Pipeline ou agendamento direto):

1. Verificar se a ordem de execução está correta:
   ```
   nb_ingest_silver → nb_gold_acto_gestao_obras → nb_gold_acto_gestao_obras_seont_os
   ```
2. Confirmar que o notebook SEONT só dispara **após** o gold base finalizar com sucesso

---

## Passo 5 — Verificação no Power BI

Após a atualização das tabelas:

1. Abrir o relatório **Obras Santos SEONT** no Power BI
2. Clicar em **Atualizar** no modelo semântico
3. Verificar:
   - OS 325698 aparece no painel SEONT
   - Contagem de OS não duplica (confirmar medidas usam `DISTINCTCOUNT` de `n_da_solicitacao`)
   - Filtros de zona funcionam corretamente

> **Atenção:** medidas DAX que usam `COUNTROWS` podem duplicar OS com `flag_multiplas_etapas = 1` no painel da gerência. Revisar e substituir por `DISTINCTCOUNT(gold_pdr_acompanhamentos_os[n_da_solicitacao])` onde necessário.

---

## Resumo das Células Alteradas

| Notebook                             | Célula                          | O que muda                                                               |
| ------------------------------------ | ------------------------------- | ------------------------------------------------------------------------ |
| `nb_gold_acto_gestao_obras`          | 5 — `adicionar_etapa_atual_2()` | `drop_duplicates` → lógica de múltiplas etapas + `flag_multiplas_etapas` |
| `nb_gold_acto_gestao_obras`          | 11 — salvar tabela              | Adiciona `str.strip()`, remove `Executor`/`Etapa`, cria `zona_aplicavel` |
| `nb_gold_acto_gestao_obras_seont_os` | 8 — `flag_seont`                | Zera `analista_responsavel` para `flag_seont = 0`                        |
| `nb_gold_acto_gestao_obras_seont_os` | 10 — `executor_responsavel`     | Nova lógica por tipo de etapa (sem fallback incorreto)                   |
| `nb_gold_acto_gestao_obras_seont_os` | 13 — `COLUNAS_FINAIS`           | Adiciona `flag_multiplas_etapas` e `zona_aplicavel`                      |

---

## Em caso de erro

| Sintoma | Causa provável | Ação |
|---|---|---|
| `KeyError: flag_multiplas_etapas` no SEONT | nb_gold não foi re-executado antes | Re-executar nb_gold e depois nb_seont |
| `KeyError: zona_aplicavel` no SEONT | Idem | Idem |
| OS 325698 ainda não aparece no SEONT | Etapa SEONT não está aberta no sistema | Verificar diretamente no Acto Gestão |
| Contagem de OS dobrou no PBI | Medidas DAX usando COUNTROWS | Substituir por DISTINCTCOUNT |
| `zona_aplicavel` não existe na tabela | Coluna `servico` ausente no df durante save | Verificar célula 11 do nb_gold |

---

## Ver Também

- [[Documentação_Fabric/Santos/obras/Processo Obras Santos|Processo Obras Santos]] — documentação do processo
- [[Documentação_Fabric/Santos/obras/ESP_DRIVE_OS_MULTIPLAS_ETAPAS|ESP_DRIVE_OS_MULTIPLAS_ETAPAS]] — especificação técnica
- [[_mapa-do-vault]] — índice geral
