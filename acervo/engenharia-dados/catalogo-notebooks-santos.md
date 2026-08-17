---
status: validado
atualizado: "2026-07-22"
dono: engenharia-dados-santos
valido-ate: "2026-10-01"
---

# Catalogo de Notebooks - Santos

## Objetivo

Consolidar visao operacional dos notebooks de Santos para manutencao, onboarding e investigacao de incidentes.

## Fonte canonica

- _DADOS_LOCAIS_HISTORICO/Santos/Mapeamento Tecnico de Notebooks - Municipio de Santos.md (fonte pessoal, não versionada)
- _DADOS_LOCAIS_HISTORICO/Santos/doc/fabric_santos_nbs_analise.md (fonte pessoal, não versionada)

## Escopo atual

- Total mapeado: 24 notebooks (recorte tecnico consolidado)
- Camadas: Bronze, Silver, Gold e Utils
- Workspace: lh_cidade_inteligente_santos

## Inventario resumido por dominio

| Dominio | Qtde notebooks | Camadas | Saidas principais |
| --- | --- | --- | --- |
| Infra e Utils | 5 | Bronze/Utils | tb_os_acto, dim_date_1/2, tb_aux_* |
| Avaliacao de servicos | 3 | Silver/Gold | gold_avaliacoes_servico, gold_avaliacoes_servicos_sentimento |
| Obras | 4 | Silver/Gold | gold_pdr_acompanhamentos_os, gold_obras_tempo_etapa, gold_obras_seont_os |
| CET e carga/descarga | 4 | Silver/Gold | gold_cet_servicos, gold_cet_carga_descarga |
| Curso de motoristas | 2 | Bronze/Silver->Gold | gold_curso_motorista |
| Ouvidoria e manifestacoes | 2 | Gold | gold_manifestacoes_ouvidoria, gold_ouvidoria_servicos |
| Secretarias (SEGOV/SEINFRA/SEPREF) | 3 | Gold | gold_segov_servicos, gold_seinfra_servicos, gold_sepref_servicos |
| Carta de servicos | 1 | Bronze->Gold | gold_carta_servicos, gold_carta_servicos_atualizacoes |

## Dependencias criticas

- utils compartilhados: nb_utils_api_acto_gestao, nb_utils_api_acto_gestao_obras, nb_utils_ingest_acto_gestao
- arquivos auxiliares: Files/acto/tb_aux.xlsx, exportar.csv e afins
- payloads/API Acto para dominios por secretaria

## Riscos tecnicos recorrentes

| Risco | Impacto | Observacao |
| --- | --- | --- |
| R5 - 401 em obras | cadeia de obras sem atualizacao | afeta Gold obras e paineis associados |
| R9 - codigo IBGE incorreto no CAGED | risco de dado errado | manter bloqueado ate correcao |
| R4 - escrita sem assert de volume | risco de publicar vazio | padronizar validacao pre-write |
| R2 - funcoes duplicadas | manutencao cara e inconsistente | consolidar em utilitario unico |

## Uso operacional

- para debug: localizar primeiro dominio e camada
- para mudanca: validar utilitarios e dependencias antes de editar
- para publicacao: confirmar tabela Gold alvo e modo de escrita

## Proxima atualizacao semanal

- revisar mudancas de notebooks por dominio
- atualizar contagem e saidas Gold alteradas
- registrar novos riscos ou riscos resolvidos
