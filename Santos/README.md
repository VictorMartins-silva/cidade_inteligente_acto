# 🏛️ Santos — Documentação & Pipelines

## 📍 Status

- **Ambiente:** Produção (Workspace `lh_cidade_inteligente_santos`)
- **Workspace ID:** `96fe5a53-3a22-4443-8d0a-e2f6d61a2690`
- **Últimas atualizações:** Process Mining (2026-05-13), Investigação Bug Obras (2026-07-15)
- **Responsáveis:** Equipe Eicon | Acto Cidade Inteligente

## 🏗️ Domínios Cobertos

| Domínio | Status | Descrição |
|---------|--------|-----------|
| **Avaliação de Serviços** | ⚠️ | Silver + Gold + Sentimento (IA Groq) |
| **Obras Públicas (SEONT)** | 🔴 CRÍTICO | Parado desde 11/03/2025 (HTTP 401) |
| **Carta de Serviços** | ✅ | SCD Type 2 com prazos SLA |
| **Manifestação de Ouvidoria** | ✅ | Ingestão e processamento |
| **CET** | ✅ | Equipamentos de Trânsito |
| **Segurança Governamental** | ✅ | Segov (domínio segurança) |
| **Infraestrutura** | ✅ | Seinfra (domínio infra) |
| **SEPREF** | ✅ | Secretaria de Patrimônio |

## 📚 Estrutura de Arquivos

### Utilidades Base
| Camada | Arquivo | Descrição |
|--------|---------|-----------|
| **Utils** | `nb_ingest_acto_santos.ipynb` | Ingestão principal da API Acto |
| **Utils** | `nb_utils_api_acto_gestao.ipynb` | API client reutilizável (fetch_tabela, adicionar_etapa_atual, harmonizar_nome_bairros, ajustar_nome_colunas) |
| **Utils** | `nb_utils_api_acto_gestao_obras.ipynb` | API client para obras (login dinâmico) — ⚠️ R5 |
| **Dim** | `nb_ingest_dim_date.ipynb` | Dimensão de datas |
| **Aux** | `nb_ingest_tb_aux_servicos.ipynb` | Carga tb_aux.xlsx (SPOF R1) |

### Avaliação de Serviços
| Camada | Arquivo | Descrição |
|--------|---------|-----------|
| **Silver** | `avaliacao_servicos/nb_silver_santos_avaliacao.ipynb` | Limpeza e tipagem |
| **Gold** | `avaliacao_servicos/nb_gold_santos_avaliacao.ipynb` | Dimensões e fatos (usa `overwrite` — R3) |
| **Gold+IA** | `avaliacao_servicos/nb_gold_santos_avaliacao_sentimento.ipynb` | Análise de sentimento Groq (usa `append` — R3) |

### Obras Públicas
| Camada | Arquivo | Descrição |
|--------|---------|-----------|
| **Silver** | `obras/nb_ingest_silver_acto_gestao_obras_santos.ipynb` | 🔴 Parado desde 11/03/2025 (HTTP 401 — R5) |
| **Gold** | `obras/nb_gold_acto_gestao_obras.ipynb` | Base PDR (usa arquivo PMS_AuxiliarPDR.xlsx — R1) |
| **Gold** | `obras/nb_gold_acto_gestao_obras_etapas.ipynb` | Etapas e timeline |
| **Gold** | `obras/SEONT/nb_gold_acto_gestao_obras_seont_os.ipynb` | Ordens de Serviço SEONT (~202 OS) |

### Carta de Serviços
| Camada | Arquivo | Descrição |
|--------|---------|-----------|
| **Ingest/Bronze** | `carta_servicos/...` | CSV com prazos SLA (669 registros, UTF-8 BOM) |
| **Silver/Gold** | `carta_servicos/...` | SCD Type 2 com vigência temporal |

### Outros Domínios
| Domínio | Pasta |
|---------|-------|
| Manifestação Ouvidoria | `manifestação_ouvidoria/` |
| CET | `cet/` |
| Segov | `segov/` |
| Seinfra | `seinfra/` |
| SEPREF | `sepref/` |

## 🔴 Riscos & Problemas Conhecidos

### CRÍTICO (Parado em produção)
- **R5 — HTTP 401 Obras:** `nb_ingest_silver_acto_gestao_obras_santos` retorna 401 desde **11/03/2025**  
  - Impacto: Gold obras, Gold etapas, SEONT e 4 relatórios PBI parados  
  - Fix: Implementar `try/except HTTPError 401 → login_acto_gestao_obras() → retry` em `nb_utils_api_acto_gestao_obras`  
  - Ver: [CLAUDE.md → R5](../CLAUDE.md#known-active-issues-do-not-ignore)

### Alto Risco
- **R3 — Misalinhamento Avaliação/Sentimento:** Gold avaliação usa `overwrite`, sentimento usa `append`  
  - Se Gold base reescrever e sentimento falhar, IDs ficam desalinhados  
  - Fix: Sincronizar modos de escrita e adicionar transações atômicas

- **R7 — Sem try/except em API:** `nb_utils_ingest_acto_gestao` chama `raise_for_status()` sem tratamento  
  - Falhas se propagam silenciosamente para chains avaliação_servicos e curso_motoristas  
  - Fix: Envolver em `try/except` com logging detalhado

- **R1 — Arquivos auxiliares (SPOF):** Mudança de caminho quebra silenciosamente:
  - `Files/acto/tb_aux.xlsx` (sheets: `aux_prazo`, `aux_regionais`) → usado em `nb_ingest_acto_santos`, `nb_utils_api_acto_gestao`
  - `PMS_AuxiliarPDR.xlsx` → usado em `nb_gold_acto_gestao_obras`
  - `raw_cadastro_carta/*.csv` → usado em `nb_ingest_carta_servicos_santos`
  - Solução planejada: migrar para Delta Tables no Lakehouse

- **R4 — Sem Rowcount Assertions:** Vários notebooks escrevem sem validar se DataFrame tem dados  
  - Referência correta: `nb_silver_santos_curso_motoristas` usa `assert len(df) > threshold`

### Médio Risco
- **R2 — Funções duplicadas:** `ajustar_nome_colunas()`, `harmonizar_nome_bairros()`, `mapa_bairros` em múltiplos notebooks  
  - Solução planejada: criar `nb_utils_shared` e centralizar

- **Formato de Payload:** Dois endpoints retornam formatos diferentes
  - `adicionar_etapa_atual()` espera `'Nº Solicitação|1'`
  - `adicionar_etapa_atual_2()` espera `'Nº Solicitação'`
  - Validar nome de coluna antes de fazer join

## 📊 Painéis Power BI Ativos

- **Avaliação de Serviços** — Análise de satisfação + sentimento (integra Groq)
- **Obras Públicas** (4 relatórios associados) — 🔴 PARADOS  
  - Gold obras, Gold etapas, SEONT, relatórios relacionados
- **Carta de Serviços** — Prazos SLA por bairro e serviço
- **Manifestação Ouvidoria** — Tipo, status, resolução

## 🔗 Links Rápidos

- **Workspace Fabric:** `lh_cidade_inteligente_santos` (ID: `96fe5a53-3a22-4443-8d0a-e2f6d61a2690`)
- **Documentação Técnica:** [GUIA_APLICACAO_FABRIC.md](./GUIA_APLICACAO_FABRIC.md)
- **Índice de Notebooks:** [00_INDEX_SANTOS.md](./00_INDEX_SANTOS.md)
- **Análise Técnica Completa:** [Relatorio_Analise_Fabric_Santos.md](./Relatorio_Analise_Fabric_Santos.md)
- **Process Mining:** [nbs_analise/process_mining_obras_santos/](./nbs_analise/)
- **Migração Modelo:** [migracao-santos-acto-novo-modelo.md](./migracao-santos-acto-novo-modelo.md)

## 📖 Ver Também

- [CLAUDE.md](../CLAUDE.md) — Riscos globais, convenções, SCD Type 2
- [00_MAPA.md](../00_MAPA.md) — Navegação geral Documentação Fabric
- [Osasco/README.md](../Osasco/README.md) — Documentação Osasco
- [Acto/README.md](../Acto/README.md) — Documentação Acto (plataforma central)
