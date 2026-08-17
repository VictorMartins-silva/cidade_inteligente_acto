---
title: Inventário Silver — Estrutura EAV e Volumes
tags: ["tipo/inventario", "ferramenta/fabric", "camada/silver", "padrao/eav"]
aliases: ["inventario silver", "eav silver"]
description: "Volumes e qualidade verificados via SQL endpoint — verificar_silver_acto.ipynb"
status: "ativo"
atualizado: "2026-06-09"
---
# Inventário Silver — Estrutura EAV e Volumes

> **Lakehouse:** `lh_solicitacoes_acto`  
> **Verificado em:** 09/06/2026 via `verificar_silver_acto.ipynb` (SQL endpoint ODBC)  
> **Tabelas Silver:** 3 unificadas (`silver.fato_solicitacoes`, `silver.fato_campos`, `silver.fato_etapas`)  
> **Fontes ativas no Silver:** 16 (15 esperadas + `osasco_monitora_oz_gestao` residual de run anterior)

[[Documentação_Fabric/Acto/EAV_BRONZE_INVENTARIO|Inventário Bronze]] | [[Documentação_Fabric/Acto/DOCUMENTACAO_TECNICA_ACTO|Doc Técnica]] | [[Documentação_Fabric/Mauá/00_INDEX_MAUA|Mauá Index]]

---

## 1. Resultado Bronze × Silver — Validação do UNION

> ✅ **Zero discrepâncias** em todas as 15 fontes × 3 tabelas (45 comparações).  
> O `UNION BY NAME allowMissingColumns=True` do `nb_silver_acto_gestao` transferiu 100% dos dados sem perda.

**Fonte extra detectada:** `osasco_monitora_oz_gestao` aparece no Silver (127 sol / 1.016 campos / 680 etapas) mas não está na lista `FONTES[]` do Silver atual. Trata-se de um resíduo de execução anterior — os dados estão presentes e corretos, mas a fonte não é processada ativamente nas runs recentes.

---

## 2. Volumes por Fonte no Silver

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
| osasco_monitora_oz_gestao *(residual)* | Osasco | 127 | 1.016 | 680 |
| **TOTAL** | — | **79.881** | **548.502** | **340.101** |

> Volumes são idênticos ao Bronze — confirmado pela seção 3 do verificador.

---

## 3. Qualidade — NULLs em Colunas Obrigatórias

> Colunas verificadas: `id_os` · `servico` · `status_fluxo` · `data_criacao` · `data_finalizacao` · `solicitante`

| Fonte | Status | Coluna com NULL | % NULL | Observação |
| --- | --- | --- | ---: | --- |
| Todos os Mauá (4 fontes) | ✅ 0% | — | 0% | Ingestão limpa |
| Todos os Osasco (3 fontes) | ✅ 0% | — | 0% | — |
| Santos (exceto obras e cet) | ✅ 0% | — | 0% | — |
| santos_cet | ⚠️ | `solicitante` | 6,1% | Registros históricos sem solicitante |
| santos_obras | ⚠️ | `data_criacao` | **44,6%** | API obras retorna estrutura diferente — 5.377 OS sem data de abertura |
| santos_obras | ⚠️ | `solicitante` | **79,4%** | Esperado — obras usa outro campo como identificador |

> **Nota:** Os NULLs em `santos_obras` são herança da API de obras (estrutura diferente das demais secretarias). Não é erro de pipeline — é característica da fonte. Confirmado no Bronze também.

---

## 4. Range de Datas — silver.fato_solicitacoes

| Fonte | data_criacao (min) | data_criacao (max) | data_finalizacao (min) | data_finalizacao (max) |
| --- | --- | --- | --- | --- |
| maua_meio_ambiente | 04/03/2024 | 09/06/2026 | 04/03/2024 | 09/06/2026 |
| maua_meio_ambiente_regiao | 04/03/2024 | 08/06/2026 | 04/03/2024 | 09/06/2026 |
| maua_meio_ambiente_cnae | 05/08/2024 | 08/06/2026 | 05/08/2024 | 09/06/2026 |
| maua_meio_ambiente_arvores | 02/04/2025 | 09/06/2026 | 03/04/2025 | 09/06/2026 |
| santos_obras | 31/05/2023 | 09/06/2026 | 14/08/2023 | 09/06/2026 |
| santos_avaliacao | 30/07/2024 | 09/06/2026 | 30/07/2024 | 09/06/2026 |
| santos_cet | 17/07/2025 | 09/06/2026 | 17/07/2025 | 09/06/2026 |
| santos_sepref | 12/09/2024 | 09/06/2026 | 03/10/2024 | 09/06/2026 |
| osasco_atendimento_cras | 09/04/2026 | 09/06/2026 | 13/04/2026 | 09/06/2026 |
| osasco_atendimento_trabalhador | 09/04/2026 | 09/06/2026 | 13/04/2026 | 09/06/2026 |

> Osasco CRAS e SETRE têm histórico curto (início abr/2026) — fontes recentes no pipeline.  
> Santos Obras tem o histórico mais longo: mai/2023 → atual.  
> Mauá Meio Ambiente: histórico desde mar/2024 (~2 anos de dados).

---

## 5. Complexidade de Fluxo — Etapas Distintas

| Fonte | Total Etapas | OSs Únicas | Etapas Distintas | Etapas/OS (média) |
| --- | ---: | ---: | ---: | ---: |
| santos_obras | 94.615 | 12.064 | **212** | 7,8 |
| **maua_meio_ambiente** | **25.460** | **3.841** | **114** | **6,6** |
| santos_cet | 55.942 | 11.516 | 30 | 4,9 |
| santos_sepref | 43.400 | 8.904 | 22 | 4,9 |
| **maua_meio_ambiente_cnae** | **6.471** | **655** | **61** | **9,9** |
| **maua_meio_ambiente_arvores** | **2.407** | **206** | **61** | **11,7** |
| **maua_meio_ambiente_regiao** | **11.319** | **1.946** | **16** | **5,8** |
| santos_seinfra | 13.836 | 2.461 | 10 | 5,6 |
| santos_avaliacao | 50.804 | 24.535 | 2 | 2,1 |

> Destaques Mauá:
> - `maua_meio_ambiente`: 2ª maior complexidade (114 etapas distintas) — só abaixo de obras (212)
> - `maua_meio_ambiente_arvores`: maior média etapas/OS (11,7) — fluxo de autorização ambiental é o mais complexo do pipeline
> - `maua_meio_ambiente_cnae`: 9,9 etapas/OS — licenciamento com CNAE tem fluxo burocrático extenso

---

## 6. Diferença Bronze → Silver — Arquitetura

```
Bronze: 48 tabelas separadas (16 fontes × 3 sufixos)
    bronze.fato_solicitacoes_{fonte}
    bronze.fato_campos_{fonte}
    bronze.fato_etapas_{fonte}

                ↓ nb_silver_acto_gestao
                  UNION BY NAME allowMissingColumns=True
                  + cast timestamps (data_criacao, data_finalizacao, data_carga)

Silver: 3 tabelas unificadas com coluna `fonte`
    silver.fato_solicitacoes  (79.754 linhas — sem osasco_monitora residual)
    silver.fato_campos        (548.422 linhas)
    silver.fato_etapas        (339.421 linhas)
```

**Consequência do `allowMissingColumns=True`:** fontes com campos diferentes (ex: obras tem colunas de OS que CET não tem) ficam com `NULL` nas colunas ausentes. Isso é esperado e tratado no Gold via `_campos_existentes()`.

---

## 7. Fonte Residual — osasco_monitora_oz_gestao

| Tabela | Linhas |
| --- | ---: |
| silver.fato_solicitacoes | 127 |
| silver.fato_campos | 1.016 |
| silver.fato_etapas | 680 |

Esta fonte está no Silver mas **não está na lista `FONTES[]`** do `nb_silver_acto_gestao` atual. Origem: run anterior quando a fonte ainda estava ativa. Os dados são válidos e não interferem nas demais fontes. Decisão: manter (não deletar); se necessário reprocessar, adicionar de volta ao FONTES[].

---

## 8. Gold Mauá — Status Final (09/06/2026)

Silver validado ✅ → Gold executado ✅ → próximo: Power BI.

**Decisão de arquitetura:** 4 tabelas fato consolidadas em 1 (grão = OS). Etapas separadas (grão = etapa).

| Notebook | Tabela Gold | Resultado | Campos |
| --- | --- | ---: | --- |
| `nb_gold_maua_meio_ambiente` | `gold.maua_meio_ambiente` | ✅ **6.740 OS** · 4 fontes | 10 campos pivotados |
| `nb_gold_maua_meio_ambiente_etapas` | `gold.maua_meio_ambiente_etapas` | ✅ **45.657 etapas** | `tempo_execucao_dias`, `is_etapa_interna` |

**Campos presentes em `gold.maua_meio_ambiente`:**
`bairro_localizacao_identificacao` (→ `bairro_consolidado` 47.4%) · `cpf` · `cnpj` · `nome_do_solicitante` · `inscricao_fiscal` · `selecione_a_regiao_de_planejamento` · `codigo_cnae` · `informe_a_atividade_secundaria_ambientalmente_licenciavel_sub_industrial` · `o_transplante_o_corte_de_arvores_isoladas_ou_de_macico_florestal` · `supressaotransplante_de_arvores_sub`

**⚠️ 3 campos com nome divergente** (ausentes na Gold, corrigir após verificar `silver.fato_campos` para fontes cnae/arvores):
- `codigo_cnae_nao_industrial`
- `codigo_cnae_industrial`
- `identificacao_do_termo_de_compromisso_ambiental_tca`

**Próximo:** M17 — padrão analista vs cidadão (`fato_etapas.executor`) → M18 — Power BI 8 páginas.
