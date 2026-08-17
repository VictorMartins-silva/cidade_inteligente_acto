---
status: validado
atualizado: "2026-07-22"
dono: engenharia-dados-santos
valido-ate: "2026-10-01"
---

# Catalogo de Pipelines - Santos

## Objetivo

Consolidar orquestracao dos pipelines de Santos para operacao, troubleshooting e governanca de refresh.

## Fonte canonica

- _DADOS_LOCAIS_HISTORICO/Santos/pipelines_santos_tecnicos.md (fonte pessoal, não versionada)

## Inventario mapeado

| Pipeline | Dominio | Atividades | Padrao |
| --- | --- | --- | --- |
| pl_ingest_acto_gestao_santos_avaliacoes_servicos | Avaliacao | 3 | Notebook Gold -> RefreshSqlEndpoint -> Refresh modelo PBI |
| pl_ingest_acto_gestao_santos_cet | CET + Curso | 7 | cadeia de notebooks -> RefreshSqlEndpoint -> 2 modelos PBI |
| pl_ingest_acto_gestao_santos_manifestacoes_ouvidoria | Manifestacoes | 7 | notebook unico -> RefreshSqlEndpoint -> 5 modelos PBI |
| pl_ingest_acto_gestao_santos_ouvidoria_servicos | Ouvidoria agregada | 3 | Notebook Gold -> RefreshSqlEndpoint -> Refresh modelo PBI |
| pl_ingest_acto_gestao_santos_segov | SEGOV | 3 | padrao simples |
| pl_ingest_acto_gestao_santos_seinfra | SEINFRA | 3 | padrao simples |
| pl_ingest_acto_gestao_santos_sepref | SEPREF | 3 | padrao simples |
| pl_ingest_carta_servicos_santos | Carta de servicos | n/d | sem print consolidado |
| pl_ingest_obras_santos | Obras | 9 | pipeline mais complexo do workspace |

## Padrao operacional dominante

Notebook (ou cadeia) -> RefreshSqlEndpoint -> Refresh semantic model Power BI

## Dependencias criticas

- conexoes de pipeline associadas ao owner original
- ordem de execucao entre dominios agregadores (ex.: ouvidoria_servicos depende de tabelas upstream)
- health da cadeia de obras para refresh de familia de paineis de obras

## Riscos operacionais

| Risco | Impacto | Acao recomendada |
| --- | --- | --- |
| Conexao inacessivel para outros usuarios | bloqueio de execucao direta | revisar ownership e permissoes de conexao |
| Refresh de modelo sem Gold atualizada | inconsistencia no painel | reforcar gate de sucesso por etapa |
| Dependencia implcita entre pipelines | dado parcial em tabelas agregadas | documentar ordem de disparo por dominio |
| Falha recorrente em obras (R5) | paineis obras defasados | priorizar correcao de autenticacao/retry |

## Checklist semanal de operacao

1. Confirmar status dos pipelines criticos (obras, avaliacao, cet).
2. Validar sucesso de RefreshSqlEndpoint apos notebook.
3. Confirmar refresh dos modelos semanticos alvo.
4. Registrar incidentes e causa raiz.
