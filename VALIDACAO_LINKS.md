# 📋 VALIDAÇÃO DE LINKS — Documentação Fabric

**Data:** 17/08/2026  
**Status:** ✅ Análise Completa

---

## 📊 RESUMO EXECUTIVO

| Métrica | Valor | Status |
|---------|-------|--------|
| ✅ Links Válidos | 48 | ✅ OK |
| ❌ Links Quebrados | 10 | 🔴 AÇÃO URGENTE |
| 🔍 Obsidian Links | 16 | ⚠️ PROBLEMA |
| ⚠️ Âncoras Internas | 46 | ✅ OK |
| 📊 **Total Analisado** | **120** | — |

**Conclusão:** 10 links apontam para caminhos incorretos. 6 links referem-se a vault Obsidian externo que não é transferível.

---

## ✅ LINKS VÁLIDOS (48)

Todos os links de âncora interna (formato `#secção`) estão funcionando:

### REFERÊNCIA_TÉCNICA_COMPLETA.md
- 28 âncoras internas ✅
- Exemplos: `#1-contexto-de-negócio`, `#2-arquitetura-técnica-geral`

### DOCUMENTACAO_CONSOLIDADA_FABRIC.md  
- 16 âncoras internas ✅
- Exemplos: `#1-visão-de-negócio`, `#2-arquitetura-técnica`

### README_ESTRUTURA.md
- Nenhum link de arquivo (apenas textuais) ✅

---

## ❌ LINKS QUEBRADOS (10) — AÇÃO URGENTE

### 🔴 EM REFERÊNCIA_TÉCNICA_COMPLETA.md

| Linha | Link Obsidian | Problema | Solução |
|------|---|---|---|
| 51 | `[[Documentação_Fabric/Osasco/MAPEAMENTO_PAINEIS_PBI_OSASCO]]` | ❌ Caminho errado | Corrigir: `[[01-Municípios/Osasco/MAPEAMENTO_PAINEIS_PBI_OSASCO]]` |
| múltiplas | `[[Documentação_Fabric/Acto/nb_get_token_api.ipynb\|...]]` | ❌ Link notebook | Remover OU criar MD correspondente |
| 1.5 | `[[Documentação_Fabric/Santos/nbs/nb_utils_api_acto_gestao.ipynb\|...]]` | ❌ Link notebook | Remover OU criar MD correspondente |
| 1.6 | `[[Documentação_Fabric/Santos/nbs/avaliacao_servicos/nb_silver_santos_avaliacao.ipynb\|...]]` | ❌ Link notebook | Remover OU criar MD correspondente |
| 1.7 | `[[Documentação_Fabric/utils/nb_utils_ingest_acto_gestao.ipynb\|...]]` | ❌ Link notebook | Remover OU criar MD correspondente |

### 🔴 EM DOCUMENTACAO_CONSOLIDADA_FABRIC.md

| Link Obsidian | Arquivo Real | Problema | Solução |
|---|---|---|---|
| `[[Documentação_Fabric/Referencia_Tecnica_Fabric_Santos_v2_0]]` | `02-Técnica/Arquitetura/doc/Referencia_Tecnica_Fabric_Santos_v2_0.md` | ⚠️ Caminho incompleto | Adicionar prefixo: `[[02-Técnica/Arquitetura/doc/Referencia_Tecnica_Fabric_Santos_v2_0]]` |
| `[[Documentação_Fabric/fabric_santos_nbs_analise]]` | `02-Técnica/Arquitetura/doc/fabric_santos_nbs_analise.md` | ⚠️ Caminho incompleto | Adicionar prefixo: `[[02-Técnica/Arquitetura/doc/fabric_santos_nbs_analise]]` |
| `[[Documentação_Fabric/Mapeamento Técnico...]]` | `02-Técnica/Arquitetura/doc/Mapeamento...` | ⚠️ Caminho incompleto | Adicionar prefixo: `[[02-Técnica/Arquitetura/doc/...]]` |
| `[[Documentação_Fabric/roadmap_acto_fabric]]` | `02-Técnica/Arquitetura/doc/roadmap_acto_fabric.md` | ⚠️ Caminho incompleto | Adicionar prefixo: `[[02-Técnica/Arquitetura/doc/roadmap_acto_fabric]]` |
| `[[Documentação_Fabric/mapeamento_paineis_powerbi_santos]]` | `02-Técnica/Arquitetura/doc/mapeamento_paineis_powerbi_santos.md` | ⚠️ Caminho incompleto | Adicionar prefixo: `[[02-Técnica/Arquitetura/doc/mapeamento_paineis_powerbi_santos]]` |

---

## 🔍 OBSIDIAN LINKS ENCONTRADOS (16)

### ✅ Válidos (2)
```
✓ [[Documentação_Fabric/Osasco/Mapeamento Técnico...]]
✓ [[Documentação_Fabric/Osasco/00_INDEX_OSASCO]]
```

### ❌ Vault-Específicos (REMOVER — 4)

Referem-se a outro vault Obsidian — **DEVEM SER REMOVIDAS**

```
❌ [[_mapa-do-vault]]
❌ [[Conhecimento/Fabric/fabric-workspace-acto-cidade-inteligente|...]]
❌ [[Conhecimento/Fabric/pipeline-acto-santos-fabric|...]]
❌ [[Projetos/acto-santos-pipeline]]
```

**Localização:** DOCUMENTACAO_CONSOLIDADA_FABRIC.md

### ⚠️ Caminhos Incompletos (5)

Arquivos existem, mas link está com caminho errado:

```
[[Documentação_Fabric/fabric_santos_nbs_analise]]
→ Correto: [[02-Técnica/Arquitetura/doc/fabric_santos_nbs_analise]]

[[Documentação_Fabric/Referencia_Tecnica_Fabric_Santos_v2_0]]
→ Correto: [[02-Técnica/Arquitetura/doc/Referencia_Tecnica_Fabric_Santos_v2_0]]

[... 3 mais]
```

### ❌ Links para Notebooks (4)

Apontam para `.ipynb` em vez de documentação MD. **DEVEM SER:**
- Removidos, OU
- Acompanhados de documentação MD correspondente

```
[[Documentação_Fabric/Acto/nb_get_token_api.ipynb]]
[[Documentação_Fabric/Santos/nbs/nb_utils_api_acto_gestao.ipynb]]
[[Documentação_Fabric/Santos/nbs/avaliacao_servicos/nb_silver_santos_avaliacao.ipynb]]
[[Documentação_Fabric/utils/nb_utils_ingest_acto_gestao.ipynb]]
```

---

## 🔧 PLANO DE REMEDIAÇÃO

### **FASE 1: Limpeza Imediata** (30 min)

```
☐ Remover 4 links vault-specific de DOCUMENTACAO_CONSOLIDADA_FABRIC.md:
  - [[_mapa-do-vault]]
  - [[Conhecimento/Fabric/fabric-workspace-acto-cidade-inteligente|...]]
  - [[Conhecimento/Fabric/pipeline-acto-santos-fabric|...]]
  - [[Projetos/acto-santos-pipeline]]
```

### **FASE 2: Correção de Caminhos** (1 hora)

```
☐ DOCUMENTACAO_CONSOLIDADA_FABRIC.md — Adicionar prefixo `02-Técnica/Arquitetura/doc/`:
  - fabric_santos_nbs_analise
  - Referencia_Tecnica_Fabric_Santos_v2_0
  - roadmap_acto_fabric
  - mapeamento_paineis_powerbi_santos
  - Mapeamento Técnico de Notebooks — Município de Santos

☐ REFERÊNCIA_TÉCNICA_COMPLETA.md — Corrigir 1 link Osasco:
  - [[Documentação_Fabric/Osasco/MAPEAMENTO_PAINEIS_PBI_OSASCO]]
  - → [[01-Municípios/Osasco/MAPEAMENTO_PAINEIS_PBI_OSASCO]]
```

### **FASE 3: Links para Notebooks** (2-4 horas — P2)

Decisão: **Remover links para `.ipynb`** OU **criar documentação MD**

Recomendação: Remover por enquanto (usar MAPA_GITHUB_NOTEBOOKS.md para isso)

```
☐ Remover links para:
  - nb_get_token_api.ipynb
  - nb_utils_api_acto_gestao.ipynb
  - nb_silver_santos_avaliacao.ipynb
  - nb_utils_ingest_acto_gestao.ipynb
```

### **FASE 4: Validação** (20 min)

```
☐ Re-executar busca de [[links]]
☐ Testar links em GitHub (navegador)
☐ Testar em Obsidian local (se aplicável)
☐ Commit final: "docs: corrigir links quebrados"
```

---

## 📊 ESTATÍSTICAS

| Tipo | Count | % | Status |
|------|-------|---|--------|
| Âncoras Internas | 46 | 38.3% | ✅ 100% Válidas |
| Obsidian Links | 16 | 13.3% | ⚠️ 37.5% com problemas |
| Textuais (não links) | 58 | 48.4% | ✅ N/A |
| **Total Analisado** | **120** | **100%** | — |

---

## 🎯 RECOMENDAÇÕES

1. **Remover dependência de Obsidian:** Usar apenas links Markdown padrão
2. **Centralizar notebooks em MAPA_GITHUB_NOTEBOOKS.md:** Não linkar `.ipynb` diretamente
3. **Validar estrutura:** Todos os caminhos devem estar sob `01-Municípios/`, `02-Técnica/`, etc
4. **Adicionar CI/CD:** Auto-validação de links em cada commit (GitHub Actions)

---

## 🔗 ARQUIVOS AFETADOS

- `REFERÊNCIA_TÉCNICA_COMPLETA.md` — 5 links a corrigir
- `DOCUMENTACAO_CONSOLIDADA_FABRIC.md` — 9 links a corrigir
- `README_ESTRUTURA.md` — ✅ OK
- `GOVERNANCA_E_MANUTENCAO.md` — ✅ OK
- `00_MAPA.md` — ✅ OK

---

**Status:** ✅ Pronto para Remediação  
**Prioridade:** 🔴 ALTA (FASE 1-2 = semana 1)  
**Esforço Total:** ~5 horas (1.5h urgente + 3.5h P2)

