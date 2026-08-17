---
title: Códigos de Catálogos e Etapas — Santos
tags:
  - municipio/santos
  - tipo/referencia
  - tema/apis
date: 2026-04-14
aliases:
  - codigos acto santos
  - catalogo etapas santos
status: "referencia"
description: "Catálogo de códigos e etapas do pipeline Santos"
---
# Códigos de Catálogos e Etapas — Santos

> [!info] Contexto
> Referência completa de todos os `codCatalogo` e `codigos_etapa` hardcoded nos notebooks do workspace `lh_cidade_inteligente_santos`. Gerado a partir do mapeamento técnico em 2026-04-14.
> 
> Veja o plano de centralização desses códigos em [[plano_extracao_via_excel_santos|Plano — Extração via Excel]].

---

## Como os códigos são usados

Os notebooks chamam a API Acto Gestão com dois endpoints distintos:

- **`ObterTempoEtapaRelatorio`** → recebe `"codCatalogos": [lista]`
- **`VisualizarDadosIntermediarios`** → recebe payload JSON com `"codCatalogo": N` por serviço

Não há `codigo_servico` hardcoded — o identificador de serviço no sistema é sempre o `codCatalogo`.

Veja a arquitetura dos notebooks em [[Documentação_Fabric/doc/Mapeamento Técnico de Notebooks — Município de Santos|Mapeamento Técnico de Notebooks — Santos]] e a documentação geral em [[DOCUMENTACAO_CONSOLIDADA_FABRIC]].

---

## 1. Obras

> [!warning] Pipeline Parado
> Status: **PARADO desde 11/03/2025** — HTTP 401 (R5 CRÍTICO). Ver [[Documentação_Fabric/_obsoleto/Relatório Técnico_ Arquitetura, Mapeamento e Otimização — Microsoft Fabric#Riscos Ativos|Riscos Ativos]].

**Notebook:** `nb_utils_api_acto_gestao_obras` | **Tabela Gold:** `gold_obras_*`

| cod_catalogo | nome_servico                                     | codigos_etapa                                   |
| ------------ | ------------------------------------------------ | ----------------------------------------------- |
| 4803         | Inscrição de Profissional (Pessoa Física)        | 10641, 16412, 10643                             |
| 4804         | Inscrição Empresa/Profissional (Pessoa Jurídica) | 10616, 10622, 16592                             |
| 5605         | Renovação da Licença de Operação                 | 14446, 14439, 14445, 14453                      |
| 5625         | Licença de Instalação                            | 14491, 14490, 14484                             |
| 5626         | Licença de Operação                              | 14467, 14468, 14475, 14461                      |
| 5627         | Licença Prévia                                   | 14430, 14421, 14415, 14422                      |
| 5628         | Manifestação Técnica Ambiental                   | 14538, 14544, 14535, 14528                      |
| 5677         | Comunicação de Serviços Isentos de Licença       | 22456                                           |
| 5679         | Construção Novas de Edificações (Sobreposta/G)   | 14754, 14763, 14764, 14733, 14762, 14761        |
| 5685         | Comunicação de Início de Obras                   | 18345                                           |
| 5686         | Construção Novas de Edificações — Unifamiliar    | 14938, 14934, 14932, 14940, 14931, 14937, 14939 |
| 5693         | Demolição                                        | 17581, 17575, 17583, 17584, 17582, 17579        |
| 5725         | Alvará de Construção Pluri-Habitacional Vertical | 14985, 14996, 14984, 14987, 14993, 14994, 14995 |
| 5755         | Alvará de Construção Condomínio Horizontal       | 15263, 15264, 15265, 15253, 15262, 15252, 15255 |
| 5964         | Renovação de Cadastro Profissional Pessoa Física | 16282, 16283                                    |
| 6093         | Habite-se                                        | 16811, 16815, 16813                             |
| 6113         | Renovação de Cadastro Empresa/Profissional       | 17033, 17034, 17032                             |
| 6326         | Projeto Urbanístico                              | 18360, 18361, 18359, 18356, 18353               |
| 6383         | Acompanhamento de Obras                          | 24356, 18548, 18554                             |
| 6513         | Novas Edificações Comercial/Serviços/Misto       | 18014, 18022, 18023, 18025, 18013, 18024, 18016 |
| 6738         | Cadastro de Empresas de Instalação e Manutenção  | 19761, 19775, 20152, 19764                      |
| 6783         | Renovação de Cadastro de Empresas de Instalação  | 20154, 19873                                    |
| 6963         | Administração Ficha Rosa                         | 20412                                           |
| 7523         | Assunção de Resp. Técnica Equipamentos           | 23033, 23035                                    |
| 8134         | Providência                                      | 25413                                           |
| 12804        | Manutenção de Fachadas em Edificações Históricas | 39156                                           |

**Total:** 26 catálogos · 88 etapas ^obras-total

---

## 2. CET

**Notebook:** `nb_gold_acto_gestao_cet` | **Tabela Gold:** `gold_cet_servicos`

| cod_catalogo | nome_servico | codigos_etapa |
|---|---|---|
| 8564 | Sinalização Horizontal e/ou Vertical | 36680 |
| 10824 | Registro de Condutor de Táxi para Auxiliar | 29681 |
| 10825 | Substituição de Veículo para Exercer a Atividade de Táxi | 33173 |
| 11717 | Declaração para Isenção de IPI e ICMS para Compra de Táxi | 36353 |
| 11765 | Renovação do Registro do Condutor Auxiliar de Táxi | 36579 |
| 11775 | Selo Anual de Autorização da Atividade de Táxi | 36333 |
| 12135 | Transferência de Permissão para Exercer Transporte Escolar | 36533 |
| 12136 | Vistoria do Veículo de Transporte Escolar | 36593 |
| 12137 | Autorização ou Cancelamento para Publicidade em Transporte Escolar | 36539 |
| 12138 | Inscrição de Condutor para Motorista Auxiliar de Autolotação | 37353 |
| 12139 | Renovação de Alvará de Motorista Auxiliar e Permissionário para Autolotação | 37216 |
| 12140 | Inscrição de Condutor para Motorista Auxiliar do Transporte Escolar | 36585 |
| 12141 | Substituição Temporária ou Definitiva de Veículo para Transporte Escolar | 36573 |
| 12142 | Agendamento de Escolta para Carga Superdimensionada | 37274 |
| 12144 | Autorização ou Cancelamento para Publicidade em Táxi | 36313 |
| 12146 | Renovação do Registro de Condutor para Permissionário e Auxiliar de Transporte Escolar | 36506 |
| 12147 | Vistoria do Veículo de Autolotação | 36448 |
| 12148 | Solicitação de Substituição de Veículo para Autolotação | 37224 |
| 12154 | Fiscalização de Veículo Abandonado em Via Pública | 36834, 36833 |
| 12204 | Credencial de Estacionamento para Idoso | 37613, 37615 |
| 12304 | Transferência de Permissão para Exercer Transporte de Autolotação | 36522 |
| 12331 | Vaga Temporária de Carga e Descarga para Obras de Construção Civil | 37396 |
| 12465 | Cadastro de Caminhão para Autorização em Zona de Restrição de Circulação | 38233, 38253 |
| 12480 | Autorização Temporária para Carga e Descarga em Locais com Restrições | 38413, 38433 |
| 13111 | Cartão Transporte para Gratuidade de Idosos | 42953, 42954 |

**Total:** 25 catálogos · 29 etapas ^cet-total

---

## 3. SEGOV

**Notebook:** `nb_gold_acto_gestao_segov` | **Tabela Gold:** `gold_segov_servicos`

| cod_catalogo | nome_servico | codigos_etapa |
|---|---|---|
| 8994 | Remoção de Resíduos de Pequenas Reformas, Móveis ou Materiais Inservíveis | 41385, 41391, 41384 |
| 9007 | Raspagem, Capinação de Vias e Logradouros Públicos | 41355, 41356 |
| 9019 | Instalação, Manutenção ou Higienização de Contentor | 40660, 40657 |
| 11737 | Coleta de Resíduos Sólidos de Carcaças de Animais (Pessoa Física) | 41417, 41416 |

**Total:** 4 catálogos · 9 etapas ^segov-total

---

## 4. SEINFRA

**Notebook:** `nb_gold_acto_gestao_seinfra` | **Tabela Gold:** `gold_seinfra_servicos`

| cod_catalogo | nome_servico | codigos_etapa |
|---|---|---|
| 11626 | Lâmpada ou Luminária Acesa Durante o Dia | 40336, 40333, 40340, 40342 |
| 11627 | Lâmpada ou Luminária Piscando | 40376, 40373, 40381, 40378 |
| 11634 | Lâmpada ou Luminária Apagada | 40356, 40358, 40353, 40361 |
| 11635 | Iluminação Fraca | 40351, 40348, 40343, 40346 |
| 11636 | Choque Elétrico em Poste de Iluminação Pública | 31554, 31532, 31524, 31527 |
| 11637 | Luminária ou Poste Tombados, Danificados ou em Risco de Queda | 40317, 40314, 40323, 40321 |

**Total:** 6 catálogos · 24 etapas ^seinfra-total

---

## 5. SEPREF

**Notebook:** `nb_gold_acto_gestao_sepref` | **Tabela Gold:** `gold_sepref_servicos`

> [!note] Payloads Externos
> Os nomes dos serviços e etapas estão nos arquivos `payload_sepref1.json`, `payload_sepref2.json`, `payload_sepref3.json` no Lakehouse (`Files/acto_gestao_api_payload/`). A centralização desses arquivos está prevista na [[plano_extracao_via_excel_santos#Fase 4 — Migrar SEPREF|Fase 4 do plano de migração]].

| Lista | cod_catalogo (todos ativos) |
|---|---|
| Lista 1 (`payload_sepref1.json`) | 8255, 8256, 8890, 8910, 8930, 8953, 8958, 8964, 8975, 8976, 8979, 8984, 9090, 11035, 11044, 11304, 11364, 11434, 11644, 11674 |
| Lista 2 (`payload_sepref2.json`) | 8895, 8898, 8902, 8904, 8912, 8927, 8951, 8956, 8963, 8967, 8979, 8980, 11086, 11204, 11205, 11214, 11225, 11534, 11584, 11674 |
| Lista 3 (`payload_sepref3.json`) | 8893, 8896, 8897, 8900, 8960, 8986, 10574, 11085, 11284 |

**Total:** 49 catálogos (8979 e 11674 duplicados entre lista 1 e 2) · etapas via API ^sepref-total

---

## 6. Ouvidoria

**Notebook:** `nb_gold_acto_gestao_manifestacoes_ouvidoria` | **Tabela Gold:** `gold_manifestacoes_ouvidoria`

| cod_catalogo | nome_servico | codigos_etapa |
|---|---|---|
| 8044 | Manifestação de Ouvidoria | 24933, 24937, 24934 |

**Total:** 1 catálogo · 3 etapas ^ouvidoria-total

---

## Resumo Geral

| Domínio | Catálogos | Etapas | Status |
|---|---|---|---|
| [[#1. Obras|Obras]] | 26 | 88 | ⚠️ Parado (401) |
| [[#2. CET|CET]] | 25 | 29 | ✅ OK |
| [[#3. SEGOV|SEGOV]] | 4 | 9 | ✅ OK |
| [[#4. SEINFRA|SEINFRA]] | 6 | 24 | ✅ OK |
| [[#5. SEPREF|SEPREF]] | 49 | via API | ✅ OK |
| [[#6. Ouvidoria|Ouvidoria]] | 1 | 3 | ✅ OK |
| **Total** | **111** | **153+** | |

---

## Links Relacionados

- [[plano_extracao_via_excel_santos|Plano — Extração via Excel e Centralização dos Códigos]]
- [[Documentação_Fabric/doc/Mapeamento Técnico de Notebooks — Município de Santos|Mapeamento Técnico de Notebooks — Santos]]
- [[DOCUMENTACAO_CONSOLIDADA_FABRIC]]
- [[Documentação_Fabric/_obsoleto/Relatório Técnico_ Arquitetura, Mapeamento e Otimização — Microsoft Fabric|Relatório Técnico Fabric]]
- [[roadmap_acto_fabric]]
