---
status: validado
atualizado: "2026-07-22"
dono: analista-bi
---

# BI - Design System e Governanca

## Diretriz

Padronizar construcao de paineis com PBIP, temas e tokens compartilhados.

## Padrao

- relatorios versionaveis em artefatos texto
- medidas reutilizaveis
- governanca visual por regras de projeto
- validacao antes de merge/publicacao

## Excecao

Qualquer override visual/manual fora de padrao deve ser documentado com motivo e impacto.

## Criterios de qualidade para publicacao

- consistencia de tipografia, espacamento e nomenclatura entre familias de painel
- aderencia ao tema e aos tokens de design definidos
- coerencia entre indicador exibido e regra no Gold/semantic model
- ausencia de componentes de rascunho em artefato de producao

## Referencia

- pbi_design_system_test/estrategia_padronizacao_paineis.md (fonte pessoal, não versionada)
- .github/instructions/powerbi-standards.instructions.md (fonte pessoal, não versionada)

## Aplicacao pratica - diagnostico Santos (2026-04)

Base analisada: 19 dashboards de Santos.

Padrao de referencia observado nas familias mais consistentes:

- fonte primaria: StandardFont
- enfase: SegoeUI-Bold
- titulo principal: 25pt
- kpi principal: 27pt
- rodape InMov: 7.5pt

Desvios recorrentes a tratar em padronizacao:

- familias com SegoeUI-Semibold no lugar de SegoeUI-Bold
- ausencia de watermark InMov em parte da colecao
- variacao de tamanho de titulo fora do baseline de 25pt
- inconsistencias de nomenclatura em titulos e siglas

Regras operacionais para novos ajustes:

- qualquer dashboard fora do template entra com checklist de conformidade visual
- correcao de desvio deve priorizar token/theme e nao ajuste manual pontual
- paineis prototipo nao entram na trilha de publicacao oficial

Checklist minimo de conformidade:

1. tipografia aderente ao baseline de familia
2. watermark e rodape conforme padrao institucional
3. nomenclatura de secretaria e dominio sem variacao indevida
4. componentes visuais alinhados ao template PBIP
