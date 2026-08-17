---
status: validado
atualizado: "2026-07-22"
dono: engenharia-dados
---

# Fonte - IBGE SIDRA

## Origem

API publica do IBGE SIDRA para indicadores socioeconomicos.

## Formato

JSON/tabular por tabela e recorte geografico.

## Periodicidade

Varia por tabela; revisar calendario por indicador.

## Lakehouse alvo

- lh_dados_publicos

## Camadas

- Bronze: captura por tabela
- Silver: normalizacao e padronizacao de chaves
- Gold: agregacoes para consumo analitico

## Restricoes LGPD

Dados publicos agregados; sem dado pessoal direto no uso padrao.

## Referencia tecnica

- Acto Cidade Inteligente/Dados Publicos/DOCUMENTACAO_TECNICA.md (fonte pessoal, não versionada)
