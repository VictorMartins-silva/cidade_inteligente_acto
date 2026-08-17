# 🏛️ Osasco — Documentação & Pipelines

## 📍 Status

- **Ambiente:** Produção
- **Projeto:** Ozmundi (integração dados públicos + geo)
- **Últimas atualizações:** Mapeamento PBI (2026), Análise geolocalização
- **Responsáveis:** Equipe Eicon | Projeto Ozmundi

## 🏗️ Domínios Cobertos

| Domínio | Status | Descrição |
|---------|--------|-----------|
| **Assistência Social** | ✅ | CRAS, Bolsa Família, CAD Único, RMA |
| **Bolsa Trabalho** | ✅ | Ingestão e Gold |
| **BPC** | ✅ | Benefício de Prestação Continuada |
| **CAGED** | 🔴 CRÍTICO | Hardcoded com código OSASCO (R9) |
| **Carta de Serviços** | ✅ | SCD Type 2 com prazos SLA |
| **Censo** | ✅ | Dados demográficos (RAIS) |
| **Comex** | ✅ | Comércio Exterior |
| **Obras** | ✅ | Obras Públicas (integração Acto) |
| **RAIS** | ✅ | Cadastro de Empregados |
| **Segurança Viária** | ✅ | Análise acidentes, infrações |
| **Segurança Pública** | ⚠️ | SSP dados criminais (geo/incompatibilidades) |

## 📚 Estrutura de Arquivos

### Assistência Social
| Domínio | Arquivo | Camada | Descrição |
|---------|---------|--------|-----------|
| **CRAS** | `assistencia_social/atendimento_cras/nb_ingest_atendimento_cras.ipynb` | Ingest | Ingestão atendimentos CRAS |
| **Bolsa Família** | `assistencia_social/bolsa_familia/nb_ingest_dump_pbf.ipynb` | Ingest | Dump PBF |
| **Bolsa Família** | `assistencia_social/bolsa_familia/nb_append_pbf.ipynb` | Ingest | Append incremental |
| **Bolsa Família** | `assistencia_social/bolsa_familia/nb_gold_pbf.ipynb` | Gold | Gold PBF |
| **CAD Único** | `assistencia_social/cad_unico/nb_ingest_bronze_cad_unico.ipynb` | Bronze | Ingestão CAD Único |
| **CAD Único** | `assistencia_social/cad_unico/nb_silver_cad_unico.ipynb` | Silver | Limpeza CAD Único |
| **CAD Único** | `assistencia_social/cad_unico/nb_gold_cad_unico_pg.ipynb` | Gold | Gold CAD Único (PG) |
| **RMA** | `assistencia_social/rma/nb_ingest_acto_rma.ipynb` | Ingest | RMA (Registro de Monitoramento) |
| **RMA** | `assistencia_social/rma/nb_ingest_acto_rma_creas.ipynb` | Ingest | RMA CREAS |

### Bolsa Trabalho
| Arquivo | Camada | Descrição |
|---------|--------|-----------|
| `bolsa_trabalho/nb_ingest_osasco_bolsa_trabalho.ipynb` | Ingest | Ingestão Bolsa Trabalho |
| `bolsa_trabalho/nb_gold_bolsa_trabalho.ipynb` | Gold | Gold Bolsa Trabalho |

### BPC (Benefício de Prestação Continuada)
| Arquivo | Camada | Descrição |
|---------|--------|-----------|
| `bpc/nb_ingest_osasco_bpc.ipynb` | Ingest | Ingestão BPC |
| `bpc/nb_gold_osasco_bpc.ipynb` | Gold | Gold BPC |

### CAGED (Cadastro Geral de Empregados)
| Arquivo | Camada | Descrição |
|---------|--------|-----------|
| `caged/nb_ingest_caged_dump.ipynb` | Ingest | Dump CAGED |
| `caged/nb_append_caged.ipynb` | Ingest | Append incremental CAGED |
| `caged/nb_gold_sql_caged.ipynb` | Gold | Gold CAGED (SQL) |

### Carta de Serviços
| Arquivo | Camada | Descrição |
|---------|--------|-----------|
| `carta_servicos/...` | Bronze/Silver/Gold | SCD Type 2 com prazos SLA |

### Análise Demográfica (Censo & RAIS)
| Arquivo | Camada | Descrição |
|---------|--------|-----------|
| `censo/...` | - | Dados demográficos |
| `rais/...` | - | RAIS empregabilidade |

### Comércio & Integração
| Arquivo | Camada | Descrição |
|---------|--------|-----------|
| `comex/...` | - | Comércio Exterior |
| `obras/...` | - | Obras Públicas (integração Acto) |

### Segurança
| Arquivo | Camada | Descrição |
|---------|--------|-----------|
| `seguranca_viaria/...` | - | Acidentes, infrações |
| `seguranca_publica/...` | - | SSP dados criminais |

## 🔴 Riscos & Problemas Conhecidos

### CRÍTICO
- **R9 — CAGED com código OSASCO hardcoded:** `nb_ingest_caged_santos` tem `CODIGO_OSASCO = 353440` em vez de `CODIGO_SANTOS = 353845`  
  - ⚠️ NÃO ATIVAR este notebook até corrigir  
  - Fix: Parametrizar código municipal ou usar mapeamento dinâmico
  - Ver: [CLAUDE.md → R9](../CLAUDE.md#known-active-issues-do-not-ignore)

### Alto Risco
- **R1 — Arquivos auxiliares (SPOF):** Mudança de caminho quebra silenciosamente:
  - `Files/acto/tb_aux.xlsx` → usado em `nb_ingest_acto_santos`, `nb_utils_api_acto_gestao`
  - `raw_cadastro_carta/*.csv` → usado em `nb_ingest_carta_servicos_santos`
  - Solução planejada: migrar para Delta Tables no Lakehouse

- **Segurança Pública — Geo/Incompatibilidades:** Análise pendente de inconsistências entre SSP dados criminais e camada geo  
  - Ver: [analise_incompatibilidade_ssp_criminais_geo_bi_seguranca.md](./analise_incompatibilidade_ssp_criminais_geo_bi_seguranca.md)

- **R2 — Funções duplicadas:** `ajustar_nome_colunas()`, `harmonizar_nome_bairros()`, `mapa_bairros` em múltiplos notebooks  
  - Solução planejada: criar `nb_utils_shared` e centralizar

### Médio Risco
- **R4 — Sem Rowcount Assertions:** Vários notebooks escrevem sem validar se DataFrame tem dados  
  - Referência correta: `nb_silver_santos_curso_motoristas` usa `assert len(df) > threshold`

## 📊 Painéis Power BI Ativos

- **Segurança Pública** — SSP dados criminais (com análise geo)
- **Segurança Viária** — Acidentes e infrações
- **Assistência Social** — CRAS atendimentos, Bolsa Família, CAD Único
- **Emprego & Renda** — CAGED, RAIS, Bolsa Trabalho
- **Loteamento & Zoneamento** — Geo (com mapas)
- **Carta de Serviços** — Prazos SLA por serviço

## 🔗 Links Rápidos

- **Índice de Notebooks:** [00_INDEX_OSASCO.md](./00_INDEX_OSASCO.md)
- **Mapeamento PBI:** [MAPEAMENTO_PAINEIS_PBI_OSASCO.md](./MAPEAMENTO_PAINEIS_PBI_OSASCO.md)
- **Análise Técnica:** [Mapeamento Técnico de Notebooks — Osasco.md](./Mapeamento%20Técnico%20de%20Notebooks%20—%20Osasco.md)
- **Geo & Mapas:** [guia_pbi_mapas_completo.md](./guia_pbi_mapas_completo.md)
- **Segurança Viária:** [mapas-ssp-osasco.md](./mapas-ssp-osasco.md)
- **Loteamento & Zoneamento:** [mapas_loteamento_zoneamento.md](./mapas_loteamento_zoneamento.md)

## 📖 Ver Também

- [CLAUDE.md](../CLAUDE.md) — Riscos globais, convenções
- [00_MAPA.md](../00_MAPA.md) — Navegação geral Documentação Fabric
- [Santos/README.md](../Santos/README.md) — Documentação Santos
- [Acto/README.md](../Acto/README.md) — Documentação Acto (plataforma central)
