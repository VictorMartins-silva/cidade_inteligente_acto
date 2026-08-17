---
title: "Spec — Mapa Geográfico · Violência Contra a Mulher · Osasco"
tags:
  - tipo/spec
  - tema/osasco
  - tema/geo
  - tema/violencia-mulher
  - tema/power-bi
municipio: Osasco
status: em-desenvolvimento
data: "2026-06-29"
relacionados:
  - "[[spec_drive_violencia_mulher_osasco]]"
  - "[[geo_mapa_bairros_osasco]]"
  - "[[spec_drive_semana_29_06_2026]]"
---

# Spec — Mapa Geográfico · Violência Contra a Mulher · Osasco

Adicionar visualização geográfica ao painel de Violência Contra a Mulher de Osasco.  
Cada ocorrência (BO) é plotada como ponto individual no mapa usando `Latitude`/`Longitude` da Gold, filtrada ao perímetro do município via ponto-em-polígono.

---

## Contexto

| Item | Detalhe |
|---|---|
| Lakehouse | `lh_cidade_inteligente_osasco` |
| Tabela de origem | `gold_osasco_violencia_mulher` |
| Notebook de origem | `nb_gold_violencia_mulher_osasco` |
| Pipeline | `pl_violencia_mulher_osasco` |
| Shapefile (polígonos Osasco) | `Mapas_SSP_Osasco/shapefiles/bairros/geo_div_bairro_mascara.*` · EPSG:3857 |
| GeoJSON pronto (EPSG:4326) | `Mapas_SSP_Osasco/geojson/bairros_osasco.json` |

### Por que alguns pontos caem fora de Osasco

As coordenadas vêm dos BOs da Polícia Civil/Militar. Erros de geocodificação, endereços de divisa, e registros de localidade equivocada geram pontos em São Paulo, Barueri, Jandira e outras cidades limítrofes. O filtro de ponto-em-polígono resolve isso na camada Gold — o PBI recebe apenas pontos válidos.

---

## Decisão de arquitetura — nova Gold de mapa (não modificar a Gold principal)

A Gold principal (`gold_osasco_violencia_mulher`) já alimenta o painel existente. Modificá-la adiciona risco de regressão. A solução é um **notebook Gold auxiliar** que lê a Gold principal, aplica o filtro geográfico e escreve uma tabela menor específica para o mapa.

```
gold_osasco_violencia_mulher  (existente — não modificar)
          ↓
nb_gold_osasco_violencia_mulher_mapa  (novo)
          ↓
gold_osasco_violencia_mulher_mapa  (nova tabela)
          ↓
PBI — visual Azure Maps / Mapa
```

---

## Passo 0 — Levantamento obrigatório antes de codificar

Rodar no Fabric (ou ODBC local) para validar cobertura e CRS:

```python
import pyodbc, pandas as pd

conn = pyodbc.connect(...)  # lh_cidade_inteligente_osasco

# 1. Cobertura de lat/long
df = pd.read_sql("""
    SELECT
        COUNT(*)                                           AS total_bos,
        SUM(CASE WHEN Latitude IS NOT NULL
                  AND Longitude IS NOT NULL THEN 1 END)   AS com_coordenada,
        SUM(CASE WHEN Latitude IS NULL
                   OR Longitude IS NULL  THEN 1 END)      AS sem_coordenada,
        MIN(Latitude)  AS lat_min,
        MAX(Latitude)  AS lat_max,
        MIN(Longitude) AS lon_min,
        MAX(Longitude) AS lon_max
    FROM gold_osasco_violencia_mulher
    WHERE Flag_Incluir = 1
""", conn)
print(df.to_string(index=False))

# 2. Amostra de 5 registros com coordenada
df_amostra = pd.read_sql("""
    SELECT TOP 5 Latitude, Longitude, Bairro, Rubrica
    FROM gold_osasco_violencia_mulher
    WHERE Flag_Incluir = 1 AND Latitude IS NOT NULL
""", conn)
print(df_amostra.to_string(index=False))
```

**Critério de aprovação para avançar:**
- Cobertura ≥ 60% dos registros com `Flag_Incluir = 1`
- `Latitude` entre -24.0 e -23.0 e `Longitude` entre -47.0 e -46.0 → confirma WGS84 (EPSG:4326)
- Se valores fora desse range: coordenadas provavelmente em EPSG:3857 (metros) — exige conversão antes do filtro

---

## Notebook: `nb_gold_osasco_violencia_mulher_mapa`

**Localização:** `violencias_mulher_osasc/gold/`  
**Trigger:** após `nb_gold_violencia_mulher_osasco` no pipeline

```python
# ============================================================
# nb_gold_osasco_violencia_mulher_mapa
# Lê Gold principal, aplica filtro ponto-em-polígono Osasco,
# escreve Gold de mapa.
# ============================================================

import geopandas as gpd
from shapely.geometry import Point
import pandas as pd

# ----------------------------------------------------------
# 1. Carregar shapefile de bairros de Osasco
#    Usar o GeoJSON já em EPSG:4326 (mais simples que o .shp)
# ----------------------------------------------------------
GEOJSON_PATH = "/lakehouse/default/Files/geo/bairros_osasco.json"

gdf_bairros = gpd.read_file(GEOJSON_PATH)
# Garantir WGS84 (o GeoJSON já deve estar em 4326)
gdf_bairros = gdf_bairros.to_crs("EPSG:4326")

# União de todos os polígonos → contorno do município
poligono_osasco = gdf_bairros.geometry.unary_union   # compatível com geopandas < 0.14

# ----------------------------------------------------------
# 2. Ler Gold principal (Spark → pandas)
# ----------------------------------------------------------
df = spark.sql("""
    SELECT
        `Numero BO`,
        `Data Ocorrência`,
        `Hora Ocorrência`,
        `Periodo_Final`,
        `OrdemDia`,
        `Tipo Local`,
        `Rubrica`,
        `Desdobramento`,
        `Circunstância`,
        `Bairro`,
        `Logradouro`,
        `Latitude`,
        `Longitude`,
        `Tipo_Regra`,
        `_fonte`,
        `_ano_ref`,
        `_mes_ref`,
        `Flag_Incluir`
    FROM gold_osasco_violencia_mulher
    WHERE Flag_Incluir = 1
      AND Latitude  IS NOT NULL
      AND Longitude IS NOT NULL
""").toPandas()

print(f"Registros com coordenada e Flag_Incluir=1: {len(df)}")

# ----------------------------------------------------------
# 3. Point-in-polygon — filtrar ao perímetro de Osasco
#    ATENÇÃO: Point(longitude, latitude) — Shapely usa (X, Y)
# ----------------------------------------------------------
def dentro_osasco(lat, lon):
    try:
        return Point(lon, lat).within(poligono_osasco)
    except Exception:
        return False

df["dentro_osasco"] = df.apply(
    lambda r: dentro_osasco(r["Latitude"], r["Longitude"]), axis=1
)

n_total    = len(df)
n_dentro   = df["dentro_osasco"].sum()
n_fora     = n_total - n_dentro
print(f"Dentro de Osasco : {n_dentro} ({100*n_dentro/n_total:.1f}%)")
print(f"Fora de Osasco   : {n_fora} ({100*n_fora/n_total:.1f}%) — excluídos do mapa")

df_mapa = df[df["dentro_osasco"]].drop(columns="dentro_osasco")

# ----------------------------------------------------------
# 4. Adicionar bairro geográfico via spatial join (opcional)
#    Permite agrupamento por bairro no PBI sem depender do
#    campo Bairro textual (que pode ter erros de grafia)
# ----------------------------------------------------------
geometry_pts = [Point(lon, lat) for lon, lat in zip(df_mapa["Longitude"], df_mapa["Latitude"])]
gdf_pontos = gpd.GeoDataFrame(df_mapa, geometry=geometry_pts, crs="EPSG:4326")

gdf_joined = gpd.sjoin(
    gdf_pontos,
    gdf_bairros[["NOME_NORM", "geometry"]],
    how="left",
    predicate="within"
)
df_mapa = pd.DataFrame(gdf_joined.drop(columns=["geometry", "index_right"]))
df_mapa = df_mapa.rename(columns={"NOME_NORM": "bairro_geo"})

# ----------------------------------------------------------
# 5. Validar e escrever Gold de mapa
# ----------------------------------------------------------
assert len(df_mapa) > 0, "Gold de mapa vazia — verificar filtro"
print(f"Escrevendo {len(df_mapa)} registros em gold_osasco_violencia_mulher_mapa")

df_spark = spark.createDataFrame(df_mapa)
df_spark.write.mode("overwrite").format("delta") \
    .option("overwriteSchema", "true") \
    .saveAsTable("gold_osasco_violencia_mulher_mapa")

print("✅ gold_osasco_violencia_mulher_mapa escrita com sucesso.")
```

---

## Schema da Gold de Mapa

| Coluna | Tipo | Observação |
|---|---|---|
| `Numero BO` | string | Identificador do BO |
| `Data Ocorrência` | date | Data do evento |
| `Hora Ocorrência` | time | Hora do evento (pode ser nula) |
| `Periodo_Final` | string | De madrugada / Pela manhã / À tarde / À noite |
| `OrdemDia` | int | 1=Seg … 7=Dom |
| `Tipo Local` | string | Casa / Via Pública / Estabelecimento / etc. |
| `Rubrica` | string | Tipo da ocorrência |
| `Desdobramento` | string | Detalhamento da rubrica |
| `Circunstância` | string | Circunstância da ocorrência |
| `Bairro` | string | Campo textual original (pode ter erros) |
| `bairro_geo` | string | Bairro pelo spatial join (mais confiável para agrupamentos) |
| `Logradouro` | string | Endereço do BO |
| `Latitude` | double | Coordenada — WGS84, dentro de Osasco |
| `Longitude` | double | Coordenada — WGS84, dentro de Osasco |
| `Tipo_Regra` | string | Regra 1 / Regra 2 |
| `_fonte` | string | PM / Civil |
| `_ano_ref` | int | Ano de referência |
| `_mes_ref` | int | Mês de referência |

> `Flag_Incluir` **não aparece na Gold de mapa** — todos os registros já passaram pelo filtro `= 1`.

---

## Pré-requisito de Deploy — Upload do GeoJSON ao OneLake

O arquivo `bairros_osasco.json` (EPSG:4326, já gerado) precisa estar acessível dentro do lakehouse:

```
lh_cidade_inteligente_osasco/
└── Files/
    └── geo/
        └── bairros_osasco.json   ← fazer upload via Fabric UI ou AzCopy
```

Caminho ABFSS no notebook:
```python
GEOJSON_PATH = "abfss://<workspace-id>@onelake.dfs.fabric.microsoft.com/<lakehouse-id>/Files/geo/bairros_osasco.json"
# ou, dentro do notebook Fabric com lakehouse montado:
GEOJSON_PATH = "/lakehouse/default/Files/geo/bairros_osasco.json"
```

---

## Atualização do Pipeline `pl_violencia_mulher_osasco`

Adicionar atividade de notebook após o Gold principal:

```
nb_ingest_bronze_violencia_mulher_osasco
    ↓
nb_silver_violencia_mulher_osasco
    ↓
nb_gold_violencia_mulher_osasco          (existente)
    ↓
nb_gold_osasco_violencia_mulher_mapa     ← NOVA ATIVIDADE
    ↓
RefreshSqlEndpoint
    ↓
RefreshPBI
```

---

## Configuração no Power BI

### Visual recomendado: Azure Maps

| Campo | Configuração |
|---|---|
| Localização | `Latitude` + `Longitude` (colunas separadas) |
| Tamanho | fixo (cada ponto = 1 BO) ou `COUNT(Numero BO)` por `bairro_geo` |
| Cor | `Rubrica` ou `Tipo_Regra` (paleta com 5–6 categorias) |
| Dica de ferramenta | `Bairro` · `Rubrica` · `Data Ocorrência` · `Tipo Local` · `Periodo_Final` |

### Filtros sugeridos para a aba de mapa

| Filtro | Campo |
|---|---|
| Período (slider) | `Data Ocorrência` |
| Período do dia | `Periodo_Final` |
| Tipo de local | `Tipo Local` |
| Fonte | `_fonte` (PM / Civil) |
| Rubrica / Tipo regra | `Rubrica` ou `Tipo_Regra` |

### Visual alternativo: Shape Map (por bairro)

Se a cobertura de lat/long for baixa (< 60%), usar `bairro_geo` para um Shape Map agregado:
- GeoJSON: `bairros_osasco.json` (já disponível)
- Chave de join: `NOME_NORM` (bairro_geo)
- Valor: contagem de BOs por bairro
- Não requer lat/long individual

---

## Checklist — Deploy

- [x] **L0** Rodar levantamento (Passo 0) — cobertura e CRS confirmados via `gerar_mapa_vcm.py` (script local ODBC)
- [x] **L1-local** Teste local completo: filtro ponto-em-polígono funcionando, `bairro_geo` OK no PBI Azure Maps (29/06/2026)
- [ ] **L1** Upload de `bairros_osasco.json` para `Files/geo/` no `lh_cidade_inteligente_osasco` (Fabric UI ou AzCopy)
- [x] **L2** `nb_gold_osasco_violencia_mulher_mapa.ipynb` criado em `violencias_mulher_osasc/gold/`
- [x] **L2b** Pipeline `pl_violencia_mulher_osasco.json` atualizado localmente (falta `notebookId` após criar no Fabric)
- [ ] **L3** Criar notebook no Fabric, executar e validar rowcount (% dentro de Osasco)
- [ ] **L3b** Preencher `notebookId` no pipeline JSON e publicar pipeline atualizado no Fabric
- [ ] **L4** Publicar pipeline atualizado no Fabric
- [ ] **L5** Criar aba de mapa no PBI com Azure Maps — lat/long + cor por Rubrica
- [ ] **L6** Adicionar filtros: período · dia · tipo local · fonte
- [ ] **L7** Publicar e comunicar analista de BI Osasco

---

## Riscos

| Risco | Impacto | Mitigação |
|---|---|---|
| Cobertura lat/long < 60% | Mapa esparso — pouco representativo | Fallback para Shape Map por bairro (`bairro_geo`) |
| Coordenadas em EPSG:3857 (metros) | Todos os pontos caem "fora de Osasco" | Verificar range no L0 — lat WGS84 deve ser ~-23.5, não -2.6M |
| `unary_union` muito lento (60 polígonos) | Timeout no notebook Fabric | ~60 polígonos é trivial — < 1s |
| `bairro_geo` nulo para pontos em fronteira | Agrupamento por bairro incompleto | `bairro_geo` é complementar — `Bairro` textual fica disponível como fallback |

---

## Extensão futura — outros datasets com lat/long

Esta mesma abordagem se aplica a qualquer tabela Gold do `lh_cidade_inteligente_osasco` que tenha lat/long. Candidatos:
- SSP dados criminais (se tabela raw tiver coordenadas individuais)
- CRAS / CREAS atendimentos (se endereços forem geocodificados)

O `bairros_osasco.json` e a função `dentro_osasco()` podem ser extraídos para `nb_utils_geo_osasco` e reutilizados via `%run`.

---

*Spec técnico · Acto Cidade Inteligente · Criado em 29/06/2026*
