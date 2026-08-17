---
title: "SIH — Sistema de Informações Hospitalares do SUS"
tags:
  - tipo/referencia-tecnica
  - tema/dados-publicos
  - tema/saude
status: ativo
revisao: "2026-07-02"
relacionados:
  - "[[Documentação_Fabric/Dados Públicos/Saude_Educacao/00_INDEX_SAUDE_EDUCACAO]]"
  - "[[Documentação_Fabric/Dados Públicos/Saude_Educacao/MAPEAMENTO_FONTES_COMPLETO]]"
  - "[[Documentação_Fabric/Dados Públicos/Saude_Educacao/DATASUS_CNES_Referencia]]"
---

# SIH — Sistema de Informações Hospitalares do SUS

> [[Documentação_Fabric/Dados Públicos/Saude_Educacao/00_INDEX_SAUDE_EDUCACAO|← Índice Saúde e Educação]]

## 1. Fontes candidatas

| Rota | Origem | Prós | Contras |
|---|---|---|---|
| **BigQuery (basedosdados.org)** ⭐ recomendada | Dataset `basedosdados.br_ms_sih` — dado processado pela metodologia ETL da PCDaS/Fiocruz e replicado pela Base dos Dados | Mesma infraestrutura GCP já usada (RAIS). Dataset mensal completo desde **janeiro/2008**, já enriquecido (ETL da PCDaS trata inconsistências conhecidas do dado bruto). Cobertura **validada em 2026-07-02 até 2026-04** — ver [[Documentação_Fabric/Dados Públicos/Saude_Educacao/MAPEAMENTO_FONTES_COMPLETO|MAPEAMENTO_FONTES_COMPLETO]]. | Validar defasagem entre a publicação mensal oficial do DATASUS e a atualização do dataset replicado — checar antes de decidir frequência de carga. |
| FTP DATASUS via **PySUS** (`pysus.online_data.SIH`) | Arquivos DBC (RD = Reduzida de AIH) por UF/competência | Fonte primária, granularidade de **AIH individual** (1 internação por linha), disponível desde 2008 (nacional) com meses mais recentes. | Exige parser DBC fora do Spark; dado bruto tem inconsistências conhecidas de codificação de procedimento/CID que a rota BigQuery já resolve. |

## 2. Acesso

- **BigQuery:** `basedosdados.br_ms_sih.*`.
- **FTP/PySUS:** `pysus.online_data.SIH.download(states, years, months)`.

## 3. Periodicidade na fonte

- Publicação **mensal**, com defasagem típica de ~2 meses entre o mês de competência (AIH) e a disponibilização do arquivo bruto no FTP do DATASUS.

## 4. Schema e granularidade

- Granularidade: **AIH (Autorização de Internação Hospitalar)** — 1 linha por internação.
- Chave de junção com `gold.dim_municipio`: município de residência do paciente e/ou município do estabelecimento (via `codCnes`).
- Campos-chave: `codCnes` (hospital), diagnóstico principal (CID), procedimento realizado, valor pago, data de internação/alta.

## 5. Volumetria estimada

- Para os 15 municípios do cluster: possivelmente dezenas de milhares de internações/ano somadas — volume moderado a alto dependendo da presença de hospitais de referência regional (ex.: Santos concentra atendimentos da Baixada Santista).

## 6. Estratégia de monitoramento/detecção de atualização recomendada

- Carga **incremental por competência mensal** (AAAAMM), comparando a última competência carregada contra a mais recente disponível na fonte a cada execução do pipeline.
- Se usar a rota BigQuery, monitorar a data de "última atualização" do dataset na Base dos Dados como gatilho de nova carga.

## 7. Riscos/dependências

- Depende do **CNES já carregado** para identificar/enriquecer o hospital via `codCnes` (ver [[Documentação_Fabric/Dados Públicos/Saude_Educacao/DATASUS_CNES_Referencia|DATASUS_CNES_Referencia]]).
- Municípios-polo (ex.: Santos) podem concentrar internações de pacientes de outras cidades da região — decidir explicitamente se o indicador de "internações por município" usa residência do paciente ou local do hospital, para não distorcer comparações entre os 15 municípios do cluster.

---

**Fonte da verdade (repositório local):** `dados_saude_educacao/ref/DATASUS_SIH_Referencia.md`
