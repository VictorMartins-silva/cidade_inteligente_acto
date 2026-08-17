---
title: Investigacao da variacao de volume - cartas de servico osasco
date: 2026-08-10
tags:
  - tipo/erro-solucao
  - projeto/carta-servicos
  - municipio/osasco
  - ferramenta/fabric
  - ferramenta/sql
  - camada/gold
projeto: carta-servicos-osasco
fonte: notebook-gold-carta-servicos-e-sql-endpoint-osasco
status: levantamento
---

# Contexto

Foi aberto um diagnostico para entender o salto de **432 para 1157** no volume de cartas de servico em Osasco.

- SQL endpoint informado: `ena6obg6j2cevcppw7dn7yu57a-knnp5frchjbujdik4l3nmgrgsa.datawarehouse.fabric.microsoft.com`
- Database informado: `Osasco carta de serviço`
- Processo principal: [[Documentação_Fabric/Osasco/nbs/carta_servicos/nb_ingest_carta_servicos_osasco.ipynb]]
- Tabelas alvo: `gold_carta_servicos`, `gold_carta_servicos_atualizacoes`

# Resultado da investigacao de logica do processo

O aumento tem alta probabilidade de vir de **mudanca de granularidade/duplicidade na Gold**, nao necessariamente de aumento real de servicos.

## Escopo analisado (processo de ingestao)

- [[Documentação_Fabric/Osasco/nbs/carta_servicos/nb_ingest_carta_servicos_osasco.ipynb]]
- [[Documentação_Fabric/Osasco/nbs/carta_servicos/nb_ingest_acto_gestao_tempo_etapa_carta_servicos.ipynb]]

## O que mudou nas ultimas atualizacoes (evidencia local)

- `nb_ingest_carta_servicos_osasco.ipynb` e `nb_ingest_acto_gestao_tempo_etapa_carta_servicos.ipynb` estao com `LastWriteTime` em **2026-04-20**.
- Nao foi encontrada, neste vault, outra versao do notebook de Osasco para diff de codigo linha a linha.
- Ou seja: o salto recente de volume tende a vir de **mudanca de dados de entrada** (CSVs em `/raw_cadastro_carta/`) e/ou **mudanca de medida no painel**, nao de alteracao nova de codigo no notebook.

## Evidencias no notebook de Osasco

1. Em `carregar_tratar_bd()`, a remocao de duplicidade por unidade foi comentada:
   - `drop(columns=["Como acessar o serviço:", "Sigla da unidade:", "Nome da Unidade:"])`
   - `drop_duplicates()`
2. Em `gerar_bd_final()`, o dataset final e `concat(grid_em_aberto, bd_cleaned)`, sem deduplicacao adicional.
3. `grid_em_aberto` remove colunas que poderiam ajudar a rastrear unicidade (ex.: numero de solicitacao) antes da consolidacao na Gold.
4. Diferenca para Santos: no notebook de Santos existe tratamento extra (ex.: normalizacoes adicionais e filtro de nulos) que reduz ruido antes da escrita.
5. O notebook `nb_ingest_acto_gestao_tempo_etapa_carta_servicos` escreve somente `gold_carta_servicos_tempo_etapa` (catalogo 6903) e **nao interfere** na contagem de `gold_carta_servicos`.

## Hipotese principal

O painel pode estar contando **linhas** de `gold_carta_servicos` (ou linhas por unidade/etapa) em vez de entidade unica de servico. Se a base passou a manter multiplas linhas por servico (unidades distintas ou registros em aberto + finalizado), o total sobe mesmo sem crescimento real.

## Hipoteses de causa raiz (ordem de probabilidade)

1. **Mudanca na granularidade da fonte CSV**: entrada passou a trazer mais ocorrencias por servico (ex.: solicitacoes/entidades), elevando `COUNT(*)`.
2. **Medida do BI mudou para contagem de linhas** (`COUNTROWS`) em vez de `DISTINCTCOUNT` de chave de servico.
3. **Mistura de conceitos no mesmo KPI**: "servicos publicados" (catalogo) junto com "solicitacoes em andamento" (operacional) na mesma metrica.

# Queries para confirmar no SQL endpoint

As queries abaixo estao em [[Documentação_Fabric/Osasco/exploracao-local-carta-servicos-2026-08-10/queries-diagnostico-sql-cartas-servico-osasco.sql]].
Versao para execucao celula a celula em Python: [[Documentação_Fabric/Osasco/exploracao-local-carta-servicos-2026-08-10/validacao-cartas-servico-osasco-sql-endpoint.ipynb]].

Validacoes prioritarias:
- contagem total de linhas vs distinct de `id_do_servico` e `nome_do_servico`
- volume por `status_tramitacao`
- servicos com maior multiplicidade (`COUNT(*)` por `id_do_servico`/`nome_do_servico`)
- comparativo por data (`data_consolidada`) para localizar quando ocorreu a virada

# Limitacao local encontrada

Neste ambiente local, nao ha cliente SQL instalado (`sqlcmd`) para executar a conexao direta no endpoint. A investigacao de processo foi concluida por leitura tecnica dos notebooks e mapeamentos.

# Proximo passo operacional

Executar o arquivo SQL de diagnostico no Fabric SQL Query Editor (ou em maquina com `sqlcmd`/ODBC) e validar se o KPI do Power BI deve usar `DISTINCTCOUNT` em vez de `COUNTROWS`.
