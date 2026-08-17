---
title: Documentação Geral — Ambiente Microsoft Fabric · Acto Cidade Inteligente
date: 2026-04-10
tags:
  - municipio/santos
  - ferramenta/fabric
  - tipo/referencia
projeto: acto-cidade-inteligente
fonte: documentacao-interna
status: obsoleto
---
# Documentação Geral: Ambiente Microsoft Fabric - Acto Cidade Inteligente

**Data:** 10 de Abril de 2026  
**Status:** Consolidado  
**Escopo:** Município de Santos e Notebooks Utilitários Compartilhados

---

## 1. Visão Geral do Projeto
O projeto **Acto Cidade Inteligente** no Microsoft Fabric visa a consolidação de dados municipais de diversas secretarias e serviços. A arquitetura segue o padrão **Medallion** (Bronze, Silver, Gold), utilizando o Lakehouse `lh_cidade_inteligente_santos` como repositório central.

---

## 2. Mapeamento de Notebooks - Município de Santos

Os notebooks de Santos estão organizados por domínios de negócio, refletindo a estrutura das secretarias e serviços específicos do município.

### 2.1. Avaliação de Serviços
Processamento de feedbacks e avaliações de usuários sobre os serviços municipais.
- `nb_silver_santos_avaliacao`: Limpeza e normalização das avaliações.
- `nb_gold_santos_avaliacao`: Consolidação dos indicadores de avaliação.
- `nb_gold_santos_avaliacao_sentimento`: Enriquecimento com IA para análise de sentimento (utiliza modo `append`).

### 2.2. CET (Companhia de Engenharia de Tráfego)
Gestão de trânsito e cursos específicos.
- `nb_ingest_estrutura_cet`: Ingestão de dados estruturais da CET.
- `nb_ingest_silver_cet_carga_descarga`: Processamento de dados de carga e descarga.
- `nb_gold_acto_gestao_cet`: Indicadores gerais da CET.
- `nb_gold_acto_gestao_cet_carga_descarga`: Painel de indicadores de carga e descarga.
- **Subdomínio: Curso de Motoristas**
    - `nb_ingest_santos_curso_motoristas`: Extração de dados de participação.
    - `nb_silver_santos_curso_motoristas`: Transformação e pivotamento de presença.

### 2.3. Obras Públicas
Domínio de alta complexidade com integração de dados de gestão de obras.
- `nb_ingest_silver_acto_gestao_obras_santos`: Ingestão baseada em API.
- `nb_gold_acto_gestao_obras`: Consolidação de indicadores de obras.
- `nb_gold_acto_gestao_obras_etapas`: Detalhamento das fases das obras.
- `nb_gold_acto_gestao_obras_seont_os`: Gestão de ordens de serviço específicas (SEONT).

### 2.4. Secretarias e Ouvidoria
Processamento de solicitações e manifestações de diversas secretarias.
- `nb_gold_acto_gestao_segov`: Dados da Secretaria de Governo.
- `nb_gold_acto_gestao_seinfra`: Dados da Secretaria de Infraestrutura.
- `nb_gold_acto_gestao_sepref`: Dados da Secretaria de Prefeituras Regionais.
- `nb_gold_acto_gestao_manifestacoes_ouvidoria`: Processamento de reclamações/sugestões.
- `nb_gold_acto_gestao_ouvidoria_servicos`: Notebook agregador que consolida dados de todas as secretarias.

### 2.5. Ingestão Geral e Apoio
- `nb_ingest_acto_santos`: Ingestão genérica de dados Acto.
- `nb_ingest_dim_date`: Geração de dimensão de tempo.
- `nb_ingest_tb_aux_servicos`: Processamento de tabelas auxiliares.
- `nb_ingest_carta_servicos_santos`: Ingestão da Carta de Serviços (atualmente em transição CSV -> API).

---

## 3. Mapeamento de Notebooks Utilitários (Shared/Common)

Estes notebooks contêm funções e configurações compartilhadas entre múltiplos ambientes (Santos, Mauá, Osasco) e são invocados via comando `%run`.

| Notebook | Localização | Função Principal |
| :--- | :--- | :--- |
| `config_api_acto` | `/utils/` | Armazena tokens e configurações de acesso às APIs por município. |
| `nb_utils_request_api` | `/utils/` | Wrapper genérico para requisições HTTP e tratamento de payloads. |
| `nb_utils_ingest_acto_gestao` | `/utils/` | Utilitários de extração em massa (Atenção: Risco R7 - Falta de try/except). |
| `nb_utils_api_acto_gestao` | `/Santos/nbs/` | Cliente central da API Acto: `fetch_tabela()`, `harmonizar_nome_bairros()`. |
| `nb_utils_api_acto_gestao_obras` | `/Santos/nbs/` | Cliente especializado para o domínio de Obras (Atenção: Risco R5 - Token Expirado). |

---

## 4. Auditoria de Riscos e Recomendações

Com base na análise técnica, foram identificados os seguintes pontos críticos que exigem atenção imediata:

### 4.1. Riscos Críticos (Bloqueantes)
- **R5 (Obras):** Falha de autenticação no pipeline de obras desde 11/03/2025. **Ação:** Implementar renovação automática de token no `nb_utils_api_acto_gestao_obras`.
- **R9 (CAGED):** Código IBGE de Santos está incorreto (está o de Osasco). **Ação:** Corrigir para `353845` antes de ativar o pipeline.

### 4.2. Fragilidades Arquiteturais
- **R1 (Arquivos Estáticos):** Dependência de arquivos Excel/CSV manuais (ex: `tb_aux.xlsx`). **Ação:** Migrar para Tabelas Delta gerenciadas.
- **R2 (Duplicação):** Funções idênticas em múltiplos notebooks. **Ação:** Centralizar no novo `nb_utils_shared`.
- **R7 (Resiliência):** Ausência de tratamento de erros `try/except` em funções de rede. **Ação:** Implementar retentativas (retries) com backoff.

---

## 5. Próximos Passos (Roadmap)
1. **Estabilização:** Correção dos riscos R5 e R9.
2. **Modularização:** Criação do repositório central de utilitários.
3. **Migração:** Transição total da Carta de Serviços para API, eliminando fontes CSV redundantes.
4. **Governança:** Documentação automática da linhagem de dados via API do Fabric.

---
**Ambiente:** `lh_cidade_inteligente_santos`

---

## Ver Também

- [[_mapa-do-vault]] — índice geral do vault
- [[Conhecimento/Fabric/fabric-workspace-acto-cidade-inteligente|fabric-workspace-acto-cidade-inteligente]] — workspace completo Acto Cidade Inteligente
- [[Conhecimento/Fabric/pipeline-acto-santos-fabric|pipeline-acto-santos-fabric]] — fluxo Data Factory + notebooks
- [[Projetos/acto-santos-pipeline]] — projeto ACTO Santos
