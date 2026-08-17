---
status: validado
atualizado: "2026-07-22"
dono: analista-bi
valido-ate: "2026-10-01"
---

# Catalogo de Paineis Power BI - Santos

## Objetivo

Centralizar a visao funcional e tecnica dos paineis de Santos para uso do time de BI e dados.

## Fonte canonica

- _DADOS_LOCAIS_HISTORICO/Santos/mapeamento_fabric/mapeamento_paineis_powerbi.md (fonte pessoal, não versionada)
- _DADOS_LOCAIS_HISTORICO/Santos/mapeamento_fabric/diagnostico_padronizacao_paineis_pbi.md (fonte pessoal, não versionada)

## Panorama

- Total mapeado: 19 dashboards
- Estrutura por familias: 6
- Consumo principal: tabelas Gold no lakehouse

## Familias de paineis

| Familia | Qtde | Escopo | Tabelas de base |
| --- | --- | --- | --- |
| F1 - Acompanhamento de servicos | 5 | SEGOV, SEINFRA, CET, SEPREF, Ouvidoria | gold_segov_servicos, gold_seinfra_servicos, gold_cet_servicos, gold_cet_carga_descarga, gold_sepref_servicos, gold_ouvidoria_servicos |
| F2 - Manifestacoes de ouvidoria | 5 | geral + cortes por secretaria | gold_manifestacoes_ouvidoria |
| F3 - Avaliacao de servicos | 1 | satisfacao, nota e sentimento | gold_avaliacoes_servico, gold_avaliacoes_servicos_sentimento |
| F4 - Carta de servicos | 1 | catalogo, validade e tramitacao | gold_carta_servicos |
| F5 - Obras/PDR/SEONT | 5 | acompanhamento de obras | gold_pdr_acompanhamentos_os, gold_obras_tempo_etapa, gold_acto_gestao_obras_seont_os |
| F6 - Curso de motorista | 2 | frequencia e desempenho | gold_curso_motoristas |

## Padroes visuais e governanca

- familias F1/F2 seguem template mais estavel
- painel de avaliacao e familia obras apresentam maiores desvios de padrao
- watermark e fontes nao estao consistentes em todos os paineis

## Riscos BI recorrentes

| Risco | Impacto | Acao recomendada |
| --- | --- | --- |
| divergencia visual entre familias | experiencia inconsistente | aplicar design system e checklist visual |
| painel de obras dependente de pipeline instavel | dado defasado no consumo | priorizar estabilizacao de ingestao obras |
| nomenclatura inconsistente em titulos/siglas | ruido operacional | padronizar dicionario de nomes |

## Uso operacional

- para manutencao: identificar familia e tabela Gold associada
- para novos paineis: reutilizar padrao de familia ja consolidada
- para auditoria: verificar desvios no diagnostico de padronizacao

## Proxima atualizacao semanal

- revisar mudancas de familias e tabelas Gold
- atualizar riscos visuais/funcionais abertos
- registrar ajustes de padronizacao aplicados
