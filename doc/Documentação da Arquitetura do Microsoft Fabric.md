---
title: Documentação da Arquitetura do Microsoft Fabric
date: 2026-04-30
tags:
  - ferramenta/fabric
  - ferramenta/lakehouse
  - tipo/referencia
projeto: acto-cidade-inteligente
fonte: documentacao-interna
status: ativo
---
# Documentação da Arquitetura do Microsoft Fabric
**Data:** Abril de 2026

## 1. Visão Geral do Ambiente Microsoft Fabric

O ambiente Microsoft Fabric da Acto Cidade Inteligente é uma plataforma unificada de dados e análises, projetada para gerenciar e processar informações de múltiplos municípios. Ele opera sob uma capacidade **Diamante** e está hospedado na região **Brazil South**. O Workspace ID principal é `96fe5a53-3a22-4443-8d0a-e2f6d61a2690`, servindo como o hub central para todos os projetos de dados [^1].

A arquitetura de dados adota o padrão **Medallion**, que organiza os dados em camadas lógicas para garantir qualidade, governança e otimização para consumo. Este padrão é implementado em um Lakehouse, que atua como o repositório central de dados [^2].

### Fluxo Geral da Arquitetura Medallion

```mermaid
graph TD
    A[Fontes de Dados: APIs (Acto), FTP, CSVs] --> B(Data Factory: Ingestão)
    B --> C{Camada Bronze: Dados Brutos (Delta Tables)}
    C --> D{Camada Silver: Dados Limpos e Transformados (Delta Tables)}
    D --> E{Camada Gold: Dados Agregados e Otimizados (Delta Tables)}
    E --> F[Power BI: Relatórios e Dashboards]
```

## 2. Estrutura de Pastas e Organização do Workspace

O workspace é organizado hierarquicamente para segregar os ativos por município e por tipo de recurso (notebooks, pipelines, modelos semânticos, etc.). A estrutura de pastas reflete a abordagem multi-cliente do projeto, com pastas dedicadas a cada município e uma pasta `utils` para recursos compartilhados [^1].

### Exemplo de Estrutura de Pastas

```
Acto Cidade Inteligente/
├── Aparecida de Goiânia/
├── Dados Públicos/
├── Mauá/
│   ├── bis_producao/
│   ├── nb/
│   └── pipelines/
├── Osasco/
│   ├── bis/
│   ├── nbs/
│   └── pipelines/
├── Santos/
│   ├── bis/
│   ├── modelos_semanticos/
│   ├── nbs/
│   │   ├── avaliacao_servicos/
│   │   ├── carta_servicos/
│   │   ├── cet/
│   │   ├── manifestacao_ouvidoria/
│   │   ├── obras/
│   │   └── segov/ (e outras secretarias)
│   ├── nbs_analise/
│   └── pipelines/
└── utils/
    ├── config_api_acto.ipynb
    ├── nb_utils_ingest_acto_gestao.ipynb
    └── nb_utils_request_api.ipynb
```

## 3. Clientes e Domínios de Dados

Atualmente, o ambiente atende a diversos municípios, sendo **Santos** o mais detalhadamente mapeado. Cada município possui seu próprio conjunto de dados e notebooks, embora alguns utilitários sejam compartilhados [^1].

### 3.1. Município de Santos

O Lakehouse `lh_cidade_inteligente_santos` é o repositório principal. Os domínios de dados incluem:

*   **Avaliação de Serviços:** Ingestão e processamento de avaliações, com camada Gold+IA para análise de sentimento.
*   **Obras Públicas:** Monitoramento de obras, com pipelines complexos e identificação de riscos críticos de autenticação.
*   **CET (Companhia de Engenharia de Tráfego):** Gestão de serviços de tráfego e curso de motoristas.
*   **Ouvidoria e Secretarias (SEGOV, SEINFRA, SEPREF):** Ingestão de dados de serviços específicos de cada secretaria, com um notebook agregador para a Ouvidoria.
*   **Carta de Serviços:** Mapeamento de serviços públicos, com desafios de unificação de fontes (CSV vs. API).
*   **CAGED:** Dados de emprego e desemprego, atualmente em construção e com erros de configuração [^1].

### 3.2. Município de Mauá

Mauá utiliza um Lakehouse específico (`lh_cidade_inteligente_maua`) dentro do mesmo workspace. Seus notebooks (`nb_ingest_maua_acto_gestao_ambiente.ipynb`, `nb_ingest_maua_acto_gestao_plan_urbano.ipynb`) demonstram padrões de ingestão e transformação de dados para serviços como meio ambiente e planejamento urbano, com persistência em Parquet na camada Silver e Delta na Gold [^3] [^4].

### 3.3. Município de Osasco

Osasco também possui notebooks dedicados (`nb_ingest_acto_gestao_osasco.ipynb`) para ingestão de dados, com configurações de API e payloads específicos para seus serviços, como o programa Bolsa Trabalho [^5].

## 4. Notebooks (nbs) e Padrões de Desenvolvimento

Os notebooks são a principal ferramenta para transformação e processamento de dados no Fabric. Eles seguem uma convenção de nomenclatura rigorosa e são organizados por camadas da arquitetura Medallion [^2].

### 4.1. Convenção de Nomenclatura

O padrão adotado é `nb_{camada}_{municipio}_{dominio}`. Exemplos:

*   `nb_ingest_acto_santos` (Bronze/Ingestão)
*   `nb_silver_santos_avaliacao` (Silver)
*   `nb_gold_santos_avaliacao` (Gold)

**Observação:** Alguns notebooks existentes podem violar essa regra, como `gold_curso_motorista`, que deveria ser `nb_gold_santos_curso_motorista` [^2].

### 4.2. Notebooks Utilitários

A pasta `utils/` e notebooks específicos dentro de cada domínio (`nb_utils_api_acto_gestao`, `nb_utils_api_acto_gestao_obras`, `nb_utils_ingest_acto_gestao`) contêm funções reutilizáveis para acesso a APIs, tratamento de dados e configurações. No entanto, há identificação de código duplicado e falta de tratamento de erros em alguns desses utilitários [^1].

### 4.3. Camadas de Processamento

*   **Bronze:** Notebooks de ingestão que leem dados de fontes externas (APIs, FTP, CSV) e os salvam como Delta Tables brutas no Lakehouse. Ex: `nb_ingest_acto_santos`.
*   **Silver:** Notebooks que realizam limpeza, normalização, tipagem e aplicação de regras de negócio básicas. Podem implementar Slowly Changing Dimensions (SCD Type 2) para versionamento de dados. Ex: `nb_silver_santos_avaliacao`.
*   **Gold:** Notebooks que agregam e transformam os dados para consumo final, criando modelos dimensionais e tabelas de fatos. Ex: `nb_gold_santos_avaliacao`, `nb_gold_ouvidoria_servicos`.
*   **Gold+IA:** Camada especializada para enriquecimento de dados com modelos de IA, como análise de sentimento [^1].

## 5. Power BI e Consumo de Dados

Os dados processados nas camadas Gold são disponibilizados para consumo através de **Modelos Semânticos do Power BI** e **Relatórios Power BI**. A maioria dos pipelines segue um padrão uniforme: Notebook (Gold) → Refresh do SQL Endpoint → Refresh do Modelo Semântico do Power BI [^1].

### 5.1. Modelos Semânticos

Cada domínio de dados possui um ou mais modelos semânticos que servem como base para os relatórios. Por exemplo, o domínio de Obras possui 4 modelos semânticos, e a Avaliação de Serviços tem seu próprio modelo [^1].

### 5.2. Relatórios e Dashboards

Os relatórios Power BI (`gestao_paineis`, `acompanhamento_avaliacao_servicos`, `acompanhamento_carta_servicos`, etc.) são o ponto final de consumo dos dados, oferecendo insights para a gestão municipal. Eles são atualizados automaticamente via pipelines [^1].

## 6. Padrões Arquiteturais e Melhores Práticas

### 6.1. Slowly Changing Dimensions (SCD Type 2)

Para dados que mudam ao longo do tempo, como os prazos das Cartas de Serviço, é crucial implementar o SCD Type 2. Isso garante que as análises históricas utilizem o prazo correto vigente na data da solicitação, evitando a corrupção retrospectiva de indicadores [^2].

**Schema de Exemplo: `gold_dim_cartas_servico_vigencia`**

| Coluna | Tipo | Papel | Descrição |
|---|---|---|---|
| `sk_carta` | `INTEGER` | PK | Chave surrogate — identificador de versão |
| `id_servico` | `STRING` | NK | Chave natural — ID do serviço no Acto |
| `nr_prazo` | `INTEGER` | | Quantidade de dias do prazo |
| `is_dias_uteis` | `BOOLEAN` | | `True` = dias úteis; `False` = dias corridos |
| `dt_inicio_vigencia` | `DATE` | **SCD2** | Data em que esta versão passou a valer |
| `dt_fim_vigencia` | `DATE` | **SCD2** | `9999-12-31` se registro ativo |
| `is_atual` | `BOOLEAN` | **SCD2** | `True` = versão vigente |

### 6.2. Validação de Dados

A implementação de validações de `rowcount` antes das operações de escrita é uma prática essencial para prevenir a sobrescrita de tabelas Gold com DataFrames vazios, garantindo a integridade dos dados [^1].

## 7. Riscos Identificados e Recomendações

O mapeamento revelou diversos riscos que afetam a confiabilidade e a manutenibilidade do ambiente. As recomendações visam mitigar esses riscos e elevar a maturidade da plataforma [^1].

| Risco | Descrição | Recomendação |
| :--- | :--- | :--- |
| **R5 (Crítico)** | Token de Obras expirado (401) | Implementar *retry* automático com reautenticação. |
| **R9 (Crítico)** | Código IBGE incorreto no CAGED | Corrigir o código IBGE antes da ativação do notebook. |
| **R1 (Atenção)** | Dependência de arquivos fixos | Migrar arquivos auxiliares para tabelas Delta. |
| **R2 (Atenção)** | Código duplicado | Consolidar funções utilitárias em um notebook compartilhado (`nb_utils_shared`). |
| **R3 (Atenção)** | Inconsistência overwrite vs append | Unificar estratégia de atualização ou isolar `allowFailure` para notebooks incrementais. |
| **R4 (Atenção)** | Ausência de validação de `rowcount` | Adicionar `assert len(df) > threshold` antes das escritas. |
| **R7 (Atenção)** | Tratamento de erros inadequado | Implementar `try/except HTTPError` com *retry* e log de falha. |
| **R_dup (Atenção)** | Duas abordagens para Carta de Serviços | Definir e documentar uma fonte canônica; desativar a redundante. |

## Referências

[^1]: [[Mapeamento_Fabric_Santos_Consolidado_v1_8.docx]] (Documento fornecido pelo usuário)
[^2]: fabric_santos_nbs_analise.md (Documento fornecido pelo usuário)
[^3]: [[nb_ingest_maua_acto_gestao_ambiente.ipynb]] (Notebook de Mauá, fornecido pelo usuário)
[^4]: [[nb_ingest_maua_acto_gestao_plan_urbano.ipynb]] (Notebook de Mauá, fornecido pelo usuário)
[^5]: nb_ingest_acto_gestao_osasco.ipynb (Notebook de Osasco, fornecido pelo usuário)

---

## Ver Também

- [[_mapa-do-vault]] — índice geral do vault
- [[Conhecimento/Fabric/fabric-workspace-acto-cidade-inteligente|fabric-workspace-acto-cidade-inteligente]] — workspace completo Acto Cidade Inteligente
- [[Conhecimento/Fabric/pipeline-acto-santos-fabric|pipeline-acto-santos-fabric]] — fluxo Data Factory + notebooks
- [[Projetos/acto-santos-pipeline]] — projeto ACTO Santos
