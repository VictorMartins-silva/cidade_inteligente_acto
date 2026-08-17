---
status: validado
atualizado: "2026-07-22"
dono: engenharia-dados
---

# Fonte - CAGED

## Origem

Novo CAGED (Cadastro Geral de Empregados e Desempregados), com recortes municipais para acompanhamento de mercado de trabalho.

## Formato

Base tabular com registros de movimentacao de emprego formal por periodo e recorte geografico.

## Periodicidade

Carga recorrente conforme calendario de publicacao da fonte e janela de ingestao do projeto.

## Lakehouse alvo

- lh_cidade_inteligente_osasco
- lh_cidade_inteligente_santos

## Camadas

- Bronze: dump historico da fonte
- Silver: padronizacao e saneamento de campos
- Gold: agregacoes para consumo analitico

## Contrato minimo de qualidade

- codigo municipal correto por recorte de cidade
- competencia temporal valida e consistente
- chaves e dimensoes geograficas sem ambiguidades

## Risco de qualidade conhecido

- uso de codigo municipal incorreto pode direcionar dados para municipio errado e comprometer indicadores.

## Regras de mitigacao

- validar codigo do municipio antes de publicar Gold
- manter validacao automatica de municipio esperado por pipeline
- bloquear publicacao quando houver divergencia de codigo

## Restricoes LGPD

Dados agregados e de vinculo formal sem exposicao de identificadores pessoais em camadas de consumo.

## Referencia tecnica

- _DADOS_LOCAIS_HISTORICO/Santos/Referencia_Tecnica_Fabric_Santos_v2_0.md (fonte pessoal, não versionada)
- _DADOS_LOCAIS_HISTORICO/Osasco/Mapeamento Tecnico de Notebooks - Osasco.md (fonte pessoal, não versionada)
