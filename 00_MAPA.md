# Documentação Fabric — Mapa Central

**Hub de navegação centralizado.** Comece aqui para encontrar qualquer documentação, spec ou referência técnica.

---

## Municípios

| Município | Pasta | README | Status |
|---|---|---|---|
| **Santos** | `Santos/` | `Santos/README.md` | 🔴 produção |
| **Osasco** | `Osasco/` | `Osasco/README.md` | 🟢 ativo |
| **Acto (Plataforma)** | `Acto/` | `Acto/README.md` | 🟢 ativo |
| **Mauá** | `Mauá/` | `Mauá/README.md` | 🟡 secundário |
| São José do Rio Preto | `SJRP/` | — | ⚪ planejamento |
| Aparecida de Goiânia | `Aparecida de Goiânia/` | — | ⚪ planejamento |

---

## Acto — Plataforma

**Veja:** `Acto/README.md` — documentação técnica e negócio da plataforma Acto

Documentos principais em `Acto/`:
- `DOCUMENTACAO_TECNICA_ACTO.md` — API, schemas, endpoints
- `DOCUMENTACAO_NEGOCIO_ACTO.md` — fluxos de negócio
- `SCHEMA_LAKEHOUSE_ACTO.md` — Schemas bronze/silver/gold
- `MAPEAMENTO_WORKSPACE_FABRIC.md` — workspace Acto

---

## Dados Públicos

**Veja:** `Dados Públicos/README.md` — projeto de dados públicos (IBGE, RAIS, CAGED, Saúde, Educação)

Documentos principais:
- `GUIA_MESTRE_DADOS_PUBLICOS.md` — roadmap geral
- `Mapeamento_Tecnico_Dados_Publicos.md` — fontes e pipelines
- `Saude_Educacao/` — DATASUS, Censo Escolar, IDEB
- Specs em `specs/` (prefixo `spec_drive_dados_publicos`)

---

## Produto DataHub

**Veja:** `Produto_DataHub/` — visão de produto e evolução da plataforma de dados

Documentos:
- `01_visao_produto_modelo_negocio.md` — Product vision
- `02_diagnostico_fabric_atual.md` — Estado atual
- `05_roadmap_fases.md` — Roadmap de implementação

---

## Documentação Técnica Geral

**Veja:** `doc/` — referência técnica consolidada

Documentos essenciais:
- `DOCUMENTACAO_CONSOLIDADA_FABRIC.md` — Arquitetura completa
- `ARQUITETURA_E_PADROES.md` — Padrões Medallion
- `fabric_santos_nbs_analise.md` — Análise de riscos R1–R9
- `roadmap_acto_fabric.md` — Inventário de notebooks
- `mapeamento_paineis_powerbi_santos.md` — 19 painéis Power BI

---

## PowerBI Santos — PDFs

**Veja:** `Powerbi-Santos/` — PDFs exportados dos 19 painéis (atualizado trimestralmente)

---

## Painéis de Negócio

**Veja:** `paineis_negocio/00_indice_paineis.md`

6 painéis principais (F1–F6):
- **F1** — Acompanhamento Serviços (avaliação, SLA)
- **F2** — Manifestações Ouvidoria
- **F3** — Avaliação de Serviços (sentimento)
- **F4** — Carta de Serviços (SLA por domínio)
- **F5** — Obras / PDR / SEONT
- **F6** — Curso de Motorista

---

## Utils Compartilhados

**Veja:** `utils/00_INDEX_UTILS.md` — notebooks utilitários compartilhados

---

## Diagramas

**Veja:** `diagramas/README.md` — Índice de diagramas (canvas, mermaid, images)

---

## Specs e Planos de Implementação

**Veja:** `specs/00_INDEX_SPECS.md` — Todas as especificações e planos

Specs estratégicos:
- `spec_drive_roadmap_migracao.md` — Migração Santos → lh_solicitacoes_acto
- `spec_drive_migracao_obras.md` — Plano Obras (implementação)
- `spec_drive_dados_publicos.md` — Dados Públicos (Fases 1–4)
- `spec_arquitetura_geo_osasco.md` — Arquitetura geoespacial
- Painéis: SEMAM, SEONT, Obras Pavimentos

---

## Tarefas

**Veja:** `Tarefas/` — rastreamento de iniciativas

---

## 📚 Documentação de Contexto

### Guias de Referência

| Documento | Propósito |
|---|---|
| **CLAUDE.md** | Contexto técnico, riscos R1–R9, padrões, quick start |
| **REFERÊNCIA_TÉCNICA_COMPLETA.md** | Referência aprofundada (arquitetura, schemas, padrões) |
| **00_MAPA.md** (este) | Navegação e índice — comece aqui |

### Fluxo de Trabalho Recomendado

1. **Novo na equipe?** → Leia `CLAUDE.md` (10 min)
2. **Procurando um documento?** → Consulte este arquivo (`00_MAPA.md`)
3. **Desenvolvendo/debugando?** → Vá até a pasta do seu município + `README.md` específico
4. **Precisa de referência técnica?** → Consulte `REFERÊNCIA_TÉCNICA_COMPLETA.md`
5. **Entendendo riscos?** → Veja seção "Known Active Issues" em `CLAUDE.md`
