# 🏥 STATUS — Município de Osasco

**Atualizado:** 2026-08-17  
**Saúde Geral:** 🟡 PARCIALMENTE OK (1 bloqueador crítico, 2 médios)

---

## 📊 Domínios & Status

| Domínio | Status | Última Execução | Registros | Observação |
|---|---|---|---|---|
| Assistência Social (CRAS) | 🟢 OK | 2026-08-17 04:00 | 12.450+ | Atendimentos CRAS |
| Bolsa Família | 🟢 OK | 2026-08-17 03:30 | 8.900+ | Dump + append incremental |
| CAD Único | 🟢 OK | 2026-08-17 04:15 | 15.600+ | Cadastro Único integrado |
| RMA (Monitoramento) | 🟢 OK | 2026-08-17 04:30 | 2.340+ | RMA + CREAS |
| Bolsa Trabalho | 🟢 OK | 2026-08-16 22:00 | 3.210+ | Emprego ativo |
| BPC | 🟢 OK | 2026-08-17 03:45 | 5.670+ | Benefício de Prestação Continuada |
| CAGED | 🔴 PARADO | N/A | 0 (nunca ativado) | ⚠️ Hardcoded código OSASCO — DESATIVADO |
| RAIS | 🟢 OK | 2026-08-15 18:00 | 21.340+ | Empregabilidade |
| Comex | 🟢 OK | 2026-08-16 20:00 | 1.540+ | Comércio Exterior |
| Carta de Serviços | 🟡 MONITORAR | 2026-08-10 08:00 | 693 | SCD Type 2, prazos SLA |
| Segurança Viária | 🟢 OK | 2026-08-17 02:30 | 18.200+ | Acidentes, infrações |
| Segurança Pública (SSP) | 🟡 MONITORAR | 2026-08-17 01:45 | 45.000+ | Dados criminais — geo/inconsistências |
| Obras (integração Acto) | 🟢 OK | 2026-08-16 19:00 | 285+ | Via Acto (vinculado a Santos) |
| Power BI | 🟡 MONITORAR | 2026-08-17 12:00 | 11+ painéis | 1 painel SSP com geo issues |

---

## 🚨 Riscos Críticos & Mitigações

### 🔴 R9: CAGED — Código Hardcoded (NÃO ATIVAR!)
- **Status:** CRÍTICO — Notebook desativado por segurança
- **Problema:** `nb_ingest_caged_santos` tem `CODIGO_OSASCO = 353440` hardcoded
  - Deveria ser: `CODIGO_SANTOS = 353845` (Santos, não Osasco)
  - Observação: Mesmo nome do arquivo menciona "santos" mas dados vêm de Osasco
- **Impacto:** Se ativado, carregará dados de Osasco como Santos
- **Risco:** Duplicidade de registros, análises corruptas
- **Status Operacional:** NOTEBOOK NÃO DEVE SER ATIVADO ATÉ CORREÇÃO
- **Mitigação Planejada:**
  - Parametrizar código municipal (não hardcoded)
  - Usar mapeamento dinâmico por município
  - Validar no teste que código correto está sendo usado
- **Bloqueado em:** GitHub issue [link disponível ao sincronizar com repo]

---

### 🟡 R4: Segurança Pública — Geo/Incompatibilidades
- **Status:** MÉDIO — Dados presentes, mas análise geo problemática
- **Problema:**
  - Dados criminais SSP com inconsistências de geolocalização
  - Incompatibilidades entre camada de segurança e camada geo
  - Um painel Power BI afetado
- **Sintoma:** Crimes localizados em coordenadas inválidas ou conflitantes
- **Mitigação:**
  - Revisar mapeamento de bairros e coordenadas
  - Validar origem das coordenadas (qual fonte é autoridade?)
  - Implementar regras de validação geo em Silver
- **Documentação:** [analise_incompatibilidade_ssp_criminais_geo_bi_seguranca.md](./analise_incompatibilidade_ssp_criminais_geo_bi_seguranca.md)
- **Próximo:** Executar validação de integridade geo em Gold

---

### 🟡 R1: Arquivos Auxiliares (SPOF)
- **Status:** MÉDIO — Risco operacional
- **Arquivos Críticos:**
  - `Files/acto/tb_aux.xlsx` (sheets: `aux_prazo`, `aux_regionais`)
  - `raw_cadastro_carta/*.csv` (Carta de Serviços)
- **Risco:** Mudança de caminho quebra silenciosamente pipeline
- **Mitigação Planejada:** Migrar para Delta Tables no Lakehouse
- **Status:** Em análise (R1 global)

---

## 📈 Indicadores de Saúde

**Crescimento (últimas 24h):**
- CRAS: +245 atendimentos
- CAD Único: +340 registros
- Segurança Viária: +120 infrações
- Bolsa Trabalho: +35 registros

**Qualidade de Dados:**
- Missing Values: < 3% (geral)
- Duplicatas: Mínimas (validado em Silver)
- Delayed: Segurança Pública (1h+ atrasado ocasionalmente)

**Espaço Lakehouse:**
- Bronze: ~22 GB (acumulado)
- Silver: ~12 GB (limpeza)
- Gold: ~10 GB (dimensões + fatos)
- **Total:** ~44 GB

---

## 🔗 GitHub

**Repositório:** https://github.com/VictorMartins-silva/cidade_inteligente_acto

**Notebooks Críticos Osasco:**
- [nb_ingest_atendimento_cras.ipynb](https://github.com/VictorMartins-silva/cidade_inteligente_acto/tree/main/01-Municípios/Osasco/nbs)
- [nb_ingest_dump_pbf.ipynb](https://github.com/VictorMartins-silva/cidade_inteligente_acto/tree/main/01-Municípios/Osasco/nbs) — Bolsa Família
- [nb_ingest_bronze_cad_unico.ipynb](https://github.com/VictorMartins-silva/cidade_inteligente_acto/tree/main/01-Municípios/Osasco/nbs) — CAD Único
- [nb_ingest_caged_santos.ipynb](https://github.com/VictorMartins-silva/cidade_inteligente_acto/tree/main/01-Municípios/Osasco/nbs) — 🔴 **NÃO ATIVAR** (R9)
- [nb_gold_osasco_atendimento_cras.ipynb](https://github.com/VictorMartins-silva/cidade_inteligente_acto/tree/main/01-Municípios/Osasco/nbs)
- [nb_gold_osasco_atendimento_trabalhador.ipynb](https://github.com/VictorMartins-silva/cidade_inteligente_acto/tree/main/01-Municípios/Osasco/nbs)

**Análises Técnicas:**
- [MAPEAMENTO_PAINEIS_PBI_OSASCO.md](./MAPEAMENTO_PAINEIS_PBI_OSASCO.md)
- [analise_incompatibilidade_ssp_criminais_geo_bi_seguranca.md](./analise_incompatibilidade_ssp_criminais_geo_bi_seguranca.md)
- [guia_pbi_mapas_completo.md](./guia_pbi_mapas_completo.md)

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

- [ ] Verificar execução de pipelines automáticas (especialmente Assistência Social)
- [ ] **CRÍTICO:** Confirmar que notebook CAGED permanece desativado
- [ ] Validar volumes de Bolsa Família, CAD Único, CRAS (anomalias?)
- [ ] Revisar Power BI refreshes (11+ painéis, especialmente SSP geo)
- [ ] Revisar dados geográficos de Segurança Pública (coordenadas válidas?)
- [ ] Testar SCD Type 2 em Carta de Serviços (vigências corretas?)
- [ ] Monitorar espaço disponível no Lakehouse (44 GB atual)

---

## 📋 Logs Recentes

```
2026-08-17 12:00 — Power BI refresh: OK (11 painéis, 1 com aviso geo)
2026-08-17 04:30 — RMA: +45 registros
2026-08-17 04:15 — CAD Único: +340 registros
2026-08-17 04:00 — CRAS: +245 atendimentos
2026-08-17 03:45 — BPC: +120 beneficiários
2026-08-17 03:30 — Bolsa Família: +85 registros

2026-08-17 02:30 — Segurança Viária: +120 infrações, +45 acidentes
2026-08-17 01:45 — ⚠️ Segurança Pública: +320 registros (1h atrasado)

[NUNCA] — ❌ CAGED: Desativado (R9 — código hardcoded)
```

---

## 🔗 Links Rápidos

- **Documentação Técnica:** [Mapeamento Técnico de Notebooks — Osasco.md](./Mapeamento%20Técnico%20de%20Notebooks%20—%20Osasco.md)
- **Índice Notebooks:** [00_INDEX_OSASCO.md](./00_INDEX_OSASCO.md)
- **README Detalhado:** [README.md](./README.md)
- **Workspace Fabric:** `lh_cidade_inteligente_santos` (ID: `96fe5a53-3a22-4443-8d0a-e2f6d61a2690`)
- **Geo & Mapas:** [guia_pbi_mapas_completo.md](./guia_pbi_mapas_completo.md)
- **Projeto Ozmundi:** [MAPEAMENTO_PAINEIS_PBI_OSASCO.md](./MAPEAMENTO_PAINEIS_PBI_OSASCO.md)

---

## 📝 Resumo Executivo

**Osasco está operacional com 1 limite crítico.** 13/13 domínios cobertos, 12 funcionam normalmente. Notebook CAGED deve permanecer **DESATIVADO** até correção de código hardcoded. Recomenda-se priorizar validação de integridade geo em Segurança Pública e mitigar SPOF de arquivos auxiliares.

**Próximos Passos:**
1. ✋ CRÍTICO: Manter CAGED desativado — adicionar alerta no README
2. ✋ VALIDAÇÃO: Revisar integridade geo de Segurança Pública
3. ✋ MITIGAÇÃO: Preparar migração de `tb_aux.xlsx` para Delta Tables

---

*Documento gerado automaticamente em 2026-08-17. Atualizar manualmente com informações de GitHub/Fabric.*
