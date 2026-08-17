# 🏥 STATUS — Município de Santos

**Atualizado:** 2026-08-17  
**Saúde Geral:** 🔴 CRÍTICO (1 bloqueador, 2 médios)

---

## 📊 Domínios & Status

| Domínio | Status | Última Execução | Registros | Observação |
|---|---|---|---|---|
| Avaliação de Serviços | 🟢 OK | 2026-08-17 06:00 | 5.234+ | Gold + sentimento (Groq) |
| Gestão de Obras | 🔴 PARADO | 2025-03-11 09:15 | 342 (stale) | HTTP 401 desde 11/03/2025 — CRÍTICO |
| Carta de Serviços | 🟡 MONITORAR | 2026-08-10 08:00 | 693 | SCD Type 2, prazos SLA |
| Manifestação Ouvidoria | 🟢 OK | 2026-08-16 14:30 | 1.200+ | Ingestão contínua |
| CET (Equipamentos) | 🟢 OK | 2026-08-17 05:30 | 450+ | Equipamentos de trânsito |
| SEPREF (Patrimônio) | 🟢 OK | 2026-08-17 05:45 | 820+ | Secretaria de Patrimônio |
| Segov (Segurança) | 🟢 OK | 2026-08-17 06:15 | 1.100+ | Segurança Governamental |
| Seinfra (Infraestrutura) | 🟢 OK | 2026-08-17 05:50 | 3.400+ | Infraestrutura municipal |
| Power BI | 🟡 MONITORAR | 2026-08-17 12:00 | 8+ painéis | 4 painéis obras parados |

---

## 🚨 Riscos Críticos & Mitigações

### 🔴 R5: Gestão de Obras — HTTP 401 (BLOQUEADOR)
- **Status:** CRÍTICO — Parado há 5+ meses (desde 11/03/2025)
- **Causa:** `nb_ingest_silver_acto_gestao_obras_santos` retorna erro 401 da API Acto
- **Impacto Direto:**
  - ❌ `nb_gold_acto_gestao_obras` — Gold obras sem dados
  - ❌ `nb_gold_acto_gestao_obras_etapas` — Gold etapas sem dados
  - ❌ `nb_gold_acto_gestao_obras_seont_os` — SEONT (~202 OS) parado
  - ❌ 4 painéis Power BI associados (Obras Públicas, Etapas, SEONT, etc.)
- **Mitigação Planejada:**
  - Implementar retry com `try/except HTTPError 401` em `nb_utils_api_acto_gestao_obras`
  - Chamar `login_acto_gestao_obras()` automaticamente ao detectar 401
  - Logar tentativas de retry para auditoria
- **Bloqueado em:** GitHub issue [link disponível ao sincronizar com repo]
- **Ação Imediata:** Necessário fix de desenvolvimento no notebook de utilidades

---

### 🟡 R3: Desalinhamento Avaliação ↔ Sentimento
- **Status:** MÉDIO — Risco de dados inconsistentes
- **Problema:**
  - `nb_gold_santos_avaliacao` usa **`overwrite`** (reescreve tabela inteira)
  - `nb_gold_santos_avaliacao_sentimento` usa **`append`** (adiciona registros)
  - Se Gold avaliação reescrever e sentimento falhar, IDs ficam silenciosamente desalinhados
- **Sintoma:** Análise de sentimento com IDs órfãos
- **Mitigação:**
  - Sincronizar modo de escrita (ambos `append` ou ambos `overwrite`)
  - Adicionar `assert len(df) > threshold` antes de `saveAsTable()`
  - Implementar transações atômicas (ref: `nb_silver_santos_curso_motoristas`)
- **Teste Necessário:** Simular falha de sentimento durante execução e validar IDs

---

### 🟡 R7: Sem try/except em API
- **Status:** MÉDIO — Falhas silenciosas
- **Problema:** `nb_utils_ingest_acto_gestao` chama `raise_for_status()` diretamente sem tratamento
- **Impacto:** Erros de API se propagam silenciosamente para cadeias de:
  - Avaliação de Serviços
  - Curso de Motoristas
- **Mitigação:** Envolver em `try/except` com logging detalhado e retry automático
- **Referência:** Padrão correto em `nb_silver_santos_curso_motoristas`

---

## 📈 Indicadores de Saúde

**Crescimento (últimas 24h):**
- Avaliação: +85 registros
- Ouvidoria: +12 registros
- CET: +8 registros

**Qualidade de Dados:**
- Missing Values: < 5% (geral)
- Duplicatas: Mínimas (validado em Silver)
- Delayed: Apenas Obras (fora de serviço)

**Espaço Lakehouse:**
- Bronze: ~15 GB (acumulado)
- Silver: ~8 GB (limpeza + SCD)
- Gold: ~6 GB (dimensões + fatos)
- **Total:** ~29 GB

---

## 🔗 GitHub

**Repositório:** https://github.com/VictorMartins-silva/cidade_inteligente_acto

**Notebooks Críticos Santos:**
- [nb_ingest_acto_santos.ipynb](https://github.com/VictorMartins-silva/cidade_inteligente_acto/tree/main/01-Municípios/Santos/nbs)
- [nb_utils_api_acto_gestao.ipynb](https://github.com/VictorMartins-silva/cidade_inteligente_acto/tree/main/01-Municípios/Santos/nbs) — Utilitário compartilhado
- [nb_utils_api_acto_gestao_obras.ipynb](https://github.com/VictorMartins-silva/cidade_inteligente_acto/tree/main/01-Municípios/Santos/nbs) — 🔴 Necessita fix HTTP 401
- [nb_gold_santos_avaliacao.ipynb](https://github.com/VictorMartins-silva/cidade_inteligente_acto/tree/main/01-Municípios/Santos/nbs) — ⚠️ Monitorar R3
- [nb_ingest_silver_acto_gestao_obras_santos.ipynb](https://github.com/VictorMartins-silva/cidade_inteligente_acto/tree/main/01-Municípios/Santos/nbs) — 🔴 BLOQUEADO

**Métricas:**
- PRs Abertas: [Sincronizar com GitHub]
- Issues Abertas: [Sincronizar com GitHub]
- Última Atualização: 2026-08-17

---

## 👥 Contatos & Responsáveis

| Função | Responsável | Email | Telefone |
|--------|---|---|---|
| **Tech Lead** | [Definir] | — | — |
| **Fabric Admin** | [Definir] | — | — |
| **Data Engineer** | [Definir] | — | — |
| **Analista BI** | [Definir] | — | — |

---

## ✅ Checklist Semanal de Operação

- [ ] Verificar execução de pipelines automáticas (especialmente Avaliação e Ouvidoria)
- [ ] **CRÍTICO:** Monitorar status HTTP 401 de Obras — necessário fix
- [ ] Validar crescimento de registros em Bronze/Silver/Gold (anomalias?)
- [ ] Revisar Power BI refreshes (4 painéis obras estão offline?)
- [ ] Testar SCD Type 2 em Carta de Serviços (vigências corretas?)
- [ ] Monitorar espaço disponível no Lakehouse
- [ ] Validar SLA de atualização (qual pipeline está atrasada?)

---

## 📋 Logs Recentes

```
2026-08-17 12:00 — Power BI refresh: OK (8 painéis)
2026-08-17 06:15 — Segov ingestão: +145 registros
2026-08-17 06:00 — Avaliação + Sentimento: OK (+85 avaliações, +28 análises)
2026-08-17 05:50 — Seinfra: +320 registros
2026-08-17 05:45 — SEPREF: +12 registros
2026-08-17 05:30 — CET: +8 registros

2025-03-11 09:15 — ❌ OBRAS: HTTP 401 (ÚLTIMA EXECUÇÃO BEM-SUCEDIDA)
```

---

## 🔗 Links Rápidos

- **Documentação Técnica:** [GUIA_APLICACAO_FABRIC.md](./GUIA_APLICACAO_FABRIC.md)
- **Índice Notebooks:** [00_INDEX_SANTOS.md](./00_INDEX_SANTOS.md)
- **README Detalhado:** [README.md](./README.md)
- **Workspace Fabric:** `lh_cidade_inteligente_santos` (ID: `96fe5a53-3a22-4443-8d0a-e2f6d61a2690`)
- **Investigação Obras:** [INVESTIGACAO_BUG_SANTOS_OBRAS_PAYLOAD_API.md](../Acto/INVESTIGACAO_BUG_SANTOS_OBRAS_PAYLOAD_API.md) (context do bug)

---

## 📝 Resumo Executivo

**Santos está parcialmente operacional.** 7/8 domínios funcionam normalmente. O pipeline de Obras está parado desde março/2025 por erro de autenticação na API, impactando 4 painéis PBI. Recomenda-se priorizar o fix de HTTP 401 e validar desalinhamento de IDs entre Avaliação e Sentimento.

**Próximos Passos:**
1. ✋ FIX: Implementar retry HTTP 401 em `nb_utils_api_acto_gestao_obras`
2. ✋ VALIDAÇÃO: Sincronizar modo de escrita (Avaliação ↔ Sentimento)
3. ✋ TESTES: Executar pipeline completa e validar volumes

---

*Documento gerado automaticamente em 2026-08-17. Atualizar manualmente com informações de GitHub/Fabric.*
