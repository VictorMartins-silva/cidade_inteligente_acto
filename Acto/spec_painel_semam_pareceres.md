---
title: "Spec — DEPCAM-SEMAM Pareceres Diversos"
tags: ["santos", "obras", "semam", "painel", "spec", "os-977435"]
municipio: Santos
status: em-desenvolvimento
os: "977435"
data: "2026-06-19"
relacionados:
  - "[[Documentação_Fabric/Acto/DOCUMENTACAO_TECNICA_ACTO]]"
  - "[[Documentação_Fabric/Acto/SCHEMA_LAKEHOUSE_ACTO]]"
---

# DEPCAM-SEMAM — Pareceres Diversos
**OS #977435** · Santos · Secretaria Municipal do Meio Ambiente

---

## Protótipo Visual

```
╔══════════════════════════════════════════════════════════════════════════════════╗
║  DEPCAM-SEMAM — PARECERES DIVERSOS                              SANTOS    🌿    ║
╠══════════════════════════════════════════════════════════════════════════════════╣
║  FILTROS                                                                        ║
║  Período: [ 01/01/2026 ] → [ 19/06/2026 ]  Técnico: [▾ Todos ]                 ║
║  Serviço: [▾ Todos                      ]  Situação: [▾ Todas ]  [Limpar ✕]    ║
╠════════════════╦════════════════╦════════════════╦════════════════════════════════╣
║  ENTRADAS      ║  SAÍDAS        ║  EM ANDAMENTO  ║  TEMPO MÉDIO (dias)           ║
║                ║                ║                ║                               ║
║     312        ║      287       ║      25        ║         14,3                  ║
║  pareceres     ║  concluídos    ║  em aberto     ║       por parecer             ║
║  recebidos     ║                ║                ║                               ║
╠═══════════════════════════════════════╦════════════════════════════════════════════╣
║  ENTRADAS vs SAÍDAS — por mês         ║  PRODUÇÃO POR TÉCNICO                     ║
║                                       ║                                           ║
║   50 ┤     ▐█▌                        ║  Ana Lima       ████████████████  87     ║
║   40 ┤  ▐█▌ ██  ▐█▌                   ║  João Silva     █████████████     64     ║
║   30 ┤  ██  ██  ██  ▐█▌               ║  Maria Costa    ████████████      52     ║
║   20 ┤  ██  ██  ██  ██  ▐█▌           ║  Pedro Alves    ██████████        41     ║
║   10 ┤  ██  ██  ██  ██  ██            ║  Carlos Melo    █████████         35     ║
║    0 └──────────────────────          ║  (outros 3)     ██████            28     ║
║      Jan Fev Mar Abr Mai Jun          ║                                           ║
║      ■ Entradas  □ Saídas             ║  Total distintos: 8 técnicos              ║
╠═══════════════════════════════════════╩════════════════════════════════════════════╣
║  DISTRIBUIÇÃO POR SERVIÇO                                                         ║
║                                                                                   ║
║  Álvará Constr. Sobreposta/Geminada   ████████████████████  98  (31,4%)          ║
║  Construção Nova – Unifamiliar        ████████████████      82  (26,3%)          ║
║  Reforma e/ou Legalização             █████████████         65  (20,8%)          ║
║  Alterações Diversas Proj. Aprovados  █████████             48  (15,4%)          ║
║  Demolição Total / Legalização        ██                    12  ( 3,8%)          ║
║  Demais (4 serviços)                  █                      7  ( 2,2%)          ║
╠═══════════════════════════════════════════════════════════════════════════════════╣
║  BASE DETALHADA                                                                   ║
║  ┌──────────┬───────────────────────────────┬───────┬─────────────┬─────────────┐ ║
║  │ OS       │ Serviço                       │ Etapa │ Técnico     │ Entrada     │ ║
║  │ Saída    │ Dias │ Situação               │       │             │             │ ║
║  ├──────────┼───────────────────────────────┼───────┼─────────────┼─────────────┤ ║
║  │ 45.231   │ Álvará Constr. Sobreposta...  │ 9     │ Ana Lima    │ 03/01/2026  │ ║
║  │ 14/01    │  11  │ ✅ Finalizada          │       │             │             │ ║
║  ├──────────┼───────────────────────────────┼───────┼─────────────┼─────────────┤ ║
║  │ 45.302   │ Reforma e/ou Legalização      │ 2     │ João Silva  │ 10/01/2026  │ ║
║  │ —        │ 160  │ 🔵 Em Atendimento      │       │             │             │ ║
║  ├──────────┼───────────────────────────────┼───────┼─────────────┼─────────────┤ ║
║  │ ...      │ ...                           │ ...   │ ...         │ ...         │ ║
║  └──────────┴───────────────────────────────┴───────┴─────────────┴─────────────┘ ║
╚═══════════════════════════════════════════════════════════════════════════════════╝
```

---

## Arquitetura Técnica

### Gold Table: `gold.santos_semam_pareceres`

**Grain:** uma linha por passagem de uma OS pela etapa SEMAM  
(uma OS de "Reforma" com etapas 1, 2, 3, 4 gera 4 linhas)

| Coluna | Tipo | Descrição | Uso no painel |
|---|---|---|---|
| `id_os` | string | Número da OS | Base Detalhada |
| `servico` | string | Nome do serviço | Filtro + gráfico distribuição |
| `etapa` | string | Nome completo da etapa SEMAM | Base Detalhada |
| `tecnico` | string | Executor da etapa | Filtro + gráfico produção |
| `solicitante` | string | Solicitante da OS | Base Detalhada |
| `dt_entrada` | timestamp | Início da etapa SEMAM = **Entrada** | KPI + série temporal |
| `dt_saida` | timestamp | Fim da etapa SEMAM = **Saída** (NULL = aberto) | KPI + série temporal |
| `dt_abertura_os` | timestamp | Data de abertura da OS | Contexto |
| `situacao` | string | "Finalizada" / "Em Atendimento" / "Pendente" | Filtro + KPI |
| `status_os` | string | Status geral da OS | Contexto |
| `dias_na_etapa` | integer | Dias entre entrada e saída (ou até hoje) | KPI tempo médio |
| `ano_mes_entrada` | string | "yyyy-MM" da entrada | Série temporal entradas |
| `ano_mes_saida` | string | "yyyy-MM" da saída | Série temporal saídas |

### Medidas DAX

```dax
-- KPI: Total Entradas no período
Entradas = COUNTROWS(
    FILTER('gold santos_semam_pareceres',
           'gold santos_semam_pareceres'[dt_entrada] >= MIN(Calendario[Data]) &&
           'gold santos_semam_pareceres'[dt_entrada] <= MAX(Calendario[Data])
    )
)

-- KPI: Total Saídas no período
Saidas = COUNTROWS(
    FILTER('gold santos_semam_pareceres',
           'gold santos_semam_pareceres'[dt_saida] >= MIN(Calendario[Data]) &&
           'gold santos_semam_pareceres'[dt_saida] <= MAX(Calendario[Data]) &&
           NOT ISBLANK('gold santos_semam_pareceres'[dt_saida])
    )
)

-- KPI: Em Andamento
Em Andamento = COUNTROWS(
    FILTER('gold santos_semam_pareceres',
           ISBLANK('gold santos_semam_pareceres'[dt_saida]) &&
           'gold santos_semam_pareceres'[situacao] = "Em Atendimento"
    )
)

-- KPI: Tempo Médio
Tempo Medio Dias = AVERAGE('gold santos_semam_pareceres'[dias_na_etapa])
```

### Filtros de Data — Atenção

O filtro de período no painel tem comportamento diferente para cada KPI:
- **Entradas**: filtra por `dt_entrada` no intervalo
- **Saídas**: filtra por `dt_saida` no intervalo  
- **Em Andamento**: `dt_saida IS NULL` (independente de período)
- **Série temporal**: eixo X baseado em `ano_mes_entrada` para entradas, `ano_mes_saida` para saídas

Recomendação: usar duas tabelas de calendário (Calendario_Entrada, Calendario_Saida) ou medidas DAX com `CALCULATE` + `USERELATIONSHIP`.

---

## Serviços e Etapas Capturados

| Serviço | Etapa(s) filtradas |
|---|---|
| Álvará de Construção Sobreposta e/ou Geminada | `9 - DEPCAM - SEMAM - Parecer Técnico Diversos` |
| Construção Nova de Edificações – Unifamiliar | `9 - DEPCAM - SEMAM - Parecer Técnico Diversos` |
| Álvará de Construção Nova – Condomínio Horizontal | `9 - DEPCAM - SEMAM - Parecer Técnico Diversos` |
| Álvará de Construção Pluri-Habitacional | `9 - DEPCAM - SEMAM - Parecer Técnico Diversos` |
| Novas Edificações Comercial, Serviços e/ou Misto | `9 - DEPCAM - SEMAM - Parecer Técnico Diversos` |
| Demolição Total / Legalização de Demolição | `DEPCAM - SEMAM - Parecer Diversos` (sem número) |
| Projeto Urbanístico | `6 - DEPCAM - SEMAM - Parecer Técnico Diversos` |
| Reforma e/ou Legalização | Etapas `1`, `2`, `3` e `4` — Parecer Técnico Diversos |
| Alterações Diversas em Projetos Aprovados | Etapas `1`, `2`, `3`, `4` e `5` — Parecer Técnico Diversos |

**Filtro aplicado no notebook:** `UPPER(etapa) CONTAINS 'SEMAM' OR UPPER(etapa) CONTAINS 'DEPCAM'`  
→ Captura todos os padrões acima independente de variações de número/formatação.

**Validação pós-execução:** rodar a célula de diagnóstico (célula 3) e confirmar que os nomes de etapa capturados correspondem aos listados acima.

---

## Notebook

**Arquivo:** [nb_gold_santos_semam_pareceres.ipynb](../nbs/nbs_gold/nb_gold_santos_semam_pareceres.ipynb)  
**Destino:** `gold.santos_semam_pareceres` (lh_solicitacoes_acto)  
**Dependência:** `silver.fato_etapas` + `silver.fato_solicitacoes` (fonte `santos_obras`)

### Checklist de ativação

- [ ] Executar célula 3 (diagnóstico) e validar nomes de etapa capturados
- [ ] Confirmar que `tecnico` NULL < 20% (etapas sem executor atribuído são esperadas)
- [ ] Descomentar `.saveAsTable()` e executar célula 5 (write)
- [ ] Criar painel PBI conectando `gold.santos_semam_pareceres`
- [ ] Adicionar `%run` do notebook no `_nb_gold_orquestracao`
- [ ] Adicionar refresh do painel PBI no `pl_ingest_acto`
