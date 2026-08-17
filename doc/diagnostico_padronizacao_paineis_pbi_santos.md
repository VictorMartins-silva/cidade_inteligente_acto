---
title: Diagnóstico de Padronização — Painéis Power BI Santos
tags:
  - municipio/santos
  - ferramenta/powerbi
  - tipo/diagnostico
  - padronizacao
  - fontes
aliases:
  - diagnóstico pbi santos
  - padronização painéis
date: 2026-04-14
status: concluído
---

# Diagnóstico de Padronização — Painéis Power BI Santos

**Data da análise:** 2026-04-14  
**Método:** Extração de metadados via PyMuPDF — análise de `font`, `size`, `color` e `bbox` por span em todas as 19 páginas iniciais  
**Referência completa:** [[mapeamento_paineis_powerbi_santos]]  
**Documentação consolidada:** [[DOCUMENTACAO_CONSOLIDADA_FABRIC]]

---

## 1. Linha de Base — Padrão de Referência

Estabelecida a partir das Famílias 1 e 2 (10 dashboards consistentes).

| Elemento         | Padrão                                                                         |
| ---------------- | ------------------------------------------------------------------------------ |
| Fonte primária   | `StandardFont`                                                                 |
| Fonte de ênfase  | `SegoeUI-Bold`                                                                 |
| Fontes de ícones | `SegoeUISymbol`, `FabricMDL2Assets`, `PowerVisuals`                            |
| Título principal | `25pt` — cor branca                                                            |
| KPI (donut/card) | `27pt`                                                                         |
| Rodapé InMov     | `7.5pt`                                                                        |
| Watermark        | "Desenvolvido por InMov - Copyright Prefeitura Municipal de Santos..."         |
| Estrutura        | 4 abas na ordem: Visão Geral · Gestão de Prazos · Finalizadas · Base Detalhada |

---

## 2. Inventário de Fontes por Dashboard

| Dashboard                                                                               | Fontes detectadas                                                                     | Status                                  |
| --------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------- | --------------------------------------- |
| [[Powerbi-Santos/acompanhamento_servicos_segov.pdf|SEGOV]]                             | StandardFont, SegoeUI-Bold, SegoeUISymbol, FabricMDL2Assets, PowerVisuals, Unnamed-T3 | ⚠️ Título 28pt                          |
| [[Powerbi-Santos/acompanhamento_servicos_seinfra.pdf|SEINFRA]]                         | StandardFont, SegoeUI-Bold, SegoeUISymbol, FabricMDL2Assets, PowerVisuals, Unnamed-T3 | ✅ Padrão                                |
| [[Powerbi-Santos/acompanhamento_servicos_cet.pdf|CET]]                                 | StandardFont, SegoeUI-Bold, SegoeUISymbol, FabricMDL2Assets, PowerVisuals, Unnamed-T3 | ✅ Padrão                                |
| [[Powerbi-Santos/acompanhamento_servicos_sepref.pdf|SEPREF]]                           | StandardFont, SegoeUI-Bold, SegoeUISymbol, FabricMDL2Assets, PowerVisuals, Unnamed-T3 | ✅ Padrão                                |
| [[Powerbi-Santos/acompanhamento_servicos_ouvidoria.pdf|Ouvidoria]]                     | StandardFont, SegoeUI-Bold, SegoeUISymbol, FabricMDL2Assets, PowerVisuals, Unnamed-T3 | ⚠️ Título 24pt + sufixo ausente         |
| [[Powerbi-Santos/acompanhamento_servicos_manif_ouvidoria.pdf|Manif. Ouvidoria]]        | StandardFont, SegoeUI-Bold, SegoeUISymbol, FabricMDL2Assets, PowerVisuals, Unnamed-T3 | ✅ Padrão                                |
| [[Powerbi-Santos/acompanhamento_servicos_manif_ouvidoria_cet.pdf|Manif. CET]]          | StandardFont, SegoeUI-Bold, SegoeUISymbol, FabricMDL2Assets, PowerVisuals, Unnamed-T3 | ⚠️ "CE T" no título                     |
| [[Powerbi-Santos/acompanhamento_servicos_manif_ouvidoria_segov.pdf|Manif. SEGOV]]      | StandardFont, SegoeUI-Bold, SegoeUISymbol, FabricMDL2Assets, PowerVisuals, Unnamed-T3 | ✅ Padrão                                |
| [[Powerbi-Santos/acompanhamento_servicos_manif_ouvidoria_seinfra.pdf|Manif. SEINFRA]]  | StandardFont, SegoeUI-Bold, SegoeUISymbol, FabricMDL2Assets, PowerVisuals, Unnamed-T3 | ✅ Padrão                                |
| [[Powerbi-Santos/acompanhamento_servicos_manif_ouvidoria_sepref.pdf|Manif. SEPREF]]    | StandardFont, SegoeUI-Bold, SegoeUISymbol, FabricMDL2Assets, PowerVisuals, Unnamed-T3 | ✅ Padrão                                |
| [[Powerbi-Santos/acompanhamento_avaliacao_servicos.pdf|Avaliações]]                    | StandardFont, SegoeUI-Bold, **ArialMT**, SegoeUISymbol, FabricMDL2Assets              | 🔴 ArialMT + sem InMov                  |
| [[Powerbi-Santos/acompanhamento_carta_servicos.pdf|Carta de Serviços]]                 | StandardFont, SegoeUI-Bold, SegoeUISymbol, FabricMDL2Assets, PowerVisuals             | ✅ Fontes ok; conteúdo diferente         |
| [[Powerbi-Santos/acompanhamento_servicos_curso_motorista.pdf|Curso Motorista]]         | StandardFont, SegoeUI-Bold, **SegoeFluentIcons**, SegoeUISymbol, FabricMDL2Assets     | ⚠️ SegoeFluentIcons extra; footer 5.2pt |
| [[Powerbi-Santos/acompanhamento_servicos_curso_motorista_cet.pdf|Curso Motorista CET]] | StandardFont, SegoeUI-Bold, **SegoeFluentIcons**, SegoeUISymbol, FabricMDL2Assets     | ⚠️ Idem versão CET                      |
| [[Powerbi-Santos/obras/pbi_obras_santos_acomp_solicitacoes.pdf|Obras Acomp.]]          | StandardFont, **SegoeUI-Semibold**, SegoeUISymbol, FabricMDL2Assets                   | ⚠️ Semibold; sem InMov                  |
| [[Powerbi-Santos/obras/pbi_obras_santos_seman_acomp_solicitacoes.pdf|SEMAN]]           | StandardFont, **SegoeUI-Semibold**, SegoeUISymbol, FabricMDL2Assets                   | ⚠️ Semibold; "SEMAM/SEMAN"              |
| [[Powerbi-Santos/obras/pbi_obras_santos_pdr.pdf|PDR I]]                                | StandardFont, **SegoeUI-Semibold**, SegoeUISymbol, FabricMDL2Assets                   | ⚠️ Semibold; sem InMov                  |
| [[Powerbi-Santos/obras/pbi_santos_obras_seont_os.pdf|SEONT]]                           | StandardFont, **SegoeUI-Semibold**, SegoeUISymbol, FabricMDL2Assets                   | ⚠️ Semibold; sem InMov                  |


---

## 3. Desvios Críticos

> [!danger] C1 — Avaliações de Serviços (template incorreto)
> - Título **28pt** (padrão: 25pt)
> - KPI **43pt** (padrão: 27pt)
> - Fonte **ArialMT** em labels de gráfico — não pertence ao stack padrão
> - **Sem watermark InMov**
> - Abas completamente diferentes: Avaliação Serviço · Avaliação Atendimento
> - **Ação:** Reconstruir usando template padrão das Famílias 1/2

> [!danger] C2 — Alvará Obras (protótipo publicado indevidamente)
> - Aba **"Rascunho"** visível em ambiente de produção/documentação
> - Escala tipográfica inflada: **80pt / 60pt / 40pt**
> - **StandardFontLight** — fonte exclusiva não vista nos outros 18 PDFs
> - **Sem watermark InMov**
> - **Ação:** Remover das publicações de produção imediatamente

---

## 4. Desvios Moderados

> [!warning] M1 — SEGOV: título 28pt em vez de 25pt
> Único dashboard da Família 1 com título maior que o padrão. Causa visual: texto ligeiramente maior que os outros painéis da mesma família.

> [!warning] M2 — Ouvidoria: título 24pt + sufixo ausente
> Renderiza como "ACOMPANHAMENTO DE SOLICITAÇÕES" sem "- OUVIDORIA". Título menor que o padrão (24pt vs 25pt). Dificulta identificação do domínio no cabeçalho.

> [!warning] M3 — Obras (4 dashboards): SegoeUI-Semibold em vez de SegoeUI-Bold
> Todos os 4 dashboards operacionais de obras usam `SegoeUI-Semibold` para ênfase. O peso visual é perceptivelmente diferente de `SegoeUI-Bold`. Nenhum dos 4 possui watermark InMov.

> [!warning] M4 — Curso de Motorista (2 dashboards): footer 5.2pt e SegoeFluentIcons
> Rodapé InMov renderizado em **5.2pt** (padrão: 7.5pt) — praticamente ilegível. Fonte `SegoeFluentIcons` extra não presente nos outros dashboards.

---

## 5. Desvios de Nomenclatura

> [!bug] Inconsistências de título detectadas

| Arquivo                                                                        | Título atual                        | Título esperado                          |     |
| ------------------------------------------------------------------------------ | ----------------------------------- | ---------------------------------------- | --- |
| [[Powerbi-Santos/acompanhamento_servicos_segov.pdf|SEGOV]]                    | "SERVIÇOS -SEGOV"                   | "SERVIÇOS - SEGOV"                       |     |
| [[Powerbi-Santos/acompanhamento_servicos_ouvidoria.pdf|Ouvidoria]]            | "ACOMPANHAMENTO DE SOLICITAÇÕES"    | "ACOMPANHAMENTO DE SERVIÇOS - OUVIDORIA" |     |
| [[Powerbi-Santos/acompanhamento_servicos_manif_ouvidoria_cet.pdf|Manif. CET]] | "MANIFESTAÇÕES DE OUVIDORIA - CE T" | "MANIFESTAÇÕES DE OUVIDORIA - CET"       |     |
| [[Powerbi-Santos/obras/pbi_obras_santos_seman_acomp_solicitacoes.pdf|SEMAN]]  | "ACOMP. - SEMAN/SEMAM"              | "ACOMP. - SEMAN"                         |     |

---

## 6. Watermark InMov — Presença por Família

> [!note] 31,6% dos dashboards estão sem watermark obrigatório

| Família | Dashboards | InMov |
|---|---|---|
| F1 — Acompanhamento Serviços (5) | todos | ✅ |
| F2 — Manifestações Ouvidoria (5) | todos | ✅ |
| F3 — Avaliações (1) | `acomp_avaliacao_servicos` | ❌ |
| F4 — Carta de Serviços (1) | `acomp_carta_servicos` | ✅ |
| F5 — Obras / PDR I (5) | todos | ❌ |
| F6 — Curso de Motorista (2) | todos | ✅ (5.2pt — quase invisível) |

---

## 7. Plano de Correções

> [!tip] Prioridades de ação

**🔴 Alta prioridade**
- [ ] Remover `acomp_alvara_obras_santos_prototipo` das publicações de produção
- [ ] Reconstruir `acomp_avaliacao_servicos` com template padrão (fontes, KPI scale, InMov)

**🟠 Média prioridade**
- [ ] Adicionar sufixo "- OUVIDORIA" e corrigir tamanho do título (24pt → 25pt)
- [ ] Substituir `SegoeUI-Semibold` por `SegoeUI-Bold` nos 4 dashboards de obras
- [ ] Adicionar watermark InMov nos dashboards de obras
- [ ] Ajustar rodapé Curso de Motorista: 5.2pt → 7.5pt

**🟡 Baixa prioridade**
- [ ] "CE T" → "CET" no título de Manifestações CET
- [ ] "-SEGOV" → "- SEGOV" (espaço antes do hífen)
- [ ] "SEMAM/SEMAN" → "SEMAN"
- [ ] Título SEGOV: 28pt → 25pt

---

## 8. Notas Metodológicas

> [!note] Sobre ArialMT em mapas
> A fonte `ArialMT` aparece nos labels de atribuição do mapa (TomTom/OSM "Grayscale Light") em todos os dashboards que possuem mapa — é injetada pelo visual de mapa, não é uma escolha do designer. **Não deve ser incluída na lista de correções.**

> [!note] Sobre obras paradas (R5)
> Os 4 dashboards operacionais de obras refletem dados até 11/03/2025 (R5 Crítico — HTTP 401 no pipeline). Os desvios de padronização documentados aqui são **independentes** desse problema de pipeline — ver [[roadmap_acto_fabric]] para status do R5.
