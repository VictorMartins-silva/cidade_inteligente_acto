---
title: Plano — Extração via Excel e Centralização dos Códigos
tags:
  - municipio/santos
  - tipo/plano
  - refatoracao
date: 2026-04-14
aliases:
  - plano excel catalogos
  - centralização acto santos
status: "referencia"
description: "Plano de extração de dados via Excel para Santos"
---
# Plano — Extração via Excel e Centralização dos Códigos

> [!abstract] Objetivo
> Substituir os `codCatalogo` e `codigos_etapa` hardcoded em múltiplos notebooks por uma planilha Excel centralizada no Lakehouse, com um script Python genérico de extração.
> 
> Referência dos códigos atuais: [[codigos_catalogos_etapas_santos|Tabela de Códigos — Catálogos e Etapas]]

---

## Contexto e Motivação

Hoje cada notebook de domínio tem os códigos espalhados no próprio código ou em arquivos JSON externos, gerando:

- Manutenção dispersa — adicionar um serviço exige editar código
- Arquivos JSON do SEPREF são pontos únicos de falha (**R1** da [[Documentação_Fabric/_obsoleto/Relatório Técnico_ Arquitetura, Mapeamento e Otimização — Microsoft Fabric|Relatório Técnico Fabric]])
- Difícil auditar quais serviços estão ativos sem abrir cada notebook

Veja o inventário completo de 111 catálogos em [[codigos_catalogos_etapas_santos]].

---

## Estrutura da Planilha Excel

**Arquivo:** `Files/acto_gestao_api_payload/config_catalogos.xlsx`

### Aba `catalogos`

| Coluna | Tipo | Descrição |
|---|---|---|
| `cod_catalogo` | int | Código do catálogo na API Acto |
| `nome_servico` | str | Nome legível do serviço |
| `dominio` | str | OBRAS, CET, SEGOV, SEINFRA, SEPREF, OUVIDORIA |
| `grupo` | int | Partição da chamada (1, 2, 3…) — para domínios com limite de resposta |
| `ativo` | int | 1 = ativo, 0 = ignorar na extração |

### Aba `etapas`

| Coluna | Tipo | Descrição |
|---|---|---|
| `cod_catalogo` | int | FK para aba `catalogos` |
| `cod_etapa` | int | Código da etapa monitorada |
| `ordem` | int | Sequência da etapa no fluxo (opcional) |

> [!tip] Por que duas abas?
> Manter etapas em linhas separadas evita fazer parse de listas em células — o script faz `groupby("cod_catalogo")["cod_etapa"].apply(list)` antes de montar o payload.

---

## Script Python — Lógica Genérica

Notebook a criar: `nb_utils_config_catalogos`

```python
import pandas as pd
import json

ARQUIVO_CONFIG = "/lakehouse/default/Files/acto_gestao_api_payload/config_catalogos.xlsx"

def carregar_config(dominio: str = None, apenas_ativos: bool = True):
    """Carrega catalogos e etapas do Excel de configuração."""
    df_cat = pd.read_excel(ARQUIVO_CONFIG, sheet_name="catalogos")
    df_eta = pd.read_excel(ARQUIVO_CONFIG, sheet_name="etapas")

    if apenas_ativos:
        df_cat = df_cat[df_cat["ativo"] == 1]
    if dominio:
        df_cat = df_cat[df_cat["dominio"] == dominio.upper()]

    df_eta_grp = (
        df_eta.groupby("cod_catalogo")["cod_etapa"]
        .apply(list)
        .reset_index()
        .rename(columns={"cod_etapa": "etapas"})
    )
    return df_cat.merge(df_eta_grp, on="cod_catalogo", how="left")


def extrair_dominio(dominio: str, TOKEN: str):
    """Extrai dados de todos os catálogos ativos de um domínio."""
    df_config = carregar_config(dominio=dominio)
    frames_solicitacoes, frames_etapas = [], []

    for grupo_id, df_grupo in df_config.groupby("grupo"):
        lista_catalogos = df_grupo["cod_catalogo"].tolist()
        df_etapas = obter_dados_etapa_atual(TOKEN, lista_catalogos)
        payload = montar_payload(df_grupo)
        df_solicitacoes = fetch_tabela(json.dumps(payload))
        frames_solicitacoes.append(df_solicitacoes)
        frames_etapas.append(df_etapas)

    return pd.concat(frames_solicitacoes), pd.concat(frames_etapas)
```

---

## Cenários por Domínio

### Domínios simples — script genérico funciona diretamente

| Domínio | Catálogos | Grupos | Ver códigos |
|---|---|---|---|
| OUVIDORIA | 1 | 1 | [[codigos_catalogos_etapas_santos#6. Ouvidoria]] |
| SEGOV | 4 | 1 | [[codigos_catalogos_etapas_santos#3. SEGOV]] |
| SEINFRA | 6 | 1 | [[codigos_catalogos_etapas_santos#4. SEINFRA]] |
| CET | 25 | 1 | [[codigos_catalogos_etapas_santos#2. CET]] |

### Domínios com particularidades

| Domínio | Catálogos | Situação | Detalhe |
|---|---|---|---|
| SEPREF | 49 | 3 grupos | Coluna `grupo` (1, 2, 3) resolve o particionamento. Ver [[codigos_catalogos_etapas_santos#5. SEPREF]] |
| OBRAS | 26 | Bloqueado | Pipeline parado por HTTP 401. Depende da correção do **R5** antes da migração. Ver [[codigos_catalogos_etapas_santos#1. Obras]] |

---

## Fases de Implementação

### Fase 1 — Criar e popular o Excel

- [ ] Criar `config_catalogos.xlsx` com abas `catalogos` e `etapas`
- [ ] Preencher com os 111 catálogos e 153+ etapas (fonte: [[codigos_catalogos_etapas_santos]])
- [ ] Upload para `Files/acto_gestao_api_payload/` no Lakehouse
- [ ] Validar: todos os catálogos ativos presentes

### Fase 2 — Criar `nb_utils_config_catalogos`

- [ ] Implementar `carregar_config()` e `extrair_dominio()`
- [ ] Adicionar sob `utils/` no repositório
- [ ] Testar leitura do Excel e montagem do payload com OUVIDORIA (1 catálogo — validação mais rápida)

### Fase 3 — Migrar domínios simples

Ordem por menor risco:

1. OUVIDORIA ← começar aqui
2. SEGOV
3. SEINFRA
4. CET

Para cada domínio:
- [ ] Substituir lista hardcoded por `carregar_config(dominio="X")`
- [ ] Comparar rowcount com versão anterior
- [ ] Confirmar rowcount `> threshold` antes de salvar na Gold (padrão de [[Documentação_Fabric/doc/Mapeamento Técnico de Notebooks — Município de Santos|Mapeamento Técnico Santos]])

### Fase 4 — Migrar SEPREF

- [ ] Validar se os 3 `payload_sepref*.json` podem ser substituídos por payloads gerados dinamicamente
- [ ] Testar os 3 grupos particionados
- [ ] Remover arquivos JSON externos do Lakehouse após validação (elimina R1)

### Fase 5 — Obras (bloqueada pelo R5)

> [!danger] Pré-requisito
> Resolver primeiro o HTTP 401 em `nb_utils_api_acto_gestao_obras`:
> adicionar `try/except HTTPError 401 → login_acto_gestao_obras() → retry`.

- [ ] Estabilizar pipeline de obras
- [ ] Migrar os 26 catálogos para o Excel

### Fase 6 — Evolução para Delta Table (opcional)

Substituir o Excel por `config.tb_catalogos_ativos` no Lakehouse:

```python
# leitura via Delta (Fase 6)
df_config = spark.read.table("config.tb_catalogos_ativos").toPandas()
```

Benefícios: elimina dependência de arquivo físico, versionamento via Delta log, leitura nativa por PySpark.

---

## Riscos

| Risco | Impacto | Mitigação |
|---|---|---|
| Excel corrompido ou path alterado | Pipeline para | Migrar para Delta Table (Fase 6) |
| Catálogo inativo no Excel mas ativo na API | Dados faltantes silenciosos | Coluna `ativo` + alerta quando rowcount cair abaixo do threshold |
| Novo serviço na API sem atualizar o Excel | Fora do escopo | Reconciliação mensal: `listar_catalogos()` vs Excel |
| SEPREF sem nomes de serviço no Excel | `nome_servico` vazio | Manter payload JSON como fallback até validação completa da Fase 4 |

---

## Links Relacionados

- [[codigos_catalogos_etapas_santos|Tabela de Códigos — Catálogos e Etapas (referência completa)]]
- [[Documentação_Fabric/doc/Mapeamento Técnico de Notebooks — Município de Santos|Mapeamento Técnico de Notebooks — Santos]]
- [[DOCUMENTACAO_CONSOLIDADA_FABRIC]]
- [[Documentação_Fabric/_obsoleto/Relatório Técnico_ Arquitetura, Mapeamento e Otimização — Microsoft Fabric|Relatório Técnico Fabric]]
- [[roadmap_acto_fabric]]
