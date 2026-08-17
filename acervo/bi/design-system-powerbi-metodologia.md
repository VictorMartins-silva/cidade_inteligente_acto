---
status: rascunho
atualizado: "2026-07-22"
dono: analista-bi
---

# BI - Metodologia Completa de Design System Power BI

## Fonte canonica

- pbi_design_system_test/README.md, 00_GUIA_DE_ESTUDO.md, estrategia_padronizacao_paineis.md e pastas fase_0_fundacao/ a fase_3_operacao/ (fonte pessoal, não versionada)

## Atencao — validar antes de tratar como concluido

O arquivo de status do projeto (`00_STATUS_PROJETO.md`) esta datado de 2026-08-17 ("PROJETO CONCLUIDO — Fase 0 Completa"), uma data **futura** em relacao a esta nota (2026-07-21) e posterior a ultima atualizacao do README (2026-07-17, "Fase 0 — Em desenvolvimento"). Ha inconsistencia de datas entre os dois arquivos-fonte — confirmar com quem mantem o projeto qual e o estado real da Fase 0 antes de tratar os artefatos abaixo como prontos para uso em producao.

## Diretriz

Design system Power BI organizado em 5 camadas e 4 fases de implementacao — vai alem do diagnostico ja registrado em `bi/design-system-powerbi.md` (que cobre so os desvios encontrados em Santos): aqui esta a metodologia operacional para corrigir e manter o padrao.

## As 5 camadas da arquitetura

1. **Themes JSON** — tema de cores/fonte por cliente (ex.: `theme_osasco.json`, `theme_santos.json`), importado direto no Power BI Desktop.
2. **Template PBIP + componentes** — templates HTML de componente visual (ex.: `card_kpi.html`, `card_comparativo.html`) com placeholders a preencher.
3. **Design tokens + UDFs DAX** — medidas de token (cor, fonte, espacamento) e funcoes DAX que geram os cards HTML a partir dos tokens (`f_CardKPI`, `f_CardComparativo`).
4. **VisOps (Git + pipeline de validacao)** — `.gitignore` que ignora `.pbix` binario e versiona `.pbip`/`.json`; pipeline teorico de validacao (PBI Inspector + Best Practice Analyzer + lints).
5. **IA assistida** — uso de IA para apoiar geracao/validacao de artefatos (mencionado na metodologia, sem detalhamento adicional no material lido).

## As 4 fases

| Fase | Objetivo | Entregas |
| --- | --- | --- |
| Fase 0 — Fundacao | Criar os artefatos base | Temas JSON, componentes HTML, tokens/UDFs DAX, config Git |
| Fase 1 — Piloto | Validar viabilidade tecnica | 2 paineis piloto (1 simples, 1 complexo) + 4 testes tecnicos |
| Fase 2 — Tombamento | Migrar paineis existentes | Mapeamento de paineis atuais, criterios de priorizacao, guia de conversao, estimativa de esforco |
| Fase 3 — Operacao | Manter o padrao no dia a dia | SOP de novo painel, SOP de rebranding de tema, SOP de desvios/excecoes, monitoramento de conformidade |

## Artefatos reutilizaveis (prontos para copiar e adaptar)

| Artefato | Uso |
| --- | --- |
| `theme_osasco.json` / `theme_santos.json` | Import direto em Power BI Desktop (File → Import theme) |
| `card_kpi.html` / `card_comparativo.html` | Copiar estrutura HTML, preencher placeholders |
| `design_tokens.dax` | Medidas de token (cor, fonte, espacamento) |
| `f_CardKPI.dax` / `f_CardComparativo.dax` | UDFs que geram HTML de card a partir dos tokens |

## Pontos de atencao

- Antes de aplicar aos paineis reais, seguir a ordem das fases (nao pular direto para tombamento sem validar o piloto).
- Cruzar com os desvios ja diagnosticados em `bi/design-system-powerbi.md` (tipografia, watermark, nomenclatura) para garantir que os tokens/temas cobrem essas correcoes especificas.

## Referencias

- pbi_design_system_test/ (README, guia de estudo, 4 fases) (fonte pessoal, não versionada)
- bi/design-system-powerbi.md (diagnostico Santos que motivou esta metodologia)
