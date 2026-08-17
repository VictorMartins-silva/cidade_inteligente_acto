---
status: validado
atualizado: "2026-07-22"
dono: analista-front-end
---

# Front-end

Conhecimento de consumo por aplicacoes e integracoes que usam dados do Fabric.

## Relacao com arquivo raiz

- consumo-sql-endpoint.md consolida contratos de SLA e regras de publicação por família/eixo
- este README cobre como conectar e o que consultar; aquele cobre o que está publicado e com qual garantia

## Padrao de acesso

Toda integração externa deve apontar para o **SQL Endpoint** do lakehouse de destino, nunca para arquivos Delta diretamente.

**Autenticação:**
- **Service Principal** (preferencial para produção): registrar o SP no Entra ID, conceder papel de `Viewer` ou superior no workspace Fabric, usar o `client_id` + `client_secret` na string de conexão.
- **Credencial pessoal temporária** (aceitável para desenvolvimento e exploração): login interativo via browser ou token AAD pessoal. Nunca usar credencial pessoal em pipelines automatizados ou código versionado.

**String de conexão genérica (ODBC/JDBC):**
```
Server=<workspace-id>.datawarehouse.fabric.microsoft.com
Database=<lakehouse-name>
Authentication=ActiveDirectoryServicePrincipal  # ou ActiveDirectoryInteractive para credencial pessoal
```

**Driver SQL recomendado:** ODBC Driver 18 for SQL Server (Windows/Linux) ou `pyodbc` com o mesmo driver em Python. O SQL Endpoint do Fabric é compatível com T-SQL padrão do SQL Server.

**Lakehouses disponíveis:**
- `lh_cidade_inteligente_santos` — tabelas Gold de Santos (serviços, obras, manifestações, avaliações)
- `lh_solicitacoes_acto` — tabelas Gold do módulo EAV (Santos, Osasco, Maúa)
- `lh_dados_publicos` — dados públicos e geoespacial (IBGE, CAGED, benchmarking)

## O que consumir e o que evitar

| O que consumir | O que evitar |
|---|---|
| Tabelas Gold (`gold.*`) | Tabelas Bronze (`bronze.*`) — dado bruto sem tratamento |
| Views Gold publicadas com contrato definido | Tabelas Silver (`silver.*`) — intermediário de pipeline, não de consumo |
| SQL Endpoint com Direct Lake no semantic model | Tabelas Gold sem contrato definido (sem dono, sem SLA, sem grão documentado) |
| Tabelas com SLA declarado em `consumo-sql-endpoint.md` | Consultas sem filtro de data em tabelas de alta volumetria (ex.: `silver.fato_etapas` com ~340 mil linhas e crescendo) |
| Colunas documentadas no catálogo de schema | Colunas com prefixo `_raw` ou `_tecnico` — são artefatos de pipeline |

> Dado sensível (PII): tabelas que contenham dado pessoal identificável (ex.: CadOZ em Osasco) não seguem contrato padrão de distribuição. Qualquer consumo dessas tabelas exige controle de acesso dedicado — ver alerta abaixo.

## Consultas de exemplo

As consultas abaixo usam nomes de coluna genéricos baseados no schema Gold do módulo Acto. Adaptar `{fonte}` e `{secretaria}` conforme o contrato do domínio desejado.

**a) Listar serviços ativos de uma secretaria:**
```sql
SELECT DISTINCT
    servico,
    secretaria,
    unidade_organizacional,
    COUNT(*) AS total_os
FROM gold.fato_servicos
WHERE
    secretaria = '{secretaria}'
    AND status_fluxo NOT IN ('Cancelado', 'Arquivado')
    AND data_criacao >= DATEADD(day, -90, GETDATE())
GROUP BY servico, secretaria, unidade_organizacional
ORDER BY total_os DESC;
```

**b) Contar solicitações por status no período:**
```sql
SELECT
    status_fluxo,
    COUNT(*) AS quantidade,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS pct_total
FROM gold.fato_servicos
WHERE
    data_criacao BETWEEN '{data_inicio}' AND '{data_fim}'
    AND municipio = '{municipio}'
GROUP BY status_fluxo
ORDER BY quantidade DESC;
```

**c) SLA médio por etapa (tempo de execução em dias):**
```sql
SELECT
    etapa,
    servico,
    COUNT(*) AS total_etapas,
    ROUND(AVG(DATEDIFF(day, data_inicio_etapa, data_fim_etapa)), 1) AS sla_medio_dias,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY DATEDIFF(day, data_inicio_etapa, data_fim_etapa)), 1) AS sla_mediana_dias
FROM gold.fato_etapas
WHERE
    data_inicio_etapa >= '{data_inicio}'
    AND data_fim_etapa IS NOT NULL
    AND municipio = '{municipio}'
GROUP BY etapa, servico
HAVING COUNT(*) >= 10
ORDER BY sla_medio_dias DESC;
```

> Para consultas em `lh_solicitacoes_acto`, confirmar os nomes reais de coluna consultando `silver.fato_campos` antes de usar — ver [engenharia-dados/runbook-debug-api-acto.md](../engenharia-dados/runbook-debug-api-acto.md#passo-3).

## Formato esperado das notas

- Contrato de acesso
- Restricoes de consumo
- Limites tecnicos
- Integracao com SQL Endpoint

## Relacao com arquivo raiz

- consumo-sql-endpoint.md consolida acordos gerais

## Alerta de dado sensivel

- paineis com PII (ex.: CadOZ H1N1 em Osasco) nao seguem contrato padrao de distribuicao ampla
- consumo de dado pessoal exige controle de acesso dedicado e nao deve ser exposto em integracao externa generica

> Ver [GUIA_ACERVO.md](../GUIA_ACERVO.md) para o índice completo de notas desta pasta.
