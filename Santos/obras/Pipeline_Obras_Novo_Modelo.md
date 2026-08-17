---
title: Pipeline de Obras — Novo Modelo (lh_solicitacoes_acto)
tags:
  - santos
  - obras
  - gold
  - pipeline
  - tecnico
aliases:
  - obras-novo-modelo
  - pipeline-obras
date: 2026-05-25
---

# Pipeline de Obras — Novo Modelo

Documentação técnica do processo de ingestão e transformação dos dados de obras do município de Santos no novo lakehouse unificado `lh_solicitacoes_acto`.

> [!info] Contexto
> Migração do pipeline legado (`lh_cidade_inteligente_santos`) para o novo módulo Acto parametrizado. O modelo anterior gerava 4 tabelas com muitas colunas nulas e nomenclatura inconsistente. O novo modelo é mais limpo, com lógica centralizada e tabelas prefixadas por município.

---

## Arquitetura do Pipeline

```
Silver (fato_solicitacoes + fato_campos + fato_etapas)
    ↓
nb_ingest_obras_aux          → dbo.santos_dim_zonas_bairros
                               dbo.santos_dim_etapas_setor
    ↓
nb_gold_santos_obras_acompanhamento → gold.santos_obras_acompanhamento  (OS-level)
nb_gold_santos_obras_tempo_etapa    → gold.santos_obras_tempo_etapa     (OS × Etapa)
```

**Fonte Silver:** `santos_obras` — 11.801 OS / 91.897 passagens de etapa / ~54k campos EAV

---

## Tabelas Auxiliares — `dbo` (nb_ingest_obras_aux)

Arquivo: `nbs/nbs_bronze/nb_ingest_obras_aux.ipynb`
Fonte: `Files/auxiliares/PMS_AuxiliarPDR.xlsx`

O arquivo Excel é convertido em tabelas Delta no schema `dbo` — separado do `gold` analítico por serem tabelas de referência/lookup, não fatos ou dimensões de negócio.

### `dbo.santos_dim_zonas_bairros`
| Coluna | Descrição |
|---|---|
| `bairro_raw` | Nome original do bairro conforme o Excel |
| `bairro_norm` | Nome normalizado (NFD → ASCII → UPPER → strip) — chave de join |
| `zona` | Zona PDR: `Z1`, `Z2` ou `Z3` |

- **122 linhas brutas → 103 após deduplicação** por `bairro_norm`
- Deduplicação necessária: o Excel tinha bairros repetidos com a mesma zona (ex: GONZAGA aparecia 2x em Z1)
- Detecção de colunas por nome do header (não por posição) — o Excel tem zona na coluna 0 e bairro na coluna 1, invertido do esperado intuitivamente

### `dbo.santos_dim_etapas_setor`
| Coluna | Descrição |
|---|---|
| `etapa_raw` | Nome original da etapa |
| `etapa_norm` | Nome normalizado — chave de join |
| `aux_setor_responsavel` | Setor responsável pela etapa (ex: SEONT, SEAP-CB, Usuário) |
| `aux_pdr` | Código PDR do setor (ex: PDR-CET, PDR-SEONT) |

- **183 etapas** mapeadas
- Deduplica por `etapa_norm` — etapas com mesmo nome normalizado mas capitalizações diferentes são tratadas como uma só

> [!warning] Manutenção
> O Excel precisa ser atualizado manualmente quando novas etapas são criadas no sistema Acto. Etapas sem mapeamento ficam com `aux_setor_responsavel = NULL` — atualmente 5.5% das passagens de etapa.

---

## Tabela Principal — `gold.santos_obras_acompanhamento`

Arquivo: `nbs/nbs_gold/nb_gold_santos_obras_acompanhamento.ipynb`
Grain: **1 linha por OS** — tabela de acompanhamento operacional

### Por que não `fato_solicitacoes_obras`?
O padrão dos outros domínios (CET, SEPREF) usa uma única tabela `fato_solicitacoes_*`. Para obras, optou-se por uma tabela `acompanhamento` mais rica que incorpora:
- Enriquecimento via AuxPDR (zona, setor responsável)
- Lógica de etapa atual (abertas vs. finalizadas)
- Flags de negócio (chefia SEONT, aprovação)

A tabela `fato_solicitacoes_obras` foi criada inicialmente mas eliminada por ser redundante — todos os campos úteis foram absorvidos pelo `acompanhamento`.

### Fluxo de construção

```
1. silver.fato_solicitacoes  → base da OS (id_os, servico, status, datas, solicitante)
2. silver.fato_campos        → pivot EAV → bairro_consolidado + titulo_profissional
                                           + numero_licenca + deliberacao
3. silver.fato_etapas        → etapa_atual (lógica abertas/finalizadas + flag_multiplas)
4. dbo.santos_dim_zonas_bairros  → zona (Z1/Z2/Z3) via join por bairro_norm
5. dbo.santos_dim_etapas_setor   → aux_setor_responsavel via join por etapa_norm
6. Colunas calculadas        → dias_na_etapa, zona_aplicavel, flag_chefia, flag_etapa_aprov
```

### Lógica de etapa atual

A etapa atual **não** usa `MAX(etapa)` (que seria alfabético). Usa uma Window com duas passagens:

1. **Etapas abertas** (`status IN ['EM ATENDIMENTO', 'PENDENTE']`): pega a mais recente por `data_inicio_etapa DESC`. Conta quantas abertas existem → `flag_multiplas_etapas`.
2. **OS sem etapa aberta**: pega a última etapa finalizada por `data_fim_etapa DESC`.

Isso garante que OS em andamento mostrem a etapa ativa, e OS finalizadas mostrem a última etapa que passou.

### Lógica de bairro

O campo bairro vem em **3 variantes distintas no EAV** dependendo do tipo de serviço:

| Campo EAV | Serviços |
|---|---|
| `txt_imob_logrbairro` | Novas edificações, habite-se, demolição |
| `cob_imob_logrbairro` | Manutenção de fachadas, reforma/legalização |
| `bairro` | Demais serviços |

Coalesce na ordem acima → `bairro_consolidado`. Somente `cob_imob_logrbairro` existe no Silver atual (os outros dois não aparecem nos dados de obras).

### `zona_aplicavel`

Calculado como `bairro_consolidado IS NOT NULL → 1, else 0`. Serviços sem relevância geográfica (ex: cadastro de profissional) não têm bairro e recebem `zona_aplicavel = 0`.

- **5.531 OS com zona preenchida (46.9%)** — esperado, pois ~50% das OS são cadastros profissionais sem endereço físico.

### Schema final (21 colunas)

| Coluna | Tipo | Origem | Descrição |
|---|---|---|---|
| `n_da_solicitacao` | string | fato_solicitacoes.id_os | ID da OS |
| `servico` | string | fato_solicitacoes | Tipo de serviço |
| `status` | string | fato_solicitacoes | Status atual do fluxo |
| `data_criacao` | timestamp | fato_solicitacoes | Abertura da OS |
| `data_finalizacao` | timestamp | fato_solicitacoes | Encerramento da OS |
| `solicitante` | string | fato_solicitacoes | Nome do solicitante |
| `titulo_profissional` | string | fato_campos (EAV) | Título do resp. técnico (coalesce PF/PJ) |
| `numero_licenca` | string | fato_campos (EAV) | Número da licença emitida |
| `deliberacao` | string | fato_campos (EAV) | Resultado da análise técnica |
| `etapa_atual` | string | fato_etapas (Window) | Etapa ativa ou última finalizada |
| `executor_atual` | string | fato_etapas (Window) | Responsável pela etapa atual |
| `flag_multiplas_etapas` | int | fato_etapas (Window) | 1 se OS tem >1 etapa aberta simultaneamente |
| `flag_chefia` | int | calculado | 1 se etapa está em SEONT-Chefia ou SEONT-Chefia (D.O) |
| `flag_etapa_aprov` | int | calculado | 1 se etapa_atual contém "ANALISADA POR" |
| `aux_setor_responsavel` | string | dim_etapas_setor | Setor responsável pela etapa atual |
| `data_etapa_inicio` | timestamp | fato_etapas | Início da etapa atual |
| `data_etapa_fim` | timestamp | fato_etapas | Fim da etapa atual (NULL se aberta) |
| `dias_na_etapa` | int | calculado | Dias na etapa (hoje-início se aberta; fim-início se fechada) |
| `zona` | string | dim_zonas_bairros | Zona PDR: Z1, Z2 ou Z3 |
| `bairro_consolidado` | string | fato_campos (EAV) | Bairro do imóvel |
| `zona_aplicavel` | int | calculado | 1 se OS tem endereço físico |

### Métricas de qualidade (25/05/2026)
- Total OS: **11.801**
- zona preenchida: **5.531 (46.9%)**
- aux_setor_responsavel: **11.686 (99.0%)**
- etapa_atual preenchida: **11.800 (100.0%)**
- flag_multiplas_etapas=1: **3.079**

---

## Tabela de Tempo — `gold.santos_obras_tempo_etapa`

Arquivo: `nbs/nbs_gold/nb_gold_santos_obras_tempo_etapa.ipynb`
Grain: **1 linha por passagem de etapa** (~91k registros)

Usada para análise de SLA, tempo por setor, identificação de gargalos no fluxo.

### Fluxo

```
silver.fato_etapas (santos_obras) → join dbo.santos_dim_etapas_setor → gold.santos_obras_tempo_etapa
```

### Colunas principais

| Coluna | Origem | Descrição |
|---|---|---|
| `os` | fato_etapas.id_os | ID da OS |
| `etapa` | fato_etapas | Nome da etapa |
| `servico` | fato_etapas | Tipo de serviço |
| `data_criacao_os` | fato_etapas | Abertura da OS |
| `data_inicio_etapa` | fato_etapas | Início desta passagem |
| `data_fim_etapa` | fato_etapas | Fim desta passagem |
| `duracao_dias_preciso` | calculado | `datediff` como float |
| `duracao_dias_int` | calculado | `datediff` como int |
| `executor` | fato_etapas | Responsável pela etapa |
| `status` | fato_etapas | Status desta passagem |
| `aux_setor_responsavel` | dim_etapas_setor | Setor responsável |
| `aux_pdr` | dim_etapas_setor | Código PDR |

### Métricas de qualidade (25/05/2026)
- Total registros: **91.897** (passagens de etapa)
- aux_setor_responsavel preenchido: **86.874 (94.5%)**
- 5.5% sem mapeamento = etapas novas não cadastradas no AuxPDR

---

## Decisões de Arquitetura

### Por que eliminar `gold.santos_obras_seont`?
O notebook `nb_gold_santos_obras_seont` apenas filtrava `santos_obras_acompanhamento` pelo setor SEONT e adicionava `flag_chefia` e `flag_etapa_aprov`. Como o Power BI faz filtros nativamente, criar uma tabela separada só para um subconjunto é overhead desnecessário. As duas flags foram absorvidas pelo `acompanhamento`.

### Por que `dbo` para as dims e não `gold`?
Tabelas `dbo` são auxiliares/referência — não são fatos ou dimensões de negócio consumidos diretamente pelo Power BI. Separar em `dbo` evita poluir o schema `gold` com tabelas de suporte, e deixa claro que essas tabelas são infraestrutura do pipeline.

### Por que ler as dims via `spark.table()` e não Excel direto?
Os notebooks Gold originalmente liam o Excel diretamente via `pd.read_excel()`. Isso criava 3 leituras redundantes do mesmo arquivo (acompanhamento + tempo_etapa + seont). A centralização em tabelas Delta via `nb_ingest_obras_aux` garante:
- Uma única leitura do Excel por execução
- Dims consultáveis via SQL endpoint
- Histórico de versões via Delta

### Prefixo `santos_` obrigatório
Todos os clientes estão no mesmo lakehouse `lh_solicitacoes_acto`. Sem prefixo, tabelas de municípios diferentes colidiriam. Padrão: `gold.{municipio}_{dominio}_{tipo}`.

---

## Ordem de Execução

```
1. nb_ingest_obras_aux              (bronze) — cria/atualiza dims no dbo
2. nb_gold_santos_obras_acompanhamento (gold) — OS-level, lê dims do dbo
3. nb_gold_santos_obras_tempo_etapa    (gold) — OS×Etapa, lê dim etapas do dbo
```

Os notebooks 2 e 3 são independentes entre si e podem rodar em paralelo após o passo 1.

Orquestrado por `_nb_gold_orquestracao` via `%run`.

---

## Pendências

- [ ] **Campos de pavimentos e área**: EAV campos para o novo painel (OS #962592). Nomes no Silver a confirmar em Fabric (`campo LIKE '%pav%'` ou `'%area%'`).
- [ ] **Atualização do AuxPDR**: 5.5% das etapas sem setor mapeado. Solicitar atualização do Excel com Kelly/DECONTE.
- [ ] **Reconexão PBI**: 4 painéis de obras ainda conectados ao LH legado. Reconexão com Jorge após validação de schema.

---

## Relacionados

- [[SPEC_DRIVE_PAINEL_OBRAS_PAVIMENTOS]] — novo painel OS por bairro, etapa e pavimento
- [[migracao-santos-acto-novo-modelo|Migração Santos Acto — Novo Modelo]] — contexto geral da migração
- [[DOCUMENTACAO_TECNICA_ACTO]] — arquitetura do módulo Acto
