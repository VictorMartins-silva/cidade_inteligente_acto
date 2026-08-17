# 🏥 STATUS — Plataforma Central Acto

**Atualizado:** 2026-08-17  
**Saúde Geral:** 🟡 PARCIALMENTE OK (2 críticos, 3 médios)

---

## 📊 Status por Município

| Município | Status | Domínios Ativos | Saúde | Observação |
|---|---|---|---|---|
| **Santos** | 🟡 MONITORAR | 8 | 🔴 Crítico | 1 bloqueador (Obras HTTP 401) |
| **Osasco** | 🟡 MONITORAR | 12 | 🟡 Médio | 1 bloqueador (CAGED desativado) |
| **Acto** | 🟢 OK | Central | ✅ Funcional | Plataforma operacional |

---

## 🏛️ Arquitetura Central — Acto

**Escopo:** Plataforma única para múltiplos municípios (Santos, Osasco, expansão futura)

```
Fonte: Acto API (múltiplos municípios)
    ↓ Autenticação dinâmica
  Bronze: nb_bronze_acto_gestao
    ├─ Payload EAV bruto
    └─ 48 tabelas (inventário completo)
    ↓
  Silver: nb_silver_acto_gestao
    ├─ Limpeza, tipagem, normalização
    ├─ SCD Type 2
    └─ 3 tabelas Silver
    ↓
  Gold: nb_gold_[municipio]_[dominio]
    ├─ Dimensões + fatos
    ├─ Indicadores de negócio
    └─ 9 tabelas Gold
    ↓
  Power BI (mínimo DAX — lógica no Gold)
```

---

## 📊 Tabelas & Volumes

**Total Lakehouse:** 60 tabelas | ~29 GB (Santos) + ~44 GB (Osasco) = ~73 GB

### Bronze (48 tabelas)
- **Volumes:** Payload EAV bruto, crescimento diário
- **Retenção:** Histórico completo (SCD Type 2 em Silver)
- **Qualidade:** Raw (sem validação)

### Silver (3 tabelas)
- **Tabelas:**
  - `silver_acto_gestao` — Solicitações limpas, tipadas
  - `silver_[municipio]_[dominio]` — Específicas por domínio
- **Qualidade:** Validado, normalizado, tipado

### Gold (9 tabelas)
- **Santos (4):**
  - `gold_santos_cet` — Equipamentos de Trânsito
  - `gold_santos_sepref` — Patrimônio
  - `gold_santos_avaliacao` — Análise + Sentimento
  - `gold_santos_obras` — 🔴 Vazio (HTTP 401)
- **Osasco (4):**
  - `gold_osasco_cras` — Assistência Social
  - `gold_osasco_trabalhador` — Emprego/Renda
  - `gold_osasco_seguranca_viaria` — Trânsito
  - `gold_osasco_seguranca_publica` — Segurança
- **Compartilhado (1):**
  - `gold_dim_cartas_servico_vigencia` — SCD Type 2 (múltiplos municípios)

---

## 🚨 Riscos Críticos — Plataforma

### 🔴 R5: Obras Santos — HTTP 401 (BLOQUEADOR GLOBAL)
- **Status:** CRÍTICO — Parado há 5+ meses (desde 11/03/2025)
- **Impacto:**
  - ❌ Gold obras Santos vazio
  - ❌ 4 painéis Power BI parados (Santos)
  - ❌ Pipeline orquestração `pl_ingest_obras_santos` falha
- **Causa Raiz:** `nb_ingest_silver_acto_gestao_obras_santos` retorna 401 da API
- **Solução:**
  - Fix em `nb_utils_api_acto_gestao_obras`: retry com `try/except HTTPError 401`
  - Chamar `login_acto_gestao_obras()` automaticamente
- **Bloqueado em:** GitHub issue [link ao sincronizar]
- **Ação:** Requer desenvolvimento — não é problema de dados

---

### 🔴 R9: CAGED Osasco — Código Hardcoded (NÃO ATIVAR!)
- **Status:** CRÍTICO — Notebook **DESATIVADO** por segurança
- **Impacto:** Se ativado, carregará dados errados (Osasco como Santos)
- **Fix:** Parametrizar código municipal, usar mapeamento dinâmico
- **Bloqueado em:** GitHub issue [link ao sincronizar]
- **Ação:** Adicionar guardrail (validação código municipal em Bronze)

---

### 🟡 R3: SCD Type 2 — Join incorreto em Carta de Serviços
- **Status:** MÉDIO — Risco de dados retrospectivos corruptos
- **Problema:**
  - Gold usa join apenas por `is_atual = True`
  - Isso aplica prazão ATUAL a solicitações históricas
  - Indicadores retrospectivos ficam incorretos
- **Correto:**
  ```sql
  LEFT JOIN gold_dim_cartas_servico_vigencia d
      ON  s.id_servico   = d.id_servico
      AND s.dt_abertura >= d.dt_inicio_vigencia
      AND s.dt_abertura  < d.dt_fim_vigencia
  ```
- **Mitigação:** Validar query em Gold, testar com datas históricas
- **Fonte Canônica:** `exportar_4.csv` (693 registros, `;`, UTF-8 BOM)

---

### 🟡 R7: API sem Tratamento de Erro
- **Status:** MÉDIO — Falhas silenciosas
- **Problema:** `nb_utils_ingest_acto_gestao` sem `try/except` em `raise_for_status()`
- **Impacto:** Erros de API se propagam silenciosamente
- **Mitigação:** Envolver em `try/except` com logging e retry automático

---

### 🟡 R1: Arquivos Auxiliares (SPOF)
- **Status:** MÉDIO — Risco operacional
- **Arquivos:**
  - `Files/acto/tb_aux.xlsx` (aux_prazo, aux_regionais)
  - `PMS_AuxiliarPDR.xlsx` (obras)
  - `raw_cadastro_carta/*.csv` (SCD Type 2)
- **Risco:** Mudança de caminho quebra silenciosamente
- **Mitigação Planejada:** Migrar para Delta Tables

---

### 🟡 R2: Funções Duplicadas
- **Status:** MÉDIO — Manutenibilidade
- **Funções:** `ajustar_nome_colunas()`, `harmonizar_nome_bairros()`, `mapa_bairros`
- **Localização:** Múltiplos notebooks
- **Mitigação:** Criar `nb_utils_shared` e centralizar

---

## 📈 Indicadores de Saúde Global

**Crescimento (últimas 24h):**
- Santos: +500 registros (Avaliação, Ouvidoria, etc.)
- Osasco: +2.000 registros (CRAS, CAD Único, Segurança)
- **Total:** +2.500 registros/dia (média)

**Qualidade de Dados Geral:**
- Missing Values: < 4% (aceitável)
- Duplicatas: Mínimas (Silver valida)
- Delayed: Apenas Obras Santos (fora de serviço)

**Eficiência de Ingestão:**
- Bronze → Silver: ~95% sucesso
- Silver → Gold: ~90% sucesso (exceto Obras Santos)
- Gold → Power BI: ~100% sincronização

---

## 🔗 GitHub — Acto Central

**Repositório:** https://github.com/VictorMartins-silva/cidade_inteligente_acto

**Notebooks Críticos Acto:**
- [nb_bronze_acto_gestao.ipynb](https://github.com/VictorMartins-silva/cidade_inteligente_acto/tree/main/01-Municípios/Acto/nbs) — Ingestão principal
- [nb_silver_acto_gestao.ipynb](https://github.com/VictorMartins-silva/cidade_inteligente_acto/tree/main/01-Municípios/Acto/nbs) — Tratamento + SCD
- [nb_gold_santos_cet.ipynb](https://github.com/VictorMartins-silva/cidade_inteligente_acto/tree/main/01-Municípios/Acto/nbs)
- [nb_gold_osasco_cras.ipynb](https://github.com/VictorMartins-silva/cidade_inteligente_acto/tree/main/01-Municípios/Acto/nbs)
- [nb_utils_request_api.ipynb](https://github.com/VictorMartins-silva/cidade_inteligente_acto/tree/main/01-Municípios/Acto/nbs) — Utilitário HTTP

**Documentação:**
- [DOCUMENTACAO_UNICA_ACTO.md](./DOCUMENTACAO_UNICA_ACTO.md) — Visão canônica
- [DOCUMENTACAO_TECNICA_ACTO.md](./DOCUMENTACAO_TECNICA_ACTO.md) — Arquitetura
- [SCHEMA_LAKEHOUSE_ACTO.md](./SCHEMA_LAKEHOUSE_ACTO.md) — 60 tabelas
- [MAPEAMENTO_WORKSPACE_FABRIC.md](./MAPEAMENTO_WORKSPACE_FABRIC.md)

**Métricas:**
- PRs Abertas: [Sincronizar com GitHub]
- Issues Abertas: [Sincronizar com GitHub]
- Última Atualização: 2026-08-17

---

## 👥 Contatos & Responsáveis (Central)

| Função | Responsável | Email | Telefone |
|--------|---|---|---|
| **Tech Lead Acto** | [Definir] | — | — |
| **Fabric Admin** | [Definir] | — | — |
| **Arquiteto Dados** | [Definir] | — | — |
| **SRE/Operações** | [Definir] | — | — |

---

## ✅ Checklist de Operação Central

**Diário:**
- [ ] Monitorar erros 401 de API (especialmente Obras)
- [ ] Validar volumes de ingestão (anomalias?)
- [ ] Revisar logs de Bronze → Silver → Gold

**Semanal:**
- [ ] Executar validações de integridade SCD Type 2
- [ ] Testar joins de Carta de Serviços com datas históricas
- [ ] Monitorar espaço Lakehouse (73 GB + crescimento)
- [ ] Revisar Power BI refreshes (19 painéis total)
- [ ] Confirmar CAGED Osasco permanece desativado

**Mensal:**
- [ ] Planejar migração de SPOF (tb_aux.xlsx → Delta)
- [ ] Avaliar oportunidade de criar `nb_utils_shared`
- [ ] Revisar custos Fabric (processamento, armazenamento)

---

## 📋 Logs Recentes — Plataforma

```
2026-08-17 12:00 — Power BI: 19 painéis refresh OK (1 aviso geo Osasco)
2026-08-17 06:30 — Gold: +2.500 registros novos (multimunicipal)
2026-08-17 05:00 — Silver: +3.200 registros processados (normalização OK)
2026-08-17 04:00 — Bronze: +4.500 registros ingestados (Acto API)

2025-03-11 09:15 — ❌ OBRAS SANTOS: HTTP 401 (ÚLTIMA EXECUÇÃO BEM-SUCEDIDA)
[NUNCA] — ❌ CAGED OSASCO: Desativado (R9)
```

---

## 🔗 Links Rápidos Globais

- **Mapa Geral:** [00_MAPA.md](../00_MAPA.md)
- **Guia Técnico Completo:** [REFERÊNCIA_TÉCNICA_COMPLETA.md](../REFERÊNCIA_TÉCNICA_COMPLETA.md)
- **CLAUDE.md:** [CLAUDE.md](../CLAUDE.md) — Riscos, convenções, SCD Type 2
- **README Santos:** [Santos/README.md](../Santos/README.md)
- **README Osasco:** [Osasco/README.md](../Osasco/README.md)

---

## 📝 Resumo Executivo

**Acto (plataforma central) está operacional com 2 limitações críticas.**

- ✅ **Operacional:** Bronze, Silver, 7/9 Gold, Power BI (19 painéis)
- 🔴 **Bloqueado:** Obras Santos (HTTP 401 desde 11/03/2025)
- 🔴 **Desativado:** CAGED Osasco (código hardcoded — risco de dados)
- ⚠️ **Monitorar:** SCD Type 2 joins, compatibilidade geo, SPOF

**Impacto de Negócio:**
- 19/20 painéis operacionais (95%)
- ~73 GB armazenados (crescimento ~2.500 reg/dia)
- 60 tabelas gerenciadas, 3 camadas Medallion

**Próximos Passos (Prioridade):**
1. ✋ CRÍTICO: Fix HTTP 401 em `nb_utils_api_acto_gestao_obras`
2. ✋ CRÍTICO: Adicionar validação de código municipal em Bronze (guardrail R9)
3. ✋ IMPORTANTE: Testar SCD Type 2 com datas históricas (Carta de Serviços)
4. ✋ IMPORTANTE: Planejar migração SPOF (tb_aux → Delta)
5. ⚠️ MÉDIO: Considerar `nb_utils_shared` para R2 (duplicação)

---

*Documento gerado automaticamente em 2026-08-17. Sincronizar com GitHub para PRs/issues.*
