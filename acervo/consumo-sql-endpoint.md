---
status: validado
atualizado: "2026-07-22"
dono: engenharia-dados
---

# Consumo SQL Endpoint

## Objetivo

Definir contratos de consumo de dados por aplicacoes e BI via SQL Endpoint.

## Contrato minimo

- tabela/visao consumida
- granularidade
- atraso maximo aceitavel
- colunas obrigatorias
- regra para nulos e registros invalidos

## Padrao de acesso

- consumir preferencialmente Gold
- evitar dependencia de estrutura Bronze/Silver em consumo final
- registrar mudancas de schema como decisao quando houver impacto cross-time

## Limitacoes conhecidas

- refresh pode introduzir defasagem temporaria
- mudanca de medida DAX nao corrige dado inconsistente na Gold
- necessidade de reconciliacao de contagem em casos de divergencia

## Checklist de publicacao

- validacao de rowcount
- validacao de campos-chave
- confirmacao de refresh endpoint/modelo
- evidencia de consistencia final no painel

## Contratos por familia de consumo (Santos)

| Familia | Fonte Gold principal | Atraso maximo aceitavel | Dono do dominio |
| --- | --- | --- | --- |
| Acompanhamento de servicos | gold_segov_servicos, gold_seinfra_servicos, gold_cet_servicos, gold_sepref_servicos | 1 dia util | Engenharia de Dados Santos |
| Manifestacoes de ouvidoria | gold_manifestacoes_ouvidoria | 1 dia util | Engenharia de Dados Santos |
| Avaliacao de servicos | gold_avaliacoes_servico, gold_avaliacoes_servicos_sentimento | 1 dia util | Engenharia de Dados Santos |
| Carta de servicos | gold_carta_servicos | conforme vigencia SCD2 | Engenharia de Dados Santos |
| Obras/PDR/SEONT | gold_pdr_acompanhamentos_os, gold_obras_tempo_etapa | dependente de estabilizacao de ingestao (ver decisao de credenciais) | Engenharia de Dados Santos |
| Curso de motorista | gold_curso_motoristas | 1 dia util | Engenharia de Dados Santos |

Regra geral: divergencia de contrato acima de tolerancia deve ser tratada como incidente de qualidade, nao como ajuste de medida no relatorio.

## Contratos por eixo tematico (Osasco)

| Eixo | Fonte Gold principal | Atraso maximo aceitavel | Observacao |
| --- | --- | --- | --- |
| Assistencia Social | gold_cad_unico_*, gold_rma_cras_*, gold_rma_creas_indicadores, gold_atendimento_cras | 1 dia util | maior volume de paineis do municipio |
| Desenvolvimento Economico | gold_osasco_pib_*, gold_caged_* | mensal (conforme fonte publica) | RAIS em CSV nao entra em contrato Gold ate migrar para Delta |
| Censo/Demografico | gold_osasco_populacao_ibge | conforme atualizacao IBGE | censo demografico em CSV fora de contrato ate migrar para Delta |
| Seguranca Publica e Viaria | gold_seg_publica_*, gold_seguranca_viaria, gold_monitora_oz | 1 dia util | remover saida Parquet redundante antes de consumo oficial |
| Governo e Cidadania | gold_carta_servicos, gold_carta_servicos_atualizacoes | conforme vigencia SCD2 | segue mesma regra de Santos |
| Saude (CadOZ) | sem tabela Gold central | nao aplicavel | acesso restrito por conter PII; nao publicar externamente |

Regra especifica: paineis com dado pessoal sensivel (ex.: CadOZ H1N1) nao entram em contrato de distribuicao ampla; exigem controle de acesso dedicado.

## Referencias cruzadas

- acervo/bi/catalogo-paineis-santos.md
- acervo/bi/catalogo-paineis-osasco.md
- acervo/decisoes/2026-07-21-scd2-carta-credenciais-consistencia-escrita.md
