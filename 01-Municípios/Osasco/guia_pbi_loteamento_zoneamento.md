---
tags:
  - osasco
  - loteamento
  - zoneamento
  - power-bi
  - azure-maps
  - tipo/guia
municipio: Osasco
aliases:
  - guia pbi loteamento
  - passo a passo loteamento zoneamento
atualizado: 2026-06-17
relacionados:
  - "[[Documentação_Fabric/Osasco/mapas_loteamento_zoneamento]]"
  - "[[Documentação_Fabric/Osasco/mapas-ssp-osasco]]"
---

# Guia PBI — Painel Loteamento / Zoneamento

> **Tempo estimado:** 2–3h
> **Pré-requisito:** Power BI Desktop instalado + acesso ao workspace Osasco

---

## Arquivos que serão usados

Todos em `Mapas_SSP_Osasco/` do projeto local:

| Arquivo | Pasta | Papel |
| --- | --- | --- |
| `loteamento_osasco.json` | `geojson/` | Reference Layer 1 — polígonos de loteamento coloridos |
| `contorno_osasco.json` | `geojson/` | Reference Layer 2 — linha do contorno municipal (overlay) |
| `loteamento_com_contorno_osasco.json` | `geojson/` | Alternativa: loteamentos + contorno num único arquivo |
| `mancha_zoneamento_osasco.json` | `geojson/` | Reference Layer — aba Zoneamento |
| `macrozoneamento_osasco.json` | `geojson/` | Reference Layer — aba Macrozoneamento |
| `tb_loteamento.csv` | `tabelas_pbi/` | Dados e filtros — Loteamento |
| `tb_mancha_zoneamento.csv` | `tabelas_pbi/` | Dados e filtros — Zoneamento |
| `tb_macrozoneamento.csv` | `tabelas_pbi/` | Dados e filtros — Macrozoneamento |

> [!tip] Por que dois arquivos para a aba Loteamento?
> `contorno_osasco.json` é um MultiLineString (só a borda, sem preenchimento) — carregado como segundo Reference Layer por cima dos polígonos. Isso permite configurar cor e espessura da linha do contorno independentemente do fill dos loteamentos.
> `loteamento_com_contorno_osasco.json` é alternativa para quem prefere um único arquivo — o contorno entra como feature com propriedade `NOME_LOTEAMENTO` = `CONTORNO_MUNICIPIO` (sem match na tabela = cor padrão).

> [!warning] Problemas conhecidos nos dados
> Dois problemas que **precisam ser resolvidos no Power Query** antes de qualquer visual:
>
> 1. `tb_mancha_zoneamento.csv` tem BOM UTF-8 — a coluna `ZONA_2024` aparece com caractere invisível no início. Precisa de rename.
> 2. `tb_loteamento.csv` — campo `situacao` tem ~8 variações de grafia. Precisa de normalização.

---

## Etapa 1 — Criar o arquivo PBIX

1. Abrir **Power BI Desktop**
2. **Arquivo → Novo**
3. Salvar como `bi_osasco_mapas_loteamento_zoneamento.pbix` no workspace local

---

## Etapa 2 — Importar as tabelas (Power Query)

### 2.1 Importar os 3 CSVs

**Início → Obter Dados → Texto/CSV** — importar cada um:

```text
tabelas_pbi/tb_loteamento.csv
tabelas_pbi/tb_mancha_zoneamento.csv
tabelas_pbi/tb_macrozoneamento.csv
```

Ao importar, clicar em **Transformar Dados** (não "Carregar") para entrar no Power Query.

---

### 2.2 Transformações obrigatórias — tb_loteamento

No Power Query, com a tabela `tb_loteamento` selecionada:

#### Passo A — Adicionar coluna situacao_norm

Aba **Adicionar Coluna → Coluna Personalizada**, com a fórmula:

```powerquery
= if [situacao] = null then "Indefinido"
  else if Text.Upper(Text.Trim([situacao])) = "APROVADO" then "Aprovado"
  else if Text.Upper(Text.Trim([situacao])) = "APROVADO / REGISTRADO" then "Aprovado/Registrado"
  else if Text.Upper(Text.Trim([situacao])) = "APROVADO/REGISTRADO" then "Aprovado/Registrado"
  else if Text.Upper(Text.Trim([situacao])) = "APROVADO PMO" then "Aprovado"
  else if Text.Upper(Text.Trim([situacao])) = "REGISTRADO" then "Aprovado/Registrado"
  else if Text.Upper(Text.Trim([situacao])) = "REGULARIZADO" then "Regularizado"
  else if Text.Upper(Text.Trim([situacao])) = "NAO APROVADO" then "Não Aprovado"
  else if Text.Upper(Text.Trim([situacao])) = "AVERBAÇÃO DE RUAS" then "Outros"
  else if Text.Upper(Text.Trim([situacao])) = "INDEFINIDO" then "Indefinido"
  else "Indefinido"
```

#### Passo B — Converter ano_aprovacao para texto

Clique na coluna `ano_aprovacao` → clique direito → **Alterar Tipo → Texto**

Isso evita que o PBI trate o ano como medida numérica.

#### Passo C — Converter area_m2 para número decimal

Coluna `area_m2` → **Alterar Tipo → Número Decimal**

---

### 2.3 Transformações obrigatórias — tb_mancha_zoneamento

#### Passo A — Corrigir o nome da coluna com BOM

A primeira coluna aparece com caractere invisível no início (BOM UTF-8). Clique duas vezes no cabeçalho e renomeie para `ZONA_2024`.

#### Passo B — Verificar tipos

- `to_perc` e `tp_perc` → **Número Inteiro**
- `ZONA_2024` e `ZONA_ABREV` → **Texto**

---

### 2.4 Transformações — tb_macrozoneamento

Nenhuma transformação obrigatória. Verificar:

- `ca_max` → alterar tipo para **Número Decimal** (valores como `4,00` com vírgula — usar substituição se necessário: `Transformar → Substituir Valores → vírgula por ponto`)
- `densidade_hab_ha` → **Número Decimal**
- `total_edificacoes` → **Número Inteiro**

---

### 2.5 Fechar e aplicar

**Página Inicial → Fechar e Aplicar** — as 3 tabelas ficam no modelo.

---

## Etapa 3 — Configurar o modelo

Não é necessário criar relacionamentos entre as tabelas (cada aba usa uma tabela independente). Nenhuma tabela de data ou tabela de fatos central.

---

## Etapa 4 — Página 1: Loteamento

### 4.1 Criar a página

Clicar em **+** na barra inferior → renomear para **Loteamento**

**Formato da página:** Exibição → Tamanho da Página → Personalizado → `1920 × 1890 pt`

### 4.2 Adicionar o visual Azure Maps

1. No painel Visualizações → clicar em **Azure Maps** (ícone de globo com pin)
2. Arrastar o visual para ocupar ~80% da tela

### 4.3 Conectar os dados ao visual

No painel de campos do visual:

- **Localização**: arrastar `tb_loteamento[NOME_LOTEAMENTO]`

> [!important] O Azure Maps vai tentar geolocalizar os nomes como endereços — isso **não é o que queremos**. O join com os polígonos é feito via Reference Layer (próximo passo), não pela localização direta.

### 4.4 Adicionar os Reference Layers (GeoJSON)

Com o visual Azure Maps selecionado → **Formatar o visual** (ícone de rolo de pintura) → seção **Reference layers**:

1. Clicar em **+ Adicionar** → **Upload local file** → `geojson/loteamento_osasco.json`
2. Clicar em **+ Adicionar** novamente → `geojson/contorno_osasco.json`

O primeiro layer exibe os polígonos coloridos. O segundo adiciona a linha do contorno municipal por cima.

Para o `contorno_osasco.json`, configurar na seção de estilo do layer:

- Cor da linha: `#1A1A1A` (preto/grafite)
- Espessura: `3px`
- Opacidade: `100%`

### 4.5 Configurar a legenda por situacao_norm

No painel de campos do visual:

- **Legenda**: arrastar `tb_loteamento[situacao_norm]`

Resultado esperado: 5 cores — Aprovado, Aprovado/Registrado, Regularizado, Não Aprovado, Indefinido.

### 4.6 Configurar tooltips

- **Dicas de ferramenta**: `tb_loteamento[ano_aprovacao]`, `tb_loteamento[area_m2]`, `tb_loteamento[bairro]`

### 4.7 Configurar o estilo do mapa

**Formatar visual → Configurações do mapa:**

- Estilo do mapa: **Satellite** (aerofoto — faz sentido para visualizar lotes reais)
- Zoom inicial: centrar em Osasco (`-23.53, -46.79`, zoom ~13)

### 4.8 Adicionar filtros e KPIs

Adicionar abaixo ou à direita do mapa:

- **Segmentação de dados** com `tb_loteamento[situacao_norm]` — permite filtrar por status
- **Segmentação de dados** com `tb_loteamento[ano_aprovacao]` — filtro por período
- **Cartão** com medida `COUNTROWS(tb_loteamento)` — total de loteamentos
- **Cartão** com medida `SUMX(tb_loteamento, tb_loteamento[area_m2]) / 1000000` — área total em km²

---

## Etapa 5 — Página 2: Zoneamento

### 5.1 Criar a página

**+** → renomear para **Zoneamento**

**Tamanho:** mesmo padrão `1920 × 1890 pt`

### 5.2 Adicionar e configurar o Azure Maps

1. Adicionar visual **Azure Maps**
2. **Localização**: `tb_mancha_zoneamento[ZONA_2024]`
3. **Reference layers → + Adicionar** → `geojson/mancha_zoneamento_osasco.json`

### 5.3 Configurar legenda e estilo

- **Legenda**: `tb_mancha_zoneamento[ZONA_2024]` — cada zona recebe uma cor

**Estilo do mapa:** Road (mais limpo — o zoneamento é visualmente denso)

**Opacidade dos polígonos:** ajustar para **75–80%** para o fundo aparecer

### 5.4 Categorias esperadas (661 polígonos, 16 zonas)

| Zona | Polígonos | Descrição resumida |
| --- | --- | --- |
| ZEPAM 3 | 295 | Proteção Ambiental — uso conforme órgão ambiental |
| ZEIS | 173 | Interesse Social |
| ZPR | 113 | Predominantemente Residencial |
| ZCE 2 | 38 | Centralidade 2 |
| ZDE | 11 | Desenvolvimento Econômico |
| ZEPAM 2 | 10 | Proteção Ambiental 2 |
| ZCE 1 | 7 | Centralidade 1 |
| + 9 zonas menores | ~16 | ZEMIU, ZOE, ZEPAM 2A, ZEP, ZERA, ZER, ZEPAM 1, ZCE 3, Tietê |

> [!note] Zona "Tietê"
> Um polígono está categorizado como `Tietê` sem sigla de zona — possivelmente a faixa do Rio Tietê com classificação especial. Verificar no QGIS se deve ser `ZOE Tietê` ou similar.

### 5.5 Tooltip por zona

Dicas de ferramenta: `ZONA_2024`, `usos`, `to_perc`, `tp_perc`, `lote_min_m2`, `frente_min_m`

### 5.6 Segmentação de dados

Segmentação com `ZONA_2024` — permite isolar uma zona específica.

---

## Etapa 6 — Página 3: Macrozoneamento (opcional)

### 6.1 Criar a página

**+** → renomear para **Macrozoneamento**

### 6.2 Configurar o visual

1. Azure Maps → **Localização**: `tb_macrozoneamento[SIGLA]`
2. Reference Layer → `geojson/macrozoneamento_osasco.json`
3. **Legenda**: `tb_macrozoneamento[descricao]`
4. Estilo: **Road**, opacidade **70%**

### 6.3 Estrutura (12 registros)

| SIGLA | Descrição |
| --- | --- |
| MDE | Desenvolvimento Empresarial |
| MDTP | Desenvolvimento de Territórios Periféricos |
| MUC | Urbanização Consolidada |
| MPA | Preservação Ambiental |
| MCADS | Conservação Ambiental e Desenvolvimento Sustentável |
| MDU | Dinamização Urbana |

### 6.4 Informações adicionais

Adicionar **tabela** com `SIGLA`, `descricao`, `ca_max`, `densidade_hab_ha`, `total_edificacoes` — permite consultar os parâmetros da macrozona ao clicar no mapa.

---

## Etapa 7 — Tema e padronização visual

### Cores sugeridas para situacao_norm (Loteamento)

| Status | Cor sugerida |
| --- | --- |
| Aprovado | `#2E7D32` (verde escuro) |
| Aprovado/Registrado | `#66BB6A` (verde claro) |
| Regularizado | `#1565C0` (azul) |
| Não Aprovado | `#C62828` (vermelho) |
| Indefinido | `#9E9E9E` (cinza) |

Para aplicar: **Formatar visual → Cores dos dados → Fx → Por valor de campo → `situacao_norm`**

### Cores sugeridas para Zoneamento

Replicar as cores do QGIS/OzMundi:

| Zona | Cor sugerida |
| --- | --- |
| ZEPAM 3 | `#2E7D32` (verde — ambiental) |
| ZEIS | `#F57C00` (laranja — social) |
| ZPR | `#FFF176` (amarelo claro — residencial) |
| ZCE 2 / ZCE 1 | `#EF5350` (vermelho — centralidade) |
| ZDE | `#7B1FA2` (roxo — econômico) |

---

## Etapa 8 — Publicar e configurar embed

### 8.1 Publicar no workspace

**Arquivo → Publicar → Publicar no Power BI** → selecionar workspace **Acto Cidade Inteligente — Osasco**

### 8.2 Configurar embed para o portal

1. Abrir o relatório no **Power BI Service** (app.powerbi.com)
2. **Arquivo → Inserir relatório → Site ou portal**
3. Copiar o código `<iframe>` gerado
4. Passar para o time de frontend do portal de Osasco

### 8.3 Configurações de atualização

Este painel usa dados estáticos (shapefiles + CSVs locais). **Não precisa de atualização agendada** — os dados só mudam quando novos shapefiles forem processados.

---

## Problemas previstos e soluções

| Problema | Causa | Solução |
| --- | --- | --- |
| Polígonos não aparecem | Reference Layer não conectado | Verificar Formatar → Reference layers — GeoJSON carregado? |
| Polígonos fora do lugar (África/oceano) | GeoJSON em CRS errado | Confirmar EPSG:4326 — rodar `converter_shapefiles_osasco.py` novamente |
| Cores não aplicam por zona | Join tabela/GeoJSON não encontrou correspondência | Conferir se `ZONA_2024` na tabela bate exatamente com a propriedade no GeoJSON |
| Coluna com caractere estranho no início | BOM UTF-8 no CSV | Renomear a coluna no Power Query (Etapa 2.3 Passo A) |
| situacao com cores duplicadas | Variações de grafia | Usar `situacao_norm` gerada no Power Query (Etapa 2.2 Passo A) |
| Azure Maps não disponível na lista | Feature não habilitada | Arquivo → Opções → Recursos de visualização → habilitar Azure Maps |
