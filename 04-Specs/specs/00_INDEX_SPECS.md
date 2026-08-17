---
title: "Índice de Specs — Acto Cidade Inteligente"
tags:
  - tipo/indice
  - tipo/spec
status: ativo
revisao: "2026-07-21"
---

# Índice de Specs — Acto Cidade Inteligente

> Todos os specs e planos de implementação do projeto estão aqui. Specs novos vão direto nesta pasta.

---

## Migração Santos → lh_solicitacoes_acto

| Spec | Escopo | Status |
|---|---|---|
| [[spec_drive_roadmap_migracao]] | Roadmap geral — 9 domínios Santos + Osasco | ✅ Ativo |
| [[spec_drive_obras_migracao]] | Diagnóstico Silver + schema de referência legado→novo | 🔄 Em progresso |
| [[spec_drive_migracao_obras]] | Plano de implementação passo a passo (8 blocos) | ✅ Ativo — **versão mais atual** |
| [[spec_drive_paridade_gold_obras]] | Paridade Gold Obras EAV × legado — bugs corrigidos, regressões, painéis PBI | 🔄 Em progresso — **spec ativo desde 07/07 · revisão 17/07** · gap SEONT parcial (24 OS pendentes de decisão de negócio), comunicação a Kelly/Jorge bloqueada |

> [!tip] Qual spec de Obras usar?
> **[[spec_drive_obras_migracao]]** — diagnóstico técnico, schema da tabela legada, volumes, perguntas em aberto  
> **[[spec_drive_migracao_obras]]** — checklist de implementação passo a passo, código, ordem de execução

---

## Migração Osasco → lh_dados_publicos

| Spec | Escopo | Status |
|---|---|---|
| [[spec_drive_migracao_osasco_lh_dados_publicos]] | 6 painéis Osasco → lh_dados_publicos | 🔄 Em progresso |

---

## Novas Fontes — Saúde e Educação

| Spec | Escopo | Status |
|---|---|---|
| [[spec_drive_datasus_censo_ideb]] | Mapeamento CNES/SIM/SINASC/SIH (DATASUS) + Censo Escolar/IDEB (INEP) → lh_dados_publicos — ver [[Documentação_Fabric/Dados Públicos/Saude_Educacao/00_INDEX_SAUDE_EDUCACAO\|documentação técnica completa]] | 🔵 Pesquisa e mapeamento consolidado concluídos · validação com Yuri pendente |

---

## Painéis BI — Novos Pedidos (OS Formais)

| Spec | OS | Cliente | Status |
|---|---|---|---|
| [[SPEC_DRIVE_PAINEL_APROVACOES_OBRAS]] | #962592 (Kelly) | PM Santos – Aprova Santos | 🔄 Protótipo criado · validação pendente |
| [[SPEC_DRIVE_MAUA_MEIO_AMBIENTE_BI]] | #971002 (Renan) | PM Mauá – Meio Ambiente | 🔵 Levantamento de requisitos |
| [[spec_painel_semam_analista_tecnico]] | #974214 | PM Santos – SEMAM Licenças | ✅ Gold ✅ · PBI ✅ publicado · pipeline pendente |
| [[spec_painel_seont_analista_tecnico]] | #974214 | PM Santos – SEONT Obras | 🔴 Gold ✅ (846 OS · 7 etapas) · PBI em retrabalho de layout (reunião 21/07) · pipeline pendente |
| [[spec_mapa_geo_violencia_mulher_osasco]] | — | PM Osasco – Violência Mulher | 🔵 Nova frente · point-in-polygon + Azure Maps |
| [[spec_arquitetura_geo_osasco]] | — | PM Osasco – Todos os mapas | 🔵 Arquitetura aprovada · 8 tabelas SSP + utilitário geo |
| [[spec_painel_osasco_visita_domiciliar]] | — | PM Osasco – NPCAD/SAS | 🟢 Pipeline EAV completo (payload→bronze→silver→gold) ✅ · painel PBI pendente |

---

## Sprints Semanais

| Spec | Escopo | Status |
|---|---|---|
| [[spec_drive_semana_20_07_2026]] | **Semana atual** — Fechamento paridade Gold Obras (Kelly/Jorge) · Retomada Geo Osasco parado · Painel Visita Domiciliar Osasco | 🔄 Em andamento |
| [[spec_drive_semana_13_07_2026]] | Semana anterior — planejava fechar Geo Osasco, mas o foco real migrou para bug crítico de payload em Obras Santos (ver [[spec_drive_paridade_gold_obras]] Bloco 6) | ⚠️ Divergiu do plano — Geo Osasco não avançou |
| [[spec_drive_semana_06_07_2026]] | Semana anterior — Osasco Geo · SEONT Analistas · SEMAM Pareceres · SEMAM Analistas · Migração PBI Santos | ✅ Concluído |
| [[spec_drive_semana_29_06_2026]] | Semana anterior — Fix SEONT Chefias · PBI SEONT Analistas · Integração pipeline · SEMAM Pareceres · Migração PBI Santos | ✅ Concluído |
| [[spec_drive_semana_22_06_2026]] | Semana 22/06 — SEMAM Pareceres · SEONT+SEMAM Analistas Gold | ✅ Concluído |
| [[spec_drive_semana_15_06_2026]] | Semana 15/06 — Violência Mulher · Mapas Osasco · SEMAM Pareceres Gold | ✅ Concluído |
| [[spec_drive_semana_08_06_2026]] | Semana 08/06 — Violência Mulher · OS #962592 · OS #971002 · Cluster Osasco | ✅ Concluído |
| [[spec_drive_semana_25_05_2026]] | Semana 25/05 — Migração Obras Santos + Novo Painel | ✅ Concluído |
| [[spec_drive_semana_11_05_2026]] | Semana 11/05 — BI Osasco + SSP Geo | ✅ Concluído |
| [[spec_drive_semana_04_05_2026]] | Semana 04/05 — Schemas + Monitoramento | ✅ Concluído |

---

## Dados Públicos — Roadmap

| Spec | Escopo | Status |
|---|---|---|
| [[spec_drive_dados_publicos]] | Roadmap mestre IBGE/SIDRA (Fases 1–4) | 🔄 Em progresso |

---

## Análise e Investigação

| Spec | Escopo | Status |
|---|---|---|
| [[esp_drive_os_multiplas_etapas]] | Bug OS com múltiplas etapas abertas simultâneas — análise e solução | ✅ Concluído |
| [[spec_paineis_indicadores_melhorias]] | 10 melhorias no módulo de Painéis de Indicadores do Acto Web | ⚠️ Validação parcial |

---

## Governança

| Spec | Escopo | Status |
|---|---|---|
| [[spec_drive_documentacao]] | Padrões de documentação unificada — regras de governança | ✅ Ativo |

---

## Como usar esta pasta

- **Spec novo** → criar diretamente em `specs/` com frontmatter `tipo/spec-drive`
- **Spec de sprint semanal** → nomear `spec_drive_semana_DD_MM_AAAA.md`
- **Spec de migração** → nomear `spec_drive_migracao_{dominio}.md`
- **Spec de análise** → nomear `esp_drive_{tema}.md` ou `spec_{tema}.md`

---

## Referências rápidas

- [[00_MAPA]] — hub central de navegação do vault
- [[spec_drive_roadmap_migracao]] — estado atual da migração Santos (onde estamos agora)
- [[paineis_negocio/00_indice_paineis|00_indice_paineis]] — documentação de negócio dos painéis
