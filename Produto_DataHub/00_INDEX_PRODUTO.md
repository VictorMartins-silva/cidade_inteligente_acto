---
tags: [produto, datahub, fabric, planejamento]
criado: 2026-07-03
status: ativo
---

# 🧭 Produto DataHub — Índice

> [!info] O que é esta pasta
> Planejamento de como transformar o trabalho de Fabric + Power BI da Eicon em um **produto interno: hub de dados públicos municipais** (DataHub Municipal). Consolida a visão de negócio, o diagnóstico do ambiente atual, a arquitetura alvo, a estratégia de terceirização via Base dos Dados e o roadmap por fases.
> Criado em 03/07/2026 a partir de pesquisa consolidada por sub-agents sobre toda a documentação e notebooks existentes.

## Documentos desta pasta

| Doc | Conteúdo | Pergunta que responde |
|---|---|---|
| [[01_visao_produto_modelo_negocio]] | Visão do produto, cliente, proposta de valor, modelo econômico | *O que estamos construindo e para quem?* |
| [[02_diagnostico_fabric_atual]] | Estado atual do Fabric: inventário, desorganização, riscos, o que já funciona | *De onde estamos partindo?* |
| [[03_arquitetura_alvo]] | Arquitetura técnica alvo: lakehouses, contratos de dados, qualidade, dev/prod | *Como o produto deve ser construído tecnicamente?* |
| [[04_estrategia_terceirizacao_bd]] | Terceirizar → aprender → internalizar com a Base dos Dados | *Como ganhar tempo sem perder controle?* |
| [[05_roadmap_fases]] | Roadmap 0–30 / 30–60 / 60–90 / 90+ dias | *O que fazer, em que ordem?* |

## Contexto em uma frase

Começamos no Fabric trabalhando a API do Acto (Santos, Osasco, Mauá); o workspace acumulou fontes públicas (IBGE, RAIS, CAGED, SSP, DATASUS/INEP em estudo) de forma desorganizada. A tese: **organizar isso como produto**, terceirizando inicialmente a ingestão de dados públicos nacionais para a Base dos Dados (BigQuery), estudando o método deles, e internalizando a engenharia quando fizer sentido — liberando o time para construir o produto (catálogo, painéis, semantic models, onboarding de municípios) primeiro.

## Anexos de apoio (nesta pasta)

Análises originalmente produzidas em conversa e salvas aqui como referência dos docs acima:

- `estrategia_terceirizacao_dados_basedosdados.html` — matriz de decisão, pauta de negociação e riscos da terceirização (base de [[04_estrategia_terceirizacao_bd]])
- `analise_basedosdados_lakehouse_eicon.html` — comparativo arquitetural Base dos Dados × Lakehouse Eicon e gaps críticos (base de [[02_diagnostico_fabric_atual]] e [[03_arquitetura_alvo]])
- `autenticacao-service-principal-fabric.html` — guia de migração de OAuth pessoal para Service Principal nos semantic models (base da seção 5 de [[03_arquitetura_alvo]])

## Documentação relacionada (fora desta pasta)

- [[00_MAPA]] — índice mestre da documentação Fabric
- [[GUIA_MESTRE_DADOS_PUBLICOS]] — framework de dados públicos (`lh_dados_publicos`)
- [[Referencia_Tecnica_Fabric_Santos_v2_0]] — referência executiva Santos
- [[MAPEAMENTO_WORKSPACE_FABRIC]] — auditoria do workspace
- [[spec_drive_datasus_censo_ideb]] — pesquisa DATASUS/INEP (rota BigQuery decidida)
- [[roadmap_acto_fabric]] — roadmap do produto Acto
