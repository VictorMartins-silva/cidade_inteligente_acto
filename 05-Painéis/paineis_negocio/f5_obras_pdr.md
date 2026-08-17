---
title: "F5 — Obras / PDR I"
tags:
  - ferramenta/powerbi
  - tipo/documentacao
  - pendente-analista
  - pipeline-parado
status: em-construção
---

# F5 — Obras / PDR I

> [!info] Como usar este documento
> Os campos marcados com **`[!todo]`** precisam ser preenchidos pela analista de negócio.
> Os campos já preenchidos vieram do mapeamento técnico — valide se estão corretos.

---

## Painéis desta família

| Arquivo Power BI | Título no painel | Abas | Foco |
|---|---|---|---|
| `pbi_obras_santos_acomp_solicitacoes` | ACOMPANHAMENTO DE SOLICITAÇÕES - OBRAS | 3 | OS de obras em geral |
| `pbi_obras_santos_seman_acomp` | ACOMP. DE SOLICITAÇÕES - SEMAN | 3 | Licenciamento ambiental (SEMAN) |
| `pbi_obras_santos_pdr` | PDR I — Participação Direta nos Resultados | 2 | Produtividade por executor/setor |
| `pbi_santos_obras_seont_os` | ACOMPANHAMENTO DE PROCESSOS POR ANALISTAS - SEONT | 2 | Analistas por zona territorial |
| `acomp_alvara_obras_santos_prototipo` | PDR I _(protótipo)_ | 5 | **Inacabado — aba "Rascunho" visível** |

> [!danger] Pipeline parado desde 11/03/2025
> **Todos os painéis desta família estão sem atualização de dados desde 11/03/2025** devido a erro HTTP 401 na API de Obras (issue R5 Crítico). Os dados exibidos nos painéis podem estar desatualizados em mais de um ano. Qualquer análise de negócio deve considerar essa limitação. Aguarda correção técnica no `nb_utils_api_acto_gestao_obras`.

---

## Objetivo de Negócio

> [!todo] Preencher — Analista de Negócio
> Esta família tem **4 painéis com escopos diferentes**. Descrever o objetivo de cada um:
> 1. **Acomp. Solicitações — Obras:** _[preencher]_
> 2. **Acomp. Solicitações — SEMAN:** _[preencher — o que é SEMAN? Secretaria de Meio Ambiente?]_
> 3. **PDR I:** _[preencher — o que é "Participação Direta nos Resultados"?]_
> 4. **SEONT — Analistas:** _[preencher — o que é SEONT? Qual a função dos analistas?]_

---

## Público-alvo

> [!todo] Preencher — Analista de Negócio
> - Acomp. Obras / SEMAN: gestores de obras, secretaria responsável?
> - PDR I: diretoria, RH, gestores de equipe para avaliação de produtividade?
> - SEONT: coordenadores de equipe de analistas de obras?

---

## Perguntas que o painel responde

> [!todo] Preencher — Analista de Negócio
> Exemplos por painel:
> **Acomp. Solicitações Obras/SEMAN:**
> - Quantas OS de obras estão abertas e qual o status de prazo?
> - Qual zona da cidade (Z1/Z2/Z3) concentra mais solicitações?
>
> **PDR I:**
> - Qual é a produtividade de cada executor/setor?
> - Qual é o tempo médio de execução por tipo de OS?
>
> **SEONT:**
> - Quais analistas têm OS abertas há mais de 30/60 dias?
> - Como está distribuída a carga por zona territorial?

---

## Detalhes por Painel

### Painel 1 — Acompanhamento de Solicitações (Obras e SEMAN)

**Abas (3 — sem "Gestão de Prazos" do padrão):**

1. **Ordens em Aberto** — KPI SLA, OS por serviço, por zona (Z1/Z2/Z3), mapa por zona
2. **Ordens Finalizadas** — % dentro/fora do prazo, tempo médio de finalização
3. **Base de Dados** — Tabela completa de OS

**Especificidades:**
- Header: "PDR I · Prefeitura de Santos (Participação Direta nos Resultados)"
- Inclui mapa por zona territorial (Z1, Z2, Z3) — diferente do mapa por bairro das Famílias 1 e 2
- Período de dados: 01/01/2024 – 09/04/2026 (Obras) / 01/01/2024 – 09/03/2026 (SEMAN)

**Filtros específicos do SEMAN:**
- Licença Prévia
- Licença de Instalação
- Licença de Operação
- Manifestação Técnica Ambiental

> [!todo] Tipos de licença SEMAN
> O que é cada tipo de licença? Qual é o fluxo de aprovação de cada uma?
> Há SLA específico por tipo de licença ambiental?

> [!todo] Sigla SEMAN
> Confirmar: SEMAN = Secretaria de Meio Ambiente de Santos? Verificar se "SEMAM" (encontrado no header do painel) é grafia alternativa ou erro — sigla correta deve ser padronizada.

---

### Painel 2 — PDR I (Produtividade)

**Abas (2):**

1. **Tabela de OS** — OS · Serviço · Etapa · Data Início · Data Fim · Tempo Execução · Executor · Duração Dias
2. **Resumo por Aux Setor** — Total OS · Duração total · Média Duração (dias) por Auxiliar de Setor Responsável

> [!todo] O que é PDR I?
> "Participação Direta nos Resultados" — é um programa de incentivo / produtividade da prefeitura?
> Como os dados do PDR são usados: avaliação de desempenho, bonificação, planejamento de equipe?
> Quem são os "Auxiliares de Setor" listados no painel?

---

### Painel 3 — SEONT (Analistas por Zona)

**Abas (2):**

1. **Seont – Analistas** — OS por analista responsável, distribuídas por zona (Z1/Z2/Z3)
   - Indicadores: **OS > 30 Dias**, **OS > 60 Dias**, **Máximo de Dias** em aberto
2. **Tabela** — OS · Status · Serviço · Bairro · Zona · Etapa · Analista Responsável · Data início · Dias na etapa

> [!todo] O que é SEONT?
> SEONT = Secretaria de Obras? Qual é a sigla completa e responsabilidade?
> Os analistas são técnicos de fiscalização? Engenheiros? Servidores de outra função?
> As zonas Z1/Z2/Z3 seguem qual delimitação geográfica?

---

### Painel 4 — Alvará de Obras (Protótipo)

> [!danger] NÃO usar em produção
> Este painel está **inacabado**: possui aba "Rascunho" visível, escala de fontes fora do padrão (80pt/60pt/40pt), 5 abas sem estrutura definida. Foi incluído na pasta de produção indevidamente. Aguarda decisão sobre continuidade ou descarte.

> [!todo] Status do protótipo de alvará
> Este painel de Alvará de Obras será desenvolvido? Qual é o objetivo de negócio planejado?
> Quem é o responsável pelo desenvolvimento? Existe prazo para conclusão?

---

## Indicadores e Métricas (KPIs)

| Indicador | Painel | Definição de negócio |
|---|---|---|
| OS em aberto por zona | Obras/SEMAN | _[preencher]_ |
| % SLA dentro do prazo | Obras/SEMAN | _[preencher]_ |
| Tempo médio de execução (dias) | PDR I | _[preencher]_ |
| Total OS por executor | PDR I | _[preencher]_ |
| OS > 30 dias | SEONT | _[preencher — é um alerta operacional?]_ |
| OS > 60 dias | SEONT | _[preencher — aciona escalada?]_ |
| Máximo de dias em aberto | SEONT | _[preencher]_ |

---

## Origem dos Dados

| Painel | Tabela Gold (Fabric) | Notebook de carga |
|---|---|---|
| Acomp. Obras / SEMAN | `gold_pdr_acompanhamentos_os` | `nb_gold_acto_gestao_obras` |
| PDR I (produtividade) | `gold_obras_tempo_etapa` | `nb_gold_acto_gestao_obras_etapas` |
| SEONT | `gold_acto_gestao_obras_seont_os` | `nb_gold_acto_gestao_obras_seont_os` |
| Alvará (protótipo) | _Em desenvolvimento_ | _—_ |

**Fonte primária:** API Acto Gestão (endpoint de Obras) → Lakehouse `lh_cidade_inteligente_santos`

> [!todo] Frequência de atualização planejada
> Quando o pipeline for restabelecido (correção R5), qual será a frequência de atualização esperada?

---

## Regras de Negócio

> [!todo] Preencher — Analista de Negócio
> Exemplos:
> - Como uma OS de obras é diferente de uma OS operacional (Famílias 1 e 2)?
> - Quais tipos de serviços estão incluídos em "obras"?
> - As zonas Z1/Z2/Z3 têm equipes dedicadas ou é apenas agrupamento geográfico?
> - O PDR gera algum indicador formal de desempenho com consequências para os servidores?

---

## Glossário

> [!todo] Preencher — Analista de Negócio

| Termo | Definição |
|---|---|
| PDR I | _[preencher — sigla completa e contexto]_ |
| SEONT | _[preencher — sigla completa e responsabilidade]_ |
| SEMAN | _[preencher — confirmar sigla e responsabilidade]_ |
| Zona (Z1/Z2/Z3) | _[preencher — delimitação geográfica]_ |
| Aux Setor Responsável | _[preencher — cargo/função]_ |
| Analista Responsável | _[preencher — cargo/função]_ |

---

## Alertas e Limitações Conhecidas

> [!danger] Dados parados desde 11/03/2025
> O pipeline de Obras tem HTTP 401 desde 11/03/2025. Todos os indicadores desta família estão congelados nessa data. **Não usar os dados para tomada de decisão até a correção do pipeline.**

> [!warning] Fonte tipográfica diferente do padrão
> Os painéis de Obras usam `SegoeUI-Semibold` em vez do `SegoeUI-Bold` padrão das Famílias 1 e 2. Visualmente perceptível mas não bloqueia o uso. Aguarda correção visual.

> [!warning] Sem watermark InMov
> Todos os 4 painéis de Obras estão sem o rodapé "Desenvolvido por InMov". Aguarda inclusão.

> [!bug] Título inconsistente SEMAM/SEMAN
> O painel SEMAN tem "SEMAM" no header e "SEMAN" no título principal. A sigla correta precisa ser confirmada e padronizada.
