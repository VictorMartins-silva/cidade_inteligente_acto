---
status: "referencia"
description: "Mapeamento completo de notebooks do município de Santos"
---
# Mapeamento Técnico de Notebooks — Município de Santos

**Revisão:** Abril de 2026 — Leitura direta de todos os notebooks (.ipynb)
**Contexto:** Workspace Microsoft Fabric `lh_cidade_inteligente_santos`
**Lakehouse ID:** `0f8d9b0e-86cc-4454-9772-4ab92eb4db2a`
**Workspace ID:** `96fe5a53-3a22-4443-8d0a-e2f6d61a2690`

---

## 1. Inventário Completo de Notebooks

| # | Notebook | Domínio | Camada | Saída (Tabela/Arquivo) | Modo Escrita |
|---|---|---|---|---|---|
| 1 | `nb_ingest_acto_santos` | Geral | Bronze → Gold | `tb_os_acto`, `Files/acto/acto_prazo.csv` | overwrite |
| 2 | `nb_ingest_dim_date` | Infraestrutura | Bronze | `dim_date_1`, `dim_date_2` | overwrite |
| 3 | `nb_ingest_tb_aux_servicos` | Infraestrutura | Bronze | `tb_aux_servicos`, `tb_aux_regionais` | overwrite |
| 4 | `nb_utils_api_acto_gestao` | Utilitário | Utils | — (biblioteca de funções) | — |
| 5 | `nb_utils_api_acto_gestao_obras` | Utilitário Obras | Utils | — (biblioteca de funções) | — |
| 6 | `nb_silver_santos_avaliacao` | Avaliação | Silver | `silver_avaliacoes_servico.parquet` | overwrite |
| 7 | `nb_gold_santos_avaliacao` | Avaliação | Gold | `gold_avaliacoes_servico` | **overwrite** |
| 8 | `nb_gold_santos_avaliacao_sentimento` | Avaliação | Gold | `gold_avaliacoes_servicos_sentimento` | **append** |
| 9 | `nb_ingest_carta_servicos_santos` | Carta de Serviços | Bronze → Gold | `gold_carta_servicos`, `gold_carta_servicos_atualizacoes` | overwrite |
| 10 | `nb_ingest_estrutura_cet` | CET | Bronze | `tb_aux_estrutura_organizacional_cet` | overwrite |
| 11 | `nb_ingest_silver_cet_carga_descarga` | CET | Silver | `silver_cet_carga_descarga_solicitacoes.parquet`, `_etapas.parquet` | overwrite |
| 12 | `nb_gold_acto_gestao_cet_carga_descarga` | CET | Gold | `gold_cet_carga_descarga` | overwrite |
| 13 | `nb_gold_acto_gestao_cet` | CET | Gold | `gold_cet_servicos` | overwrite |
| 14 | `nb_ingest_santos_curso_motoristas` | CET / Curso | Bronze | `silver_solicitacoes.parquet`, `silver_etapas.parquet` | overwrite |
| 15 | `nb_silver_santos_curso_motoristas` | CET / Curso | Silver → Gold | `gold_curso_motorista` | overwrite |
| 16 | `nb_gold_acto_gestao_manifestacoes_ouvidoria` | Ouvidoria | Gold | `gold_manifestacoes_ouvidoria` | overwrite |
| 17 | `nb_gold_acto_gestao_ouvidoria_servicos` | Ouvidoria | Gold | `gold_ouvidoria_servicos` | overwrite |
| 18 | `nb_ingest_silver_acto_gestao_obras_santos` | Obras | Silver | `silver_acto_gesta_obras_santos_*.parquet` | overwrite |
| 19 | `nb_gold_acto_gestao_obras` | Obras | Gold | `gold_pdr_acompanhamentos_os` | overwrite |
| 20 | `nb_gold_acto_gestao_obras_etapas` | Obras | Gold | `gold_obras_tempo_etapa` | overwrite |
| 21 | `nb_gold_acto_gestao_obras_seont_os` | Obras / SEONT | Gold | `gold_obras_seont_os` | overwrite |
| 22 | `nb_gold_acto_gestao_sepref` | SEPREF | Gold | `gold_sepref_servicos` | overwrite |
| 23 | `nb_gold_acto_gestao_segov` | SEGOV | Gold | `gold_segov_servicos` | overwrite |
| 24 | `nb_gold_acto_gestao_seinfra` | SEINFRA | Gold | `gold_seinfra_servicos` | overwrite |

**Total: 24 notebooks**

---

## 2. Detalhamento por Notebook

### 2.1. `nb_ingest_acto_santos`

**Camada:** Bronze → Gold (pipeline completo em um único notebook)
**Fonte:** `Files/acto/exportar.csv` — CSV exportado manualmente da plataforma Acto

**Funções internas:**

| Função | Responsabilidade |
|---|---|
| `processar_os()` | Carrega o CSV, remove duplicatas, unifica colunas de Canal, bfill de bairro |
| `processar_prazo()` | Lê sheet `aux_prazo` do `tb_aux.xlsx` |
| `processar_bairros()` | Lê sheet `aux_regionais` do `tb_aux.xlsx` |
| `aplicar_merge()` | JOIN inner com prazo, LEFT com bairros |
| `tratar_datas()` | Converte datas, calcula prazo, `tempo_execucao_real`, `dias_ate_vencimento`, `status_conclusao_servico` |
| `remover_registros_teste()` | Filtra lista de 12 solicitantes testes conhecidos |
| `tratar_base_final_solicitacoes()` | Atribui `unidade_executora` (COPAISA, SEALURB, região), `responsavel_execucao`, seleciona 49 colunas finais |
| `harmonizar_ordenar_etapas()` | Normaliza nomes de 19 etapas, cria `ordem_etapa` (1–19, 99 para não mapeados) |
| `harmonizar_nome_bairros()` | Corrige 18 variantes de nomes de bairros |
| `ajustar_nome_colunas()` | Converte para snake_case, remove acentos |

**Saídas:**
- `Tables/tb_os_acto` (Delta Table, overwrite + overwriteSchema)
- `Files/acto/acto_prazo.csv`

**Dependências externas (pontos de falha R1):**
- `Files/acto/exportar.csv` — gerado manualmente, sem automação
- `Files/acto/tb_aux.xlsx` (sheets `aux_prazo`, `aux_regionais`)

**Observações:**
- `ajustar_nome_colunas()` e `harmonizar_nome_bairros()` definidas localmente — duplicatas do `nb_utils_api_acto_gestao` (R2). A versão local **não** inclui remoção de vírgula nas colunas nem o `str.title()` inicial nos bairros.
- Sem `assert` de rowcount antes do `saveAsTable` (R4).

---

### 2.2. `nb_ingest_dim_date`

**Camada:** Bronze
**Fonte:** Geração por PySpark via função `sequence`

**Lógica:** Gera sequência diária de `2020-01-01` a `2030-12-31` com colunas em português (`month_name`, `day_name`).

**Saídas:** `dim_date_1` e `dim_date_2` — tabelas idênticas criadas para compatibilidade com dois modelos semânticos distintos.

---

### 2.3. `nb_ingest_tb_aux_servicos`

**Camada:** Bronze
**Fonte:** `Files/acto/tb_aux.xlsx`

**Lógica:** Lê as duas sheets do arquivo auxiliar e persiste como Delta Tables, tornando-as consultáveis via SQL no Lakehouse.

**Saídas:** `tb_aux_servicos` (sheet `aux_prazo`) e `tb_aux_regionais` (sheet `aux_regionais`)

---

### 2.4. `nb_utils_api_acto_gestao`

**Camada:** Utils
**Dependências:** `%run ./config_api_acto` (configura `TOKEN_SANTOS`)

**Funções exportadas (usadas via `%run`):**

| Função                                        | Assinatura                 | Descrição                                                                                                 |
| --------------------------------------------- | -------------------------- | --------------------------------------------------------------------------------------------------------- |
| `fetch_tabela(payload_str)`                   | `str → pd.DataFrame`       | POST para `/api/Tabela/VisualizarDadosIntermediarios`; itera sobre `data[].dados`                         |
| `obter_dados_etapa_atual(TOKEN, codigos)`     | `str, list → pd.DataFrame` | POST para `/api/RelatoriosEtapa/ObterTempoEtapaRelatorio`                                                 |
| `adicionar_etapa_atual(df_etapas, df_sol)`    | —                          | Detecta etapa atual por `dataAtenderEtapa` máxima; join pela coluna `"Nº Solicitação\|1"`                 |
| `adicionar_etapa_atual_2(df_etapas, df_sol)`  | —                          | Idem, mas join pela coluna `"Nº Solicitação"` (sem sufixo `\|1`)                                          |
| `aplicar_bfill(df, coluna)`                   | —                          | Consolida variantes duplicadas de uma coluna (ex.: `Bairro\|50`, `Bairro\|62`) via bfill horizontal       |
| `harmonizar_nome_bairros(df)`                 | —                          | Normaliza 16 variantes de nomes de bairros de Santos                                                      |
| `ajustar_nome_colunas(df)`                    | —                          | Snake_case, remove acentos e símbolos; inclui remoção de vírgulas (correção do Delta)                     |
| `aplicar_merge_prazo_bairros(acto)`           | —                          | Merge com `tb_aux.xlsx` (prazo + bairros); usado por secretarias                                          |
| `aplicar_merge_prazo_bairros_ouvidoria(acto)` | —                          | Idem, renomeia `servico` → `nome_do_servico_avaliado` para ouvidoria                                      |
| `tratar_datas_prazos(acto_prazo)`             | —                          | Calcula `data_vencimento_prazo`, `tempo_execucao_real`, `dias_ate_vencimento`, `status_conclusao_servico` |
| `tratar_base_final_solicitacoes(acto_prazo)`  | —                          | Atribui `unidade_executora` e `responsavel_execucao`                                                      |
| `remover_registros_teste(acto_prazo)`         | —                          | Lista com 13 solicitantes testes (1 a mais que `nb_ingest_acto_santos`)                                   |

**Observação crítica — `adicionar_etapa_atual` vs `_2`:** A diferença está **apenas no nome da coluna de join** (`"Nº Solicitação|1"` vs `"Nº Solicitação"`). Usar a função errada resulta em merge vazio silencioso — todas as colunas de etapa ficam `NaN` sem lançar erro.

---

### 2.5. `nb_utils_api_acto_gestao_obras`

**Camada:** Utils
**Contexto:** Autenticação dinâmica para a API de Obras — endpoint diferente, token separado `TOKEN_SANTOS_OBRAS`, header `App_Id` obrigatório.

**STATUS — R5 CRÍTICO:** Contém `raise_for_status()` sem `try/except`. Desde 11/03/2025 o token expira e o notebook lança `HTTPError: 401`, paralisando toda a pipeline de obras downstream (notebooks 18–21).

---

### 2.6. `nb_silver_santos_avaliacao`

**Camada:** Silver
**Dependências:** `%run ./config_api_acto`, `%run ./nb_utils_ingest_acto_gestao`

**Lógica:** Carrega payload `payload_santos_avaliacao.json` → chama `extrair_tabela_acto_gestao()` → salva resultado bruto em Parquet sem transformação.

**Saída:** `Files/silver/avaliacoes_servico/silver_avaliacoes_servico.parquet`
**Volume:** ~12.996 linhas (último run)

---

### 2.7. `nb_gold_santos_avaliacao`

**Camada:** Gold
**Dependências:** `%run ./nb_silver_santos_avaliacao`

**Lógica:**
1. Lê o Parquet silver
2. Normaliza nomes de serviços via `padronizar_servicos()` — dicionário com 15 mapeamentos de variantes e erros de grafia
3. Cria colunas fixas: `codFluxo='12977'`, `codCatalogo='8225'`, `etapa='NA'`
4. Renomeia colunas para schema compatível com `tb_os_acto`
5. Remove registros sem `nome_do_servico_avaliado`, com `resposta_secretaria` contendo "teste" e sem protocolo
6. Trata `area_responsavel` faltante via dimensão de-para por serviço

**Saída:** `gold_avaliacoes_servico` (Delta Table, **overwrite**)
**Alerta R3:** Se este notebook sobrescrever com sucesso e o próximo falhar, os `seqFluxo` ficam desalinhados com a tabela de sentimento.

---

### 2.8. `nb_gold_santos_avaliacao_sentimento`

**Camada:** Gold
**Dependências:** `gold_avaliacoes_servico`
**Pacotes externos:** `groq`, `tqdm`, `pyodbc`, `sqlalchemy`

**Lógica (incremental):**
1. Carrega `gold_avaliacoes_servico` (origem) e `gold_avaliacoes_servicos_sentimento` (destino existente)
2. Filtra apenas `seqFluxo` novos (não presentes no destino)
3. Para cada novo registro: classifica por **regras** (nota + palavras-chave) e, se incerto, chama **Groq API** (modelo `llama-3.1-8b-instant`)
4. Usa cache local para evitar chamadas duplicadas à API
5. Trata rate-limit HTTP 429: `sleep(65s)`
6. Cria coluna `palavra_foco` (palavra mais frequente no corpus por comentário)
7. Grava somente colunas de sentimento: `seqFluxo` + `analise_*` + `palavra_foco`

**Saída:** `gold_avaliacoes_servicos_sentimento` (Delta Table, **append**)
**Volume atual:** 14.085 total (1.340 classificados via IA/regras, 12.745 sem comentário)
**Suporte a dois modos:** Fabric via `spark.table()` ou local via `pyodbc` + endpoint DW do Fabric.

---

### 2.9. `nb_ingest_carta_servicos_santos`

**Camada:** Bronze → Gold
**Fontes:**
- `Files/raw_cadastro_carta/bd_carta_servicos_santos.csv` — registros **finalizados** (histórico)
- `Files/raw_cadastro_carta/grid_carta_servicos_santos.csv` — registros **em aberto** (Em atendimento / Pendente)

**Lógica:**
1. `carregar_tratar_bd()`: CSV histórico, padroniza colunas via `unidecode`, status = "Finalizado"
2. `carregar_tratar_grid()`: filtra `status in ('Em atendimento', 'Pendente')`, remove colunas de execução
3. `gerar_bd_final()`: concat BD + Grid, cria `data_consolidada`, `dias_desde_atualizacao`, `periodo_atualizacao` (6 faixas: <30d, 30–60d, 60–90d, 90–120d, 120–365d, >365d), extrai `sigla_area_responsavel`
4. `gerar_grid_final()`: versão simplificada do Grid para visão de atualizações

**Saídas:**
- `gold_carta_servicos` (Delta Table, overwrite)
- `gold_carta_servicos_atualizacoes` (Delta Table, overwrite)

---

### 2.10. `nb_ingest_estrutura_cet`

**Camada:** Bronze
**Fonte:** Dict Python hardcoded no notebook (4 linhas de hierarquia: Diretoria → Gerência → Unidade Executora)

**Saída:** `tb_aux_estrutura_organizacional_cet` (Delta Table)
**Status:** Execução manual apenas, sem pipeline.

---

### 2.11. `nb_ingest_silver_cet_carga_descarga`

**Camada:** Silver
**Dependências:** `%run ./nb_utils_ingest_acto_gestao`, `%run ./config_api_acto`

**Lógica:** Extrai dados via `extrair_tabela_acto_gestao(payload_cet_carga_descarga.json, TOKEN_SANTOS)` e persiste parquets brutos sem transformação.

**Saídas:**
- `Files/acto_cet/silver_cet_carga_descarga_solicitacoes.parquet`
- `Files/acto_cet/silver_cet_carga_descarga_etapas.parquet`

---

### 2.12. `nb_gold_acto_gestao_cet_carga_descarga`

**Camada:** Gold
**Dependências:** `%run ./nb_ingest_silver_cet_carga_descarga`, `%run ./nb_utils_api_acto_gestao`

**Lógica:**
1. Lê parquets silver da CET
2. `tratar_nome_colunas()`: remove pipe notation (`|ID`), converte para snake_case
3. `tratar_datas()`: ISO8601 → string, calcula `dia_da_semana_num` e `dia_da_semana_txt`
4. `converter_horarios()`: normaliza horários em minutos numéricos ou `HH:MM` para `HH:MM:SS`
5. `adicionar_periodo_dia()`: classifica em madrugada / manhã / tarde / noite
6. `tratar_bairro_carga()`: normaliza bairros, preenche vazios com "Indisponível"
7. `remover_registros_teste()` via utils

**Saída:** `gold_cet_carga_descarga` (Delta Table, overwrite)
**Volume:** 1.046 registros

---

### 2.13. `nb_gold_acto_gestao_cet`

**Camada:** Gold
**Dependências:** `%run ./nb_utils_api_acto_gestao`
**Catálogos da API:** `[8564, 10824, 10825, 11717, 11765]`

**Padrão:** Idêntico ao template das secretarias — extrai, processa etapas, alinha schema com `tb_os_acto`.

**Saída:** `gold_cet_servicos` (Delta Table, overwrite)

---

### 2.14. `nb_ingest_santos_curso_motoristas`

**Camada:** Bronze (arquivos salvos em `Files/silver/` por convenção de nome)
**Dependências:** `%run ./config_api_acto`, `%run ./nb_utils_ingest_acto_gestao`

**Lógica:** Extrai via `extrair_tabela_acto_gestao(payload_santos_curso_motorista.json, TOKEN_SANTOS)` e salva Parquets brutos sem transformação.

**Saídas:**
- `Files/silver/santos_curso_motorista/silver_solicitacoes.parquet` (106 linhas, 110 colunas)
- `Files/silver/santos_curso_motorista/silver_etapas.parquet` (712 linhas)

---

### 2.15. `nb_silver_santos_curso_motoristas`

**Camada:** Silver → Gold (pipeline completo)
**Dependências:** `%run ./nb_utils_api_acto_gestao`

**Lógica:**
1. Lê o Parquet silver mais recente de `Files/silver/santos_curso_motorista/`
2. `tratar_nome_colunas()`: remove sufixo `|ID`, converte para snake_case sem acentos
3. Consolida colunas duplicadas via bfill horizontal
4. **Unpivot:** transforma colunas de presença por dia (`presenca_d2..d8`) em linhas — 1 linha por aluno por dia de aula
5. Conversão de tipos (datas, numéricos)
6. Valida rowcount com `try/except` + `spark.table().count()` após o write

**Saída:** `gold_curso_motorista` (Delta Table, overwrite)
**Anomalia de nomenclatura:** Tabela e notebook não seguem o padrão `nb_gold_santos_*` — referenciado no CLAUDE.md como violação conhecida.

---

### 2.16. `nb_gold_acto_gestao_manifestacoes_ouvidoria`

**Camada:** Gold
**Dependências:** `%run ./nb_utils_api_acto_gestao`
**Catálogos:** `[8044]` (etapas: 24933 MANIFESTAÇÃO, 24937, 24934 CLASSIFICAÇÃO)

**Lógica:**
1. `obter_dados_etapa_atual(TOKEN, [8044])` + `fetch_tabela(json_inline)`
2. `adicionar_etapa_atual()` — join por `"Nº Solicitação|1"`
3. `tratar_nome_coluna()`: renomeia para schema `tb_os_acto`
4. `harmonizar_nome_bairros()` + `aplicar_merge_prazo_bairros_ouvidoria()`
5. Prazo fixo de **30 dias** hardcoded: `df['prazo_de_conclusao'] = 30`
6. Alinha schema via `reindex(columns=tb_os_acto.columns)`

**Saída:** `gold_manifestacoes_ouvidoria` (Delta Table, overwrite)
**Volume:** 755 registros (de 798 extraídos, 43 removidos por testes/merge sem match)

---

### 2.17. `nb_gold_acto_gestao_ouvidoria_servicos`

**Camada:** Gold (agregação)
**Dependências (5 tabelas):** `gold_sepref_servicos`, `gold_seinfra_servicos`, `gold_cet_servicos`, `gold_segov_servicos`, `gold_manifestacoes_ouvidoria`

**Lógica:** `unionAll` via `functools.reduce` — todas as tabelas devem ter schema idêntico (alinhado com `tb_os_acto`).

**Saída:** `gold_ouvidoria_servicos` (Delta Table, overwrite)
**Risco:** Qualquer divergência de schema em uma das 5 tabelas faz o `unionAll` falhar ou produzir NULLs silenciosos.

---

### 2.18. `nb_ingest_silver_acto_gestao_obras_santos`

**Camada:** Silver
**Dependências:** `%run ./nb_utils_ingest_acto_gestao`, `%run ./config_api_acto`
**Token:** `TOKEN_SANTOS_OBRAS` (distinto do token padrão)

**Saídas:**
- `Files/acto_obras/silver/silver_acto_gesta_obras_santos_solicitacoes.parquet`
- `Files/acto_obras/silver/silver_acto_gesta_obras_santos_etapas.parquet`

**STATUS — BLOQUEADO (R5 CRÍTICO):**
Último run registra `HTTPError: 401 Client Error: Unauthorized` em `/api/RelatoriosEtapa/ObterTempoEtapaRelatorio`. Bloqueado desde 11/03/2025. Paralisa os notebooks 19, 20 e 21 downstream.

---

### 2.19. `nb_gold_acto_gestao_obras`

**Camada:** Gold
**Dependências:** `%run ./nb_ingest_silver_acto_gestao_obras_santos`

**Lógica:**
1. Carrega parquets silver (solicitações + etapas)
2. Bfill horizontal nas colunas duplicadas das solicitações
3. Versão local de `adicionar_etapa_atual_2()` para detectar etapa atual
4. Merge com `Files/acto/PMS_AuxiliarPDR.xlsx` → colunas `aux_setor_responsavel`, `aux_pdr`, `Zona`
5. Cálculo de colunas derivadas de data/etapa

**Saída:** `gold_pdr_acompanhamentos_os` (Delta Table, overwrite)
**Schema:** 18 colunas incluindo `zona`, `bairro_consolidado`, `zona_aplicavel`, `flag_multiplas_etapas`

---

### 2.20. `nb_gold_acto_gestao_obras_etapas`

**Camada:** Gold
**Dependências:** Parquets silver obras + `%run ./nb_utils_api_acto_gestao`
**Catálogos:** 27 catálogos `[4803, 4804, 5605, 5625, 5626, 5627, 5628, 5677, 5679, 5685, 5686, 5693, 5725, 5755, 5964, 6093, 6113, 6326, 6383, 6513, 6738, 6783, 6963, 7523, 8134, 12804, 7243]`

**Lógica:**
1. Carrega parquets silver e chama `obter_dados_etapa_atual()` para os 27 catálogos
2. Mapeia colunas API → formato padrão (`os`, `etapa`, `servico`, datas, `status`, `executor`)
3. Calcula duração: `duracao_dias_preciso` (float) e `duracao_dias_int` (Int64) — feito **antes** de converter datas para string
4. Merge com `PMS_AuxiliarPDR.xlsx` → `aux_setor_responsavel` (94% preenchido) e `aux_pdr` (10% preenchido)

**Saída:** `gold_obras_tempo_etapa` (Delta Table, overwrite, 15 colunas)
**Volume:** 71.500 registros (último run bem-sucedido)

---

### 2.21. `nb_gold_acto_gestao_obras_seont_os`

**Camada:** Gold
**Dependências:** `gold_pdr_acompanhamentos_os`, `silver_acto_gesta_obras_santos_solicitacoes.parquet`
**Status:** Execução manual apenas (sem pipeline registrado)

**Lógica:**
1. Carrega `gold_pdr_acompanhamentos_os` (11.303 registros)
2. Extrai analistas por zona do silver via bfill sobre 11 variantes de `"Esta solicitação deverá ser analisada por:|ID"`
3. Merge gold + analistas por `n_da_solicitacao`
4. `flag_seont = 1` se `aux_setor_responsavel in {SEONT, SEONT-Chefia, SEONT-Chefia (D.O), SEONT CHEFIA}`
5. Zera `analista_responsavel` para etapas não-SEONT
6. `flag_etapa_aprov = 1` para 30+ etapas terminais/de aprovação (normalização sem acento para comparação robusta)
7. `executor_responsavel`: SEONT com executor → `executor_atual`; SEONT sem executor → `analista_responsavel`; não-SEONT → `executor_atual` sem fallback
8. Filtra: mantém apenas `flag_seont = 1`

**Saída:** `gold_obras_seont_os` (Delta Table, overwrite, 22 colunas)
**Volume:** 263 registros SEONT (SEONT-Chefia D.O: 110, SEONT: 78, SEONT-Chefia: 75)

---

### 2.22. `nb_gold_acto_gestao_sepref`

**Camada:** Gold
**Dependências:** `%run ./nb_utils_api_acto_gestao`
**Catálogos:** 49 catálogos divididos em 3 lotes (payload_sepref1/2/3.json)

**Lógica:**
1. Extrai 3 lotes separados (limitação da API com payloads grandes)
2. Concat das 3 extrações
3. Bfill horizontal em 11 colunas: `Nº Solicitação`, `Serviço`, `Data Finalização`, `Status Fluxo`, `Solicitante`, `Data Criação`, `Canal`, `CPF`, `Nome`, `Bairro ocorrência`, `Bairro interessado`
4. `adicionar_etapa_atual_2()` (join por `"Nº Solicitação"`)
5. Pipeline padrão utils (ver Seção 6)
6. Alinha schema com `tb_os_acto` via `reindex`

**Saída:** `gold_sepref_servicos` (Delta Table, overwrite)
**Volume:** ~7.776 registros (1.950 + 4.118 + 1.708)

---

### 2.23. `nb_gold_acto_gestao_segov`

**Camada:** Gold
**Dependências:** `%run ./nb_utils_api_acto_gestao`
**Catálogos:** `[11737, 9019, 9007, 8994]`

Mesmo template das secretarias. **Saída:** `gold_segov_servicos` (Delta Table, overwrite)

---

### 2.24. `nb_gold_acto_gestao_seinfra`

**Camada:** Gold
**Dependências:** `%run ./nb_utils_api_acto_gestao`
**Catálogos:** `[11636, 11635, 11626, 11627, 11634, 11637]`

Mesmo template das secretarias. **Saída:** `gold_seinfra_servicos` (Delta Table, overwrite)

---

## 3. Mapa de Dependências (Lineage)

### 3.1. Avaliação de Serviços

```
config_api_acto ─────────────────────────────┐
nb_utils_ingest_acto_gestao ─────────────────┤
                                             ↓
                             nb_silver_santos_avaliacao
                             (→ silver_avaliacoes_servico.parquet)
                                             ↓
                             nb_gold_santos_avaliacao
                             (→ gold_avaliacoes_servico  [OVERWRITE])
                                             ↓
                             nb_gold_santos_avaliacao_sentimento
                             (→ gold_avaliacoes_servicos_sentimento  [APPEND])
```

### 3.2. Obras Públicas

```
nb_utils_api_acto_gestao_obras ─── nb_ingest_silver_acto_gestao_obras_santos
                                   [BLOQUEADO: HTTP 401 desde 11/03/2025 — R5]
                                             ↓
                             nb_gold_acto_gestao_obras
                             (→ gold_pdr_acompanhamentos_os)
                                      ↙            ↘
     nb_gold_acto_gestao_obras_etapas      nb_gold_acto_gestao_obras_seont_os
     (→ gold_obras_tempo_etapa)            (→ gold_obras_seont_os)
```

### 3.3. Secretarias + Ouvidoria

```
nb_utils_api_acto_gestao ──┬── nb_gold_acto_gestao_sepref  → gold_sepref_servicos
                           ├── nb_gold_acto_gestao_seinfra  → gold_seinfra_servicos
                           ├── nb_gold_acto_gestao_cet      → gold_cet_servicos
                           ├── nb_gold_acto_gestao_segov    → gold_segov_servicos
                           └── nb_gold_acto_gestao_manifestacoes_ouvidoria
                                                             → gold_manifestacoes_ouvidoria
                                                                      ↓
                                              nb_gold_acto_gestao_ouvidoria_servicos
                                              (unionAll das 5 tabelas)
                                              → gold_ouvidoria_servicos
```

### 3.4. CET Carga/Descarga

```
nb_utils_ingest_acto_gestao ──── nb_ingest_silver_cet_carga_descarga
                                 (→ silver_cet_carga_descarga_*.parquet)
                                             ↓
nb_utils_api_acto_gestao ──────── nb_gold_acto_gestao_cet_carga_descarga
                                  (→ gold_cet_carga_descarga)
```

### 3.5. Curso de Motoristas

```
nb_utils_ingest_acto_gestao ──── nb_ingest_santos_curso_motoristas
                                 (→ silver_*.parquet)
                                             ↓
nb_utils_api_acto_gestao ──────── nb_silver_santos_curso_motoristas
                                  (→ gold_curso_motorista)
```

---

## 4. Catálogo de Tabelas Delta no Lakehouse

| Tabela Delta | Criada por | Tipo | Atualização |
|---|---|---|---|
| `tb_os_acto` | `nb_ingest_acto_santos` | Fato principal | Manual (CSV) |
| `dim_date_1` | `nb_ingest_dim_date` | Dimensão | Manual |
| `dim_date_2` | `nb_ingest_dim_date` | Dimensão | Manual |
| `tb_aux_servicos` | `nb_ingest_tb_aux_servicos` | Auxiliar | Manual |
| `tb_aux_regionais` | `nb_ingest_tb_aux_servicos` | Auxiliar | Manual |
| `tb_aux_estrutura_organizacional_cet` | `nb_ingest_estrutura_cet` | Auxiliar estática | Manual |
| `gold_avaliacoes_servico` | `nb_gold_santos_avaliacao` | Fato | Pipeline |
| `gold_avaliacoes_servicos_sentimento` | `nb_gold_santos_avaliacao_sentimento` | Enriquecimento IA | Pipeline (append) |
| `gold_carta_servicos` | `nb_ingest_carta_servicos_santos` | Fato | Pipeline |
| `gold_carta_servicos_atualizacoes` | `nb_ingest_carta_servicos_santos` | Auxiliar | Pipeline |
| `gold_cet_carga_descarga` | `nb_gold_acto_gestao_cet_carga_descarga` | Fato | Pipeline |
| `gold_cet_servicos` | `nb_gold_acto_gestao_cet` | Fato | Pipeline |
| `gold_curso_motorista` | `nb_silver_santos_curso_motoristas` | Fato | Pipeline |
| `gold_manifestacoes_ouvidoria` | `nb_gold_acto_gestao_manifestacoes_ouvidoria` | Fato | Pipeline |
| `gold_ouvidoria_servicos` | `nb_gold_acto_gestao_ouvidoria_servicos` | Fato consolidado | Pipeline |
| `gold_pdr_acompanhamentos_os` | `nb_gold_acto_gestao_obras` | Fato | Pipeline (bloqueado) |
| `gold_obras_tempo_etapa` | `nb_gold_acto_gestao_obras_etapas` | Analítica | Pipeline (bloqueado) |
| `gold_obras_seont_os` | `nb_gold_acto_gestao_obras_seont_os` | Analítica | Manual |
| `gold_sepref_servicos` | `nb_gold_acto_gestao_sepref` | Fato | Pipeline |
| `gold_segov_servicos` | `nb_gold_acto_gestao_segov` | Fato | Pipeline |
| `gold_seinfra_servicos` | `nb_gold_acto_gestao_seinfra` | Fato | Pipeline |

---

## 5. Diagnóstico de Riscos e Problemas Conhecidos

### R5 — CRÍTICO: Pipeline de Obras bloqueada (HTTP 401)

- **Afetados:** notebooks 18 → 19 → 20 → 21
- **Causa:** Token `TOKEN_SANTOS_OBRAS` expirado. O `raise_for_status()` em `nb_utils_ingest_acto_gestao` lança exceção sem tratamento nem retry.
- **Evidência:** Stacktrace registrado no último run: `HTTPError: 401 Client Error: Unauthorized for url: .../api/RelatoriosEtapa/ObterTempoEtapaRelatorio`
- **Impacto:** 4 notebooks paralisados, dashboards de obras desatualizados desde 11/03/2025 (4+ relatórios PBI afetados).
- **Correção:** Adicionar `try/except HTTPError` com chamada a `login_acto_gestao_obras()` e retry em `nb_utils_api_acto_gestao_obras`.

### R3 — Desalinhamento silencioso Gold Avaliação (overwrite + append)

- **Causa:** `nb_gold_santos_avaliacao` usa overwrite enquanto `nb_gold_santos_avaliacao_sentimento` usa append incremental por `seqFluxo`.
- **Cenário de falha:** `avaliacao` roda OK (reescreve `seqFluxo`) → `sentimento` falha → na próxima execução, `sentimento` usa os `seqFluxo` da tabela existente mas a base de avaliação já foi reescrita com outros IDs.

### R2 — Funções duplicadas com divergências

| Função | `nb_ingest_acto_santos` (local) | `nb_utils_api_acto_gestao` (canônico) |
|---|---|---|
| `ajustar_nome_colunas()` | Não remove vírgulas | Remove vírgulas (fix do Delta) |
| `harmonizar_nome_bairros()` | 18 replaces, sem `str.title()` inicial | 16 replaces, com `str.title()` |
| `remover_registros_teste()` | 12 nomes | 13 nomes (adiciona "Guilherme Martins Pereira") |

### R4 — Ausência de validação de rowcount antes de escrita

Notebooks sem `assert len(df) > 0` antes do `saveAsTable`:
- `nb_gold_acto_gestao_sepref`, `nb_gold_acto_gestao_segov`, `nb_gold_acto_gestao_seinfra`, `nb_gold_acto_gestao_cet`
- `nb_gold_acto_gestao_manifestacoes_ouvidoria`
- `nb_gold_acto_gestao_obras`, `nb_gold_acto_gestao_obras_etapas`

**Referência de boa prática:** `nb_silver_santos_curso_motoristas` usa `try/except` com `spark.table(NOME_TABELA_GOLD).count()` após o write para validar.

### R7 — `raise_for_status()` sem tratamento em `nb_utils_ingest_acto_gestao`

Afeta todos os notebooks que usam `%run ./nb_utils_ingest_acto_gestao`: avaliação, carta de serviços, CET, curso de motoristas. Qualquer falha HTTP propaga exceção e para o pipeline sem retry.

### R1 — Arquivos auxiliares como pontos únicos de falha

| Arquivo | Usado em |
|---|---|
| `Files/acto/exportar.csv` | `nb_ingest_acto_santos` (gerado manualmente) |
| `Files/acto/tb_aux.xlsx` | `nb_ingest_acto_santos`, `nb_ingest_tb_aux_servicos`, `nb_utils_api_acto_gestao` |
| `Files/acto/PMS_AuxiliarPDR.xlsx` | `nb_gold_acto_gestao_obras`, `nb_gold_acto_gestao_obras_etapas` |
| `Files/raw_cadastro_carta/bd_carta_servicos_santos.csv` | `nb_ingest_carta_servicos_santos` |
| `Files/raw_cadastro_carta/grid_carta_servicos_santos.csv` | `nb_ingest_carta_servicos_santos` |

### Risco no `adicionar_etapa_atual` vs `_2`

- `adicionar_etapa_atual()` — join por `"Nº Solicitação|1"` (com sufixo pipe): usado por `nb_gold_acto_gestao_manifestacoes_ouvidoria` e `nb_silver_santos_avaliacao`
- `adicionar_etapa_atual_2()` — join por `"Nº Solicitação"` (sem sufixo): usado por `nb_gold_acto_gestao_sepref`, `nb_gold_acto_gestao_obras` e demais secretarias

Usar a função errada resulta em **zero matches silenciosos** — merge retorna `NaN` em todas as colunas de etapa sem lançar erro.

### Anomalia de nomenclatura

- Tabela `gold_curso_motorista` e notebook `nb_silver_santos_curso_motoristas` não seguem o padrão `nb_gold_santos_*`. Conforme CLAUDE.md, deveria ser renomeado para `nb_gold_santos_curso_motorista`.

---

## 6. Padrão de Pipeline das Secretarias (Template)

Os notebooks `nb_gold_acto_gestao_sepref`, `nb_gold_acto_gestao_segov`, `nb_gold_acto_gestao_seinfra` e `nb_gold_acto_gestao_cet` seguem o mesmo template de 10 passos:

```python
%run ./nb_utils_api_acto_gestao

# 1. Extração — obter_dados_etapa_atual(TOKEN, [codigos]) + fetch_tabela(json_inline)
# 2. Junção   — adicionar_etapa_atual_2(df_etapas, df_solicitacoes)
# 3. Renomear — tratar_nome_coluna()
# 4. Bairros  — harmonizar_nome_bairros()
# 5. Enriq.   — aplicar_merge_prazo_bairros()  →  prazo + bairros via tb_aux.xlsx
# 6. Datas    — tratar_datas_prazos()
# 7. Negócio  — tratar_base_final_solicitacoes()  →  unidade_executora, responsavel_execucao
# 8. Filtro   — remover_registros_teste()
# 9. Schema   — reindex(columns=tb_os_acto.columns)  →  alinha para o unionAll
# 10. Escrita — saveAsTable("gold_<secretaria>_servicos", mode="overwrite")
```

O passo 9 (`reindex`) garante que todas as tabelas das secretarias têm o mesmo schema que `tb_os_acto`, permitindo o `unionAll` em `nb_gold_acto_gestao_ouvidoria_servicos`.

---

## 7. Referências

- Código-fonte: notebooks `.ipynb` lidos diretamente de `Acto Cidade Inteligente/Santos/nbs/`
- Contexto arquitetural: `CLAUDE.md` do projeto

---

## Ver Também

- [[_mapa-do-vault]] — índice geral do vault
- [[Conhecimento/Fabric/fabric-workspace-acto-cidade-inteligente|fabric-workspace-acto-cidade-inteligente]] — workspace completo Acto Cidade Inteligente
- [[Conhecimento/Fabric/pipeline-acto-santos-fabric|pipeline-acto-santos-fabric]] — fluxo Data Factory + notebooks
- [[Projetos/acto-santos-pipeline]] — projeto ACTO Santos
