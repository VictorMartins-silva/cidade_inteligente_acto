---
title: Fabric Santos — Mapeamento Analítico dos nbs/
date: 2026-05-20
tags:
  - municipio/santos
  - ferramenta/fabric
  - tipo/referencia
  - tema/etl-elt
projeto: acto-santos
fonte: mapeamento-consolidado-v1-8
status: ativo
---
# Fabric Santos — Mapeamento Analítico dos `nbs/`
> **Acto Cidade Inteligente · Município de Santos · Workspace Fabric**  
> Baseado em: Mapeamento Consolidado v1.8 (Abril 2026)  
> Finalidade: guiar planejamento, simplificação e priorização de melhorias arquiteturais

---

## 1. Mapa de Notebooks — Visão Geral

```
nbs/
├── [RAIZ]
│   ├── nb_ingest_acto_santos               → CSV/API → Delta (tb_os_acto)
│   ├── nb_ingest_dim_date                  → Delta (dim_date_1, dim_date_2)
│   ├── nb_ingest_tb_aux_servicos           → Delta (tb_aux_servicos, tb_aux_regionais)
│   ├── nb_utils_api_acto_gestao            ★ UTIL CENTRAL — funções API gestão
│   ├── nb_utils_api_acto_gestao_obras      ★ UTIL OBRAS — funções API obras
│   ├── nb_utils_ingest_acto_gestao         ★ UTIL EXTRAÇÃO — sem try/except ⚠️R7
│   └── nb_ingest_carta_servicos_santos     → CSV → Gold (proprietário diferente ⚠️)
│
├── avaliacao_servicos/
│   ├── nb_silver_santos_avaliacao          → silver_avaliacoes_servico.parquet
│   ├── nb_gold_santos_avaliacao            → gold_avaliacoes_servico (Delta, overwrite)
│   └── nb_gold_santos_avaliacao_sentimento → gold_avaliacoes_servicos_sentimento (Delta, append)
│
├── obras/
│   ├── nb_ingest_silver_acto_gestao_obras_santos → silver_obras_*.parquet ⚠️R5 401 ATIVO
│   ├── nb_gold_acto_gestao_obras                 → gold_pdr_acompanhamentos_os ⚠️R1 R2
│   ├── nb_gold_acto_gestao_obras_etapas          → gold_obras_tempo_etapa
│   └── SEONT/nb_gold_acto_gestao_obras_seont_os  → gold_pdr_seont_os (sem pipeline)
│
├── cet/
│   ├── nb_ingest_estrutura_cet            → tb_aux_estrutura_organizacional_cet (sem pipeline)
│   ├── nb_ingest_silver_cet_carga_descarga → silver_cet_carga_descarga_*.parquet ⚠️R4
│   ├── nb_gold_acto_gestao_cet            → gold_cet_servicos
│   ├── nb_gold_acto_gestao_cet_carga_descarga → gold_cet_carga_descarga
│   └── curso_motoristas/
│       ├── nb_ingest_santos_curso_motoristas → silver_solicitacoes + silver_etapas.parquet
│       └── nb_silver_santos_curso_motoristas → gold_curso_motorista (742 lin, 120 col) ✅ rowcount
│
├── manifestacao_ouvidoria/
│   ├── nb_gold_acto_gestao_manifestacoes_ouvidoria → gold_manifestacoes_ouvidoria ⚠️R4
│   └── nb_gold_acto_gestao_ouvidoria_servicos      → gold_ouvidoria_servicos (unionAll 5 tabelas) ★
│
├── segov/
│   └── nb_gold_acto_gestao_segov          → gold_segov_servicos (366 lin.)
│
├── seinfra/
│   └── nb_gold_acto_gestao_seinfra        → gold_seinfra_servicos (1.161 lin.)
│
├── sepref/
│   └── nb_gold_acto_gestao_sepref         → gold_sepref_servicos (usa JSON externo)
│
├── carta_servicos/
│   ├── gestao_prazo_sla/
│   │   ├── 01_ingestao_cartas_servico     → Gold (Silver) — executado ✅
│   │   ├── 02_ingestao_solicitacoes       → NUNCA executado ⚠️
│   │   ├── config_api_acto_atualizado     → UTIL: tokens multi-município
│   │   └── nb_utils_sla_santos            → UTIL: funções SLA
│   └── nb_ingest_carta_servicos_santos    → Gold via CSV ⚠️R1 (proprietário: Francisco)
│
└── caged_santos/
    └── nb_ingest_caged_santos             → EM CONSTRUÇÃO — nunca executado ⚠️R9
```

---

## 2. Relações entre Notebooks — Grafo de Dependências

### 2.1 Fluxo principal: Avaliação de Serviços

```
nb_utils_api_acto_gestao  ←──── nb_utils_ingest_acto_gestao ⚠️R7
        │
        ▼
nb_silver_santos_avaliacao
        │
        ▼
nb_gold_santos_avaliacao
        │
        ├──▶ nb_gold_santos_avaliacao_sentimento
        │         (append incremental — risco dessincronização ⚠️R3)
        │
        └──▶ Pipeline: pl_ingest_acto_gestao_santos_avaliacoes_servicos
```

### 2.2 Fluxo: Obras Públicas

```
nb_utils_ingest_acto_gestao ⚠️R7
nb_utils_api_acto_gestao_obras (login dinâmico)
        │
        ▼
nb_ingest_silver_acto_gestao_obras_santos  ⚠️R5 (401 ATIVO desde 11/03/2025)
        │
        ├──▶ nb_gold_acto_gestao_obras  ⚠️R1 R2
        │         │
        │         ├──▶ nb_gold_acto_gestao_obras_seont_os  (sem pipeline!)
        │         │
        │         └──▶ [pl_ingest_obras_santos]
        │
        └──▶ nb_gold_acto_gestao_obras_etapas
                  │
                  └──▶ [pl_ingest_obras_santos] (paralelo com Gold obras)
```

### 2.3 Fluxo: CET + Curso de Motoristas

```
nb_utils_api_acto_gestao
        │
        ├──▶ nb_gold_acto_gestao_cet  →  gold_cet_servicos
        │
        └──▶ nb_silver_santos_curso_motoristas
                  ↑
        nb_ingest_santos_curso_motoristas (Bronze)
                  │
                  └──▶ gold_curso_motorista ✅ rowcount

nb_ingest_silver_cet_carga_descarga  ⚠️R4
        │
        └──▶ nb_gold_acto_gestao_cet_carga_descarga

[Tudo via pipeline: pl_ingest_acto_gestao_santos_cet]
```

### 2.4 Fluxo: Ouvidoria Agregadora (padrão único no workspace)

```
gold_sepref_servicos    ──┐
gold_seinfra_servicos   ──┤
gold_cet_servicos       ──┼──▶ nb_gold_acto_gestao_ouvidoria_servicos
gold_segov_servicos     ──┤         │
gold_manifestacoes_ouvidoria ─┘     └──▶ gold_ouvidoria_servicos (unionAll)
                                          │
                                          └──▶ [pl_ingest_ouvidoria_servicos]
```

### 2.5 Fluxo: Secretarias Simples (segov / seinfra / sepref)

```
nb_utils_api_acto_gestao
        │
        ├──▶ nb_gold_acto_gestao_segov   →  gold_segov_servicos
        ├──▶ nb_gold_acto_gestao_seinfra →  gold_seinfra_servicos
        └──▶ nb_gold_acto_gestao_sepref  →  gold_sepref_servicos
                  ↑ usa import_json_payload() — único com esse padrão
```

---

## 3. Separação de Responsabilidades por Domínio

| Domínio | Notebooks | Proprietário | Camadas |
|---|---|---|---|
| Infraestrutura / Utils | [[Documentação_Fabric/Santos/nbs/nb_utils_api_acto_gestao.ipynb|nb_utils_api_acto_gestao]], [[Documentação_Fabric/Santos/nbs/nb_utils_api_acto_gestao_obras.ipynb|nb_utils_api_acto_gestao_obras]], [[Documentação_Fabric/utils/nb_utils_ingest_acto_gestao.ipynb|nb_utils_ingest_acto_gestao]] | Yuri / Victor | Utilitário |
| Avaliação de Serviços | 3 notebooks | Yuri (Silver/Gold) + Victor (Sentimento) | Silver → Gold → Gold+IA |
| Obras Públicas | 4 notebooks | Yuri (Silver/Etapas) + Victor (Gold/SEONT) | Bronze → Silver → Gold |
| CET | 4 notebooks + 2 (motoristas) | Yuri (base) + Victor (motoristas) | Bronze → Silver → Gold |
| Ouvidoria / Agregação | 2 notebooks | Yuri | Gold → Gold+ agregado |
| Secretarias simples | 3 notebooks (segov/seinfra/sepref) | Yuri | API → Gold direto |
| Carta de Serviços | 4 notebooks (API) + 1 (CSV) | Victor (API) + Francisco (CSV) | Bronze → Gold |
| CAGED | 1 notebook | Yuri | **Em construção — não produção** |

---

## 4. Diagnóstico de Processos Deficientes

### 🔴 CRÍTICO — Bloqueio de Produção

#### R5 · Token 401 Ativo — Obras Paradas
- **Onde:** `nb_ingest_silver_acto_gestao_obras_santos`
- **Desde:** 11/03/2025 — **mais de 60 dias sem ingestão**
- **Impacto:** toda a cadeia de obras está parada (Gold obras, Gold etapas, SEONT, 4 relatórios PBI)
- **Causa:** token de obras com vida útil curta, sem retry automático de reautenticação
- **Ação:** adicionar `try/except HTTPError 401 → login_acto_gestao_obras() → retry` em `nb_utils_api_acto_gestao_obras`

#### R9 · Bug de Código IBGE — CAGED bloqueado
- **Onde:** `nb_ingest_caged_santos`
- **Problema:** `CODIGO_OSASCO = 353440` hardcoded — deve ser `CODIGO_SANTOS = 353845`
- **Impacto:** se executado, ingeriria dados de Osasco no workspace de Santos
- **Ação:** corrigir antes de qualquer ativação do CAGED

---

### 🟡 ATENÇÃO — Fragilidade Arquitetural

#### R1 · Single Point of Failure — Arquivos Físicos como Fonte de Dados

| Arquivo | Usado em | Risco |
|---|---|---|
| `tb_aux.xlsx` (Excel) | `nb_utils_api_acto_gestao` | Mudança de local quebra avaliação |
| `PMS_AuxiliarPDR.xlsx` | `nb_gold_acto_gestao_obras` | Mudança de local quebra Gold obras |
| `grid_carta_servicos_santos.csv` | `nb_ingest_carta_servicos_santos` | CSV desatualizado = dados defasados |
| `bd_carta_servicos_santos.csv` | `nb_ingest_carta_servicos_santos` | idem |

**Ação:** migrar todos para tabelas Delta no Lakehouse.

#### R2 · Código Duplicado — Funções sem Centralização

| Função | Aparece em |
|---|---|
| `ajustar_nome_colunas()` | múltiplos notebooks |
| `harmonizar_nome_bairros()` | múltiplos notebooks |
| `mapa_bairros` (dicionário inline) | `nb_gold_acto_gestao_obras` |
| `tratar_nome_colunas()` / `colunas_para_snake_case()` | `nb_utils_ingest_acto_gestao` |

**Ação:** criar `nb_utils_shared` com todas as funções comuns. Substituir duplicatas por `%run ./nb_utils_shared`.

#### R3 · Dessincronização overwrite × append (Sentimento)
- `nb_gold_santos_avaliacao` usa **overwrite** (Gold base)
- `nb_gold_santos_avaliacao_sentimento` usa **append** incremental
- Se o Gold base for sobrescrito e o sentimento falhar, os IDs ficam desalinhados silenciosamente
- **Ação:** adicionar `allowFailure = false` isolado para o notebook de sentimento no pipeline

#### R4 · Ausência de Validação de Rowcount

Notebooks que escrevem sem verificar se o DataFrame está vazio:

| Notebook | Escrita sem assert |
|---|---|
| `nb_ingest_silver_acto_gestao_obras_santos` | `to_parquet()` |
| `nb_ingest_silver_cet_carga_descarga` | `to_parquet()` |
| `nb_ingest_santos_curso_motoristas` | `to_parquet()` |
| `nb_gold_acto_gestao_manifestacoes_ouvidoria` | `saveAsTable` |
| `nb_gold_acto_gestao_cet` | `saveAsTable` |

**Padrão correto já implementado em:** `nb_silver_santos_curso_motoristas` ✅  
**Ação:** adicionar `assert len(df) > threshold` antes de qualquer escrita nos notebooks listados.

#### R6 · Dois Layouts de Payload — `adicionar_etapa_atual` vs `_2`
- `adicionar_etapa_atual()` usa `'Nº Solicitação│1'`
- `adicionar_etapa_atual_2()` usa `'Nº Solicitação'`
- Sem documentação de qual endpoint retorna cada formato
- **Ação:** documentar em docstring e adicionar validação de colunas na entrada

#### R7 · `nb_utils_ingest_acto_gestao` sem Tratamento de Erros
- Usa `raise_for_status()` direto sem `try/except`
- Falhas de API propagam sem alertas para: `avaliacao_servicos` e `curso_motoristas`
- **Ação:** encapsular em `try/except HTTPError` com retry e log de falha

---

### 🔵 ATENÇÃO — Governança e Rastreabilidade

#### R_dup · Carta de Serviços com Duas Abordagens Paralelas

| Abordagem | Proprietário | Fonte | Status |
|---|---|---|---|
| `gestao_prazo_sla/` (API) | Victor | API Acto Gestão | `02_ingestao_solicitacoes` nunca executado |
| `nb_ingest_carta_servicos_santos` | Francisco | CSV em `/raw_cadastro_carta/` | Em produção (pipeline ativo) |

- Não está definido qual é a **fonte de verdade**
- CSV pode estar desatualizado se ninguém atualizar manualmente o arquivo
- **Ação:** decidir e documentar a fonte canônica; desativar ou arquivar a abordagem redundante

#### R8 · Localização Incorreta de `curso_motoristas` na Documentação
- Produção: `nbs/cet/curso_motoristas/`
- Documentação anterior: `nbs/curso_motoristas/`
- **Ação:** atualizar toda referência anterior (já corrigido em v1.8, verificar protótipos locais)

---

## 5. Processos sem Pipeline Mapeado

Os notebooks abaixo **não têm pipeline identificado** — execução manual ou por pipeline não rastreado:

| Notebook | Saída | Risco |
|---|---|---|
| `nb_gold_acto_gestao_obras_seont_os` | `gold_pdr_seont_os` (211 reg.) | Sem automação — dado pode ficar defasado |
| `nb_ingest_estrutura_cet` | `tb_aux_estrutura_organizacional_cet` | Atualização manual da hierarquia CET |

**Ação:** criar pipelines dedicados ou incluir esses notebooks nos pipelines existentes (obras e cet respectivamente).

---

## 6. Padrão Pipeline — O que funciona bem e o que diverge

### Padrão uniforme (8 de 9 pipelines):
```
Notebook Gold → RefreshSqlEndpoint → Refresh modelo PBI
```

### Exceção: `pl_ingest_obras_santos` (9 atividades — mais complexo):
```
Silver → Gold obras → Gold SEONT ──┐
              └──── Gold etapas ───┴──▶ RefreshSqlEndpoint → 4× Refresh PBI (paralelo)
```

### Pendências de agendamento:
- **Confirmado:** `pl_ingest_obras_santos` — diário 00:30 BRT
- **Desconhecido:** todos os outros 8 pipelines (requer acesso via API REST Fabric)

---

## 7. Plano de Ação Priorizado

### 🔴 Imediato (bloqueia produção)

| # | Ação | Responsável | Esforço |
|---|---|---|---|
| 1 | Corrigir retry 401 em obras (`nb_utils_api_acto_gestao_obras`) | Victor | Baixo |
| 2 | Corrigir `CODIGO_IBGE` no CAGED (353440 → 353845) | Victor/Yuri | Mínimo |

### 🟡 Curto prazo (fragilidade alta)

| # | Ação | Responsável | Esforço |
|---|---|---|---|
| 3 | Adicionar `assert len(df) > 0` antes de todos os `to_parquet/saveAsTable` | Victor/Yuri | Baixo |
| 4 | Migrar Excel/CSV auxiliares para tabelas Delta | Yuri | Médio |
| 5 | Obter agendamentos dos 9 pipelines via API REST Fabric | Victor | Baixo |
| 6 | Criar pipeline para `nb_gold_acto_gestao_obras_seont_os` | Victor | Baixo |

### 🟢 Médio prazo (melhoria de manutenção)

| # | Ação | Responsável | Esforço |
|---|---|---|---|
| 7 | Criar `nb_utils_shared` e centralizar funções duplicadas | Victor/Yuri | Médio |
| 8 | Adicionar `try/except HTTPError` em `nb_utils_ingest_acto_gestao` | Yuri | Baixo |
| 9 | Definir fonte canônica para carta_servicos (CSV vs API) | Victor + Francisco | Decisão |
| 10 | Documentar payloads `adicionar_etapa_atual` vs `_2` com docstrings | Victor | Baixo |

### 🔵 Longo prazo (arquitetura)

| # | Ação | Responsável | Esforço |
|---|---|---|---|
| 11 | Mapear `Santos/modelos_semanticos` e `Santos/nbs_analise` | Victor | Médio |
| 12 | Ativar e validar `02_ingestao_solicitacoes` de carta_servicos | Victor | Médio |
| 13 | Revisitar `pl_cet` e `pl_manifestacoes_ouvidoria` (nomes truncados) | Victor | Baixo |

---

## 8. Volumes de Dados por Domínio

| Domínio | Tabela Gold | Registros |
|---|---|---|
| Avaliação | gold_avaliacoes_servico | 12.996 |
| Avaliação Sentimento | gold_avaliacoes_servicos_sentimento | 1.340 |
| Obras — OS | gold_pdr_acompanhamentos_os | 10.366 |
| Obras — Etapas | gold_obras_tempo_etapa | 71.500 |
| Obras — SEONT | gold_pdr_seont_os | 211 |
| CET — Serviços | gold_cet_servicos | — |
| CET — Carga/Descarga | gold_cet_carga_descarga | 1.046 |
| Curso Motoristas | gold_curso_motorista | 742 (120 col) |
| Manifestação Ouvidoria | gold_manifestacoes_ouvidoria | 798 |
| Ouvidoria Agregada | gold_ouvidoria_servicos | unionAll de 5 secretarias |
| SEGOV | gold_segov_servicos | 366 |
| SEINFRA | gold_seinfra_servicos | 1.161 |
| SEPREF | gold_sepref_servicos | — |

---

## 9. Pendências de Mapeamento

| Área | Item | Prioridade |
|---|---|---|
| `Santos/modelos_semanticos` | Inventário de modelos semânticos PBI | Média |
| `Santos/nbs_analise` | Inventário — exploratório ou produção? | Média |
| Pipelines | Agendamentos dos 9 pipelines | Alta |
| `pl_cet` | Atividades 2 e 7 (nomes truncados) | Média |
| `pl_manifestacoes_ouvidoria` | Atividade 1 (sem nome capturado) | Média |
| `carta_servicos/01_ingestao` | Nome completo da tabela de saída | Baixa |

---

*Gerado em Abril 2026 · Acto Cidade Inteligente / Santos · Workspace ID: `96fe5a53-3a22-4443-8d0a-e2f6d61a2690`*

---

## Ver Também

- [[_mapa-do-vault]] — índice geral do vault
- [[Conhecimento/Fabric/fabric-workspace-acto-cidade-inteligente|fabric-workspace-acto-cidade-inteligente]] — workspace completo Acto Cidade Inteligente
- [[Conhecimento/Fabric/pipeline-acto-santos-fabric|pipeline-acto-santos-fabric]] — fluxo Data Factory + notebooks
- [[Projetos/acto-santos-pipeline]] — projeto ACTO Santos
