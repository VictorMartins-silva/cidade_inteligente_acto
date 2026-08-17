---
title: "Spec — SEMAM Licenças Ambientais · Visão Analistas Técnicos"
tags: ["santos", "obras", "semam", "painel", "spec", "os-974214"]
municipio: Santos
status: em-desenvolvimento
os: "974214"
data: "2026-06-24"
relacionados:
  - "[[spec_painel_semam_pareceres]]"
  - "[[Documentação_Fabric/Acto/SCHEMA_LAKEHOUSE_ACTO]]"
---

# SEMAM — Licenças Ambientais · Visão Analistas Técnicos
**OS #974214** · Santos · Secretaria Municipal do Meio Ambiente

Painel para acompanhar a carteira de OS de licenças ambientais por analista técnico.
Identifica quem fez a última análise técnica de cada OS, respeitando a regra do Comunique-se.

---

## Protótipo Visual — Página 1: Visão Consolidada

```
╔══════════════════════════════════════════════════════════════════════════════╗
║  SEMAM — LICENÇAS AMBIENTAIS · ANALISTAS TÉCNICOS              SANTOS  🌿   ║
╠══════════════════════════════════════════════════════════════════════════════╣
║  Período abertura: [ 01/01/2024 ▾ ] → [ 24/06/2026 ▾ ]                     ║
║  Analista: [ ▾ Todos             ]   Serviço: [ ▾ Todos    ]                ║
║  Status:   [ ▾ Todos             ]   Zona:    [ ▾ Todas    ]   [ Limpar ✕ ] ║
╠══════════════╦══════════════╦═════════════════╦══════════════════════════════╣
║  TOTAL OS    ║ EM ANDAMENTO ║   FINALIZADAS   ║  NÃO ATRIBUÍDAS              ║
║              ║              ║                 ║                              ║
║    187       ║      52      ║      135        ║          4                   ║
║  licenças    ║  em aberto   ║   concluídas    ║   (SUPORTE INMOV / sistema)  ║
╠══════════════════════════════════════╦═══════════════════════════════════════╣
║  OS POR ANALISTA TÉCNICO ↓           ║  DISTRIBUIÇÃO POR SERVIÇO             ║
║                                      ║                                       ║
║  ELAINE PATRÍCIA DA S. MEDEIROS  37  ║         ╭───────────────────╮         ║
║  ██████████████████████████████      ║         │  LP  37%          │         ║
║  CARLOS ROGÉRIO RIBEIRO          34  ║         │                   │         ║
║  █████████████████████████████        ║    MTA  │           LI 17% │         ║
║  LUÍS VITOR PIRES HILSDORF       23  ║    26%  │                   │         ║
║  ████████████████████             ║         │       LO 14%      │         ║
║  LÚCIO MENDONÇA                  18  ║         │   LPI 4% RLO 3%   │         ║
║  ████████████████                 ║         ╰───────────────────╯         ║
║  LEONARDO VELARDI MALHEIRO       18  ║                                       ║
║  MARINA FERRRARI DE BARROS       17  ║  ETAPA DA ANÁLISE                     ║
║  LAURA CRISTINA RIBEIRO PESSOA   16  ║  ┌──────────────────────┬────┬──────┐ ║
║  MAURICIO TAVARES DA MOTA        16  ║  │ ANÁLISE DOCUMENTAL   │184 │ 94% │ ║
║  TALITA SOARES REIS              14  ║  │ ANALISTA 2           │ 15 │  8% │ ║
║  JEFFERSON FAGUNDES PEDROSO      12  ║  │ (LPI — a confirmar)  │  ? │  ?% │ ║
║  ROBSON VIEIRA MARCHIORI         11  ║  └──────────────────────┴────┴──────┘ ║
║  (...demais analistas...)            ║  * OS podem ter mais de uma etapa     ║
║  Não Atribuído                   19  ║                                       ║
╠══════════════════════════════════════╩═══════════════════════════════════════╣
║  OS POR SERVIÇO × ANALISTA  (matriz — filtrada pelo seletor de analista)     ║
║                                                                              ║
║  Analista             │  LP  │  LI  │  LO  │  MTA │  RLO │  LPI │  Total  ║
║  ─────────────────────┼──────┼──────┼──────┼──────┼──────┼──────┼─────── ║
║  ELAINE PATRÍCIA      │  15  │   9  │   7  │   6  │   0  │   ?  │   37   ║
║  CARLOS ROGÉRIO       │  12  │   8  │   6  │   8  │   0  │   ?  │   34   ║
║  Não Atribuído        │   8  │   5  │   2  │   4  │   0  │   ?  │   19   ║
║  ...                  │  .. │  .. │  .. │  .. │  .. │  .. │  ..  ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

---

## Protótipo Visual — Página 2: Visão Detalhada

```
╔══════════════════════════════════════════════════════════════════════════════╗
║  SEMAM — DETALHE DAS OS POR ANALISTA                           SANTOS  🌿   ║
╠══════════════════════════════════════════════════════════════════════════════╣
║  Analista: [ ▾ ELAINE PATRÍCIA DA S. MEDEIROS ]   Serviço: [ ▾ Todos  ]    ║
║  Status:   [ ▾ Todos                          ]   Zona:    [ ▾ Todas  ]    ║
╠══════════════════════════════════════════════════════════════════════════════╣
║                                                                              ║
║  ┌────────┬──────────────────────────────┬────────┬──────────────┬──────────┐║
║  │ Nº OS  │ Serviço                      │ Status │ Etapa Atual  │ Abertura ║
║  ├────────┼──────────────────────────────┼────────┼──────────────┼──────────┤║
║  │924.156 │ LICENÇA PRÉVIA               │ 🔵 Atd │ COMUNIQUE-SE │ 12/03/25 ║
║  │854.621 │ LICENÇA DE INSTALAÇÃO        │ ✅ Fin │ PUBL. D.O.   │ 05/11/24 ║
║  │803.910 │ MANIFESTAÇÃO TÉC. AMBIENTAL  │ ✅ Fin │ FINALIZAÇÃO  │ 14/07/23 ║
║  │978.604 │ LICENÇA DE INSTALAÇÃO        │ 🔵 Atd │ DELIB. CHEFIA│ 02/04/26 ║
║  │        │ ...                          │        │              │          ║
║  ├────────┴──────────────────────────────┴────────┴──────────────┴──────────┤║
║  │ 37 OS encontradas para o filtro aplicado                                  ║
║  └────────────────────────────────────────────────────────────────────────── ║
║                                                                              ║
║  LINHA DO TEMPO — OS ativas por mês de abertura (Elaine Patrícia)           ║
║                                                                              ║
║   12 ┤                  █                                                    ║
║   10 ┤          █       █   █                                                ║
║    8 ┤      █   █   █   █   █   █                                            ║
║    6 ┤  █   █   █   █   █   █   █   █                                        ║
║    4 ┤  █   █   █   █   █   █   █   █   █   █                                ║
║    2 ┤  █   █   █   █   █   █   █   █   █   █   █                            ║
║    0 └───────────────────────────────────────────────────                    ║
║      Jan Fev Mar Abr Mai Jun Jul Ago Set Out Nov  (2025-2026)               ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

---

## Mapeamento — Colunas Gold → Visuais PBI

| Coluna                 | Tipo      | De onde vem                               | Usado em                                   |
| ---------------------- | --------- | ----------------------------------------- | ------------------------------------------ |
| `id_os`                | varchar   | `fato_etapas.id_os`                       | Tabela detalhe, drill-through              |
| `servico`              | varchar   | `fato_etapas.servico`                     | Filtro, donut, matriz                      |
| `analista_tecnico`     | varchar   | executor última análise (+ normalização)  | Filtro principal, barra horizontal, matriz |
| `etapa_analise`        | varchar   | nome da etapa executada                   | Tabela etapas, matriz                      |
| `data_inicio_analise`  | datetime2 | `fato_etapas.data_inicio_etapa`           | Linha do tempo, filtro período             |
| `data_fim_analise`     | datetime2 | `fato_etapas.data_fim_etapa`              | Cálculo dias                               |
| `status_etapa_analise` | varchar   | `fato_etapas.status`                      | Info complementar                          |
| `status`               | varchar   | `gold.santos_obras_acompanhamento.status` | Filtro, cards, cor condicional             |
| `data_criacao`         | datetime2 | gold acompanhamento                       | Filtro período abertura, linha do tempo    |
| `data_finalizacao`     | datetime2 | gold acompanhamento                       | Filtro período encerramento                |
| `etapa_atual`          | varchar   | gold acompanhamento                       | Tabela detalhe                             |
| `executor_atual`       | varchar   | gold acompanhamento                       | Info complementar (quem tem hoje)          |
| `zona`                 | varchar   | gold acompanhamento                       | Filtro geográfico                          |
| `solicitante`          | varchar   | gold acompanhamento                       | Tabela detalhe                             |
| `numero_licenca`       | varchar   | gold acompanhamento                       | Tabela detalhe                             |

---

## Medidas DAX

```dax
// ─── Medidas base ───────────────────────────────────────────────────────────

Total OS =
COUNTROWS('gold santos_semam_analista_tecnico')

OS Em Andamento =
CALCULATE(
    [Total OS],
    'gold santos_semam_analista_tecnico'[status] = "Em atendimento"
)

OS Finalizado =
CALCULATE(
    [Total OS],
    'gold santos_semam_analista_tecnico'[status] = "Finalizado"
)

OS Não Atribuído =
CALCULATE(
    [Total OS],
    'gold santos_semam_analista_tecnico'[analista_tecnico] = "Não Atribuído"
)

// ─── Auxiliares ─────────────────────────────────────────────────────────────

Analista Selecionado =
IF(
    ISFILTERED('gold santos_semam_analista_tecnico'[analista_tecnico]),
    SELECTEDVALUE('gold santos_semam_analista_tecnico'[analista_tecnico], "Múltiplos"),
    "Todos"
)
```

---

## Passo a Passo — Montar o Painel no Power BI

### 1. Conectar à fonte

1. Abrir Power BI Desktop → **Obter dados** → **SQL Server Analysis Services** ou **Warehouse** (Fabric)
2. Servidor: `ena6obg6j2cevcppw7dn7yu57a-knnp5frchjbujdik4l3nmgrgsa.datawarehouse.fabric.microsoft.com`
3. Banco: `lh_solicitacoes_acto`
4. Selecionar tabela: `gold.santos_semam_analista_tecnico`
5. Importar (não DirectQuery — tabela pequena, ~250 linhas)

---

### 2. Criar tabela de calendário (para filtro de período)

No Power Query ou DAX:

```dax
Calendario =
CALENDAR(
    DATE(2020, 1, 1),
    TODAY()
)
```

Relacionar: `Calendario[Date]` → `gold santos_semam_analista_tecnico[data_criacao]` (relação ativa)

---

### 3. Página 1 — Visão Consolidada

#### 3.1 Barra de filtros (topo)

| Visual | Tipo | Campo |
|---|---|---|
| Filtro de período | Segmentação de dados (intervalo) | `Calendario[Date]` |
| Analista | Segmentação de dados (lista) | `analista_tecnico` |
| Serviço | Segmentação de dados (lista) | `servico` |
| Status | Segmentação de dados (lista) | `status` |
| Zona | Segmentação de dados (lista) | `zona` |

#### 3.2 Cards KPI (4 cartões na linha)

| Card | Medida | Formatação |
|---|---|---|
| Total OS | `[Total OS]` | número inteiro |
| Em Andamento | `[OS Em Andamento]` | número inteiro, azul |
| Finalizadas | `[OS Finalizado]` | número inteiro, verde |
| Não Atribuídas | `[OS Não Atribuído]` | número inteiro, amarelo |

#### 3.3 Gráfico de barras horizontais — OS por Analista

- **Visual:** Gráfico de barras horizontais
- **Eixo Y:** `analista_tecnico` — ordenar por valor DESC
- **Valor:** `[Total OS]`
- **Cor condicional:** analista = "Não Atribuído" → cor diferenciada (laranja/amarelo)
- **Rótulos de dados:** ativados
- **Tamanho:** coluna esquerda, altura proporcional ao número de analistas (~22 linhas)

#### 3.4 Gráfico de rosca — Distribuição por Serviço

- **Visual:** Gráfico de rosca (donut)
- **Legenda:** `servico`
- **Valores:** `[Total OS]`
- **Cores sugeridas:** LP=azul, LI=verde, LO=laranja, MTA=roxo, RLO=vermelho, LPI=ciano

#### 3.5 Tabela simples — Etapas de análise

- **Visual:** Tabela
- **Colunas:** `etapa_analise`, contagem `[Total OS]`, `% do Total`
- **Posição:** abaixo do donut

#### 3.6 Matriz — Analista × Serviço

- **Visual:** Matriz
- **Linhas:** `analista_tecnico`
- **Colunas:** `servico`
- **Valores:** `[Total OS]`
- **Subtotais:** linha e coluna ativados
- **Formatação condicional:** escala de cor nos valores (branco→azul)

---

### 4. Página 2 — Visão Detalhada

#### 4.1 Filtros (herdar da Página 1 ou repetir)

Usar **Sincronização de segmentações** (Ver → Sincronizar segmentações) para que os filtros da Página 1 se apliquem aqui.

#### 4.2 Tabela de detalhes

| Coluna exibida | Campo da tabela | Formato |
|---|---|---|
| Nº OS | `id_os` | texto |
| Serviço | `servico` | texto |
| Status | `status` | ícone condicional: 🔵 Em atendimento / ✅ Finalizado / ❌ Cancelado |
| Analista Técnico | `analista_tecnico` | texto |
| Etapa Análise | `etapa_analise` | texto |
| Etapa Atual | `etapa_atual` | texto |
| Data Abertura | `data_criacao` | dd/mm/yyyy |
| Data Finalização | `data_finalizacao` | dd/mm/yyyy (em branco se nulo) |
| Zona | `zona` | texto |

- Ordenação padrão: `data_criacao` DESC
- Exportação: habilitar "Exportar dados" nas opções do visual

#### 4.3 Linha do tempo (opcional)

- **Visual:** Gráfico de colunas agrupadas
- **Eixo X:** `data_criacao` agrupado por mês (format: "MMM/yyyy")
- **Valor:** `[Total OS]`
- **Legenda:** `status` (empilhado por Em Andamento / Finalizado)
- **Filtro:** responde ao seletor de analista

---

### 5. Formatação geral

| Item | Configuração |
|---|---|
| Fundo da página | Cinza muito claro (#F5F5F5) ou branco |
| Cor destaque | Verde escuro SEMAM (#2E7D32) no título e bordas |
| Fonte títulos | Segoe UI Semibold, 14pt |
| Fonte dados | Segoe UI, 11pt |
| Bordas cards | Arredondadas, sombra leve |
| Tooltip | Ativar em todos os visuais — mostrar `id_os`, `servico`, `analista_tecnico`, `status` |

---

### 6. Configurar cores condicionais nos cards

No card **Não Atribuídas**:
- Se `[OS Não Atribuído] > 0` → fundo amarelo claro `#FFF9C4`
- Adicionar subtítulo: "Processos sem análise registrada"

No gráfico de barras **OS por Analista**:
- Regra: se `analista_tecnico = "Não Atribuído"` → cor `#E65100` (laranja)
- Demais → cor padrão `#1565C0` (azul)

---

### 7. Checklist antes de publicar

- [ ] Confirmar que `analista_tecnico = "Não Atribuído"` aparece separado visualmente
- [ ] Confirmar que LPI aparece no donut (OS novas chegando via pipeline)
- [ ] Testar filtro de período — validar que filtra por `data_criacao`
- [ ] Testar sincronização de filtros entre Página 1 e Página 2
- [ ] Exportar 5 linhas da tabela detalhe e conferir com o cliente
- [ ] Publicar no workspace `Acto Cidade Inteligente`
- [ ] Adicionar refresh do modelo PBI no `pl_ingest_acto`

---

## Gold Table de referência

**Tabela:** `gold.santos_semam_analista_tecnico`
**Notebook:** `nb_gold_santos_semam_analista_tecnico.ipynb`
**Grain:** uma linha por OS (última análise técnica)
**~251 linhas esperadas** após próximo Gold run com LPI incluído

### Regra do Comunique-se
Executor = quem fez a **última** etapa de `ANÁLISE DOCUMENTAL` ou `ANALISTA N` — mesmo que a etapa atual seja `COMUNIQUE-SE`, `PUBLICAÇÃO`, ou `FINALIZAÇÃO`. A atribuição do processo não muda com o Comunique-se.
