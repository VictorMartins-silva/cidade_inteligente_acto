---
title: "Spec Drive — DATASUS (CNES/SIM/SINASC/SIH) + Censo Escolar/IDEB"
tags:
  - tipo/spec
  - tema/dados-publicos
  - tema/saude
  - tema/educacao
  - ferramenta/fabric
status: em-construção
revisao: "2026-07-02"
relacionados:
  - "[[Documentação_Fabric/Dados Públicos/spec_drive_dados_publicos]]"
  - "[[Documentação_Fabric/Dados Públicos/Mapeamento_Tecnico_Dados_Publicos]]"
  - "[[Documentação_Fabric/Dados Públicos/00_INDEX_DADOS_PUBLICOS]]"
  - "[[Documentação_Fabric/Dados Públicos/Saude_Educacao/00_INDEX_SAUDE_EDUCACAO]]"
---

# Spec Drive — DATASUS (CNES/SIM/SINASC/SIH) + Censo Escolar/IDEB

> [!tip] Para Claude
> Levantamento de fontes solicitado por Yuri Lucatelli Taba (Teams, 02/07/2026). A documentação técnica completa foi espelhada neste vault em [[Documentação_Fabric/Dados Públicos/Saude_Educacao/00_INDEX_SAUDE_EDUCACAO|Saude_Educacao/00_INDEX_SAUDE_EDUCACAO]] (6 referências técnicas + mapeamento consolidado). A fonte da verdade continua sendo o repositório local `dados_saude_educacao/` (paralelo a `geo_osasco/`). Este spec é o resumo executivo de alto nível.

**Última atualização:** 2026-07-02
**Status geral:** ==Pesquisa e documentação concluídas, incluindo mapeamento consolidado de subconjuntos/canais/URLs · Risco de defasagem do BigQuery resolvido (CNES e SIH atualizados até 2026) · Aguardando confirmação de acesso GCP e validação de Yuri para iniciar ingestão (fase 2)==

---

## Visão Geral

Levantamento de 5 fontes públicas de saúde e educação para ingestão no `lh_dados_publicos`, mesmo lakehouse que já recebe IBGE/SIDRA e RAIS ([[Documentação_Fabric/Dados Públicos/spec_drive_dados_publicos]]):

- **Saúde (DATASUS):** CNES (estabelecimentos), SIM (mortalidade), SINASC (nascidos vivos), SIH (internações hospitalares)
- **Educação (INEP):** Censo Escolar, IDEB

```mermaid
graph LR
    A[basedosdados.org / BigQuery] --> B[Bronze lh_dados_publicos]
    B --> C[Silver]
    C --> D[Gold]
    D --> E[Power BI]
```

**Decisão de rota:** todas as 5 fontes têm réplica tratada em `basedosdados.org` (BigQuery), a mesma infraestrutura já usada para o RAIS neste projeto. Rota recomendada para todas — evita parser DBC (DATASUS) e schema instável dos brutos INEP.

---

## Matriz de Fontes

| Fonte | Rota recomendada | Periodicidade na origem | Depende de | Doc técnica local |
|---|---|---|---|---|
| CNES | `basedosdados.br_ms_cnes` | Mensal | — (pré-requisito das demais) | `dados_saude_educacao/ref/DATASUS_CNES_Referencia.md` |
| SIM / SINASC | `basedosdados.br_ms_sim` / `br_ms_sinasc` | Anual, fechamento em 1–2 anos | CNES (lookup `codCnes`) | `dados_saude_educacao/ref/DATASUS_SIM_SINASC_Referencia.md` |
| SIH | `basedosdados.br_ms_sih` (ETL PCDaS) | Mensal, ~2 meses de defasagem | CNES (lookup `codCnes`) | `dados_saude_educacao/ref/DATASUS_SIH_Referencia.md` |
| Censo Escolar | `basedosdados.br_inep_censo_escolar` | Anual | — (pré-requisito do IDEB) | `dados_saude_educacao/ref/Censo_Escolar_Referencia.md` |
| IDEB | `basedosdados.br_inep_ideb` | **Bienal** | Censo Escolar (taxa de aprovação) | `dados_saude_educacao/ref/IDEB_Referencia.md` |

---

## Riscos e pontos de atenção transversais

1. Defasagem de atualização é muito heterogênea entre fontes (quase tempo real no CNES até bienal no IDEB) — painel final não pode assumir cadência única.
2. SIM/SINASC/SIH podem divergir entre "município de residência" e "município de ocorrência/hospital" — decidir por indicador antes de construir Gold.
3. Validar cobertura temporal real do BigQuery no momento da implementação (buscas indicaram possível defasagem, ex. CNES ~2021) antes de assumir que está atualizado.
4. IDEB não deve ser interpolado entre edições bienais.

---

## Procedimento Padrão (fase 2 — fora de escopo desta entrega)

1. Validar acesso ao dataset `basedosdados.*` no mesmo projeto GCP já usado para RAIS
2. Criar `nb_ingest_*` seguindo padrão de `nb_ingest_populacao_ibge` / `nb_ingest_cempre_ibge`
3. Ordem de ingestão: CNES → (SIM, SINASC, SIH em paralelo) · Censo Escolar → IDEB
4. Definir estratégia de monitoramento por fonte (comparação de competência/edição mais recente vs. última carregada)

---

## Referências Rápidas

| O que precisar | Onde encontrar |
|---|---|
| Documentação técnica completa por fonte | `dados_saude_educacao/ref/*.md` (repo local) |
| Índice do projeto de mapeamento | `dados_saude_educacao/00_INDEX.md` (repo local) |
| Precedente de estrutura (mapeamento geo SSP) | `geo_osasco/00_INDEX.md` (repo local) |
| Arquitetura geral de dados públicos | [[Documentação_Fabric/Dados Públicos/spec_drive_dados_publicos]] |
| Inventário de notebooks/tabelas existentes | [[Documentação_Fabric/Dados Públicos/Mapeamento_Tecnico_Dados_Publicos]] |
