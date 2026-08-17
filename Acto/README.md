# 🏛️ Acto — Documentação da Plataforma & Pipelines

## 📍 Status

- **Ambiente:** Produção (Workspace `lh_cidade_inteligente_santos`)
- **Workspace ID:** `96fe5a53-3a22-4443-8d0a-e2f6d61a2690`
- **Escopo:** Plataforma central Acto Cidade Inteligente (múltiplos municípios)
- **Últimas atualizações:** Migração CET/SEPREF (2026), Bug investigação (2026-07-15)
- **Responsáveis:** Equipe Eicon | Acto Cidade Inteligente

## 🏗️ Arquitetura da Plataforma

```
Fonte: Acto API (múltiplos municípios)
    ↓
  Bronze: nb_bronze_acto_gestao (ingestão bruta, payload EAV)
    ↓
  Silver: nb_silver_acto_gestao (limpeza, tipagem, normalização, SCD Type 2)
    ↓
  Gold: nb_gold_[municipio]_[dominio] (dimensões, fatos, indicadores)
    ↓
  Power BI (mínimo DAX — lógica no Gold)
```

## 🏢 Domínios Cobertos (por Município)

### Santos
| Domínio | Status | Descrição |
|---------|--------|-----------|
| **Gestão (Geral)** | ✅ | Solicitações, etapas, SLA |
| **CET** | ✅ | Equipamentos de Trânsito |
| **SEPREF** | ✅ | Secretaria de Patrimônio |
| **Avaliação** | ⚠️ | Gold + sentimento (Groq) — R3 (misalinhamento) |
| **Obras** | 🔴 CRÍTICO | Parado desde 11/03/2025 (HTTP 401 — R5) |
| **Ouvidoria** | ✅ | Manifestações |
| **Segov** | ✅ | Segurança Governamental |
| **Seinfra** | ✅ | Infraestrutura |

### Osasco
| Domínio | Status | Descrição |
|---------|--------|-----------|
| **Atendimento CRAS** | ✅ | Assistência Social |
| **Atendimento Trabalhador** | ✅ | Bolsa Trabalho, BPC, CAGED, RAIS |
| **Carta de Serviços** | ✅ | SCD Type 2 com prazos |
| **Segurança Pública** | ⚠️ | Dados criminais SSP |

## 📚 Estrutura de Arquivos

### Raiz — Utilitários & Configuração
| Arquivo | Função |
|---------|--------|
| `nb_get_token_api.ipynb` | Obtenção de token de autenticação Acto |

### Bronze — Ingestão Raw
| Camada | Arquivo | Descrição |
|--------|---------|-----------|
| Bronze | `nbs/nbs_bronze/nb_bronze_acto_gestao.ipynb` | Ingestão principal (payload EAV bruto) |
| Orquestração | `nbs/nbs_bronze/nb_bronze_orquestracao.ipynb` | Orquestração de ingestões |

### Silver — Tratamento & Tipagem
| Camada | Arquivo | Descrição |
|--------|---------|-----------|
| Silver | `nbs/nbs_silver/nb_silver_acto_gestao.ipynb` | Limpeza, normalização, SCD Type 2 |

### Gold — Dimensões & Fatos (por Domínio)
| Municipio | Domínio | Arquivo | Descrição |
|-----------|---------|---------|-----------|
| **Santos** | CET | `nbs/nbs_gold/nb_gold_santos_cet.ipynb` | Gold CET |
| **Santos** | SEPREF | `nbs/nbs_gold/nb_gold_santos_sepref.ipynb` | Gold SEPREF |
| **Osasco** | CRAS | `nbs/nbs_gold/nb_gold_osasco_atendimento_cras.ipynb` | Gold CRAS |
| **Osasco** | Trabalhador | `nbs/nbs_gold/nb_gold_osasco_atendimento_trabalhador.ipynb` | Gold Bolsa/BPC/CAGED/RAIS |
| **Orquestração** | - | `nbs/nbs_gold/_nb_gold_orquestracao.ipynb` | Orquestração Gold |

### Utilitários
| Arquivo | Função |
|---------|--------|
| `utils/nb_utils_request_api.ipynb` | Utils de requisição (GET, POST, autenticação) |
| `utils/nb_utils_teste_token.ipynb` | Teste de conectividade e token |

## 🔴 Riscos & Problemas Conhecidos

### CRÍTICO (Parado em produção)
- **R5 — HTTP 401 Obras (Santos):** `nb_ingest_silver_acto_gestao_obras_santos` retorna 401 desde **11/03/2025**  
  - Impacto: Gold obras, Gold etapas, SEONT e 4 relatórios PBI parados  
  - Fix: Implementar `try/except HTTPError 401 → login_acto_gestao_obras() → retry` em `nb_utils_api_acto_gestao_obras`  
  - Ver: [CLAUDE.md → R5](../CLAUDE.md#known-active-issues-do-not-ignore)

- **R9 — CAGED (Osasco):** `nb_ingest_caged_santos` com `CODIGO_OSASCO = 353440` hardcoded  
  - ⚠️ NÃO ATIVAR até corrigir  
  - Ver: [CLAUDE.md → R9](../CLAUDE.md#known-active-issues-do-not-ignore)

### Alto Risco
- **R3 — Misalinhamento Gold (Santos Avaliação):** Gold avaliação usa `overwrite`, sentimento usa `append`  
  - Se Gold reescrever e sentimento falhar, IDs desalinhados  
  - Solução: sincronizar modos e adicionar transações atômicas

- **R7 — Sem try/except em API:** `nb_utils_ingest_acto_gestao` chama `raise_for_status()` sem tratamento  
  - Falhas propagam silenciosamente para chains avaliação e curso_motoristas  
  - Fix: envolver em `try/except` com logging

- **R1 — Arquivos auxiliares (SPOF):** Mudança de caminho quebra silenciosamente:
  - `Files/acto/tb_aux.xlsx` (sheets: `aux_prazo`, `aux_regionais`)
  - `PMS_AuxiliarPDR.xlsx` (obras)
  - `raw_cadastro_carta/*.csv` (carta de serviços)
  - Solução planejada: migrar para Delta Tables no Lakehouse

### Médio Risco
- **R2 — Funções duplicadas:** `ajustar_nome_colunas()`, `harmonizar_nome_bairros()`, `mapa_bairros` em múltiplos notebooks  
  - Solução planejada: criar `nb_utils_shared` e centralizar

- **R4 — Sem Rowcount Assertions:** Vários notebooks escrevem sem validar se DataFrame tem dados  
  - Referência: `nb_silver_santos_curso_motoristas` usa `assert len(df) > threshold`

- **Formato de Payload EAV:** Dois endpoints podem retornar formatos diferentes
  - `adicionar_etapa_atual()` espera `'Nº Solicitação|1'`
  - `adicionar_etapa_atual_2()` espera `'Nº Solicitação'`
  - Validar nome de coluna antes de fazer join

## 🔗 SCD Type 2 — Carta de Serviços (Importante!)

**O join com SLA DEVE usar `dt_abertura` entre vigências, NUNCA apenas `is_atual = True`:**

```sql
LEFT JOIN gold_dim_cartas_servico_vigencia d
    ON  s.id_servico   = d.id_servico
    AND s.dt_abertura >= d.dt_inicio_vigencia
    AND s.dt_abertura  < d.dt_fim_vigencia
```

Juntar apenas por `is_atual = True` aplica o prazão ATUAL a todas as solicitações históricas, corrompendo indicadores retrospectivos.

**Fonte canônica:** `exportar_4.csv` (693 registros, delimitador `;`, UTF-8 BOM)  
**Descartar:** `cadastro_carta_de_servico.csv` (conteúdo idêntico, fonte duplicada)

## 📊 Lakehouse Schema Acto

**Total:** 60 tabelas (48 Bronze · 3 Silver · 9 Gold) — atualizado 09/06/2026

Ver detalhes em:
- [SCHEMA_LAKEHOUSE_ACTO.md](./SCHEMA_LAKEHOUSE_ACTO.md) — estrutura completa
- [EAV_BRONZE_INVENTARIO.md](./EAV_BRONZE_INVENTARIO.md) — volumes, campos, NULLs

## 📖 Documentação Técnica

| Documento | Descrição |
|-----------|-----------|
| [DOCUMENTACAO_UNICA_ACTO.md](./DOCUMENTACAO_UNICA_ACTO.md) | Visão canônica do módulo e migração Santos |
| [DOCUMENTACAO_TECNICA_ACTO.md](./DOCUMENTACAO_TECNICA_ACTO.md) | Arquitetura, padrões, componentes |
| [DOCUMENTACAO_NEGOCIO_ACTO.md](./DOCUMENTACAO_NEGOCIO_ACTO.md) | Contexto negócio, SLAs, indicadores |
| [MAPEAMENTO_WORKSPACE_FABRIC.md](./MAPEAMENTO_WORKSPACE_FABRIC.md) | Mapeamento workspace Fabric (60 tabelas) |
| [DIAGRAMAS_ACTO.md](./DIAGRAMAS_ACTO.md) | Diagramas e fluxos |

## 📋 Guias de Início & Operação

| Documento | Escopo |
|-----------|--------|
| [GUIA_POR_ONDE_COMECAR_ACTO.md](./GUIA_POR_ONDE_COMECAR_ACTO.md) | Ordem recomendada de leitura para novos devs |
| [GUIA_DIARIO_ACTO.md](./GUIA_DIARIO_ACTO.md) | Resumo de uso diário e validações rápidas |
| [CHECKLIST_INICIO_MIGRACAO_CET_SEPREF.md](./CHECKLIST_INICIO_MIGRACAO_CET_SEPREF.md) | Checklist operacional: CET + SEPREF |
| [PLANO_GOLD_CET_SEPREF_PRAZO_UNIDADE_EXECUTORA.md](./PLANO_GOLD_CET_SEPREF_PRAZO_UNIDADE_EXECUTORA.md) | Plano técnico: prazo + unidade executora |

## 🔍 Investigações & Postmortems

| Documento | Assunto | Status |
|-----------|---------|--------|
| [INVESTIGACAO_BUG_SANTOS_OBRAS_PAYLOAD_API.md](./INVESTIGACAO_BUG_SANTOS_OBRAS_PAYLOAD_API.md) | Bug santos_obras: KeyError id_os + campos órfãos + inconsistência EAV | ✅ Resolvido (15/07/2026) |

## 🔗 Links Rápidos

- **Índice de Notebooks:** [00_INDEX_ACTO.md](./00_INDEX_ACTO.md)
- **Especificações & Roadmap:** [spec_paineis_indicadores_melhorias.md](./spec_paineis_indicadores_melhorias.md)
- **Painel SEMAM:** [spec_painel_semam_pareceres.md](./spec_painel_semam_pareceres.md)

## 📖 Ver Também

- [CLAUDE.md](../CLAUDE.md) — Riscos globais, convenções, SCD Type 2
- [00_MAPA.md](../00_MAPA.md) — Navegação geral Documentação Fabric
- [Santos/README.md](../Santos/README.md) — Documentação Santos (domínios específicos)
- [Osasco/README.md](../Osasco/README.md) — Documentação Osasco (domínios específicos)
