---
title: Checklist de Início — Migração CET e SEPREF
tags: ["tipo/checklist", "tema/migracao", "secretaria/cet", "secretaria/sepref"]
status: "ativo"
revisao: "2026-08-05"
---
# Checklist de Início — Migração CET e SEPREF

> Objetivo: iniciar a migração por CET e SEPREF usando a versão correta dos notebooks do modelo novo EAV.

## 1) Validar versão correta dos notebooks (bloqueante)

- [ ] Confirmar que o notebook CET usado é o do módulo novo EAV:
  - Caminho técnico: `Desktop/PROJETOS/Mapeamento_fabric/Acto Cidade Inteligente/Acto/nbs/nbs_gold/nb_gold_santos_cet.ipynb`
  - Sinais esperados: `%run nb_utils_gold_acto_gestao`, `FONTES = ["santos_cet"]`, `TABELA = "gold.santos_cet"`.
- [ ] Confirmar que o notebook SEPREF usado é o do módulo novo EAV:
  - Caminho técnico: `Desktop/PROJETOS/Mapeamento_fabric/Acto Cidade Inteligente/Acto/nbs/nbs_gold/nb_gold_santos_sepref.ipynb`
  - Sinais esperados: leitura de `silver.fato_*` com schema `silver.` e write ativo para `gold.fato_solicitacoes_sepref`.
- [ ] Confirmar que o utilitário `nb_utils_gold_acto_gestao.ipynb` está disponível e atualizado no ambiente de execução.
- [ ] Não usar, para migração, as cópias antigas do Obsidian que mostram write comentado em CET/SEPREF.

## 2) Escopo e janela de validação

- [ ] Definir janela temporal única para comparação (ex.: últimos 90 dias fechados).
- [ ] Definir KPIs mínimos por domínio:
  - CET: volume OS, status, etapa atual, distribuição por serviço/canal.
  - SEPREF: volume OS, status, etapa atual, bairros (ocorrência/interessado), canal.
- [ ] Listar colunas críticas de negócio por painel antes de executar cutover.

## 3) Execução técnica inicial (CET e SEPREF)

- [ ] Executar Bronze e Silver do módulo Acto para garantir base atualizada.
- [ ] Executar Gold CET novo.
- [ ] Executar Gold SEPREF novo.
- [ ] Verificar se houve escrita Delta com sucesso e sem assert.

## 4) Validação de paridade

- [ ] Comparar rowcount por período: legado vs novo.
- [ ] Comparar presença de colunas críticas (100% esperadas).
- [ ] Comparar taxa de nulos em campos críticos.
- [ ] Comparar KPI final no mesmo recorte temporal.

## 5) Preparação do cutover

- [ ] Garantir que o SQL Endpoint registrou as tabelas novas (usar `recreateTables=true` apenas na primeira publicação quando necessário).
- [ ] Validar dependência da pipeline `pl_ingest_acto`:
  - Bronze -> Silver -> _nb_gold_orquestracao -> RefreshSqlEndpoint -> refresh semântico.
- [ ] Confirmar se há refresh semântico específico de CET/SEPREF no pipeline (não assumir).

## 6) Critério de go/no-go

- [ ] GO: sem divergência material de KPI, colunas críticas presentes, pipeline concluindo.
- [ ] NO-GO: divergência de KPI, perda de coluna crítica, falha de refresh ou inconsistência de janela.

## 7) Decisão operacional para início

- [ ] Iniciar por CET.
- [ ] Em seguida SEPREF.
- [ ] Só depois abrir próxima frente (Obras/Avaliação/etc.).
