---
title: Plano Gold CET/SEPREF — Prazo e Unidade Executora
tags: ["tipo/plano", "tema/migracao", "secretaria/cet", "secretaria/sepref", "tema/sla"]
status: "ativo"
revisao: "2026-08-05"
---
# Plano Gold CET/SEPREF — Inclusão de Prazo e Unidade Executora

> Objetivo: entender e padronizar no modelo Acto (EAV) a extração de prazo e unidade executora, seguindo o processo montado pelo Yuri no ambiente Fabric.

---

## 1) O que foi confirmado

### 1.1 No notebook aberto no Fabric (evidência visual)

Foi identificado no `nb_gold_santos_cet` um bloco explícito de enriquecimento de prazo com:

1. `%run ./nb_utils_gold_carta_prazo`
2. chamada `enriquecer_prazo_carta(df_gold, FONTES_CET, "gold.santos_cet")`
3. write final da `gold.santos_cet`
4. bloco de observabilidade para serviços sem de-para

Também foi observado texto indicando que o prazo é resolvido por duas tabelas de referência:

- `silver.depara_servicos_acto` (nome transacional da API -> serviço canônico)
- `silver.dim_carta_servicos_prazos` (id_servico + vigência temporal -> prazo)

### 1.2 No acervo técnico local

- O helper padrão de Gold (`nb_utils_gold_acto_gestao`) já traz `executor_atual` via última etapa (`silver.fato_etapas`) e estrutura de build para CET/SEPREF.
- A lógica de unidade executora/setor está mais madura hoje no domínio Obras (`aux_setor_responsavel`), com mapeamento de etapa e observabilidade.
- Não foi encontrada documentação específica consolidada do fluxo Yuri para `enriquecer_prazo_carta` em CET/SEPREF; por isso este documento foi criado.

---

## 2) Desenho funcional (alvo)

## 2.1 Prazo

Entrada:

- `df_gold` base (já pivotado via EAV)
- `silver.depara_servicos_acto`
- `silver.dim_carta_servicos_prazos`

Saída esperada no Gold:

- coluna de prazo (dias)
- coluna de data limite/prazo derivado
- coluna de status de prazo (ex.: dentro, vencido, vence hoje)
- coluna de motivo para prazo não resolvido (observabilidade)

Regra crítica:

- resolver prazo por vigência temporal correta (não usar apenas versão atual sem data de referência)

## 2.2 Unidade executora

Entrada:

- `silver.fato_etapas.executor` (para `executor_atual`)
- possíveis campos EAV de área/setor executora em `silver.fato_campos` (a confirmar por fonte)

Saída esperada no Gold:

- `executor_atual` (já disponível)
- `unidade_executora` padronizada (nova coluna de negócio)

Regra de priorização proposta:

1. usar campo canônico de unidade executora quando existir no EAV
2. fallback para campo de setor/área executora equivalente
3. fallback final para `executor_atual` (somente enquanto não houver campo institucional estável)

---

## 3) Plano de implementação por notebook

## 3.1 `nb_gold_santos_cet`

1. Construir `df_gold` base via helper EAV.
2. Aplicar `enriquecer_prazo_carta`.
3. Derivar `unidade_executora` com regra de prioridade.
4. Executar checks de observabilidade.
5. Escrever em `gold.santos_cet`.

## 3.2 `nb_gold_santos_sepref`

1. Construir `df_gold` base via helper EAV.
2. Aplicar `enriquecer_prazo_carta`.
3. Derivar `unidade_executora` com mesma regra, ajustando nomes de campo do domínio.
4. Executar checks de observabilidade.
5. Escrever em tabela Gold final de SEPREF.

---

## 4) Queries de descoberta antes do código

Executar no Fabric (por fonte) para fechar nomes reais dos campos de unidade executora:

```sql
-- CET
SELECT campo, COUNT(*) AS qtd
FROM silver.fato_campos
WHERE fonte = 'santos_cet'
  AND (
    campo LIKE '%execut%'
    OR campo LIKE '%setor%'
    OR campo LIKE '%unidade%'
    OR campo LIKE '%area%'
    OR campo LIKE '%cbo%'
  )
GROUP BY campo
ORDER BY qtd DESC;
```

```sql
-- SEPREF
SELECT campo, COUNT(*) AS qtd
FROM silver.fato_campos
WHERE fonte = 'santos_sepref'
  AND (
    campo LIKE '%execut%'
    OR campo LIKE '%setor%'
    OR campo LIKE '%unidade%'
    OR campo LIKE '%area%'
    OR campo LIKE '%cbo%'
  )
GROUP BY campo
ORDER BY qtd DESC;
```

---

## 5) Observabilidade mínima obrigatória

## 5.1 Prazo

- total de OS com prazo resolvido
- total de OS sem de-para
- top serviços sem de-para

## 5.2 Unidade executora

- taxa de preenchimento de `unidade_executora`
- top 20 valores de `unidade_executora`
- quantidade de registros em fallback para `executor_atual`

---

## 6) Critério de aceite (go/no-go)

GO:

- prazo resolvido em alta cobertura (meta inicial >= 90%)
- `unidade_executora` com cobertura adequada (meta inicial >= 85%)
- KPI principal sem divergência material contra legado na janela fechada

NO-GO:

- muitos serviços sem de-para sem plano de saneamento
- cobertura de unidade executora baixa sem fallback rastreável
- divergência relevante em KPI final

---

## 7) Próximos passos imediatos

1. Confirmar no Fabric o conteúdo atual de `nb_utils_gold_carta_prazo`.
2. Rodar as queries de descoberta de campos (CET/SEPREF).
3. Fechar mapeamento final de `unidade_executora` por fonte.
4. Aplicar no Gold CET primeiro, depois SEPREF.
5. Validar e só então avançar para cutover de consumo.

---

## 8) Referências

- [[Documentação_Fabric/Acto/DOCUMENTACAO_UNICA_ACTO|DOCUMENTACAO_UNICA_ACTO]]
- [[Documentação_Fabric/Acto/CHECKLIST_INICIO_MIGRACAO_CET_SEPREF|CHECKLIST_INICIO_MIGRACAO_CET_SEPREF]]
- [[Documentação_Fabric/Acto/nbs/nbs_gold/nb_gold_santos_cet.ipynb|nb_gold_santos_cet]]
- [[Documentação_Fabric/Acto/nbs/nbs_gold/nb_gold_santos_sepref.ipynb|nb_gold_santos_sepref]]
