---
title: Schemas do Lakehouse (Módulo Acto)
date: 2026-06-09
tags:
  - ferramenta/fabric
  - ferramenta/lakehouse
  - tipo/dataset
  - camada/bronze
  - camada/silver
  - camada/gold
projeto: acto-cidade-inteligente
fonte: lh_solicitacoes_acto
status: ativo
---
# Schemas do Lakehouse (Módulo Acto)

> **Lakehouse:** `lh_solicitacoes_acto`
> **Total de Tabelas:** 60 (48 Bronze, 3 Silver, 9 Gold)
> **Atualizado:** 2026-06-09 — adicionadas 4 fontes Mauá Meio Ambiente

> Volumes verificados: [[Documentação_Fabric/Acto/EAV_BRONZE_INVENTARIO|Inventário Bronze EAV — 09/06/2026]]

Este documento cataloga o schema estrutural de todas as tabelas (Bronze, Silver e Gold) presentes no Lakehouse unificado do módulo Acto Gestão.

---

## 1. Camada Bronze (30 Tabelas)
A camada Bronze armazena os dados brutos e normalizados (EAV) extraídos das requisições via API do Acto Gestão, particionados por origem.

### 1.1. Estrutura Padrão: `fato_solicitacoes_*` (12 Colunas)
Armazena o cabeçalho das solicitações (Status, Datas Principais, Solicitante).

*Aplica-se às fontes: `osasco_atendimento_cras`, `osasco_atendimento_trabalhador`, `santos_avaliacao`, `santos_cet`, `santos_curso_motorista`, `santos_obras`, `santos_ouvidoria_manifestacao`, `santos_segov`, `santos_seinfra`, `santos_sepref`.*

| # | Coluna | Tipo | Descrição |
|---|---|---|---|
| 1 | `id_os` | `varchar` | Número da solicitação (PK) |
| 2 | `servico` | `varchar` | Nome do serviço |
| 3 | `status_fluxo` | `varchar` | Status da solicitação |
| 4 | `data_criacao` | `varchar` | Data/hora de abertura |
| 5 | `data_finalizacao` | `varchar` | Data/hora de conclusão |
| 6 | `solicitante` | `varchar` | Solicitante (Nome/ID) |
| 7 | `origem` | `varchar` | Caminho do arquivo JSON original |
| 8 | `data_carga` | `datetime2` | Data de processamento |
| 9 | `fonte` | `varchar` | ID da fonte |
| 10 | `municipio` | `varchar` | Município (Metadado injetado) |
| 11 | `secretaria` | `varchar` | Secretaria (Metadado injetado) |
| 12 | `unidade_organizacional` | `varchar` | Unidade Organizacional (Metadado) |

### 1.2. Estrutura Padrão: `fato_campos_*` (10 Colunas)
Armazena os campos dinâmicos dos formulários no modelo Entity-Attribute-Value (EAV).

*Aplica-se às mesmas 10 fontes acima.*

| # | Coluna | Tipo | Descrição |
|---|---|---|---|
| 1 | `id_os` | `varchar` | FK de `fato_solicitacoes` |
| 2 | `servico` | `varchar` | Nome do serviço |
| 3 | `campo` | `varchar` | Nome da chave dinâmica (Atributo) |
| 4 | `valor` | `varchar` | Valor preenchido (Valor) |
| 5 | `origem` | `varchar` | Arquivo JSON |
| 6 | `data_carga` | `datetime2` | Data da ingestão |
| 7 | `fonte` | `varchar` | ID da fonte |
| 8 | `municipio` | `varchar` | Metadado Injetado |
| 9 | `secretaria` | `varchar` | Metadado Injetado |
| 10 | `unidade_organizacional` | `varchar` | Metadado Injetado |

### 1.3. Estrutura Padrão: `fato_etapas_*` (16 Colunas)
Armazena os dados de SLA (tempos por etapa de cada solicitação).

*Aplica-se às mesmas 10 fontes acima.*

| # | Coluna | Tipo |
|---|---|---|
| 1 | `etapa` | `varchar` |
| 2 | `servico` | `varchar` |
| 3 | `id_os` | `bigint` |
| 4 | `data_criacao` | `varchar` |
| 5 | `data_finalizacao` | `varchar` |
| 6 | `data_inicio_etapa` | `varchar` |
| 7 | `data_fim_etapa` | `varchar` |
| 8 | `data_atender_etapa` | `varchar` |
| 9 | `status` | `varchar` |
| 10 | `executor` | `varchar` |
| 11 | `origem` | `varchar` |
| 12 | `data_carga` | `datetime2` |
| 13 | `fonte` | `varchar` |
| 14 | `municipio` | `varchar` |
| 15 | `secretaria` | `varchar` |
| 16 | `unidade_organizacional` | `varchar` |

---

## 2. Camada Silver (3 Tabelas Consolidadas)
Tabelas unificadas geradas via `UNION BY NAME` das fontes Bronze, convertendo as colunas de data brutas para timestamp.

### 2.1. `silver.fato_solicitacoes` (12 Colunas)
As mesmas 12 colunas da Bronze (`id_os`, `servico`, `status_fluxo`, etc.), porém com `data_criacao` e `data_finalizacao` tipadas corretamente como `datetime2`.

### 2.2. `silver.fato_campos` (10 Colunas)
Modelo unificado EAV cross-secretarias e municípios. Colunas idênticas à Bronze, convertendo `data_carga` em `datetime2`.

### 2.3. `silver.fato_etapas` (16 Colunas)
Modelo unificado de tracking de SLA de etapas. Tipos de colunas `data_criacao`, `data_finalizacao` convertidas para `datetime2`.

---

## 3. Camada Gold (9 Tabelas)
Nesta camada, os atributos chave/valor (EAV) da tabela de campos são pivotados para colunas horizontais baseadas na regra de negócio de cada secretaria. 
Essas tabelas mantêm todas as colunas raízes herdadas da Silver Fato Solicitações (linhas 1 a 12), acrescidas das colunas de negócio abaixo.

### 3.1. `gold.fato_solicitacoes_avaliacao` (28 colunas)
| Colunas Pivotadas Específicas |
|---|
| `CLASS_ATENDIMENTO`, `CLASS_SERVIÇO`, `RDO_EXPECTATIVAS`, `RDO_RESOLUCAO_SERVICO`, `TXA_DESCRICAO_SOLICITACAO`, `TXA_RESPOSTA_SECRETARIA`, `TXA_SUGESTÃO_1`, `TXA_SUGESTÃO_2`, `TXT_CATEGORIA`, `TXT_EMAIL_COPIAR_PARA_ESTE_CAMPO`, `TXT_NOME_PESSOAL`, `TXT_PROTOCOLO`, `TXT_SERVICO`, `TXT_ÁREA_RESPONSÁVEL`, `etapa_atual`, `data_fim_ultima_etapa` |

### 3.2. `gold.fato_solicitacoes_cet` (34 colunas)
| Colunas Pivotadas Específicas                                                                                                                                                                                                                                                                                                                                                                                        |
| -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `bairro`, `canal`, `cnpj`, `cpf`, `data_de_inicio`, `data_de_termino`, `descricao_da_solicitacao`, `encaminhamento_da_analise`, `horario_de_inicio`, `horario_de_termino`, `nome`, `nome_do_logradouro`, `numero`, `observacoes`, `placa_do_veiculo`, `razao_social`, `servico_a_ser_executado`, `tipo_de_solicitacao`, `tipo_logradouro`, `zona_de_restricao_de_circulacao`, `etapa_atual`, `data_fim_ultima_etapa` |

### 3.3. `gold.fato_solicitacoes_curso_motorista` (53 colunas)
| Colunas Pivotadas Específicas (Principais) |
|---|
| `CBO_CONCLUSAO_CURSO`, `CBO_PRESENCA`, `CBO_TIPO_CURSO`, `DT_ATIVIDADE_DATA_INICIO`, `DT_ATIVIDADE_DATA_FIM`, `LBL_AVALIACAO_CURSO`, *...diversas colunas de questionário (RAD_)*, `etapas.etapa`, `etapas.status`, `etapa_atual`, `data_fim_ultima_etapa` |

### 3.4. `gold.fato_solicitacoes_obras` (94 colunas)
| Colunas Pivotadas Específicas (Principais) |
|---|
| `Autor_CNPJ_resp_pj_1`, `CNPJ`, `CPF_PF`, `Logradouro`, `NUMERO_LICENÇA`, `SQL`, `TXT_IMOB_*`, `etapas.etapa`, `etapas.executor`, `etapas.status`, `etapa_atual`, `data_fim_ultima_etapa` |

### 3.5. `gold.fato_solicitacoes_ouvidoria_manifestacao` (19 colunas)
| Colunas Pivotadas Específicas |
|---|
| `CBO_IDENTIFICAÇÃO_DO_INTERESSADO`, `CBO_TIPO_DE_MANIFESTAÇÃO`, `CBO_canal`, `TXT_BAIRRO_LOCAL_DA_OCORRÊNCIA`, `TXT_NOME_DO_SERVIÇO_PESQUISA`, `etapa_atual`, `data_fim_ultima_etapa` |

### 3.6. `gold.fato_solicitacoes_segov` (26 colunas)
| Colunas Pivotadas Específicas |
|---|
| `CBO_CANAL`, `TXA_DESCRICAO_SOLICITACAO`, `TXT_BAIRRO_INTERESSADO`, `TXT_BAIRRO_OCORRENCIA`, `TXT_CPF_INTERESSADO`, `TXT_NOME_INTERESSADO`, `TXT_NOME_LOGRADOURO_INTERESSADO`, `TXT_NOME_LOGRADOURO_OCORRENCIA`, `TXT_NUMERO_INTERESSADO`, `TXT_NUMERO_OCORRENCIA`, `TXT_TIPO_LOGRADOURO_INTERESSADO`, `TXT_TIPO_LOGRADOURO_OCORRENCIA`, `etapa_atual`, `data_fim_ultima_etapa` |

### 3.7. `gold.fato_solicitacoes_seinfra` (32 colunas)
| Colunas Pivotadas Específicas |
|---|
| `CBO_CANAL`, `CBO_CONCLUCAO_EXECUCAO`, `CBO_EXECUCAO`, `DT_AGENDAMENTO`, `DT_EXECUCAO`, `RAD_EXECUTOR`, `TXA_DESCRICAO_SOLICITACAO`, `TXT_BAIRRO_OCORRENCIA`, `TXT_CPF_INTERESSADO`, `TXT_ENDERECOREFERENCIA_BAIRRO`, `TXT_ENDERECOREFERENCIA_LOGRADOURONOME`, `TXT_ENDERECOREFERENCIA_LOGRADOUROTIPO`, `TXT_ENDERECOREFERENCIA_NUMERO`, `TXT_NOME_INTERESSADO`, `TXT_NOME_LOGRADOURO_OCORRENCIA`, `TXT_NUMERO_OCORRENCIA`, `TXT_PLAQUETA`, `TXT_TIPO_LOGRADOURO_OCORRENCIA`, `etapa_atual`, `data_fim_ultima_etapa` |

### 3.8. `gold.fato_solicitacoes_sepref` (23 colunas)
| Colunas Pivotadas Específicas                                                                                                                                                   |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `agendamento`, `bairro_interessado`, `bairro_ocorrencia`, `canal`, `cpf`, `nome`, `nome_logradouro`, `numero_imovel`, `tipo_logradouro`, `etapa_atual`, `data_fim_ultima_etapa` |

### 3.9. `gold.osasco_atendimento_trabalhador` (35 colunas)
| Colunas Pivotadas Específicas |
|---|
| `assunto_cadastro_unico_municipal_cadoz`, `assunto_cadastro_unico_para_programas_sociais_cadunico`, `assunto_servicos_e_programas_trabalho_e_renda`, `classificacao`, `comparecimento`, `demanda_beneficio_prestacao_continuada_bcp_idoso`, `demanda_beneficio_prestacao_continuada_bcp_pcd`, `demanda_carteira_do_autista`, `demanda_carteira_do_idoso`, `demanda_ctps_carteira_de_trabalho`, `demanda_passe_livre_pcd`, `demanda_programa_bolsa_aluguel`, `demanda_programa_bolsa_familia_pbf`, `demanda_programa_gas_do_povo`, `demanda_programa_id_jovem`, `demanda_programa_nosso_futuro_pnf`, `demanda_programa_pe_de_meia`, `demanda_seguro_desemprego`, `demanda_servico_de_protecao_social_crascreascentro_pop`, `demanda_tarifa_social_de_agua`, `nome_da_unidade`, `regiao`, `tempo_atendimento_minutos` |

## Relacionados

- [[Documentação_Fabric/Acto/EAV_BRONZE_INVENTARIO|Inventário Bronze EAV]]
- [[Documentação_Fabric/Acto/EAV_SILVER_INVENTARIO|Inventário Silver EAV]]
- [[Documentação_Fabric/Acto/DOCUMENTACAO_TECNICA_ACTO|Documentação Técnica Acto]]
- [[Documentação_Fabric/Acto/00_INDEX_ACTO|Índice Acto]]
