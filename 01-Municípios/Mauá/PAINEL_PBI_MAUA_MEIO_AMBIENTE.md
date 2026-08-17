---
title: "Protótipo Power BI — Mauá Meio Ambiente"
tags:
  - power-bi
  - maua
  - meio-ambiente
  - prototipo
  - tipo/referencia
municipio: Mauá
aliases:
  - painel maua meio ambiente
  - pbi maua
data: "2026-06-11"
versao: "1.0"
relacionados:
  - "[[Documentação_Fabric/Mauá/00_INDEX_MAUA]]"
  - "[[Documentação_Fabric/doc/DETALHAMENTO_OSASCO_MAUA]]"
---

# Protótipo Power BI — PM Mauá — Meio Ambiente

> **7 relatórios · 2 tabelas Gold · SQL Endpoint Fabric**
> Fonte: `lh_solicitacoes_acto` · Atualizado em 11/06/2026

---

## Navegação Rápida

| # | Relatório | Status | Dados |
|---|---|---|---|
| [[#R1 — Tempo de Atendimento × Serviço × Etapa\|R1]] | Tempo × Etapa | ✅ Pronto | `Fato_Etapas` |
| [[#R2 — Distribuição × Analista\|R2]] | Analistas | ✅ Pronto | `Fato_Etapas` |
| [[#R3 — Documentos Emitidos × Serviço\|R3]] | Documentos | ✅ Pronto (proxy) | `Fato_OS` |
| [[#R4 — Poda × Região de Planejamento\|R4]] | Poda × Região | ✅ Pronto | `Fato_OS` |
| [[#R5 — Licenças × CNAE\|R5]] | CNAE | ✅ ~43 OS | `Fato_OS` |
| [[#R6 — TCA × Período\|R6]] | TCA | 🔴 Bloqueado | — |
| [[#R7 — Supressão de Árvores\|R7]] | Árvores | ⚠️ Parcial | `Fato_OS` |

---

## Modelo de Dados

```
gold.maua_meio_ambiente        →  Fato_OS      (3.901 linhas)
gold.maua_meio_ambiente_etapas →  Fato_Etapas  (25.603 linhas)

Relacionamento:
  Fato_OS [id_os]  ◄──────────  Fato_Etapas [id_os]
       (1)                              (N)
  Direção: simples (OS filtra Etapas)
```

### Colunas Gold → Display Name PBI

| Coluna Gold | Nome no PBI |
|---|---|
| `codigo_cnae` | `cnae_primario` |
| `informe_a_atividade_secundaria_ambientalmente_licenciavel_sub_industrial` | `cnae_secundario` |
| `o_transplante_o_corte_de_arvores_isoladas_ou_de_macico_florestal` | `flag_supressao_arvore` |
| `supressaotransplante_de_arvores_sub` | `supressao_arvore_detalhes` |
| `selecione_a_regiao_de_planejamento` | `regiao_planejamento` |
| `bairro_consolidado` | `bairro` |
| `n_do_documento` | `num_documento` |
| `data_de_validade` | `validade_documento` |

---

## Medidas DAX

```dax
// ── GERAIS
Total OS           = COUNTROWS(Fato_OS)
OS Finalizadas     = CALCULATE(COUNTROWS(Fato_OS), Fato_OS[status_fluxo] = "Finalizado")
OS Em Atendimento  = CALCULATE(COUNTROWS(Fato_OS), Fato_OS[status_fluxo] = "Em atendimento")
% Concluídas       = DIVIDE([OS Finalizadas], [Total OS], 0)

// ── R1
Tempo Médio (dias) = AVERAGEX(
    FILTER(Fato_Etapas, Fato_Etapas[is_etapa_interna] = TRUE && Fato_Etapas[tempo_execucao_dias] >= 0),
    Fato_Etapas[tempo_execucao_dias])

Tempo Máximo (dias) = MAXX(FILTER(Fato_Etapas, Fato_Etapas[is_etapa_interna] = TRUE), Fato_Etapas[tempo_execucao_dias])

Resumo Tempo = "No período de " & FORMAT(MIN(Fato_Etapas[data_criacao]),"DD/MM/YYYY")
    & " a " & FORMAT(MAX(Fato_Etapas[data_criacao]),"DD/MM/YYYY")
    & ", a etapa " & SELECTEDVALUE(Fato_Etapas[etapa],"(todas)")
    & " do serviço " & SELECTEDVALUE(Fato_OS[servico],"(todos)")
    & " apresentou tempo médio de execução de "
    & FORMAT([Tempo Médio (dias)],"0.0") & " dias."

// ── R2
OS por Analista      = CALCULATE(DISTINCTCOUNT(Fato_Etapas[id_os]), Fato_Etapas[is_etapa_interna] = TRUE)
Rank Analista        = RANKX(ALLSELECTED(Fato_Etapas[executor]), [OS por Analista],, DESC, Dense)
Total Analistas      = CALCULATE(DISTINCTCOUNT(Fato_Etapas[executor]), Fato_Etapas[is_etapa_interna] = TRUE, Fato_Etapas[executor] <> BLANK())

// ── R3
Total Documentos     = CALCULATE(COUNTROWS(Fato_OS), Fato_OS[num_documento] <> BLANK())
% OS com Documento   = DIVIDE([Total Documentos], [Total OS], 0)

// ── R4
Total OS Poda        = CALCULATE(COUNTROWS(Fato_OS), Fato_OS[servico] = "Poda Ou Remoção De Árvores Em Calçadas E Outras Áreas Públicas")
% Poda com Região    = DIVIDE(CALCULATE([Total OS Poda], Fato_OS[regiao_planejamento] <> BLANK()), [Total OS Poda], 0)

// ── R5
OS Licenças Válidas  = CALCULATE(COUNTROWS(Fato_OS), Fato_OS[cnae_primario] <> BLANK())
Emissões por CNAE    = CALCULATE(COUNTROWS(Fato_OS), Fato_OS[cnae_primario] <> BLANK(), OR(Fato_OS[num_documento] <> BLANK(), Fato_OS[validade_documento] <> BLANK()))
```

---

## R1 — Tempo de Atendimento × Serviço × Etapa

> **Spec:** Tempo médio de execução das etapas por serviço · filtro período + serviço + etapa

> [!success] Status: Pronto
> Fonte: `Fato_Etapas` · `tempo_execucao_dias` pré-calculado · média 12,1 dias · máx 664 dias

### Linhagem
```
silver.fato_etapas → gold.maua_meio_ambiente_etapas → Fato_Etapas (PBI)
```

### Slicers / Filtros

| Elemento      | Campo                                                | Tipo                         |
| ------------- | ---------------------------------------------------- | ---------------------------- |
| 📅 Período    | `Fato_Etapas[data_criacao]`                          | Intervalo de datas           |
| 📋 Serviço    | `Fato_OS[servico]`                                   | Dropdown multi (via rel.)    |
| 📋 Etapa      | `Fato_Etapas[etapa]`                                 | Lista — cascata após serviço |
| Filtro página | `is_etapa_interna = TRUE` `tempo_execucao_dias >= 0` | Painel filtros               |

### Wireframe

```
╔══════════════════════════════════════════════════════════════════════════════╗
║  R1 — Tempo de Atendimento × Serviço × Etapa                               ║
╠══════════════════════════════════════════════════════════════════════════════╣
║                                                                              ║
║  📅 [01/01/2025 ──────────── 31/12/2025]  📋 Serviço [▼]  📋 Etapa [▼]    ║
║                                                                              ║
╠═══════════════════════╦═══════════════════════╦═══════════════════════════  ║
║   TEMPO MÉDIO          ║    TEMPO MÁXIMO        ║   TEMPO MÍNIMO            ║
║                        ║                        ║                           ║
║      12,1 dias         ║      664 dias          ║       0 dias              ║
║                        ║                        ║                           ║
╠═══════════════════════╩════════════════════════╩═══════════════════════════ ║
║                                                                              ║
║  ── Tempo Médio por Etapa (barras horizontais) ───────────────────────────  ║
║                                                                              ║
║  ANÁLISE TÉCNICA         ████████████████████████████████  24,3 d          ║
║  DISTRIBUIÇÃO            ████████████████████  15,8 d                      ║
║  VALIDAÇÃO DA SOLIC.     ████████████  9,2 d                               ║
║  REGISTRO DA SOLIC.      ███████████  8,7 d                                ║
║  FINALIZAÇÃO             ████████  5,1 d                                   ║
║  IDENTIFICAÇÃO ÁRVORE    ███████  4,6 d                                    ║
║  APURAÇÃO                █████  3,2 d                                      ║
║                                                                              ║
╠══════════════════════════════════════════════════════════════════════════════╣
║                                                                              ║
║  ── Tabela detalhada ─────────────────────────────────────────────────────  ║
║                                                                              ║
║  Serviço                   │ Etapa            │ Média  │ Máx  │ Ocorrências ║
║  ──────────────────────────┼──────────────────┼────────┼──────┼──────────── ║
║  Poda                      │ Análise Técnica  │ 18,2   │ 421  │ 847        ║
║  Licença Ambiental         │ Análise Técnica  │ 31,4   │ 664  │ 189        ║
║  Autorização Ambiental     │ Análise Técnica  │ 22,7   │ 312  │  97        ║
║  Manifestação Técnica      │ Análise Técnica  │  8,1   │  95  │ 143        ║
║  Informação Técnica        │ Análise Técnica  │  6,3   │  88  │ 118        ║
║  Denúncia Infração Amb.    │ Apuração         │ 11,2   │ 201  │  —         ║
║                                                                              ║
╠══════════════════════════════════════════════════════════════════════════════╣
║                                                                              ║
║  💬 "No período de 01/01/2025 a 31/12/2025, a etapa ANÁLISE TÉCNICA         ║
║       do serviço Licença Ambiental apresentou tempo médio de 31,4 dias."    ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

---

## R2 — Distribuição × Analista

> **Spec:** Total de solicitações atendidas por analista, por serviço e período · excluir etapas de cidadão · exibir gráfico

> [!success] Status: Pronto
> `is_etapa_interna` corrigido em 11/06/2026 — exclui DADOS DO SOLICITANTE, BOAS-VINDAS, FIM DE FLUXO e variantes

### Slicers / Filtros

| Elemento      | Campo                                                                                         | Tipo               |
| ------------- | --------------------------------------------------------------------------------------------- | ------------------ |
| 📅 Período    | `Fato_Etapas[data_criacao]`                                                                   | Intervalo de datas |
| 📋 Serviço    | `Fato_OS[servico]`                                                                            | Dropdown multi     |
| Filtro página | `is_etapa_interna = TRUE` `executor <> BLANK()` `executor <> "ADMINISTRAACTO ADMINISTRAACTO"` | Painel filtros     |

### Wireframe

```
╔══════════════════════════════════════════════════════════════════════════════╗
║  R2 — Totais de Distribuição × Analista                                     ║
╠══════════════════════════════════════════════════════════════════════════════╣
║                                                                              ║
║  📅 [01/01/2025 ──────────── 31/12/2025]  📋 Serviço [▼ Todos]            ║
║                                                                              ║
╠═══════════════════════╦════════════════════════════════════════════════════  ║
║  ANALISTAS ATIVOS      ║  TOTAL OS (período)                                ║
║       42               ║       3.901                                        ║
╠═══════════════════════╩════════════════════════════════════════════════════  ║
║                                                                              ║
║  ┌─ Gráfico de barras — Top 10 Analistas ────────────────────┐             ║
║  │                                                            │             ║
║  │  Jucilaine Buzetto   ██████████████████████████  1.064    │             ║
║  │  Sergio Caram        ████████████████  679                 │             ║
║  │  Paulo Alexandre     █████████████  545                    │             ║
║  │  Reinaldo Araújo     ████████  363                         │             ║
║  │  Diego Santos        ████████  339                         │             ║
║  │  Marcelo Maranhão    ████████  332                         │             ║
║  │  José Rogério        ███████  302                          │             ║
║  │  Daniel Mesquita     ████  178                             │             ║
║  │  Renan Destefano     ████  171                             │             ║
║  │  Simony Cerqueira    ████  150                             │             ║
║  │                                                            │             ║
║  └────────────────────────────────────────────────────────────┘             ║
║                                                                              ║
║  ┌─ Tabela (formato spec) ───────────────────────────────────┐             ║
║  │  Analistas                          Total solicitações    │             ║
║  │  ─────────────────────────────────  ──────────────────    │             ║
║  │  Jucilaine dos Santos Pereira B.    1.064                 │             ║
║  │  Sergio Caram de Moraes             679                   │             ║
║  │  Paulo Alexandre da Costa           545                   │             ║
║  │  Reinaldo Soares de Araújo          363                   │             ║
║  │  Diego Soares Santos                339                   │             ║
║  │  ...                                ...                   │             ║
║  └────────────────────────────────────────────────────────────┘             ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

> [!warning] Atenção
> Filtrar `executor <> "ADMINISTRAACTO ADMINISTRAACTO"` no painel de filtros do PBI além do `is_etapa_interna` — garante exclusão de etapas residuais automáticas.

---

## R3 — Documentos Emitidos × Serviço

> **Spec:** Documentos emitidos por serviço e por solicitação · campos: Nº OS, data abertura, serviço, solicitante, Nº documento, data emissão, validade

> [!warning] Status: Pronto com proxy
> `data_emissao` não existe na Silver — campo não capturado pelo payload Acto. Filtro `num_documento <> BLANK()` equivale funcionalmente (se tem número, houve emissão). Para data literal: adicionar ao payload.

### Slicers / Filtros

| Elemento | Campo | Tipo |
|---|---|---|
| 📅 Período | `Fato_OS[data_criacao]` | Intervalo de datas |
| 📋 Serviço | `Fato_OS[servico]` | Dropdown multi |
| Filtro página | `num_documento <> BLANK()` | Painel filtros (equivale a "data emissão preenchida") |

### Wireframe

```
╔══════════════════════════════════════════════════════════════════════════════╗
║  R3 — Documentos Emitidos × Serviço                                         ║
╠══════════════════════════════════════════════════════════════════════════════╣
║                                                                              ║
║  📅 [01/01/2025 ──────────── 31/12/2025]  📋 Serviço [▼ Todos]            ║
║                                                                              ║
╠═══════════════════════╦════════════════════════════════════════════════════  ║
║  DOCUMENTOS EMITIDOS   ║  COM VALIDADE                                      ║
║       454              ║     149                                            ║
╠═══════════════════════╩════════════════════════════════════════════════════  ║
║                                                                              ║
║  ┌─ Documentos por Serviço ──────────────────────────────────┐             ║
║  │                                                            │             ║
║  │  Controle de Documentos    ████████████████████████  149  │             ║
║  │  Informação Técnica        ████████████  79               │             ║
║  │  Manifestação Técnica      ██████████  69                 │             ║
║  │  Lic. Ambiental Renov.     █████████  65                  │             ║
║  │  Autorização Ambiental     ██████  38                     │             ║
║  │  Licença Ambiental         █████  34                      │             ║
║  │  Licença Simplificada      █  10                          │             ║
║  │  Lic. Simpl. Renovação     █   8                          │             ║
║  │                                                            │             ║
║  └────────────────────────────────────────────────────────────┘             ║
║                                                                              ║
║  ┌─ Detalhe por Solicitação ─────────────────────────────────────────────┐ ║
║  │  Nº OS   │ Data Abertura │ Serviço          │ Solicitante │ Nº Doc │ Validade ║
║  │  ────────┼───────────────┼──────────────────┼─────────────┼────────┼──────── ║
║  │  OS-0001 │ 03/01/2025    │ Controle Doc.    │ Empresa X   │ D-1234 │ 31/12/25 ║
║  │  OS-0002 │ 05/01/2025    │ Inf. Técnica     │ João Silva  │ D-1235 │  —      ║
║  │  OS-0003 │ 07/01/2025    │ Lic. Ambiental   │ Empresa Y   │ D-1236 │ 31/06/26 ║
║  │  ...                                                                   │ ║
║  └───────────────────────────────────────────────────────────────────────┘ ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

> [!info] Observação técnica
> Campo `data_emissao` ausente da Silver — para obter a data literal de emissão, identificar o `tit` do campo no formulário Acto e adicionar ao `payload_maua_meio_ambiente.json`. Após próxima ingestão Bronze + Silver + Gold, o campo aparece automaticamente.

---

## R4 — Poda × Região de Planejamento

> **Spec (exclusivo serviço Poda):** Quantidade de OS abertas por região · listagem com data abertura, bairro, região · gráfico por região

> [!success] Status: Pronto
> 1.956 OS de Poda · 1.079 com região (55%) · 1.082 com bairro (55%)

### Slicers / Filtros

| Elemento | Campo | Tipo |
|---|---|---|
| 📅 Período | `Fato_OS[data_criacao]` | Intervalo de datas |
| Filtro página fixo | `servico = "Poda Ou Remoção De Árvores..."` | Painel filtros — não exposto como slicer |

### Wireframe

```
╔══════════════════════════════════════════════════════════════════════════════╗
║  R4 — Poda × Região de Planejamento                        [Excl. Poda]    ║
╠══════════════════════════════════════════════════════════════════════════════╣
║                                                                              ║
║  📅 [01/01/2025 ──────────── 31/12/2025]                                   ║
║                                                                              ║
╠═══════════════════════╦═══════════════════════╦═══════════════════════════  ║
║  TOTAL OS PODA         ║  COM REGIÃO            ║  % COM REGIÃO             ║
║       1.956            ║     1.079              ║     55,2%                 ║
╠═══════════════════════╩═══════════════════════╩═══════════════════════════  ║
║                                                                              ║
║  ┌─ OS por Região de Planejamento ───────────────────────────────────────┐ ║
║  │                                                                        │ ║
║  │  REGIÃO NORTE        ████████████████████████████████████  412        │ ║
║  │  REGIÃO SUL          ██████████████████████████  318                  │ ║
║  │  REGIÃO LESTE        ████████████████████  243                        │ ║
║  │  REGIÃO CENTRO       ████████████████  198                            │ ║
║  │  REGIÃO OESTE        █████████  108                                   │ ║
║  │  (sem região)        ██████████████████████████  877                  │ ║
║  │                                                                        │ ║
║  │  * Valores ilustrativos — distribuição real após PBI conectado         │ ║
║  └────────────────────────────────────────────────────────────────────────┘ ║
║                                                                              ║
║  ┌─ Listagem de Solicitações ─────────────────────────────────────────────┐ ║
║  │  Data Abertura │ Bairro            │ Região de Planejamento            │ ║
║  │  ──────────────┼───────────────────┼───────────────────────────────── │ ║
║  │  03/01/2025    │ Jardim Zaira      │ REGIÃO NORTE                     │ ║
║  │  05/01/2025    │ Vila Nogueira     │ REGIÃO SUL                       │ ║
║  │  07/01/2025    │ —                 │ —                                │ ║
║  │  ...                                                                   │ ║
║  └────────────────────────────────────────────────────────────────────────┘ ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

> [!info] Cobertura de região
> 45% das OS de Poda não têm região preenchida — foram abertas antes da coleta do campo ou via canal sem o formulário completo. O gráfico exibe `(sem região)` como categoria separada.

---

## R5 — Licenças × CNAE

> **Spec (exclusivo Licenças):** OS validadas (passou por Análise Técnica) com CNAE primário e secundário · 2 gráficos: OS por CNAE e emissões por CNAE

> [!warning] Status: Pronto — volume inicial baixo
> 43 OS com `cnae_primario` · volume crescerá conforme novas OS atingirem a etapa Análise Técnica

### Filtro de página
```
Fato_OS[cnae_primario] <> BLANK()
```
> Equivale a "OS que executaram ao menos uma vez a etapa Análise Técnica" conforme spec.

### Wireframe

```
╔══════════════════════════════════════════════════════════════════════════════╗
║  R5 — Licenças × CNAE                                  [Excl. Licenças]   ║
╠══════════════════════════════════════════════════════════════════════════════╣
║                                                                              ║
║  📅 [01/01/2025 ──────────── 31/12/2025]                                   ║
║                                                                              ║
╠═══════════════════════╦════════════════════════════════════════════════════  ║
║  OS LICENÇAS VÁLIDAS   ║  EMISSÕES                                          ║
║       43               ║     ~20                                            ║
╠═══════════════════════╩════════════════════════════════════════════════════  ║
║                                                                              ║
║  ┌─ Gráfico 1: OS por CNAE ──────────────────────────────────┐             ║
║  │  (conforme spec — "1º gráfico de barras")                  │             ║
║  │                                                            │             ║
║  │  47.12-0/00  ██████████████████████████████  18           │             ║
║  │  35.14-6/00  ████████████████  9                           │             ║
║  │  38.11-4/00  ████████  5                                   │             ║
║  │  23.92-3/00  ██████  4                                     │             ║
║  │  outros      ████  7                                       │             ║
║  │                                                            │             ║
║  └────────────────────────────────────────────────────────────┘             ║
║                                                                              ║
║  ┌─ Gráfico 2: Emissões por CNAE ────────────────────────────┐             ║
║  │  (conforme spec — "2º gráfico" — só OS com num_doc ou validade)         ║
║  │                                                            │             ║
║  │  47.12-0/00  ████████████████████  12                     │             ║
║  │  35.14-6/00  ██████  4                                     │             ║
║  │  38.11-4/00  ████  2                                       │             ║
║  │  23.92-3/00  ██  1                                         │             ║
║  │                                                            │             ║
║  └────────────────────────────────────────────────────────────┘             ║
║                                                                              ║
║  ┌─ Detalhe por Solicitação ─────────────────────────────────────────────┐ ║
║  │  Nº OS │ Data  │ Serviço    │ Solicitante │ CNAE Pri. │ CNAE Sec. │ Doc │ ║
║  │  ──────┼───────┼────────────┼─────────────┼───────────┼───────────┼─── │ ║
║  │  OS-X  │ ...   │ Lic. Amb.  │ Empresa Z   │ 47.12-0   │ 35.14-6   │ D- │ ║
║  │  ...                                                                   │ ║
║  └───────────────────────────────────────────────────────────────────────┘ ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

> [!info] Volume atual
> 43 OS com CNAE hoje — serviços Licença Ambiental, Licença Simplificada e renovações. Volume cresce automaticamente a cada pipeline quando novas OS atingem Análise Técnica.

---

## R6 — TCA × Período

> **Spec (exclusivo Autorização):** OS com TCA firmado na etapa Autorização Ambiental · campos: Nº OS, data abertura, serviço, solicitante, Nº TCA, data emissão

> [!error] Status: Bloqueado
> Campo `identificacao_do_termo_de_compromisso_ambiental_tca` ausente da Silver — OS de Autorização Ambiental ainda não atingiram a etapa de emissão do TCA. Ativará automaticamente quando chegarem.

### Placeholder para exibir no PBI

```
╔══════════════════════════════════════════════════════════════════════════════╗
║  R6 — TCA × Período                                    [Excl. Autorização] ║
╠══════════════════════════════════════════════════════════════════════════════╣
║                                                                              ║
║                                                                              ║
║                        ⏳                                                   ║
║                                                                              ║
║         Dados de TCA estarão disponíveis quando as primeiras                ║
║         OS de Autorização Ambiental atingirem a etapa                       ║
║         "Autorização Ambiental" no sistema Acto.                            ║
║                                                                              ║
║         O pipeline atualiza automaticamente — nenhuma                       ║
║         alteração de código é necessária.                                   ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

### Estrutura futura (quando ativar)

| Visual | Campos |
|---|---|
| Cartão | Total TCAs emitidos |
| Tabela | `id_os`, `data_criacao`, `servico`, `solicitante`, TCA, `validade_documento` |
| Filtro página | `identificacao_do_termo_de_compromisso_ambiental_tca <> BLANK()` |

---

## R7 — Supressão de Árvores

> **Spec (exclusivo Autorização):** OS com checkbox supressão marcado · somatória de "Nº Individuo" e "Área M²" de subformulários

> [!warning] Status: Parcial
> **Checkbox** `flag_supressao_arvore` disponível · 41 OS · **Subformulário** (Nº Individuo / Área M²) não capturado pelo EAV atual — requer extensão do Bronze para arrays Acto

### Wireframe (dados disponíveis hoje)

```
╔══════════════════════════════════════════════════════════════════════════════╗
║  R7 — Supressão de Árvores                             [Excl. Autorização] ║
╠══════════════════════════════════════════════════════════════════════════════╣
║                                                                              ║
║  📅 [01/01/2025 ──────────── 31/12/2025]                                   ║
║                                                                              ║
╠═══════════════════════╦════════════════════════════════════════════════════  ║
║  OS C/ SUPRESSÃO       ║  SOMA Nº INDIVÍDUOS        SOMA ÁREA M²           ║
║       41               ║  ⚠️ Subformulário          ⚠️ Subformulário       ║
╠═══════════════════════╩════════════════════════════════════════════════════  ║
║                                                                              ║
║  ┌─ Listagem de Solicitações ─────────────────────────────────────────────┐ ║
║  │  Nº OS    │ Data Abertura │ Solicitante      │ Tipo Supressão          │ ║
║  │  ─────────┼───────────────┼──────────────────┼──────────────────────── │ ║
║  │  OS-XXXX  │ 03/02/2025    │ Empresa A        │ Transplante / Corte     │ ║
║  │  OS-XXXX  │ 17/03/2025    │ Construtora B    │ Transplante / Corte     │ ║
║  │  ...                                                                   │ ║
║  └────────────────────────────────────────────────────────────────────────┘ ║
║                                                                              ║
║  ┌─────────────────────────────────────────────────────────────────────────┐ ║
║  │  ℹ️  Somatória de "Nº Individuo" e "Área M²" requer captura de          │ ║
║  │      subformulários (arrays) da API Acto — não disponível no EAV atual. │ ║
║  │      Previsão: extensão do Bronze em iteração futura.                   │ ║
║  └─────────────────────────────────────────────────────────────────────────┘ ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

---

## Ordem de Construção no PBI

```
Passo 1 — Conectar SQL Endpoint
  Server: ena6obg6j2cevcppw7dn7yu57a-knnp5frchjbujdik4l3nmgrgsa.datawarehouse.fabric.microsoft.com
  Database: lh_solicitacoes_acto
  Tabelas: gold.maua_meio_ambiente · gold.maua_meio_ambiente_etapas

Passo 2 — Criar relacionamento
  Fato_Etapas[id_os]  →  Fato_OS[id_os]
  Cardinalidade: N:1 · Filtro: Simples

Passo 3 — Renomear colunas (Display Names — ver tabela acima)

Passo 4 — Criar tabela _Medidas e adicionar DAX

Passo 5 — Construir páginas na ordem:
  R4 → R2 → R1 → R3 → R5 → placeholder R6 → R7 parcial
```

---

## Checklist de Validação Pós-Build

- [ ] R2: "ADMINISTRAACTO ADMINISTRAACTO" ausente da tabela de analistas
- [ ] R2: Total de analistas ≠ 0 após filtro `is_etapa_interna = TRUE`
- [ ] R4: Gráfico de barras exibe `(sem região)` separado — não mistura com regiões
- [ ] R5: Filtro de página `cnae_primario <> BLANK()` funcional — tabela exibe só OS validadas
- [ ] R3: Exportação da tabela de documentos funcional (botão exportar habilitado)
- [ ] R1: Texto dinâmico `Resumo Tempo` exibido apenas quando 1 serviço + 1 etapa selecionados
- [ ] R6: Placeholder visível sem erro de dados

---

*Gerado por Claude Code · Dados verificados via SQL Endpoint em 11/06/2026*
*Fonte de dados: `lh_solicitacoes_acto` · Pipeline: `pl_ingest_acto`*
