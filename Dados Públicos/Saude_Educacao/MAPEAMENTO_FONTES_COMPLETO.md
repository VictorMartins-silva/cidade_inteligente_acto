---
title: "Mapeamento Completo de Fontes — DATASUS (CNES, SIM, SINASC, SIH) + INEP (Censo Escolar, IDEB)"
tags:
  - tipo/referencia-tecnica
  - tema/dados-publicos
  - tema/saude
  - tema/educacao
status: ativo
revisao: "2026-07-02"
relacionados:
  - "[[Documentação_Fabric/Dados Públicos/Saude_Educacao/00_INDEX_SAUDE_EDUCACAO]]"
  - "[[Documentação_Fabric/Dados Públicos/Saude_Educacao/DATASUS_CNES_Referencia]]"
  - "[[Documentação_Fabric/Dados Públicos/Saude_Educacao/DATASUS_SIM_SINASC_Referencia]]"
  - "[[Documentação_Fabric/Dados Públicos/Saude_Educacao/DATASUS_SIH_Referencia]]"
  - "[[Documentação_Fabric/Dados Públicos/Saude_Educacao/Censo_Escolar_Referencia]]"
  - "[[Documentação_Fabric/Dados Públicos/Saude_Educacao/IDEB_Referencia]]"
---

# Mapeamento Completo de Fontes — DATASUS (CNES, SIM, SINASC, SIH) + INEP (Censo Escolar, IDEB)

> [[Documentação_Fabric/Dados Públicos/Saude_Educacao/00_INDEX_SAUDE_EDUCACAO|← Índice Saúde e Educação]]

**Objetivo:** documento de mapeamento de bases públicas consolidando, para cada fonte, portal oficial, subconjuntos de dados, formatos, canais de acesso, cobertura temporal, periodicidade, granularidade e documentação de apoio. Complementa os documentos individuais: [[Documentação_Fabric/Dados Públicos/Saude_Educacao/DATASUS_CNES_Referencia|DATASUS_CNES_Referencia]], [[Documentação_Fabric/Dados Públicos/Saude_Educacao/DATASUS_SIM_SINASC_Referencia|DATASUS_SIM_SINASC_Referencia]], [[Documentação_Fabric/Dados Públicos/Saude_Educacao/DATASUS_SIH_Referencia|DATASUS_SIH_Referencia]], [[Documentação_Fabric/Dados Públicos/Saude_Educacao/Censo_Escolar_Referencia|Censo_Escolar_Referencia]], [[Documentação_Fabric/Dados Públicos/Saude_Educacao/IDEB_Referencia|IDEB_Referencia]].

**Validação web realizada em:** 2026-07-02 (WebSearch/WebFetch em fontes primárias — URLs citadas ao final de cada seção).

> ⚠️ **Atualização importante vs. documentos anteriores:** a cobertura dos datasets da Base dos Dados (BigQuery) foi verificada nesta data e está **muito mais atual** do que o risco apontado inicialmente no índice (que citava possível defasagem em ~2021): `br_ms_cnes` vai até **2026-05** e `br_ms_sih` até **2026-04**.

> ℹ️ O portal **OpenDataSUS** (`opendatasus.saude.gov.br`) hoje redireciona para o novo **Portal de Dados Abertos do SUS** (`dadosabertos.saude.gov.br`) — usar a URL nova em qualquer automação.

---

## 1. CNES — Cadastro Nacional de Estabelecimentos de Saúde

### 1.1 Site/portal oficial

- **Portal principal:** `https://cnes.datasus.gov.br/` — Ministério da Saúde / DATASUS (SEIDIGI).
- **Portais secundários:**
  - TABNET (tabulação agregada): `https://datasus.saude.gov.br/informacoes-de-saude-tabnet/`
  - Transferência de Arquivos DATASUS: `https://datasus.saude.gov.br/transferencia-de-arquivos/`
  - Base dos Dados: `https://basedosdados.org/dataset/354d6d98-bc09-4e22-a58a-e4eac3a5283c`
  - PCDaS/Fiocruz: `https://pcdas.icict.fiocruz.br/conjunto-de-dados/cadastro-nacional-de-estabelecimentos-de-saude/`
  - Metadados no Comitê de Estatísticas Sociais (IBGE): `https://ces.ibge.gov.br/base-de-dados/metadados/ministerio-da-saude/cadastro-nacional-de-estabelecimentos-de-saude-cnes.html`

### 1.2 Bases/tabelas contidas na origem

O FTP do DATASUS distribui o CNES em **13 grupos mensais** (1 arquivo por grupo × UF × competência AAAAMM):

| Grupo | Sigla | Conteúdo |
|---|---|---|
| Estabelecimentos | **ST** | Cadastro do estabelecimento (tipo, esfera, natureza jurídica, gestão) — tabela "mãe" |
| Profissional | **PF** | Vínculos de profissionais de saúde (CBO, carga horária, vínculo SUS) |
| Leitos | **LT** | Leitos por tipo (clínico, cirúrgico, UTI etc.) e disponibilidade SUS |
| Equipamentos | **EQ** | Equipamentos existentes/em uso (imagem, infraestrutura, métodos gráficos) |
| Equipes | **EP** | Equipes de saúde (ESF, NASF, saúde bucal etc.) |
| Habilitação | **HB** | Habilitações/credenciamentos do estabelecimento em alta complexidade |
| Serviço Especializado | **SR** | Serviços especializados ofertados e classificação |
| Dados Complementares | **DC** | Dados complementares (diálise, quimio/radioterapia etc.) |
| Estabelecimento de Ensino | **EE** | Atributo de hospital de ensino |
| Estabelecimento Filantrópico | **EF** | Atributo de entidade filantrópica |
| Gestão e Metas | **GM** | Contratos de gestão e metas |
| Incentivos | **IN** | Incentivos recebidos |
| Regra Contratual | **RC** | Regras contratuais |

Na Base dos Dados, os mesmos grupos aparecem como tabelas do dataset `br_ms_cnes`: `estabelecimento`, `profissional`, `leito`, `equipe`, `equipamento`, `habilitacao`, `dados_complementares`, `servico_especializado` (nem todos os 13 grupos são replicados — validar no console antes da ingestão).

### 1.3 Formato dos arquivos

- **Origem (FTP):** `.DBC` (DBF comprimido, formato proprietário DATASUS) — exige decodificador (PySUS, `read.dbc` em R, TabWin).
- **Portal CNES (arquivos de base de dados):** dumps mensais completos em ZIP.
- **API REST:** JSON.
- **Base dos Dados:** tabelas BigQuery (colunar, consultável via SQL) com exportação Parquet/CSV.
- **TABNET:** tabulações agregadas em HTML/CSV.

### 1.4 Locais de disponibilização

| Canal | Endereço | Observação |
|---|---|---|
| FTP DATASUS | `ftp://ftp.datasus.gov.br/dissemin/publicos/CNES/200508_/Dados/{GRUPO}/` | Arquivos `STUF AAMM.dbc` etc., mensais |
| Portal CNES — downloads | `https://cnes.datasus.gov.br/pages/downloads/arquivosBaseDados.jsp` | Base de dados completa mensal (ZIP) |
| API REST | `https://cnes.datasus.gov.br/rest/estabelecimentos` | Foto do cadastro atual; sem contrato formal documentado |
| BigQuery / Base dos Dados | `basedosdados.br_ms_cnes.*` | Rota recomendada no projeto |
| PySUS (Python) | `pysus.online_data.CNES` | Wrapper do FTP, converte DBC → parquet/pandas |
| microdatasus (R) | `https://github.com/rfsaldanha/microdatasus` | Wrapper do FTP em R |
| PCDaS/Fiocruz | `https://pcdas.icict.fiocruz.br/` | Dado enriquecido pela metodologia ETL própria |
| TABNET | `https://datasus.saude.gov.br/informacoes-de-saude-tabnet/` | Só agregados, sem microdado |

### 1.5 Período/cobertura temporal

- **FTP:** desde **agosto/2005** (competência 200508), mensal, até a competência corrente.
- **Base dos Dados (verificado 2026-07-02):** **2005-08 a 2026-05** — defasagem de ~1–2 meses vs. FTP.
- **API REST:** somente situação cadastral atual (sem histórico).

### 1.6 Periodicidade de atualização

- **Mensal** — estabelecimentos são obrigados a atualizar o cadastro mensalmente; DATASUS publica 1 competência/mês no FTP.
- Não há conceito formal de "preliminar vs. fechado": o CNES é um cadastro vivo — cada competência é uma foto do mês.

### 1.7 Granularidade

- **Por estabelecimento de saúde** (código CNES de 7 dígitos), com tabelas satélite por profissional/leito/equipamento/etc. (1 linha por vínculo/item × competência).
- Município presente via código IBGE — junção direta com `gold.dim_municipio`.

### 1.8 Dicionário de dados/documentação

- **Documentação oficial CNES (layouts, dicionários):** `https://cnes.datasus.gov.br/pages/downloads/documentacao.jsp`
- **Dicionário PySUS (grupos e nomes de arquivo):** `https://pysus.readthedocs.io/pt/latest/databases/CNES.html`
- **Documentação PCDaS (dicionário de variáveis enriquecidas):** `https://pcdas.icict.fiocruz.br/conjunto-de-dados/cadastro-nacional-de-estabelecimentos-de-saude/documentacao/`
- **Dicionários por tabela na Base dos Dados** (aba "Dados" de cada tabela do dataset).

**Fontes consultadas:** [Portal CNES — downloads](https://cnes.datasus.gov.br/pages/downloads/arquivosBaseDados.jsp) · [Documentação CNES](https://cnes.datasus.gov.br/pages/downloads/documentacao.jsp) · [Transferência de Arquivos DATASUS](https://datasus.saude.gov.br/transferencia-de-arquivos/) · [PySUS — CNES](https://pysus.readthedocs.io/pt/latest/databases/CNES.html) · [Base dos Dados — CNES](https://basedosdados.org/dataset/354d6d98-bc09-4e22-a58a-e4eac3a5283c) · [PCDaS — CNES](https://pcdas.icict.fiocruz.br/conjunto-de-dados/cadastro-nacional-de-estabelecimentos-de-saude/documentacao/) · [CES/IBGE — metadados CNES](https://ces.ibge.gov.br/base-de-dados/metadados/ministerio-da-saude/cadastro-nacional-de-estabelecimentos-de-saude-cnes.html)

---

## 2. SIM — Sistema de Informações sobre Mortalidade

### 2.1 Site/portal oficial

- **Portal principal:** `https://datasus.saude.gov.br/` (DATASUS / Ministério da Saúde — SVSA).
- **Portais secundários:**
  - Portal de Dados Abertos do SUS: `https://dadosabertos.saude.gov.br/` (ex-OpenDataSUS — a URL antiga `opendatasus.saude.gov.br` redireciona para cá)
  - TABNET — Estatísticas Vitais: `https://datasus.saude.gov.br/informacoes-de-saude-tabnet/`
  - Base dos Dados: `https://basedosdados.org/dataset/5beeec93-cbf3-43f6-9eea-9bee6a0d1683`
  - PCDaS/Fiocruz (conjunto SIM enriquecido)

### 2.2 Bases/tabelas contidas na origem

| Subconjunto | Arquivo FTP | Conteúdo |
|---|---|---|
| Declarações de Óbito (CID-10) | `DOUFAAAA.dbc` (dir `SIM/CID10/DORES/`) | 1 linha por óbito, codificação CID-10, desde 1996 |
| Declarações de Óbito (CID-9) | `DORUFAA.dbc` (dir `SIM/CID9/`) | Série histórica 1979–1995 em CID-9 |
| Óbitos fetais | `DOFET` | Óbitos fetais (CID-10) |
| Óbitos por causas externas | `DOEXT` | Recorte de causas externas |
| Óbitos infantis | `DOINF` | Recorte de menores de 1 ano |
| Óbitos maternos | `DOMAT` | Recorte de óbitos maternos |
| Dados preliminares | dir `SIM/PRELIM/` e CSV no dadosabertos | Ano corrente/recente antes do fechamento |
| Agregados BD | `municipio_causa` etc. (`br_ms_sim`) | Tabelas agregadas por município × causa × ano |

### 2.3 Formato dos arquivos

- **FTP:** `.DBC` (anual, por UF).
- **Portal de Dados Abertos do SUS:** **CSV** (microdados preliminares e finais).
- **Base dos Dados:** BigQuery (SQL/Parquet/CSV).
- **TABNET:** agregados HTML/CSV.

### 2.4 Locais de disponibilização

| Canal | Endereço |
|---|---|
| FTP DATASUS | `ftp://ftp.datasus.gov.br/dissemin/publicos/SIM/` |
| Dados Abertos do SUS | `https://dadosabertos.saude.gov.br/` (buscar "SIM") — CSV, inclui preliminares |
| BigQuery / Base dos Dados | `basedosdados.br_ms_sim.*` |
| PySUS | `pysus.online_data.SIM.download(states, years)` |
| microdatasus (R) | `fetch_datasus(information_system = "SIM-DO", ...)` |
| TABNET | Mortalidade — desde 1979 |

### 2.5 Período/cobertura temporal

- **FTP:** desde **1979** (CID-9 até 1995; CID-10 de 1996 em diante).
- **Base dos Dados:** 1979 até ~2022 nos microdados fechados (verificar ano a ano no console — a página do dataset carrega tabelas dinamicamente).
- **Defasagem:** dado **preliminar** do ano N sai ao longo de N+1; dado **definitivo/fechado** tipicamente **12–24 meses** após o fim do ano de competência.

### 2.6 Periodicidade de atualização

- Coleta contínua (declaração de óbito), **consolidação anual**.
- **Duas versões formais do dado: "preliminar" e "final"** — o preliminar pode ganhar registros e ter causas recodificadas até o fechamento. Nunca tratar o ano mais recente como definitivo (regra já registrada em [[Documentação_Fabric/Dados Públicos/Saude_Educacao/DATASUS_SIM_SINASC_Referencia|DATASUS_SIM_SINASC_Referencia]]).

### 2.7 Granularidade

- **Registro individual** (1 linha = 1 óbito). Município de **residência** (`CODMUNRES`) e de **ocorrência** (`CODMUNOCOR`) — escolher explicitamente por indicador.

### 2.8 Dicionário de dados/documentação

- Estrutura da Declaração de Óbito e dicionários: portal SVSA/DATASUS e pacote de documentação que acompanha os arquivos no FTP (`SIM/Docs/`).
- Dicionário PCDaS: `https://pcdas.icict.fiocruz.br/` (conjunto SIM → documentação).
- Dicionário por coluna na Base dos Dados (aba da tabela).
- microdatasus documenta o pré-processamento/rotulagem: `https://rfsaldanha.github.io/microdatasus/`

**Fontes consultadas:** [Base dos Dados — SIM](https://basedosdados.org/dataset/5beeec93-cbf3-43f6-9eea-9bee6a0d1683?table=dea823a5-cad7-4014-b77c-4aa33b3b0541) · [Portal de Dados Abertos do SUS](https://dadosabertos.saude.gov.br/) · [microdatasus](https://github.com/rfsaldanha/microdatasus) · [Transferência de Arquivos DATASUS](https://datasus.saude.gov.br/transferencia-de-arquivos/) · [artigo microdatasus (SciELO)](https://www.scielo.br/j/csp/a/gdJXqcrW5PPDHX8rwPDYL7F/?lang=pt)

---

## 3. SINASC — Sistema de Informações sobre Nascidos Vivos

### 3.1 Site/portal oficial

- **Portal principal:** `https://datasus.saude.gov.br/` (DATASUS / MS — SVSA). Portal temático: `http://sinasc.saude.gov.br/`.
- **Portais secundários:** Portal de Dados Abertos do SUS (`https://dadosabertos.saude.gov.br/`), TABNET, Base dos Dados (`https://basedosdados.org/dataset/48ccef51-8207-40ee-af5b-134c8ac3fb8c`), PCDaS/Fiocruz.

### 3.2 Bases/tabelas contidas na origem

| Subconjunto | Arquivo FTP | Conteúdo |
|---|---|---|
| Declarações de Nascido Vivo | `DNUFAAAA.dbc` (dir `SINASC/.../DNRES/`) | 1 linha por nascido vivo |
| Série antiga | `DNR` (1994–1995) | Estrutura antiga da DN |
| Dados preliminares | dir `PRELIM/` e CSV no dadosabertos | Ano corrente antes do fechamento |
| Agregados BD | tabelas agregadas por município (`br_ms_sinasc`) | Nascimentos por município × ano |

O SINASC é estruturalmente mais simples que o SIM — essencialmente uma base única (DN) com recortes preliminares/definitivos.

### 3.3 Formato dos arquivos

- **FTP:** `.DBC` (anual, por UF). **Dados Abertos do SUS:** CSV. **Base dos Dados:** BigQuery. **TABNET:** agregados.

### 3.4 Locais de disponibilização

| Canal | Endereço |
|---|---|
| FTP DATASUS | `ftp://ftp.datasus.gov.br/dissemin/publicos/SINASC/` |
| Dados Abertos do SUS | `https://dadosabertos.saude.gov.br/` (buscar "SINASC") |
| BigQuery / Base dos Dados | `basedosdados.br_ms_sinasc.*` |
| PySUS | `pysus.online_data.SINASC.download(states, years)` |
| microdatasus (R) | `fetch_datasus(information_system = "SINASC", ...)` |
| TABNET | Nascidos vivos — desde 1994 |

### 3.5 Período/cobertura temporal

- **FTP:** desde **1994** (portal TABNET); a Base dos Dados reporta cobertura **1979–2024** (série retroprojetada/consolidada — verificado 2026-07-02).
- **Defasagem:** mesma lógica do SIM — preliminar no ano seguinte, fechamento em **12–24 meses**.

### 3.6 Periodicidade de atualização

- Coleta contínua, **consolidação anual**, com versões **preliminar** e **final** — dados preliminares "podem ser alterados por inserção de novos registros ou procedimentos de avaliação de qualidade" (nota oficial).

### 3.7 Granularidade

- **Registro individual** (1 linha = 1 nascimento). Município de residência da mãe vs. de ocorrência do parto — mesma decisão de indicador do SIM. Campos-chave: peso ao nascer, semanas de gestação, tipo de parto, idade da mãe, `CODESTAB` (CNES).

### 3.8 Dicionário de dados/documentação

- Documentação/estrutura da DN no portal temático `http://sinasc.saude.gov.br/` e em `SINASC/Docs/` no FTP.
- Dicionário PCDaS: `https://pcdas.icict.fiocruz.br/wp-content/uploads/2021/10/documentacao_sinasc-1.html`
- Dicionário por coluna na Base dos Dados.

**Fontes consultadas:** [Base dos Dados — SINASC](https://basedosdados.org/dataset/48ccef51-8207-40ee-af5b-134c8ac3fb8c) · [Portal SINASC](http://sinasc.saude.gov.br/) · [Dados Abertos do SUS](https://dadosabertos.saude.gov.br/) · [PCDaS — documentação SINASC](https://pcdas.icict.fiocruz.br/wp-content/uploads/2021/10/documentacao_sinasc-1.html) · [nota sobre dados preliminares (PMSP)](https://prefeitura.sp.gov.br/web/saude/w/epidemiologia_e_informacao/nascidos_vivos/312653)

---

## 4. SIH — Sistema de Informações Hospitalares do SUS

### 4.1 Site/portal oficial

- **Portal principal:** `https://datasus.saude.gov.br/acesso-a-informacao/producao-hospitalar-sih-sus/` (DATASUS / MS).
- **Portais secundários:** TABNET (produção hospitalar), portal SIHD (`http://www2.datasus.gov.br/SIHD/`), Base dos Dados (`https://basedosdados.org/dataset/ff933265-8b61-4458-877a-173b3f38102b`), PCDaS/Fiocruz.

### 4.2 Bases/tabelas contidas na origem

| Subconjunto | Arquivo FTP | Conteúdo |
|---|---|---|
| AIH Reduzida | **RD**`UFAAMM.dbc` | 1 linha por internação aprovada — arquivo principal para análise |
| AIH Rejeitada | **RJ**`UFAAMM.dbc` | AIHs rejeitadas no processamento |
| AIH Rejeitada com erro | **ER**`UFAAMM.dbc` | Rejeitadas por erro de crítica |
| Serviços Profissionais | **SP**`UFAAMM.dbc` | Atos médicos/procedimentos realizados dentro de cada AIH (detalhe da RD) |
| Complementares (CH/CM) | dir do FTP | Arquivos complementares de faturamento |

### 4.3 Formato dos arquivos

- **FTP:** `.DBC` mensal por UF/grupo.
- **PCDaS:** CSV/JSON/HTML (via ElasticSearch e download), dado já enriquecido.
- **Base dos Dados:** BigQuery (replica a metodologia ETL da PCDaS).
- **TABNET:** agregados.

### 4.4 Locais de disponibilização

| Canal | Endereço |
|---|---|
| FTP DATASUS | `ftp://ftp.datasus.gov.br/dissemin/publicos/SIHSUS/200801_/Dados/` |
| BigQuery / Base dos Dados | `basedosdados.br_ms_sih.*` |
| PCDaS/Fiocruz | `https://pcdas.icict.fiocruz.br/conjunto-de-dados/sistema-de-informacoes-hospitalares-do-sus-sihsus/` |
| PySUS | `pysus.online_data.SIH.download(states, years, months)` |
| microdatasus (R) | `fetch_datasus(information_system = "SIH-RD", ...)` |
| TABNET | Produção hospitalar — por local de internação/residência |

### 4.5 Período/cobertura temporal

- **FTP (série atual):** desde **janeiro/2008** (dir `200801_`); há série anterior 1992–2007 em layout antigo.
- **Base dos Dados (verificado 2026-07-02):** **2008-01 a 2026-04**.
- **PCDaS (verificado 2026-07-02):** 2008-01 a 2026-03, atualização trimestral.
- **Defasagem:** ~**2 meses** entre a competência da AIH e a publicação do DBC no FTP; competências recentes sofrem retificação (AIHs apresentadas com atraso) — janela móvel de ~3–6 meses até estabilizar.

### 4.6 Periodicidade de atualização

- **Mensal** no FTP. Não há rótulo formal "preliminar/fechado", mas competências recentes são retificáveis — na prática, tratar os últimos ~6 meses como abertos e reprocessar.

### 4.7 Granularidade

- **Por AIH (internação)** no RD; **por procedimento** no SP. Município de residência do paciente (`MUNIC_RES`) vs. município do hospital (`MUNIC_MOV`/via `CNES`) — decisão crítica para os 15 municípios (Santos concentra referência regional).

### 4.8 Dicionário de dados/documentação

- Layout oficial da AIH Reduzida: `http://www2.datasus.gov.br/SIHD/reduzida` e manuais do SIHD.
- Dicionário PCDaS: `https://pcdas.icict.fiocruz.br/conjunto-de-dados/sistema-de-informacoes-hospitalares-do-sus-sihsus/documentacao/`
- PySUS — nomenclatura de arquivos: `https://pysus.readthedocs.io/en/latest/databases/SIH.html`
- Dicionário por coluna na Base dos Dados.

**Fontes consultadas:** [Produção Hospitalar SIH/SUS — DATASUS](https://datasus.saude.gov.br/acesso-a-informacao/producao-hospitalar-sih-sus/) · [Reduzida da AIH — SIHD](http://www2.datasus.gov.br/SIHD/reduzida) · [PySUS — SIH](https://pysus.readthedocs.io/en/latest/databases/SIH.html) · [Base dos Dados — SIH](https://basedosdados.org/dataset/ff933265-8b61-4458-877a-173b3f38102b) · [PCDaS — SIH documentação](https://pcdas.icict.fiocruz.br/conjunto-de-dados/sistema-de-informacoes-hospitalares-do-sus-sihsus/documentacao/)

---

## 5. Censo Escolar da Educação Básica — INEP

### 5.1 Site/portal oficial

- **Portal principal:** `https://www.gov.br/inep/pt-br/acesso-a-informacao/dados-abertos/microdados/censo-escolar` — INEP / Ministério da Educação (DEED — Diretoria de Estatísticas Educacionais).
- **Portais secundários:**
  - dados.gov.br: `https://dados.gov.br/dados/conjuntos-dados/inep-microdados-do-censo-escolar-da-educacao-basica`
  - Base dos Dados: `https://basedosdados.org/dataset/dae21af4-4b6a-42f4-b94a-4c2061ea9de5`
  - Catálogo de Escolas (consulta online) e Sinopses Estatísticas no portal INEP

### 5.2 Bases/tabelas contidas na origem

O pacote anual de microdados é organizado em **4 dimensões**:

| Dimensão | Conteúdo |
|---|---|
| **Escola** | Cadastro e infraestrutura (dependência administrativa, localização, água/energia/internet, bibliotecas, laboratórios) |
| **Turma** | Etapa/modalidade de ensino, turno, atividades complementares |
| **Matrícula** | 1 linha por aluno-matrícula: idade, sexo, cor/raça, necessidades especiais, transporte escolar |
| **Docente** | Função docente: formação, vínculo, disciplinas lecionadas |

Além dos microdados, o INEP publica produtos derivados: **Sinopses Estatísticas** (XLSX agregado), **Indicadores Educacionais** (taxas de rendimento, distorção idade-série, INSE etc.) e **Notas Estatísticas** por edição.

### 5.3 Formato dos arquivos

- **INEP (microdados):** ZIP anual contendo **CSV delimitado por `|` (pipe)**, dicionário de dados em **XLSX**, scripts de leitura (SAS/R) e documentação PDF.
- **Sinopses:** XLSX.
- **Base dos Dados:** BigQuery (schema harmonizado entre anos).

### 5.4 Locais de disponibilização

| Canal | Endereço |
|---|---|
| Download direto INEP | `https://www.gov.br/inep/pt-br/acesso-a-informacao/dados-abertos/microdados/censo-escolar` (arquivos hospedados em `download.inep.gov.br`) |
| dados.gov.br | `https://dados.gov.br/dados/conjuntos-dados/inep-microdados-do-censo-escolar-da-educacao-basica` |
| BigQuery / Base dos Dados | `basedosdados.br_inep_censo_escolar.*` (tabelas escola, turma, matrícula, docente) |
| Sem API REST | — apenas download de ZIP anual |

### 5.5 Período/cobertura temporal

- **Microdados oficiais INEP:** desde **1995** (edições recentes 2020–2025 disponíveis na página; edições anteriores reorganizadas após revisão de privacidade/LGPD de 2022).
- **Base dos Dados (verificado 2026-07-02):** **2007 a 2024** — a edição 2025 já tem Notas Estatísticas publicadas pelo INEP; microdados 2025 saem no ciclo de divulgação (a réplica BD vem depois).
- **Defasagem:** coleta em maio (data de referência) → resultados/microdados divulgados entre o fim do mesmo ano e o início do seguinte.

### 5.6 Periodicidade de atualização

- **Anual** (data de referência: última quarta-feira de maio). Há divulgação de resultados **preliminares** (para retificação pelas escolas) seguida dos dados **finais** — os microdados publicados correspondem à base final; retificações pontuais podem gerar reedição do arquivo.

### 5.7 Granularidade

- Múltiplos níveis: **escola → turma → matrícula (aluno) → função docente**. Código de município IBGE presente na dimensão escola — junção com `gold.dim_municipio`.

### 5.8 Dicionário de dados/documentação

- **Dicionário XLSX dentro de cada ZIP anual** (por dimensão, com domínios de cada variável).
- Notas Estatísticas por edição: ex. `https://download.inep.gov.br/publicacoes/institucionais/estatisticas_e_indicadores/notas_estatisticas_censo_escolar_da_educacao_basica_2025.pdf`
- Página geral de microdados INEP: `https://www.gov.br/inep/pt-br/acesso-a-informacao/dados-abertos/microdados`

**Fontes consultadas:** [Microdados Censo Escolar — INEP](https://www.gov.br/inep/pt-br/acesso-a-informacao/dados-abertos/microdados/censo-escolar) · [dados.gov.br — Censo Escolar](https://dados.gov.br/dados/conjuntos-dados/inep-microdados-do-censo-escolar-da-educacao-basica) · [Base dos Dados — Censo Escolar](https://basedosdados.org/dataset/dae21af4-4b6a-42f4-b94a-4c2061ea9de5) · [Notas Estatísticas 2025 (INEP)](https://download.inep.gov.br/publicacoes/institucionais/estatisticas_e_indicadores/notas_estatisticas_censo_escolar_da_educacao_basica_2025.pdf)

---

## 6. IDEB — Índice de Desenvolvimento da Educação Básica

### 6.1 Site/portal oficial

- **Portal principal:** `https://www.gov.br/inep/pt-br/areas-de-atuacao/pesquisas-estatisticas-e-indicadores/ideb` — INEP / MEC.
- **Página de resultados/downloads:** `https://www.gov.br/inep/pt-br/areas-de-atuacao/pesquisas-estatisticas-e-indicadores/ideb/resultados`
- **Portais secundários:** painel Power BI público (`ideb.inep.gov.br` / app.powerbi.com), dados.gov.br (`https://dados.gov.br/dados/conjuntos-dados/inep-indicador-educacional-da-educacao-basica-indice-de-desenvolvimento-da-educacao-basica-ideb`), Base dos Dados (`https://basedosdados.org/dataset/96eab476-5d30-459b-82be-f888d4d0d6b9`), QEdu (visualização de terceiros).

### 6.2 Bases/tabelas contidas na origem

Planilhas de resultado por **nível de agregação × etapa de ensino**:

| Subconjunto | Conteúdo |
|---|---|
| IDEB Escolas | Nota observada e meta projetada por escola × etapa (anos iniciais, anos finais, ensino médio) |
| IDEB Municípios | Resultado por município × rede (municipal/estadual/pública/privada) × etapa |
| IDEB UF/Regiões/Brasil | Agregados estaduais e nacional |
| Componentes | Taxa de aprovação (fluxo, do Censo Escolar), nota Saeb (aprendizado) — abertos nas planilhas |

### 6.3 Formato dos arquivos

- **INEP:** planilhas **XLSX/ODS** (uma por nível de agregação × edição), publicadas em `download.inep.gov.br`; documentos metodológicos em PDF. Sem API.
- **Base dos Dados:** BigQuery (tabelas por agregação: `brasil`, `uf`, `municipio`, `escola`).

### 6.4 Locais de disponibilização

| Canal | Endereço |
|---|---|
| Download direto INEP | `https://www.gov.br/inep/pt-br/areas-de-atuacao/pesquisas-estatisticas-e-indicadores/ideb/resultados` (arquivos em `download.inep.gov.br/ideb/`) |
| dados.gov.br | `https://dados.gov.br/dados/conjuntos-dados/inep-indicador-educacional-da-educacao-basica-indice-de-desenvolvimento-da-educacao-basica-ideb` |
| BigQuery / Base dos Dados | `basedosdados.br_inep_ideb.*` |
| Painel Power BI público | link em `https://www.gov.br/inep/.../ideb` |

### 6.5 Período/cobertura temporal

- **Edições bienais desde 2005** (2005, 2007, ..., 2023; próxima: 2025, divulgação prevista para 2026).
- **Base dos Dados (verificado 2026-07-02):** **2005 a 2023**.
- **Defasagem:** resultado da edição do ano N (ímpar) é divulgado em meados de N+1 (ex.: IDEB 2023 divulgado em agosto/2024, conforme Portaria nº 267/2023).

### 6.6 Periodicidade de atualização

- **Bienal** (anos ímpares) — única fonte não-anual/mensal deste levantamento. Sem conceito de preliminar/fechado: a divulgação é única por edição (retificações pontuais são raras e comunicadas por nota).

### 6.7 Granularidade

- **Escola, rede/município, UF, região e Brasil** — múltiplos níveis por edição. Junção com `gold.dim_municipio` por código IBGE.

### 6.8 Dicionário de dados/documentação

- **Nota Técnica de concepção do IDEB:** `https://download.inep.gov.br/educacao_basica/portal_ideb/o_que_e_o_ideb/Nota_Tecnica_n1_concepcaoIDEB.pdf`
- **Nota informativa da edição** (ex. 2023): `https://download.inep.gov.br/ideb/nota_informativa_ideb_2023.pdf`
- **Apresentação de resultados** (ex. 2023): `https://download.inep.gov.br/ideb/apresentacao_ideb_2023.pdf`
- Layout de colunas descrito na primeira aba de cada planilha XLSX de resultados.

**Fontes consultadas:** [IDEB — INEP](https://www.gov.br/inep/pt-br/areas-de-atuacao/pesquisas-estatisticas-e-indicadores/ideb) · [Resultados IDEB — INEP](https://www.gov.br/inep/pt-br/areas-de-atuacao/pesquisas-estatisticas-e-indicadores/ideb/resultados) · [Nota informativa IDEB 2023](https://download.inep.gov.br/ideb/nota_informativa_ideb_2023.pdf) · [Nota Técnica nº 1 — concepção do IDEB](https://download.inep.gov.br/educacao_basica/portal_ideb/o_que_e_o_ideb/Nota_Tecnica_n1_concepcaoIDEB.pdf) · [dados.gov.br — IDEB](https://dados.gov.br/dados/conjuntos-dados/inep-indicador-educacional-da-educacao-basica-indice-de-desenvolvimento-da-educacao-basica-ideb) · [Base dos Dados — IDEB](https://basedosdados.org/dataset/96eab476-5d30-459b-82be-f888d4d0d6b9)

---

## 7. Tabela-resumo comparativa

| Base | Subconjuntos | Formato bruto | Canais de acesso | Cobertura temporal | Periodicidade | Documentação |
|---|---|---|---|---|---|---|
| **CNES** | 13 grupos: ST (estabelecimento), PF, LT, EQ, EP, HB, SR, DC, EE, EF, GM, IN, RC | DBC mensal por UF | FTP DATASUS · portal CNES (ZIP) · API REST · BigQuery/BD · PySUS/microdatasus · PCDaS · TABNET | 2005-08 → hoje (BD até 2026-05) | **Mensal** (cadastro vivo, sem preliminar/fechado) | `cnes.datasus.gov.br/pages/downloads/documentacao.jsp` |
| **SIM** | DO (CID-10), DOR (CID-9), DOFET, DOEXT, DOINF, DOMAT + preliminares | DBC anual por UF; CSV no dadosabertos | FTP DATASUS · dadosabertos.saude.gov.br · BigQuery/BD · PySUS/microdatasus · PCDaS · TABNET | 1979 → ~2024 preliminar (fechado até ~2022/2023) | **Anual**, preliminar → fechado em 12–24 meses | `SIM/Docs` no FTP · PCDaS · dicionário BD |
| **SINASC** | DN (nascidos vivos) + preliminares | DBC anual por UF; CSV no dadosabertos | FTP DATASUS · dadosabertos.saude.gov.br · BigQuery/BD · PySUS/microdatasus · PCDaS · TABNET | 1994 (FTP) / 1979 (BD) → 2024 | **Anual**, preliminar → fechado em 12–24 meses | `sinasc.saude.gov.br` · PCDaS · dicionário BD |
| **SIH** | RD (AIH reduzida), SP (serviços profissionais), RJ, ER + complementares | DBC mensal por UF | FTP DATASUS · BigQuery/BD (ETL PCDaS) · PCDaS (CSV/JSON) · PySUS/microdatasus · TABNET | 2008-01 → hoje (BD até 2026-04) | **Mensal**, defasagem ~2 meses; últimos ~6 meses retificáveis | `www2.datasus.gov.br/SIHD/reduzida` · PCDaS · dicionário BD |
| **Censo Escolar** | Escola, Turma, Matrícula, Docente (+ sinopses e indicadores derivados) | CSV pipe (`\|`) em ZIP anual + dicionário XLSX | Download INEP · dados.gov.br · BigQuery/BD | 1995 → 2024/2025 (BD 2007–2024) | **Anual** (referência: última 4ª feira de maio; divulgação no mesmo ano/início do seguinte) | Dicionário XLSX no ZIP · Notas Estatísticas INEP |
| **IDEB** | Resultados por escola, município/rede, UF, Brasil (nota, meta, aprovação, Saeb) | XLSX/ODS por edição | Download INEP · dados.gov.br · BigQuery/BD · Power BI público | 2005 → 2023 (edição 2025 sai em 2026) | **Bienal** (anos ímpares), divulgação ~1 ano depois | Nota Técnica nº 1 · nota informativa por edição |

---

## 8. Observações transversais

1. **Rota recomendada permanece BigQuery/basedosdados.org** para as 6 bases (decisão do [[Documentação_Fabric/Dados Públicos/Saude_Educacao/00_INDEX_SAUDE_EDUCACAO|índice]]) — e a verificação desta data **remove o principal risco apontado**: CNES e SIH estão atualizados até abril–maio/2026 na BD.
2. **Fallbacks documentados:** FTP+PySUS (DATASUS) e download direto (INEP) são as fontes primárias caso a réplica BD atrase em algum ciclo.
3. **PCDaS/Fiocruz** é uma terceira rota relevante para SIH/SIM/SINASC/CNES: dado enriquecido, CSV, atualização trimestral — útil como referência de metodologia ETL mesmo se não for usada como fonte.
4. **OpenDataSUS migrou** para `dadosabertos.saude.gov.br` — atualizar qualquer referência antiga.
5. Regras já estabelecidas nos docs individuais continuam valendo: CNES antes de SIM/SINASC/SIH (lookup `codCnes`); Censo Escolar antes do IDEB; nunca tratar ano recente de SIM/SINASC como definitivo; não interpolar IDEB entre edições.

---

**Criado em:** 2026-07-02 · **Validação web:** 2026-07-02 · **Mantido por:** Victor Silva
**Fonte da verdade (repositório local):** `dados_saude_educacao/ref/MAPEAMENTO_FONTES_COMPLETO.md`
