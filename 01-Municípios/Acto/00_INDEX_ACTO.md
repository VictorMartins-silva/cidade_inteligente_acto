---
title: Índice Acto — Plataforma
tags: ["tipo/indice", "ferramenta/fabric"]
aliases: ["acto", "index acto", "plataforma acto"]
description: "Índice de notebooks da plataforma Acto Cidade Inteligente"
status: "ativo"
---
# Acto — Documentação da Plataforma

> [[Documentação_Fabric/00_MAPA|00_MAPA Fabric]] | [[_mapa-do-vault]]

---

## Documentação

- [[Documentação_Fabric/Acto/GUIA_DIARIO_ACTO|GUIA_DIARIO_ACTO]] — resumo de uso diário e validação rápida
- [[Documentação_Fabric/Acto/GUIA_POR_ONDE_COMECAR_ACTO|GUIA_POR_ONDE_COMECAR_ACTO]] — ordem recomendada de leitura
- [[Documentação_Fabric/Acto/DOCUMENTACAO_UNICA_ACTO|DOCUMENTACAO_UNICA_ACTO]] — visão canônica do módulo e da migração Santos
- [[Documentação_Fabric/Acto/CHECKLIST_INICIO_MIGRACAO_CET_SEPREF|CHECKLIST_INICIO_MIGRACAO_CET_SEPREF]] — início operacional da migração (onda CET/SEPREF)
- [[Documentação_Fabric/Acto/PLANO_GOLD_CET_SEPREF_PRAZO_UNIDADE_EXECUTORA|PLANO_GOLD_CET_SEPREF_PRAZO_UNIDADE_EXECUTORA]] — plano técnico para inclusão de prazo e unidade executora
- [[Documentação_Fabric/Acto/DOCUMENTACAO_TECNICA_ACTO|DOCUMENTACAO_TECNICA_ACTO]]
- [[Documentação_Fabric/Acto/DOCUMENTACAO_NEGOCIO_ACTO|DOCUMENTACAO_NEGOCIO_ACTO]]
- [[Documentação_Fabric/Acto/DIAGRAMAS_ACTO|DIAGRAMAS_ACTO]]
- [[Documentação_Fabric/Acto/MAPEAMENTO_WORKSPACE_FABRIC|MAPEAMENTO_WORKSPACE_FABRIC]]
- [[Documentação_Fabric/Acto/SCHEMA_LAKEHOUSE_ACTO|Schema Lakehouse Acto]] — 60 tabelas (48 Bronze · 3 Silver · 9 Gold) · atualizado 09/06/2026
- [[Documentação_Fabric/Acto/EAV_BRONZE_INVENTARIO|Inventário Bronze EAV]] — volumes, campos, NULLs e padrão de payload verificados 09/06/2026
- [[Documentação_Fabric/Acto/spec_paineis_indicadores_melhorias|Spec — Melhorias Painéis de Indicadores]] — publicação/pesquisa/layout/navegação (10 itens)
- [[Documentação_Fabric/Acto/INVESTIGACAO_BUG_SANTOS_OBRAS_PAYLOAD_API|Investigação — Bug santos_obras (payload + API)]] — postmortem: KeyError id_os + campos de formulário órfãos no payload + nome de campo EAV inconsistente entre execuções da API. Resolvido e validado em produção 15/07/2026

---

## Notebooks da Plataforma Acto

| Notebook | Função |
|---|---|
| [[Documentação_Fabric/Acto/nb_get_token_api.ipynb|nb_get_token_api]] | Obtenção de token de autenticação |
| [[Documentação_Fabric/Acto/nbs/nbs_bronze/nb_bronze_acto_gestao.ipynb|nb_bronze_acto_gestao]] | Ingestão Bronze |
| [[Documentação_Fabric/Acto/nbs/nbs_bronze/nb_bronze_orquestracao.ipynb|nb_bronze_orquestracao]] | Orquestração Bronze |
| [[Documentação_Fabric/Acto/nbs/nbs_silver/nb_silver_acto_gestao.ipynb|nb_silver_acto_gestao]] | Tratamento Silver |
| [[Documentação_Fabric/Acto/utils/nb_utils_request_api|nb_utils_request_api]] | Utils de requisição |
| [[Documentação_Fabric/Acto/nbs/utils/nb_utils_teste_token.ipynb|nb_utils_teste_token]] | Teste de token |

### Gold (por domínio)
- [[Documentação_Fabric/Acto/nbs/nbs_gold/nb_gold_santos_cet.ipynb|nb_gold_santos_cet]]
- [[Documentação_Fabric/Acto/nbs/nbs_gold/nb_gold_santos_sepref.ipynb|nb_gold_santos_sepref]]
- [[Documentação_Fabric/Acto/nbs/nbs_gold/nb_gold_osasco_atendimento_cras.ipynb|nb_gold_osasco_atendimento_cras]]
- [[Documentação_Fabric/Acto/nbs/nbs_gold/nb_gold_osasco_atendimento_trabalhador.ipynb|nb_gold_osasco_atendimento_trabalhador]]
- [[Documentação_Fabric/Acto/nbs/nbs_gold/_nb_gold_orquestracao.ipynb|_nb_gold_orquestracao]]

---

## Screenshots

- [[Documentação_Fabric/Acto/Captura de tela 2026-05-01 140844.png|Captura de tela 140844]] — 2026-05-01
- [[Documentação_Fabric/Acto/pipelines/Captura de tela 2026-05-01 141200.png|Captura de tela 141200]] — pipelines
