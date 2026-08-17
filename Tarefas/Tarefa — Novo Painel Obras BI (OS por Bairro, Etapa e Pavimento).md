---
title: "Tarefa — Novo Painel Obras BI (OS por Bairro, Etapa e Pavimento)"
date: 2026-05-25
tags:
  - obras
  - power-bi
  - santos
  - backlog
status: backlog
prioridade: média
origem: "Solicitação #962592 — Kelly Araujo Simões"
---

# Novo Painel de Obras BI — OS por Bairro, Etapa e Pavimento

> [!info] Origem
> Solicitação #962592 · Cliente: PM Santos – Aprova Santos · Data: 25/05/2026
> Classificação: Requisição · Eixo: Configuração · Menu: Processos

## Resumo

Novo relatório Power BI para análise de aprovações de obras cruzando **serviço**, **etapa do fluxo**, **quantidade de pavimentos**, **bairro** e **ano**.

---

## Requisitos do Painel

### Filtros
- **Serviço** (ex.: plurifamiliar, comercial)
- **Etapa** (tempo por etapa — eixo do cruzamento)
- **Quantidade de pavimentos** — usado como dimensão de grade (grid)

### Dimensões de Análise
- **B) Linha:** Bairros
- **C) Coluna / eixo temporal:** Ano

### Métricas
- **Contagem distinta de OS** (`COUNT DISTINCT id_os`)
- **Soma de área** (`SUM area`)

---

## Regra de Negócio Crítica — Contagem Distinta de OS

> [!warning] Deduplicação obrigatória
> Uma mesma OS pode passar **mais de uma vez** pela mesma etapa (por erro operacional ou retrabalho). A **aprovação é única**, portanto a contagem deve usar `COUNT DISTINCT` de `id_os` — nunca `COUNT(*)` — para não inflar o número de aprovações.

---

## Exemplo de Análise

> "Quantos empreendimentos com mais de 10 pavimentos foram aprovados entre 2023 e 2026?"
>
> = Quantas OS dos serviços **plurifamiliar** e **comercial** passaram pela etapa de **emissão de alvará**, por bairro — contando cada OS uma única vez.

---

## Checklist de Planejamento

- [ ] Confirmar fonte Gold que contém `id_os`, `id_servico`, `etapa`, `qt_pavimentos`, `bairro`, `dt_aprovacao`, `area`
- [ ] Verificar se `qt_pavimentos` já está na Gold ou precisa ser extraído do Bronze/Silver de obras
- [ ] Levantar mapeamento de etapas relevantes (ex.: "emissão alvará") junto ao cliente
- [ ] Definir granularidade da tabela fato para suportar `COUNT DISTINCT id_os` sem duplicidade
- [ ] Validar que a Gold de obras está operacional — ver [[R5 — HTTP 401 obras]] (pipeline parado desde 11/03/2025)
- [ ] Mapear quais serviços são "plurifamiliar" e "comercial" no cadastro de serviços
- [ ] Prototipar visual no PBI: matriz bairro × ano com slicer de etapa e pavimentos
- [ ] Alinhar escopo final com cliente antes de iniciar desenvolvimento

---

## Dependências Técnicas

| Item | Status | Nota |
|---|---|---|
| Pipeline `pl_ingest_obras_santos` | **PARADO** | R5 — HTTP 401 desde 11/03/2025 |
| Gold obras (`nb_gold_acto_gestao_obras`) | Dependente do pipeline | Sem dados frescos |
| Gold etapas obras | Dependente do pipeline | Idem |
| Campos `qt_pavimentos` e `area` | A verificar | Confirmar presença na Gold |

> [!danger] Bloqueador
> Este painel **não pode ser entregue** enquanto o [[R5 — HTTP 401 obras]] não for resolvido. Corrigir `nb_utils_api_acto_gestao_obras` com `try/except HTTPError 401 → login_acto_gestao_obras() → retry` é pré-requisito.

---

## Notas Adicionais

- Relacionado ao conjunto de 4 painéis PBI de obras ainda no LH legado — ver [[Plano de revisão — Obras PBI migração]]
- Gold de obras tem 94 colunas, muitas sem uso — ver [[Atividade futura: refatorar Gold obras]]
