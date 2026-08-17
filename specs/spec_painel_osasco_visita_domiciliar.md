---
title: "Spec — Visita Domiciliar (NPCAD) · Osasco"
tags: ["osasco", "assistencia-social", "npcad", "painel", "spec", "eav"]
municipio: Osasco
status: painel-construido-aguardando-publicacao
data: "2026-07-21"
relacionados:
  - "[[Documentação_Fabric/Acto/EAV_BRONZE_INVENTARIO]]"
  - "[[Documentação_Fabric/Acto/SCHEMA_LAKEHOUSE_ACTO]]"
  - "[[00_INDEX_SPECS]]"
---

# Visita Domiciliar (NPCAD) · Osasco

Painel para o serviço "Visita Domiciliar" executado pelo NPCAD (Núcleo de Pesquisa, Cadastro e Documentação — SAS/Osasco), que valida endereço de moradia e composição familiar de solicitantes do CadÚnico.

**Origem:** `PLANO_PAINEL Visita Domiciliar_PMO_2026_07_06.docx` (V.100, 06/07/2026, elaborado por Susélide Tenani/Governança).
**Publicação prevista:** Sistema ACTO, Módulo Gestão, Menu Painel de Indicadores.
**Frequência de carga:** diária.
**Local de trabalho / documentação técnica:** `Acto Cidade Inteligente/Osasco/nbs/assistencia_social/visita_domiciliar/README.md` — inclui todo o histórico de descoberta de campos, o script `testar_payload_local.py` para revalidar o payload contra a API real, e o payload final (`payload/visita_domiciliar.json`).

---

## Status (21/07/2026)

| Etapa | Status |
|---|---|
| Payload configurado e validado contra a API real do Acto | ✅ 166 OS, todos os campos mapeados presentes |
| Bronze (`bronze.fato_solicitacoes/campos/etapas_osasco_visita_domiciliar`) | ✅ Rodado no Fabric — 166 solicitações, 540 etapas |
| Silver (`silver.fato_solicitacoes/campos/etapas`, `fonte = 'osasco_visita_domiciliar'`) | ✅ Rodado no Fabric |
| Gold (`gold.osasco_visita_domiciliar`) | ✅ Rodado no Fabric — 166 linhas, 28/29 campos EAV pivotados |
| Painel Power BI / nativo Acto | ✅ Construído (Visão Geral + Base Detalhada) — 🟡 **publicação e homologação com o PMO ainda pendentes** |
| Documentação formal do painel (este spec) | ✅ Este documento |

> [!note] Atualização 21/07/2026
> Construção do painel concluída. Publicação formal e validação com o PMO (pendências 1-3 abaixo) ainda em aberto antes de considerar o item fechado de ponta a ponta.

---

## Fluxo real do serviço no Acto — `FLX_VISITA_DOMICILIAR`

```
ABERTURA → ATUALIZAÇÃO → ANÁLISE → VISITA → ACOMPANHAMENTO → ENCERRAMENTO
```

Cada etapa tem formulário próprio (`FOR_VISITA_DOMICILIAR - {ETAPA}`), mas é um **template de cadastro social genérico reaproveitado** entre etapas — o serviço tem 723 campos configuráveis no total (CPF, Nome, BPC, Bolsa Família, CadOZ etc.), dos quais só ~29 são relevantes para este painel. `codCatalogo` do serviço: `13924`.

Etapas observadas em produção (14/07/2026, 540 registros / 166 OS): ABERTURA 154 · ATUALIZAÇÃO 153 · ANÁLISE 117 · VISITA 68 · ENCERRAMENTO 47 · ACOMPANHAMENTO 1 (existe no fluxo real mas não aparece no seletor de etapas do configurador de relatório).

---

## Requisitos do painel (docx)

### Aba VISÃO GERAL

Filtros: Período (Ano/Mês/Dia, default mês atual) · Sigla Unidade Origem · Motivo visita · Resultado visita · Status O.S. (Pendente/Atendimento, Finalizado, Cancelado)

9 indicadores:
1. Total de solicitações de visitas
2. Visitas por status (quantidade e %)
3. Visitas por etapa (quantidade e %)
4. Visitas por motivo (quantidade e %)
5. Visitas por unidade origem (quantidade e %)
6. Visitas por executor — executor da etapa VISITA (quantidade e %)
7. Visitas por resultado — atributo da etapa VISITA (gráfico de barras)
8. Distribuição de visitas por período — solicitada (data de solicitação) vs. realizada (data de conclusão da etapa VISITA)
9. Distribuição de visitas por bairro — mesma lógica solicitada/realizada

### Aba BASE DETALHADA

32 colunas: Nº Solicitação, Data Solicitação, Status, Data Finalização, CPF/Nome interessado, Data Nascimento, Classificação, Subclassificação, Atualizado, Usuário, Serviço, CadÚnico (Cod.Familiar/Atualização), Unidade Origem, Zona Origem, Solicitante Origem, endereço completo (Bairro/Tipo/Logradouro/Número/Complemento), telefones, e-mail, Motivo, Data e Responsável da 1ª/2ª/3ª visita, Resultado da Visita.

### Aba MONITORAMENTO

🔴 **Sem conteúdo definido no docx original** — só o título aparece no sumário. Pendência a validar com o PMO antes de desenhar essa aba.

---

## Mapeamento — campo do docx → payload → Gold

Os **6 campos padrão** (sem etapa vinculada, presentes em toda fonte Acto):

| docx | payload `col`/`tit` | coluna Gold |
|---|---|---|
| Nº Solicitação | `seqFluxo` / "Nº Solicitação" | `id_os` |
| Serviço | `servico` / "Serviço" | `servico` |
| Status | `statusFluxo` / "Status Fluxo" | `status_fluxo` |
| Data Finalização | `dataCriacao` / "Data Finalização" | `data_finalizacao` |
| Data Solicitação | `dataSolicitacao` / "Data Criação" | `data_criacao` |
| Solicitante Origem | `solicitante` / "Solicitante" | `solicitante` |

Os **28 campos EAV com dado** (nome real em `fato_campos.campo` = `col` do payload em minúsculo — ver achado técnico abaixo):

| docx | coluna Gold (`fato_campos.campo`) | Preenchimento (166 OS) |
|---|---|---|
| CPF interessado | `txt_cpf_interessado` | 85% |
| Nome interessado | `txt_nome_interessado` | 85% |
| Data Nascimento | `dt_nascimento_interessado` | 84% |
| Classificação | `cbo_classificacao` | 85% |
| Subclassificação | `cbo_subclassificacao` | 46% |
| CadÚnico – Atualização | `dt_cadunico_atualizado_interessado` | 41% |
| Solicitante Origem (sigla) | `uorg_sigla` | 69% |
| Unidade Origem | `uorg_nome` | 73% |
| Zona Origem | `uorg_regiao` | 70% |
| Bairro | `txt_bairro_interessado` | 84% |
| Tipo (logradouro) | `txt_tipo_logradouro_interessado` | 84% |
| Logradouro | `txt_nome_logradouro_interessado` | 84% |
| Número | `txt_numero_interessado` | 84% |
| Complemento | `txt_complemento_interessado` | 51% |
| Telefone principal | `txt_telefone_interessado` | 84% |
| Telefone alternativo | `txt_telefone_alternativo_interessado` | 45% |
| E-mail | `txt_email_interessado` | 54% |
| Motivo | `cbo_demandas` | 72% |
| Justificativa (bônus, fora do docx) | `txa_descricao_solicitacao` | 76% |
| "Atualizado" | `txt_atualizado_interessado` | 28% |
| "Usuário" | `txt_usuario_interessado` | 28% |
| Data 1ª visita | `dt_visita_1` | 25% |
| Data 2ª visita | `dt_visita_2` | 3% |
| Data 3ª visita | `dt_visita_3` | 1% |
| Responsável 1ª visita | `txt_responsavel_1_visita_1` | 25% |
| Responsável 2ª visita | `txt_responsavel_1_visita_2` | 3% |
| Responsável 3ª visita | `txt_responsavel_1_visita_3` | 1% |
| Resultado da Visita | `cbo_resultado_visita` | 25% |

**Campo configurado mas sempre vazio:** `CadÚnico – Cod.Familiar` (`txt_cadunico_fam_cod_interessado`, `codFormularioCampo` 944101) — Id confirmado correto no Acto (visível, etapa ABERTURA), mas 0/166 OS têm valor. **Não é bug de configuração — é gap de processo do NPCAD** (o técnico não preenche esse campo na prática). Levar ao PMO; candidato relacionado não selecionado: `A composição familiar abaixo foi declarada ao CADÚNICO do governo federal` (id 944156).

**Colunas adicionais no Gold, geradas automaticamente por `build_gold_fato_solicitacoes()`:** `etapa_atual`, `executor_atual`, `data_fim_ultima_etapa` (última etapa via window function, não a etapa VISITA especificamente), `bairro_consolidado` (coalesce de `txt_bairro_interessado`).

---

## Achado técnico — nome do `campo` em `fato_campos` para fontes EAV

`Acto/CLAUDE.md` e `EAV_BRONZE_INVENTARIO.md` documentam que a API do Acto usa o **`tit`** como chave da resposta JSON (`clean_col_name(tit)` vira o nome da coluna). **Essa regra vale apenas para os 6 campos padrão** (sem `codEtapa`/`codFormularioCampo`).

Para campos de formulário/EAV (com `codFormularioCampo` preenchido no payload), a API retorna a linha chaveada pelo **`col` do payload, em minúsculo** — não pelo `tit`. Confirmado em produção via:

```sql
SELECT campo, COUNT(*) AS n FROM silver.fato_campos
WHERE fonte = 'osasco_visita_domiciliar' GROUP BY campo ORDER BY n DESC
```

Isso quebrou a primeira tentativa do `nb_gold_osasco_visita_domiciliar` (28/28 campos reportados como "ausentes" — o `CAMPOS` usava os nomes derivados de `tit`). Corrigido usando os nomes reais de `col`. **Aplicar essa regra em qualquer fonte EAV nova:** montar o `CAMPOS` do Gold com `lower(col)`, e sempre confirmar via a query acima antes de finalizar, em vez de assumir pelo `tit`. Detalhe adicionado também em `EAV_BRONZE_INVENTARIO.md`.

---

## Pipeline — arquivos alterados/criados

| Arquivo | Mudança |
|---|---|
| `Files/payloads/payload_osasco_visita_domiciliar.json` | Novo — 35 campos (6 padrão + 29 EAV) |
| `Acto Cidade Inteligente/Acto/nbs/nbs_bronze/nb_bronze_orquestracao.ipynb` | Nova entrada em `fontes[]` — `id_fonte: "osasco_visita_domiciliar"`, `secretaria: "SAS"`, `unidade_organizacional: "NPCAD"` |
| `Acto Cidade Inteligente/Acto/nbs/nbs_silver/nb_silver_acto_gestao.ipynb` | `"osasco_visita_domiciliar"` adicionado em `FONTES` |
| `Acto Cidade Inteligente/Acto/nbs/nbs_gold/nb_gold_osasco_visita_domiciliar.ipynb` | Novo — usa `build_gold_fato_solicitacoes()`, 28 campos EAV pivotados |
| `Acto Cidade Inteligente/Acto/nbs/nbs_gold/_nb_gold_orquestracao.ipynb` | `%run ./nb_gold_osasco_visita_domiciliar` adicionado |

---

## Pendências

| # | Item | Ação |
|---|---|---|
| 1 | Aba MONITORAMENTO sem conteúdo no docx | Validar com o PMO antes de desenhar |
| 2 | `secretaria: "SAS"` / `unidade_organizacional: "NPCAD"` | Assumido, não confirmado formalmente com o PMO |
| 3 | `CadÚnico – Cod.Familiar` sempre vazio | Gap de processo do NPCAD, não bug — levar ao PMO |
| 4 | Refresh do SQL Endpoint + modelo PBI em `pl_ingest_acto` | Ainda não adicionado |
| 5 | ~~Construção do painel (Power BI ou nativo Acto)~~ | ✅ Concluída 21/07 — falta publicação/homologação formal |

---

## Próximos passos

1. Adicionar refresh desta fonte em `pl_ingest_acto` (RefreshSqlEndpoint + PBI).
2. Validar com o PMO as pendências 1–3 acima.
3. ~~Montar o painel seguindo os 9 indicadores da Visão Geral + tabela Base Detalhada~~ — ✅ concluído 21/07.
4. Publicar o painel e adicionar entrada nº 25 em `MAPEAMENTO_PAINEIS_OSASCO_FABRIC.md`.
