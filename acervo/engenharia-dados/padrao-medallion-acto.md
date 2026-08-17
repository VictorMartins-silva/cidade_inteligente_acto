---
status: validado
atualizado: "2026-07-22"
dono: engenharia-dados
---

# Padrao Tecnico - Medallion Acto

## Padrao tecnico

Camadas Bronze -> Silver -> Gold com separacao de responsabilidade por etapa.

## Fluxo

1. Extracao da fonte
2. Persistencia Bronze
3. Padronizacao Silver
4. Regras de negocio Gold
5. Publicacao para consumo

## Riscos

- perda silenciosa de registros
- overwrite sem validacao
- mudanca de schema em fonte externa

## Pontos de atencao

- assert de rowcount antes de escrita
- campos-chave validados antes de joins
- rastreabilidade de transformacoes

## Referencias

- GUIA_MESTRE_COPILOT.md
- Acto Cidade Inteligente/Acto/CLAUDE.md
