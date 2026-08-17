---
title: Governança e Manutenção
date: 2026-05-20
tags:
  - ferramenta/fabric
  - tipo/referencia
projeto: acto-cidade-inteligente
fonte: documentacao-interna
status: ativo
---
# Governança e Manutenção

## 1. Matriz de Riscos (Auditoria v2.0)

| ID | Risco | Status | Impacto | Ação |
|---|---|---|---|---|
| **R1** | Hardcode em `/Files` | 🟠 Médio | Quebra se arquivo sumir | Migrar para Tabelas Delta |
| **R5** | Erro 401 (Obras) | 🔴 Crítico | Relatórios desatualizados | Ajustar `nb_utils_api_acto_gestao_obras` |
| **R6** | Conflito `adicionar_etapa` | 🟡 Baixo | Dados `NaN` no BI | Unificar para função `_2` |
| **R9** | Hardcode IBGE | 🔴 Crítico | Dados cruzados (SNT vs OSC) | Centralizar em config central |

## 2. Orquestração (Pipelines)
- **`pl_ingest_acto_santos`**: Diário.
- **`pl_ingest_obras_santos`**: Diário (Atualmente com falha R5).
- **`pl_silver_cet_servicos`**: Diário.
- **`pl_gold_carta_servicos_csv`**: Semanal.

## 3. Guia de Troubleshooting
### 3.1 Token Expirado
Execute o notebook `Acto/nb_get_token_api.ipynb` para validar as credenciais.

### 3.2 Colunas com `NaN`
Verifique se o notebook está usando o `adicionar_etapa_atual` correto para o payload da API. O join deve ser feito pelo campo `"Nº Solicitação"` sem sufixos em novos catálogos.

### 3.3 Falha no Power BI
Verifique o status do **SQL Analytics Endpoint** no Fabric. Se as tabelas Gold estiverem com `overwriteSchema=True`, o endpoint pode precisar de refresh manual.
