---
title: "Índice — Documentação de Negócio dos Painéis Power BI"
tags:
  - ferramenta/powerbi
  - tipo/documentacao
  - tipo/indice
status: em-construção
aliases: ["paineis", "dashboard paineis", "f1 f2 f3"]
description: "Índice dos painéis de negócio (F1-F6) do projeto Acto Santos"
---
# Documentação de Negócio — Painéis Power BI Santos

**Workspace:** `lh_cidade_inteligente_santos`
**Responsável técnico:** Victor Silva
**Analista de Negócio:** _[preencher]_
**Início da documentação:** 2026-04-15

---

## Como usar esta documentação

Cada arquivo de família contém:

1. **Campos pré-preenchidos** — dados técnicos extraídos do mapeamento (abas, indicadores, tabelas Gold, filtros, limitações)
2. **Campos marcados com `[!todo]`** — perguntas e seções que precisam ser preenchidas pela **analista de negócio** após entrevista com os responsáveis de cada secretaria

### Fluxo de trabalho sugerido

```
Victor → passa os arquivos para a analista
Analista → entrevista responsáveis de cada secretaria
Analista → preenche os campos [!todo] em cada arquivo
Revisão conjunta → valida e publica documentação final
```

---

## Inventário de Painéis

| Família | Painéis | Arquivo | Status |
|---|---|---|---|
| [[f1_acompanhamento_servicos|F1 — Acomp. Serviços]] | SEGOV · SEINFRA · CET · SEPREF · OUVIDORIA (5 painéis) | [f1_acompanhamento_servicos.md](f1_acompanhamento_servicos.md) | Pendente analista |
| [[f2_manifestacoes_ouvidoria|F2 — Manifestações Ouvidoria]] | Geral · CET · SEGOV · SEINFRA · SEPREF (5 painéis) | [f2_manifestacoes_ouvidoria.md](f2_manifestacoes_ouvidoria.md) | Pendente analista |
| [[f3_avaliacao_servicos|F3 — Avaliação de Serviços]] | Avaliações Santos (1 painel) | [f3_avaliacao_servicos.md](f3_avaliacao_servicos.md) | Pendente analista |
| [[f4_carta_servicos|F4 — Carta de Serviços]] | Carta de Serviços (1 painel) | [f4_carta_servicos.md](f4_carta_servicos.md) | Pendente analista |
| [[f5_obras_pdr|F5 — Obras / PDR I]] | Obras · SEMAN · PDR I · SEONT · Alvará _(5 painéis)_ | [f5_obras_pdr.md](f5_obras_pdr.md) | ⚠️ Pipeline parado |
| [[f6_curso_motorista|F6 — Curso de Motorista]] | Gestão · CET (2 painéis) | [f6_curso_motorista.md](f6_curso_motorista.md) | Pendente analista |
| **Total** | **19 painéis** | | |

---

## O que a analista de negócio precisa fazer

Em cada arquivo, os campos `[!todo]` cobrem:

| Seção | O que preencher |
|---|---|
| **Objetivo de Negócio** | Por que este painel existe? Que decisão ele apoia? |
| **Público-alvo** | Quem usa e para quê? |
| **Perguntas que o painel responde** | As perguntas de negócio que motivaram o painel |
| **Definição de KPIs** | O que cada indicador significa para o negócio |
| **Regras de Negócio** | SLA, critérios, fluxos, cálculos de negócio |
| **Glossário** | Termos do domínio explicados para novos usuários |
| **Validações** | Confirmar dados pré-preenchidos com os responsáveis |

---

## Secretarias e contatos

> [!todo] Preencher — Responsável por cada domínio
> Incluir nome e contato do responsável de negócio em cada secretaria para facilitar as entrevistas.

| Domínio | Secretaria | Responsável | Contato |
|---|---|---|---|
| Serviços SEGOV | _[preencher]_ | _[preencher]_ | _[preencher]_ |
| Serviços SEINFRA | _[preencher]_ | _[preencher]_ | _[preencher]_ |
| Serviços CET | _[preencher]_ | _[preencher]_ | _[preencher]_ |
| Serviços SEPREF | _[preencher]_ | _[preencher]_ | _[preencher]_ |
| Ouvidoria | _[preencher]_ | _[preencher]_ | _[preencher]_ |
| Avaliações | _[preencher]_ | _[preencher]_ | _[preencher]_ |
| Carta de Serviços | _[preencher]_ | _[preencher]_ | _[preencher]_ |
| Obras / PDR I | _[preencher]_ | _[preencher]_ | _[preencher]_ |
| Curso Motorista (CET) | _[preencher]_ | _[preencher]_ | _[preencher]_ |

---

## Alertas Críticos Conhecidos (para contextualizar a analista)

> [!danger] F5 — Obras parada desde 11/03/2025
> Os 5 painéis da Família 5 (Obras) não recebem dados novos desde 11/03/2025 por falha de autenticação na API. Qualquer entrevista sobre o domínio de Obras deve mencionar essa limitação.

> [!warning] F3 — Avaliações fora do padrão visual
> O painel de Avaliações usa template diferente dos demais — não é falha de conteúdo, apenas visual. Dados estão corretos.

> [!bug] F5 — Protótipo de Alvará inacabado em produção
> O arquivo `acomp_alvara_obras_santos_prototipo` está na pasta de produção mas tem aba "Rascunho" visível. Não deve ser usado para análise de negócio até ser finalizado.

---

## Referências técnicas

- [[Documentação_Fabric/doc/mapeamento_paineis_powerbi_santos|Mapeamento técnico completo dos painéis]]
- [[Documentação_Fabric/doc/diagnostico_padronizacao_paineis_pbi_santos|Diagnóstico de padronização visual]]
- [[DOCUMENTACAO_CONSOLIDADA_FABRIC|Documentação consolidada do ambiente Fabric]]
