# 🏛️ Quick Start — Arquiteto / Tech Lead

**Tempo:** <10 minutos para navegar  
**Objetivo:** Referência rápida, decisões de design

---

## 🏗️ Referência Técnica

**REFERÊNCIA_TÉCNICA_COMPLETA.md:**
- Medalha (Bronze/Silver/Gold)
- SCD Type 2 — como implementar
- Padrões de naming
- Governança

---

## ⚠️ Riscos & Mitigação

**CLAUDE.md** seção "Known Active Issues":
- R1-R9 mapeados
- Impacto + mitigação
- Roadmap de fixes

**DASHBOARD_RISCOS.md:**
- Status de cada risco
- Links para code/issues

---

## 🎯 Arquitetura por Domínio

**02-Técnica/Arquitetura/doc/**
- `ARQUITETURA_E_PADROES.md`
- `GOVERNANCA_E_MANUTENCAO.md`
- `MAPEAMENTO_WORKSPACE_FABRIC.md`

---

## 🔄 Novo Padrão / Função Compartilhada

Precisa criar função que outros vão reusar?

1. Implemente em `nb_utils_shared`
2. Documente interface em `02-Técnica/Arquitetura/Utils/`
3. Atualize todos os notebooks que duplicam
4. PR com padrão claro

---

## 📈 Métricas de Saúde

**PROGRESSO_REORGANIZACAO.md:**
- Quantos commits?
- Qual taxa de sucesso?
- Qual namespace/folder coverage?

---

## 🎨 Decisões de Design

### Precisa de SCD Type 2?
→ `REFERÊNCIA_TÉCNICA_COMPLETA.md` seção "SCD Type 2"

### Precisa adicionar novo município?
→ Copie template em `01-Municípios/[template]/README.md`

### Pipeline master vs sub-pipelines?
→ `CLAUDE.md` seção "Arquitetura Modular"

---

## 📞 Contato

- Tech Lead: [Lead-email]
- Slack: `#fabric-architecture`
- Code review: GitHub PR
