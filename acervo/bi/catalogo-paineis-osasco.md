---
status: validado
atualizado: "2026-07-22"
dono: analista-bi
valido-ate: "2026-10-01"
---

# Catalogo de Paineis Power BI - Osasco

## Objetivo

Centralizar a visao funcional e tecnica dos paineis de Osasco para uso do time de BI e dados.

## Fonte canonica

- MAPEAMENTO_PAINEIS_OSASCO_FABRIC.md (fonte pessoal, não versionada)

## Panorama

- Total mapeado: 24 paineis ativos (+1 predecessor historico +1 pipeline pronto sem painel publicado)
- Estrutura por eixos tematicos: 9
- Consumo principal: tabelas Gold no lakehouse local e em lh_dados_publicos (dominios escalaveis)

## Eixos tematicos

| Eixo | Qtde paineis | Tabelas Gold principais | Observacao |
| --- | --- | --- | --- |
| Assistencia Social | 8 (+1 predecessor) | gold_cad_unico_*, gold_rma_cras_*, gold_rma_creas_indicadores, gold_atendimento_cras, gold_osasco_atendimento_trabalhador, gold_pbf_municipios_selecionados, gold_bolsa_trabalho | maior densidade de paineis do municipio |
| Desenvolvimento Economico | 3 | gold_osasco_pib_*, gold_caged_*, gold_rais (CSV) | RAIS ainda em CSV |
| Relacoes Internacionais / Comex | 1 | gold_osasco_comexstat | dominio exclusivo local |
| Censo / Demografico | 3 | gold_osasco_populacao_ibge, gold_censo_demografico (CSV) | fecundidade ainda em CSV |
| Seguranca Publica e Viaria | 3 | gold_seg_publica_*, gold_seguranca_viaria, gold_monitora_oz | seguranca viaria com Parquet redundante |
| Desenvolvimento Urbano | 2 | gold_alvaras_obras | mapas de zoneamento sem fonte documentada |
| Saude | 1 | CadOZ local (sem Gold central) | contem PII sensivel (CPF/nome/endereco) |
| Esporte e Lazer | 1 | sem notebook identificado no inventario | mapeamento pendente |
| Governo e Cidadania | 1 | gold_carta_servicos, gold_carta_servicos_atualizacoes, gold_carta_servicos_tempo_etapa | segue padrao de carta de servicos |

## Pipeline pronto sem painel publicado

- dominio: Visita Domiciliar (NPCAD)
- tabela Gold: gold.osasco_visita_domiciliar
- status: pipeline testado, painel (Power BI ou nativo Acto) ainda pendente

## Riscos e gaps recorrentes

| Risco/Gap | Impacto | Prioridade |
| --- | --- | --- |
| canvas com tamanhos de pagina inconsistentes entre familias | experiencia de navegacao ruim | alta em paineis criticos (RMA/CRAS, obras, seguranca publica) |
| saidas em CSV (RAIS, censo demografico) | fragilidade de consumo e falta de padrao Delta | media |
| duplicacao Delta+Parquet em seguranca viaria | redundancia e custo de manutencao | media |
| painel com dado PII sensivel (CadOZ H1N1) | risco de exposicao indevida | alta - tratar como governanca de acesso |
| notebooks de ingestao nao identificados (esporte, CadOZ) | dificuldade de manutencao e auditoria | baixa/media |
| BPC sem Gold publicada (escrita comentada) | indicador ausente para painel | alta |

## Uso operacional

- para manutencao: identificar eixo tematico e tabela Gold associada antes de alterar
- para novos paineis: priorizar padrao Delta e canvas padronizado por familia
- para dado sensivel: tratar CadOZ como caso de acesso restrito, nao publicar base detalhada externamente

## Proxima atualizacao semanal

- revisar avanco da migracao CSV -> Delta (RAIS e censo demografico)
- acompanhar publicacao do painel de Visita Domiciliar
- revisar status de padronizacao de canvas nos paineis criticos
