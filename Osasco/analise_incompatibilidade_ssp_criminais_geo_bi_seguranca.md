---
title: "Análise — Incompatibilidade ssp_criminais_geo vs gold_seg_publica_dados_criminais"
tags:
  - power-bi
  - osasco
  - seguranca-publica
  - ssp
  - dados-publicos
  - tipo/analise
municipio: Osasco
data: "2026-07-01"
status: ativo
aliases:
  - troca fonte ssp criminais geo
  - justificativa ssp criminais geo
  - ssp criminais geo vs dados criminais
relacionados:
  - "[[Documentação_Fabric/Osasco/00_INDEX_OSASCO]]"
  - "[[Documentação_Fabric/Osasco/MAPEAMENTO_PAINEIS_PBI_OSASCO]]"
  - "[[Documentação_Fabric/Osasco/geo_osasco_ssp_dados_criminais]]"
  - "[[Documentação_Fabric/Dados Públicos/spec_drive_semana_30_06_2026]]"
---

# Análise — Por que não dá para trocar a fonte dos gráficos de `bi_osasco_seguranca_publica` por `gold osasco_ssp_criminais_geo`

> **Demanda recebida (01/07/2026):** substituir a fonte de dados dos gráficos da página "Visão Geral" do painel `bi_osasco_seguranca_publica` — hoje `gold_seg_publica_dados_criminais` — pela tabela `gold osasco_ssp_criminais_geo` (a mesma usada no mapa da página "Mapas ocorrências delitos").
>
> **Conclusão:** não é possível fazer essa troca mantendo os mesmos valores. As duas tabelas têm grãos diferentes, um gap de volume de ~22% e taxonomias de bairro incompatíveis (240 vs 60 bairros). Detalhamento completo abaixo — este documento serve como justificativa técnica para quem pediu a mudança.

---

## 1. Método

Conectado ao Power BI Desktop aberto na máquina (arquivo `bi_osasco_seguranca_publica`) via MCP de modelagem tabular. Inspecionados os três visuais da página **"Visão Geral"**:

1. Gráfico de linha — *Ocorrências por mês e ano, segundo a natureza apurada do delito*
2. *Ranking de ocorrências por natureza do delito*
3. *Ranking de ocorrências por bairro — Top 20*

Para cada visual, os campos foram lidos diretamente no painel de Visualizações (Eixo X/Y, Legenda, Cards) e as medidas por trás foram abertas via DAX (`measure_operations.Get`) para confirmar a lógica exata de cálculo.

---

## 2. Campos usados hoje (fonte: `gold_seg_publica_dados_criminais`)

| Visual | Eixo Y | Eixo X / Valor | Medida por trás | Cards |
|---|---|---|---|---|
| Linha — Ocorrências por mês/ano/natureza | mês (parâmetro "Tipo de visualização") | Ano (legenda) | `Ocorrencias_Mes_Ano_Natureza` = `CALCULATE(SUM(quantidade_ocorrencias), ALLSELECTED(...))` | — |
| Ranking por natureza do delito | `natureza_apurada` | `Contagem_delito_Topo` = `MAXX(ADDCOLUMNS(VALUES(natureza_apurada), SUM(quantidade_ocorrencias)))` | mesma | Delito_Mais_Frequente, Total_Ocorrencias, Tipos_de_Delito (`DISTINCTCOUNT(natureza_apurada)`) |
| Ranking por bairro Top 20 | `bairro` | `Total_Ocorrencias_Bairro` = `SUM(quantidade_ocorrencias)` | mesma | Bairro_Mais_Ocorrencias, Total_Ocorrencias, Bairros_Analisados (`DISTINCTCOUNT(bairro)`) |

---

## 3. Por que a troca quebra os valores

### 3.1 Grão diferente (causa raiz)

`gold_seg_publica_dados_criminais` tem só **8 colunas** e já vem **pré-agregada**: cada linha é uma combinação `bairro + natureza_apurada + ano_estatistica + mes_estatistica`, com a contagem pronta na coluna `quantidade_ocorrencias`.

```
ano_estatistica · mes_estatistica · nome_municipio_circunscricao
bairro · natureza_apurada · quantidade_ocorrencias
Data_Fato (calc) · Periodo_Serie (calc)
```

`gold osasco_ssp_criminais_geo` tem **17 colunas** e é **granular** — 1 linha por Boletim de Ocorrência individual, com lat/long:

```
ano_bo · data_ocorrencia_bo · hora_ocorrencia_bo · rubrica · natureza_apurada
descr_conduta · nome_municipio_circunscricao · descr_tipolocal · descr_subtipolocal
logradouro · numero_logradouro · bairro · latitude · longitude
ano_estatistica · mes_estatistica · bairro_geo
```

Toda medida precisaria trocar `SUM(quantidade_ocorrencias)` por `COUNTROWS(tabela)`. Isso é viável tecnicamente, mas não resolve os dois problemas abaixo — que são de **conteúdo dos dados**, não de sintaxe DAX.

### 3.2 Volume ~22% menor (medido via DAX)

| Métrica (jan–mai/2026) | `dados_criminais` | `ssp_criminais_geo` | Diferença |
|---|---|---|---|
| Total de ocorrências | **7.671** | **5.960** | **−22,3%** |

A tabela geo cobre só ~78% do volume oficial no mesmo período. Consistente com a hipótese de que `ssp_criminais_geo` só contém BOs que puderam ser **geolocalizados** (lat/long válidos + ponto-em-polígono dentro de Osasco) — os que não tiveram endereço resolvido ficam de fora do funil de geocodificação. Trocar a fonte dos cards/gráficos faria os números "despencarem" sem que tenha havido queda real de criminalidade.

### 3.3 Taxonomia de bairro incompatível

| Coluna | Valores distintos |
|---|---|
| `dados_criminais[bairro]` | **240** |
| `ssp_criminais_geo[bairro]` (bruta, como digitada no BO) | 215 |
| `ssp_criminais_geo[bairro_geo]` (geocodificada via shapefile) | **60** |

Nenhuma bate com 240. A tabela geo usa a malha dos 60 bairros oficiais do shapefile municipal (`bairros_osasco.json`, ver [[Documentação_Fabric/Osasco/geo_osasco_ssp_dados_criminais]]), enquanto `dados_criminais` preserva o texto de bairro como veio do BO original — muito mais granular e sujo (variações de grafia, sub-bairros, etc.). O **"Ranking de ocorrências por bairro"** é o visual mais impactado: não dá para reproduzir o Top 20 atual com a mesma resolução usando `bairro_geo`, e usando `bairro` bruta o número de categorias ainda não bate (215 vs 240) e herda os problemas de qualidade abaixo.

### 3.4 Único campo hoje compatível: `natureza_apurada`

24 valores distintos em `ssp_criminais_geo` vs 23 em `dados_criminais` — próximo o suficiente para reconstruir esse gráfico especificamente, ainda que herdando o gap de volume do item 3.2.

---

## 4. Recomendação

1. **Manter `gold_seg_publica_dados_criminais` como fonte dos KPIs/rankings** da Visão Geral — é o dado oficial agregado, com cobertura completa e taxonomia de bairro fina.
2. **Usar `gold osasco_ssp_criminais_geo` apenas para o mapa** (página "Mapas ocorrências delitos") — esse é o propósito para o qual ela foi desenhada (visualização espacial, não contagem oficial). Ver decisão de arquitetura em [[Documentação_Fabric/Dados Públicos/spec_drive_semana_30_06_2026]] (revisão de 01/07/2026): `ssp_criminais_geo` foi confirmada como única tabela de produção para geo.
3. Se a demanda de troca persistir, o passo anterior necessário é investigar com a fonte SSP **por que 22% dos BOs não são geolocalizáveis** — se isso puder ser corrigido (geocodificação por CEP/logradouro como fallback, por exemplo), as duas bases convergem e a troca passa a fazer sentido.
4. Nota à parte: o caminho de migração já documentado em [[Documentação_Fabric/Osasco/MAPEAMENTO_PAINEIS_PBI_OSASCO#Segurança Pública e Viária|MAPEAMENTO_PAINEIS_PBI_OSASCO]] aponta `bi_osasco_seguranca_publica` para migrar para `lh_dados_publicos.gold.ssp_dados_criminais` (a versão **não-geo**, agregada) — não para `ssp_criminais_geo`. Vale confirmar se a demanda que gerou este pedido não é, na verdade, sobre essa migração já planejada (tabela diferente) em vez da tabela geo do mapa.

---

## 5. Achado lateral — qualidade de dados em `ssp_criminais_geo`

Levantamento feito antes da comparação, útil para quem for usar essa tabela no mapa:

| Campo | Problema | Volume |
|---|---|---|
| `data_ocorrencia_bo` | Ano divergente de `ano_bo`; datas absurdas (mín. 08/02/1975) | 1.294 registros (2%) |
| `numero_logradouro` | Valor literal `1970-01-01 00:00:00` (epoch, artefato de ETL) em vez de número/branco | 11.774 registros (18,5%) |
| `descr_conduta` | Grafias duplicadas (`VEICULO`/`Veículo`) + string literal `"NaN"` (não é branco real) | 12.030 registros (19%) com `"NaN"` |
| `descr_tipolocal` | Em branco | 43.970 registros (69%) |

Recomenda-se usar `ano_estatistica`/`mes_estatistica` (não `data_ocorrencia_bo`) para qualquer filtro temporal — essas colunas já vêm tratadas no Gold.

**Ponto de maior concentração no mapa:** bairro **CENTRO**, coordenada `-23,5286665 / -46,7756281` (Praça Antônio Menck) — 210 ocorrências no mesmo ponto exato. Bem provável que seja um ponto de fallback de geocodificação (endereços incompletos caindo no centroide do bairro), não 210 crimes literalmente na praça. Vale considerar excluir ou destacar esse ponto separadamente no visual de mapa para não distorcer a leitura.

---

## 6. Medida criada nesta sessão (tabela `Medidas`, pasta "Mapa Geo")

```dax
Contagem_Ocorrencias_Ponto_Geo =
COUNTROWS(
    FILTER(
        ALLSELECTED('gold osasco_ssp_criminais_geo'),
        'gold osasco_ssp_criminais_geo'[latitude] = MAX('gold osasco_ssp_criminais_geo'[latitude]) &&
        'gold osasco_ssp_criminais_geo'[longitude] = MAX('gold osasco_ssp_criminais_geo'[longitude])
    )
)
```

Conta quantas ocorrências caem exatamente na mesma latitude/longitude — usar como campo de **Valor/Tamanho da bolha** no visual de mapa (Azure Maps). Testada e validada (achado do item 5 acima).

---

## 7. Links relacionados

- [[Documentação_Fabric/Osasco/00_INDEX_OSASCO]]
- [[Documentação_Fabric/Osasco/MAPEAMENTO_PAINEIS_PBI_OSASCO]] — seção "Segurança Pública e Viária"
- [[Documentação_Fabric/Osasco/geo_osasco_ssp_dados_criminais]] — documentação do projeto geo (notebooks, schema, arquitetura)
- [[Documentação_Fabric/Dados Públicos/spec_drive_semana_30_06_2026]] — decisão de arquitetura que confirma `ssp_criminais_geo` como única tabela geo de produção
