---
status: "ativo"
description: "Roadmap de desenvolvimento do projeto Acto no Microsoft Fabric"
---
# Roadmap de Notebooks e Arquitetura
## Acto · Microsoft Fabric — Gestão de Prazos de Serviços (SLA)

**Prefeitura de Santos**  
**Workspace:** `lh_cidade_inteligente_santos` | **Capacity:** Diamante | **Gerado:** Abril 2026

---

## 1. Visão Geral da Arquitetura

A solução adota a arquitetura Medallion em três camadas dentro do Microsoft Fabric Lakehouse (`lh_cidade_inteligente_santos`). Os dados do Acto são ingeridos via Data Factory, transformados por notebooks PySpark/Python e disponibilizados no Power BI.

```
Fonte (Acto / CSV)
        ↓
   Data Factory
  (ingestão HTTP / CSV → JSON bruto)
        ↓
     BRONZE
  (Delta Tables – dados brutos, sem transformação)
        ↓
     SILVER
  (Tipagem, limpeza, regras de negócio, SCD Type 2)
        ↓
      GOLD
  (Fato Solicitações, Dim Cartas SCD2, SLA calculado, Indicadores)
        ↓
    Power BI
```

| Camada | Responsabilidade | Tecnologia |
|--------|-----------------|------------|
| Bronze | Persistir payload bruto sem alteração | Delta Table, Data Factory |
| Silver | Limpeza, tipagem, normalização, SCD2 | PySpark / Python |
| Gold | Agregações, indicadores, modelo dimensional | PySpark / SQL |
| Consumo | Relatórios e dashboards | Power BI (DAX) |

---

## 2. Inventário de Notebooks — Estado Atual

Mapeamento de todos os notebooks do workspace, com camada, domínio, conformidade com padrão de nomenclatura (`nb_{camada}_{municipio}_{dominio}`) e tipo de output.

| Notebook | Camada | Domínio | Padrão? | Output |
|---|---|---|---|---|
| `nb_ingest_acto_santos` | Bronze | Solicitações Acto | ✅ Sim | JSON payload → Delta Table raw |
| `nb_ingest_santos_curso_motoristas` | Bronze | Curso de Motoristas | ✅ Sim | JSON payload → Delta Table raw |
| `nb_ingest_cartas_servico` | Bronze | Cartas de Serviço | 🔲 Previsto | CSV → `bronze_cartas_servico` |
| `nb_silver_santos_avaliacao` | Silver | Avaliação de Serviços | ✅ Sim | `silver_avaliacao` |
| `nb_silver_santos_curso_motorista` | Silver | Curso de Motoristas | ✅ Sim | `silver_curso_motorista` |
| `nb_silver_cartas_servico` | Silver | Cartas de Serviço | 🔲 Previsto | `silver_cartas_servico` (SCD2) |
| `nb_silver_solicitacoes_sla` | Silver | SLA / Prazos | 🔲 Previsto | `silver_solicitacoes` |
| `nb_gold_santos_avaliacao` | Gold | Avaliação de Serviços | ✅ Sim | `gold_avaliacao` |
| `nb_gold_santos_avaliacao_sentimento` | Gold | Avaliação / Sentimento | ✅ Sim | `gold_sentimento` |
| `gold_curso_motorista` | Gold | Curso de Motoristas | ⚠️ Parcial | `gold_curso_motorista` — nome sem prefixo `nb_` e sem município |
| `nb_gold_dim_cartas_vigencia` | Gold | Cartas SCD2 | 🔲 Previsto | `gold_dim_cartas_servico_vigencia` |
| `nb_gold_fato_solicitacoes` | Gold | Fato Solicitações | 🔲 Previsto | `gold_fato_solicitacoes` |
| `nb_gold_sla_indicadores` | Gold | SLA / Indicadores | 🔲 Previsto | `gold_sla_indicadores` (consumo Power BI) |

> Notebooks marcados como **Previsto** fazem parte do escopo deste projeto e ainda não existem no workspace.

---

## 3. Análise de Padrão de Nomenclatura

Padrão adotado: `nb_{camada}_{municipio}_{dominio}`

| Aspecto | Padrão Esperado | Status |
|---|---|---|
| Prefixo | `nb_` | ⚠️ `gold_curso_motorista` viola esta regra |
| Camada | `bronze` / `silver` / `gold` / `ingest` | ✅ Todos os notebooks existentes seguem |
| Município | `_santos_` | ⚠️ `gold_curso_motorista` omite o município |
| Domínio | `_avaliacao` / `_sla` / `_cartas` / `_curso_motorista` | ✅ Todos seguem |
| Sufixo especial | `_sentimento` / `_vigencia` / `_indicadores` | ✅ Notebooks de enriquecimento — ok |

**Ação recomendada:** renomear `gold_curso_motorista` → `nb_gold_santos_curso_motorista`

---

## 4. Tipos de Dado de Saída por Notebook

Todos os notebooks produzem Delta Tables persistidas no Lakehouse.

### 4.1 Domínio — Avaliação de Serviços

| Tabela de Saída | Formato | Granularidade | Consumidor |
|---|---|---|---|
| `silver_avaliacao` | Delta Table / long format | 1 linha por avaliação | `nb_gold_santos_avaliacao` |
| `gold_avaliacao` | Delta Table / agregado | 1 linha por serviço/período | Power BI |
| `gold_sentimento` | Delta Table / enriquecida | 1 linha por avaliação + sentimento | Power BI (HTML visual) |

### 4.2 Domínio — Curso de Motoristas

| Tabela de Saída | Formato | Granularidade | Consumidor |
|---|---|---|---|
| `silver_curso_motorista` | Delta Table / long format | 1 linha por aluno/dia | `gold_curso_motorista` |
| `gold_curso_motorista` | Delta Table / presença | 1 linha por aluno/turma/dia | Power BI (HTML Content) |

**Regras de negócio ativas:**
- D1 = administrativo → excluído de aprovação e presença
- D8 = excluído dos dias válidos de aula
- Ausência inferida apenas para `status_fluxo = "Finalizado"`
- Estados de presença: Presente / Ausente / Pendente / Cancelado

### 4.3 Domínio — Cartas de Serviço / SLA (Novo Escopo)

| Tabela de Saída | Formato | Granularidade | Detalhe-chave |
|---|---|---|---|
| `bronze_cartas_servico` | Delta Table / raw CSV | 1 linha por registro do CSV | Snapshot com `dt_carga` |
| `silver_cartas_servico` | Delta Table / limpa | 1 linha por carta ativa | Tipagem, dedup, normalização de nomes |
| `silver_solicitacoes` | Delta Table / padronizada | 1 linha por solicitação | Join key: `id_servico + dt_abertura` |
| `gold_dim_cartas_servico_vigencia` | Delta Table / **SCD Type 2** | 1 linha por versão de prazo | `dt_inicio_vigencia`, `dt_fim_vigencia`, `is_atual` |
| `gold_fato_solicitacoes` | Delta Table / fato | 1 linha por solicitação | FK: dim_cartas + dim_servico + dim_calendario |
| `gold_sla_indicadores` | Delta Table / agregada | Por serviço / período / secretaria | Consumo direto Power BI — DAX mínimo |

---

## 5. Análise da Fonte de Dados (CSV exportar_4)

Análise executada sobre `exportar_4.csv`, exportação atual da tabela de cartas de serviço do Acto.

> **Nota:** `cadastro_carta_de_servico.csv` e `exportar_4.csv` possuem estrutura e conteúdo idênticos (mesmo schema, mesmos 693 registros). Usar `exportar_4.csv` como fonte canônica e descartar o outro.

### 5.1 Estrutura do Arquivo

| # | Coluna (nome original) | Tipo inferido | Observação |
|---|---|---|---|
| 0 | `DATA DE ATUALIZAÇÃO` | Datetime | Formato `DD/MM/AAAA HH:MM` |
| 1 | `Nome:` | String | Nome do serviço — chave de join fuzzy com Acto |
| 2 | `Categoria:` | String | 14 categorias mapeadas |
| 3 | `Público alvo` | String | Campo descritivo livre — não usado em SLA |
| 4 | `Dados e documentos requeridos:` | String (multiline) | ⚠️ Campo multiline — principal causa de quebra de CSV |
| 5 | `Formas de consulta ao andamento do serviço:` | String (multiline) | ⚠️ Campo multiline — idem |
| 6 | `Secretaria Responsável` | String | 32 secretarias únicas identificadas |
| 7 | `Data-Hora da inserção/atualização (mais recente)` | Date | Formato `DD/MM/AAAA` — granularidade dia |
| 8 | `ID do serviço:` | String/Int | ⚠️ 3 registros com ID nulo (0,4%) |
| 9 | `Área executora:` | String | Hierarquia: Secretaria — Seção |
| 10 | `Prazo para conclusão:` | Integer | ⚠️ 39 registros sem prazo (5,6%) |
| 11 | `Medida do prazo:` | Enum | Dias (68%), Dias úteis (30%), Nulo (2,2%) |
| 12 | `Canal do serviço online:` | URL / String | Link Acto Digital — pode estar vazio |

**Totais:** 693 registros | 13 colunas | Delimitador: `;` | Quotechar: `"` | Encoding: UTF-8 BOM

### 5.2 Diagnóstico de Qualidade

| Problema | Severidade | Quantidade | Tratamento na Camada Silver |
|---|---|---|---|
| Campos multiline (docs, formas de consulta) | 🔴 Alta | Todos os registros | `csv.reader` com `quotechar='"'` + CRLF handling no PySpark |
| IDs nulos (`ID do serviço`) | 🟡 Média | 3 registros | Isolar em tabela de rejeição; não propagar para Gold |
| Prazos nulos | 🟡 Média | 39 registros (5,6%) | Marcar como `sem_sla_definido` na `dim_cartas` |
| Medida do prazo nula | 🟡 Média | 15 registros (2,2%) | Default `"Dias"` quando prazo preenchido; senão `null` |
| Dias vs. Dias úteis não padronizado | 🔴 Alta | 207 reg. dias úteis | Coluna flag `is_dias_uteis BOOLEAN`; cálculo SLA bifurcado |
| Sem controle de versão / vigência | 🔴 Crítica | 100% dos registros | **SCD Type 2** na `dim_cartas_vigencia` — core do projeto |
| Dois CSVs idênticos (`exportar_4` e `cadastro_carta`) | 🟢 Baixa | Duplicação de fonte | Usar `exportar_4` como canônico; descartar o outro |

---

## 6. Ponto Crítico — SCD Type 2 (Vigência de Prazos)

O maior risco de confiabilidade do sistema atual é a ausência de versionamento dos prazos. Quando uma carta de serviço tem seu prazo alterado, qualquer solicitação histórica recalculada passa a usar o novo prazo, corrompendo retrospectivamente os indicadores.

### Schema — `gold_dim_cartas_servico_vigencia`

| Coluna | Tipo | Papel | Descrição |
|---|---|---|---|
| `sk_carta` | `INTEGER` | PK | Chave surrogate — identificador de versão |
| `id_servico` | `STRING` | NK | Chave natural — ID do serviço no Acto |
| `nm_servico` | `STRING` | | Nome do serviço normalizado |
| `ds_secretaria` | `STRING` | | Secretaria responsável |
| `nr_prazo` | `INTEGER` | | Quantidade de dias do prazo |
| `is_dias_uteis` | `BOOLEAN` | | `True` = dias úteis; `False` = dias corridos |
| `dt_inicio_vigencia` | `DATE` | **SCD2** | Data em que esta versão passou a valer |
| `dt_fim_vigencia` | `DATE` | **SCD2** | `9999-12-31` se registro ativo |
| `is_atual` | `BOOLEAN` | **SCD2** | `True` = versão vigente |
| `dt_carga` | `TIMESTAMP` | Auditoria | Timestamp da ingestão |

### Lógica de Join SLA

A correta aplicação do SLA exige que o join entre solicitações e prazos use a data de abertura como critério de vigência:

```sql
-- Join correto: usa dt_inicio_vigencia e dt_fim_vigencia
SELECT
    s.*,
    d.nr_prazo,
    d.is_dias_uteis
FROM silver_solicitacoes s
LEFT JOIN gold_dim_cartas_servico_vigencia d
    ON  s.id_servico       = d.id_servico
    AND s.dt_abertura     >= d.dt_inicio_vigencia
    AND s.dt_abertura      < d.dt_fim_vigencia
```

> **Nunca** fazer join apenas pela chave `is_atual = True` — isso aplica o prazo mais recente a todas as solicitações históricas.

---

## 7. Roadmap de Execução

| Fase | Título | Notebooks / Entregas | Status |
|---|---|---|---|
| F1 | Consolidação Bronze | `nb_ingest_acto_santos`<br>`nb_ingest_santos_curso_motoristas` | ✅ Concluído |
| F2 | Consolidação Silver/Gold Existente | `nb_silver_santos_avaliacao`<br>`nb_gold_santos_avaliacao`<br>`nb_gold_santos_avaliacao_sentimento`<br>`nb_silver_santos_curso_motorista`<br>`gold_curso_motorista` *(renomear)* | ✅ Concluído *(ajuste de nome pendente)* |
| F3 | Ingestão Cartas de Serviço | `nb_ingest_cartas_servico`<br>→ `bronze_cartas_servico` (Delta) | 🔲 A fazer |
| F4 | Silver — Limpeza e SCD2 | `nb_silver_cartas_servico`<br>→ `silver_cartas_servico` (SCD Type 2)<br>`nb_silver_solicitacoes_sla`<br>→ `silver_solicitacoes` | 🔲 A fazer |
| F5 | Gold — Dimensão e Fato | `nb_gold_dim_cartas_vigencia`<br>→ `gold_dim_cartas_servico_vigencia`<br>`nb_gold_fato_solicitacoes`<br>→ `gold_fato_solicitacoes` | 🔲 A fazer |
| F6 | Gold — Indicadores SLA + Power BI | `nb_gold_sla_indicadores`<br>→ `gold_sla_indicadores`<br>Configuração Power BI<br>DAX: `%SLA`, `dias_atraso`, `status` | 🔲 A fazer |

---

## 8. Dependências entre Notebooks

Ordem de execução obrigatória por domínio. O Data Factory deve respeitar estas dependências ao orquestrar os pipelines.

### Domínio Avaliação (existente)

```
nb_ingest_acto_santos
    → nb_silver_santos_avaliacao
        → nb_gold_santos_avaliacao
            → nb_gold_santos_avaliacao_sentimento
```

### Domínio Curso de Motoristas (existente)

```
nb_ingest_santos_curso_motoristas
    → nb_silver_santos_curso_motorista
        → gold_curso_motorista  ← (renomear para nb_gold_santos_curso_motorista)
```

### Domínio SLA / Cartas de Serviço (novo)

```
nb_ingest_cartas_servico
    → nb_silver_cartas_servico
        → nb_gold_dim_cartas_vigencia ──────────────┐
                                                    ↓
nb_ingest_acto_santos                    nb_gold_sla_indicadores
    → nb_silver_solicitacoes_sla                    ↑
        → nb_gold_fato_solicitacoes ────────────────┘
```

---

## 9. Checklist de Ações Imediatas

| # | Ação | Esforço |
|---|---|---|
| 1 | Renomear `gold_curso_motorista` → `nb_gold_santos_curso_motorista` | 🟢 Baixo |
| 2 | Definir fonte canônica: usar `exportar_4.csv` (descartar `cadastro_carta_de_servico.csv`) | 🟢 Baixo |
| 3 | Criar `nb_ingest_cartas_servico`: ler CSV com `quotechar`, tratar multiline, salvar em Delta | 🟡 Médio |
| 4 | Criar `nb_silver_cartas_servico`: limpeza, tipagem `is_dias_uteis`, rejeição de IDs nulos | 🔴 Alto |
| 5 | Implementar SCD Type 2 em `nb_silver_cartas_servico` (`dt_inicio/fim_vigencia`, `is_atual`) | 🔴 Alto |
| 6 | Criar `nb_silver_solicitacoes_sla`: ingestão e padronização das solicitações do Acto | 🔴 Alto |
| 7 | Criar `nb_gold_dim_cartas_vigencia`: consolidar dimensão versionada para Power BI | 🔴 Alto |
| 8 | Criar `nb_gold_fato_solicitacoes`: join com vigência (`dt_abertura` entre `dt_inicio` e `dt_fim`) | 🔴 Alto |
| 9 | Criar `nb_gold_sla_indicadores`: calcular `%_no_prazo`, `dias_atraso_medio`, status por secretaria | 🟡 Médio |
| 10 | Configurar pipeline Data Factory para orquestrar nova cadeia de SLA | 🟡 Médio |
| 11 | Construir relatório Power BI consumindo `gold_sla_indicadores` + `gold_dim_cartas_vigencia` | 🟡 Médio |

---

## Referências

- **Workspace ID:** `96fe5a53-3a22-4443-8d0a-e2f6d61a2690`
- **Lakehouse:** `lh_cidade_inteligente_santos`
- **Capacity:** Diamante
- **Fonte de dados canônica:** `exportar_4.csv` (693 registros, 13 colunas, UTF-8 BOM, delimitador `;`)
- **Padrão de notebook:** `nb_{camada}_{municipio}_{dominio}`
- **Padrão SLA:** SCD Type 2 com `dt_inicio_vigencia` / `dt_fim_vigencia` / `is_atual`

---

## Ver Também

- [[_mapa-do-vault]] — índice geral do vault
- [[Conhecimento/Fabric/fabric-workspace-acto-cidade-inteligente|fabric-workspace-acto-cidade-inteligente]] — workspace completo Acto Cidade Inteligente
- [[Conhecimento/Fabric/pipeline-acto-santos-fabric|pipeline-acto-santos-fabric]] — fluxo Data Factory + notebooks
- [[Projetos/acto-santos-pipeline]] — projeto ACTO Santos
