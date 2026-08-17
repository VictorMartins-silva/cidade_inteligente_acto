---
title: "Geo — Mapa de Bairros Osasco (SSP)"
tags:
  - tipo/tecnico
  - tema/dados-publicos
  - tema/bi-osasco
  - ssp-geolocalizacao
  - geojson
  - powerbi-shapemap
criado: "2026-05-11"
---

# Geo — Mapa de Bairros Osasco para Shape Map (Power BI)

## Contexto

Demanda trazida pela Yasmin: geolocalizar ocorrências SSP de Osasco por bairro para o Power BI. O objetivo era usar o shapefile `geo_div_bairro_mascara` entregue por ela para montar um Shape Map com polígonos coloridos por intensidade de ocorrências.

Após análise, o arquivo JSON exportado do shapefile **não era compatível** com o Power BI — foi necessário gerar um novo arquivo no padrão que já funciona em Santos.

---

## Arquivos Disponíveis

| Arquivo | Localização | Problema |
|---|---|---|
| `geo_div_bairro_mascara (3).json` | `Mapas_SSP_Osasco/geo_div_mascaras/` | Tipo `GeometryCollection`, sem nomes, EPSG:3857 — **não usar** |
| `geo_div_bairro_mascara.shp/.dbf` | `Mapas_SSP_Osasco/geo_div_mascaras/` | Fonte primária válida — uso via Python/QGIS |
| `abairramento_osasco.json` | `Mapas_SSP_Osasco/` | **Usar este** — padrão idêntico ao Santos |
| `mapa_bairros_ocorrencias.csv` | `Mapas_SSP_Osasco/` | Dados de entrada (60 bairros + centroides + total SSP) |

---

## Por que o JSON Original Não Funcionava

O arquivo `geo_div_bairro_mascara (3).json` tinha três problemas críticos:

1. **Tipo `GeometryCollection`** — o Shape Map do Power BI exige `FeatureCollection`
2. **Sem `properties`** — não havia campo de nome para fazer o join com os dados
3. **Coordenadas em EPSG:3857** (metros: `-5.210.859, -2.695.459`) — o GeoJSON exige EPSG:4326 (graus)

---

## Padrão Santos (Referência)

O arquivo `ABAIRRAMENTO_LC1187-2022-SIR.json` que funciona hoje em Santos usa:

```json
{
  "type": "FeatureCollection",
  "features": [{
    "type": "Feature",
    "geometry": { "type": "Polygon", "coordinates": [[...lat/lon...]]} ,
    "properties": { "NOME": "Gonzaga" }
  }]
}
```

- 59 features (bairros)
- Coordenadas em WGS84/EPSG:4326
- Join via `properties.NOME`

---

## Solução — `abairramento_osasco.json`

Gerado via script Python (`gerar_abairramento_osasco.py`) com:

1. **Point-in-polygon**: centroide de cada bairro do CSV projetado para EPSG:3857 → testado contra os 60 polígonos do shapefile
2. **100% match** — todos os 60 bairros pareados sem fallback
3. **Conversão EPSG:3857 → EPSG:4326** nas coordenadas dos polígonos
4. **Montagem como `FeatureCollection`** com `properties.NOME`, `NOME_NORM` e `MUNICIPIO`

```json
{
  "type": "FeatureCollection",
  "features": [{
    "type": "Feature",
    "geometry": { "type": "Polygon", "coordinates": [[...lat/lon...]]} ,
    "properties": {
      "NOME": "Centro",
      "NOME_NORM": "CENTRO",
      "MUNICIPIO": "Osasco"
    }
  }]
}
```

---

## Diferenças em Relação ao Santos

| | Santos | Osasco |
|---|---|---|
| Bairros | 59 | 60 |
| Campo join | `NOME` | `NOME` (ou `NOME_NORM` — mais robusto) |
| Campo extra | — | `NOME_NORM` (uppercase sem acento) |
| Campo extra | — | `MUNICIPIO` |

A presença de `NOME_NORM` é uma vantagem: permite fazer o join por uppercase sem depender de acentuação correta nos dados.

---

## Status no Power BI (11/05/2026)

O Shape Map carregou os polígonos e o mapa ficou **semi-funcional** após as mudanças:
- ✅ Polígonos de Osasco renderizados corretamente
- ✅ Join via `NOME` funcionando
- ⚠️ Bairros inválidos na tabela SSP (`"-"`, `"06851-000"`, `"AREA RURAL"`, etc.) aparecem na tabela lateral mas não no mapa — comportamento esperado
- ⚠️ Validar normalização `NOME` nos dados vs GeoJSON (case sensitivity)

---

## Como Configurar no Power BI

```
Shape Map → Formato → Adicionar mapa → abairramento_osasco.json
Campo Localização → coluna bairro dos dados (deve bater com NOME ou NOME_NORM)
Campo Saturação de cor → total_ocorrencias (agregação: Soma)
```

**Atenção:** o join é case-sensitive. Usar `NOME_NORM` (uppercase) como chave e normalizar a coluna de dados evita esse problema.

---

## Documentação Técnica Completa

Salva em:
`Acto Cidade Inteligente/Mapas_SSP_Osasco/Estrutura_Dados_Geo_PowerBI.md`

Cobre: estrutura de cada formato, diferenças CRS, como configurar o Shape Map, pontos de atenção.

---

## Cruzamento SSP × Shapefile — Números Chave

| Status | Entradas | Ocorrências | % ocorr |
|---|---|---|---|
| Validado | 79 | 22.418 | **96,3%** |
| Não mapeado | 62 | 824 | 3,5% |
| Fora de Osasco | 7 | 23 | 0,1% |
| Inválido | 3 | 7 | 0,0% |

DE-PARAs recomendados para subir para ~98,4%:
- `"JARDIM D ABRIL"` → `"JARDIM D'ABRIL"` (225 ocorr)
- `"PORTAL D OESTE"` → `"PORTAL D'OESTE"` (146 ocorr)
- `"JARDIM MUNHOZ JUNIOR"` → `"MUNHOZ JR."` (117 ocorr)
- `"I.A.P.I."` → `"IAPI"` (44 ocorr)

Documento completo: `Mapas_SSP_Osasco/Comparacao_SSP_vs_Shapefile_Osasco.md`

---

## Links

- [[spec_drive_semana_11_05_2026|Spec Semana 11/05]]
- [[diagnostico_paineis_osasco_publicos|Diagnóstico Painéis Osasco]]
- [[Mapeamento_Tecnico_Dados_Publicos|Mapeamento Técnico]]
