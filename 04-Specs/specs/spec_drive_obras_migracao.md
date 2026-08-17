---
title: "Spec Drive — Migração Obras Santos → lh_solicitacoes_acto"
tags:
  - tipo/spec-drive
  - tema/obras
  - tema/migracao
  - tema/santos
status: em-progresso
revisao: "2026-05-19"
---

# Spec Drive — Migração Obras Santos → lh_solicitacoes_acto

> **Objetivo:** Migrar os 3 painéis PBI ativos de Obras (Acomp. Obras/SEMAN, PDR I, SEONT) do lakehouse legado `lh_cidade_inteligente_santos` para o novo `lh_solicitacoes_acto`, recriando toda a lógica de negócio usando o Silver EAV como fonte.
> **Painel Alvará protótipo:** fora de escopo — inacabado, não migrar.
> **Para o plano de implementação passo a passo, ver:** [[SPEC_DRIVE_MIGRACAO_OBRAS]]

---

## Roadmap de Progresso

```
[✅] Fase 0 — Diagnóstico Silver
[🔄] Fase 1 — Gold Acompanhamento
[ ]  Fase 2 — Gold Etapas (PDR I)
[ ]  Fase 3 — Gold SEONT
[ ]  Fase 4 — Pipeline + Reconexão PBI
```

### Status por entregável

| Entregável | Status | Observação |
|---|---|---|
| Silver `santos_obras` confirmado | ✅ Concluído | 11.729 OS / 91.003 etapas / 54.504 campos |
| Schema Silver mapeado | ✅ Concluído | `fato_etapas` 16 col, `fato_solicitacoes` 12 col |
| Valores de status mapeados | ✅ Concluído | EM ATENDIMENTO / FINALIZADA / CANCELADA / PENDENTE |
| `nb_gold_santos_obras_acompanhamento` escrito | ✅ Pronto para deploy | Arquivo local criado em `Acto/nbs/nbs_gold/` |
| Verificar `PMS_AuxiliarPDR.xlsx` no novo LH | ⏳ Próximo passo | `os.path.exists("/lakehouse/default/Files/acto/PMS_AuxiliarPDR.xlsx")` |
| Rodar e validar `gold.obras_acompanhamentos_os` | ⏳ Aguardando deploy | Volumes esperados: ~11.729 OS |
| `nb_gold_santos_obras_etapas` | ⏳ Não iniciado | — |
| `nb_gold_santos_obras_seont` | ⏳ Não iniciado | Depende do acompanhamento |
| RefreshSqlEndpoint + reconexão PBI (3 painéis) | ⏳ Não iniciado | Aguarda Gold completo + validação Kelly |

---

## Dados do Silver Confirmados (2026-05-19)

> [!success] R5 resolvido no novo modelo
> O pipeline legado (`nb_ingest_silver_acto_gestao_obras_santos`) tinha HTTP 401 desde 11/03/2025. O novo módulo usa OAuth2 (`nb_get_token_api`) e **já está funcionando** — o Silver tem mais dados que o legado.

| Tabela | Métrica | Valor | Comparação legado |
|---|---|---|---|
| `silver.fato_etapas` (santos_obras) | OS distintas | **11.729** | ~10.984 no legado |
| `silver.fato_etapas` (santos_obras) | Total etapas | **91.003** | ~71.500 no legado |
| `silver.fato_campos` (santos_obras) | Total campos | **54.504** | — |

### Schema `silver.fato_etapas` (16 colunas)

| Coluna | Tipo | Uso no Gold |
|---|---|---|
| `etapa` | string | → `etapa_atual` |
| `servico` | string | referência |
| `id_os` | string | chave de join |
| `data_criacao` | timestamp | da OS |
| `data_finalizacao` | timestamp | da OS |
| `data_inicio_etapa` | timestamp | → `data_etapa_inicio`, `dias_na_etapa` |
| `data_fim_etapa` | timestamp | → `data_etapa_fim`, `dias_na_etapa` |
| `data_atender_etapa` | timestamp | prazo da etapa |
| `status` | string | **filtro etapa aberta** |
| `executor` | string | → `executor_atual` |
| `origem` | string | controle interno |
| `data_carga` | timestamp | controle interno |
| `fonte` | string | filtro = 'santos_obras' |
| `municipio` | string | Santos |
| `secretaria` | string | OBRAS |
| `unidade_organizacional` | string | OBRAS |

### Schema `silver.fato_solicitacoes` (12 colunas)

| Coluna | Uso no Gold |
|---|---|
| `id_os` | chave primária = `n_da_solicitacao` |
| `servico` | → `servico` |
| `status_fluxo` | → `status` |
| `data_criacao` | → `data_criacao` |
| `data_finalizacao` | → `data_finalizacao` |
| `solicitante` | → `solicitante` |
| `origem`, `data_carga`, `fonte`, `municipio`, `secretaria`, `unidade_organizacional` | controle interno |

### Status de etapas em `silver.fato_etapas`

| Status | Contagem | Interpretação |
|---|---|---|
| `EM ATENDIMENTO` | 43.933 | Etapa **aberta** |
| `FINALIZADA` | 41.574 | Etapa fechada |
| `CANCELADA` | 3.700 | Etapa cancelada |
| `PENDENTE` | 1.796 | Etapa **aberta** |

> [!note] Lógica de etapa aberta
> `status IN ('EM ATENDIMENTO', 'PENDENTE')` → etapa ativa
> OS sem etapa ativa → usar última etapa `FINALIZADA` ou `CANCELADA` por `data_fim_etapa DESC`

---

## Painéis PBI de Obras (4 arquivos)

| Arquivo PBI | Tabela Legacy | Nova Tabela | Status |
|---|---|---|---|
| `pbi_obras_santos_acomp_solicitacoes` | `gold_pdr_acompanhamentos_os` | `gold.obras_acompanhamentos_os` | 🔴 Parado desde 11/03/2025 |
| `pbi_obras_santos_seman_acomp` | `gold_pdr_acompanhamentos_os` | `gold.obras_acompanhamentos_os` | 🔴 Parado desde 11/03/2025 |
| `pbi_obras_santos_pdr` | `gold_obras_tempo_etapa` | `gold.obras_tempo_etapa` | 🔴 Parado desde 11/03/2025 |
| `pbi_santos_obras_seont_os` | `gold_obras_seont_os` | `gold.obras_seont_os` | 🔴 Parado desde 11/03/2025 |
| `acomp_alvara_obras_santos_prototipo` | — | — | ⚫ Inacabado — fora de escopo |

---

## Tabelas Legacy — Schema de Referência

### `gold_pdr_acompanhamentos_os` (~11.303 registros, 18 colunas)

| Coluna | Tipo | Fonte no novo modelo |
|---|---|---|
| `n_da_solicitacao` | Int64 | `fato_solicitacoes.id_os` |
| `servico` | string | `fato_solicitacoes.servico` |
| `status` | string | `fato_solicitacoes.status_fluxo` |
| `data_criacao` | timestamp | `fato_solicitacoes.data_criacao` |
| `data_finalizacao` | timestamp | `fato_solicitacoes.data_finalizacao` |
| `solicitante` | string | `fato_solicitacoes.solicitante` |
| `titulo_profissional` | string | `fato_campos` pivot `Titulo_Profissional_PF/PJ` |
| `etapa_atual` | string | `fato_etapas` filtro status aberto, `data_inicio DESC` |
| `executor_atual` | string | `fato_etapas.executor` da etapa atual |
| `flag_multiplas_etapas` | int | count(etapas abertas por OS) > 1 |
| `aux_setor_responsavel` | string | `PMS_AuxiliarPDR.xlsx` sheet `Etapas` |
| `data_etapa_inicio` | timestamp | `fato_etapas.data_inicio_etapa` |
| `data_etapa_fim` | timestamp | `fato_etapas.data_fim_etapa` |
| `tempo_execucao` | string | ⚠️ não encontrado no Silver ainda |
| `dias_na_etapa` | float | calculado: aberta=hoje-inicio, fechada=fim-inicio |
| `zona` | string | `PMS_AuxiliarPDR.xlsx` sheet `Zona_Bairros` |
| `bairro_consolidado` | string | `fato_campos` pivot `Bairro` + normalização |
| `zona_aplicavel` | int | 1 por padrão — ajustar com Kelly/DECONTE |

### `gold_obras_tempo_etapa` (~71.500 registros → novo: ~91.003 etapas)

| Coluna | Tipo | Fonte no novo modelo |
|---|---|---|
| `os` | string | `fato_etapas.id_os` |
| `etapa` | string | `fato_etapas.etapa` |
| `servico` | string | `fato_etapas.servico` |
| `data_criacao_os` | timestamp | `fato_etapas.data_criacao` |
| `data_inicio_etapa` | timestamp | `fato_etapas.data_inicio_etapa` |
| `data_atendimento_etapa` | timestamp | `fato_etapas.data_atender_etapa` |
| `data_fim_etapa` | timestamp | `fato_etapas.data_fim_etapa` |
| `data_finalizacao_os` | timestamp | `fato_etapas.data_finalizacao` |
| `tempo_execucao` | string | ⚠️ não encontrado no Silver ainda |
| `status` | string | `fato_etapas.status` |
| `executor` | string | `fato_etapas.executor` |
| `duracao_dias_preciso` | float | `datediff(data_fim_etapa, data_inicio_etapa)` |
| `duracao_dias_int` | int | cast(duracao_dias_preciso) |
| `aux_setor_responsavel` | string | `PMS_AuxiliarPDR.xlsx` sheet `Etapas` |
| `aux_pdr` | string | `PMS_AuxiliarPDR.xlsx` sheet `Etapas` (~10%) |

### `gold_obras_seont_os` (~263 registros, 22 colunas)

Subconjunto de `obras_acompanhamentos_os` com `flag_seont = 1`, acrescido de:

| Coluna adicional | Origem |
|---|---|
| `analista_responsavel` | `fato_campos` pivot campo `Esta solicitação deverá ser analisada por:` (~3.4% preenchido) |
| `executor_responsavel` | SEONT com executor → `executor_atual`; sem executor → `analista_responsavel` |
| `flag_seont` | `aux_setor_responsavel` IN {SEONT, SEONT-Chefia, SEONT-Chefia (D.O), SEONT CHEFIA} |
| `flag_etapa_aprov` | `etapa_atual` IN conjunto de 28 nomes de etapas de aprovação/conclusão |

---

## Pendências e Perguntas em Aberto

> [!warning] `tempo_execucao` — origem desconhecida
> A coluna `tempo_execucao` existe nas tabelas legacy mas não está em `fato_solicitacoes` nem em `fato_etapas`. Pode estar em `fato_campos` (EAV). Investigar:
> ```sql
> SELECT DISTINCT campo FROM silver.fato_campos
> WHERE fonte = 'santos_obras'
> AND lower(campo) LIKE '%execucao%' OR lower(campo) LIKE '%execução%'
> ```

> [!todo] Confirmar com Kelly/DECONTE
> - Serviços SEMAN (Licença Prévia, Instalação, Operação, Manifestação Técnica Ambiental)
> - Serviços com `zona_aplicavel = 0`
> - Se o painel PDR I usa `tempo_execucao` em medidas DAX

---

## Ferramentas de Diagnóstico

### Script SQL local

`Acto/explorar_schema_sql.py` — conecta ao SQL endpoint do `lh_solicitacoes_acto` via ODBC e lista colunas de todas as tabelas `bronze/silver/gold/dbo`.

```
Server: ena6obg6j2cevcppw7dn7yu57a-knnp5frchjbujdik4l3nmgrgsa.datawarehouse.fabric.microsoft.com
Database: lh_solicitacoes_acto
Auth: Azure AD Interactive (abre browser MFA)
```

---

## Referências

- [[SPEC_DRIVE_MIGRACAO_OBRAS]] — plano de implementação passo a passo (8 blocos) — **versão mais atual**
- [[f5_obras_pdr]] — documentação de negócio dos painéis F5 (Obras/PDR I)
- [[SPEC_DRIVE_ROADMAP_MIGRACAO]] — roadmap geral da migração Santos
- [[ESP_DRIVE_OS_MULTIPLAS_ETAPAS]] — análise do bug de múltiplas etapas
