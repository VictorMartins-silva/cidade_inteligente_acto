---
title: "Painel Loteamento / Zoneamento — Osasco (Azure Maps)"
tags:
  - osasco
  - loteamento
  - zoneamento
  - power-bi
  - azure-maps
  - tipo/spec
municipio: Osasco
aliases:
  - loteamento osasco
  - zoneamento osasco
  - painel loteamento
atualizado: 2026-06-17
relacionados:
  - "[[Documentação_Fabric/Osasco/MAPEAMENTO_PAINEIS_PBI_OSASCO]]"
  - "[[Documentação_Fabric/Osasco/mapas-ssp-osasco]]"
  - "[[Documentação_Fabric/Osasco/00_INDEX_OSASCO]]"
---

# Painel Loteamento / Zoneamento — Osasco

> Próximo painel a publicar no portal público de Osasco (embed).  
> Painel anterior concluído: `bi_osasco_mapas_vulnerabilidade` ✅

---

## Estrutura do painel

| Aba | Conteúdo | Visual PBI |
| --- | --- | --- |
| Loteamento | Polígonos de loteamentos com status (Aprovado / Regularizado / Indefinido) | Azure Maps — Reference Layer |
| Zoneamento | Mancha de zoneamento 2024 por categoria | Azure Maps — Reference Layer |
| Macrozoneamento | 12 macrozonas municipais | Azure Maps — Reference Layer (opcional, 2ª visual ou 3ª aba) |

---

## Estado dos dados: já concluído

O script `scripts/converter_shapefiles_osasco.py` já processou todos os layers. Arquivos prontos em:

| Camada | GeoJSON | Tabela PBI | Chave de join |
| --- | --- | --- | --- |
| Loteamentos | `geojson/loteamento_osasco.json` | `tabelas_pbi/tb_loteamento.csv` | `NOME_LOTEAMENTO` |
| Zoneamento (mancha) | `geojson/mancha_zoneamento_osasco.json` | `tabelas_pbi/tb_mancha_zoneamento.csv` | `ZONA_2024` |
| Macrozoneamento | `geojson/macrozoneamento_osasco.json` | `tabelas_pbi/tb_macrozoneamento.csv` | `SIGLA` |

Todos em **EPSG:4326 (WGS84)** — conversão dos shapefiles originais já feita.

### Atributos disponíveis por camada

**`tb_loteamento.csv`**
- `NOME_LOTEAMENTO` — chave de join
- `situacao` — `Aprovado` / `Aprovado PMO` / `aprovado/registrado` / `Aprovado / Registrado` / `Regularizado` / `Indefinido`
- `bairro` — bairro de referência (nem sempre preenchido)
- `ano_aprovacao` — ano de aprovação do loteamento
- `area_m2` — área em m²

**`tb_mancha_zoneamento.csv`**
- `ZONA_2024` — chave de join (ex: `ZCE 1`, `ZEPAM 3`, `ZEIS`)
- `ZONA_ABREV` — abreviação da zona
- `usos` — usos permitidos (ex: `R1, R2.1, R3, B1, B2, M`)
- `to_perc` — taxa de ocupação (%)
- `tp_perc` — taxa de permeabilidade (%)
- `lote_min_m2` — área mínima de lote
- `frente_min_m` — frente mínima de lote

**`tb_macrozoneamento.csv`**
- `SIGLA` — chave de join (ex: `MDE`, `MDTP`, `MUC`, `MPA`, `MCADS`, `MDU`)
- `descricao` — nome completo da macrozona
- `ca_max` — coeficiente de aproveitamento máximo
- `densidade_hab_ha` — densidade hab/ha
- `total_edificacoes` — total de edificações na zona

---

## Configuração no Power BI (Azure Maps)

### Aba Loteamento

1. Adicionar visual **Azure Maps** → ícone de engrenagem → **Reference Layer** → importar `geojson/loteamento_osasco.json`
2. Importar `tabelas_pbi/tb_loteamento.csv` como tabela no modelo
3. **Localização** = `NOME_LOTEAMENTO`
4. **Legenda** = `situacao` — gera cores automáticas por status
5. **Tooltip**: `ano_aprovacao`, `area_m2`, `bairro`
6. Estilo de fundo sugerido: **Satellite** (aerofoto) — faz sentido para lotes

> [!tip] Normalizar `situacao`
> O campo tem variações de caixa (`Aprovado` vs `aprovado/registrado`). Criar coluna calculada no PBI:
> ```
> situacao_norm = UPPER(TRIM(tb_loteamento[situacao]))
> ```
> e usar `situacao_norm` na Legenda para colapsar duplicatas.

### Aba Zoneamento

1. Reference Layer → `geojson/mancha_zoneamento_osasco.json`
2. Importar `tabelas_pbi/tb_mancha_zoneamento.csv`
3. **Localização** = `ZONA_2024`
4. **Legenda** = `ZONA_2024` (cada zona recebe uma cor)
5. Estilo de fundo sugerido: **Road** (mais limpo — o zoneamento já é denso visualmente)
6. Opacidade dos polígonos: **~80%** para o fundo aparecer

### Macrozoneamento (opcional)

- Reference Layer → `geojson/macrozoneamento_osasco.json`
- Tabela: `tabelas_pbi/tb_macrozoneamento.csv`
- **Localização** = `SIGLA`, **Legenda** = `descricao`
- Pode ser uma 3ª aba ou um toggle dentro da aba Zoneamento

---

## Shape Map vs Azure Maps

O painel atual (`bi_osasco_mapas_loteamento_zoneamento.pdf`) usa **Shape Map**. A migração para Azure Maps traz:

| Aspecto | Shape Map (atual) | Azure Maps (novo) |
| --- | --- | --- |
| Fundo de mapa | Neutro (sem detalhe) | Satélite / Rua / Dark |
| WMS externo | Necessário para aerofoto | Nativo |
| Reference Layer | ❌ (só GeoJSON na config do visual) | ✅ suporta GeoJSON de polígonos |
| Interatividade | Baixa | Alta (zoom, pan, tooltip rico) |
| Legenda automática | Sim | Sim |

---

## Checklist de execução

- [ ] PBI Desktop → aba Loteamento → Azure Maps → Reference Layer → `loteamento_osasco.json`
- [ ] Importar `tb_loteamento.csv` → criar coluna `situacao_norm`
- [ ] Localização = `NOME_LOTEAMENTO`, Legenda = `situacao_norm`
- [ ] PBI Desktop → aba Zoneamento → Azure Maps → Reference Layer → `mancha_zoneamento_osasco.json`
- [ ] Importar `tb_mancha_zoneamento.csv`
- [ ] Localização = `ZONA_2024`, Legenda = `ZONA_2024`, fundo = Road, opacidade = 80%
- [ ] (Opcional) Aba Macrozoneamento com `macrozoneamento_osasco.json`
- [ ] Criar legenda visual (caixas de texto + cores) replicando o QGIS
- [ ] Publicar workspace → configurar embed no portal Osasco

---

## Shapefiles fonte

Shapefiles originais disponíveis em `Mapas_SSP_Osasco/shapefiles/` do projeto local:

| Pasta | Shapefile | CRS original |
| --- | --- | --- |
| `shapefiles/loteamento/` | `vw_geo_loteamento.*` | EPSG:31983 (SIRGAS UTM 23S) |
| `shapefiles/mancha_zoneamento/` | `geo_mancha_zoneamento.*` | EPSG:31983 |
| `shapefiles/macrozoneamento/` | `geo_macrozoneamento.*` | EPSG:31983 |

Para converter novos shapefiles: `scripts/converter_shapefiles_osasco.py` — lê `shapefiles/` e gera `geojson/` + `tabelas_pbi/` automaticamente.
