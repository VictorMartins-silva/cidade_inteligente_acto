---
title: Mapeamento de Painéis Power BI — Santos
tags:
  - municipio/santos
  - ferramenta/powerbi
  - mapeamento
  - padronizacao
date: 2026-04-14
aliases:
  - paineis pbi santos
  - dashboards santos
---

# Mapeamento de Painéis Power BI — Santos

> [!info] Contexto
> Mapeamento completo dos 19 dashboards Power BI do workspace `lh_cidade_inteligente_santos`, gerado a partir da análise dos PDFs em [[Documentação_Fabric/Powerbi-Santos/00_INDEX_PBI_SANTOS|Índice PowerBI Santos]]. Referência técnica em [[DOCUMENTACAO_CONSOLIDADA_FABRIC]].
>
> Fonte de dados de cada painel: tabelas Gold do Lakehouse — ver [[codigos_catalogos_etapas_santos]] para os domínios mapeados.

---

## Visão Geral

| Família                        | Dashboards | Padronizado |
| ------------------------------ | ---------- | ----------- |
| 1 — Acompanhamento de Serviços | 5          | Sim         |
| 2 — Manifestações de Ouvidoria | 5          | Sim         |
| 3 — Avaliações de Serviços     | 1          | Parcial     |
| 4 — Carta de Serviços          | 1          | Diferente   |
| 5 — Obras / PDR I              | 5          | Não         |
| 6 — Curso de Motorista         | 2          | Diferente   |
| **Total**                      | **19**     |             |

---

## Família 1 — Acompanhamento de Serviços

Dashboards operacionais por secretaria. Template padrão InMov com 4 abas.

| Painel | Domínio | Tabela Gold |
|---|---|---|
| [[Powerbi-Santos/acompanhamento_servicos_segov.pdf|Acompanhamento SEGOV]] | [[codigos_catalogos_etapas_santos#3. SEGOV|SEGOV]] | `gold_segov_servicos` |
| [[Powerbi-Santos/acompanhamento_servicos_seinfra.pdf|Acompanhamento SEINFRA]] | [[codigos_catalogos_etapas_santos#4. SEINFRA|SEINFRA]] | `gold_seinfra_servicos` |
| [[Powerbi-Santos/acompanhamento_servicos_cet.pdf|Acompanhamento CET]] | [[codigos_catalogos_etapas_santos#2. CET|CET]] | `gold_cet_servicos` |
| [[Powerbi-Santos/acompanhamento_servicos_sepref.pdf|Acompanhamento SEPREF]] | [[codigos_catalogos_etapas_santos#5. SEPREF|SEPREF]] | `gold_sepref_servicos` |
| [[Powerbi-Santos/acompanhamento_servicos_ouvidoria.pdf|Acompanhamento Ouvidoria]] | Ouvidoria | `gold_ouvidoria_servicos` |

### Estrutura Padrão (4 Abas)

**Aba 1 — Ordens em Aberto – Visão Geral**
- KPI SLA: % Prazo Vencido / Dentro do prazo / Vence hoje
- OS por serviço · por canal · por etapa · por Unidade Executora · por Bairro
- Ranking de solicitantes
- Mapa geolocalizado (TomTom/OSM — Grayscale Light)

**Aba 2 — Gestão de Prazos – OS em Aberto**
- Gráfico de OS por dia (média móvel 7 dias)
- OS com prazo vencido vs dentro do prazo por serviço
- Tabela: dias desde/até o vencimento por OS

**Aba 3 — Análise de Ordens Finalizadas**
- % OS dentro/fora do prazo (finalizadas)
- Tempo médio de finalização por serviço e Unidade Executora
- OS por bairro, canal, solicitante

**Aba 4 — Base de Dados Detalhada**
- Tabela completa: OS · Serviço · Status · Etapa · Prazo · Dias restantes · Tempo realizado

> [!tip] Aba Extra — CET
> O dashboard [[Powerbi-Santos/acompanhamento_servicos_cet.pdf|CET]] possui uma 5ª aba exclusiva: **Autorização Carga e Descarga**, com análise de horários, períodos (manhã/tarde/noite), dias da semana e taxa de deferimento das autorizações temporárias.

---

## Família 2 — Manifestações de Ouvidoria

Mesma estrutura da Família 1, filtrada por secretaria de destino das manifestações.

| Painel                                                                                      | Escopo            | Observação                             |
| ------------------------------------------------------------------------------------------- | ----------------- | -------------------------------------- |
| [[Powerbi-Santos/acompanhamento_servicos_manif_ouvidoria.pdf|Ouvidoria — Geral]]           | Todos os domínios | Dashboard principal                    |
| [[Powerbi-Santos/acompanhamento_servicos_manif_ouvidoria_cet.pdf|Ouvidoria — CET]]         | CET               | Título com erro: "CE T" (espaço extra) |
| [[Powerbi-Santos/acompanhamento_servicos_manif_ouvidoria_segov.pdf|Ouvidoria — SEGOV]]     | SEGOV             | OK                                     |
| [[Powerbi-Santos/acompanhamento_servicos_manif_ouvidoria_seinfra.pdf|Ouvidoria — SEINFRA]] | SEINFRA           | Páginas 1-2 sem dados visíveis         |
| [[Powerbi-Santos/acompanhamento_servicos_manif_ouvidoria_sepref.pdf|Ouvidoria — SEPREF]]   | SEPREF            | OK                                     |

Diferença em relação à Família 1: destaque para **canal de atendimento** (Telefônico, Presencial, Correspondência, Portal/Aplicativo, WhatsApp, Redes Sociais) na Visão Geral.

**Tabela Gold:** `gold_manifestacoes_ouvidoria` — ver [[codigos_catalogos_etapas_santos#6. Ouvidoria]]

---

## Família 3 — Avaliações de Serviços

| Painel | Título | Páginas |
|---|---|---|
| [[Powerbi-Santos/acompanhamento_avaliacao_servicos.pdf|Avaliações de Serviços]] | AVALIAÇÕES DE SERVIÇOS - SANTOS | 4 |

**Abas:**
1. **Visão Geral** — % respondidas, expectativas (Atendidas/Frustradas/Superadas), ranking por % questão resolvida
2. **Avaliação do Serviço** — Nota média por serviço (0–5 ★), satisfação por mês, tabela com comentários
3. **Avaliação do Atendimento** — Nota de atendimento por OS
4. **Base de Dados Detalhada**

> [!warning] Template Diferente
> Este dashboard **não tem** o watermark "Desenvolvido por InMov". Template e origem distintos dos demais. KPIs são notas em estrelas (★/☆), não SLA de prazo.

**Tabelas Gold:** `gold_avaliacoes_servico` + `gold_avaliacoes_servicos_sentimento`

---

## Família 4 — Carta de Serviços

| Painel | Título | Páginas |
|---|---|---|
| [[Powerbi-Santos/acompanhamento_carta_servicos.pdf|Carta de Serviços]] | ACOMPANHAMENTO DA CARTA DE SERVIÇOS | 4 |

**Abas:**
1. **RESUMO DA CARTA** — 692 serviços publicados · 37 em tramitação · 28 secretarias · 25 categorias
2. **VALIDADE DA CARTA** — Serviços por tempo desde última atualização, ranking de mais desatualizados
3. **ATUALIZAÇÕES EM TRAMITAÇÃO** — Por secretaria, categoria e etapa de execução
4. **BASE DETALHADA**

> [!note] Escopo diferente
> Este painel gerencia o **catálogo de serviços** (metadados), não as OS operacionais. Sem KPI de SLA de execução e sem mapa. Tem rodapé InMov.

**Tabela Gold:** `gold_carta_servicos`

---

## Família 5 — Obras / PDR I

> [!danger] Pipeline Parado — R5 Crítico
> Todos os dashboards desta família estão potencialmente desatualizados. O pipeline de Obras está parado **desde 11/03/2025** por HTTP 401 no `nb_utils_api_acto_gestao_obras`.
> Correção: adicionar `try/except HTTPError 401 → login_acto_gestao_obras() → retry`.
> Ver [[Documentação_Fabric/_obsoleto/Relatório Técnico_ Arquitetura, Mapeamento e Otimização — Microsoft Fabric|Relatório Técnico Fabric]].

| Painel                                                                                            | Título                                     | Abas | Observação                            |
| ------------------------------------------------------------------------------------------------- | ------------------------------------------ | ---- | ------------------------------------- |
| [[Powerbi-Santos/obras/pbi_obras_santos_acomp_solicitacoes.pdf|Acomp. Solicitações Obras]]       | ACOMP. SOLICITAÇÕES - OBRAS                | 3    | Sem aba "Gestão de Prazos"            |
| [[Powerbi-Santos/obras/pbi_obras_santos_seman_acomp_solicitacoes.pdf|Acomp. Solicitações SEMAM]] | ACOMP. SOLICITAÇÕES - SEMAM/SEMAN          | 3    | Título inconsistente (SEMAM vs SEMAN) |
| [[Powerbi-Santos/obras/pbi_obras_santos_pdr.pdf|PDR I]]                                          | PDR I — Participação Direta nos Resultados | 2    | Tabela execução por executor/etapa    |
| [[Powerbi-Santos/obras/pbi_santos_obras_seont_os.pdf|SEONT — Analistas]]                         | ACOMP. PROCESSOS ANALISTAS - SEONT         | 2    | Por zona Z1/Z2/Z3 + analista          |

**Tabelas Gold:** `gold_pdr_acompanhamentos_os` · `gold_obras_tempo_etapa` · `gold_acto_gestao_obras_seont_os`

---

## Família 6 — Curso de Motorista

| Painel | Páginas |
|---|---|
| [[Powerbi-Santos/acompanhamento_servicos_curso_motorista.pdf|Curso de Motorista]] | 1 |
| [[Powerbi-Santos/acompanhamento_servicos_curso_motorista_cet.pdf|Curso de Motorista CET]] | 1 |

**Elementos (1 página única):**
- Funil de conversão: Inscrições → Deferidos → Aprovados/Reprovados
- KPIs: Taxa de Deferimento · Taxa de Evasão
- Frequência diária por dia do curso (D1–D7) — gráfico presença/ausência
- Resultados de satisfação (carga horária, instrutores, clareza, aplicabilidade)
- Tabela por aluno com status e presença

**Tabela Gold:** `gold_curso_motoristas`

---

## Diagnóstico de Padronização

### Elementos Padrão Confirmados (Famílias 1 e 2)

- Watermark InMov (`Desenvolvido por InMov - Copyright Prefeitura Municipal de Santos`)
- 4 abas na ordem: Visão Geral → Gestão de Prazos → Análise Finalizadas → Base Detalhada
- Filtros padrão: Status OS · Etapa · Serviço · Ano · Mês · Prazo · Unidade · Bairro + Limpar Filtros
- KPI SLA em donut (Vencido / Dentro do prazo / Vence hoje)
- Tabela dias desde/até vencimento
- Gráfico de abertura diária com média móvel 7 dias
- Mapa Grayscale (TomTom/OSM)

### Desvios e Problemas Identificados

> [!bug] D1 — Avaliações com Template Diferente
> Sem watermark InMov. Abas, KPIs e filtros completamente distintos dos painéis operacionais. Ver [[Powerbi-Santos/acompanhamento_avaliacao_servicos.pdf|PDF]].

> [!bug] D7 — Alvará Obras INACABADO
> Aba "Rascunho" visível no PDF. 5 abas inconsistentes (Visão geral · Metas · Tabelas · **Rascunho** · Resumo). Dashboard não deve estar em produção. Ver [[Powerbi-Santos/obras/acompanhamento_alvara_obras_santos_prototipo.pdf|PDF]].

> [!warning] D9 — Ouvidoria SEINFRA sem Dados
> Páginas 1-2 do [[Powerbi-Santos/acompanhamento_servicos_manif_ouvidoria_seinfra.pdf|PDF]] sem métricas visíveis. Possível ausência de dados no período ou filtro zerado.

> [!warning] D10 — Inconsistências de Nomenclatura
> - "MANIFESTAÇÕES DE OUVIDORIA - **CE T**" (espaço extra no título CET)
> - "ACOMPANHAMENTO DE SERVIÇOS **-SEGOV**" (sem espaço antes do hífen)
> - "ACOMPANHAMENTO DE **SOLICITAÇÕES** - OBRAS" (vs "**SERVIÇOS**" dos demais)
> - "**SEMAM**" no header vs "**SEMAN**" no título do mesmo PDF

| #   | Painel                                                                                    | Tipo                   | Detalhe                                         |
| --- | ----------------------------------------------------------------------------------------- | ---------------------- | ----------------------------------------------- |
| D1  | [[Powerbi-Santos/acompanhamento_avaliacao_servicos.pdf|Avaliações]]                      | Template diferente     | Sem watermark; KPIs em estrelas                 |
| D2  | [[Powerbi-Santos/acompanhamento_carta_servicos.pdf|Carta de Serviços]]                   | Escopo diferente       | Foco em catálogo, não em OS                     |
| D3  | [[Powerbi-Santos/acompanhamento_servicos_cet.pdf|CET]]                                   | Aba extra              | "Autorização Carga e Descarga" (justificada)    |
| D4  | [[Powerbi-Santos/obras/pbi_obras_santos_acomp_solicitacoes.pdf|Obras Acomp.]]            | Abas reduzidas         | 3 abas, sem "Gestão de Prazos"                  |
| D5  | [[Powerbi-Santos/obras/pbi_obras_santos_pdr.pdf|PDR I]]                                  | Estrutura livre        | Tabela de produtividade, sem padrão             |
| D6  | [[Powerbi-Santos/obras/pbi_santos_obras_seont_os.pdf|SEONT]]                             | Sem padrão             | Analistas/zonas; 2 abas próprias                |
| D7  | [[Powerbi-Santos/obras/acompanhamento_alvara_obras_santos_prototipo.pdf|Alvará Obras]]   | **INACABADO**          | Aba "Rascunho" visível                          |
| D8  | [[Powerbi-Santos/acompanhamento_servicos_curso_motorista.pdf|Curso Motorista]]           | Domínio isolado        | 1 página; sem SLA/mapa                          |
| D9  | [[Powerbi-Santos/acompanhamento_servicos_manif_ouvidoria_seinfra.pdf|Ouvidoria SEINFRA]] | Dados ausentes         | Possível ausência de dados                      |
| D10 | Múltiplos                                                                                 | Títulos inconsistentes | "CE T", "-SEGOV", "SOLICITAÇÕES", "SEMAM/SEMAN" |
| D11 | [[Powerbi-Santos/acompanhamento_servicos_segov.pdf|SEGOV]]                               | Formatação             | Espaço faltante antes do hífen                  |

---

## SLA por Domínio (extraído dos painéis)

| Domínio | Finalizadas Dentro Prazo | Em Aberto Dentro Prazo | Status |
|---|---|---|---|
| CET | 99,37% | 99,58% | Excelente |
| SEGOV | 96,91% | 100% | Bom |
| OUVIDORIA | 73,6% | — | Regular |
| SEINFRA | 61,82% | ~47% | Alto atraso |
| SEPREF | — | 40,79% | Crítico |
| Manif. SEINFRA | 46,88% dentro | — | Pior SLA |
| OBRAS | N/A | N/A | Pipeline parado |

---

## Correlação Gold → Power BI

| Tabela Gold | Dashboard |
|---|---|
| `gold_segov_servicos` | [[Powerbi-Santos/acompanhamento_servicos_segov.pdf|Família 1 — SEGOV]] |
| `gold_seinfra_servicos` | [[Powerbi-Santos/acompanhamento_servicos_seinfra.pdf|Família 1 — SEINFRA]] |
| `gold_cet_servicos` | [[Powerbi-Santos/acompanhamento_servicos_cet.pdf|Família 1 — CET]] |
| `gold_cet_carga_descarga` | [[Powerbi-Santos/acompanhamento_servicos_cet.pdf|Família 1 — CET (Carga e Descarga)]] |
| `gold_sepref_servicos` | [[Powerbi-Santos/acompanhamento_servicos_sepref.pdf|Família 1 — SEPREF]] |
| `gold_ouvidoria_servicos` | [[Powerbi-Santos/acompanhamento_servicos_ouvidoria.pdf|Família 1 — Ouvidoria]] |
| `gold_manifestacoes_ouvidoria` | [[Powerbi-Santos/acompanhamento_servicos_manif_ouvidoria.pdf|Família 2 — todas (5 dashboards)]] |
| `gold_avaliacoes_servico` | [[Powerbi-Santos/acompanhamento_avaliacao_servicos.pdf|Família 3 — Avaliações]] |
| `gold_avaliacoes_servicos_sentimento` | [[Powerbi-Santos/acompanhamento_avaliacao_servicos.pdf|Família 3 — Avaliações]] |
| `gold_carta_servicos` | [[Powerbi-Santos/acompanhamento_carta_servicos.pdf|Família 4 — Carta de Serviços]] |
| `gold_pdr_acompanhamentos_os` | [[Powerbi-Santos/obras/pbi_obras_santos_acomp_solicitacoes.pdf|Família 5 — Obras Acomp.]] |
| `gold_obras_tempo_etapa` | [[Powerbi-Santos/obras/pbi_obras_santos_pdr.pdf|Família 5 — PDR I]] |
| `gold_curso_motoristas` | [[Powerbi-Santos/acompanhamento_servicos_curso_motorista.pdf|Família 6 — Curso de Motorista]] |

---

## Links Relacionados

- [[codigos_catalogos_etapas_santos|Tabela de Códigos — Catálogos e Etapas]]
- [[DOCUMENTACAO_CONSOLIDADA_FABRIC|Documentação Consolidada do Fabric]]
- [[Documentação_Fabric/_obsoleto/Relatório Técnico_ Arquitetura, Mapeamento e Otimização — Microsoft Fabric|Relatório Técnico Fabric]]
- [[Mapeamento Técnico de Notebooks — Município de Santos|Mapeamento de Notebooks]]
- [[roadmap_acto_fabric|Roadmap Acto Fabric]]
- [[plano_extracao_via_excel_santos|Plano de Extração via Excel]]
