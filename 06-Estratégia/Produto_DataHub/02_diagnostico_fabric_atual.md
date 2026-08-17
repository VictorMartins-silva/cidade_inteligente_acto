---
tags: [produto, datahub, fabric, diagnostico]
criado: 2026-07-03
status: fotografia-03-07-2026
---

# 02 · Diagnóstico do Fabric Atual

⬅️ [[01_visao_produto_modelo_negocio]] · Próximo: [[03_arquitetura_alvo]]

> [!warning] Resumo executivo
> A fundação técnica (medallion, módulo Acto EAV parametrizado, schema Silver canônico de dados públicos, Direct Lake) **já é adequada para produto**. O gap está em **engenharia de plataforma** — segredos, ambientes, CI/CD, qualidade contratual, catálogo, multi-tenant — e na **dívida operacional do legado** (R5, R9, R1) que consome capacidade do time.

## 1. Inventário (auditoria 01/05/2026 + docs)

**Workspace único:** `Acto Cidade Inteligente` (ID `96fe5a53-3a22-4443-8d0a-e2f6d61a2690`), capacidade Diamante, Brazil South.

| Lakehouse | Status |
|---|---|
| `lh_solicitacoes_acto` | 🟢 Novo modelo unificado (EAV) — sem semantic model ainda |
| `lh_cidade_inteligente_santos` | 🟡 Legado em uso; semantic model de 07/2025 |
| `lh_cidade_inteligente_osasco` | 🟡 Legado; semantic model desatualizado desde 04/2025 |
| `lh_cidade_inteligente_maua` | 🟡 Legado, sem semantic model |
| `lh_dados_publicos` | 🟢 Ativo, com schemas `bronze.`/`silver.`/`gold.` |

**Volumetria:** ~72 notebooks (37 Santos legado, 31 Osasco, 4 Mauá, 11 Acto novo, ~6 dados públicos + utils), ~11+ pipelines, 3 semantic models, ~21+ relatórios PBI.

**Fontes:** Acto API (4 tenants, OAuth2 JWT), IBGE/SIDRA (população, PIB, CEMPRE, Censo 2022), RAIS via BigQuery/basedosdados, CAGED via FTP MTE, SSP-SP, CSVs manuais (carta de serviços, Infosiga). Em prospecção: DATASUS (CNES/SIM/SINASC/SIH) + Censo Escolar/IDEB — rota BigQuery decidida 02/07, aguardando validação do Yuri.

## 2. Sintomas de desorganização

### Duas gerações de arquitetura convivendo
Legado por município (notebook por fonte) × novo modelo Acto EAV parametrizado (`nb_bronze_orquestracao` em loop sobre 11 fontes). Migração Santos → `lh_solicitacoes_acto` em andamento; painéis de Obras ainda apontam para o LH legado.

### Riscos ativos

| ID | Risco | Status |
|---|---|---|
| **R5** 🔴 | HTTP 401 em obras Santos desde 11/03 — cadeia inteira parada (Gold obras, etapas, SEONT, 4 PBI) | ATIVO |
| **R9** 🔴 | `nb_ingest_caged_santos` com código de Osasco hardcoded | ATIVO, bloqueado |
| **R1** 🟠 | Excel/CSV como fontes (tb_aux.xlsx, PMS_AuxiliarPDR.xlsx) — SPOF | ATIVO |
| **R7** 🟠 | Utils de ingestão sem try/except — falhas silenciosas | ATIVO |
| **R2/R3/R4** 🟡 | Funções duplicadas; overwrite×append dessincronizando IDs; escrita sem assert | ATIVOS |
| **R6/R8** | Payloads conflitantes + credenciais pessoais em texto claro; usuários de teste hardcoded | ATIVOS |

> [!danger] Credenciais hardcoded
> Tokens no `utils/config_api_acto`; credencial GCP (`bd2024-444413-*.json`) em `Files/` e no repositório local; credencial pessoal em texto claro no orquestrador Bronze. **Bloqueio absoluto para onboarding de cliente novo.** Sem Key Vault.

### Outros sintomas
- **Notebooks sem pipeline** (execução manual): seont_os, estrutura_cet, dim_date, tb_aux, avaliacao_sentimento. Agendamentos de 8/9 pipelines Santos desconhecidos.
- **Nomenclatura inconsistente:** `gold_curso_motorista` sem prefixo; prefixo no nome × schemas; convenção nova `gold.santos_*` ainda não universal.
- **Observabilidade zero:** o R5 ficou >60 dias sem detecção; `pl_ingest_acto` com `retry: 0`; semantic model Osasco desatualizado há >1 ano sem alarme.
- **Catálogo manual:** inventário vive em Markdown mantido à mão — a própria numeração dos riscos diverge entre documentos.
- **Itens órfãos:** `gestao_paineis` sem documentação, `gold_bpc_osasco` comentado, `silver_nova_caged_sp` sem dono confirmado.

## 3. O que já funciona e é base do produto

1. **Medallion consistente** Bronze→Silver→Gold, lógica de negócio no Gold (DAX mínimo).
2. **Módulo Acto EAV parametrizado** — o ativo mais produtizável: 3 fatos normalizados, 1 notebook Bronze genérico + payload JSON por fonte; adicionar fonte = 1 JSON, sem código novo; pipeline roda 11 fontes em ~10 min.
3. **Schema padrão Silver de dados públicos** (`id_municipio · nome_municipio · ano · indicador · valor`) — contrato de dados de facto, replicado em população/PIB/CEMPRE.
4. **Clusters centralizados** em `nb_utils_ibge` — fonte única de verdade dos 15 municípios.
5. **Direct Lake + SQL Endpoint** como padrão de consumo, com `Gold → RefreshSqlEndpoint → Refresh PBI` uniforme.
6. **Token OAuth2 automatizado** (`nb_get_token_api`) — resolve a classe de falha do R5 no módulo novo.
7. **SCD Type 2 de vigência de prazos** (carta de serviços/SLA) — padrão documentado e reutilizável.
8. **Método de trabalho:** specs por entrega, protocolo de validação, levantamento estruturado de fontes novas (modelo `dados_saude_educacao/ref/`).

## 4. Lacunas para produto multi-cliente

| # | Lacuna | Consequência hoje |
|---|---|---|
| 1 | **Multi-tenancy** — 1 workspace, lakehouses misturando clientes | Sem isolamento de acesso/custo; dados de Osasco visíveis a quem opera Santos |
| 2 | **Gestão de segredos** — sem Key Vault | Bloqueio de onboarding; risco de vazamento |
| 3 | **Contratos de dados + qualidade** — asserts ad-hoc | R5 sem detecção por 60+ dias; sem freshness/schema checks |
| 4 | **Ambientes e CI/CD** — deploy manual, sem git no workspace, sem dev/prod | Teste estrutural roda em produção |
| 5 | **Catálogo/lineage** — Markdown manual | Divergência entre docs; ownership informal |
| 6 | **Configuração por cliente** — códigos IBGE, bairros e prazos em Excel/hardcode | O R9 é consequência direta |
| 7 | **Kit de onboarding de município** — inexistente | Aparecida/SJRP parados |

---
Fontes: `MAPEAMENTO_WORKSPACE_FABRIC.md`, `Referencia_Tecnica_Fabric_Santos_v2_0.md`, `fabric_santos_nbs_analise.md`, `ARQUITETURA_E_PADROES.md`, `GOVERNANCA_E_MANUTENCAO.md`, `GUIA_MESTRE_DADOS_PUBLICOS.md`, `GUIA_MESTRE_COPILOT.md`, CLAUDE.md do projeto.
