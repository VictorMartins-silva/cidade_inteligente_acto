---
tags:
  - osasco
  - power-bi
  - azure-maps
  - loteamento
  - zoneamento
  - tipo/guia
municipio: Osasco
atualizado: 2026-06-18
relacionados:
  - "[[guia_pbi_loteamento_zoneamento]]"
  - "[[mapas_loteamento_zoneamento]]"
---

# Guia PBI — Painel Mapas Urbanos (6 sub-abas)

## Plano de ajustes — revisão 2026-06-18

> Baseado na revisão dos 6 prints do painel em construção.

### Diagnóstico por sub-aba

| Sub-aba | Status | Problemas identificados |
| --- | --- | --- |
| Loteamento | 🟡 Quase certo | Filtros errados (SIGLA/descricao), KPI Área m² incorreto |
| Máscara de Bairros | 🟡 Quase certo | Filtros errados (SIGLA/descricao), KPI Área m² incorreto |
| Quadras 2019 | 🟢 Funcional | KPI Área m² compartilhado (445 Mi — de outro contexto) |
| Zoneamento 2024 | 🟡 Quase certo | Filtro por `usos` (texto longo) — trocar por `ZONA_2024` |
| Zoneamento 1978 | 🟡 Quase certo | "(Em branco)" no filtro grupo; botão "Zoneamento" deveria se chamar "Zoneamento 1978" |
| Macrozonas | 🟡 Quase certo | Botão "Zoneamento 1978" deveria se chamar "Macrozonas" |

---

### Plano de ação — passo a passo

#### P1 — Corrigir labels dos botões de sub-navegação (Zoneamento)

Os bookmarks estão corretos mas os botões têm nome errado:

| Botão atual | Nome correto |
| --- | --- |
| "Zoneamento" | "Zoneamento 1978" |
| "Zoneamento 1978" | "Macrozonas" |

**Como corrigir:** Selecionar cada botão → painel Formato → Botão → Texto → alterar o label.

---

#### P2 — Corrigir filtros da página Loteamento

Os filtros "SIGLA" e "descricao" são do macrozoneamento e não deveriam aparecer na aba Loteamento. Isso acontece porque os filtros não foram capturados nos bookmarks.

**Como corrigir:**
1. Na sub-aba **Loteamento** ativa, remover os slicers de SIGLA e descricao
2. Adicionar slicers corretos: `tb_loteamento[situacao]`, `tb_loteamento[bairro]`, `tb_loteamento[ano_aprovacao]`
3. **Atualizar o bookmark** `bm_loteamento` e `bm_bairros` para capturar o estado dos slicers

> [!warning] Bookmarks e slicers
> Ao criar/atualizar o bookmark, marcar **"Dados"** apenas para os slicers que devem ser diferentes por sub-aba. Se um slicer é compartilhado entre sub-abas, deixar "Dados" desmarcado.

---

#### P3 — Corrigir KPI "Área m²" (445 Mi em todas as abas)

O valor 445 Mi aparece em todas as sub-abas porque o cartão de área está sempre conectado a `tb_loteamento`. Cada sub-aba deve ter seu próprio KPI contextual:

| Sub-aba | KPI sugerido | Medida DAX |
| --- | --- | --- |
| Loteamento | "Lotes cadastrados" | `COUNTROWS(tb_loteamento)` |
| Loteamento | "Área somada¹" | `FORMAT(SUM(tb_loteamento[area_m2])/1000000, "0.0") & " km²"` |
| Máscara de Bairros | "Bairros" | `DISTINCTCOUNT(tb_loteamento[bairro])` |
| Quadras 2019 | "Quadras" | `COUNTROWS(tb_quadras)` |
| Quadras 2019 | "Unidades" | `SUM(tb_quadras[qt_unid])` |

¹ Adicionar nota: *"Área somada pode ultrapassar a área do município pois loteamentos históricos se sobrepõem."*

**Como corrigir no PBI:**
1. Criar as medidas DAX em **Início → Nova Medida**
2. Substituir os cartões genéricos por cartões específicos por sub-aba
3. Controlar visibilidade via bookmark (mostrar/ocultar o cartão certo)

---

#### P4 — Filtro Zoneamento 2024: trocar `usos` por `ZONA_2024`

O slicer atual usa o campo `usos` (textos longos tipo "R1, R2.1, R2.2...") que é difícil de usar como filtro. Substituir por:

- **Slicer principal:** `tb_mancha_zoneamento[ZONA_2024]` — lista as siglas (ZEPAM 3, ZEIS, ZPR...)
- **Tabela de detalhes:** manter `usos`, `to_perc`, `tp_perc`, `lote_min_m2`, `frente_min_m` como tabela abaixo

---

#### P5 — Tratar "(Em branco)" no filtro grupo (Zoneamento 1978)

Alguns polígonos do `geo_zoneamento_vigente` têm `grupo` nulo. No Power Query:

```powerquery
= Table.ReplaceValue(#"Etapa anterior", null, "Não classificado", Replacer.ReplaceValue, {"grupo"})
```

Ou criar coluna calculada DAX:
```dax
grupo_norm = IF(ISBLANK(tb_zoneamento_1978[grupo]), "Não classificado", tb_zoneamento_1978[grupo])
```

---

#### P6 — Tooltip histórico para loteamentos 1942–1961

Adicionar uma caixa de texto ou callout na aba Loteamento com o seguinte conteúdo:

> **Sobre os anos anteriores a 1962**
> Osasco foi distrito de São Paulo até 1962. Loteamentos aprovados entre 1942 e 1961 foram registrados pela Prefeitura de São Paulo — o dado é historicamente correto.

**Opções de implementação no PBI:**
- **Opção A (simples):** Caixa de texto fixa no rodapé da página, visível em todas as sub-abas de Loteamento
- **Opção B (elegante):** Botão "ℹ" com ação de bookmark que exibe/oculta um card com o texto explicativo
- **Opção C (tooltip):** Criar uma página de tooltip personalizada e associar ao visual da tabela

Recomendação: **Opção B** — botão ℹ no canto da tabela que abre o card ao clicar.

---

#### P7 — Ajustes visuais gerais

- [ ] Padronizar cor dos botões ativos vs inativos em todas as páginas (atualmente inconsistente)
- [ ] Remover o campo "SIGLA" do painel de dados da página Loteamento (está poluindo)
- [ ] Verificar se o limite municipal (`limite_municipal_osasco.json`) está carregado em todos os 6 mapas
- [ ] Fixar zoom inicial em todos os mapas: Lat `-23.529`, Lon `-46.789`, Zoom `12`

---

### Ordem de execução sugerida

```
P1 (5 min)  → Renomear botões Zoneamento 1978 e Macrozonas
P4 (10 min) → Trocar slicer usos por ZONA_2024
P5 (5 min)  → Tratar (Em branco) no grupo 1978
P2 (20 min) → Corrigir filtros Loteamento + reatualizar bookmarks
P3 (30 min) → Criar medidas DAX e KPIs por sub-aba
P6 (15 min) → Implementar tooltip histórico (Opção B)
P7 (15 min) → Ajustes visuais finais
```

**Total estimado: ~1h40**

---

## Protótipo de layout

```
╔══════════════════════════════════════════════════════════════════════════╗
║         [● LOTEAMENTO]              [○ ZONEAMENTO]                      ║
╠══════════════════════════════════════════════════════════════════════════╣
║   [● Loteamento] [○ Máscara Bairros] [○ Quadras 2019]                  ║
╠════════════════════════════════════╦═════════════════════════════════════╣
║                                    ║  Filtros                           ║
║                                    ║  ┌──────────────────────────────┐  ║
║      AZURE MAPS                    ║  │ Situação   [▼ Todos        ] │  ║
║   (polígonos de loteamento         ║  │ Bairro     [▼ Todos        ] │  ║
║    coloridos por situação)         ║  │ Ano        [▼ Todos        ] │  ║
║                                    ║  └──────────────────────────────┘  ║
║                                    ║                                     ║
║   ○ contorno preto por cima        ║  ┌──────────┐  ┌───────────────┐  ║
║                                    ║  │   435    │  │  77.4 km²     │  ║
║                                    ║  │  lotes   │  │  área total   │  ║
║                                    ║  └──────────┘  └───────────────┘  ║
║                                    ║                                     ║
║                                    ║  Legenda                            ║
║                                    ║  ■ Aprovado                        ║
║                                    ║  ■ Aprov./Registrado               ║
║                                    ║  ■ Regularizado                    ║
║                                    ║  ■ Não Aprovado                    ║
║                                    ║  ■ Indefinido                      ║
╚════════════════════════════════════╩═════════════════════════════════════╝
```

```
╔══════════════════════════════════════════════════════════════════════════╗
║         [○ LOTEAMENTO]              [● ZONEAMENTO]                      ║
╠══════════════════════════════════════════════════════════════════════════╣
║   [● Zoneamento 2024] [○ Zoneamento 1978] [○ Macrozonas]               ║
╠════════════════════════════════════╦═════════════════════════════════════╣
║                                    ║  Filtro por Zona                    ║
║                                    ║  ┌──────────────────────────────┐  ║
║      AZURE MAPS                    ║  │ □ ZEPAM 3  (295 polígonos)   │  ║
║   (mancha de zoneamento            ║  │ □ ZEIS     (173 polígonos)   │  ║
║    colorida por ZONA_2024)         ║  │ □ ZPR      (113 polígonos)   │  ║
║                                    ║  │ □ ZCE 2    ( 38 polígonos)   │  ║
║                                    ║  │ □ ZDE      ( 11 polígonos)   │  ║
║   ○ limite municipal por cima      ║  │ + 11 zonas menores...        │  ║
║                                    ║  └──────────────────────────────┘  ║
║                                    ║                                     ║
║                                    ║  Parâmetros da zona selecionada     ║
║                                    ║  ┌──────────────────────────────┐  ║
║                                    ║  │ TO    TP    Lote mín  Frente │  ║
║                                    ║  │ 60%   50%   200 m²   8 m    │  ║
║                                    ║  └──────────────────────────────┘  ║
╚════════════════════════════════════╩═════════════════════════════════════╝
```

---

## Arquivos GeoJSON por sub-aba

| Sub-aba | GeoJSON (Reference Layer) | Overlay fixo | Tabela de dados | Chave de join |
| --- | --- | --- | --- | --- |
| Loteamento | `loteamento_osasco.json` | `limite_municipal_osasco.json` | `tb_loteamento` | `NOME_LOTEAMENTO` |
| Máscara de Bairros | `bairros_osasco.json` | `limite_municipal_osasco.json` | `tb_loteamento` (agrupado) | `NOME_NORM` |
| Quadras 2019 | `quadras_osasco.json` | `limite_municipal_osasco.json` | `tb_quadras` | `chave_qd` |
| Zoneamento 2024 | `mancha_zoneamento_osasco.json` | `limite_municipal_osasco.json` | `tb_mancha_zoneamento` | `ZONA_2024` |
| Zoneamento 1978 | `zoneamento_1978_osasco.json` | `limite_municipal_osasco.json` | `tb_zoneamento_1978` | `zona` |
| Macrozonas | `macrozoneamento_osasco.json` | `limite_municipal_osasco.json` | `tb_macrozoneamento` | `SIGLA` |

> [!warning] Tamanho dos arquivos
> `mancha_zoneamento_osasco.json` (3.2 MB) e `zoneamento_1978_osasco.json` (2.1 MB) excedem o limite nominal de 1 MB do Reference Layer. Na prática o Azure Maps aceita arquivos maiores — testar o upload e simplificar geometria se falhar.

---

## Etapa 1 — Estrutura de páginas no PBI

Criar **2 páginas reais** no Power BI:

- Página `P1_Loteamento`
- Página `P2_Zoneamento`

Em cada página, todos os visuais das sub-abas ficam **sobrepostos na mesma posição**. Os bookmarks controlam quais estão visíveis.

---

## Etapa 2 — Importar as tabelas (Power Query)

**Início → Obter Dados → Texto/CSV**, importar todos os 6 CSVs:

```text
tabelas_pbi/tb_loteamento.csv
tabelas_pbi/tb_quadras.csv
tabelas_pbi/tb_mancha_zoneamento.csv
tabelas_pbi/tb_zoneamento_1978.csv
tabelas_pbi/tb_macrozoneamento.csv
```

Transformações obrigatórias em Power Query:
- `tb_loteamento`: já processada com `situacao` normalizada e `bairro` por spatial join
- `tb_mancha_zoneamento`: renomear coluna BOM → `ZONA_2024` (ver [[guia_pbi_loteamento_zoneamento]])
- `tb_quadras`: `qt_unid` e `area_m2` → Número Inteiro; `area_const` → Número Decimal
- `tb_zoneamento_1978`: todos os tipos já corretos

---

## Etapa 3 — Página P1: Loteamento (3 bookmarks)

### 3.1 Adicionar os 3 visuais Azure Maps sobrepostos

Posicionar todos no **mesmo local e tamanho exatos** (ex: X=20, Y=120, W=800, H=700):

| Visual | Nome no painel Seleção | GeoJSON |
| --- | --- | --- |
| Azure Maps A | `map_loteamento` | `loteamento_osasco.json` |
| Azure Maps B | `map_bairros` | `bairros_osasco.json` |
| Azure Maps C | `map_quadras` | `quadras_osasco.json` |

Em cada visual, adicionar um segundo Reference Layer com `limite_municipal_osasco.json`.

### 3.2 Configurar cada mapa

**map_loteamento:**
- Localização: `tb_loteamento[NOME_LOTEAMENTO]`
- Legenda: `tb_loteamento[situacao]`
- Tooltips: `bairro`, `ano_aprovacao`, `area_m2`
- Estilo: Satellite

**map_bairros:**
- Localização: `tb_loteamento[bairro]` (ou campo de bairro agrupado)
- Legenda: `tb_loteamento[bairro]`
- Estilo: Road (fundo neutro para destacar bairros)

**map_quadras:**
- Sem dados conectados (visualização pura)
- Estilo: Road
- Polígonos: fill cinza claro, stroke escuro

### 3.3 Adicionar painel lateral

À direita do mapa, adicionar (visíveis em todas as sub-abas):
- 3 **Segmentações de dados**: `situacao`, `bairro`, `ano_aprovacao`
- 2 **Cartões**: `COUNTROWS(tb_loteamento)` e `SUM(tb_loteamento[area_m2])/1000000`

### 3.4 Criar os botões de navegação (sub-abas)

Inserir 3 botões horizontais acima do mapa:

```
[Loteamento]   [Máscara de Bairros]   [Quadras 2019]
```

**Formatar cada botão:**
- Estado Padrão: fundo azul escuro, texto branco
- Estado Hover: fundo verde, texto branco
- Ação: Tipo = Indicador (a ser configurado após criar bookmarks)

### 3.5 Criar os bookmarks

**Exibição → Indicadores → + Adicionar** para cada estado:

| Bookmark        | Visível          | Oculto                          |
| --------------- | ---------------- | ------------------------------- |
| `bm_loteamento` | `map_loteamento` | `map_bairros`, `map_quadras`    |
| `bm_bairros`    | `map_bairros`    | `map_loteamento`, `map_quadras` |
| `bm_quadras`    | `map_quadras`    | `map_loteamento`, `map_bairros` |

Para cada bookmark:
1. No painel **Seleção**: configurar visibilidade (olho aberto/fechado)
2. No painel **Indicadores**: clique direito → **Atualizar**
3. Clique direito → desmarcar **Dados** (preserva filtros ativos)

### 3.6 Conectar botões aos bookmarks

Selecionar cada botão → **Formato → Ação → Tipo: Indicador** → escolher o bookmark correspondente.

Testar: **Ctrl + clique** no botão (em modo edição).

---

## Etapa 4 — Página P2: Zoneamento (3 bookmarks)

### 4.1 Adicionar os 3 visuais Azure Maps sobrepostos

| Visual | Nome | GeoJSON |
| --- | --- | --- |
| Azure Maps D | `map_zoneamento_2024` | `mancha_zoneamento_osasco.json` |
| Azure Maps E | `map_zoneamento_1978` | `zoneamento_1978_osasco.json` |
| Azure Maps F | `map_macrozonas` | `macrozoneamento_osasco.json` |

### 4.2 Configurar cada mapa

**map_zoneamento_2024:**
- Localização: `tb_mancha_zoneamento[ZONA_2024]`
- Legenda: `tb_mancha_zoneamento[ZONA_2024]`
- Tooltips: `usos`, `to_perc`, `tp_perc`, `lote_min_m2`, `frente_min_m`
- Estilo: Road, opacidade polígonos 75%

**map_zoneamento_1978:**
- Localização: `tb_zoneamento_1978[zona]`
- Legenda: `tb_zoneamento_1978[grupo]` (7 grupos — mais limpo que 49 zonas)
- Tooltips: `zona`, `grupo`, `area_m2`
- Estilo: Road, opacidade 75%

**map_macrozonas:**
- Localização: `tb_macrozoneamento[SIGLA]`
- Legenda: `tb_macrozoneamento[descricao]`
- Tooltips: `ca_max`, `densidade_hab_ha`, `total_edificacoes`
- Estilo: Road, opacidade 70%

### 4.3 Painel lateral — Zoneamento 2024

- **Segmentação**: `tb_mancha_zoneamento[ZONA_2024]` (seleção múltipla — substitui as 16 camadas individuais #118–133)
- **Tabela**: `ZONA_2024`, `usos`, `to_perc`, `tp_perc`, `lote_min_m2`, `frente_min_m`

### 4.4 Criar bookmarks — Zoneamento

| Bookmark        | Visível               | Oculto                                       |
| --------------- | --------------------- | -------------------------------------------- |
| `bm_zon_2024`   | `map_zoneamento_2024` | `map_zoneamento_1978`, `map_macrozonas`      |
| `bm_zon_1978`   | `map_zoneamento_1978` | `map_zoneamento_2024`, `map_macrozonas`      |
| `bm_macrozonas` | `map_macrozonas`      | `map_zoneamento_2024`, `map_zoneamento_1978` |

Repetir processo: configurar Seleção → Atualizar bookmark → desmarcar Dados.

---

## Etapa 5 — Navegação principal entre páginas

Adicionar em **ambas as páginas**, no topo:

```
[LOTEAMENTO]     [ZONEAMENTO]
```

- Botão LOTEAMENTO: Ação = **Navegação de Página → P1_Loteamento**
- Botão ZONEAMENTO: Ação = **Navegação de Página → P2_Zoneamento**

Destacar visualmente qual página está ativa (cor sólida = ativa, outline = inativa).

---

## Etapa 6 — Cores recomendadas

### Loteamento — por situacao

| Situação | Cor |
| --- | --- |
| Aprovado | `#2E7D32` |
| Aprovado/Registrado | `#66BB6A` |
| Regularizado | `#1565C0` |
| Não Aprovado | `#C62828` |
| Indefinido | `#9E9E9E` |

### Zoneamento 2024 — por grupo funcional

| Tipo | Cor |
| --- | --- |
| ZEPAM (ambiental) | `#2E7D32` |
| ZEIS (social) | `#F57C00` |
| ZPR (residencial) | `#FFF176` |
| ZCE (centralidade) | `#EF5350` |
| ZDE (econômico) | `#7B1FA2` |

### Zoneamento 1978 — por grupo

| Grupo | Cor |
| --- | --- |
| ZR (Residencial) | `#FFF176` |
| ZCS (Comercial/Serv.) | `#EF5350` |
| ZI (Industrial) | `#7B1FA2` |
| ZAV (Alto Verde) | `#2E7D32` |
| ZE (Especial) | `#F57C00` |
| ZECS | `#EF9A9A` |
| S (Setor) | `#90CAF9` |

---

## Checklist de entrega

- [ ] 5 CSVs importados e tipados no Power Query
- [ ] P1: 3 Azure Maps sobrepostos + 3 bookmarks + botões sub-nav
- [ ] P2: 3 Azure Maps sobrepostos + 3 bookmarks + botões sub-nav
- [ ] Navegação principal P1 ↔ P2 funcionando
- [ ] `limite_municipal_osasco.json` carregado como Reference Layer 2 em todos os 6 mapas
- [ ] Cores por categoria configuradas
- [ ] Publicar no workspace Osasco
- [ ] Embed `<iframe>` gerado para o portal
