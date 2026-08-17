---
title: Diagnóstico de Painéis — Osasco · Dados Públicos
date: 2026-05-04
tags:
  - municipio/osasco
  - ferramenta/powerbi
  - ferramenta/fabric
  - tema/dados-publicos
  - tipo/dashboard
  - camada/gold
projeto: dados-publicos
fonte: portal-acto-gestao-osasco
status: ativo
---
# 🔍 Diagnóstico de Painéis: Osasco — Dados Públicos

Este documento detalha o mapeamento entre os painéis existentes no portal **Acto Gestão Osasco** (Seção PBI) e as tabelas Gold desenvolvidas no **Lakehouse `lh_dados_publicos`**.

**Data do Diagnóstico:** 04 de Maio de 2026  
**Status do Portal:** Atualizado (Censo 2022 integrado)

---

## 🗺️ Mapeamento de Eixos e Tabelas Gold

### 1. Eixo: Demografia
*   **Dashboard:** Censo Demográfico
*   **Abas Identificadas:** População, Envelhecimento, Educação, Domicílios, Renda per Capita, Fecundidade, Migração.
*   **Mapeamento `lh_dados_publicos`:**
    *   ✅ `gold_censo_piramide_populacao` (Cobre abas População/Gênero)
    *   ✅ `gold_censo_envelhecimento` (Cobre aba Envelhecimento)
    *   ✅ `gold_censo_renda` (Cobre aba Renda per Capita)
    *   ✅ `gold_censo_domicilios` (Cobre aba Domicílios)
    *   ✅ `gold_censo_fecundidade` (Cobre aba Fecundidade)
    *   ✅ `gold_censo_frequenta_escola` (Cobre aba Educação)

### 2. Eixo: Desenvolvimento Econômico
*   **Dashboards:** Empregos Formais (CAGED) e Produto Interno Bruto (PIB).
*   **Indicadores:** Saldo de empregos, admissões por CNAE, evolução do PIB.
*   **Mapeamento `lh_dados_publicos`:**
    *   ✅ `gold_mercado_trabalho` (CAGED + RAIS unificados)
    *   ✅ `gold_pib_municipios` (Evolução histórica do PIB)

### 3. Eixo: Desenvolvimento Humano (CadÚnico)
*   **Dashboard:** Mapas de Vulnerabilidade Social.
*   **Abas:** CadÚnico, Pobreza, Bolsa Família, Vulnerabilidade.
*   **Status no Fabric:** 🔲 **Pendente**. 
*   **Ação Sugerida:** Criar pipeline para ingestão do CadÚnico (MDS) para os 15 municípios.

### 4. Eixo: Segurança Pública & Viária
*   **Dashboards:** Ocorrências de Delitos (SSP-SP) e Ocorrências no Trânsito (InfoSiga).
*   **Status no Fabric:** 🛠️ **Em estruturação** (`nb_seguranca_publica`).
*   **Mapeamento Futuro:** `gold_seguranca_publica_ocorrencias` e `gold_transito_ocorrencias`.

---

## 🚀 Conclusão e Recomendações

1.  **Paridade de Dados:** O projeto `lh_dados_publicos` já possui paridade técnica para os dois eixos mais acessados (Demografia e Economia).
2.  **Diferencial Acto:** Nosso diferencial será a visão **Multi-Município** (Clusters), enquanto o portal atual foca apenas em Osasco isoladamente.
3.  **Próxima Prioridade:** Ingestão de **Segurança Pública (SSP-SP)** para fechar o "Trio de Ferro" de dados públicos (Demografia, Economia, Segurança).

---
*Documento gerado automaticamente para suporte à decisão - Acto Cidade Inteligente.*
