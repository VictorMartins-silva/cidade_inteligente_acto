---
status: validado
atualizado: "2026-07-22"
dono: engenharia-dados-santos
---

# Fonte - Acto API Gestao

## Origem

API operacional da plataforma Acto para solicitacoes e etapas.

Escopo principal de uso:

- solicitacoes de servicos por secretaria
- etapas e tempos de atendimento
- dados de apoio para indicadores operacionais

## Formato

Resposta estruturada com colunas dinamicas por dominio/servico.

Contrato operacional minimo:

- payload por dominio documentado e versionado
- identificador de solicitacao consistente entre solicitacoes e etapas
- colunas de data em formato convertivel para datetime

## Periodicidade

Conforme janela de ingestao definida por pipeline.

Padrao recomendado:

- ingestao diaria para dominios operacionais
- reprocessamento controlado por janela quando houver erro de autenticacao ou schema drift

## Lakehouse alvo

- lh_solicitacoes_acto
- lh_cidade_inteligente_santos (legado)

## Camadas

- Bronze: payload bruto por fonte
- Silver: consolidacao e padronizacao
- Gold: visoes por dominio para consumo BI

## Regras de ingestao e qualidade

- separar claramente extracao, transformacao e escrita
- validar rowcount antes de escrever em Gold
- registrar colunas obrigatorias por dominio
- em falha de autenticacao, aplicar retry controlado apos renovacao de token

## Dependencias sensiveis

- token e credenciais de API nunca versionados em texto aberto
- arquivos auxiliares de payload mantidos em local governado

## Restricoes LGPD

- atencao a campos pessoais (nome, cpf, contato)
- mascaramento e segregacao por perfil de acesso quando aplicavel

## Referencia tecnica

- Acto Cidade Inteligente/Acto/CLAUDE.md (fonte pessoal, não versionada)
- GUIA_MESTRE_COPILOT.md (fonte pessoal, não versionada)
