---
title: "CNES — Cadastro Nacional de Estabelecimentos de Saúde"
tags:
  - tipo/referencia-tecnica
  - tema/dados-publicos
  - tema/saude
status: ativo
revisao: "2026-07-02"
relacionados:
  - "[[Documentação_Fabric/Dados Públicos/Saude_Educacao/00_INDEX_SAUDE_EDUCACAO]]"
  - "[[Documentação_Fabric/Dados Públicos/Saude_Educacao/MAPEAMENTO_FONTES_COMPLETO]]"
  - "[[Documentação_Fabric/Dados Públicos/Saude_Educacao/DATASUS_SIM_SINASC_Referencia]]"
  - "[[Documentação_Fabric/Dados Públicos/Saude_Educacao/DATASUS_SIH_Referencia]]"
---

# CNES — Cadastro Nacional de Estabelecimentos de Saúde

> [[Documentação_Fabric/Dados Públicos/Saude_Educacao/00_INDEX_SAUDE_EDUCACAO|← Índice Saúde e Educação]]

## 1. Fontes candidatas

| Rota | Origem | Prós | Contras |
|---|---|---|---|
| **BigQuery (basedosdados.org)** ⭐ recomendada | Dataset `basedosdados.br_ms_cnes` | Já temos conta/projeto GCP funcionando (mesma usada para RAIS). Tabelas já tratadas/padronizadas (tipos, nomes de coluna). Sem necessidade de parser DBC. | Depende do ciclo de atualização da Base dos Dados. Cobertura **validada em 2026-07-02 até 2026-05** — ver [[Documentação_Fabric/Dados Públicos/Saude_Educacao/MAPEAMENTO_FONTES_COMPLETO|MAPEAMENTO_FONTES_COMPLETO]]. |
| API REST oficial (`cnes.datasus.gov.br/rest/estabelecimentos`) | Ministério da Saúde | Dado "vivo" — reflete situação cadastral atual, sem defasagem de carga em lote. Suporta busca por unidade (`codUnidade`) ou geolocalização (lat/lon/raio). | É uma foto do cadastro atual, não fornece série histórica mensal facilmente; endpoints não documentados oficialmente/instáveis; sem OpenAPI público confirmado — precisa validar rate limits e autenticação na prática. |
| FTP DATASUS via **PySUS** (`pysus.online_data.cnes`) | Arquivos DBC brutos, mensais desde ~2003 | Fonte primária, granularidade mensal e histórico completo (2003+). Biblioteca Python madura (`AlertaDengue/PySUS`), converte DBC → parquet/pandas. | Exige rodar o parser localmente (não roda nativamente dentro do Spark do Fabric); precisa de etapa intermediária de ingestão (baixar fora do Fabric ou via notebook Python puro antes de subir ao Lakehouse). |

## 2. Acesso

- **BigQuery:** `basedosdados.br_ms_cnes.*` — tabelas: `estabelecimento`, `profissional`, `leito`, `equipe`, `equipamento`, `habilitacao`, `dados_complementares`, `servico_especializado`. Autenticação via credencial GCP já usada no pipeline RAIS.
- **API REST:** `https://cnes.datasus.gov.br/rest/estabelecimentos` — sem chave de API aparente (uso público), mas comportamento e limites não documentados oficialmente — testar antes de depender em produção.
- **FTP/PySUS:** `pip install pysus` → `from pysus.online_data.CNES import download` — parâmetros: grupo (ST=estabelecimentos, PF=profissionais, LT=leitos, etc.), UF, ano/mês.

## 3. Periodicidade na fonte

- CNES tem **atualização mensal obrigatória** por lei (estabelecimentos devem atualizar cadastro mensalmente ou a cada mudança).
- Cobertura histórica FTP: desde 2003 (competência real desde 2005-08), granularidade mensal (competência AAAAMM).

## 4. Schema e granularidade

- Granularidade: **estabelecimento de saúde** (CNES = código de 7 dígitos), com tabelas satélite por profissional, leito, equipamento, habilitação.
- Chave de junção com `gold.dim_municipio`: `codIbge` (código IBGE de 6 ou 7 dígitos) presente na tabela de estabelecimentos.
- Campos-chave: `codCnes`, `codUnidade`, `codIbge`, `nomeFantasia`, `esferaAdministrativa`, `natureza_juridica`, tipo de estabelecimento.

## 5. Volumetria estimada

- Nacional: dezenas de milhares de estabelecimentos ativos (~400k registros históricos incluindo baixados/inativos, ordem de grandeza — validar na extração real).
- Para os 15 municípios do cluster (Santos, Osasco, Mauá e demais): volume baixo, dezenas a poucas centenas de estabelecimentos por município — carga leve.

## 6. Estratégia de monitoramento/detecção de atualização recomendada

- **Se via BigQuery:** checar `metadata` do dataset na Base dos Dados (campo de última atualização) antes de cada carga; alternativa é hash/rowcount comparison entre execuções (`assert` de linhas novas, seguindo padrão R4 do projeto).
- **Se via FTP/PySUS:** comparar competência (AAAAMM) mais recente disponível no FTP contra a última carregada na Bronze — rodar checagem mensal.
- Como o CNES é cadastro "vivo", considerar carga **incremental por competência** (não overwrite total) para preservar histórico de mudanças de estabelecimento (relevante para SIH/SINASC que referenciam CNES por competência).

## 7. Riscos/dependências

- **SIM, SINASC e SIH referenciam `codCnes`** para identificar o estabelecimento de ocorrência/internação — o CNES deve ser ingerido **antes** desses três para permitir lookup/enriquecimento.
- API REST oficial não tem contrato formal documentado — tratar como best-effort, não como SLA.

---

**Fonte da verdade (repositório local):** `dados_saude_educacao/ref/DATASUS_CNES_Referencia.md`
