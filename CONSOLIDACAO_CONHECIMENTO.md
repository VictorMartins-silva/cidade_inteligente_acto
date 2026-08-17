# 📚 CONSOLIDAÇÃO DE CONHECIMENTO — Duplicatas & Fragmentação

**Análise:** 2026-08-17  
**Status:** ✅ Completa

---

## 🔴 CRÍTICO IMEDIATO

### BUG: CODIGO_OSASCO Hardcoded em nb_ingest_caged_santos

| Notebook | Código | Status |
|---|---|---|
| `nb_gold_acto_gestao_obras` | 353845 | ✅ Correto (SANTOS) |
| `nb_ingest_caged_santos` | 353440 | 🔴 **ERRADO** (OSASCO!) |

**Ação IMEDIATA (5 min):** Corrigir `nb_ingest_caged_santos`: `CODIGO_OSASCO = 353440` → `CODIGO_SANTOS = 353845`

---

## 1. FUNÇÕES DUPLICADAS (R2 — MÉDIO)

### 1.1 `ajustar_nome_colunas()`
- ✅ **CANÔNICA:** `nb_utils_api_acto_gestao` (remove acentos, snake_case, **vírgulas**)
- ❌ **DUPLICADA:** `nb_ingest_acto_santos` (sem remoção de vírgula — bug Delta)
- **Impacto:** Dados processados diferentemente conforme notebook usado
- **Ação:** Centralizar em `nb_utils_shared`
- **Esforço:** 30 min

### 1.2 `harmonizar_nome_bairros()`
- ✅ **CANÔNICA:** `nb_utils_api_acto_gestao` (16 variantes + `str.title()`)
- ❌ **DUPLICADA:** `nb_ingest_acto_santos` (18 variantes, sem normalização)
- **Impacto:** Análises de bairro com diferentes resultados
- **Ação:** Centralizar em `nb_utils_shared`
- **Esforço:** 30 min

### 1.3 `mapa_bairros` (dicionário)
- ✅ **CANÔNICA:** Inline em `nb_gold_acto_gestao_obras` (~25 entradas)
- **Referências:** `spec_drive_paridade_gold_obras.md` + CSV Osasco (60 bairros)
- **Impacto:** Não sincronizado entre contextos
- **Ação:** Migrar para `dim_bairro_normalizacao` Delta Table
- **Esforço:** 2h (P2)

---

## 2. DOCUMENTAÇÃO DUPLICADA

### 2.1 Avaliação de Serviços
- **Técnica:** `02-Técnica/Arquitetura/doc/avaliacao_servicos_ia_santos.md` (IA + Groq)
- **Negócio:** `05-Painéis/paineis_negocio/f3_avaliacao_servicos.md` (painel Power BI)
- **Status:** ✅ Bem documentadas, ❌ sem links cruzados
- **Ação:** Adicionar referências cruzadas

### 2.2 SCD Type 2 — Carta de Serviços
**Documentado em 5 lugares:**
1. `REFERÊNCIA_TÉCNICA_COMPLETA.md` seção 12.3 ✅ **CANÔNICA**
2. `CLAUDE.md` — "SCD Type 2" section
3. `README_ESTRUTURA.md` — referência rápida
4. `DOCUMENTACAO_CONSOLIDADA_FABRIC.md` seção 13
5. `acervo/decisoes/2026-07-21-scd2-carta-credenciais...md`

**Recomendação:** Manter REFERÊNCIA como canônica, outros linkam com `Ver também: ...`

---

## 3. PADRÕES REPETIDOS

### 3.1 SCD Type 2 — Implementação Vigência de Prazos
- Encontrado em: `nb_silver_santos_avaliacao` + `nb_gold_santos_avaliacao`
- **Pattern CORRETO:**
```sql
LEFT JOIN gold_dim_cartas_servico_vigencia d
    ON  s.id_servico = d.id_servico
    AND s.dt_abertura >= d.dt_inicio_vigencia
    AND s.dt_abertura < d.dt_fim_vigencia
```
- **Risco:** Se alguém usar `is_atual = True`, análises históricas ficam erradas
- **Ação:** Auditar se implementação está consistente em 2 notebooks
- **Esforço:** 2h

---

## 4. CONFIGURAÇÕES ESPALHADAS (SPOF)

### 4.1 Caminhos de Arquivo (R1)

| Arquivo | Usado em | Risco |
|---|---|---|
| `Files/acto/tb_aux.xlsx` | `nb_ingest_acto_santos`, `nb_utils_api_acto_gestao` | Se mover, quebra silenciosamente |
| `PMS_AuxiliarPDR.xlsx` | `nb_gold_acto_gestao_obras` | Idem |
| `raw_cadastro_carta/*.csv` | `nb_ingest_carta_servicos_santos` | Idem |

**Recomendação:** Já documentado em CLAUDE.md R1. Adicionar validações (`assert os.path.exists(path)`).

### 4.2 Nomes de Bairros (Espalhados)
- `mapa_bairros` dict em nb_gold_acto_gestao_obras
- `harmonizar_nome_bairros()` em nb_utils_api_acto_gestao
- `bairros_osasco_centroids.csv` (geo)

**Ação:** Consolidar em `dim_bairro_normalizacao` Delta Table (P2, 4h)

---

## 📋 MATRIZ DE AÇÕES

### 🔴 CRÍTICO (Hoje — 5 min)
| ID | O Quê | Onde | Esforço |
|---|---|---|---|
| C1 | Corrigir CODIGO_SANTOS | `nb_ingest_caged_santos` | 5 min |

### P1 (Semana 1 — 3h)
| ID | O Quê | Onde | Esforço |
|---|---|---|---|
| P1-1 | Centralizar `ajustar_nome_colunas()` | Remove de `nb_ingest_acto_santos`, cria `nb_utils_shared` | 30 min |
| P1-2 | Centralizar `harmonizar_nome_bairros()` | Remove de `nb_ingest_acto_santos` | 30 min |
| P1-3 | Config centralizada de municípios | Criar `config_municipios.py` | 1h |
| P1-4 | Validar caminhos de arquivo | Adicionar `assert os.path.exists()` | 1h |

### P2 (Semana 2 — 6h)
| ID | O Quê | Onde | Esforço |
|---|---|---|---|
| P2-1 | Links cruzados — Avaliação | Docs técnica + negócio | 30 min |
| P2-2 | Consolidar SCD Type 2 ref | 5 docs → 1 canônico | 1h |
| P2-3 | Auditar SCD Type 2 impl | 2 notebooks | 2h |
| P2-4 | Tabela Delta — Bairros | `dim_bairro_normalizacao` | 4h |

### P3 (Roadmap — 15h)
| ID | O Quê | Onde | Esforço |
|---|---|---|---|
| P3-1 | Criar `nb_utils_shared` | Consolidar todas utils | 8h |
| P3-2 | Migrar arquivos para Delta | `tb_aux.xlsx` → tabelas (R1) | 4h |
| P3-3 | Finalizar token management | Azure Key Vault | 3h |

---

## 📊 IMPACTO ESTIMADO

- **📉 Redução código duplicado:** ~150 linhas (65%)
- **⏱️ Manutenção:** -30% de tempo em próximas mudanças
- **🚀 Onboarding:** -20% de confusão ("qual versão usar?")
- **🐛 Bugs silenciosos evitados:** 3+ riscos mitigados

---

## 🔗 DOCUMENTAÇÃO RELACIONADA

- `REFERÊNCIA_TÉCNICA_COMPLETA.md` — Padrões técnicos, SCD Type 2
- `CLAUDE.md` — Contexto geral, R2, R1
- `README_ESTRUTURA.md` — Convenções
- `DASHBOARD_RISCOS.md` — R1-R9 com prioridades

---

**Status:** ✅ Análise Consolidada  
**Gerado:** 2026-08-17  
**Próximo:** Executar ações P1 (semana 1)
