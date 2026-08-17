# 🚨 DASHBOARD DE RISCOS — Fabric/Acto Cidade Inteligente

**Última atualização:** 17/08/2026  
**Revisor:** Copilot CLI  
**Status Geral:** 🔴 **CRÍTICO** (4 riscos críticos abertos, pipeline obras PARADA)  
**Workspace:** `lh_cidade_inteligente_santos` (ID: `96fe5a53-3a22-4443-8d0a-e2f6d61a2690`)

---

## 📊 Visão Geral — Matriz de Riscos

| ID | Risco | Status | Severidade | Impacto | Afetados | Mitigação |
|---|---|---|---|---|---|---|
| **R1** | Arquivos auxiliares (Single Point of Failure) | 🔴 ABERTO | CRÍTICO | 3 pipelines quebram se arquivo move | 3 notebooks | Migrar para Delta Tables |
| **R2** | Funções duplicadas | 🟡 PLANEJADO | MÉDIO | Manutenção 2x mais lenta | 5+ notebooks | Consolidar em nb_utils_shared |
| **R3** | Desalinhamento de IDs em Gold | 🟡 MONITORAR | MÉDIO | Dados corruptos silenciosos | Avaliação + Sentimento | Usar SCD Type 2 + assertions |
| **R4** | DataFrames sem validação pre-save | 🟡 AUDITORIA | MÉDIO | Dados inválidos → Power BI | 5+ notebooks | Assert len(df) > threshold |
| **R5** | **Obras pipeline parado (HTTP 401)** | 🔴 **PARADO** | **CRÍTICO** | **Gestão de obras 100% parada** | **6+ documentos** | **Retry com login refresh** |
| **R6** | *(reservado)* | — | — | — | — | — |
| **R7** | API sem try/except (falhas silenciosas) | 🔴 ABERTO | CRÍTICO | Dados incompletos → BI | 2 chains | Envolver raise_for_status() |
| **R8** | *(reservado)* | — | — | — | — | — |
| **R9** | **CAGED com código errado** | 🔴 **BLOQUEADO** | **CRÍTICO** | **Relatório fraudulento** | **1 notebook** | **Corrigir CODIGO_SANTOS** |

---

## 🔴 RISCOS CRÍTICOS — Ação Imediata Obrigatória

### ⚠️ R5: Obras Pipeline Parado — HTTP 401 (11/03/2025 até HOJE)

**PRIORIDADE:** 🔴 **P0 — URGENTÍSSIMO**

**Status:** PIPELINE COMPLETAMENTE PARADA há 5+ meses

**Notebooks Afetados:**
- 🔗 `nb_ingest_silver_acto_gestao_obras_santos` (HTTP 401 desde 11/03/2025)
- `nb_utils_api_acto_gestao_obras` (precisa retry HTTPError 401)

**Pipelines Data Factory Paradas:**
- `pl_ingest_obras_santos` (9 atividades)
- Gold obras
- Gold etapas
- SEONT OS
- 4× PBI refresh (em paralelo)

**Power BI Reports Afetados:**
- Relatório SEONT (sem dados há 5+ meses)
- Relatório Etapas Consolidadas
- 2 outros reports de gestão de obras

**Raiz do Problema:**
```
Autenticação Acto API expirada → HTTP 401
Token precisa refresh automático
Sem try/except, o erro é silencioso
```

**Impacto Negócio:**
- ❌ Gestão de obras ZERO transparência
- ❌ Decisões sem dados atualizados
- ❌ Stakeholders sem indicadores de SLA
- ❌ Nenhuma nova solicitação rastreada

**Mitigação Imediata (código Python):**

```python
# Arquivo: nb_utils_api_acto_gestao_obras
import requests
from requests.exceptions import HTTPError

def fetch_obras_with_retry(url, session, max_retries=2):
    """Fetch com retry automático em caso de 401"""
    for attempt in range(max_retries):
        try:
            response = session.get(url, timeout=30)
            response.raise_for_status()
            return response
        except HTTPError as e:
            if e.response.status_code == 401 and attempt < max_retries - 1:
                print(f"⚠️ HTTP 401 — Refreshing token and retrying (attempt {attempt + 1})")
                login_acto_gestao_obras()  # Função de refresh de token
                continue
            else:
                raise  # Re-raise se não é 401 ou foi última tentativa

# No notebook:
response = fetch_obras_with_retry(url, session)
data = response.json()
```

**Verificação Pós-Fix:**
1. Execute `nb_ingest_silver_acto_gestao_obras_santos` manualmente
2. Verifique se HTTP 200 (não 401)
3. Valide rowcount > 0 em Delta Table
4. Trigger `pl_ingest_obras_santos` via Data Factory
5. Confirme 4 PBI reports refreshando

**Status:** 🔴 CRÍTICO — PRECISA AÇÃO HOJE  
**Responsável:** Data Engineer (Fabric Admin)  
**Deadline:** IMEDIATO (pipeline parada há 150+ dias)

---

### ⚠️ R9: CAGED — Código de Município Errado

**PRIORIDADE:** 🔴 **P1 — NUNCA ATIVAR SEM FIX**

**Status:** BLOQUEADO (notebook desativado)

**Notebook Afetado:**
- 🔗 `nb_ingest_caged_santos`

**Problema (CRÍTICO):**
```python
# ❌ ERRADO — Osasco, não Santos!
CODIGO_OSASCO = 353440

# Deve ser:
CODIGO_SANTOS = 353845  # ✅ CORRETO
```

**Impacto Negócio:**
- 📊 Relatório CAGED reporta dados de **Osasco como Santos**
- 🔴 FRAUDE DE DADOS — Dados falsificados propositalmente
- 📑 Documentação legal comprometida
- ⚖️ Risco de sanção regulatória

**Mitigação Obrigatória:**

```python
# Arquivo: nb_ingest_caged_santos

# STEP 1: Corrigir constante
CODIGO_SANTOS = 353845  # ✅ Correto

# STEP 2: Adicionar validação
assert CODIGO_SANTOS == 353845, f"❌ Código inválido: {CODIGO_SANTOS}. Esperado 353845 (Santos)"

# STEP 3: Adicionar na documentação do notebook
"""
IMPORTANTE: Este notebook processa CAGED para a Cidade de Santos.
Código IBGE de Santos = 353845
Qualquer outro código resultará em dados fraudulentos.
"""
```

**Verificação Pós-Fix:**
1. Corrigir constante para 353845
2. Adicionar assert antes de qualquer query
3. Testar com dados conhecidos de Santos
4. Confirmar rowcount > 0
5. Validar nomes de bairros (devem ser de Santos)
6. **NÃO ativar em produção sem aprovação do DPO**

**Status:** 🔴 CRÍTICO — BLOQUEADO  
**Responsável:** Data Engineer responsável por CAGED  
**Pré-requisito para Ativação:** Code Review + Validação Dados

---

### ⚠️ R7: API sem try/except — Falhas Silenciosas

**PRIORIDADE:** 🔴 **P1 — CORREÇÃO OBRIGATÓRIA**

**Arquivo Afetado:**
- 🔗 `nb_utils_ingest_acto_gestao` (extraction utilities)

**Problema:**
```python
# ❌ ERRADO — Sem tratamento de erro
response.raise_for_status()  # Falha silenciosa se API retorna erro

# Notebooks dependentes (propagam falha):
# - avaliacao_servicos chain
# - curso_motoristas chain
```

**Impacto:**
- 🔴 Se API falha (timeout, 5xx, 429), notebook continua normalmente
- ❌ Dados incompletos aparecem como completos
- 📊 Power BI recebe dados parciais sem avisar
- 🔍 Difícil debugar (erro não está no log)

**Mitigação Obrigatória:**

```python
# Arquivo: nb_utils_ingest_acto_gestao

import requests
from requests.exceptions import HTTPError, RequestException

def fetch_tabela(tabela_id, session):
    """Fetch com tratamento robusto de erro"""
    url = f"https://api.acto.com.br/tabelas/{tabela_id}"
    
    try:
        response = session.get(url, timeout=30)
        response.raise_for_status()
        return response.json()
    except HTTPError as e:
        # Erro HTTP (4xx, 5xx)
        status_code = e.response.status_code
        print(f"🔴 ERRO HTTP {status_code} ao buscar tabela {tabela_id}")
        print(f"   URL: {url}")
        print(f"   Response: {e.response.text[:500]}")
        raise RuntimeError(f"API error: {status_code}") from e
    except RequestException as e:
        # Timeout, connection error, etc
        print(f"🔴 ERRO DE CONEXÃO ao buscar tabela {tabela_id}: {str(e)}")
        raise RuntimeError(f"Connection error: {str(e)}") from e

# Aplicar mesmo padrão em TODAS as chamadas HTTP
# ✅ Resultado: Erro explícito no notebook, não silencioso
```

**Verificação Pós-Fix:**
1. Identifique todas as chamadas `raise_for_status()` em `nb_utils_ingest_acto_gestao`
2. Envolver cada uma em try/except com log claro
3. Testar com API offline (ou mock com erro 5xx)
4. Confirmar que notebook FALHA explicitamente (não silenciosamente)

**Status:** 🔴 ABERTO  
**Responsável:** Data Engineer responsável por ingestão  
**Impacto Até Arrumar:** Possíveis dados inválidos em avaliação_servicos e curso_motoristas

---

### ⚠️ R1: Arquivos Auxiliares — Single Point of Failure

**PRIORIDADE:** 🔴 **P1 — PLANEJAMENTO IMEDIATO**

**Arquivos Críticos (ABFSS/Local):**

| Arquivo | Sheets/Campos | Usado em | Impacto se Move |
|---|---|---|---|
| `Files/acto/tb_aux.xlsx` | `aux_prazo`, `aux_regionais` | `nb_ingest_acto_santos`, `nb_utils_api_acto_gestao` | 2 pipelines quebram |
| `PMS_AuxiliarPDR.xlsx` | — | `nb_gold_acto_gestao_obras` | Gold obras falha |
| `raw_cadastro_carta/*.csv` | — | `nb_ingest_carta_servicos_santos` | Carta de serviços parada |

**Problema:**
```
❌ Caminhos hardcoded em notebooks
   Se arquivo move ou é deletado → Notebook quebra silenciosamente
   Sem versionamento
   Sem backup automático
```

**Impacto Negócio:**
- 🔴 3 pipelines críticas dependem de um arquivo Excel
- ❌ Sem histórico de mudanças
- 🔍 Difícil auditar quem mudou o quê
- 💾 Sem backup

**Mitigação Recomendada (Roadmap):**

```markdown
## FASE 1: Consolidar Arquivos (Semana 1)
- Localizar TODOS os caminhos hardcoded
- Criar config centralizado: `config_arquivos_auxiliares.py`
- Substituir paths em todos os notebooks

## FASE 2: Migrar para Delta Tables (Semanas 2-4)
- Criar tb_aux_prazo (Delta Table)
- Criar tb_aux_regionais (Delta Table)
- Criar tb_pms_auxiliar_pdr (Delta Table)
- Migrar raw_cadastro_carta → Delta Table (com versionamento)

## FASE 3: Descontinuar Arquivos (Semana 5+)
- Remover referências a .xlsx
- Arquivar arquivos antigos
- Documentar histórico de mudanças

## CÓDIGO EXEMPLO:

# Arquivo: config_arquivos_auxiliares.py
ARQUIVOS_AUXILIARES = {
    'aux_prazo': {
        'fonte': 'Files/acto/tb_aux.xlsx',
        'sheet': 'aux_prazo',
        'backup': True,
        'descricao': 'Prazos SLA por tipo de serviço'
    },
    'aux_regionais': {
        'fonte': 'Files/acto/tb_aux.xlsx',
        'sheet': 'aux_regionais',
        'backup': True,
        'descricao': 'Mapeamento bairros → regionais'
    }
}

# Usar em notebooks:
import config_arquivos_auxiliares as cfg
df = spark.read.excel(cfg.ARQUIVOS_AUXILIARES['aux_prazo']['fonte'], 
                      sheet=cfg.ARQUIVOS_AUXILIARES['aux_prazo']['sheet'])
```

**Status:** 🔴 NÃO INICIADO  
**Impacto Até Arrumar:** 3 pipelines críticas em risco constante  
**Responsável:** Tech Lead (planejamento arquitetura)  
**Timeline Recomendado:** 4-5 semanas

---

## 🟡 RISCOS MÉDIOS — Vigilância e Planejamento

### R2: Funções Duplicadas — Manutenção Difícil

**PRIORIDADE:** 🟡 **P2 — PLANEJAMENTO**

**Funções Duplicadas:**
- `ajustar_nome_colunas()` (5+ notebooks)
- `harmonizar_nome_bairros()` (3+ notebooks)
- `mapa_bairros` (2+ notebooks)

**Problema:**
```
❌ Mesma lógica em 5+ locais
   Se bug é encontrado, precisa corrigir em 5 locais
   Risco de inconsistência entre versões
```

**Mitigação Recomendada:**
```python
# STEP 1: Criar nb_utils_shared
# Arquivo: nb_utils_shared

def ajustar_nome_colunas(df, mapa=None):
    """Padroniza nomes de colunas"""
    # Lógica centralizada
    return df.withColumnRenamed(...)

def harmonizar_nome_bairros(df, col_bairro='bairro'):
    """Normaliza nomes de bairros"""
    # Lógica centralizada
    return df.join(mapa_bairros, ...)

# STEP 2: Substituir em todos os notebooks
# No início de cada notebook:
%run ./nb_utils_shared
# Use as funções normalmente
```

**Status:** 🟡 PLANEJADO  
**Impacto:** Manutenção mais lenta, risco de bugs  
**Timeline:** 2-3 semanas

---

### R3: Desalinhamento de IDs em Gold — Dados Corruptos Silenciosos

**PRIORIDADE:** 🟡 **P2 — MONITORAMENTO**

**Problema:**
```
Notebook A (nb_gold_santos_avaliacao):
  - Usa mode='overwrite' → reescreve tabela inteira
  
Notebook B (nb_gold_santos_avaliacao_sentimento):
  - Usa mode='append' → adiciona novos registros
  
Se A reescreve e B falha → IDs ficam desalinhados
Resultado: Dados corruptos silenciosos
```

**Cenário Crítico:**
```
Time 1: Avaliação reescreve tabela (1000 registros)
Time 2: Sentimento tenta fazer append
         └─ Mas IDs novo não correspondem
Result: Análise de sentimento desalinhada com IDs de avaliação
```

**Mitigação Recomendada:**

```python
# STEP 1: Usar SCD Type 2
# Notebook: nb_gold_santos_avaliacao
df_avaliacao.write \
    .format("delta") \
    .mode("merge") \  # Não overwrite!
    .option("mergeSchema", "true") \
    .saveAsTable("gold_avaliacao_scd2")

# STEP 2: Adicionar assertions rowcount
rowcount_antes = spark.sql("SELECT COUNT(*) as cnt FROM gold_avaliacao_scd2").collect()[0]['cnt']
rowcount_novo = len(df_novo)

assert rowcount_novo > 100, f"⚠️ Dataframe vazio: {rowcount_novo} registros"
assert rowcount_novo >= rowcount_antes * 0.8, \
    f"❌ Perda suspeita de dados: {rowcount_antes} → {rowcount_novo}"

# STEP 3: Log explícito
print(f"✅ Gold Avaliação: {rowcount_antes} → {rowcount_novo} registros")
```

**Verificação Pós-Fix:**
1. Mudar `nb_gold_santos_avaliacao` para SCD Type 2
2. Adicionar assertions em ambos notebooks
3. Testar cenário: reescrever A, depois B
4. Confirmar IDs alinhados

**Status:** 🟡 MONITORAR  
**Impacto:** Possível corrupção de dados silenciosa  
**Timeline:** 1-2 semanas (baixa complexidade)

---

### R4: DataFrames sem Validação Pre-Save

**PRIORIDADE:** 🟡 **P2 — AUDITORIA**

**Problema:**
```
Vários notebooks escrevem Delta Tables sem validar:
  - rowcount > 0 (não escreve vazio)
  - Schema correto (tipos, colunas)
  - Dados nulos inesperados
```

**Padrão Correto (referência):**
```python
# Arquivo: nb_silver_santos_curso_motoristas (✅ bom exemplo)

# ANTES de salvar:
rowcount = len(df_cursos)
assert rowcount > 100, f"❌ Nenhum curso encontrado: {rowcount} registros"

# SALVAR
df_cursos.write.format("delta").mode("overwrite").saveAsTable("silver_cursos")

# DEPOIS de salvar (validação pós-persistência)
final_count = spark.sql("SELECT COUNT(*) FROM silver_cursos").collect()[0][0]
assert final_count == rowcount, f"❌ Rowcount mismatch: {rowcount} escrito, {final_count} lido"
```

**Padrão ERRADO (não fazer):**
```python
# ❌ Sem validação
df.write.format("delta").mode("overwrite").saveAsTable("silver_dados")
# Se df está vazio → tabela vazia silenciosamente
```

**Auditoria Necessária:**
1. Verificar todos os notebooks que fazem `to_parquet()` ou `saveAsTable()`
2. Adicionar assertions conforme padrão acima
3. Testar com dados vazios/inválidos

**Status:** 🟡 AUDITORIA NECESSÁRIA  
**Impacto:** Dados inválidos podem chegar a Power BI  
**Timeline:** 1-2 semanas (audit + fixes)

---

## 📋 Recomendações Técnicas Adicionais

### Conflito de Payload Formats — `adicionar_etapa_atual` vs `_2`

**Contexto:** Duas funções diferentes esperam colunas diferentes:
- `adicionar_etapa_atual()` → coluna `'Nº Solicitação|1'`
- `adicionar_etapa_atual_2()` → coluna `'Nº Solicitação'`

**Recomendação:**
```python
# Adicionar validação ANTES de usar qualquer função:

def adicionar_etapa_com_validacao(df, funcao='_1'):
    """Wrapper que valida input column antes de chamar API"""
    if funcao == '_1':
        required_col = 'Nº Solicitação|1'
    elif funcao == '_2':
        required_col = 'Nº Solicitação'
    else:
        raise ValueError(f"Funcao inválida: {funcao}")
    
    assert required_col in df.columns, \
        f"❌ Coluna esperada '{required_col}' não encontrada. Colunas: {df.columns}"
    
    return adicionar_etapa_atual() if funcao == '_1' else adicionar_etapa_atual_2()
```

---

### SCD Type 2 — Carta de Serviços / SLA (Padrão Crítico)

**NUNCA fazer:**
```sql
-- ❌ ERRADO — Aplica deadline ATUAL a TODAS as histórico
LEFT JOIN gold_dim_cartas_servico d
    ON s.id_servico = d.id_servico
    AND d.is_atual = True
```

**SEMPRE fazer:**
```sql
-- ✅ CORRETO — Aplica deadline vigente NA DATA da solicitação
LEFT JOIN gold_dim_cartas_servico_vigencia d
    ON s.id_servico = d.id_servico
    AND s.dt_abertura >= d.dt_inicio_vigencia
    AND s.dt_abertura < d.dt_fim_vigencia
```

**Fonte Canonical:** `exportar_4.csv` (693 registros, delimiter `;`, UTF-8 BOM)

---

## ✅ Checklist de Ação — Roadmap Executivo

### 🔴 SEMANA 1 — CRÍTICOS

- [ ] **R5:** Implementar retry HTTPError 401 em `nb_utils_api_acto_gestao_obras`
  - [ ] Adicionar try/except HTTPError
  - [ ] Chamar login_acto_gestao_obras() em caso de 401
  - [ ] Testar manualmente: `nb_ingest_silver_acto_gestao_obras_santos`
  - [ ] Verificar HTTP 200 + rowcount > 0
  - [ ] Trigger `pl_ingest_obras_santos` via Data Factory
  - [ ] Confirmar 4 PBI reports refreshando
  - **Responsável:** Data Engineer (Fabric Admin)
  - **Deadline:** HOJE

- [ ] **R9:** Corrigir CAGED e NUNCA ativar sem fix
  - [ ] Substituir `CODIGO_OSASCO = 353440` → `CODIGO_SANTOS = 353845`
  - [ ] Adicionar assert de validação
  - [ ] Testar com dados conhecidos de Santos
  - [ ] Code review + aprovação DPO antes de ativar
  - **Responsável:** Data Engineer responsável por CAGED
  - **Deadline:** 1 semana

### 🔴 SEMANA 2-3 — ALTOS

- [ ] **R7:** Adicionar try/except em `nb_utils_ingest_acto_gestao`
  - [ ] Envolver TODAS as chamadas `raise_for_status()` em try/except
  - [ ] Adicionar log claro de erro
  - [ ] Testar com API offline
  - **Responsável:** Data Engineer responsável por ingestão
  - **Deadline:** 2 semanas

- [ ] **R1:** Iniciar Phase 1 (consolidar arquivos)
  - [ ] Localizar todos os caminhos hardcoded
  - [ ] Criar `config_arquivos_auxiliares.py`
  - [ ] Testar em 1 notebook (POC)
  - **Responsável:** Tech Lead
  - **Deadline:** 3 semanas

### 🟡 SEMANA 4-6 — MÉDIOS

- [ ] **R3:** Implementar SCD Type 2 em avaliação + sentimento
  - [ ] Mudar `nb_gold_santos_avaliacao` para merge (não overwrite)
  - [ ] Adicionar assertions rowcount
  - [ ] Testar desalinhamento
  - **Responsável:** Data Engineer
  - **Deadline:** 2 semanas

- [ ] **R4:** Auditoria de assertions em DataFrames
  - [ ] Listar todos os notebooks que salvam tabelas
  - [ ] Adicionar assert len(df) > threshold em cada um
  - [ ] Testar com dados vazios
  - **Responsável:** Data Engineer
  - **Deadline:** 2 semanas

- [ ] **R2:** Criar `nb_utils_shared` e consolidar funções
  - [ ] Criar notebook centralizado
  - [ ] Mover `ajustar_nome_colunas()`, `harmonizar_nome_bairros()`, etc
  - [ ] Substituir em 5+ notebooks com `%run`
  - [ ] Testar cada um
  - **Responsável:** Tech Lead
  - **Deadline:** 3-4 semanas

---

## 📞 Contatos e Responsabilidades

| Papel | Responsável | Contato | Riscos |
|---|---|---|---|
| **Fabric Admin / Data Engineer Lead** | [procurar em Teams] | — | R5 (obras 401), R7 (API) |
| **Data Engineer (Ingestão)** | [procurar em Teams] | — | R7 (API), R1 (arquivos) |
| **Data Engineer (CAGED)** | [procurar em Teams] | — | R9 (código errado) |
| **Tech Lead (Arquitetura)** | [procurar em Teams] | — | R1 (single point), R2 (funções) |
| **DPO (Governance)** | [procurar em Teams] | — | R9 (aprovação) |

---

## 📈 Histórico de Riscos

| Data | Risco | Evento | Status |
|---|---|---|---|
| 11/03/2025 | R5 | Obras pipeline parou (HTTP 401) | 🔴 PARADO (150+ dias) |
| 2025 | R1 | Documentado em CLAUDE.md | 🔴 NÃO INICIADO |
| 2025 | R7 | Documentado em CLAUDE.md | 🔴 ABERTO |
| 2025 | R9 | Documentado em CLAUDE.md | 🔴 BLOQUEADO |
| 2025 | R2, R3, R4 | Documentado em CLAUDE.md | 🟡 MONITORAR |

---

## 📚 Ver Também

- **CLAUDE.md** — Documentação técnica completa (fonte deste dashboard)
- **00_MAPA.md** — Índice centralizado
- **REFERÊNCIA_TÉCNICA_COMPLETA.md** — Padrões detalhados
- **README.md** (Santos/) — Documentação por município

---

**Classificação:** 🔴 CONFIDENCIAL — Data Engineering Team Only  
**Próxima Revisão:** 24/08/2026  
**Mantido por:** Copilot CLI  
**Última atualização:** 17/08/2026 12:55 UTC-3
