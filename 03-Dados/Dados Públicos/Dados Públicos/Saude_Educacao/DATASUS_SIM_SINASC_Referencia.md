---
title: "SIM / SINASC — Sistema de Informações sobre Mortalidade / Nascidos Vivos"
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

# SIM / SINASC — Sistema de Informações sobre Mortalidade / Nascidos Vivos

> [[Documentação_Fabric/Dados Públicos/Saude_Educacao/00_INDEX_SAUDE_EDUCACAO|← Índice Saúde e Educação]]

## 1. Fontes candidatas

| Rota | Origem | Prós | Contras |
|---|---|---|---|
| **BigQuery (basedosdados.org)** ⭐ recomendada | Datasets `basedosdados.br_ms_sim` e `basedosdados.br_ms_sinasc` | Mesma infraestrutura GCP já usada (RAIS). Dados tratados e com tabelas agregadas prontas (ex.: `municipio_causa` no SIM) além de microdados. | SIM/SINASC têm **defasagem oficial de fechamento** na própria fonte primária (dados "preliminares" vs "fechados" — óbitos/nascimentos podem ser registrados com até 12–24 meses de atraso); a réplica na Base dos Dados herda esse atraso e soma o próprio ciclo de ETL deles — checar data de corte antes de cada carga. |
| FTP DATASUS via **PySUS** (`pysus.online_data.SIM` / `.SINASC`) | Arquivos DBC brutos por UF/ano | Fonte primária com granularidade de **registro individual** (1 óbito / 1 nascimento por linha), histórico longo. Biblioteca já suporta `sim.download()` e `sinasc.download()`. | Mesmo problema de defasagem de fechamento é herdado da fonte original — não é um contra da rota em si, mas deve ser documentado. Exige parser DBC fora do Spark do Fabric. |

## 2. Acesso

- **BigQuery:** `basedosdados.br_ms_sim.*` e `basedosdados.br_ms_sinasc.*`. Tabelas incluem microdados individuais e agregados por município (ex.: `municipio_causa` com `id_municipio`, `numero_obitos`, `causa_basica`, `ano`).
- **FTP/PySUS:** `pysus.online_data.SIM.download(states, years)` / `pysus.online_data.SINASC.download(states, years)`.

## 3. Periodicidade na fonte

- Coleta contínua (declaração de óbito/nascimento), mas **consolidação anual** — o Ministério da Saúde publica dados "preliminares" no ano corrente e "fechados" (definitivos) com defasagem típica de 1 a 2 anos.
- **Importante para o padrão de monitoramento:** nunca tratar o ano mais recente como definitivo — sinalizar explicitamente no Gold se o dado é preliminar ou fechado.

## 4. Schema e granularidade

- Granularidade: **registro individual** (1 linha = 1 óbito no SIM, 1 nascimento no SINASC).
- Chave de junção com `gold.dim_municipio`: `id_municipio` / `codmunres` (município de residência) — atenção: pode divergir do município de ocorrência (`codmunocor`), decidir qual usar conforme o indicador.
- Campos-chave SIM: causa básica de óbito (CID), data óbito, idade, sexo, `codCnes` do estabelecimento (quando aplicável).
- Campos-chave SINASC: peso ao nascer, idade da mãe, tipo de parto, `codCnes` do estabelecimento de nascimento.

## 5. Volumetria estimada

- Para os 15 municípios do cluster: dezenas de milhares de registros/ano somados (óbitos + nascimentos) — carga moderada, mas cresce linearmente com o histórico anual acumulado.

## 6. Estratégia de monitoramento/detecção de atualização recomendada

- Carga **incremental por ano de competência**, nunca overwrite total (o ano corrente será re-publicado como "fechado" futuramente — precisa reprocessar quando isso ocorrer).
- Monitorar campo de status/versão do dado (preliminar/fechado) na fonte escolhida a cada carga anual.
- Alertar se o ano mais recente disponível não mudar de "preliminar" para "fechado" dentro da janela esperada (~24 meses).

## 7. Riscos/dependências

- Depende do **CNES já carregado** para enriquecer com nome/tipo do estabelecimento via `codCnes` (ver [[Documentação_Fabric/Dados Públicos/Saude_Educacao/DATASUS_CNES_Referencia|DATASUS_CNES_Referencia]]).
- Risco de dupla contagem/inconsistência se misturar município de residência com município de ocorrência sem padronizar — definir isso na spec antes de construir o Gold.

---

**Fonte da verdade (repositório local):** `dados_saude_educacao/ref/DATASUS_SIM_SINASC_Referencia.md`
