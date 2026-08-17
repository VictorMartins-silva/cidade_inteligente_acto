---
title: "Spec Drive — Migração Santos → Módulo Acto"
tags:
  - tipo/spec-drive
  - tema/migracao
  - tema/santos
  - tema/roadmap
status: ativo
revisao: "2026-05-19"
---

# Spec Drive — Migração Santos → Módulo Acto

> **Escopo atual:** 8 domínios Santos + 2 Osasco migrados para `lh_solicitacoes_acto`
> **Pipeline:** `pl_ingest_acto` (objectId `39b453a3-0532-46b2-85b2-85f77032ef2b`)
> **Atualizado:** 2026-05-19

---

## Estado Atual — 2026-05-19

| Componente | Estado |
|---|---|
| `nb_get_token_api` — OAuth2 automático | ✅ Pronto |
| `nb_utils_request_api` — extração EAV | ✅ Pronto |
| `nb_bronze_acto_gestao` + `nb_bronze_orquestracao` | ✅ 11 fontes ativos |
| `nb_silver_acto_gestao` — UNION BY NAME | ✅ 62.625 sol / 464.396 campos / 271.685 etapas |
| Gold Santos — 9 tabelas | ✅ Todas em `gold.` schema |
| Gold Osasco — trabalhador | ✅ `gold.osasco_atendimento_trabalhador` |
| Gold Osasco — CRAS | ⚠️ Notebook é cópia do trabalhador — precisa ajuste |
| Tabelas `dbo.gold_fato_*` antigas | ✅ Dropadas |
| RefreshSqlEndpoint (`recreateTables: true`) | ⏳ Pendente |
| Reconexão PBI Santos (9 painéis prontos) | ⏳ Pendente — responsável: Jorge |
| Obras PBI (4+1 painéis) | 🔒 Bloqueado — validar schema com Kelly/DECONTE |
| Credenciais `ACTO_USER`/`ACTO_SENHA` | ❌ Plaintext no `nb_bronze_orquestracao` |

---

## Fontes Ativos no Bronze (11)

| `id_fonte` | Município | Secretaria | Payload |
|---|---|---|---|
| `santos_cet` | Santos | CET | `payload_santos_cet.json` |
| `santos_cet_carga_descarga` | Santos | CET | `payload_cet_carga_descarga.json` |
| `santos_sepref` | Santos | SEPREF | `payload_santos_sepref_consolidado.json` |
| `santos_avaliacao` | Santos | OUVIDORIA | `payload_santos_avaliacao.json` |
| `santos_ouvidoria_manifestacao` | Santos | OUVIDORIA | `payload_santos_ouvidoria_manifestacao.json` |
| `santos_seinfra` | Santos | SEINFRA | `payload_santos_seinfra.json` |
| `santos_segov` | Santos | SEGOV | `payload_santos_segov.json` |
| `santos_curso_motorista` | Santos | CET | `payload_santos_curso_motorista.json` |
| `santos_obras` | Santos | OBRAS | `payload_obras.json` |
| `osasco_atendimento_cras` | Osasco | SAS | `payload_osasco_atendimento_cras.json` |
| `osasco_atendimento_trabalhador` | Osasco | SETRE | `payload_osasco_atendimento_trabalhador.json` |

---

## Tabelas Gold Disponíveis em `lh_solicitacoes_acto`

| Tabela | Fonte | PBI pronto para reconectar |
|---|---|---|
| `gold.fato_solicitacoes_cet` | santos_cet | ✅ Sim |
| `gold.fato_solicitacoes_cet_carga_descarga` | santos_cet_carga_descarga | ✅ Sim |
| `gold.fato_solicitacoes_sepref` | santos_sepref | ✅ Sim |
| `gold.fato_solicitacoes_avaliacao` | santos_avaliacao | ⚠️ Depende de sentimento (não migrado) |
| `gold.fato_solicitacoes_segov` | santos_segov | ✅ Sim |
| `gold.fato_solicitacoes_seinfra` | santos_seinfra | ✅ Sim |
| `gold.fato_solicitacoes_ouvidoria_manifestacao` | santos_ouvidoria_manifestacao | ✅ Sim (F1 + F2 x5) |
| `gold.fato_solicitacoes_curso_motorista` | santos_curso_motorista | ✅ Sim (2 painéis) |
| `gold.fato_solicitacoes_obras` | santos_obras | 🔒 Não — validar com cliente |
| `gold.osasco_atendimento_trabalhador` | osasco_atendimento_trabalhador | ✅ Sim |

---

## Próximos Passos

### ⏳ Bloco A — SQL Endpoint (imediato)

- [ ] **A.1** Rodar `RefreshSqlEndpoint` com `recreateTables: true` para registrar as tabelas `gold.*` no catálogo SQL
- [ ] **A.2** Verificar no SQL Endpoint que todas as 10 tabelas aparecem no schema `gold`
- [ ] **A.3** Reverter `recreateTables` para `false` na pipeline

---

### ⏳ Bloco B — Reconexão PBI Santos (Jorge)

9 painéis prontos para reconectar ao `lh_solicitacoes_acto`:

- [ ] **B.1** F1 — SEGOV (`gold_segov_servicos` → `gold.fato_solicitacoes_segov`)
- [ ] **B.2** F1 — SEINFRA (`gold_seinfra_servicos` → `gold.fato_solicitacoes_seinfra`)
- [ ] **B.3** F1 — CET principal (`gold_cet_servicos` → `gold.fato_solicitacoes_cet`)
- [ ] **B.4** F1 — CET Carga e Descarga (`gold_cet_carga_descarga` → `gold.fato_solicitacoes_cet_carga_descarga`)
- [ ] **B.5** F1 — SEPREF (`gold_sepref_servicos` → `gold.fato_solicitacoes_sepref`)
- [ ] **B.6** F1 — Ouvidoria (`gold_ouvidoria_servicos` → `gold.fato_solicitacoes_ouvidoria_manifestacao`)
- [ ] **B.7** F2 — Manifestações Ouvidoria x5 (`gold_manifestacoes_ouvidoria` → `gold.fato_solicitacoes_ouvidoria_manifestacao`)
- [ ] **B.8** F6 — Curso Motorista x2 (`gold_curso_motoristas` → `gold.fato_solicitacoes_curso_motorista`)
- [ ] **B.9** Adicionar refreshes PBI dos painéis reconectados na `pl_ingest_acto`

> [!warning] Atenção para Jorge
> Os nomes das colunas mudaram em relação às tabelas legadas (EAV pivot vs. Gold específico). Validar medidas DAX após reconectar antes de publicar.

---

### 🔒 Bloco C — Obras (ver spec dedicado)

Ver [[SPEC_DRIVE_MIGRACAO_OBRAS]] — plano de implementação completo em 8 blocos.

- [ ] **C.1** Bloco 0–1: Corrigir `nb_gold_santos_obras` + conectar ao orquestrador
- [ ] **C.2** Bloco 2: Corrigir `zona_aplicavel` + `analista_responsavel`
- [ ] **C.3** Bloco 3: Migrar PMS_AuxiliarPDR.xlsx → Delta
- [ ] **C.4** Bloco 4–5: Criar `nb_gold_santos_obras_seont` + `nb_gold_santos_obras_tempo_etapa`
- [ ] **C.5** Bloco 6–7: SQL Endpoint + reconexão 4 painéis PBI

---

### 🔧 Bloco D — Pendências técnicas

- [ ] **D.1** Ajustar `nb_gold_osasco_atendimento_cras` — atualmente é cópia do trabalhador, precisa lógica própria
- [ ] **D.2** Credenciais: migrar `ACTO_USER`/`ACTO_SENHA` de plaintext para `mssparkutils.credentials.getSecret()`
- [ ] **D.3** Avaliação Sentimento — tabela não existe no novo LH; painel bloqueado até criação do notebook
- [ ] **D.4** Carta de Serviços — fora do escopo do `lh_solicitacoes_acto` (fonte CSV); painel bloqueado

---

## Fora de Escopo — Esta Iteração

| Domínio | Motivo |
|---|---|
| Avaliação Sentimento | Notebook sem pipeline ativo, tabela não migrada |
| Carta de Serviços / SLA | Fonte CSV — escopo separado |
| CAGED Santos | Bug ativo (código IBGE errado) — não ativar |
| Mauá, Aparecida, SJRP | Escopo futuro |

---

## Referências

- [[DOCUMENTACAO_TECNICA_ACTO]] — arquitetura técnica do módulo Acto
- [[mapeamento_paineis_powerbi_santos]] — inventário de painéis PBI Santos com famílias e tabelas
- [[MAPEAMENTO_WORKSPACE_FABRIC]] — IDs de datasets, lakehouses, workspace
- [[SPEC_DRIVE_MIGRACAO_OBRAS]] — spec detalhado de implementação das obras
