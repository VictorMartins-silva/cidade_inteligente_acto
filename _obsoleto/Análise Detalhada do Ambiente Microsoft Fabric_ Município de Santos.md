---
title: Análise Detalhada do Ambiente Microsoft Fabric — Município de Santos
date: 2026-04-30
tags:
  - municipio/santos
  - ferramenta/fabric
  - tipo/referencia
projeto: acto-santos
fonte: documentacao-interna
status: obsoleto
---
# Análise Detalhada do Ambiente Microsoft Fabric: Município de Santos

**Data:** Abril de 2026

## 1. Visão Geral do Ambiente

O ambiente Microsoft Fabric do Município de Santos, denominado `lh_cidade_inteligente_santos`, opera sob uma capacidade Diamante na região Brazil South. Este ambiente é o repositório principal de dados para o projeto Acto Cidade Inteligente, englobando uma arquitetura de dados estruturada que visa integrar informações de diversas secretarias e serviços municipais.

A arquitetura de dados adotada segue predominantemente o padrão Medallion, organizando os dados em camadas lógicas:
- **Bronze:** Ingestão de dados brutos provenientes de APIs (Acto Gestão), FTP (CAGED) e arquivos estáticos (CSV/Excel).
- **Silver:** Armazenamento intermediário em formato Parquet, onde ocorrem as primeiras transformações e limpezas.
- **Gold:** Tabelas Delta otimizadas para consumo, contendo dados agregados e regras de negócio aplicadas.
- **Gold+IA:** Uma camada especializada que enriquece os dados da camada Gold com análises de sentimento geradas por Inteligência Artificial.

O fluxo de orquestração é padronizado através de pipelines que, em sua maioria, seguem a sequência: execução de Notebook (Gold) → Refresh do SQL Endpoint → Refresh do Modelo Semântico do Power BI.

![Fluxograma de Dados](https://private-us-east-1.manuscdn.com/sessionFile/x0aq6JaaFy1K889Cagtvf8/sandbox/AJEoCMDKQfx6zO5KmC5BSH-images_1775759826366_na1fn_L2hvbWUvdWJ1bnR1L2ZsdXhvZ3JhbWFfZGFkb3M.png?Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9wcml2YXRlLXVzLWVhc3QtMS5tYW51c2Nkbi5jb20vc2Vzc2lvbkZpbGUveDBhcTZKYWFGeTFLODg5Q2FndHZmOC9zYW5kYm94L0FKRW9DTURLUWZ4NnpPNUttQzVCU0gtaW1hZ2VzXzE3NzU3NTk4MjYzNjZfbmExZm5fTDJodmJXVXZkV0oxYm5SMUwyWnNkWGh2WjNKaGJXRmZaR0ZrYjNNLnBuZyIsIkNvbmRpdGlvbiI6eyJEYXRlTGVzc1RoYW4iOnsiQVdTOkVwb2NoVGltZSI6MTc5ODc2MTYwMH19fV19&Key-Pair-Id=K2HSFNDJXOU9YS&Signature=ttvTJwvUSLCoLp7NHzqJ5BJHMgPtqBG5JxXMxfXarFxlTo52Ooy~OlOjSpV7y6J1TuVja3NBq0OkTjRx0SE-0MrZfxtT4C6H1uJMJUK0dMBdgLM3m8BbkQec~wTa6~z~jQCMHWUatA-wE5QchsZUga76O5WE9vVjB7f4h~DFsqs6zBRIuIoTbluL2A7pBLY3avadJPQMPIksLls0v~qLfEw-Whkzo23JSZrruBG~Tao1uz3dhJtjO5Bu7K2houI28DVZj4Wv6RgfgZVOwvq3L5i5LAUHq1pY5CatR1Vgmhc2Al08QRMmkcl7zbFRY52Dvao2syPmMzkGrNNqRBtNZA__)

## 2. Mapeamento de Ativos e Fluxos

O ambiente é composto por diversos domínios de dados, cada um com suas particularidades e níveis de maturidade:

### 2.1. Avaliação de Serviços
Este domínio está completo e operacional. Ele ingere dados de avaliações, processa-os através das camadas Silver e Gold, e aplica uma análise de sentimento na camada Gold+IA. Notavelmente, o notebook de sentimento utiliza um método de escrita `append` incremental, enquanto o notebook base utiliza `overwrite`.

### 2.2. Obras Públicas
Um dos domínios mais complexos, englobando três notebooks raiz e uma subpasta (SEONT). O pipeline `pl_ingest_obras_santos` é o mais robusto do ambiente, contendo nove atividades inter-relacionadas. No entanto, este domínio apresenta falhas críticas de autenticação que interromperam a ingestão de dados.

### 2.3. Companhia de Engenharia de Tráfego (CET) e Curso de Motoristas
O domínio da CET está mapeado e inclui a gestão de serviços e carga/descarga. Uma observação importante é a localização da subpasta `curso_motoristas`, que se encontra dentro da estrutura da CET (`nbs/cet/curso_motoristas`), divergindo da documentação original do protótipo. O processamento do curso de motoristas é detalhado, envolvendo normalização, pivotamento de dados de presença e aplicação de regras de negócio complexas.

### 2.4. Ouvidoria e Secretarias (SEGOV, SEINFRA, SEPREF)
Estes domínios seguem um padrão simplificado, ingerindo dados diretamente da API para a camada Gold, sem passar explicitamente por uma camada Silver documentada. Um destaque arquitetural é o notebook agregador `nb_gold_acto_gestao_ouvidoria_servicos`, que realiza um `unionAll` das tabelas Gold de cinco secretarias diferentes, consolidando a visão de serviços da ouvidoria.

### 2.5. Carta de Serviços
Este domínio apresenta uma dualidade arquitetural. Existem duas abordagens paralelas para a ingestão de dados: uma baseada em arquivos CSV estáticos (atualmente em produção) e outra baseada em consumo de API (em desenvolvimento/teste). Esta duplicidade gera incertezas sobre a fonte de verdade dos dados.

### 2.6. CAGED
O domínio de dados de emprego e desemprego encontra-se em fase de construção. O notebook de ingestão nunca foi executado em produção e contém erros de configuração que impedem seu funcionamento correto.

## 3. Auditoria de Riscos Arquiteturais

A análise do documento de mapeamento revelou diversos riscos arquiteturais que comprometem a estabilidade, escalabilidade e confiabilidade do ambiente de dados. A matriz abaixo detalha estes riscos, seus impactos e as recomendações técnicas para mitigação.

| Risco | Descrição | Impacto | Recomendação Técnica |
| :--- | :--- | :--- | :--- |
| **R5 (Crítico)** | **Falha de Autenticação (Token Expirado):** O notebook `nb_ingest_silver_acto_gestao_obras_santos` falhou com erro HTTP 401 (Unauthorized) em 11/03/2025. | Interrupção total da ingestão de dados de obras públicas, resultando em dashboards desatualizados. | Implementar um mecanismo de *retry* automático com reautenticação via função `login_acto_gestao_obras()` ao interceptar o erro HTTP 401. |
| **R9 (Crítico)** | **Código IBGE Incorreto:** O notebook `nb_ingest_caged_santos` possui o código IBGE de Osasco (353440) *hardcoded*, em vez do código de Santos (353845). | Ingestão de dados de um município incorreto, invalidando as análises de emprego e desemprego. | Corrigir a variável `CODIGO_OSASCO` para `CODIGO_SANTOS = 353845` antes de promover o notebook para produção. |
| **R1 (Atenção)** | **Single Point of Failure (Arquivos Fixos):** Dependência de arquivos Excel e CSV estáticos (ex: `PMS_AuxiliarPDR.xlsx`, `grid_carta_servicos_santos.csv`) para configurações e dados auxiliares. | Fragilidade do pipeline; qualquer alteração no local ou formato do arquivo quebra a ingestão. | Migrar todos os arquivos auxiliares e de configuração para tabelas Delta versionadas no Lakehouse. |
| **R2 (Atenção)** | **Código Duplicado:** Funções de transformação (ex: `ajustar_nome_colunas()`) e dicionários de mapeamento estão replicados em múltiplos notebooks. | Dificuldade de manutenção e risco de inconsistências lógicas entre diferentes domínios. | Consolidar todas as funções utilitárias e mapeamentos comuns em um notebook compartilhado (`nb_utils_shared`). |
| **R3 (Atenção)** | **Inconsistência de Escrita (Overwrite vs Append):** O notebook base de avaliação usa `overwrite`, enquanto o de sentimento usa `append`. | Risco de dessincronização; o *overwrite* da base pode apagar registros que o *append* incremental não reprocessará. | Implementar lógica de *allowFailure* isolada para o notebook de sentimento ou unificar a estratégia de atualização. |
| **R4 (Atenção)** | **Ausência de Validação de Dados:** Múltiplos notebooks realizam operações de escrita (`to_parquet`, `saveAsTable`) sem validar se o DataFrame contém dados. | Risco de sobrescrever tabelas Gold com DataFrames vazios em caso de falha silenciosa na origem. | Implementar `assert len(df) > 0` (ou um *threshold* específico) antes de qualquer operação de escrita. |
| **R6 (Atenção)** | **Inconsistência de Payloads de API:** Existência de funções quase idênticas (`adicionar_etapa_atual()` e `adicionar_etapa_atual_2()`) com chaves diferentes. | Confusão no desenvolvimento e risco de falhas na extração de dados da API. | Documentar claramente qual endpoint retorna cada formato e adicionar validação de esquema nas funções. |
| **R7 (Atenção)** | **Tratamento de Erros Inadequado:** O notebook `nb_utils_ingest_acto_gestao` utiliza `raise_for_status()` sem blocos `try/except`. | Falhas temporárias da API causam a quebra imediata do pipeline sem tentativa de recuperação. | Adicionar blocos `try/except` para erros HTTP, implementando lógica de *retry* com *backoff* exponencial. |
| **R8 (Atenção)** | **Desalinhamento de Documentação:** A pasta `curso_motoristas` está localizada em um caminho diferente do documentado no protótipo. | Confusão na governança e manutenção do ambiente. | Atualizar a documentação oficial e os metadados do projeto para refletir a estrutura real de produção. |

## 4. Plano de Ação e Roadmap de Melhorias

Para estabilizar o ambiente e elevar sua maturidade técnica, propõe-se o seguinte roadmap de melhorias, dividido em fases de execução.

![Roadmap de Melhorias](https://private-us-east-1.manuscdn.com/sessionFile/x0aq6JaaFy1K889Cagtvf8/sandbox/AJEoCMDKQfx6zO5KmC5BSH-images_1775759826366_na1fn_L2hvbWUvdWJ1bnR1L3JvYWRtYXBfbWVsaG9yaWFz.png?Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9wcml2YXRlLXVzLWVhc3QtMS5tYW51c2Nkbi5jb20vc2Vzc2lvbkZpbGUveDBhcTZKYWFGeTFLODg5Q2FndHZmOC9zYW5kYm94L0FKRW9DTURLUWZ4NnpPNUttQzVCU0gtaW1hZ2VzXzE3NzU3NTk4MjYzNjZfbmExZm5fTDJodmJXVXZkV0oxYm5SMUwzSnZZV1J0WVhCZmJXVnNhRzl5YVdGei5wbmciLCJDb25kaXRpb24iOnsiRGF0ZUxlc3NUaGFuIjp7IkFXUzpFcG9jaFRpbWUiOjE3OTg3NjE2MDB9fX1dfQ__&Key-Pair-Id=K2HSFNDJXOU9YS&Signature=vdOqNN~UQXI3ivRs9wWKxRvvm0bAgnkAEarvMwqhblrglAQbeHzULvXlykmia~8FLEcgccMksjdlVhszaBKOA-ki0h8jf96NNZo5Kq847HirsKy764J0RH0-37LhP3HmPCiYTFGmGFKHffDCgm3P04C4MxOjDxH7tIVSeGrUpFN2qDxLkmuWQqstmzLF5WmkVbLgNAsc~WTsHfHnnd8Z0ArNHcDQBeKpp2tDoSNJtIyGDU0JPahNrueeEZdT6mjXbhF5HC5GmyPgVKa8T8zZpJbBt9owm3-heGmEZHgzTf2TjFj1NeiPzK08hkz15jmpmGFEakW6x4ADDkXjDkh4Lw__)

### 4.1. Curto Prazo (Imediato)
O foco desta fase é restabelecer a operação normal e corrigir erros bloqueantes.
1. **Restabelecer Ingestão de Obras:** Corrigir imediatamente o erro de autenticação (R5) no pipeline de obras, implementando a renovação automática do token.
2. **Corrigir Configuração do CAGED:** Alterar o código IBGE no notebook do CAGED (R9) para garantir que os dados corretos sejam ingeridos quando o pipeline for ativado.
3. **Implementar Validações de Segurança:** Adicionar verificações de `rowcount` (R4) em todos os notebooks de ingestão e transformação para evitar a corrupção de dados por sobrescrita vazia.

### 4.2. Médio Prazo
O objetivo desta fase é aumentar a resiliência e a manutenibilidade do código.
1. **Eliminar Single Points of Failure:** Substituir a leitura de arquivos Excel e CSV (R1) por consultas a tabelas Delta gerenciadas no Lakehouse.
2. **Refatoração e Modularização:** Criar o notebook `nb_utils_shared` e migrar todas as funções duplicadas (R2) para este repositório central.
3. **Governança de Pipelines:** Mapear e documentar os agendamentos de todos os pipelines via API REST do Fabric, garantindo visibilidade sobre os SLAs de atualização.

### 4.3. Longo Prazo
Esta fase visa a consolidação arquitetural e a documentação abrangente.
1. **Unificação Arquitetural:** Resolver a dualidade no domínio de Carta de Serviços, definindo uma única fonte de verdade (preferencialmente via API) e descontinuando o fluxo redundante.
2. **Documentação de Integrações:** Mapear e documentar exaustivamente os payloads da API Acto Gestão (R6), criando contratos de dados claros.
3. **Mapeamento de Consumo:** Realizar o inventário completo da pasta `modelos_semanticos` e `nbs_analise`, estabelecendo a linhagem de dados ponta a ponta, desde a origem até os dashboards finais.

## 5. Conclusão

O ambiente Microsoft Fabric do Município de Santos apresenta uma fundação sólida baseada na arquitetura Medallion, com pipelines bem estruturados para a maioria dos domínios. No entanto, a presença de falhas críticas de autenticação, dependência de arquivos estáticos e duplicação de código representam riscos significativos à operação contínua.

A execução disciplinada do roadmap de melhorias proposto não apenas resolverá os incidentes atuais, mas também elevará a resiliência, a segurança e a escalabilidade da plataforma de dados, garantindo que o projeto Acto Cidade Inteligente continue a fornecer *insights* valiosos e confiáveis para a gestão municipal.

---

## Ver Também

- [[_mapa-do-vault]] — índice geral do vault
- [[Conhecimento/Fabric/fabric-workspace-acto-cidade-inteligente|fabric-workspace-acto-cidade-inteligente]] — workspace completo Acto Cidade Inteligente
- [[Conhecimento/Fabric/pipeline-acto-santos-fabric|pipeline-acto-santos-fabric]] — fluxo Data Factory + notebooks
- [[Projetos/acto-santos-pipeline]] — projeto ACTO Santos
