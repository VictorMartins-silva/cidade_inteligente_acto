---
title: Process Mining — Projeto Urbanístico · Santos
tags: ["tipo/analise", "municipio/santos", "dominio/obras", "ferramenta/process-mining", "status/concluido"]
municipio: Santos
dominio: Obras
status: concluído
data_conclusao: 2026-05-13
---

# Process Mining — Projeto Urbanístico · Santos

> **Relacionado:** [[Santos/00_INDEX_SANTOS|Índice Santos]] · [[Santos/nbs/obras/nb_ingest_silver_acto_gestao_obras_santos.ipynb|Silver Obras]] · [[doc/fabric_santos_nbs_analise|Análise de Dependências]]
>
> ⚠️ **Nota R5:** O pipeline de obras está parado desde 11/03/2025 (HTTP 401). A análise usa dados até essa data.

---

## Localização dos Arquivos

| Arquivo | Caminho |
|---|---|
| Notebook principal | `c:\Users\victor.silva\Desktop\PROJETOS\Mapeamento_fabric\pm4py\nb_process_mining_obras_santos.ipynb` |
| Relatório HTML cliente | `pm4py\relatorio_process_mining_santos.html` (gerado ao rodar a última célula) |
| Etapas teóricas | `pm4py\intended_stages.csv` (49 etapas do fluxograma oficial) |
| Snapshots standalone | `pm4py\pm4py_snapshot_log.csv`, `_ghost.csv`, `_rework.csv` (gerados ao rodar célula 10) |

---

## Objetivo

Comparar o fluxo **teórico** (fluxograma SEONT + `intended_stages.csv`) com a execução **real** (`gold_obras_tempo_etapa`) para:
- Identificar etapas fantasma (ghost stages — existem no sistema mas nunca executadas)
- Detectar loops de retrabalho por OS
- Mapear o fluxo real com diagramas interativos
- Propor uma reforma estruturada do serviço

---

## Fonte de Dados

```sql
SELECT os, etapa, data_fim_etapa
FROM dbo.gold_obras_tempo_etapa
WHERE servico = 'PROJETO URBANÍSTICO'
```

- **Período:** 2024-01-03 → 2026-05-12
- **Volume:** 5.494 eventos · 239 OS únicas · 47 etapas distintas
- **Conexão:** SQL Endpoint Fabric via `pyodbc` + `ActiveDirectoryInteractive`

---

## Principais Achados

### Ghost Stages — 5 etapas nunca executadas

| Etapa | Status |
|---|---|
| 7 PROJUR - PARECER TÉCNICO | 🚫 Ghost |
| 3 SEOBE - PARECER TÉCNICO | 🚫 Ghost |
| 4 DECONTE - PARECER TÉCNICO | 🚫 Ghost |
| DELIBERAÇÃO SEOBE | 🚫 Ghost |
| DELIBERAÇÃO GABINETE DO PREFEITO | 🚫 Ghost |

### Retrabalho — 9 etapas críticas (≥5% das OS em loop)

| Etapa | % OS em loop | Visitas extras |
|---|---|---|
| DELIBERAÇÃO SEONT | 46,0% | +499 |
| REGISTRO DA PUBLICIDADE DO DIÁRIO OFICIAL | 43,5% | +386 |
| SEONT - PRÉ ANÁLISE TÉCNICA | 41,4% | +412 |
| SEONT - ANÁLISE TÉCNICA - CONFERÊNCIA DOS DADOS | 39,3% | +350 |
| SEONT - ANÁLISE TÉCNICA | 38,1% | +324 |
| COMUNIQUE-SE | 35,6% | +305 |
| SEONT CONFERÊNCIA FINAL - ANÁLISE TÉCNICA | 13,0% | +53 |
| SECATEM - COMUNIQUE-SE | 10,5% | +45 |
| SECATEM - CORREÇÃO | 7,9% | +26 |

> **43,7% de todos os eventos são retrabalho.** O cluster SEONT responde por 68% do total (1.638 visitas extras).

---

## Diagnóstico Raiz

Dois problemas distintos identificados nos dados:

**Problema 1 — Critério de aprovação ausente**
A DELIBERAÇÃO SEONT retorna 4,5 vezes por OS em média. Não é complexidade técnica: é ausência de rubrica compartilhada. Cada analista aprova com padrão diferente.

**Problema 2 — Posição errada das etapas de controle**
COMUNIQUE-SE (35,6%) e PRÉ ANÁLISE TÉCNICA (41,4%) estão posicionados depois que o processo já avançou — detectam problemas tarde e devolvem tudo ao início.

---

## Proposta de Reforma (3 Horizontes)

### H1 — Semanas (sem alterar sistema)
- Excluir 5 etapas fantasma do fluxograma e treinamentos
- Criar rubrica única de aprovação para DELIBERAÇÃO SEONT → meta: de 4,5 para ≤1 retorno
- Reunião de alinhamento SEONT para mapear sobreposição entre as 3 análises técnicas

### H2 — Meses (redesenho do fluxo)
- Antecipar COMUNIQUE-SE como portão de entrada (completude documental antes de qualquer análise)
- Fundir as 3 etapas de análise SEONT em uma única com checklist estruturado
- Investigar upstream do Diário Oficial (campos cadastrais incorretos chegando no final)

### H3 — 6–12 meses (estrutural)
- SLA por etapa com alertas automáticos no Acto
- Painel de monitoramento contínuo via `gold_obras_tempo_etapa`
- Redesenho do modelo de responsabilidade SEONT (designação direta, eliminar redistribuição Z1/Z2/Z3)

### Impacto estimado

| Medida | Visitas extras eliminadas | Esforço |
|---|---|---|
| Rubrica DELIBERAÇÃO SEONT | ~499 | Baixo |
| COMUNIQUE-SE como portão | ~305 | Médio |
| Fusão 3 análises SEONT | ~1.086 | Alto |
| Correção upstream Diário Oficial | ~386 | Médio |
| **Total** | **~2.276 de 2.400** | **95% do retrabalho** |

---

## Estrutura do Notebook

| Célula | Função |
|---|---|
| `4ea359ea` | Imports + config (CONN_STR, SERVICE_NAME) |
| `a2662f92` | `get_schema()` — diagnóstico das colunas |
| `e7186e52` | `load_data()` — extração via SQL Endpoint |
| `23924f7c` | `prepare_log()` — normalização e ordenação |
| `720717de` | `ghost_stage_analysis()` — matching por prefixo para nomes truncados |
| `f4556324` | `rework_analysis()` — detecção de loops por OS |
| `d814670e` | `sankey_chart()` — diagrama de fluxo Sankey |
| `22fcd4fb` | `transition_heatmap()` — matriz de transições |
| `83bb04c3` | `restructuring_report()` — relatório textual |
| `26c9a347` | `process_flow_diagram()` — mapa hierárquico de fluxo |
| `07dc000b` | `stage_volume_chart()` — volume por etapa com retrabalho em vermelho |
| `1cb939d4` | `top_paths_chart()` — top 15 caminhos mais frequentes |
| `46019894` | `rework_loop_diagram()` — bubble chart dos retornos |
| `d8cd0267` | `stage_treemap()` — treemap por fase do processo |
| `095d5213` | `generate_report()` — gera HTML completo para o cliente |
| `a1c71c10` | `save_snapshots()` + `generate_report_standalone()` — versão offline |

---

## Como Gerar o Relatório Offline (sem Fabric)

1. Executar o notebook completo **uma vez** com conexão ao Fabric → célula `a1c71c10` salva os CSVs
2. Nas próximas vezes, descomente `generate_report_standalone()` na última célula e execute apenas ela

---

## Observações Técnicas

- Datas em `gold_obras_tempo_etapa` são **varchar** — usar `pd.to_datetime(..., errors='coerce')` obrigatório
- Bug corrigido em `generate_report`: `{n for e,v in trans.items() if v>=3}` (era `e[1]>=3`, comparava string com int)
- Ghost stage matching usa prefixo para nomes truncados com `...` no CSV
- `intended_stages.csv` tem 49 etapas; 44 ativas, 5 ghost
