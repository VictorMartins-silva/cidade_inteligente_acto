---
title: "Geo Osasco — Projeto de Geolocalização de Dados Criminais"
tags:
  - geo
  - osasco
  - dados-criminais
  - ssp
  - fabric
  - mapa
aliases:
  - projeto geo osasco
  - dados criminais osasco
  - ssp osasco
relacionados:
  - "[[Documentação_Fabric/Dados Públicos/00_INDEX_DADOS_PUBLICOS]]"
  - "[[Conhecimento/Fabric/analise-produto-acto-cidade-inteligente]]"
  - "[[Documentação_Fabric/Osasco/00_INDEX_OSASCO]]"
---

# Geo Osasco — Geolocalização de Dados Criminais SSP-SP

> **Pasta de desenvolvimento:** `c:\Users\victor.silva\Desktop\PROJETOS\Mapeamento_fabric\geo_osasco\`  
> **Lakehouse:** `lh_dados_publicos`  
> **Fonte:** API SSP-SP (Secretaria de Segurança Pública)  
> **Status:** ✅ Em desenvolvimento (2 notebooks Gold + utils)

---

## 📍 Projeto

**Objetivo:** Mapear registros criminais do estado de São Paulo com foco em **Osasco**, enriquecendo coordenadas (latitude/longitude) com **bairro_geo** derivado de shapefile municipal.

**Lógica:**
1. **Bronze:** SSP fornece dados criminais brutos (5.1M linhas − estado inteiro)
2. **Silver:** Limpeza, tipificação criminal, normalização − `silver.ssp_dados_criminais` (~1.2M linhas com coords)
3. **Gold:** Filtro geo para Osasco + join bairro_geo + validação

---

## 🗂️ Estrutura de Arquivos

```
geo_osasco/
├── nb_utils_geo_osasco.ipynb                    ← ⭐ Utilitário compartilhado
├── nb_gold_osasco_ssp_dados_criminais_geo.ipynb ← 📍 GOLD Principal (1.2M → ~X linhas)
├── nb_gold_osasco_ssp_criminais_geo.ipynb        ← 📍 GOLD Alternativo (5.1M → ~Y linhas)
├── nb_gold_osasco_flagrantes_mapa.ipynb          ← 🚨 GOLD Flagrantes
├── nb_levantamento_geo_dados_publicos.ipynb      ← 🔍 Exploração (pesquisa)
├── levantamento_geo_lakehouse.py                 ← 🐍 Script Python (diagnóstico)
├── output/                                       ← Artefatos locais
└── OBSIDIAN_CONEXAO.md                          ← Documentação (também no vault)
```

---

## 📊 Tabelas — Relação Silver ↔ Gold

### `silver.ssp_dados_criminais`
**Origem:** API SSP-SP (todos os estados, ~1.2M linhas com coordenadas válidas)

| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `ano_bo` | int | Ano do boletim |
| `data_ocorrencia_bo` | date | Data da ocorrência |
| `mes_estatistica` | int | Mês para agregação |
| `ano_estatistica` | int | Ano para agregação |
| **`natureza_apurada`** | string | ⭐ Tipificação criminal (CPF-apurado) |
| `descr_conduta` | string | Descrição da conduta |
| `nome_municipio_circunscricao` | string | Município da circunscrição |
| `descr_subtipolocal` | string | Tipo de local (rua, residência, etc.) |
| `logradouro` | string | Rua/avenida |
| `numero_logradouro` | int | Número do logradouro |
| `bairro` | string | Bairro (dados brutos SSP) |
| **`latitude`** | float | Coordenada geográfica |
| **`longitude`** | float | Coordenada geográfica |

### `gold.osasco_ssp_dados_criminais_geo`
**Origem:** Silver filtrado para Osasco + join shapefile

| Coluna | Tipo | Descrição | Adicionado por |
|--------|------|-----------|---|
| (todas de Silver) | — | Colunas herdadas | — |
| **`bairro_geo`** | string | ⭐ Bairro derivado do shapefile (60 bairros válidos) | `filtrar_para_osasco()` |

**Filtro aplicado:**
```
1. nome_municipio_circunscricao = 'OSASCO'
2. -23.75 < latitude < -23.35 AND -47.05 < longitude < -46.55
3. Point(lon, lat).within(poligono_osasco)  ← Shapefile municipal
→ Resultado: ~X linhas mapeadas para 60 bairros
```

---

## 🔧 Utilitário Geo — `nb_utils_geo_osasco`

**Uso:**
```python
%run ./nb_utils_geo_osasco
```

**Expõe:**

| Objeto | Tipo | Descrição |
|--------|------|-----------|
| `poligono_osasco` | `shapely.Polygon` | Contorno do município (union dos 60 bairros) |
| `gdf_bairros_osasco` | `GeoDataFrame` | 60 polígonos com coluna `NOME_NORM` |
| `filtrar_para_osasco(df, col_lat, col_lon)` | função | Filtra + adiciona `bairro_geo` |

**Pré-requisito:**
```
Files/geo/bairros_osasco.json
```

No lakehouse padrão (`lh_dados_publicos`). Arquivo contém:
- FeatureCollection com 60 Features (bairros)
- Cada Feature tem properties `NOME_NORM` (nome do bairro) + geometry (Polygon)

---

## 📓 Notebooks Detalhados

### 1️⃣ `nb_gold_osasco_ssp_dados_criminais_geo.ipynb` (⭐ PRINCIPAL)

**Objetivo:** Ouro (Gold) para dataset SSP Dados Criminais com geolocalização

**Fluxo:**
```
1. %run ./nb_utils_geo_osasco                  (injeta utils geo)
2. Ler silver.ssp_dados_criminais (~1.2M)
3. filtrar_para_osasco() → Osasco + bairro_geo
4. Assert len > 0
5. Gravar gold.osasco_ssp_dados_criminais_geo
6. Validação: Bbox, cobertura bairro (≥80%), distribuição, série temporal, top naturezas
```

**Padrão de validação:**
- 📍 **Bbox:** lat [-23.75, -23.35], lon [-47.05, -46.55]
- 🏘️  **bairro_geo:** ≥80% preenchido
- 📅 **Série temporal:** Distribuição por ano
- ⚖️  **Naturezas apuradas:** Top 10 crimes

**Schema Gold:** Vide tabela Silver + coluna `bairro_geo`

---

### 2️⃣ `nb_gold_osasco_ssp_criminais_geo.ipynb` (Alternativo)

**Diferença:** Usa `silver.ssp_criminais` (5.1M linhas, schema ligeiramente diferente)

> ⚠️ **Nota:** `ssp_criminais` vs `ssp_dados_criminais`  
> `ssp_criminais`: 5.1M linhas − dataset original completo  
> `ssp_dados_criminais`: 1.2M linhas − subset com `natureza_apurada` detalhada

**Usar um ou outro conforme necessidade:**
- Se precisa **cobertura total** → `ssp_criminais` (5.1M)
- Se precisa **tipificação criminal detalhada** → `ssp_dados_criminais` (1.2M, recomendado para mapa)

---

### 3️⃣ `nb_gold_osasco_flagrantes_mapa.ipynb` (Flagrantes)

**Objetivo:** Subset específico para flagrantes (crimes em flagrante)

**Padrão:** Filtro adicional + validação específica para flagrantes

---

## 🔍 Notebooks de Exploração

### `nb_levantamento_geo_dados_publicos.ipynb`
- Diagnóstico da ingestão IBGE/SIDRA
- Validação de clusters (Santos, Osasco, Mauá)
- Debugging de mismatches geo

### `levantamento_geo_lakehouse.py`
- Script Python (fora de Fabric)
- Diagnóstico de lakehouse + permissões
- Teste de conectividade

---

## 📈 Matriz de Responsabilidades

| Atividade | Owner | Revisor | Validação |
|---|---|---|---|
| Atualizar bairros_osasco.json (shapefile) | GIS/Geo | Eng. Geo | 60 bairros, geometria válida |
| Executar nb_utils_geo_osasco | Data Eng | Eng. Geo | geopandas instalado, cache |
| Executar Gold (filtrar + gravar) | Data Eng | Analista | Bbox, bairro_geo cobertura ≥80% |
| Validação de dados criminais | Analista SSP | — | Naturezas apuradas, distribuição temporal |
| Criar visual no mapa | BI Dev | Analista | Legenda, filtros, cores |

---

## 🚨 Riscos & Mitigações

| Risco | Severidade | Mitigação |
|---|---|---|
| bairros_osasco.json não existe | 🔴 CRÍTICO | Arquivos auxiliares em Memory: `/memories/repo/acto_cidade_inteligente_contexto.md` §R1 |
| Coordenadas inválidas (0,0 ou fora de SP) | 🟡 MÉDIO | Filtro Bbox + Point.within() reduzem outliers |
| Disparidade entre Silver e Gold rowcount | 🟠 ALTO | Validação de cobertura bairro_geo ≥80% + top 10 naturezas |
| geopandas versão incompatível | 🟡 MÉDIO | Auto-install em nb_utils_geo_osasco com versionamento |

---

## 📞 Contatos

| Aspecto | Contato | Email | Telefone |
|---|---|---|---|
| Dados SSP-SP | Sec. Segurança Pública | — | — |
| Geolocalização | Eng. Geo (interno) | — | — |
| Análise Criminologia | Analista Osasco | — | — |

---

## 🔗 Links Internos (Obsidian)

- **[[Documentação_Fabric/Dados Públicos/00_INDEX_DADOS_PUBLICOS]]** — Índice Dados Públicos (IBGE/SIDRA/RAIS)
- **[[Documentação_Fabric/Osasco/00_INDEX_OSASCO]]** — Índice de documentos Osasco
- **[[Documentação_Fabric/CLAUDE.md]]** — Arquitetura geral

---

## 📝 Últimas Modificações

| Data | Mudança |
|---|---|
| 2026-07-01 | Criação em vault Obsidian — `geo_osasco_ssp_dados_criminais.md` |
| 2026-07-01 | Documentação original no repositório — `geo_osasco/OBSIDIAN_CONEXAO.md` |
| 2026-06-30 | Levantamento geo detalhado — identificado `ssp_dados_criminais` vs `ssp_criminais` |

---

## 🎓 Roteiro de Aprendizagem

**Dia 1 — Setup (1h)**
1. Ler este arquivo (geo_osasco_ssp_dados_criminais.md)
2. Verificar presença de `Files/geo/bairros_osasco.json`
3. Executar `nb_utils_geo_osasco` (instala geopandas)

**Dia 2 — Gold (2h)**
1. Abrir `nb_gold_osasco_ssp_dados_criminais_geo.ipynb`
2. Executar células 1-5 (carrega Silver → filtra → valida)
3. Entender validação de qualidade (célula 6)

**Dia 3 — Integração (2h)**
1. Explorar `gold.osasco_ssp_dados_criminais_geo` via SQL Endpoint
2. Criar visual no Power BI (mapa base)
3. Testar filtros (por bairro, por natureza apurada, por ano)

---

**Mantido por:** Victor Silva (Mapeamento Fabric)  
**Última revisão:** 2026-07-01  
**Status:** ✅ Ativo  
**Sincronização:** Repositório local ↔ Vault Obsidian (manual)
