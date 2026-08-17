# 📁 Estrutura de Documentação Fabric

## Navegação Rápida

| Pasta | Conteúdo | Uso |
|-------|----------|-----|
| **00_MAPA.md** | Hub central de links | Comece aqui — entenda o contexto |
| **CLAUDE.md** | Instruções para IA + Riscos Ativos | Novo dev lê isto em primeiro lugar |
| **REFERÊNCIA_TÉCNICA_COMPLETA.md** | Padrões, arquitetura, riscos técnicos | Consulta durante desenvolvimento |
| **01-Municípios/** | Santos, Osasco, Acto, Mauá, SJRP, Aparecida | Trabalho diário — escolha seu município |
| **02-Técnica/** | Arquitetura, Diagramas, Utils | Referência técnica consolidada |
| **03-Dados/** | Dados Públicos, Mapas, Power BI | Fontes externas, mapas, painéis |
| **04-Specs/** | Especificações de features | Planejamento e requisitos |
| **05-Painéis/** | Documentação de painéis Power BI | Análise de indicadores |
| **06-Estratégia/** | Produto DataHub, Tarefas | Roadmap e planejamento estratégico |

---

## 🚀 Fluxo Típico de Trabalho

### Novo Dev (Onboarding — 15 min)
1. **CLAUDE.md** (5 min)
   - Contexto geral
   - Riscos ativos (R5, R9, R7, R3, R4, R1, R2)
   - Qual issue/risk você está corrigindo?

2. **00_MAPA.md** (2 min)
   - Visão geral da documentação
   - Onde encontrar cada coisa

3. **01-Municípios/[seu-municipio]/README.md** (5 min)
   - Estrutura específica do município
   - Pipelines e notebooks
   - Contatos

4. **Comece no notebook ou issue**

---

### Debugging de Pipeline (Hoje há um erro!)

1. **CLAUDE.md → "Known Active Issues"**
   - Qual risk match? (R5, R9, etc.)
   - Instruções de correção

2. **01-Municípios/[municipio]/README.md**
   - Fluxo esperado
   - Checklist de validação

3. **02-Técnica/Arquitetura/**
   - Padrão de código
   - Padrão de erro handling

4. **Git log** + **Commits recentes**
   - Quem mexeu lá?
   - Qual foi a mudança?

---

### Criando um Novo Spec/Feature

1. **04-Specs/** — Escreva a especificação
   - `spec_nova_feature_[data].md`
   - Template: Contexto → Problema → Solução → Aceitação

2. **06-Estratégia/Tarefas/**
   - Crie uma tarefa rastreável
   - Vinculada ao spec

3. **Atualize 00_MAPA.md**
   - Linkify a novo spec
   - Indique status

4. **Converse com a equipe**
   - Link no Slack
   - Discuta no PR

---

### Visualizando Dados / Power BI

1. **03-Dados/Power BI/**
   - Qual painel você quer entender?
   - Link para o relatório + documento técnico

2. **02-Técnica/Diagramas/**
   - Entenda a arquitetura dos dados
   - Fluxo Bronze → Silver → Gold

3. **03-Dados/Dados Públicos/ ou Mapas/**
   - Se usa dados externos
   - Se usa mapas geoespaciais

---

## 📂 Estrutura Detalhada

```
Documentação_Fabric/
│
├─ 📖 RAIZ (acesso rápido — leia primeiro)
│  ├─ 00_MAPA.md                              [HUB CENTRAL]
│  ├─ CLAUDE.md                               [CONTEXTO + RISCOS]
│  ├─ REFERÊNCIA_TÉCNICA_COMPLETA.md          [REFERÊNCIA]
│  ├─ PROGRESSO_REORGANIZACAO.md              [STATUS]
│  └─ README_ESTRUTURA.md                     [ESTE ARQUIVO]
│
├─ 📍 01-Municípios/                          [TRABALHO DIÁRIO]
│  ├─ Santos/
│  │  ├─ README.md                            [Guia rápido]
│  │  ├─ Pipelines/                           [Data Factory]
│  │  ├─ Notebooks/                           [Pyspark]
│  │  └─ Issues/                              [Known issues]
│  ├─ Osasco/
│  ├─ Acto/
│  ├─ Mauá/
│  ├─ SJRP/
│  └─ Aparecida de Goiânia/
│
├─ 🔧 02-Técnica/                             [REFERÊNCIA CONSOLIDADA]
│  ├─ Arquitetura/
│  │  ├─ 01-Arquitetura-Geral.md              [Medallion, fluxo]
│  │  ├─ 02-Padrões-Código.md                 [Como escrever]
│  │  ├─ 03-SCD-Type2.md                      [Dimensões)
│  │  └─ ...
│  ├─ Diagramas/
│  │  ├─ canvas/                              [Miro, etc]
│  │  ├─ mermaid/                             [.mmd files]
│  │  └─ images/                              [Screenshots]
│  └─ Utils/
│     ├─ common-functions.md                  [Funções reutilizáveis]
│     ├─ sql-snippets.md                      [Queries padrão]
│     └─ ...
│
├─ 📊 03-Dados/                               [FONTES, MAPAS, BI]
│  ├─ Dados Públicos/
│  │  ├─ IBGE/                                [Dados do IBGE]
│  │  ├─ Acto API/                            [Schema da API]
│  │  └─ CAGED/                               [Emprego]
│  ├─ Mapas Geoespaciais/
│  │  ├─ Bairros-Santos.md                    [Mapeamento de bairros]
│  │  ├─ shapefiles/                          [Dados GIS]
│  │  └─ ...
│  └─ Power BI/
│     ├─ Modelo-Semântico.md                  [DAX, tabelas]
│     ├─ Relatórios/                          [Docs por relatório]
│     └─ ...
│
├─ 📋 04-Specs/                               [ESPECIFICAÇÕES]
│  ├─ spec_novo_pipeline_ssp.md               [Feature specs]
│  ├─ spec_scd_type2_obras.md                 [Design decisions]
│  └─ ...
│
├─ 🎨 05-Painéis/                             [DOCUMENTAÇÃO DE PAINÉIS]
│  ├─ Avaliação de Serviços.md                [Painel + Indicadores]
│  ├─ Gestão de Obras.md                      [Sequências, SLAs]
│  ├─ Cursos Motoristas.md                    [Certificações]
│  └─ ...
│
└─ 🏛️ 06-Estratégia/                          [PRODUTO, ROADMAP]
   ├─ Produto_DataHub/
   │  ├─ Visão do Produto.md                  [O que é]
   │  ├─ Roadmap.md                           [Q3-Q4 2026]
   │  └─ ...
   └─ Tarefas/
      ├─ Backlog.md                           [Tudo a fazer]
      ├─ In Progress.md                       [Agora]
      └─ Done.md                              [Histórico]
```

---

## 💡 Dicas Importantes

### 🔴 Riscos Ativos (em CLAUDE.md)
- **R5 [CRÍTICO]**: Obras pipeline parou em 11/03 (HTTP 401). Corrigir: adicionar retry com login em `nb_utils_api_acto_gestao_obras`
- **R9 [CRÍTICO]**: `nb_ingest_caged_santos` tem CODIGO_OSASCO (353440) em vez de CODIGO_SANTOS (353845)
- **R7**: `nb_utils_ingest_acto_gestao` falta `try/except` em `raise_for_status()`
- **R3**: Gold base reescrita sem sincronização com sentimento → IDs podem ficar desalinhados
- **R4**: DataFrames sem rowcount assertions antes de `to_parquet()` / `saveAsTable()`
- **R1**: Arquivos auxiliares (Excel/CSV) são ponto único de falha
- **R2**: Funções duplicadas — planejar consolidação em `nb_utils_shared`

### 🔧 Padrões Importantes
- **SCD Type 2 (Carta de Serviços)**: Sempre usar `dt_abertura` entre `dt_inicio_vigencia` e `dt_fim_vigencia`
- **Padrão de assertivas**: `assert len(df) > threshold` antes de `to_parquet()`
- **Nomes de função**: `adicionar_etapa_atual()` vs `adicionar_etapa_atual_2()` — validar coluna de entrada!
- **Namespacing de colunas**: Use `ajustar_nome_colunas()` para padronizar

### 📋 Antes de Fazer Commit
- [ ] Testei no notebook
- [ ] Validei com assertivas
- [ ] Atualizei CLAUDE.md se há novos riscos
- [ ] Rodei o painel correspondente (se BI)
- [ ] Linkifiquei em 00_MAPA.md

---

## 🔗 Atalhos Rápidos

| Objetivo | Atalho |
|----------|--------|
| Entender o projeto | → `00_MAPA.md` |
| Corrigir um erro | → `CLAUDE.md` → "Known Active Issues" |
| Procurar um notebook | → `01-Municípios/[municipio]/` |
| Entender arquitetura | → `02-Técnica/Arquitetura/01-Arquitetura-Geral.md` |
| Ver um diagrama | → `02-Técnica/Diagramas/` |
| Encontrar um painel | → `05-Painéis/` |
| Planejar feature | → `04-Specs/` + `06-Estratégia/Tarefas/` |
| Explorar mapa | → `03-Dados/Mapas Geoespaciais/` |

---

**Última atualização**: 17/08/2026  
**Versão**: Reorganizada para trabalho diário — estrutura temática
