---
title: Guia Mestre — Framework de Dados Públicos (Microsoft Fabric)
date: 2026-05-05
tags:
  - ferramenta/fabric
  - ferramenta/lakehouse
  - tema/dados-publicos
  - tipo/referencia
  - camada/bronze
  - camada/silver
  - camada/gold
projeto: dados-publicos
fonte: documentacao-interna
status: ativo
---
# 🗺️ Guia Mestre: Framework de Dados Públicos (Microsoft Fabric)

Este documento é a **Fonte Única de Verdade (Soberano)** para o ecossistema de dados públicos brasileiros no projeto **Acto Cidade Inteligente**. Ele consolida toda a arquitetura, governança, matriz de clusters e inventário técnico.

**Última Atualização:** 2026-05-05
**Versão:** 3.0 (Migração Lakehouse com Schemas)
**Status Geral:** ==Fase 3 ✅ Concluída · Fase 3.5 🔵 Migração em andamento==

---

## 🏛️ Governança e Escopo Territorial (05/05)

O projeto usa **15 municípios** organizados em 3 clusters com papéis distintos:

| Papel | Municípios | Dados |
|---|---|---|
| **Clientes Core** | Santos · Osasco · Mauá | Completos, todas as camadas, todos os domínios |
| **Benchmarks** | 12 municípios de porte similar por cluster | Dados agregados — usados apenas para comparação nos dashboards (ranking, evolução) |

**Origem da lista:** `CLUSTERS` dict em `nb_utils_ibge` — única fonte de verdade. Área territorial ingerida dinamicamente via SIDRA t/1301 (`ingest_area_territorial()`), sem hardcode.

**Controle de Volume:** Dados agregados para os 15 municípios representam <1% do Lakehouse total.

---

## 🏗️ Arquitetura — Lakehouse com Schemas (a partir de 05/05)

O `lh_dados_publicos` foi recriado com suporte a schemas habilitado. Convenção: `schema.nome` — sem prefixo de camada no nome da tabela.

```
bronze.ibge_populacao     bronze.ibge_pib     bronze.ibge_cempre
bronze.rais               bronze.caged

silver.populacao          silver.pib          silver.cempre
silver.rais               silver.caged        silver.censo_*

gold.populacao            gold.pib            gold.mercado_trabalho
gold.censo_*              (12 tabelas)
```

---

## 1. Dicionário de Ingestão (Notebooks & Tabelas)

### 📊 Domínio: Censo Demográfico 2022
| Notebook | Tabela de Saída | Fonte (ID Sidra) | Parâmetros / Variáveis |
| :--- | :--- | :--- | :--- |
| `nb_ingest_censo_ibge` | `silver_censo_piramide_2022` | SIDRA t/9514 | População por idade e sexo |
| `nb_ingest_censo_ibge` | `silver_censo_envelhecimento` | SIDRA t/9756 | Índice de envelhecimento por cor/raça |
| `nb_ingest_censo_ibge` | `silver_censo_pop_00_10` | SIDRA t/1552 | Histórico populacional (2000, 2010) |
| `nb_ingest_censo_ibge` | `silver_censo_frequencia_escola`| SIDRA t/10058| Frequência escolar 6 a 17 anos |
| `nb_ingest_censo_ibge` | `silver_censo_renda_2022` | SIDRA t/10296 | Rendimento nominal mensal per capita |
| `nb_ingest_censo_ibge` | `silver_censo_fecundidade` | SIDRA t/10076 | Média de filhos por mulher e idade |
| `nb_ingest_censo_paridade`| `gold_censo_alfabetizacao` | SIDRA t/9541 | Alfabetização por sexo e cor/raça |
| `nb_ingest_censo_paridade`| `gold_censo_urbana_rural`  | SIDRA t/9605 | População por situação de domicílio |
| `nb_ingest_censo_paridade`| `gold_censo_migracao`     | SIDRA t/9843 | Naturalidade (Estado de Nascimento) |
| `nb_gold_censo_demografico`| `gold_censo_piramide_populacao`| Silver Censo | Agrupamento Ativo/Inativo e % Gênero |
| `nb_gold_censo_demografico`| `gold_censo_renda` | Silver Censo | Comparativo 2010 vs 2022 |

### 💼 Domínio: Mercado de Trabalho
| Notebook | Tabela de Saída | Fonte | Parâmetros |
| :--- | :--- | :--- | :--- |
| `nb_ingest_rais_bigquery` | `silver_rais` | BigQuery (BD) | Microdados RAIS unificados por Cluster |
| `nb_ingest_caged` | `silver_caged` | FTP MTE | Movimentação mensal (Admissões/Desligamentos) |
| `nb_gold_mercado_trabalho`| `gold_mercado_trabalho`| Unificação RAIS/CAGED| Vínculos ativos, CNAE e Tamanho Estab. |

---

## 2. Arquitetura e Governança de Dados

### Padrão de Nomenclatura
- **Colunas:** Todas convertidas para `snake_case` via `nb_utils_ibge`. Caracteres especiais e acentos removidos para compatibilidade com Delta Lake e SQL Endpoint.
- **Tabelas:** Prefixo `silver_` para dados limpos e `gold_` para dados prontos para BI.

### Otimização Fabric (Direct Lake)
Todas as tabelas são salvas no formato **Delta** com a opção `overwriteSchema = true`. A camada Gold é otimizada para conectividade Direct Lake, permitindo que o Power BI acesse os dados sem necessidade de atualização (Import) ou latência de DirectQuery.

---

## 3. Matriz de Clusters (15 Municípios)

O framework processa dinamicamente 3 clusters estratégicos:
- **SANTOS:** Santos, São Vicente, Praia Grande, Guarujá, Cubatão.
- **OSASCO:** Osasco, Taboão da Serra, Suzano, Mogi das Cruzes, Várzea Paulista, São Caetano do Sul.
- **MAUÁ:** Mauá, Carapicuíba, Itapevi, Ribeirão Pires.

---

## 4. Protocolo de Validação de Dados (Auditoria)

Utilizamos o notebook `nb_validacao_dados` via **SQL Analytics Endpoint** para garantir a consistência:
1. **Contagem de Municípios:** Mínimo de 15 municípios distintos em todas as tabelas Gold.
2. **Casting de Valor:** Limpeza de caracteres IBGE (`-`, `...`) via `TRY_CAST`.
3. **Cruzamento Demográfico-Econômico:**
   - **Indicador:** `% Formalização` = (Empregos Formais / População Total) * 100.
   - **Referência:** São Caetano do Sul (~69%) vs Carapicuíba (~10%).

---

## 5. Próximos Passos (Fase 4)

- [ ] Criação do Modelo Semântico Direct Lake unificado.
- [ ] Desenvolvimento do Dashboard Executivo (Aba Demográfica + Aba Econômica).
- [ ] Automação do calendário de atualização do Novo CAGED (Yuri).

## Relacionados

- [[Documentação_Fabric/Dados Públicos/00_INDEX_DADOS_PUBLICOS|Índice Dados Públicos]]
- [[Documentação_Fabric/Dados Públicos/pendencias_projeto_dados_publicos|Pendências do Projeto]]
- [[Documentação_Fabric/Dados Públicos/Mapeamento_Tecnico_Dados_Publicos|Mapeamento Técnico]]
