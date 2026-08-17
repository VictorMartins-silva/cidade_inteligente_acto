---
status: validado
atualizado: "2026-07-22"
dono: engenharia-dados
---

# Padrao Tecnico - Monitoramento de Fontes de Dados

## Objetivo

Estabelecer monitoramento minimo para detectar degradacao de qualidade, quebra de schema e falhas de ingestao antes de impactar Gold e Power BI.

## Escopo

- fontes API (Acto)
- fontes publicas tabulares (CAGED, SIDRA, RAIS e equivalentes)
- arquivos auxiliares criticos usados em transformacoes

## Sinais obrigatorios por execucao

1. disponibilidade da fonte
2. status de autenticacao/autorizacao
3. rowcount de entrada e saida
4. esquema minimo esperado
5. taxa de nulos em colunas criticas

## Regras de alerta

- alerta critico quando rowcount de saida for zero em carga esperada positiva
- alerta alto para quebra de schema em coluna obrigatoria
- alerta alto para falha de autenticacao recorrente
- alerta medio para variacao anomala de volume entre janelas

## Checklist pre-publicacao Gold

1. rowcount validado e acima de limite minimo da fonte
2. schema obrigatorio presente
3. chaves de negocio sem duplicidade critica
4. dependencia de arquivo auxiliar confirmada

## Governanca de resposta

- incidente de runtime/plataforma: tratar como falha operacional
- incidente de consistencia/qualidade: tratar como falha de dados
- toda mitigacao aplicada deve registrar causa, acao e validacao posterior

## Referencias

- acervo/engenharia-dados/orquestracao-e-observabilidade.md
- acervo/fontes/acto-api.md
- acervo/fontes/caged.md
