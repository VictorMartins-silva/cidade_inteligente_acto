---
title: Status Report — Entrega Fase 3 · Dados Públicos
date: 2026-05-07
tags:
  - ferramenta/fabric
  - ferramenta/lakehouse
  - tema/dados-publicos
  - tipo/projeto
projeto: dados-publicos
fonte: documentacao-interna
status: ativo
---
# Status Report: Entrega Fase 3 · Dados Públicos
**Data:** 07/05/2026  
**Status:** Concluído (Migração Técnica) | Iniciando (BI/Dashboards)

---

## 🎯 Objetivo Alcançado
Finalização da migração do Lakehouse `lh_dados_publicos` para a arquitetura **Schema-Aware (v3.0)**. Todas as tabelas foram movidas de um namespace flat para a estrutura Medallion segregada por schemas (`bronze`, `silver`, `gold`, `monitoramento`).

## 🚀 Entregas Realizadas (Fase 3.5)

### 📊 Governança e Infraestrutura
- [x] **Arquitetura v3.0**: Migração completa de nomes de tabela para padrão `schema.tabela`.
- [x] **Pipeline de Monitoramento**: Orquestrador automatizado com lógica de dispatch para SIDRA API, BigQuery e FTP.
- [x] **Tabelas Auxiliares (Dimensões)**:
    - `silver.dim_municipio`: Mapeamento de 15 municípios + clusters (Santos, Osasco, Mauá).
    - `silver.dim_calendario`: Dimensão de tempo padronizada para joins de Mercado de Trabalho.

### 📁 Ingestão de Dados
- [x] **SSP (Segurança Pública)**: ✅ 9 tabelas `silver.ssp_*` carregadas (Total: **491.004 linhas**).
- [x] **CAGED (Trabalho)**: ✅ Pipeline automatizado via FTP MTE.
- [x] **RAIS (Trabalho)**: ✅ Extração via BigQuery (Base dos Dados) funcional com credenciais em `Files/`.
- [x] **IBGE (Censo/PIB/Pop)**: ✅ 12 tabelas Gold geradas com os novos clusters de 15 municípios.

## 🔵 Próximos Passos (Semana 12/05)
- [ ] **Direct Lake**: Publicação do modelo semântico oficial no Power BI Service.
- [ ] **Dashboards Osasco**: Criação do `nb_gold_osasco_seguranca_publica` para visões de crimes e produtividade policial.
- [ ] **Validação com Usuário**: Homologação dos números finais via SQL Endpoint.

---
*Relatório gerado automaticamente para Daily Meeting · Projeto Acto Cidade Inteligente*
