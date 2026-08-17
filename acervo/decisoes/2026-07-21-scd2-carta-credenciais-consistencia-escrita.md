---
status: validado
atualizado: "2026-07-22"
dono: coordenador
---

# Decisao - SCD2 Carta, Credenciais e Consistencia de Escrita

## Problema

Havia variacao de abordagem entre notebooks para vigencia de SLA/Carta de Servicos, tratamento de autenticacao de API e uso de overwrite/append, aumentando risco de inconsistencias de historico e publicacao.

## Alternativas

1. Manter liberdade por notebook, com ajustes caso a caso.
2. Definir padrao oficial unico para vigencia, autenticacao e politica de escrita.

## Decisao

Adotar padrao oficial transversal:

- SLA/Carta de Servicos segue SCD Type 2 por vigencia temporal.
- falha de autenticacao deve usar renovacao de credencial e retry controlado, sem exposicao de segredo.
- operacao de escrita (overwrite/append) deve ser explicita, justificada e validada por impacto.

## Regras normativas

### 1) SCD Type 2 para SLA/Carta

- joins de vigencia devem usar data de evento no intervalo de vigencia
- proibido aplicar somente registro atual quando a analise for historica

### 2) Credenciais e token

- tokens e segredos nao podem ser versionados em texto puro
- erro de autenticacao deve acionar fluxo de renovacao controlado
- retry limitado e direcionado a causa, sem loop generico

### 3) Consistencia overwrite/append

- overwrite apenas com validacao pre-write e impacto mapeado
- append apenas com criterio de deduplicacao e idempotencia definido
- mudanca de estrategia exige registro de decisao e evidencia de validacao

## Status

Aprovada para aplicacao em notebooks e pipelines ativos da plataforma.

## Impacto

- reduz divergencia historica em indicadores de SLA/Carta
- melhora confiabilidade operacional em ingestao com autenticacao
- aumenta rastreabilidade de publicacao por politica de escrita

## Referencias

- _DADOS_LOCAIS_HISTORICO/Santos/Referencia_Tecnica_Fabric_Santos_v2_0.md (fonte pessoal, não versionada)
- acervo/fontes/acto-api.md
- acervo/engenharia-dados/orquestracao-e-observabilidade.md
