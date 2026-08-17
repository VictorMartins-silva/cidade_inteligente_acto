# 🗂️ MAPA — Notebooks no GitHub

**Repositório:** [VictorMartins-silva/cidade_inteligente_acto](https://github.com/VictorMartins-silva/cidade_inteligente_acto)  
**Branch:** main  
**Atualizado:** 17/08/2026

---

## 📍 SANTOS

### Utilidades Base
- [nb_ingest_acto_santos](https://github.com/VictorMartins-silva/cidade_inteligente_acto/blob/main/notebooks/santos/nb_ingest_acto_santos.ipynb) — Ingestão principal da API Acto
- [nb_utils_api_acto_gestao](https://github.com/VictorMartins-silva/cidade_inteligente_acto/blob/main/notebooks/santos/nb_utils_api_acto_gestao.ipynb) — API client reutilizável (fetch_tabela, adicionar_etapa_atual, harmonizar_nome_bairros, ajustar_nome_colunas)
- [nb_utils_api_acto_gestao_obras](https://github.com/VictorMartins-silva/cidade_inteligente_acto/blob/main/notebooks/santos/nb_utils_api_acto_gestao_obras.ipynb) — API client para obras (login dinâmico) — ⚠️ R5
- [nb_ingest_dim_date](https://github.com/VictorMartins-silva/cidade_inteligente_acto/blob/main/notebooks/santos/nb_ingest_dim_date.ipynb) — Dimensão de datas
- [nb_ingest_tb_aux_servicos](https://github.com/VictorMartins-silva/cidade_inteligente_acto/blob/main/notebooks/santos/nb_ingest_tb_aux_servicos.ipynb) — Carga tb_aux.xlsx (SPOF R1)

### Avaliação de Serviços
- [nb_silver_santos_avaliacao](https://github.com/VictorMartins-silva/cidade_inteligente_acto/blob/main/notebooks/santos/avaliacao_servicos/nb_silver_santos_avaliacao.ipynb) — Silver: Limpeza e tipagem
- [nb_gold_santos_avaliacao](https://github.com/VictorMartins-silva/cidade_inteligente_acto/blob/main/notebooks/santos/avaliacao_servicos/nb_gold_santos_avaliacao.ipynb) — Gold: Dimensões e fatos (usa `overwrite` — R3)
- [nb_gold_santos_avaliacao_sentimento](https://github.com/VictorMartins-silva/cidade_inteligente_acto/blob/main/notebooks/santos/avaliacao_servicos/nb_gold_santos_avaliacao_sentimento.ipynb) — Gold+IA: Análise de sentimento Groq (usa `append` — R3) ⚠️ Risco desalinhamento

### Obras Públicas
- [nb_ingest_silver_acto_gestao_obras_santos](https://github.com/VictorMartins-silva/cidade_inteligente_acto/blob/main/notebooks/santos/obras/nb_ingest_silver_acto_gestao_obras_santos.ipynb) — 🔴 CRÍTICO: Parado desde 11/03/2025 (HTTP 401 — R5)
- [nb_gold_acto_gestao_obras](https://github.com/VictorMartins-silva/cidade_inteligente_acto/blob/main/notebooks/santos/obras/nb_gold_acto_gestao_obras.ipynb) — Gold: Base PDR (usa arquivo PMS_AuxiliarPDR.xlsx — R1)
- [nb_gold_acto_gestao_obras_etapas](https://github.com/VictorMartins-silva/cidade_inteligente_acto/blob/main/notebooks/santos/obras/nb_gold_acto_gestao_obras_etapas.ipynb) — Gold: Etapas e timeline
- [nb_gold_acto_gestao_obras_seont_os](https://github.com/VictorMartins-silva/cidade_inteligente_acto/blob/main/notebooks/santos/obras/SEONT/nb_gold_acto_gestao_obras_seont_os.ipynb) — Gold: Ordens de Serviço SEONT (~202 OS)

### Carta de Serviços
- [nb_ingest_carta_servicos_santos](https://github.com/VictorMartins-silva/cidade_inteligente_acto/blob/main/notebooks/santos/carta_servicos/nb_ingest_carta_servicos_santos.ipynb) — Bronze: CSV com prazos SLA (669 registros, UTF-8 BOM)
- [nb_silver_carta_servicos_santos](https://github.com/VictorMartins-silva/cidade_inteligente_acto/blob/main/notebooks/santos/carta_servicos/nb_silver_carta_servicos_santos.ipynb) — Silver: Limpeza
- [nb_gold_carta_servicos_santos](https://github.com/VictorMartins-silva/cidade_inteligente_acto/blob/main/notebooks/santos/carta_servicos/nb_gold_carta_servicos_santos.ipynb) — Gold: SCD Type 2 com vigência temporal

### Outros Domínios Santos
- **Manifestação Ouvidoria** → `manifestação_ouvidoria/` (TBD)
- **CET** → `cet/` (TBD)
- **Segov** → `segov/` (TBD)
- **Seinfra** → `seinfra/` (TBD)
- **SEPREF** → `sepref/` (TBD)

---

## 🏢 OSASCO

### Assistência Social — CRAS
- [nb_ingest_atendimento_cras](https://github.com/VictorMartins-silva/cidade_inteligente_acto/blob/main/notebooks/osasco/assistencia_social/atendimento_cras/nb_ingest_atendimento_cras.ipynb) — Ingestão atendimentos CRAS

### Assistência Social — Bolsa Família
- [nb_ingest_dump_pbf](https://github.com/VictorMartins-silva/cidade_inteligente_acto/blob/main/notebooks/osasco/assistencia_social/bolsa_familia/nb_ingest_dump_pbf.ipynb) — Ingestão: Dump PBF
- [nb_append_pbf](https://github.com/VictorMartins-silva/cidade_inteligente_acto/blob/main/notebooks/osasco/assistencia_social/bolsa_familia/nb_append_pbf.ipynb) — Ingestão: Append incremental
- [nb_gold_pbf](https://github.com/VictorMartins-silva/cidade_inteligente_acto/blob/main/notebooks/osasco/assistencia_social/bolsa_familia/nb_gold_pbf.ipynb) — Gold

### Assistência Social — CAD Único
- [nb_ingest_bronze_cad_unico](https://github.com/VictorMartins-silva/cidade_inteligente_acto/blob/main/notebooks/osasco/assistencia_social/cad_unico/nb_ingest_bronze_cad_unico.ipynb) — Bronze: Ingestão
- [nb_silver_cad_unico](https://github.com/VictorMartins-silva/cidade_inteligente_acto/blob/main/notebooks/osasco/assistencia_social/cad_unico/nb_silver_cad_unico.ipynb) — Silver: Limpeza
- [nb_gold_cad_unico_pg](https://github.com/VictorMartins-silva/cidade_inteligente_acto/blob/main/notebooks/osasco/assistencia_social/cad_unico/nb_gold_cad_unico_pg.ipynb) — Gold (PG)

### Assistência Social — RMA
- [nb_ingest_acto_rma](https://github.com/VictorMartins-silva/cidade_inteligente_acto/blob/main/notebooks/osasco/assistencia_social/rma/nb_ingest_acto_rma.ipynb) — RMA (Registro de Monitoramento)
- [nb_ingest_acto_rma_creas](https://github.com/VictorMartins-silva/cidade_inteligente_acto/blob/main/notebooks/osasco/assistencia_social/rma/nb_ingest_acto_rma_creas.ipynb) — RMA CREAS

### Bolsa Trabalho
- [nb_ingest_osasco_bolsa_trabalho](https://github.com/VictorMartins-silva/cidade_inteligente_acto/blob/main/notebooks/osasco/bolsa_trabalho/nb_ingest_osasco_bolsa_trabalho.ipynb) — Ingestão
- [nb_gold_bolsa_trabalho](https://github.com/VictorMartins-silva/cidade_inteligente_acto/blob/main/notebooks/osasco/bolsa_trabalho/nb_gold_bolsa_trabalho.ipynb) — Gold

### BPC (Benefício de Prestação Continuada)
- [nb_ingest_osasco_bpc](https://github.com/VictorMartins-silva/cidade_inteligente_acto/blob/main/notebooks/osasco/bpc/nb_ingest_osasco_bpc.ipynb) — Ingestão
- [nb_gold_osasco_bpc](https://github.com/VictorMartins-silva/cidade_inteligente_acto/blob/main/notebooks/osasco/bpc/nb_gold_osasco_bpc.ipynb) — Gold

### CAGED (Cadastro Geral de Empregados)
- [nb_ingest_caged_dump](https://github.com/VictorMartins-silva/cidade_inteligente_acto/blob/main/notebooks/osasco/caged/nb_ingest_caged_dump.ipynb) — Ingestão: Dump
- [nb_append_caged](https://github.com/VictorMartins-silva/cidade_inteligente_acto/blob/main/notebooks/osasco/caged/nb_append_caged.ipynb) — Ingestão: Append incremental
- [nb_gold_sql_caged](https://github.com/VictorMartins-silva/cidade_inteligente_acto/blob/main/notebooks/osasco/caged/nb_gold_sql_caged.ipynb) — Gold (SQL) — 🔴 CRÍTICO: Código OSASCO hardcoded (R9)

### Carta de Serviços
- (TBD) — SCD Type 2 com prazos SLA

### Outros Domínios Osasco
- **Censo** → `censo/` (TBD)
- **RAIS** → `rais/` (TBD)
- **Comex** → `comex/` (TBD)
- **Obras** → `obras/` (TBD)
- **Segurança Viária** → `seguranca_viaria/` (TBD)
- **Segurança Pública** → `seguranca_publica/` (TBD) — Dados criminais SSP (geo/incompatibilidades)

---

## ⚙️ ACTO (Plataforma Core)

### Configuração & Autenticação
- [nb_get_token_api](https://github.com/VictorMartins-silva/cidade_inteligente_acto/blob/main/notebooks/acto/nb_get_token_api.ipynb) — Obtenção de token de autenticação Acto

### Bronze — Ingestão Raw
- [nb_bronze_acto_gestao](https://github.com/VictorMartins-silva/cidade_inteligente_acto/blob/main/notebooks/acto/nbs/nbs_bronze/nb_bronze_acto_gestao.ipynb) — Ingestão principal (payload EAV bruto)
- [nb_bronze_orquestracao](https://github.com/VictorMartins-silva/cidade_inteligente_acto/blob/main/notebooks/acto/nbs/nbs_bronze/nb_bronze_orquestracao.ipynb) — Orquestração de ingestões

### Silver — Tratamento & Tipagem
- [nb_silver_acto_gestao](https://github.com/VictorMartins-silva/cidade_inteligente_acto/blob/main/notebooks/acto/nbs/nbs_silver/nb_silver_acto_gestao.ipynb) — Limpeza, normalização, SCD Type 2

### Gold — Dimensões & Fatos
- [nb_gold_santos_cet](https://github.com/VictorMartins-silva/cidade_inteligente_acto/blob/main/notebooks/acto/nbs/nbs_gold/nb_gold_santos_cet.ipynb) — Gold: CET (Santos)
- [nb_gold_santos_sepref](https://github.com/VictorMartins-silva/cidade_inteligente_acto/blob/main/notebooks/acto/nbs/nbs_gold/nb_gold_santos_sepref.ipynb) — Gold: SEPREF (Santos)
- [nb_gold_osasco_atendimento_cras](https://github.com/VictorMartins-silva/cidade_inteligente_acto/blob/main/notebooks/acto/nbs/nbs_gold/nb_gold_osasco_atendimento_cras.ipynb) — Gold: CRAS (Osasco)
- [nb_gold_osasco_atendimento_trabalhador](https://github.com/VictorMartins-silva/cidade_inteligente_acto/blob/main/notebooks/acto/nbs/nbs_gold/nb_gold_osasco_atendimento_trabalhador.ipynb) — Gold: Bolsa/BPC/CAGED/RAIS (Osasco)
- [_nb_gold_orquestracao](https://github.com/VictorMartins-silva/cidade_inteligente_acto/blob/main/notebooks/acto/nbs/nbs_gold/_nb_gold_orquestracao.ipynb) — Orquestração Gold

### Utilitários Acto
- [nb_utils_request_api](https://github.com/VictorMartins-silva/cidade_inteligente_acto/blob/main/notebooks/acto/utils/nb_utils_request_api.ipynb) — Utils de requisição (GET, POST, autenticação)
- [nb_utils_teste_token](https://github.com/VictorMartins-silva/cidade_inteligente_acto/blob/main/notebooks/acto/utils/nb_utils_teste_token.ipynb) — Teste de conectividade e token

---

## 🔴 RISCOS & STATUS CRÍTICO

### CRÍTICO — Parado em Produção
- **R5 — HTTP 401 Obras (Santos):** `nb_ingest_silver_acto_gestao_obras_santos` retorna 401 desde **11/03/2025**  
  - Impacto: 4 relatórios PBI parados  
  - Status: Aguardando investigação

- **R9 — CAGED (Osasco):** `nb_gold_sql_caged` com código municipal hardcoded  
  - ⚠️ NÃO ATIVAR até corrigir  
  - Status: Requer correção antes de ativação

### Alto Risco
- **R3 — Misalinhamento Avaliação (Santos):** Gold avaliação usa `overwrite`, sentimento usa `append`  
  - Risco: desalinhamento de IDs se Gold reescrever e sentimento falhar
  - Status: Sincronização necessária

- **R7 — Sem try/except em API:** `nb_utils_ingest_acto_gestao` sem tratamento de erros  
  - Impacto: falhas propagam silenciosamente para chains avaliação e curso_motoristas  
  - Status: Requer refatoração

- **R1 — Arquivos auxiliares (SPOF):**  
  - `Files/acto/tb_aux.xlsx` (sheets: `aux_prazo`, `aux_regionais`)  
  - `PMS_AuxiliarPDR.xlsx` (obras)  
  - `raw_cadastro_carta/*.csv` (carta de serviços)  
  - Solução planejada: migrar para Delta Tables no Lakehouse

### Médio Risco
- **R2 — Funções duplicadas:** `ajustar_nome_colunas()`, `harmonizar_nome_bairros()`, `mapa_bairros`  
  - Solução planejada: criar `nb_utils_shared` e centralizar

- **R4 — Sem Rowcount Assertions:** Vários notebooks escrevem sem validar se DataFrame tem dados  
  - Referência correta: `nb_silver_santos_curso_motoristas` usa `assert len(df) > threshold`

---

## 📖 Legendas

| Símbolo | Significado |
|---------|------------|
| 🟢 | Funcional e testado |
| 🟡 | Funcional com ressalvas |
| 🔴 | Crítico / Parado |
| ⚠️ | Risco identificado |
| TBD | A ser documentado |
| R1-R9 | Referência para problema conhecido (ver [CLAUDE.md](../CLAUDE.md)) |

---

## 🔗 Documentação Relacionada

- **[CLAUDE.md](../CLAUDE.md)** — Riscos globais, convenções, SCD Type 2
- **[00_MAPA.md](../00_MAPA.md)** — Navegação geral Documentação Fabric
- **[01-Municípios/Santos/README.md](./Santos/README.md)** — Documentação técnica Santos
- **[01-Municípios/Osasco/README.md](./Osasco/README.md)** — Documentação técnica Osasco
- **[01-Municípios/Acto/README.md](./Acto/README.md)** — Documentação plataforma Acto

---

**Última atualização:** 17/08/2026  
**Gerado automaticamente** — Para atualizações, execute de novo após mudanças na estrutura.
