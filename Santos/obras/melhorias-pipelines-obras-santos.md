---
title: Melhorias de Pipeline — Obras Santos
date: 2026-04-13
tags:
  - projeto/obras-santos
  - ferramenta/fabric
  - tema/pipeline
  - data-factory
status: proposta
---

> Propostas de otimização para os pipelines do Data Factory — sem alteração de notebooks.
> Contexto: [[Documentação_Fabric/Santos/obras/Processo Obras Santos|Processo Obras Santos]] · Projeto: [[Projetos/acto-santos-pipeline]]

Oportunidade 1 — Paralelizar Obras (ganho imediato)

  Hoje os 4 notebooks rodam em série pura:
  ingest_silver → gold_etapas → gold_obras → gold_seont_os → Refresh → 4× PBI

  gold_etapas e gold_obras leem os mesmos Parquets do silver e são completamente independentes entre si. Só gold_seont_os depende de  
  gold_obras. Dá para paralelizar:

  ingest_silver
        ↓
  [gold_etapas] ──── [gold_obras]   ← paralelo
                         ↓
                   [gold_seont_os]
                         ↓
                 [RefreshSqlEndpoint]
                         ↓
                 [4× PBI paralelos]
  Ganho: elimina o tempo ocioso de esperar gold_etapas terminar antes de gold_obras iniciar.

  ---
  Oportunidade 2 — Consolidar SEGOV + SEINFRA + SEPREF + Manifestações + Ouvidoria (maior ganho)

  Hoje você tem 5 pipelines independentes para domínios que convergem no [[Documentação_Fabric/Santos/nbs/manifestação_ouvidoria/nb_gold_acto_gestao_ouvidoria_servicos.ipynb|nb_gold_acto_gestao_ouvidoria_servicos]] (unionAll de 5        
  tabelas). O problema atual: não há garantia de ordem — o pipeline de ouvidoria pode rodar com dados velhos de alguma secretaria.    

  Hoje (5 pipelines isolados sem dependência entre si):
  pl_segov       → gold_segov    ─┐
  pl_seinfra     → gold_seinfra  ─┤
  pl_sepref      → gold_sepref   ─┼→ [sem sincronização] → pl_ouvidoria_servicos
  pl_cet         → gold_cet      ─┤
  pl_manifestacoes → gold_manif  ─┘

  Proposta — 1 pipeline unificado:
  [gold_segov] [gold_seinfra] [gold_sepref] [gold_manifestacoes]   ← 4 em paralelo
                            ↓
                 [gold_ouvidoria_servicos]  (unionAll, só roda depois dos 4)
                            ↓
                 [RefreshSqlEndpoint]  (1 único, em vez de 5)
                            ↓
                 [todos os modelos PBI em paralelo]

  Ganhos:
  - Garante que o unionAll sempre usa dados frescos das 4 tabelas
  - Reduz de 5 pipelines para 1 (menos overhead de agendamento)
  - 1 RefreshSqlEndpoint em vez de 5 chamadas separadas

  ▎ O CET pode continuar separado pois já tem o curso de motoristas junto e tem modelo PBI próprio.

  ---
  Oportunidade 3 — Paralelizar CET

  Hoje (4 notebooks em série):
  gold_cet → gold_cet_carga_descarga → ingest_curso → silver_curso → Refresh → 2× PBI

  gold_cet, gold_cet_carga_descarga e a cadeia ingest_curso → silver_curso são completamente independentes. Só precisam convergir     
  antes do RefreshSqlEndpoint:

  [gold_cet] ── [gold_cet_carga_descarga] ── [ingest_curso → silver_curso]   ← 3 branches paralelas
                                 ↓
                         [RefreshSqlEndpoint]
                                 ↓
                    [PBI_cet]  [PBI_curso_motoristas]   ← paralelo
  Ganho: o tempo do pipeline cai para o tempo da branch mais lenta, em vez da soma das 4.

  ---
  Oportunidade 4 — Incluir Sentimento no Pipeline de Avaliação

  [[Documentação_Fabric/Santos/nbs/avaliacao_servicos/nb_gold_santos_avaliacao_sentimento.ipynb|nb_gold_santos_avaliacao_sentimento]] hoje roda sem pipeline (manual). Pode entrar no pipeline de avaliação com allowFailure = true   
  para que uma falha da API Groq não bloqueie o refresh do modelo principal:

  [[Documentação_Fabric/Santos/nbs/avaliacao_servicos/nb_gold_santos_avaliacao.ipynb|nb_gold_santos_avaliacao]]
          ↓
  [[Documentação_Fabric/Santos/nbs/avaliacao_servicos/nb_gold_santos_avaliacao_sentimento.ipynb|nb_gold_santos_avaliacao_sentimento]]  [allowFailure = true]
          ↓
  RefreshSqlEndpoint
          ↓
  [[Documentação_Fabric/Powerbi-Santos/acompanhamento_avaliacao_servicos.pdf|acompanhamento_avaliacao_servicos]]

  ---
  Resumo das Propostas

  ┌─────┬───────────────────────────────────────────────────────────────┬─────────┬───────────────────────────────────────────────┐   
  │  #  │                          O que fazer                          │ Esforço │                     Ganho                     │   
  ├─────┼───────────────────────────────────────────────────────────────┼─────────┼───────────────────────────────────────────────┤   
  │ 1   │ Paralelizar gold_etapas e gold_obras em                       │ Baixo   │ Reduz tempo do pipeline de obras              │   
  │     │ pl_ingest_obras_santos                                        │         │                                               │   
  ├─────┼───────────────────────────────────────────────────────────────┼─────────┼───────────────────────────────────────────────┤   
  │ 2   │ Consolidar SEGOV + SEINFRA + SEPREF + Manifestações +         │ Médio   │ Garante consistência do unionAll + elimina 4  │   
  │     │ Ouvidoria em 1 pipeline                                       │         │ pipelines                                     │   
  ├─────┼───────────────────────────────────────────────────────────────┼─────────┼───────────────────────────────────────────────┤   
  │ 3   │ Paralelizar as 3 branches do CET                              │ Baixo   │ Reduz tempo do pipeline CET                   │   
  ├─────┼───────────────────────────────────────────────────────────────┼─────────┼───────────────────────────────────────────────┤   
  │ 4   │ Adicionar sentimento ao pipeline de avaliação com             │ Baixo   │ Automatiza o sentimento, sem risco de         │   
  │     │ allowFailure                                                  │         │ bloquear o modelo PBI                         │   
  └─────┴───────────────────────────────────────────────────────────────┴─────────┴───────────────────────────────────────────────┘   

  Todas as mudanças são puramente de configuração dentro do Data Factory — sem alterar nenhum notebook. Quer que eu detalhe como      
  configurar alguma dessas no Fabric?

---

## Ver Também

- [[Documentação_Fabric/Santos/obras/Processo Obras Santos|Processo Obras Santos]] — pipeline completo de obras
- [[Conhecimento/Fabric/pipeline-acto-santos-fabric|pipeline-acto-santos-fabric]] — fluxo atual Data Factory
- [[Projetos/acto-santos-pipeline]] — projeto ACTO Santos
- [[_mapa-do-vault]] — índice geral
