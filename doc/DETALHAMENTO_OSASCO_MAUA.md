---
title: Detalhamento Técnico — Osasco e Mauá
date: 2026-05-20
tags:
  - municipio/osasco
  - municipio/maua
  - ferramenta/fabric
  - tipo/referencia
projeto: acto-cidade-inteligente
fonte: documentacao-interna
status: ativo
---
# Detalhamento Técnico — Osasco e Mauá

## 1. Município de Osasco
**Lakehouse:** `lh_cidade_inteligente_osasco`  
**Token:** `TOKEN_OSASCO`

### 1.1 Inventário por Domínio
| Domínio | Notebooks | Status |
|---|---|---|
| Assistência Social (CRAS/CadÚnico) | 9 | ✅ Delta |
| BPC | 2 | 🔴 Pendente Escrita Delta |
| Censo / Demográfico | 4 | 🟠 CSV → Delta |
| RAIS | 3 | 🟠 CSV → Delta |
| Segurança Pública | 2 | ✅ Delta |

### 1.2 Migrações Prioritárias
- **BPC:** Ativar `saveAsTable("gold_bpc_osasco")`.
- **RAIS/Censo:** Converter `to_csv()` para `saveAsTable()`.

## 2. Município de Mauá
**Lakehouse:** `lh_cidade_inteligente_maua`  
**Token:** `TOKEN_MAUA`

### 2.1 Inventário de Notebooks
| Notebook | Domínio | Camada |
|---|---|---|
| `_nb_maua_main_acto` | Geral | Orquestrador |
| `nb_maua_gold_plan_urbano` | Planejamento | Gold |
| `nb_maua_ingest_gold_ambiente` | Meio Ambiente | Gold |

### 2.2 Particularidade Técnica
Usa o utilitário `nb_utils_maua_ingest_acto_gestao` para consolidar o conceito de **Stage Tracking** via função `consolidar_conceito_bfill`.
