# Guia de Início — Acto Cidade Inteligente

> **Objetivo:** orientar por onde começar a leitura e a validação do módulo Acto sem reexplorar o acervo.
>
> **Uso recomendado:** abrir este guia antes de mexer em notebooks, pipeline, Golds ou migração de Santos.

---

## 1. O que ler primeiro

1. [GUIA_DIARIO_ACTO.md](GUIA_DIARIO_ACTO.md)
2. [DOCUMENTACAO_UNICA_ACTO.md](DOCUMENTACAO_UNICA_ACTO.md)
3. [Acto/CLAUDE.md](../CLAUDE.md)
4. [DOCUMENTACAO_TECNICA_ACTO.md](DOCUMENTACAO_TECNICA_ACTO.md)
5. [DOCUMENTACAO_NEGOCIO_ACTO.md](DOCUMENTACAO_NEGOCIO_ACTO.md)
6. [DIAGRAMAS_ACTO.md](DIAGRAMAS_ACTO.md)

Se o foco for migração de Santos, leia em seguida:

1. [SPEC_DRIVE_ROADMAP_MIGRACAO.md](../specs/SPEC_DRIVE_ROADMAP_MIGRACAO.md)
2. [SPEC_DRIVE_MIGRACAO_OBRAS.md](../specs/SPEC_DRIVE_MIGRACAO_OBRAS.md)
3. [SPEC_DRIVE_PAINEL_APROVACOES_OBRAS.md](../specs/SPEC_DRIVE_PAINEL_APROVACOES_OBRAS.md)

---

## 2. Sequência prática de leitura

### Etapa A — Entender o modelo

- Confirmar que o módulo Acto novo usa `lh_solicitacoes_acto`.
- Entender o fluxo Bronze → Silver → Gold.
- Revisar o mapa dos Golds e as fontes de cada domínio.

### Etapa B — Entender o estado real

- Verificar quais notebooks já gravam Delta.
- Separar o que é legado de Santos do que já pertence ao módulo novo.
- Identificar documentação desatualizada antes de tomar decisão de corte.

### Etapa C — Planejar migração

- Começar por Santos CET e SEPREF.
- Definir a janela temporal de comparação.
- Validar rowcount, colunas críticas e KPI antes de trocar conexões.

---

## 3. Onde cada assunto mora

| Assunto | Documento principal |
|---|---|
| Visão canônica do módulo Acto | [DOCUMENTACAO_UNICA_ACTO.md](DOCUMENTACAO_UNICA_ACTO.md) |
| Arquitetura e notebooks do módulo | [Acto/CLAUDE.md](../CLAUDE.md) |
| Detalhe técnico | [DOCUMENTACAO_TECNICA_ACTO.md](DOCUMENTACAO_TECNICA_ACTO.md) |
| Negócio e domínios | [DOCUMENTACAO_NEGOCIO_ACTO.md](DOCUMENTACAO_NEGOCIO_ACTO.md) |
| Diagramas e fluxos | [DIAGRAMAS_ACTO.md](DIAGRAMAS_ACTO.md) |
| Migração Santos | [SPEC_DRIVE_ROADMAP_MIGRACAO.md](../specs/SPEC_DRIVE_ROADMAP_MIGRACAO.md) |

---

## 4. Ordem mínima para validar antes de mexer

1. Ler o resumo executivo da documentação única.
2. Confirmar o mapa dos Golds e os notebooks que gravam Delta.
3. Revisar a pipeline `pl_ingest_acto`.
4. Comparar a regra de negócio do legado de Santos com o Gold novo.
5. Só depois planejar a troca de conexões do Power BI.

---

## 5. Regra de ouro

Se houver conflito entre documento antigo e notebook atual, o notebook e a pipeline valem mais do que a documentação antiga.
