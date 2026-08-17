# 📊 Diagramas da Documentação Fabric

Índice organizado de diagramas do projeto **Acto Cidade Inteligente — Município de Santos**.

---

## 📁 Estrutura de Pastas

```
diagramas/
├── canvas/        → Diagramas em formato Canvas (Lucidchart, Excalidraw)
├── mermaid/       → Diagramas técnicos em Mermaid (.mmd)
├── images/        → Imagens PNG/JPG finais prontas para documentação
└── README.md      → Este arquivo
```

---

## 📄 Canvas — Diagramas Interativos

| Diagrama | Localização | Última Atualização | Descrição |
|---|---|---|---|
| **Extração Acto Santos** | `canvas/extracao_acto_santos.canvas` | 14/04/2026 | Fluxo de extração de dados da API Acto para Bronze |
| **Fabric Consolidado Completo** | `canvas/fabric_consolidado_completo.canvas` | 15/04/2026 | Visão consolidada de toda a arquitetura Fabric (Bronze → Silver → Gold) |
| **Mapa Documentação Fabric** | `canvas/mapa_documentacao_fabric.canvas` | 15/04/2026 | Índice visual de como a documentação está organizada |
| **Painéis Obras — Fluxo Técnico** | `canvas/paineis_obras_fluxo.canvas` | 16/07/2026 | Fluxo técnico das pipelines de obras (ingestão → processamento → BI) |
| **Painéis Obras — Visão de Negócio** | `canvas/paineis_obras_negocio.canvas` | 16/07/2026 | Mapa de negócio dos painéis de obras (stakeholders, KPIs, entidades) |
| **Visão Geral Projeto** | `canvas/visao_geral_projeto.canvas` | 02/05/2026 | Overview de alto nível do projeto Acto Cidade Inteligente |

### 📝 Referências Textuais

| Arquivo | Localização | Última Atualização | Descrição |
|---|---|---|---|
| **Fluxos Técnicos** | `canvas/fluxos_tecnicos.md` | 16/07/2026 | Documentação em Markdown dos fluxos técnicos |

---

## 📊 Mermaid — Diagramas Técnicos

| Diagrama | Localização | Última Atualização | Descrição |
|---|---|---|---|
| **Arquitetura Fabric Completa** | `mermaid/fabric_architecture_complete.mmd` | 10/04/2026 | ERD + fluxo de dados completo (Bronze → Silver → Gold) |

**Nota:** Este arquivo passou por dedupliação. Versões duplicadas (1 e 2) foram removidas.

---

## 🖼️ Images — Exportações Finais (PNG/JPG)

| Imagem | Localização | Última Atualização | Descrição |
|---|---|---|---|
| **Diagrama Ambiente Fabric** | `images/diagrama_ambiente_fabric.png` | 10/04/2026 | Screenshot da arquitetura de ambiente (dev/prod) |
| **Diagrama Lógica Notebooks** | `images/diagrama_logica_nb.png` | 10/04/2026 | Diagrama visual da lógica e interdependência dos notebooks |

---

## 🔧 Dicas de Uso

1. **Para editar diagramas Canvas:**
   - Abra o arquivo `.canvas` diretamente no Excalidraw ou Lucidchart
   - Após salvar, exporte como PNG em `images/` se necessário

2. **Para editar diagramas Mermaid:**
   - Edite o `.mmd` em seu editor de código
   - Use https://mermaid.live para visualizar em tempo real

3. **Para documentação:**
   - Referencie as imagens PNG de `images/` no seu Markdown/Docusaurus

---

## 📋 Histórico de Reorganização

- **17/08/2026:** Reorganização completa da pasta `diagramas/`
  - ✅ Criadas 3 subpastas temáticas (canvas, mermaid, images)
  - ✅ Removidas 2 duplicatas de `fabric_architecture_complete.mmd`
  - ✅ Criado índice centralizado (este README)

---

## 💡 Padrões de Nomenclatura

- **Canvas:** `<dominio>_<descricao>.canvas`
  - Exemplo: `extracao_acto_santos.canvas`

- **Mermaid:** `<tipo>_<escopo>.mmd`
  - Exemplo: `fabric_architecture_complete.mmd`

- **Imagens:** `diagrama_<tipo>_<escopo>.png`
  - Exemplo: `diagrama_ambiente_fabric.png`

---

## 🚀 Próximas Melhorias

- [ ] Converter `diagrama_ambiente_fabric.png` e `diagrama_logica_nb.png` em Mermaid (reduzir dependência de PNGs estáticas)
- [ ] Adicionar versionamento no Git para `canvas` (rastrear mudanças)
- [ ] Criar diagrama SCD Type 2 para Carta de Serviços (faltante)

---

**Última revisão:** 17/08/2026  
**Responsável:** Documentação Técnica — Acto Cidade Inteligente
