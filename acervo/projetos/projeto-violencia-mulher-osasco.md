---
status: rascunho
atualizado: "2026-07-22"
dono: coordenador
valido-ate: "2026-08-31"
---

# Projeto - Violencia Contra a Mulher (Osasco)

## Fonte canonica

- violencias_mulher_osasc/spec_drive_violencia_mulher_osasco.md, ROTEIRO_FABRIC.md (fonte pessoal, não versionada)

## Objetivo

Estruturar no Microsoft Fabric a pipeline completa de ingestao, tratamento e entrega dos dados de Boletins de Ocorrencia (Policia Militar + Policia Civil) relacionados a violencia contra a mulher em Osasco, alimentando painel Power BI atualizado, sem duplicacao e com rastreabilidade por fonte.

## Contexto

- Workspace Fabric alvo: `lh_cidade_inteligente_osasco`.
- Fonte: bases mensais `.xlsx` da PM e da PC, upload manual no OneLake. Volume estimado de 500-2.000 BOs/mes por fonte, historico desde jan/2024.
- Fluxo medallion planejado: Bronze (append por arquivo, dedup por `arquivo_origem`) → Silver (tipagem, dedup por linha, `Chave_BO`) → Gold (regras de negocio: `Tipo_Regra`, `Flag_Incluir`, `Motivo_Auditoria`, `Tipo Local` normalizado) → Power BI (Direct Lake).

## Status atual

- Existe protótipo local completo fora do Fabric: pastas `bronze/`, `silver/`, `gold/` com dados processados, arquivos `gold_dim_local.parquet` e `gold_dim_rubricas.parquet` gerados, e um `.pbix` de referencia (`BI_REF_Painel_Violencia_Mulher_PMOsasco_v1.13_2026-05-25`).
- A spec e o roteiro definem os 3 notebooks (`nb_ingest_bronze_violencia_mulher_osasco`, `nb_silver_violencia_mulher_osasco`, `nb_gold_violencia_mulher_osasco`) e o pipeline `pl_violencia_mulher_osasco`, mas **nao ha confirmacao neste levantamento de que esses notebooks ja rodam no workspace Fabric real** — o que existe e o protótipo local + a especificacao.

## Proxima acao

Confirmar com quem toca a frente (Victor/Yuri) se os notebooks Bronze/Silver/Gold ja foram portados para o Fabric ou se o projeto ainda esta na fase de prototipo local antes de tratar isso como entrega em producao.

## Ocorrencias

- 2026-06-01: Spec drive registrada com arquitetura completa (fluxo medallion, schema da tabela Gold principal, inventario de notebooks).

## Decisoes locais

- Regras de classificacao de BO ficam centralizadas num script de referencia (`tratar_base_completa.py`) antes de virarem regra de Gold no Fabric.

## Pendencias externas

- Validar estagio real de execucao no Fabric (prototipo local vs. producao).
- Confirmar cadencia real de upload mensal das bases PM/PC no OneLake.

## Referencias

- violencias_mulher_osasc/spec_drive_violencia_mulher_osasco.md (fonte pessoal, não versionada)
- violencias_mulher_osasc/ROTEIRO_FABRIC.md (fonte pessoal, não versionada)
