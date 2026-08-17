---
title: Inventário Bronze — Estrutura EAV e Volumes
tags: ["tipo/inventario", "ferramenta/fabric", "camada/bronze", "padrao/eav"]
aliases: ["inventario bronze", "eav bronze"]
description: "Volumes e campos EAV verificados via SQL endpoint — verificar_bronze_acto.ipynb"
status: "ativo"
atualizado: "2026-06-09"
---
# Inventário Bronze — Estrutura EAV e Volumes

> **Lakehouse:** `lh_solicitacoes_acto`
> **Verificado em:** 09/06/2026 via `verificar_bronze_acto.ipynb` (SQL endpoint ODBC)
> **Fontes ativas:** 16 (9 Santos + 3 Osasco + 4 Mauá)
> **Tabelas Bronze:** 48 (16 fontes × 3: `fato_solicitacoes`, `fato_campos`, `fato_etapas`)

[[Documentação_Fabric/Acto/SCHEMA_LAKEHOUSE_ACTO|Schema Lakehouse Acto]] | [[Documentação_Fabric/Acto/DOCUMENTACAO_TECNICA_ACTO|Doc Técnica]] | [[Documentação_Fabric/Mauá/00_INDEX_MAUA|Mauá Index]]

---

## 1. Volumes por Fonte

| Fonte | Município | fato_solicitacoes | fato_campos (EAV) | fato_etapas |
| --- | --- | ---: | ---: | ---: |
| santos_avaliacao | Santos | 24.535 | 195.474 | 50.804 |
| santos_obras | Santos | 12.065 | 56.429 | 94.615 |
| santos_cet | Santos | 11.516 | 81.364 | 55.942 |
| santos_sepref | Santos | 9.051 | 37.986 | 43.400 |
| santos_cet_carga_descarga | Santos | 5.584 | 90.864 | 22.508 |
| **maua_meio_ambiente** | **Mauá** | **3.887** | **19.766** | **25.460** |
| santos_seinfra | Santos | 2.461 | 26.624 | 13.836 |
| **maua_meio_ambiente_regiao** | **Mauá** | **1.946** | **2.149** | **11.319** |
| santos_segov | Santos | 1.043 | 7.233 | 3.532 |
| santos_ouvidoria_manifestacao | Santos | 962 | 4.734 | 4.796 |
| osasco_atendimento_trabalhador | Osasco | 760 | 15.619 | 2.234 |
| **maua_meio_ambiente_cnae** | **Mauá** | **703** | **78** | **6.471** |
| osasco_atendimento_cras | Osasco | 320 | 6.008 | 943 |
| **maua_meio_ambiente_arvores** | **Mauá** | **204** | **78** | **2.407** |
| santos_curso_motorista | Santos | 156 | 1.080 | 1.154 |
| osasco_monitora_oz_gestao | Osasco | 127 | 1.016 | 680 |
| **TOTAL** | — | **75.320** | **548.422** | **339.865** |

---

## 2. Qualidade — NULLs em Colunas Obrigatórias

> Colunas verificadas: `id_os` · `servico` · `status_fluxo` · `data_criacao` · `data_finalizacao` · `solicitante`

| Fonte | Status | Observação |
| --- | --- | --- |
| Todos os Mauá (4 fontes) | ✅ 0% NULLs | Ingestão limpa |
| Todos os Osasco (3 fontes) | ✅ 0% NULLs | — |
| Santos (exceto obras e cet) | ✅ 0% NULLs | — |
| santos_cet | ⚠️ `solicitante`: 6.1% NULL | Registros históricos sem solicitante |
| santos_obras | ⚠️ `data_criacao`: 44.6% · `solicitante`: 79.4% NULL | API obras retorna estrutura diferente — resolvido via candidatos alternativos |

---

## 3. Range de Datas

| Fonte | data_finalizacao (min) | data_finalizacao (max) |
| --- | --- | --- |
| maua_meio_ambiente | 03/2024 | 06/2026 |
| maua_meio_ambiente_regiao | 03/2024 | 06/2026 |
| maua_meio_ambiente_cnae | 08/2024 | 06/2026 |
| maua_meio_ambiente_arvores | 04/2025 | 06/2026 |
| santos_obras | 08/2023 | 06/2026 |
| santos_cet | 07/2025 (criação) | 06/2026 |

> `data_criacao` (abertura) aparece NULL em muitas fontes no bronze — o campo vem de `dataSolicitacao` (tit "Data Criação") que é o campo correto. A `data_finalizacao` tem melhor cobertura pois vem de `dataCriacao` (tit "Data Finalização" — nome contra-intuitivo da API).

---

## 4. Campos EAV por Fonte (Mauá Meio Ambiente)

### maua_meio_ambiente — 19.766 registros EAV

| Campo EAV | Ocorrências |
| --- | ---: |
| bairro_localizacoes_identificadas | ~1.706 |
| numero_localizacoes_identificadas | ~1.705 |
| logradouro_localizacoes_identificadas | ~1.705 |
| geolocalizacoes_identificadas | ~1.704 |
| cpf | ~1.347 |
| nome_do_solicitante | ~1.305 |
| esta_solicitacao_devera_ser_analisada_por | ~1.260 |
| selecione_a_regiao_de_planejamento | ~1.075 |
| nova_identificacao_de_nrco_queda_de_galhos | ~682 |
| validacao_tecnica | ~551 |
| validacao_cadastro_social | ~494 |
| quantidade_atual_lim | ~402 |
| nome_cientifico | ~401 |
| classificacao | ~400 |

### maua_meio_ambiente_cnae — 78 registros EAV

| Campo EAV | Ocorrências |
| --- | ---: |
| codigo_cnae | ~45 |
| informe_a_atividade_secundaria_ambientalmente_licenciavel_sub_industrial | ~20 |

> Volume baixo esperado — licenças ambientais com CNAE são serviços específicos (703 solicitações no total).

### maua_meio_ambiente_arvores — 78 registros EAV

| Campo EAV | Ocorrências |
| --- | ---: |
| o_transplante_o_corte_de_arvores_isoladas_inc_do_macico_florestal | ~40 |
| supressaotransplante_de_arvores_sub | ~37 |

> Campo TCA (`identificacao_do_termo_de_compromisso_ambiental_tca`) não apareceu no top — baixa cobertura (TCA emitido em casos específicos). Confirmar na Gold.

### maua_meio_ambiente_regiao — 2.149 registros EAV

| Campo EAV | Ocorrências |
| --- | ---: |
| selecione_a_regiao_de_planejamento | ~1.075 |
| bairro_localizacoes_identificacoes | ~1.074 |

---

## 5. Complexidade de Fluxo — Etapas Distintas

| Fonte | Total Etapas | OSs Únicas | Etapas Distintas |
| --- | ---: | ---: | ---: |
| santos_obras | 94.615 | 12.064 | **212** |
| **maua_meio_ambiente** | **25.460** | **3.841** | **114** |
| santos_cet | 55.942 | 11.516 | 30 |
| santos_sepref | 43.400 | 8.904 | 22 |
| **maua_meio_ambiente_cnae** | **6.471** | **655** | **61** |
| **maua_meio_ambiente_arvores** | **2.407** | **206** | **61** |
| osasco_monitora_oz_gestao | 680 | 127 | 14 |
| santos_seinfra | 13.836 | 2.461 | 10 |
| santos_avaliacao | 50.804 | 24.535 | 2 |

> Mauá Meio Ambiente tem 114 etapas distintas — 2ª maior complexidade do pipeline, atrás apenas de Santos Obras (212). Relevante para o relatório R1 (SLA por etapa).

---

## 6. Serviços — Mauá Meio Ambiente

### maua_meio_ambiente (3.887 solicitações)

| Serviço | Qtd |
| --- | ---: |
| PODA OU REMOÇÃO DE ÁRVORES EM CALÇADAS E OUTRAS ÁREAS | 1.946 |
| VIVEIRO - CONTROLE DE ESPÉCIES | 403 |
| LICENÇA AMBIENTAL (LP, LI E LO) | 266 |
| LICENÇA AMBIENTAL (LP, LI E LO) - RENOVAÇÃO | 262 |
| AUTORIZAÇÃO AMBIENTAL (SUPRESSÃO / INTERVENÇÃO APP) | 204 |
| MANIFESTAÇÃO TÉCNICA | 200 |
| INFORMAÇÃO TÉCNICA | 160 |
| CONTROLE DE DOCUMENTOS - LICENÇAS E AUTORIZAÇÕES | 150 |
| LICENÇA SIMPLIFICADA | 97 |
| VIVEIRO - CADASTRO DE ESPÉCIES | 89 |
| LICENÇA SIMPLIFICADA - RENOVAÇÃO | 53 |
| CERTIFICADO DE DISPENSA DE LICENCIAMENTO | 22 |
| COMUNICAÇÃO DE SUSPENSÃO OU ENCERRAMENTO | 5 |
| EXAME TÉCNICO | 4 |
| CONTROLE DE ESTOQUE INTERNO (HOMOLOGAÇÃO) | 1 |

### maua_meio_ambiente_cnae (703 solicitações)
Somente licenças ambientais com CNAE: LP/LI/LO (266), LP/LI/LO Renovação (262), Simplificada (97), Simplificada Renovação (53), Renovação LP/LI/LO (25).

### maua_meio_ambiente_arvores (204 solicitações)
Exclusivamente: AUTORIZAÇÃO AMBIENTAL (SUPRESSÃO DE VEGETAÇÃO / INTERVENÇÃO EM APP) — 204.

### maua_meio_ambiente_regiao (1.946 solicitações)
Exclusivamente: PODA OU REMOÇÃO DE ÁRVORES EM CALÇADAS E OUTRAS ÁREAS — 1.946.

---

## 7. Padrão de Payload — 6 Colunas Obrigatórias

> Regra estabelecida em 09/06/2026. Todo payload deve incluir as 6 entradas em cada `servicos` de cada catálogo. O Bronze seleciona essas colunas de forma estrita — ausência causa `KeyError`.

| `col` (enviado no payload) | `tit` (nome retornado pela API) | Coluna no Bronze | Papel |
| --- | --- | --- | --- |
| `seqFluxo` | `Nº Solicitação` | `n_solicitacao` → `id_os` | Chave primária |
| `servico` | `Serviço` | `servico` | Nome do serviço |
| `statusFluxo` | `Status Fluxo` | `status_fluxo` | Status atual |
| `dataCriacao` | `Data Finalização` | `data_finalizacao` | Data encerramento |
| `dataSolicitacao` | `Data Criação` | `data_criacao` | Data abertura |
| `solicitante` | `Solicitante` | `solicitante` | Nome do solicitante |

> **Regra crítica:** a API usa o campo `tit` como chave na resposta JSON, não o `col`.
> **Atenção:** `dataCriacao` (col) tem tit `"Data Finalização"` — é a data de encerramento, não de criação. `dataSolicitacao` tem tit `"Data Criação"` — é a abertura.

---

## 8. Fluxo EAV — Arquitetura do Processo

```
Payload JSON (Files/payloads/)
    └─ servicos[]: define colunas · tit é o nome retornado pela API
         ↓
API Acto — VisualizarDadosIntermediarios
    └─ retorna linhas com chaves = tit de cada servico
         ↓
nb_utils_request_api
    ├─ consolidar_colunas_duplicadas() — coalesce multi-catálogo
    ├─ clean_col_name()                — snake_case, sem acentos, strip |N
    └─ fetch_dados_etapa()             — SLA endpoint separado
         ↓
bronze.fato_solicitacoes_{fonte}   ← 6 colunas padrão + metadados (12 colunas)
bronze.fato_campos_{fonte}         ← EAV: id_os · campo · valor + metadados (10 colunas)
bronze.fato_etapas_{fonte}         ← SLA por etapa (16 colunas)
         ↓ nb_silver_acto_gestao
silver.fato_solicitacoes/campos/etapas   ← UNION BY NAME allowMissingColumns=True
         ↓ nb_gold_{municipio}_{dominio}
gold.{tabela}                            ← pivot EAV → colunas (lista CAMPOS no notebook)
```

### Checklist — Adicionar nova fonte

- [ ] Criar payload JSON com 6 colunas padrão + campos específicos
- [ ] Adicionar entrada em `fontes[]` no `nb_bronze_orquestracao`
- [ ] Adicionar `id_fonte` em `FONTES[]` no `nb_silver_acto_gestao`
- [ ] Criar `nb_gold_{municipio}_{dominio}` com `CAMPOS = [campos EAV desejados]` — **usar `lower(col)`, não `clean_col_name(tit)`** (ver §9)
- [ ] Confirmar os nomes reais de `CAMPOS` via SQL antes de finalizar o Gold (ver §9) — não assumir pelo `tit`
- [ ] Adicionar `%run` no `_nb_gold_orquestracao`
- [ ] Rodar pipeline e validar com `verificar_bronze_acto.ipynb`

---

## 9. Correção ao padrão da §7 — nome do `campo` em `fato_campos` para fontes EAV

> Descoberto em 14/07/2026 ao adicionar a fonte `osasco_visita_domiciliar` — quebrou a primeira tentativa do Gold (28/28 campos "ausentes").

A §7 documenta que a API do Acto usa o `tit` como chave da resposta JSON (`clean_col_name(tit)` vira o nome da coluna). **Isso vale apenas para os 6 campos padrão** (`seqFluxo`, `servico`, `statusFluxo`, `dataCriacao`, `dataSolicitacao`, `solicitante` — sem `codEtapa`/`codFormularioCampo`).

**Para campos de formulário/EAV (com `codFormularioCampo` preenchido no payload), a API retorna a linha chaveada pelo `col` do payload, em minúsculo — não pelo `tit` limpo.**

Exemplo real (`payload_osasco_visita_domiciliar.json`):
```json
{"col": "TXT_CPF_INTERESSADO", "tit": "CPF interessado", "codFormularioCampo": 944099, "etapa": "ABERTURA"}
```
→ em `silver.fato_campos`, o `campo` vem como `txt_cpf_interessado` (= `col` minúsculo), **não** `cpf_interessado` (que seria `clean_col_name(tit)`).

**Regra prática:** ao montar `CAMPOS` de um novo `nb_gold_{municipio}_{dominio}`, usar `lower(col)` para todo campo com `codFormularioCampo` preenchido. Antes de finalizar a lista, sempre confirmar os nomes reais rodando:

```sql
SELECT campo, COUNT(*) AS n FROM silver.fato_campos
WHERE fonte = '<id_fonte>' GROUP BY campo ORDER BY n DESC
```

Detalhe completo do caso que originou esse achado: `Documentação_Fabric/specs/spec_painel_osasco_visita_domiciliar.md`.
