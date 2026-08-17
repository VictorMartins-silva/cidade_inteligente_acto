---
status: validado
atualizado: "2026-07-22"
dono: engenharia-dados
valido-ate: "2026-10-01"
---

# Catalogo de Notebooks - Osasco

## Objetivo

Consolidar visao operacional dos notebooks de Osasco para manutencao, onboarding e planejamento de migracao para Gold em Delta.

## Fonte canonica

- _DADOS_LOCAIS_HISTORICO/Osasco/Mapeamento Tecnico de Notebooks - Osasco.md (fonte pessoal, não versionada)

## Escopo atual

- Total mapeado: 31 notebooks
- Camadas: Bronze, Silver, Gold e Raw
- Workspace: lh_cidade_inteligente_osasco

## Distribuicao por camada

| Camada | Quantidade |
| --- | --- |
| Gold | 20 |
| Silver | 6 |
| Bronze | 3 |
| Raw | 2 |

## Inventario resumido por dominio

| Dominio | Qtde notebooks | Camadas predominantes | Saidas principais |
| --- | --- | --- | --- |
| Assistencia Social | 9 | Bronze/Silver/Gold | gold_atendimento_cras, gold_cad_unico_*, gold_rma_cras_*, gold_rma_creas_indicadores |
| Bolsa Trabalho | 2 | Silver/Gold | silver_bolsa_trabalho, gold_bolsa_trabalho |
| BPC | 2 | Silver/Gold | silver_bpc (parquet), gold_osasco_bpc |
| CAGED | 3 | Bronze/Silver/Gold | dump_caged, silver_caged, gold_caged_* |
| Carta de Servicos | 2 | Gold | gold_carta_servicos, gold_carta_servicos_tempo_etapa |
| Censo/Demografico | 4 | Gold | gold_osasco_populacao_ibge, gold_osasco_pib_*, gold_populacao_densidade |
| Comex | 1 | Gold | gold_osasco_comexstat |
| Obras | 1 | Gold | gold_alvaras_obras |
| RAIS | 3 | Raw/Gold | raw_rais_estab_sp, gold_rais |
| Seguranca Viaria | 2 | Silver/Gold | silver_infosiga_*, gold_seguranca_viaria |
| Seguranca Publica | 2 | Gold | gold_monitora_oz, gold_seg_publica_* |

## Pontos criticos de migracao para Gold

| Notebook | Estado atual | Acao recomendada |
| --- | --- | --- |
| nb_gold_osasco_bpc | escrita Gold comentada | habilitar escrita Delta e validar schema |
| nb_ingest_censo | gera 10 CSV em Files/gold_censo_demografico | substituir por tabelas Gold Delta |
| nb_gold_populacao_densidade | gera CSV em Files/gold_populacao_densidade | migrar para Gold Delta |
| nb_gold_rais | gera 2 CSV em Files/gold_rais | migrar para Gold Delta |
| nb_gold_seguranca_viaria | escreve Delta e Parquet em paralelo | remover duplicacao Parquet e manter Delta |

## Dependencias de atencao

- APIs externas: Acto Gestao, Portal da Transparencia, SIDRA, Comexstat
- arquivos de apoio: Files/cadastro_unico/cep_bairros.csv, payloads JSON por dominio
- notebooks utilitarios compartilhados via percent-run e configuracao de tokens

## Uso operacional

- para debug: identificar dominio e camada do notebook antes da alteracao
- para evolucao: priorizar migracao de saidas CSV/Parquet para Delta em Gold
- para publicacao: confirmar tabela alvo, modo de escrita e validacao pre-write

## Proxima atualizacao semanal

- revisar mudancas por dominio e notebooks ativados/desativados
- atualizar lista de notebooks com saida fora de Delta em Gold
- registrar convergencia de modelos para consumo no Power BI
