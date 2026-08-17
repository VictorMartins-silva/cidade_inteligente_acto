---
title: Relatório Técnico — Arquitetura, Mapeamento e Otimização · Microsoft Fabric
date: 2026-05-20
tags:
  - ferramenta/fabric
  - tipo/referencia
projeto: acto-cidade-inteligente
fonte: documentacao-interna
status: obsoleto
---
# Relatório Técnico: Arquitetura, Mapeamento e Otimização — Microsoft Fabric

Este relatório apresenta uma análise profunda do ambiente Microsoft Fabric, focando na linhagem de dados, tratamentos aplicados, redundâncias de código e propostas de modernização da arquitetura.

---

## 1. Mapeamento de Camadas e Linhagem de Dados

O ambiente utiliza a **Arquitetura Medallion** para organizar o fluxo de dados. Abaixo, o detalhamento de como cada camada é gerada e seus respectivos tipos de saída.

### 1.1. Camada Bronze (Ingestão)
*   **Responsabilidade:** Captura de dados brutos das APIs do Acto Gestão e arquivos auxiliares.
*   **Notebooks:** `nb_ingest_...` (ex: `nb_ingest_caged_santos`, `nb_ingest_acto_gestao_osasco`).
*   **Tipo de Saída:** Arquivos **JSON/Parquet** na pasta `Files` do Lakehouse ou **Delta Tables** brutas.
*   **Tratamento:** Mínimo. Apenas persistência do payload recebido da API para garantir a reprodutibilidade.

### 1.2. Camada Silver (Limpeza e Padronização)
*   **Responsabilidade:** Tipagem, limpeza de nomes de colunas e normalização.
*   **Notebooks:** `nb_silver_...` (ex: `nb_silver_maua_plan_urbano`).
*   **Tipo de Saída:** **Delta Tables** (otimizadas para leitura).
*   **Tratamentos Comuns:**
    *   Remoção de sufixos de ID em nomes de colunas (ex: `Coluna|123` -> `Coluna`).
    *   Conversão de strings ISO8601 para `datetime`.
    *   Aplicação de `bfill` para consolidar colunas duplicadas geradas por diferentes versões de formulários.
    *   Conversão para `snake_case`.

### 1.3. Camada Gold (Negócio e Agregação)
*   **Responsabilidade:** Aplicação de regras de negócio complexas, joins entre domínios e preparação para o Power BI.
*   **Notebooks:** `nb_gold_...` (ex: `nb_gold_acto_gestao_sepref`).
*   **Tipo de Saída:** **Delta Tables** em modo `overwrite` (maioria) ou `append` (incremental).
*   **Tratamentos Específicos:**
    *   Cálculo de prazos e SLAs.
    *   Cruzamento com tabelas auxiliares de bairros e secretarias.
    *   Filtragem de registros de teste.
    *   Renomeação final para nomes amigáveis ao negócio (ex: `os` -> `n_da_solicitacao`).

---

## 2. Análise de Redundâncias e Funções para Globalização

Identificamos uma alta fragmentação de funções utilitárias. Atualmente, existem múltiplos arquivos `nb_utils_...` com códigos idênticos ou levemente divergentes.

### 2.1. Funções Repetidas (Candidatas ao Utils Global)

| Função | Onde está hoje | Proposta |
| :--- | :--- | :--- |
| `import_json_payload` | Mauá, Santos, Osasco, Utils | Mover para `nb_utils_shared` |
| `tratar_nome_colunas` | Mauá, Santos, Utils | Unificar lógica de regex em `nb_utils_shared` |
| `colunas_para_snake_case` | Mauá, Santos, Utils | Padronizar uso de `unicodedata` em `nb_utils_shared` |
| `consolidar_conceito_bfill` | Mauá, Santos | Centralizar para evitar erro de performance (fragmentação) |
| `obter_dados_etapa_atual` | Santos, Mauá | Centralizar chamada de API com tratamento de erro robusto |
| `make_headers` | Todos os Utils | Centralizar gestão de Headers e Tokens |

### 2.2. O Problema dos "Utils" Fragmentados
Existem pelo menos 4 notebooks de utilitários (`nb_utils_ingest_acto_gestao`, `nb_utils_maua_ingest_acto_gestao`, `nb_utils_request_api`, `nb_utils_api_acto_gestao`) que fazem quase a mesma coisa. Isso gera um **risco de manutenção**: se a URL da API do Acto mudar, é necessário alterar 4 arquivos diferentes.

---

## 3. Fluxo de Processo Atual vs. Sugestões de Melhoria

### 3.1. Como o processo acontece hoje
1.  **Gatilho:** Pipelines do Data Factory chamam notebooks de ingestão.
2.  **Autenticação:** Tokens são passados via variáveis de ambiente ou hardcoded em notebooks de config.
3.  **Processamento:** O notebook lê o payload JSON, chama a API, trata os dados em memória (Pandas) e salva como Spark DataFrame.
4.  **Dependência:** Uso extensivo de `%run` para carregar funções utilitárias.

### 3.2. Sugestões de Melhoria Geral (Roadmap de Evolução)

#### A. Centralização de Código (Library Approach)
*   **Ação:** Criar um único `nb_utils_global` ou transformar as funções comuns em um pacote Python (.whl) instalado no ambiente Spark do Fabric.
*   **Benefício:** Redução de 60% no volume de código repetido e facilidade de manutenção.

#### B. Robustez na Ingestão (Resiliência)
*   **Ação:** Implementar **Retries** automáticos nas chamadas de API dentro do Utils Global.
*   **Ação:** Validar o esquema dos dados (Schema Enforcement) na camada Bronze para evitar que mudanças na API quebrem a Gold silenciosamente.

#### C. Migração para Spark Nativo
*   **Ação:** Muitos notebooks usam `toPandas()` e processam dados localmente no driver. Para volumes maiores, isso causará erro de memória (`OOM`).
*   **Sugestão:** Reescrever funções de tratamento (`bfill`, `snake_case`) usando funções nativas do **PySpark** (`pyspark.sql.functions`).

#### D. Gestão de Segredos (Segurança)
*   **Ação:** Remover tokens de notebooks e arquivos de texto.
*   **Sugestão:** Utilizar o **Azure Key Vault** integrado ao Fabric para buscar segredos e tokens de forma segura.

#### E. Monitoramento de Qualidade (Data Quality)
*   **Ação:** Adicionar testes de qualidade (ex: Great Expectations ou simples asserts) entre as camadas Silver e Gold para garantir que o número de linhas não caia drasticamente de um dia para o outro.

---

**Conclusão:** O ambiente está bem estruturado logicamente (Medallion), mas sofre com a **duplicação de esforço técnico**. A centralização das funções de tratamento e a migração gradual para Spark nativo são os passos fundamentais para garantir a escalabilidade do projeto.

---

## Ver Também

- [[_mapa-do-vault]] — índice geral do vault
- [[Conhecimento/Fabric/fabric-workspace-acto-cidade-inteligente|fabric-workspace-acto-cidade-inteligente]] — workspace completo Acto Cidade Inteligente
- [[Conhecimento/Fabric/pipeline-acto-santos-fabric|pipeline-acto-santos-fabric]] — fluxo Data Factory + notebooks
- [[Projetos/acto-santos-pipeline]] — projeto ACTO Santos
