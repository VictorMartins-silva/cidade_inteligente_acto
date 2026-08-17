---
title: "Insights e Decisões — Dados Públicos"
tags:
  - insights
  - decisoes
  - tema/dados-publicos
  - validacao
aliases:
  - insights dados públicos
  - decisões fabric dados públicos
revisao: "2026-05-04"
---

# Insights e Decisões — Dados Públicos

Registro de achados analíticos e decisões técnicas relevantes do projeto `lh_dados_publicos`.

Relacionado: [[00_INDEX_DADOS_PUBLICOS]] · [[fase3_entrega_dados_publicos]] · [[GUIA_MESTRE_DADOS_PUBLICOS]]

---

## Insights Analíticos

### Disparidade de Formalização — São Caetano vs Carapicuíba (2022)

> [!example] Insight de Ouro — Validado em 04/05/2026
> A validação cruzada `gold_mercado_trabalho` (RAIS) ÷ `gold_populacao_municipios` confirmou uma **disparidade de 59 pontos percentuais** no índice de formalização entre municípios do mesmo estado:
>
> | Município | Cluster | Vínculos RAIS | População | % Formalização |
> |---|---|---|---|---|
> | São Caetano do Sul | OSASCO | 114.644 | 165.655 | **69,2%** |
> | Santos | SANTOS | 187.791 | 418.608 | 44,9% |
> | Osasco | OSASCO | 198.454 | 728.615 | 27,2% |
> | Mauá | MAUA | 74.514 | 418.261 | 17,8% |
> | São Vicente | SANTOS | 36.787 | 329.911 | 11,2% |
> | Carapicuíba | MAUA | 39.777 | 386.984 | **10,3%** |
>
> **Conclusão:** A camada Gold valida que municípios geograficamente próximos têm mercados de trabalho radicalmente diferentes. São Caetano (polo industrial consolidado) tem formalização 6,7× maior que Carapicuíba (periferia metropolitana).

**Query de validação:** `nb_validacao_dados` → célula `val-cross` · JOIN por `id_municipio` (7 dígitos IBGE)

---

### Saldo CAGED — Recuperação Pós-2020 Confirmada

> [!info] Padrão observado em todos os 3 clusters
> 2020: Saldo negativo (pandemia)
> 2021: Recuperação forte em todos os clusters
> 2022–2025: Crescimento contínuo — OSASCO lidera em volume absoluto

| Cluster | 2020 | 2021 | 2022 | 2023 | 2024 | 2025 |
|---|---|---|---|---|---|---|
| MAUA | -342 | +10.001 | +6.238 | +5.306 | +7.539 | +7.772 |
| OSASCO | -4.142 | +46.382 | +23.720 | +7.522 | +27.111 | +31.095 |
| SANTOS | -8.644 | +15.775 | +10.695 | +11.043 | +14.096 | +7.603 |

---

## Decisões Técnicas

### Arquitetura de Ingestão CAGED

> [!warning] Decisão — 04/05/2026
> **`nb_ingest_caged` (BigQuery) é prototipagem, não produção.**
> Alinhado com Yuri em 04/05: o processo de produção será via FTP MTE (`ftp.mtps.gov.br/pdet/microdados/NOVO CAGED/`). Yuri assume a responsabilidade. O notebook BigQuery serve apenas para validação da gold até o FTP estar pronto.

### JOIN por id_municipio — Padrão Obrigatório

> [!warning] Decisão — 04/05/2026
> Nunca fazer JOIN por `nome_municipio` entre tabelas Gold. As tabelas têm formatos diferentes:
> - `gold_censo_*`: usa `municipio` com sufixo `" (SP)"`
> - `gold_mercado_trabalho` e `gold_populacao_municipios`: usa `nome_municipio` sem sufixo
>
> **Padrão:** sempre usar `id_municipio` (código IBGE 7 dígitos) como chave de JOIN.

### silver_nova_caged_sp — Candidata a Limpeza

> [!warning] Decisão — 04/05/2026
> Tabela `silver_nova_caged_sp` no lakehouse não tem uso confirmado no Gold. É uma staging FTP do Yuri que cobre todo o SP sem filtro de município. Confirmar com Yuri antes de dropar.

---

*Insights e Decisões · Acto Cidade Inteligente · Dados Públicos · 04/05/2026*
