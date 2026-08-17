---
title: "Censo Escolar — INEP"
tags:
  - tipo/referencia-tecnica
  - tema/dados-publicos
  - tema/educacao
status: ativo
revisao: "2026-07-02"
relacionados:
  - "[[Documentação_Fabric/Dados Públicos/Saude_Educacao/00_INDEX_SAUDE_EDUCACAO]]"
  - "[[Documentação_Fabric/Dados Públicos/Saude_Educacao/MAPEAMENTO_FONTES_COMPLETO]]"
  - "[[Documentação_Fabric/Dados Públicos/Saude_Educacao/IDEB_Referencia]]"
---

# Censo Escolar — INEP

> [[Documentação_Fabric/Dados Públicos/Saude_Educacao/00_INDEX_SAUDE_EDUCACAO|← Índice Saúde e Educação]]

## 1. Fontes candidatas

| Rota | Origem | Prós | Contras |
|---|---|---|---|
| **BigQuery (basedosdados.org)** ⭐ recomendada | Dataset `basedosdados.br_inep_censo_escolar` — 4 tabelas (escola, turma, matrícula, docente) | Mesma infraestrutura GCP já usada (RAIS). Evita parsear os arquivos CSV pipe-delimited enormes do INEP manualmente; schema já harmonizado ano a ano (nomes de coluna mudam nos brutos do INEP entre edições). | Confirmar defasagem entre publicação oficial do INEP e replicação na Base dos Dados a cada novo ano-base. |
| Microdados oficiais INEP (`download.inep.gov.br`) | Arquivos CSV brutos, delimitador `\|`, um pacote por ano | Fonte primária, dado mais recente possível assim que o INEP publica. Inclui dicionário de dados (XLSX) e tabelas auxiliares. | Arquivos grandes (matrícula/docente por região), schema muda entre anos (exige normalização manual a cada edição), sem API — apenas download direto do arquivo zip anual. |

## 2. Acesso

- **BigQuery:** `basedosdados.br_inep_censo_escolar.*` — tabelas por unidade de análise: **escola**, **turma**, **matrícula** e **função docente**.
- **INEP direto:** `https://www.gov.br/inep/pt-br/acesso-a-informacao/dados-abertos/microdados/censo-escolar` — download de pacote ZIP anual, sem autenticação, sem API REST.

## 3. Periodicidade na fonte

- Coleta **anual**, com dia de referência na última quarta-feira de maio (Dia Nacional do Censo Escolar).
- Publicação dos microdados definitivos ocorre no **mesmo ano de referência** (após etapas de verificação/validação pelos gestores escolares) — geralmente entre o fim do ano de coleta e o início do ano seguinte.

## 4. Schema e granularidade

- Granularidade: múltiplos níveis — **escola**, **turma**, **matrícula** (aluno) e **função docente**.
- Chave de junção com `gold.dim_municipio`: código do município (IBGE) presente na tabela de escola.
- Campos-chave: infraestrutura escolar, dependência administrativa (municipal/estadual/privada), matrículas por etapa/modalidade, número de docentes.

## 5. Volumetria estimada

- Para os 15 municípios do cluster: centenas de escolas, dezenas de milhares de matrículas por ano — volume moderado, mas a tabela de matrícula é a mais pesada (1 linha por aluno).

## 6. Estratégia de monitoramento/detecção de atualização recomendada

- Carga **anual**, disparada manualmente ou por checagem de nova edição publicada (INEP costuma anunciar a data de divulgação com antecedência — não há endpoint de metadados formal para polling automático).
- Se via BigQuery, monitorar quando a tabela do ano corrente aparecer no dataset da Base dos Dados (defasada em relação à publicação oficial do INEP).

## 7. Riscos/dependências

- **IDEB depende do Censo Escolar** (usa dados de aprovação/matrícula do Censo como insumo) — ingerir Censo Escolar antes ou em paralelo ao IDEB (ver [[Documentação_Fabric/Dados Públicos/Saude_Educacao/IDEB_Referencia|IDEB_Referencia]]).
- Mudança de schema entre edições anuais do INEP é conhecida — se optar pela rota oficial (não BigQuery), validar nomes de coluna a cada novo ano antes de rodar o pipeline.

---

**Fonte da verdade (repositório local):** `dados_saude_educacao/ref/Censo_Escolar_Referencia.md`
