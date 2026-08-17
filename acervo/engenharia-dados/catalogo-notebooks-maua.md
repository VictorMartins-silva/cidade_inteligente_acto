---
status: validado
atualizado: "2026-07-22"
dono: engenharia-dados
valido-ate: "2026-10-01"
---

# Catalogo de Notebooks - Maua

## Objetivo

Consolidar visao operacional dos notebooks de Maua para manutencao, onboarding e planejamento de evolucao para Gold em Delta.

## Fonte canonica

- Acto Cidade Inteligente/Maua/CLAUDE.md (fonte pessoal, não versionada)

## Escopo atual

- Total mapeado: 4 notebooks
- Dominios: Meio Ambiente, Planejamento Urbano
- Workspace: lh_cidade_inteligente_maua
- Modelo legado sem semantic model DirectLake (Power BI consome via SQL Endpoint / DirectQuery)

## Inventario resumido

| Notebook | Dominio | Saida | Modo |
| --- | --- | --- | --- |
| nb_ingest_maua_acto_gestao_ambiente | Meio Ambiente | gold_maua_meio_ambiente_solicitacoes, gold_maua_meio_ambiente_etapas | overwrite Delta |
| nb_ingest_maua_acto_gestao_plan_urbano | Planejamento Urbano | 26 Parquet silver + etapas em Files/silver_planejamento_urbano/ | Parquet (migracao pendente) |
| nb_silver_maua_plan_urbano | Planejamento Urbano | gold_maua_pl_urbano | overwrite Delta |
| nb_silver_maua_etapas_tempo_plan_urbano | Planejamento Urbano | gold_maua_pl_urbano_etapas | overwrite Delta |

## Pontos criticos de migracao para Gold

| Notebook | Estado atual | Acao recomendada |
| --- | --- | --- |
| nb_ingest_maua_acto_gestao_plan_urbano | gera 26 Parquets de solicitacoes + etapas + decisoes | migrar para saveAsTable() Delta, eliminando camada Parquet intermediaria |

## Dependencias de atencao

- API Acto Gestao (TOKEN_MAUA), payloads JSON versionados em payload/
- funcao adicionar_etapa_atual_2() (espera coluna 'No Solicitacao' sem sufixo de pipe) - nao confundir com adicionar_etapa_atual() de Santos
- notebook utilitario compartilhado nb_utils_maua_ingest_acto_gestao

## Riscos e gaps conhecidos

| Gap | Impacto | Prioridade |
| --- | --- | --- |
| campo data_de_emissao ausente na API (Meio Ambiente) | bloqueia pagina planejada R3 - Documentos Emitidos | alta |
| ausencia de shapefile oficial de bairros | granularidade geografica minima passa a ser Regiao de Planejamento (RP1-14) | media - decisao ja tomada |
| divergencia de nome de coluna CNAE | validar nome real antes de referenciar em silver.fato_campos | media |
| subformularios (arrays aninhados) nao capturados no modelo EAV | bloqueia paginas planejadas R7 e R8 | media - requer extensao da camada Bronze |
| pastas pipelines/ e bis_producao/ vazias | nenhum pipeline de orquestracao ou painel Power BI publicado ainda | alta - fundacional |
| sem semantic model DirectLake | consumo Power BI depende de DirectQuery no SQL Endpoint | media |

## Uso operacional

- para debug: identificar dominio e notebook antes da alteracao, validar nome de coluna quando aplicavel (CNAE, etapa)
- para evolucao: priorizar migracao de saida Parquet do Planejamento Urbano para Delta
- para paineis: 8 paginas planejadas (R1-R8) conforme spec_powerbi_maua_meio_ambiente.md; R3, R6, R7, R8 bloqueadas por lacunas de dado

## Proxima atualizacao semanal

- acompanhar criacao de pipeline de orquestracao (ainda inexistente)
- acompanhar evolucao das paginas Power BI planejadas e desbloqueio de R3/R7/R8
- revisar migracao Parquet -> Delta do Planejamento Urbano
