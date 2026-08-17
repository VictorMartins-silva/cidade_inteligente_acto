---
title: Mapas SSP Osasco — Documentação Técnica
date: 2026-06-17
tags:
  - municipio/osasco
  - ferramenta/python
  - ferramenta/powerbi
  - tema/dados-publicos
  - tipo/pipeline
projeto: dados-publicos
fonte: ssp-sp
status: ativo
---
# Mapas_SSP_Osasco â€” DocumentaÃ§Ã£o TÃ©cnica

  

## O que Ã© esta pasta

  

Pipeline geoespacial local que cruza os dados de ocorrÃªncias criminais da **SSP-SP** (Secretaria de SeguranÃ§a PÃºblica) com a malha oficial de bairros de Osasco e exporta os resultados prontos para visualizaÃ§Ã£o no **Power BI** (visuais de mapa).

  

O fluxo resolve um problema central: a SSP registra nomes de bairros em texto livre, com abreviaÃ§Ãµes e grafias inconsistentes, enquanto o shapefile oficial usa nomenclatura padronizada. Este pipeline faz a normalizaÃ§Ã£o e valida a cobertura geogrÃ¡fica antes de exportar.

  

---

  

## Estrutura de arquivos

> **Reorganização em 17/06/2026** — pastas consolidadas por papel. Ver CLAUDE.md do projeto para detalhes completos.

```text
Mapas_SSP_Osasco/
│
├── shapefiles/                    ← fontes originais (EPSG:31983/3857 — prefeitura)
│   ├── bairros/                   geo_div_bairro_mascara.*
│   ├── loteamento/                vw_geo_loteamento.*
│   ├── macrozoneamento/           geo_macrozoneamento.*
│   ├── mancha_zoneamento/         geo_mancha_zoneamento.*
│   └── assistencia_cras/          geo_div_bairro_assistencia_cras.*
│
├── geojson/                       ← GeoJSONs prontos para PBI (EPSG:4326)
│   ├── bairros_osasco.json        join: NOME_NORM
│   ├── loteamento_osasco.json     join: NOME_LOTEAMENTO
│   ├── macrozoneamento_osasco.json  join: SIGLA
│   ├── mancha_zoneamento_osasco.json  join: ZONA_2024
│   ├── assistencia_cras_osasco.json  join: CRAS
│   └── territorios_cras_osasco.json
│
├── tabelas_pbi/                   ← CSVs de atributos para modelo Power BI
│   ├── tb_bairros.csv  ·  tb_cras.csv
│   ├── tb_loteamento.csv  ·  tb_macrozoneamento.csv  ·  tb_mancha_zoneamento.csv
│   └── tb_vulnerabilidade_bairros.csv  ·  tb_vulnerabilidade_cras.csv
│
├── overlays/                      ← camadas auxiliares (rodovias, rios, labels)
│
├── dados_ssp/                     ← saídas do pipeline SSP (ocorrências criminais)
│   ├── abairramento_osasco.json   GeoJSON principal Shape Map
│   ├── mapa_bairros_ocorrencias.csv
│   ├── ssp_para_powerbi.csv
│   ├── bairros_osasco_centroids.csv
│   └── validacao_bairros_ssp_vs_shapefile.csv
│
├── scripts/                       ← todos os scripts Python
│   ├── converter_shapefiles_osasco.py  ← shapefiles/ → geojson/ + tabelas_pbi/
│   ├── gerar_mapa_pbi.py              ← all-in-one: Fabric → CSV
│   └── [outros scripts]
│
└── doc/                           ← documentação técnica
    ├── estado_atual_loteamento_zoneamento.md
    ├── Estrutura_Dados_Geo_PowerBI.md
    └── Comparacao_SSP_vs_Shapefile_Osasco.md
```

---

  

## Conceitos: mapas, camadas e formatos geoespaciais

  

Esta seÃ§Ã£o explica os conceitos fundamentais usados em todo o pipeline. Entender o que Ã© cada formato e para que serve evita confusÃ£o na hora de usar os arquivos no Power BI ou em scripts Python.

  

### O que Ã© um dado vetorial (vs. raster)

  

Existem dois grandes paradigmas de dados geoespaciais:

  

- **Raster** â€” uma grade de pixels (como uma foto de satÃ©lite). Cada pixel tem um valor (cor, temperatura, altitude). NÃ£o Ã© o que usamos aqui.

- **Vetorial** â€” geometrias matemÃ¡ticas: pontos, linhas e polÃ­gonos. Ã‰ o modelo deste pipeline.

  

Um bairro, por exemplo, Ã© representado como um **polÃ­gono** â€” uma sequÃªncia de coordenadas (lat/lon) que formam seu contorno. O centroide de um bairro Ã© um **ponto** (lat/lon do centro geomÃ©trico do polÃ­gono).

  

### Tipos de geometria

  

| Tipo | DescriÃ§Ã£o | Exemplo neste projeto |

|---|---|---|

| **Ponto** (Point) | Uma coordenada lat/lon | Centroide de um bairro |

| **Linha** (LineString) | SequÃªncia de pontos conectados | NÃ£o usado aqui |

| **PolÃ­gono** (Polygon) | Ãrea fechada por um contorno | Limite de um bairro |

| **MultiPolÃ­gono** (MultiPolygon) | VÃ¡rios polÃ­gonos num mesmo registro | Bairros com enclaves |

  

### O que Ã© projeÃ§Ã£o / CRS (Coordinate Reference System)

  

Coordenadas geogrÃ¡ficas precisam de um sistema de referÃªncia para ter significado. Os dois mais comuns:

  

| CRS | CÃ³digo EPSG | Unidade | Uso |

|---|---|---|---|

| **WGS84** | EPSG:4326 | Graus (lat/lon) | GPS, Google Maps, Power BI, GeoJSON |

| **Web Mercator** (Pseudo-Mercator) | EPSG:3857 | Metros | OpenStreetMap, Google Maps tiles, shapefiles de prefeituras |

  

O shapefile `geo_div_bairro_mascara` estÃ¡ em **EPSG:3857** (metros). O Power BI e o GeoJSON exigem **EPSG:4326** (graus). Por isso todos os scripts fazem a conversÃ£o:

  

```python

shape = gpd.read_file(SHAPE_PATH) Â  Â  Â  Â  Â # lÃª em EPSG:3857

shape_wgs84 = shape.to_crs(epsg=4326) Â  Â  Â # converte para lat/lon

```

  

Sem esta conversÃ£o, os polÃ­gonos aparecem em posiÃ§Ãµes erradas ou o mapa nÃ£o renderiza.

  

---

  

### Shapefile (.shp)

  

O formato mais antigo e ainda mais comum para dados geoespaciais vetoriais, criado pela Esri nos anos 1990. **Nunca Ã© um arquivo Ãºnico** â€” Ã© sempre um conjunto de arquivos com o mesmo nome-base e extensÃµes diferentes, todos obrigatÃ³rios:

  

| ExtensÃ£o | ConteÃºdo | ObrigatÃ³rio |

|---|---|---|

| `.shp` | Geometrias (os polÃ­gonos em si) | Sim |

| `.dbf` | Tabela de atributos (colunas como `nom_bairro`, `area_m2`) | Sim |

| `.shx` | Ãndice espacial (acelera consultas por localizaÃ§Ã£o) | Sim |

| `.prj` | DefiniÃ§Ã£o da projeÃ§Ã£o (CRS) em formato WKT | Quase sempre |

| `.cst` | Charset (codificaÃ§Ã£o dos textos no .dbf) | Opcional |

  

O arquivo `.prj` deste projeto contÃ©m:

```

PROJCS["WGS 84 / Pseudo-Mercator", ... AUTHORITY["EPSG","3857"]]

```

Isso indica que as coordenadas estÃ£o em metros na projeÃ§Ã£o Web Mercator.

  

**Como o Python lÃª um shapefile:**

```python

import geopandas as gpd

  

shape = gpd.read_file("geo_div_bairro_mascara.shp")

# GeoPandas lÃª automaticamente .dbf (atributos) e .prj (projeÃ§Ã£o)

# O resultado Ã© um DataFrame com uma coluna especial chamada "geometry"

print(shape.columns)

# ['nom_bairro', 'area_m2', 'totpopcens', 'geometry']

```

  

**LimitaÃ§Ãµes do shapefile:**

- Nomes de colunas limitados a 10 caracteres (heranÃ§a do dBASE)

- NÃ£o suporta tipos complexos (listas, JSON aninhado)

- MÃºltiplos arquivos = risco de perder um e corromper o dado

  

---

  

### GeoJSON (.geojson)

  

Formato moderno baseado em JSON, aberto e legÃ­vel por humanos. Um Ãºnico arquivo contÃ©m tanto as geometrias quanto os atributos, com suporte nativo a UTF-8.

  

**Estrutura bÃ¡sica:**

```json

{

Â  "type": "FeatureCollection",

Â  "features": [

Â  Â  {

Â  Â  Â  "type": "Feature",

Â  Â  Â  "geometry": {

Â  Â  Â  Â  "type": "Polygon",

Â  Â  Â  Â  "coordinates": [[[-46.778, -23.534], [-46.779, -23.535], ...]]

Â  Â  Â  },

Â  Â  Â  "properties": {

Â  Â  Â  Â  "bairro_norm": "CENTRO",

Â  Â  Â  Â  "nom_bairro": "Centro",

Â  Â  Â  Â  "area_m2": 1234567.89,

Â  Â  Â  Â  "populacao_censo": 45000

Â  Â  Â  }

Â  Â  }

Â  ]

}

```

  

**Sempre em EPSG:4326** â€” a especificaÃ§Ã£o GeoJSON define que as coordenadas sÃ£o sempre em graus (lon, lat), na ordem longitude primeiro. Por isso a conversÃ£o de CRS Ã© obrigatÃ³ria antes de exportar para GeoJSON.

  

**Uso neste projeto:** o arquivo `bairros_osasco.geojson` Ã© carregado no visual **Shape Map** do Power BI. O PBI lÃª as geometrias dos polÃ­gonos e usa a coluna `bairro_norm` como chave para colorir cada bairro com base nos dados da tabela de ocorrÃªncias.

  

---

  

### CSV com lat/lon (centroides)

  

NÃ£o Ã© um formato geoespacial nativo, mas Ã© suficiente para visuais de **pontos** (bolhas, marcadores) no Power BI e outras ferramentas. Cada linha Ã© um ponto com latitude e longitude explÃ­citas.

  

**Centroide** Ã© o ponto geomÃ©trico central de um polÃ­gono â€” calculado como:

```python

shape["latitude"] Â = shape.geometry.centroid.y Â  # y = latitude

shape["longitude"] = shape.geometry.centroid.x Â  # x = longitude

```

  

**AtenÃ§Ã£o:** em geometrias complexas (bairros em formato de L, por exemplo), o centroide pode cair fora do polÃ­gono. Para este uso (mapa de bolhas), isso Ã© aceitÃ¡vel.

  

O arquivo `bairros_osasco_centroids.csv` e `mapa_bairros_ocorrencias.csv` usam este modelo â€” um ponto por bairro com o total de ocorrÃªncias, pronto para um mapa de bolhas onde o tamanho da bolha representa a quantidade.

  

---

  

### Como os formatos se relacionam neste projeto

  

```

geo_div_bairro_mascara.shp Â  (shapefile â€” fonte primÃ¡ria, EPSG:3857)

Â  Â  Â  Â  Â  â”‚

Â  Â  Â  Â  Â  â”‚ Â gpd.read_file() + .to_crs(4326)

Â  Â  Â  Â  Â  â”‚

Â  Â  Â  Â  Â  â”œâ”€â”€â–º bairros_osasco.geojson Â  Â  Â  Â  Â PolÃ­gonos â†’ Shape Map PBI

Â  Â  Â  Â  Â  â”‚

Â  Â  Â  Â  Â  â””â”€â”€â–º geometry.centroid â†’ lat/lon

Â  Â  Â  Â  Â  Â  Â  Â  Â  Â  â”‚

Â  Â  Â  Â  Â  Â  Â  Â  Â  Â  â””â”€â”€â–º bairros_osasco_centroids.csv Â  Â Pontos â†’ Mapa de bolhas PBI

Â  Â  Â  Â  Â  Â  Â  Â  Â  Â  â””â”€â”€â–º mapa_bairros_ocorrencias.csv Â  Â Pontos + dados SSP â†’ PBI

```

  

---

  

### Qual formato usar para cada visual do Power BI

  

| Visual Power BI | Formato necessÃ¡rio | Arquivo neste projeto |

|---|---|---|

| **Shape Map** (polÃ­gonos coloridos) | GeoJSON com geometrias | `bairros_osasco.geojson` |

| **Mapa / Azure Maps** (bolhas por localizaÃ§Ã£o) | CSV com `latitude` e `longitude` | `mapa_bairros_ocorrencias.csv` |

| **Mapa de Preenchimento** (choropleth nativo) | Nomes reconhecidos pelo Bing Maps | NÃ£o aplicÃ¡vel â€” bairros de Osasco nÃ£o sÃ£o reconhecidos nativamente |

  

O Shape Map exige que o GeoJSON tenha uma propriedade de texto para fazer o join com os dados â€” neste projeto Ã© `bairro_norm`. No Power BI, vocÃª configura essa coluna como "LocalizaÃ§Ã£o" e ela Ã© usada para parear cada polÃ­gono com a linha correspondente na tabela de dados.

  

---

  

## O shapefile `geo_div_bairro_mascara`

  

Malha vetorial oficial dos bairros de Osasco, com as seguintes colunas relevantes:

  

| Coluna | Tipo | DescriÃ§Ã£o |

|---|---|---|

| `nom_bairro` | string | Nome oficial do bairro |

| `area_m2` | float | Ãrea do polÃ­gono em metros quadrados |

| `totpopcens` | float | PopulaÃ§Ã£o total pelo Censo |

| `geometry` | polygon | PolÃ­gono do bairro |

  

**ProjeÃ§Ã£o original:** EPSG:3857 (Web Mercator, unidade em metros).

Todos os scripts convertem para **EPSG:4326** (WGS84, lat/lon em graus) antes de exportar para o Power BI.

  

---

  

## Fonte de dados: SSP via Fabric

  

Os dados de ocorrÃªncias sÃ£o lidos da tabela Gold do Lakehouse `lh_dados_publicos`:

  

```sql

SELECT bairro, SUM(quantidade_ocorrencias) AS total_ocorrencias

FROM gold.ssp_dados_criminais

WHERE UPPER(nome_municipio_circunscricao) = 'OSASCO'

Â  AND bairro IS NOT NULL AND bairro <> ''

GROUP BY bairro

```

  

**ConexÃ£o:** SQL Endpoint do Microsoft Fabric via `pyodbc` com autenticaÃ§Ã£o `ActiveDirectoryInteractive` (login interativo no browser).

  

```

Server: ena6obg6j2cevcppw7dn7yu57a-knnp5frchjbujdik4l3nmgrgsa.datawarehouse.fabric.microsoft.com

Database: lh_dados_publicos

```

  

---

  

## O problema de normalizaÃ§Ã£o de nomes (DE-PARA)

  

A SSP usa grafias inconsistentes que nÃ£o batem diretamente com o shapefile. O dicionÃ¡rio `DEPARA` resolve as principais divergÃªncias:

  

| SSP (original) | Shapefile (canÃ´nico) | Motivo |

|---|---|---|

| `INDUSTRIAL ALTINO` | `INDL. ALTINO` | Shapefile abrevia "Industrial" â†’ "Indl." |

| `MUNHOZ JUNIOR` / `MUNHOZ JR` | `MUNHOZ JR.` | PadronizaÃ§Ã£o de sufixo |

| `JARDIM ALIANCA` | `ALIANCA` | Shapefile omite prefixo "Jardim" |

| `KM DEZOITO` / `QUILOMETRO DEZOITO` | `KM 18` | Forma numÃ©rica vs. por extenso |

| `PARQUE DAS BANDEIRAS` | `BANDEIRAS` | OmissÃ£o de prefixo "Parque" |

  

AlÃ©m disso, hÃ¡ bairros **sabidamente fora de Osasco** (erros de geolocalizaÃ§Ã£o na SSP) que sÃ£o excluÃ­dos:

  

```

LAPA, JAGUARA, JAGUARE, RIO PEQUENO, VILA DALVA, VILA LEOPOLDINA, VILA JAGUARA

```

  

E entradas **invÃ¡lidas** (CEP digitado no campo de bairro, traÃ§o):

  

```

"-", "06851-000", "AREA RURAL"

```

  

---

  

## Scripts â€” o que cada um faz e quando usar

  

### 1. `validacao_bairros_ssp_shapefile.py`

**Quando usar:** diagnÃ³stico de cobertura. Roda apÃ³s uma atualizaÃ§Ã£o da tabela SSP para verificar se novos bairros surgiram sem correspondÃªncia no shapefile.

  

**O que faz:**

1. LÃª o shapefile e normaliza `nom_bairro` (uppercase, sem acento)

2. Conecta ao Fabric e busca bairros Ãºnicos com ocorrÃªncias em Osasco

3. Aplica o DE-PARA e exclui invÃ¡lidos/fora de Osasco

4. Cruza os dois conjuntos e reporta: match, sÃ³ na SSP, sÃ³ no shapefile, e % de cobertura

5. Exporta `validacao_bairros_ssp_vs_shapefile.csv` com status de cada bairro

  

**SaÃ­da no terminal:**

```

âœ… Match (SSP âˆ© Shapefile): Â  XX

âŒ SÃ³ na SSP (sem geoloc): Â  Â XX

ðŸ“Š Cobertura: Â  Â  Â  Â  Â  Â  Â  Â  XX%

```

  

---

  

### 2. `gerar_geojson.py`

**Quando usar:** atualizar o arquivo de polÃ­gonos para o visual **Shape Map** do Power BI (nÃ£o busca dados da SSP â€” sÃ³ processa o shapefile).

  

**O que faz:**

1. LÃª o shapefile

2. Converte EPSG:3857 â†’ EPSG:4326

3. Normaliza `nom_bairro` â†’ `bairro_norm` (chave de join)

4. Exporta `bairros_osasco.geojson` com colunas: `bairro_norm`, `nom_bairro`, `area_m2`, `totpopcens`, `geometry`

  

---

  

### 3. `exportar_para_powerbi.py`

**Quando usar:** pipeline completo de exportaÃ§Ã£o. Gera todos os arquivos necessÃ¡rios para o Power BI de uma sÃ³ vez, sem buscar dados no Fabric (usa o CSV de validaÃ§Ã£o jÃ¡ existente como entrada).

  

**PrÃ©-requisito:** `validacao_bairros_ssp_vs_shapefile.csv` jÃ¡ gerado.

  

**O que faz e gera:**

  

| Arquivo gerado | Uso no Power BI |

|---|---|

| `bairros_osasco.geojson` | Visual Shape Map (polÃ­gonos por bairro) |

| `bairros_osasco_centroids.csv` | Visual de mapa de bolhas (lat/lon por bairro) |

| `ssp_para_powerbi.csv` | Dados SSP com lat/lon, status e categoria de cor |

  

**Colunas do `ssp_para_powerbi.csv`:**

  

| Coluna | DescriÃ§Ã£o |

|---|---|

| `municipio` | Sempre "OSASCO" |

| `bairro` | Nome original da SSP |

| `bairro_norm` | Nome normalizado (uppercase, sem acento) |

| `bairro_norm_v2` | Nome apÃ³s DE-PARA (chave de join com shapefile) |

| `total_ocorrencias` | Total de ocorrÃªncias no bairro |

| `status` | `Validado` / `Nao mapeado` / `Fora de Osasco` / `Invalido` |

| `latitude` | Lat do centroide do bairro (vazio se nÃ£o mapeado) |

| `longitude` | Lon do centroide do bairro (vazio se nÃ£o mapeado) |

| `categoria` | Prefixo numÃ©rico para ordenaÃ§Ã£o no PBI (`1_Validado`, `2_Nao mapeado`, etc.) |

  

---

  

### 4. `gerar_mapa_pbi.py`

**Quando usar:** pipeline all-in-one. Busca dados diretamente no Fabric, cruza com o shapefile e gera `mapa_bairros_ocorrencias.csv` em um Ãºnico passo. Ideal para atualizaÃ§Ã£o recorrente.

  

**O que gera:**

  

`mapa_bairros_ocorrencias.csv` â€” um arquivo Ãºnico com todos os bairros do shapefile + total de ocorrÃªncias SSP (0 para bairros sem ocorrÃªncia registrada):

  

| Coluna | DescriÃ§Ã£o |

|---|---|

| `bairro_norm` | Nome normalizado (chave) |

| `bairro` | Nome oficial do shapefile |

| `latitude` | Centroide lat |

| `longitude` | Centroide lon |

| `area_m2` | Ãrea em mÂ² |

| `populacao_censo` | PopulaÃ§Ã£o (Censo) |

| `total_ocorrencias` | Total de ocorrÃªncias SSP (0 se sem dado) |

  

---

  

## Fluxo recomendado de atualizaÃ§Ã£o

  

```

1. [Fabric] gold.ssp_dados_criminais atualizada

Â  Â  Â  Â  Â â†“

2. [Local] python gerar_mapa_pbi.py

Â  Â â†’ Conecta no Fabric (login interativo)

Â  Â â†’ Gera mapa_bairros_ocorrencias.csv

Â  Â  Â  Â  Â â†“

3. [Power BI] Importar mapa_bairros_ocorrencias.csv

Â  Â â†’ Visual de mapa de bolhas: latitude/longitude + total_ocorrencias

```

  

Para o visual de polÃ­gonos (Shape Map), o `bairros_osasco.geojson` Ã© estÃ¡tico (sÃ³ muda se o shapefile mudar) â€” nÃ£o precisa ser regerado a cada atualizaÃ§Ã£o de dados.

  

---

  

## DependÃªncias Python (ambiente local)

  

```

geopandas Â  Â  Â # leitura e manipulaÃ§Ã£o de shapefiles/GeoJSON

pyodbc Â  Â  Â  Â  # conexÃ£o com SQL Endpoint do Fabric

pandas Â  Â  Â  Â  # manipulaÃ§Ã£o de dados

unidecode Â  Â  Â # remoÃ§Ã£o de acentos para normalizaÃ§Ã£o de nomes

```

  

InstalaÃ§Ã£o:

```bash

pip install geopandas pyodbc pandas unidecode

```

  

O `pyodbc` requer o driver **ODBC Driver 18 for SQL Server** instalado no Windows.

  

---

  

## LimitaÃ§Ãµes conhecidas

  

- **`KM 18`** nÃ£o tem centroide no arquivo de saÃ­da (bairro nÃ£o encontrado no shapefile apÃ³s DE-PARA). O bairro existe na SSP mas pode estar registrado com geometria diferente â€” requer verificaÃ§Ã£o manual.

- O shapefile cobre apenas Osasco. Bairros de municÃ­pios vizinhos registrados erroneamente na SSP sÃ£o filtrados pela lista `FORA_DE_OSASCO` mas nÃ£o sÃ£o corrigidos.

- A conexÃ£o com o Fabric (`ActiveDirectoryInteractive`) abre uma janela de login no browser â€” nÃ£o Ã© possÃ­vel automatizar sem service principal.

## Relacionados

- [[Documentação_Fabric/Osasco/geo_osasco_ssp_dados_criminais|Geo Osasco — SSP Dados Criminais]]
- [[Documentação_Fabric/Osasco/00_INDEX_OSASCO|Índice Osasco]]
