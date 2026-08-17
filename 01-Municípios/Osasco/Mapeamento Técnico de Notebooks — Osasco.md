---
title: "Mapeamento Técnico de Notebooks — Osasco"
tags:
  - ferramenta/fabric
  - tipo/notebook
  - tipo/inventario
  - municipio/osasco
aliases:
  - inventario notebooks osasco
  - notebooks osasco
relacionados:
  - "[[Santos/DOCUMENTACAO_CONSOLIDADA_FABRIC]]"
  - "[[Osasco/00_INDEX_OSASCO]]"
---

# Mapeamento Técnico de Notebooks — Município de Osasco

**Revisão:** Abril de 2026 — Leitura direta de todos os notebooks (.ipynb)
**Contexto:** Workspace Microsoft Fabric `lh_cidade_inteligente_osasco`
**Caminho Fabric:** Acto Cidade Inteligente > Osasco > nbs

> **Objetivo declarado pelo líder:** os notebooks estão "meio bagunçados". A meta é alterar o final do código para gerar tabelas Delta no lakehouse como camada **Gold** (em vez de arquivos/Parquet), para que o Jorge replique o Dash em Python no Power BI.

---

## Inventário Global — Todos os Domínios

| #   | Notebook                                           | Domínio             | Camada | Saída atual                                                                               | Modo            | Migração necessária |
| --- | -------------------------------------------------- | ------------------- | ------ | ----------------------------------------------------------------------------------------- | --------------- | ------------------- |
| 1   | `nb_ingest_atendimento_cras`                       | Assistência Social  | Gold   | `gold_atendimento_cras`, `gold_atendimento_cras_etapas`                                   | overwrite       | Não                 |
| 2   | `nb_append_pbf`                                    | Assistência Social  | Silver | `silver_pbf_sp`                                                                           | append          | Criar Gold Osasco   |
| 3   | `nb_gold_pbf`                                      | Assistência Social  | Gold   | `gold_pbf_municipios_selecionados`                                                        | overwrite (SQL) | Não                 |
| 4   | `nb_ingest_dump_pbf`                               | Assistência Social  | Bronze | `dump_pbf_sp`                                                                             | overwrite       | Não                 |
| 5   | `nb_ingest_bronze_cad_unico`                       | Assistência Social  | Bronze | `bronze_cad_unico_reg01…reg18`                                                            | append          | Não                 |
| 6   | `nb_silver_cad_unico`                              | Assistência Social  | Silver | `silver_cad_unico_reg01`, `reg04`                                                         | overwrite       | Não                 |
| 7   | `nb_gold_cad_unico_pg`                             | Assistência Social  | Gold   | `gold_cad_unico_*` (12 tabelas)                                                           | overwrite       | Não                 |
| 8   | `nb_ingest_acto_rma`                               | Assistência Social  | Gold   | `gold_rma_cras_*` (4 tabelas)                                                             | overwrite       | Não                 |
| 9   | `nb_ingest_acto_rma_creas`                         | Assistência Social  | Gold   | `gold_rma_creas_indicadores`                                                              | overwrite       | Não                 |
| 10  | `nb_ingest_osasco_bolsa_trabalho`                  | Bolsa Trabalho      | Silver | `silver_bolsa_trabalho`                                                                   | overwrite       | Não                 |
| 11  | `nb_gold_bolsa_trabalho`                           | Bolsa Trabalho      | Gold   | `gold_bolsa_trabalho`                                                                     | overwrite       | Não                 |
| 12  | `nb_ingest_osasco_bpc`                             | BPC                 | Silver | Parquet particionado `Files/silver_bpc/`                                                  | parquet         | Não (Silver)        |
| 13  | `nb_gold_osasco_bpc`                               | BPC                 | Gold   | **escrita comentada**                                                                     | —               | **SIM — CRÍTICO**   |
| 14  | `nb_append_caged`                                  | CAGED               | Silver | `silver_caged`                                                                            | append          | Não                 |
| 15  | `nb_gold_sql_caged`                                | CAGED               | Gold   | 5 tabelas `gold_caged_*`                                                                  | overwrite       | Não                 |
| 16  | `nb_ingest_caged_dump`                             | CAGED               | Bronze | `dump_caged`                                                                              | overwrite       | Não                 |
| 17  | `nb_ingest_carta_servicos_osasco`                  | Carta Serviços      | Gold   | `gold_carta_servicos`, `gold_carta_servicos_atualizacoes`                                 | overwrite       | Não                 |
| 18  | `nb_ingest_acto_gestao_tempo_etapa_carta_servicos` | Carta Serviços      | Gold   | `gold_carta_servicos_tempo_etapa`                                                         | overwrite       | Não                 |
| 19  | `nb_ingest_censo`                                  | Censo / Demografico | Gold   | **10 arquivos CSV** `Files/gold_censo_demografico/`                                       | CSV             | **SIM**             |
| 20  | `nb_ingest_populacao_sidra`                        | Censo / Demografico | Gold   | `gold_osasco_populacao_ibge`                                                              | overwrite       | Não                 |
| 21  | `nb_ingest_pib_sidra`                              | Censo / Demografico | Gold   | `gold_osasco_pib_per_capita`, `gold_osasco_pib_categoria`, `gold_osasco_participacao_pib` | overwrite       | Não                 |
| 22  | `nb_gold_populacao_densidade`                      | Censo / Demografico | Gold   | **1 arquivo CSV** `Files/gold_populacao_densidade/`                                       | CSV             | **SIM**             |
| 23  | `nb_ingest_osasco_comexstat`                       | Comex               | Gold   | `gold_osasco_comexstat`                                                                   | overwrite       | Não                 |
| 24  | `nb_ingest_grid_obras`                             | Obras               | Gold   | `gold_alvaras_obras`                                                                      | overwrite       | Não                 |
| 25  | `nb_ingest_rais_bd`                                | RAIS                | Raw    | `raw_rais_estab_sp` (dump BigQuery)                                                       | overwrite       | Não                 |
| 26  | `nb_append_rais_ftp`                               | RAIS                | Raw    | `raw_rais_estab_sp` (FTP 2024)                                                            | overwrite       | Não                 |
| 27  | `nb_gold_rais`                                     | RAIS                | Gold   | **2 arquivos CSV** `Files/gold_rais/`                                                     | CSV             | **SIM**             |
| 28  | `nb_ingest_infosiga_seg_viaria`                    | Segurança Viária    | Silver | `silver_infosiga_pessoas`, `silver_infosiga_sinistros`, `silver_infosiga_veiculos`        | overwrite       | Não                 |
| 29  | `nb_gold_seguranca_viaria`                         | Segurança Viária    | Gold   | 4 tabelas Delta + 3 Parquet (duplicação)                                                  | overwrite       | Remover Parquet     |
| 30  | `nb_ingest_monitora_oz`                            | Segurança Pública   | Gold   | `gold_monitora_oz`                                                                        | overwrite       | Não                 |
| 31  | `nb_gold_osasco_seguranca_publica`                 | Segurança Pública   | Gold   | 4 tabelas `gold_seg_publica_*`                                                            | overwrite       | Não                 |

**Total: 31 notebooks**

---

## Domínio 1 — Assistência Social

### Inventário

| #   | Notebook                     | Subdomínio    | Saída                                                   | Modo            |
| --- | ---------------------------- | ------------- | ------------------------------------------------------- | --------------- |
| 1   | `nb_ingest_atendimento_cras` | CRAS / Acto   | `gold_atendimento_cras`, `gold_atendimento_cras_etapas` | overwrite       |
| 2   | `nb_append_pbf`              | Bolsa Família | `silver_pbf_sp`                                         | append          |
| 3   | `nb_gold_pbf`                | Bolsa Família | `gold_pbf_municipios_selecionados`                      | overwrite (SQL) |
| 4   | `nb_ingest_dump_pbf`         | Bolsa Família | `dump_pbf_sp`                                           | overwrite       |
| 5   | `nb_ingest_bronze_cad_unico` | CadÚnico      | `bronze_cad_unico_reg01…reg18` (12 tabelas)             | append          |
| 6   | `nb_silver_cad_unico`        | CadÚnico      | `silver_cad_unico_reg01`, `reg04`                       | overwrite       |
| 7   | `nb_gold_cad_unico_pg`       | CadÚnico      | `gold_cad_unico_*` (12 tabelas)                         | overwrite       |
| 8   | `nb_ingest_acto_rma`         | RMA / CRAS    | `gold_rma_cras_*` (4 tabelas)                           | overwrite       |
| 9   | `nb_ingest_acto_rma_creas`   | RMA / CREAS   | `gold_rma_creas_indicadores`                            | overwrite       |

---

### `nb_ingest_atendimento_cras`
**Caminho:** `nbs/assistencia_social/atendimento_cras/`
**Dependências:** `%run ./nb_utils_request_api`, `%run ./config_api_acto`

**Fonte de dados:** API Acto Gestão via payload JSON
- Arquivo: `Files/payloads/payload_osasco_atendimento_cras.json`
- Token: `TOKEN_OSASCO`

**Processamento:**
- `extrair_tabela_acto_gestao()`: extrai solicitações e etapas
- `tratar_solicitacoes()`: converte datas ISO8601, calcula `tempo_atendimento_minutos`, combina colunas de assunto/demanda
- `tratar_etapas()`: converte datas, renomeia colunas, calcula durações (dias/horas/minutos/segundos)

**Saída:**
| Tabela | Descrição |
|---|---|
| `gold_atendimento_cras` | Solicitações com tempo de atendimento e demanda combinada |
| `gold_atendimento_cras_etapas` | Etapas com durações calculadas |

**Modo:** overwrite com `overwriteSchema=true`

---

### `nb_append_pbf`
**Caminho:** `nbs/assistencia_social/bolsa_familia/`

**Fonte de dados:** Portal da Transparência
- URL: `https://portaldatransparencia.gov.br/download-de-dados/novo-bolsa-familia/{ANO_MES}`
- Parâmetros `ANO` e `MES` configurados no topo do notebook

**Processamento:**
- Download streaming ZIP, extração, remoção do ZIP
- Leitura CSV com schema fixo (encoding `latin1`, sep `;`)
- Filtra `UF == "SP"`, normaliza colunas snake_case
- Converte `valor_parcela` (vírgula → ponto, cast double)
- Formata datas `mes_referencia` e `mes_competencia`

**Saída:**
| Tabela | Descrição |
|---|---|
| `lh_cidade_inteligente_osasco.silver_pbf_sp` | PBF SP, granularidade por NIS favorecido |

**Modo:** append (acumulativo mensal)

> **Atenção:** Execução manual mês a mês. Sem controle de duplicidade — reprocessar o mesmo mês gera duplicatas.

---

### `nb_gold_pbf`
**Caminho:** `nbs/assistencia_social/bolsa_familia/`
**Dependência:** `silver_pbf_sp`

**Processamento (SQL puro):** Agrega silver por `mes_referencia` e `nome_municipio` para 6 municípios comparativos: Osasco, São Bernardo do Campo, Sorocaba, Ribeirão Preto, Santo André, São José dos Campos.

**Saída:**
| Tabela | Colunas |
|---|---|
| `gold_pbf_municipios_selecionados` | `mes_referencia`, `nome_municipio`, `total_repasses`, `n_favorecidos`, `media_repasses` |

**Modo:** `CREATE OR REPLACE TABLE` (equivale a overwrite)

---

### `nb_ingest_dump_pbf`
**Caminho:** `nbs/assistencia_social/bolsa_familia/`

**Fonte de dados:** `Files/raw_bolsa_familia/tb_pbf_sp.csv` (encoding `latin1`, sep `;`)

**Saída:**
| Tabela | Descrição |
|---|---|
| `dump_pbf_sp` | Dump histórico PBF SP (base para carga inicial) |

**Modo:** overwrite

---

### `nb_ingest_bronze_cad_unico`
**Caminho:** `nbs/assistencia_social/cad_unico/`

**Fonte de dados:** TXT de largura fixa CadÚnico
- Arquivo: `Files/bronze_cad_unico/raw_cad_unico_marco26.TXT`
- Encoding: `cp850`, `VERSAO = "2026-03-01"` (hardcoded)

**Processamento:**
- Lê o TXT linha a linha, separa em 12 blocos por código de registro (01–18)
- Cada bloco lido com `pd.read_fwf()` usando `colspecs` do layout Access
- Adiciona `versao_arquivo` a todos os DataFrames, converte para `StringType`

**Saída (12 tabelas Bronze):**
| Tabela | Bloco | Conteúdo |
|---|---|---|
| `bronze_cad_unico_reg01` | 01 | Família: endereço, renda, status cadastral |
| `bronze_cad_unico_reg02` | 02 | Domicílio: cômodos, água, saneamento |
| `bronze_cad_unico_reg03` | 03 | Família: qtd pessoas, despesas, CRAS |
| `bronze_cad_unico_reg04` | 04 | Membros: nome, NIS, sexo, nascimento, parentesco |
| `bronze_cad_unico_reg05` | 05 | Documentos dos membros |
| `bronze_cad_unico_reg06` | 06 | Deficiências dos membros |
| `bronze_cad_unico_reg07` | 07 | Escolaridade dos membros |
| `bronze_cad_unico_reg09` | 09 | Contatos da família |
| `bronze_cad_unico_reg14` | 14 | Pendências/auditoria |
| `bronze_cad_unico_reg16` | 16 | Transferências de família |
| `bronze_cad_unico_reg17` | 17 | Transferências de membros |
| `bronze_cad_unico_reg18` | 18 | Exclusões |

**Modo:** append (mantém histórico por `versao_arquivo`)

---

### `nb_silver_cad_unico`
**Caminho:** `nbs/assistencia_social/cad_unico/`
**Dependência:** `bronze_cad_unico_reg01`, `bronze_cad_unico_reg04`

**Processamento:**
- Aplica dicionários código → descrição (status cadastral, parentesco)
- `construir_transicoes_spark()`: detecta transições de status via Window com `lag()` — Primeira aparição, Saída informal, Exclusão (3→4), Reativação (4→3), Sem mudança
- Cria chave composta `chave_familia_versao`

**Saída:**
| Tabela | Conteúdo |
|---|---|
| `silver_cad_unico_reg01` | Famílias com status e tipo de transição mensal |
| `silver_cad_unico_reg04` | Membros com status e tipo de transição mensal |

**Modo:** overwrite

---

### `nb_gold_cad_unico_pg`
**Caminho:** `nbs/assistencia_social/cad_unico/`
**Dependência:** `bronze_cad_unico_reg01` a `reg07`

**Processamento:**
- `consolidar_registros()`: JOIN inner reg01 + reg02 + reg03 + reg04 + reg07
- `aplicar_dicionarios()`: traduz códigos numéricos (sexo, parentesco, água, saneamento, escolaridade)
- `tratar_datas()`: converte `dat_cadastramento_fam` (formato `ddMMyyyy`)
- `tratar_exportacao_pruc()`: filtra ativos (status ≠ 4), calcula renda per capita
- JOIN com `Files/cadastro_unico/cep_bairros.csv` para bairro

**Saída (12 tabelas Gold):**
| Tabela | Conteúdo |
|---|---|
| `gold_cad_unico_cod_familiar_fam` | IDs únicos de famílias |
| `gold_cad_unico_cod_familiar_fam_2025` | Famílias cadastradas em 2026 |
| `gold_cad_unico_renda_per_capita_fam` | Renda per capita por família |
| `gold_cad_unico_n_pessoas_fam` | Tamanho das famílias |
| `gold_cad_unico_agua_canalizada_fam` | Acesso à água canalizada |
| `gold_cad_unico_qtd_comodos_domic_fam` | Quantidade de cômodos |
| `gold_cad_unico_sabe_ler_escrever_memb` | Alfabetização dos membros |
| `gold_cad_unico_sexo_pessoa` | Distribuição por sexo |
| `gold_cad_unico_forma_coleta` | Coleta com/sem visita domiciliar por ano |
| `gold_cad_unico_parentesco` | Distribuição de parentesco |
| `gold_cad_unico_indicadores_bairros` | Indicadores socioeconômicos por bairro |
| `gold_cad_unico_escoa_sanitario_fam` | Tipo de esgotamento sanitário |

**Modo:** overwrite com `overwriteSchema=true`

> **Arquivo auxiliar crítico (R1):** `Files/cadastro_unico/cep_bairros.csv` — join CEP → bairro. Quebra silenciosa se movido.

---

### `nb_ingest_acto_rma` (CRAS)
**Caminho:** `nbs/assistencia_social/rma/`

**Fonte de dados:**
- CSV atual: `Files/raw_sas_rma/bd_rma.csv` (utf-8-sig, sep `;`)
- Histórico parquets: `rma_cras_{ano}_carga_indicadores.parquet` (2016–2024, 9 arquivos)
- Histórico raça: `Files/raw_sas_rma/estrutura_bloco_e.xlsx`

**Processamento:**
- `tratar_rmas()`: padroniza nomes dos 10 CRAS via `MAP_SIGLA_UNIDADE`
- Gera 4 bases analíticas no formato longo (melt): indicadores, raça/cor, identidade de gênero, bairros
- Consolida histórico 2016–2026, normaliza rótulos entre versões via `CONSOLIDACAO_INDICADORES`

**Saída:**
| Tabela | Conteúdo | Registros |
|---|---|---|
| `gold_rma_cras_indicadores` | ~80 indicadores × CRAS × mês (2016–2026) | 55.218 |
| `gold_rma_cras_raca_cor` | Raça/cor do RF por CRAS e sexo | — |
| `gold_rma_cras_id_genero` | Identidade de gênero por CRAS | — |
| `gold_rma_cras_bairros` | Contagem por bairro × CRAS | 8.580 |

**Modo:** overwrite

---

### `nb_ingest_acto_rma_creas` (CREAS)
**Caminho:** `nbs/assistencia_social/rma/`

**Fonte de dados:** `Files/raw_sas_rma/bd_rma_creas.csv` (utf-8-sig, sep `;`)

**Processamento:** Análogo ao CRAS. CREAS Norte e Sul. Seções: PAEFI (acompanhamento), MSE (medidas socioeducativas), tipos de violência, abordagem social.

**Saída:**
| Tabela | Conteúdo | Registros |
|---|---|---|
| `gold_rma_creas_indicadores` | ~80 indicadores × CREAS × mês | 1.183 |

**Nota:** Tabelas de raça, identidade de gênero e bairros do CREAS estão **comentadas** no código (aguardando decisão de escopo).

**Modo:** overwrite

---

## Domínio 2 — Bolsa Trabalho

### Inventário

| # | Notebook | Saída | Modo |
|---|---|---|---|
| 10 | `nb_ingest_osasco_bolsa_trabalho` | `silver_bolsa_trabalho` | overwrite |
| 11 | `nb_gold_bolsa_trabalho` | `gold_bolsa_trabalho` | overwrite |

---

### `nb_ingest_osasco_bolsa_trabalho`
**Caminho:** `nbs/bolsa_trabalho/`
**Dependência:** `%run ./config_api_acto`

**Fonte de dados:** API Acto Gestão
- Endpoint: `POST /api/Tabela/VisualizarDadosIntermediarios`
- `codCatalogos: [13256]`
- Etapas selecionadas: `[41434, 41433, 41438]`
- Token: `TOKEN_OSASCO`

**Processamento:**
- Filtra status != "Cancelado"
- Ajusta nomes de colunas (snake_case, sem acentos)
- Resultado: ~70 linhas × 87 campos

**Campos-chave:** CPF, NIS, código familiar CadÚnico, curso pretendido, status do interessado, renda total família, condição de trabalho, identidade de gênero, raça/cor

**Saída:**
| Tabela | Descrição |
|---|---|
| `silver_bolsa_trabalho` | Solicitantes do Bolsa Trabalho com dados socioeconômicos |

**Modo:** overwrite

---

### `nb_gold_bolsa_trabalho`
**Caminho:** `nbs/bolsa_trabalho/`
**Dependência:** `silver_bolsa_trabalho`

**Processamento:**
- Limpeza de renda: vírgula → ponto, remove separador de milhar via regex, cast double, `floor()`
- Cria `faixa_renda` (8 categorias): "Sem informação" / "Até R$ 500" / "De R$ 500 a R$ 1.000" / … / "Acima de R$ 5.000"

**Saída:**
| Tabela | Descrição |
|---|---|
| `gold_bolsa_trabalho` | Solicitantes com faixa de renda calculada |

**Modo:** overwrite com `overwriteSchema=true`

> **Observação:** `df_gold_base` com colunas selecionadas é construído no código mas **não é escrito** — a tabela Gold é o DataFrame completo (`df_gold_bolsa_trabalho`).

---

## Domínio 3 — BPC

### Inventário

| # | Notebook | Saída | Modo |
|---|---|---|---|
| 12 | `nb_ingest_osasco_bpc` | Parquet `Files/silver_bpc/` | parquet particionado |
| 13 | `nb_gold_osasco_bpc` | **escrita comentada** | — |

---

### `nb_ingest_osasco_bpc`
**Caminho:** `nbs/bpc/`

**Fonte de dados:** Portal da Transparência
- URL: `https://portaldatransparencia.gov.br/download-de-dados/bpc/{ano_mes}`
- Cobertura: 2019-01 até mês atual - 1 (85 períodos)

**Processamento:**
- Incremental: lê `Files/metadata/bpc/controle_carga.csv` e pula períodos já carregados
- Schema fixo `SCHEMA_BPC` (14 colunas, tipo string)
- Adiciona `ano_referencia` e `mes_referencia` como colunas de partição
- Hash de validação por arquivo

**Saída:**
| Caminho | Descrição |
|---|---|
| `Files/silver_bpc/ano=YYYY/mes=MM/data.parquet` | Silver BPC particionado por ano e mês |

> **Nota:** Esta camada é Silver (Parquet), não Delta table. A migração para Delta é oportunidade futura.

---

### `nb_gold_osasco_bpc`
**Caminho:** `nbs/bpc/`
**Dependência:** `Files/silver_bpc/` (leitura parquet)

**Processamento:**
- Lê 439.573.542 registros totais do parquet Silver
- Cria `df_gold` com `codigo_municipio_siafi` (cast bigint) e `valor_parcela_numerico` (vírgula → ponto, cast double)

**Saída:** ⚠️ **ESCRITA COMPLETAMENTE COMENTADA NO CÓDIGO**

```python
# df_clean.write.format("delta").mode("overwrite")...
```

> **CRÍTICO — Migração obrigatória:** Este é o caso "bagunçado" mencionado pelo líder. A tabela Gold de BPC **não existe**. Descomentar e ajustar o bloco de escrita para `saveAsTable("gold_bpc_osasco")`.

---

## Domínio 4 — CAGED

### Inventário

| # | Notebook | Saída | Modo |
|---|---|---|---|
| 14 | `nb_append_caged` | `silver_caged` | append |
| 15 | `nb_gold_sql_caged` | 5 tabelas `gold_caged_*` | overwrite |
| 16 | `nb_ingest_caged_dump` | `dump_caged` | overwrite |

---

### `nb_append_caged`
**Caminho:** `nbs/caged/`

**Fonte de dados:** FTP MTE
- Host: `ftp.mtps.gov.br/pdet/microdados/NOVO CAGED/{ANO}/{ANO_MES}/`
- Arquivos: `CAGEDMOV`, `CAGEDEXC`, `CAGEDFOR` (formato 7z, extração via `py7zr`)
- `CODIGO_OSASCO = 353440` (filtro municipio)

**Processamento:**
- Descomprime cada arquivo 7z, lê CSV, filtra por `CODIGO_OSASCO`
- JOIN com descrição CNAE (path ABFSS, lakehouse `66918002-484f-4823-bb7f-0e4131dcbd26`)
- JOIN com CBO 2002
- JOIN com layout Excel de-para para normalização de colunas
- Cast para `LongType`

**Saída:**
| Tabela | Descrição |
|---|---|
| `silver_caged` | MOV + EXC + FOR consolidados, filtrado Osasco |

**Modo:** append

---

### `nb_gold_sql_caged`
**Caminho:** `nbs/caged/`
**Dependência:** `silver_caged`

**Processamento (SQL puro):** 5 agregações Gold:

**Saída:**
| Tabela | Conteúdo |
|---|---|
| `gold_caged_saldo_movimentacao_anual` | Saldo + salário médio por ano/mês/seção CNAE |
| `gold_caged_saldo_secao` | Saldo + salário total por seção CNAE |
| `gold_caged_media_idade` | Média de idade por variável (Admissões/Demissões) × CNAE |
| `gold_caged_media_salario` | Salário médio por variável × CNAE |
| `gold_caged_saldo_idade` | Saldo por faixa etária (17 faixas: 0–5 até 80+) |

**Modo:** overwrite

---

### `nb_ingest_caged_dump`
**Caminho:** `nbs/caged/`

**Fonte de dados:** `Files/caged_02042025.csv` (ABFSS path, encoding `latin1`, sep `;`)

**Saída:**
| Tabela | Descrição |
|---|---|
| `dump_caged` | Dump histórico CAGED (base para carga inicial) |

**Modo:** overwrite Delta

---

## Domínio 5 — Carta de Serviços

### Inventário

| # | Notebook | Saída | Modo |
|---|---|---|---|
| 17 | `nb_ingest_carta_servicos_osasco` | `gold_carta_servicos`, `gold_carta_servicos_atualizacoes` | overwrite |
| 18 | `nb_ingest_acto_gestao_tempo_etapa_carta_servicos` | `gold_carta_servicos_tempo_etapa` | overwrite |

---

### `nb_ingest_carta_servicos_osasco`
**Caminho:** `nbs/carta_servicos/`

**Fonte de dados:** 2 CSVs
- `Files/raw_cadastro_carta/grid_cadastro_carta.csv` (em andamento / em atendimento)
- `Files/raw_cadastro_carta/bd_entidade_cadastro_carta.csv` (finalizados)
- Encoding: `utf-8-sig`, sep `;`

**Processamento:**
- `carregar_tratar_bd()`: renomeia, adiciona `servico = "Cadastro de carta de serviço"` e `status_tramitacao = "Finalizado"`
- `carregar_tratar_grid()`: filtra status Em atendimento / Pendente, remove colunas internas
- `gerar_bd_final()`: concat grid + bd, calcula `data_consolidada`, `dias_desde_atualizacao`, `periodo_atualizacao` (6 faixas), `sigla_area_responsavel`
- `gerar_grid_final()`: grid completo para tabela de atualizações

**Saída:**
| Tabela | Descrição |
|---|---|
| `gold_carta_servicos` | Todas as solicitações (finalizadas + em andamento) |
| `gold_carta_servicos_atualizacoes` | Somente OS em aberto com detalhes de executor/etapa |

**Modo:** overwrite (tabela de atualizações só criada se houver OS em aberto)

---

### `nb_ingest_acto_gestao_tempo_etapa_carta_servicos`
**Caminho:** `nbs/carta_servicos/`
**Dependência:** `%run ./config_api_acto`

**Fonte de dados:** API Acto Gestão
- Endpoint: `POST /api/RelatoriosEtapa/ObterTempoEtapaRelatorio`
- `codCatalogos: [6903]`
- Período: 2024-01-01 a 2026-03-25
- Token: `TOKEN_OSASCO`

**Processamento:**
- Remove colunas `notifications`, `isValid`, `codEtapa`
- Converte colunas de data via `pd.to_datetime(format="ISO8601")`

**Saída:**
| Tabela | Descrição |
|---|---|
| `gold_carta_servicos_tempo_etapa` | Tempo gasto por etapa, catálogo 6903 |

**Modo:** overwrite

---

## Domínio 6 — Censo / Demográfico

### Inventário

| # | Notebook | Saída | Modo | Migração |
|---|---|---|---|---|
| 19 | `nb_ingest_censo` | 10 CSV `Files/gold_censo_demografico/` | CSV | **SIM** |
| 20 | `nb_ingest_populacao_sidra` | `gold_osasco_populacao_ibge` | overwrite | Não |
| 21 | `nb_ingest_pib_sidra` | 3 tabelas `gold_osasco_pib_*` | overwrite | Não |
| 22 | `nb_gold_populacao_densidade` | 1 CSV `Files/gold_populacao_densidade/` | CSV | **SIM** |

---

### `nb_ingest_censo`
**Caminho:** `nbs/censo/`

**Fonte de dados:** IBGE SIDRA API (chamadas JSON diretas) + `ipeadatapy`

**Municípios cobertos:** Osasco, São Bernardo do Campo, Sorocaba, Ribeirão Preto, Santo André, São José dos Campos (6 municípios comparativos)

**Processamento — 10 extrações:**
1. Pirâmide etária (Censo 2010 + 2022)
2. Urbana/rural (histórico)
3. Índice de envelhecimento
4. Razão de dependência demográfica
5. Distribuição por gênero
6. Frequência escolar
7. Domicílios particulares
8. Renda domiciliar (2010 + 2022)
9. Taxa de fecundidade
10. Domicílios por cor/raça do responsável

**Saída atual (MIGRAÇÃO NECESSÁRIA):**
| Arquivo CSV | Conteúdo |
|---|---|
| `Files/gold_censo_demografico/piramide_etaria.csv` | Distribuição por faixa etária e sexo |
| `Files/gold_censo_demografico/urbana_rural.csv` | Pop. urbana vs. rural histórico |
| `Files/gold_censo_demografico/envelhecimento.csv` | Índice de envelhecimento |
| `Files/gold_censo_demografico/dependencia.csv` | Razão de dependência |
| `Files/gold_censo_demografico/genero.csv` | Distribuição por gênero |
| `Files/gold_censo_demografico/escola.csv` | Frequência escolar |
| `Files/gold_censo_demografico/domicilios.csv` | Domicílios particulares |
| `Files/gold_censo_demografico/renda.csv` | Renda domiciliar |
| `Files/gold_censo_demografico/fecundidade.csv` | Taxa de fecundidade |
| `Files/gold_censo_demografico/domicilios_raca.csv` | Domicílios por raça/cor |

> **Migração:** Substituir todos os `to_csv()` por `spark.createDataFrame(df).write.mode("overwrite").format("delta").saveAsTable("gold_censo_{nome}")`.

---

### `nb_ingest_populacao_sidra`
**Caminho:** `nbs/censo/`

**Fonte de dados:** `sidrapy` (biblioteca)
- Tabela SIDRA 6579: estimativas populacionais 2000–2024
- Tabela SIDRA 793: contagens de 2007
- Tabela SIDRA 608: Censo 2010
- 6 municípios comparativos

**Saída:**
| Tabela | Descrição |
|---|---|
| `gold_osasco_populacao_ibge` | Série histórica de população IBGE por município e ano |

**Modo:** overwrite

---

### `nb_ingest_pib_sidra`
**Caminho:** `nbs/censo/`

**Fonte de dados:** `sidrapy`
- Tabela SIDRA 5938: PIB municipal
- Tabela SIDRA 1737: IPCA (deflator, base 2023)
- Usa `gold_osasco_populacao_ibge` para cálculo per capita

**Processamento:** Deflaciona valores para base 2023, calcula PIB per capita, agrupa por categoria (Total, Impostos, Agropecuária, Indústria, Serviços, Administração)

**Saída:**
| Tabela | Descrição |
|---|---|
| `gold_osasco_pib_per_capita` | PIB per capita deflacionado por município e ano |
| `gold_osasco_pib_categoria` | PIB por categoria IBGE por município e ano |
| `gold_osasco_participacao_pib` | Participação percentual no PIB estadual/nacional |

**Modo:** overwrite

---

### `nb_gold_populacao_densidade`
**Caminho:** `nbs/censo/`

**Fonte de dados:** `ipeadatapy`
- Série `POPTOT`: população total
- Série `AREA`: área territorial km²
- 6 municípios, histórico desde 1970

**Processamento:** `densidade = populacao / area_km2`

**Saída atual (MIGRAÇÃO NECESSÁRIA):**
| Arquivo CSV | Conteúdo |
|---|---|
| `Files/gold_populacao_densidade/densidade_pop_munic_selecionados.csv` | Densidade demográfica histórica por município |

> **Migração:** Substituir `to_csv()` por `saveAsTable("gold_populacao_densidade")`.

---

## Domínio 7 — Comércio Exterior (Comex)

### Inventário

| # | Notebook | Saída | Modo |
|---|---|---|---|
| 23 | `nb_ingest_osasco_comexstat` | `gold_osasco_comexstat` | overwrite |

---

### `nb_ingest_osasco_comexstat`
**Caminho:** `nbs/comex/`

**Fonte de dados:**
- `Files/raw_comexstat/comexstat_municipios_1997_2026.parquet`
- `Files/raw_comexstat/NCM_SH.csv` (encoding `latin1`, sep `;`)

**Processamento:**
- Cast `VL_FOB` → int64, `SH4` → str, `CO_ANO` → int32
- Filtra `CO_MUN == 3434401` (Osasco)
- JOIN com `NCM_SH.csv` em `SH4` para obter descrições `NO_SH4_POR`, `NO_SH2_POR`, `NO_SEC_POR`

**Saída:**
| Tabela | Colunas-chave |
|---|---|
| `gold_osasco_comexstat` | `co_ano`, `co_mes`, `sh4`, `co_mun`, `vl_fob`, `tipo`, `no_sh4_por`, `no_sh2_por`, `no_sec_por` |

**Modo:** overwrite

---

## Domínio 8 — Obras

### Inventário

| # | Notebook | Saída | Modo |
|---|---|---|---|
| 24 | `nb_ingest_grid_obras` | `gold_alvaras_obras` | overwrite |

---

### `nb_ingest_grid_obras`
**Caminho:** `nbs/obras/`

**Fonte de dados:**
- `Files/obras/os_servicos_obras.csv` (sep `;`)
- `Files/obras/tb_aux_etapas_consideradas.xlsx`

**Processamento:**
- Outer join OS grid × etapas consideradas (chave: `servico` + `etapa_atual`)
- `status_alvara = "expedido"` se na interseção, `"em_tramite"` se só no grid
- Filtra 25 tipos de serviço: Alvará de Construção, Demolição, Reforma, Regularização, Terraplenagem, Habite-se, Certidões, etc.
- Remove colunas 100% nulas

**Estatística do processo (snapshot Abril 2026):**

| Serviço | Em tramite | Expedido | % Expedido |
|---|---|---|---|
| Alvará de Regularização | 1.211 | 110 | 8,3% |
| Certidão de Uso do Solo | 1.119 | 453 | 28,8% |
| Alvará de Construção | 710 | 56 | 7,3% |

**Saída:**
| Tabela | Descrição |
|---|---|
| `gold_alvaras_obras` | Alvarás e certidões com status expedido/em_tramite |

**Modo:** overwrite — última data de solicitação: 2026-04-19

---

## Domínio 9 — RAIS

### Inventário

| # | Notebook | Saída | Modo | Migração |
|---|---|---|---|---|
| 25 | `nb_ingest_rais_bd` | `raw_rais_estab_sp` (BigQuery dump) | overwrite | Não |
| 26 | `nb_append_rais_ftp` | `raw_rais_estab_sp` (FTP 2024 consolidado) | overwrite | Não |
| 27 | `nb_gold_rais` | 2 CSV `Files/gold_rais/` | CSV | **SIM** |

---

### `nb_ingest_rais_bd`
**Caminho:** `nbs/rais/`

**Fonte de dados:** Google BigQuery — Base dos Dados
- Tabela: `basedosdados.br_me_rais.microdados_estabelecimentos`
- Credencial: `Files/bd2024-444413-1084f2b9d765.json` (R1 — arquivo único de credencial)
- Filtro: `sigla_uf = 'SP'`, `ano >= 1993`
- Lib: `google-cloud-bigquery`, `pyarrow`, `db-dtypes`

**Processamento:**
- Agrega por ano/uf/municipio/tamanho_estabelecimento/cnae_1/cnae_2/cnae_2_subclasse
- Métricas: `quantidade_vinculos_ativos`, `quantidade_vinculos_clt`, `quantidade_vinculos_estatutarios`

**Saída:**
| Tabela | Descrição |
|---|---|
| `raw_rais_estab_sp` | Série histórica RAIS SP 1993+ (base completa BigQuery) |

**Modo:** overwrite (`CREATE OR REPLACE TABLE`)

---

### `nb_append_rais_ftp`
**Caminho:** `nbs/rais/`

**Fonte de dados:** FTP MTE
- Host: `ftp.mtps.gov.br/pdet/microdados/RAIS/2024/`
- Arquivo: `RAIS_ESTAB_PUB.7z` → `RAIS_ESTAB_PUB.COMT` (CSV, encoding `latin1`)
- Lib: `py7zr`

**Processamento:**
- `download_rais_data()`: acessa FTP, baixa e extrai o .7z (comentado — execução manual)
- Filtra `uf_codigo == 35` (SP), adiciona `sigla_uf = 'SP'`, `ano = 2024`
- Renomeia colunas para padrão, agrega por municipio/tamanho/cnae
- Consolida com dump existente `raw_rais_estab_sp` via `pd.concat`

**Saída:**
| Tabela | Descrição |
|---|---|
| `raw_rais_estab_sp` | Dump histórico + FTP 2024 consolidados |

**Modo:** overwrite (substitui a tabela inteira)

---

### `nb_gold_rais`
**Caminho:** `nbs/rais/`
**Dependência:** `lh_cidade_inteligente_osasco.raw_rais_estab_sp`

**Processamento:**
- Filtra Osasco (`id_municipio IN ('3534401', '353440')`)
- JOIN com `Files/aux_tables/br_bd_diretorios_brasil_cnae_1.csv` (descrição seção CNAE 1)
- JOIN com `Files/aux_tables/br_bd_diretorios_brasil_cnae_2.csv` (descrição seção CNAE 2)
- `descricao_secao_cnae`: prioriza CNAE 2, fallback para CNAE 1
- Agrega por `ano × descricao_secao_cnae` → `rais_anual`
- Mapeamento `tamanho_estabelecimento`: 1→"ZERO" até 10→"1000 OU MAIS", -1→"IGNORADO"
- Agrega por `ano × tamanho × descricao_secao_cnae` → `rais_tamanho_estabelecimento`

**Saída atual (MIGRAÇÃO NECESSÁRIA):**
| Arquivo CSV | Conteúdo |
|---|---|
| `Files/gold_rais/rais_anual.csv` | Vínculos ativos por ano e seção CNAE |
| `Files/gold_rais/gold_rais_tamanho_estabelecimento.csv` | Vínculos ativos por ano, tamanho de estabelecimento e CNAE |

> **Nota:** Execução anterior teve `IsADirectoryError` por conflito de nome de pasta — já corrigido na versão atual (path `Files/gold_rais/`).

> **Migração:** Substituir os dois `to_csv()` por `saveAsTable("gold_rais_anual")` e `saveAsTable("gold_rais_tamanho_estabelecimento")`.

**Snapshot 2024 (vínculos ativos por seção):**

| Seção CNAE | Vínculos |
|---|---|
| Comércio; reparação de veículos | 49.556 |
| Transporte, armazenagem e correio | 37.614 |
| Atividades administrativas | 22.038 |
| Administração pública | 18.805 |
| Indústrias de transformação | 16.978 |

---

## Domínio 10 — Segurança Viária

### Inventário

| # | Notebook | Saída | Modo | Observação |
|---|---|---|---|---|
| 28 | `nb_ingest_infosiga_seg_viaria` | 3 tabelas Silver | overwrite | Também salva Parquet intermediário |
| 29 | `nb_gold_seguranca_viaria` | 4 tabelas Gold + 3 Parquet | overwrite | Parquet é redundante |

---

### `nb_ingest_infosiga_seg_viaria`
**Caminho:** `nbs/seguraca_viaria/` *(atenção: typo no nome da pasta — "seguraca" sem "n")*

**Fonte de dados:** DETRAN SP INFOSIGA
- URL: `https://infosiga.detran.sp.gov.br/rest/painel/download/file/dados_infosiga.zip`
- Conteúdo: CSVs separados por período (2015–2021 e 2022–2026), 3 grupos: sinistros, pessoas, veículos
- Encoding: `latin1`, sep `;`

**Processamento:**
- Download via `requests`, extração via `zipfile`
- Concatenação dos dois períodos para cada grupo
- Salva Parquet intermediário em `Files/silver_seguranca_viaria/dados_infosiga/`

**Saída:**
| Tabela | Descrição |
|---|---|
| `silver_infosiga_sinistros` | Sinistros 2015–2026 (todo SP) |
| `silver_infosiga_pessoas` | Vítimas por sinistro 2015–2026 |
| `silver_infosiga_veiculos` | Veículos envolvidos 2015–2026 |

**Modo:** overwrite

---

### `nb_gold_seguranca_viaria`
**Caminho:** `nbs/seguraca_viaria/`
**Dependência:** `silver_infosiga_sinistros`, `silver_infosiga_pessoas`

**Processamento:**
- Filtra `municipio.str.contains("OSASCO")`
- Converte datas para datetime
- Cria `ano_mes_sinistro` como `pd.to_datetime(format="%Y/%m")`
- Define categorias ordenadas para `dia_da_semana` e `turno`
- Filtra a partir de 2019

**Saída (Delta + Parquet duplicado):**
| Tabela Delta | Arquivo Parquet | Conteúdo |
|---|---|---|
| `gold_infosiga_sinistros_tipo_via` | `gold_infosiga_sinistros_tipo_via.parquet` | Sinistros por ano/mês × tipo de via |
| `gold_infosiga_sinistros_tipo_registro` | `gold_infosiga_sinistros_tipo_registro.parquet` | Sinistros por ano/mês × tipo de registro |
| `gold_infosiga_sinistros_dia_semana_turno` | `gold_infosiga_sinistros_dia_semana_turno.parquet` | Sinistros por ano × dia semana × turno |
| `gold_infosiga_pessoas_oz` | `gold_infosiga_pessoas_oz.parquet` | Vítimas Osasco com tipo veículo, faixa etária, sexo, gravidade |

**Modo:** overwrite

> **Atenção:** O notebook salva **tanto** Parquet quanto Delta table para os mesmos dados. Os arquivos Parquet em `Files/gold_seguranca_viaria/` são redundantes — podem ser removidos para simplificar.

---

## Domínio 11 — Segurança Pública

### Inventário

| # | Notebook | Saída | Modo |
|---|---|---|---|
| 30 | `nb_ingest_monitora_oz` | `gold_monitora_oz` | overwrite |
| 31 | `nb_gold_osasco_seguranca_publica` | 4 tabelas `gold_seg_publica_*` | overwrite |

---

### `nb_ingest_monitora_oz`
**Caminho:** `nbs/seguranca_publica/`
**Dependência:** `%run ./config_api_acto`

**Fonte de dados:** API Acto Gestão
- Endpoint: `POST /api/Tabela/VisualizarDadosIntermediarios`
- `codCatalogos: [13366, 13254]`
  - 13366: Credenciamento compartilhamento câmeras particulares — etapa 40898
  - 13254: Credenciamento instalação de totem de videomonitoramento — etapa 40440
- Token: `TOKEN_OSASCO` + `APP_ID_OSASCO`

**Processamento:**
- `buscar_tabela()`: POST com configuração JSON completa dos campos, expande `dados` aninhados em lista flat
- Consolida colunas duplicadas de dois catálogos (bairro, CEP, CNPJ, CPF, nome fantasia, nome) via `bfill(axis=1)`
- Renomeia colunas (`seqFluxo → os`, `dataSolicitacao → data_solicitacao`, etc.)
- Converte datas ISO8601

**Saída:**
| Tabela | Descrição |
|---|---|
| `gold_monitora_oz` | Credenciamentos Programa Monitora OZ (câmeras + totens) |

**Campos disponíveis:** OS, serviço, status, data_solicitacao, data_finalizacao, bairro, CEP, CNPJ, nome fantasia, nome interessado

**Modo:** overwrite

---

### `nb_gold_osasco_seguranca_publica`
**Caminho:** `nbs/seguranca_publica/`

**Fonte de dados:** CSVs Silver em `Files/silver_seguranca_publica/`
- `silver_tb_entorpecentes.csv` + `silver_tb_apreensao_entorpecentes.csv`
- `silver_tb_armas_apreendidas.csv`
- `silver_tb_prisoes.csv`
- `silver_tb_dados_criminais.csv`
- Encoding: padrão (múltiplos tipos mistos — DtypeWarning esperado)

**Processamento por tabela:**
- **Entorpecentes:** filtra Osasco, JOIN com apreensões, converte gramas → kg, agrega por ano/mês/tipo de local/tipo de droga
- **Armas:** filtra Osasco, agrega por ano/mês/município/tipo de arma
- **Prisões:** filtra Osasco, agrega por ano/mês/tipo de local (combina coluna `MÊS ESTATISTICA` com `MES_ESTATISTICA` via bfill)
- **Dados criminais:** filtra `nome_municipio_circunscricao == 'OSASCO'`, agrega por ano/mês/bairro/natureza apurada

**Saída:**
| Tabela | Conteúdo |
|---|---|
| `gold_seg_publica_entorpecentes` | Apreensões por ano/mês/tipo de local/droga (kg + BOs) |
| `gold_seg_publica_armas` | Armas apreendidas por ano/mês/tipo |
| `gold_seg_publica_prisoes` | Prisões por ano/mês/tipo de local |
| `gold_seg_publica_dados_criminais` | Ocorrências por ano/mês/bairro/natureza |

**Modo:** overwrite com `overwriteSchema=true`

---

## Dependências e Arquivos Auxiliares — Mapa Completo

| Arquivo / Recurso                                     | Usado em                                                                                                                  | Risco                                   |
| ----------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------- | --------------------------------------- |
| `Files/payloads/payload_osasco_atendimento_cras.json` | `nb_ingest_atendimento_cras`                                                                                              | R1 — path hardcoded                     |
| `Files/raw_bolsa_familia/tb_pbf_sp.csv`               | `nb_ingest_dump_pbf`                                                                                                      | R1 — arquivo único histórico            |
| `Files/bronze_cad_unico/raw_cad_unico_marco26.TXT`    | `nb_ingest_bronze_cad_unico`                                                                                              | R1 — nome de arquivo hardcoded          |
| `Files/cadastro_unico/cep_bairros.csv`                | `nb_gold_cad_unico_pg`                                                                                                    | R1 — join CEP/bairro, quebra silenciosa |
| `Files/raw_sas_rma/bd_rma.csv`                        | `nb_ingest_acto_rma`                                                                                                      | R1 — substituído mensalmente            |
| `Files/raw_sas_rma/bd_rma_creas.csv`                  | `nb_ingest_acto_rma_creas`                                                                                                | R1 — substituído mensalmente            |
| `Files/raw_sas_rma/estrutura_bloco_e.xlsx`            | `nb_ingest_acto_rma`                                                                                                      | R1 — histórico raça CRAS                |
| `Files/metadata/bpc/controle_carga.csv`               | `nb_ingest_osasco_bpc`                                                                                                    | R1 — controle incremental               |
| `Files/obras/tb_aux_etapas_consideradas.xlsx`         | `nb_ingest_grid_obras`                                                                                                    | R1 — lista de etapas consideradas       |
| `Files/raw_comexstat/NCM_SH.csv`                      | `nb_ingest_osasco_comexstat`                                                                                              | R1 — descrição SH4                      |
| `Files/aux_tables/br_bd_diretorios_brasil_cnae_1.csv` | `nb_gold_rais`                                                                                                            | R1 — descrição seção CNAE 1             |
| `Files/aux_tables/br_bd_diretorios_brasil_cnae_2.csv` | `nb_gold_rais`                                                                                                            | R1 — descrição seção CNAE 2             |
| `Files/bd2024-444413-1084f2b9d765.json`               | `nb_ingest_rais_bd`                                                                                                       | **R1 CRÍTICO** — credencial BigQuery    |
| `Files/silver_seguranca_publica/*.csv`                | `nb_gold_osasco_seguranca_publica`                                                                                        | R1 — 4 CSVs Silver                      |
| FTP `ftp.mtps.gov.br`                                 | `nb_append_caged`, `nb_append_rais_ftp`                                                                                   | Dependência externa                     |
| API Acto Gestão                                       | `nb_ingest_atendimento_cras`, `nb_ingest_osasco_bolsa_trabalho`, `nb_ingest_carta_servicos_acto`, `nb_ingest_monitora_oz` | Token JWT com expiração                 |
| BigQuery `basedosdados`                               | `nb_ingest_rais_bd`                                                                                                       | Cota + validade de credencial           |
| SIDRA / IBGE                                          | `nb_ingest_populacao_sidra`, `nb_ingest_pib_sidra`, `nb_ingest_censo`                                                     | API pública, sem autenticação           |
| INFOSIGA DETRAN SP                                    | `nb_ingest_infosiga_seg_viaria`                                                                                           | Download público, sem autenticação      |
| Portal Transparência                                  | `nb_append_pbf`, `nb_ingest_osasco_bpc`                                                                                   | Download público                        |

---

## Oportunidades de Migração — Arquivo → Delta Gold

Esta é a principal ação solicitada pelo líder: substituir saídas em arquivo por tabelas Delta Gold.

| Prioridade | Notebook                      | Estado atual                                 | Ação                                                                                                              |
| ---------- | ----------------------------- | -------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- |
| 🔴 CRÍTICO | `nb_gold_osasco_bpc`          | Escrita Delta **comentada**                  | Descomentar e ajustar `saveAsTable("gold_bpc_osasco")`                                                            |
| 🟠 ALTA    | `nb_ingest_censo`             | 10 CSVs em `Files/gold_censo_demografico/`   | Substituir 10 `to_csv()` por `saveAsTable()` com nomes `gold_censo_{tema}`                                        |
| 🟠 ALTA    | `nb_gold_rais`                | 2 CSVs em `Files/gold_rais/`                 | Substituir 2 `to_csv()` por `saveAsTable("gold_rais_anual")` e `saveAsTable("gold_rais_tamanho_estabelecimento")` |
| 🟡 MÉDIA   | `nb_gold_populacao_densidade` | 1 CSV em `Files/gold_populacao_densidade/`   | Substituir `to_csv()` por `saveAsTable("gold_populacao_densidade")`                                               |
| 🟡 MÉDIA   | `nb_gold_seguranca_viaria`    | Escreve Delta + Parquet para os mesmos dados | Remover os 3 `to_parquet()` redundantes                                                                           |
| 🟢 BAIXA   | `nb_append_pbf`               | Silver SP (não filtrado Osasco)              | Criar Gold separado: `WHERE nome_municipio = 'OSASCO'`                                                            |
| 🟢 BAIXA   | `nb_ingest_rma_creas`         | Tabelas raça/bairros comentadas              | Descomentar se escopo do Dash CREAS for confirmado                                                                |

---

## Fluxo de Dados — Visão Completa Osasco

```
╔══════════════════════════════════════════════════════════════════════╗
║                    FONTES EXTERNAS                                   ║
╠══════════════════════════════════════════════════════════════════════╣
║ API Acto Gestão  │ FTP MTE     │ Portal Transp.  │ IBGE/SIDRA       ║
║ BigQuery BD      │ INFOSIGA    │ CadÚnico TXT    │ DETRAN SP        ║
╚══════════════════════════════════════════════════════════════════════╝
                                │
          ┌─────────────────────┼──────────────────────┐
          ▼                     ▼                      ▼
┌──────────────────┐  ┌──────────────────┐  ┌──────────────────────┐
│  Bronze / Raw    │  │     Silver       │  │   Gold (direto)      │
├──────────────────┤  ├──────────────────┤  ├──────────────────────┤
│ bronze_cad_unico │  │ silver_pbf_sp    │  │ gold_atendimento_cras│
│ raw_rais_estab_sp│  │ silver_caged     │  │ gold_carta_servicos  │
│ dump_caged       │  │ silver_cad_unico │  │ gold_monitora_oz     │
│ dump_pbf_sp      │  │ silver_infosiga  │  │ gold_rma_cras_*      │
│                  │  │ (Files/*.csv)    │  │ gold_rma_creas_*     │
└────────┬─────────┘  └────────┬─────────┘  └──────────────────────┘
         │                     │
         ▼                     ▼
┌────────────────────────────────────────────────────────────────────┐
│                        GOLD (derivado)                             │
├────────────────────────────────────────────────────────────────────┤
│ gold_pbf_municipios_selecionados   gold_caged_*  (5 tabelas)       │
│ gold_cad_unico_*   (12 tabelas)    gold_osasco_pib_*  (3 tabelas)  │
│ gold_bolsa_trabalho                gold_osasco_comexstat            │
│ gold_alvaras_obras                 gold_infosiga_*  (4 tabelas)    │
│ gold_seg_publica_*  (4 tabelas)    gold_osasco_populacao_ibge       │
│ gold_carta_servicos_tempo_etapa                                     │
│                                                                    │
│ ⚠️ Ainda em arquivo (migrar → Delta):                              │
│  gold_bpc_osasco [comentado]    gold_rais_anual [CSV]              │
│  gold_censo_*  (10 CSVs)        gold_populacao_densidade [CSV]     │
└────────────────────────────────────────────────────────────────────┘
                              │
                              ▼
                     Power BI / Dash Python
                         (Jorge)
```
