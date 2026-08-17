---
tags: [produto, datahub, negocio, estrategia]
criado: 2026-07-03
status: rascunho-para-discussao
---

# 01 · Visão de Produto e Modelo de Negócio

⬅️ [[00_INDEX_PRODUTO]] · Próximo: [[02_diagnostico_fabric_atual]]

## 1. O produto

**DataHub Municipal**: plataforma de dados e indicadores para prefeituras, construída sobre Microsoft Fabric + Power BI, que combina:

1. **Dados operacionais do Acto** (solicitações, obras, carta de serviços/SLA, avaliações) — o core proprietário, que já entregamos hoje;
2. **Dados públicos municipalizados** (IBGE, RAIS, CAGED, SSP, DATASUS, Censo Escolar/IDEB) — o diferencial de benchmarking e contexto;
3. **Camada de consumo** — painéis Power BI por secretaria, semantic models Direct Lake, SQL Endpoint e, futuramente, catálogo e serviços analíticos.

> [!tip] Tese central
> A Eicon não vende "tabelas" — vende **decisão municipal informada**. Dados públicos nacionais são commodity (qualquer um baixa); o valor está em **municipalizar, cruzar com o operacional do Acto e entregar no formato que o gestor já usa** (Power BI, Excel via SQL Endpoint).

## 2. Cliente e proposta de valor

- **Cliente:** prefeituras (B2G). Ativos: Santos (principal), Osasco, Mauá; Aparecida de Goiânia e SJRP em desenvolvimento.
- **Usuário:** secretarias municipais (SEONT, SEMAM, ouvidoria, planejamento) e gestores que abrem OS de painéis.
- **Proposta de valor atual:** analytics operacional sobre o Acto — SLA de carta de serviços (SCD Type 2 de vigência de prazos), acompanhamento de obras, avaliação de serviços.
- **Proposta de valor do hub:** benchmarking entre municípios e indicadores de contexto. O modelo já existe embrionário no `lh_dados_publicos`: **15 municípios em 3 clusters** (3 clientes core + 12 benchmarks), onde adicionar uma cidade = adicionar um código IBGE no dict `CLUSTERS` de `nb_utils_ibge`.

### Valor analítico já demonstrado

- "Insight de ouro" (04/05/2026): disparidade de **59 p.p. na formalização de emprego** entre São Caetano (69,2%) e Carapicuíba (10,3%) via RAIS ÷ População — exatamente o tipo de comparativo que sustenta a narrativa de benchmarking (`insights_decisoes_dados_publicos.md`).
- Recuperação pós-pandemia do saldo CAGED confirmada nos 3 clusters.
- Geo de segurança pública: `gold.osasco_ssp_criminais_geo` (62 mil registros, 60 bairros) alimentando mapas Azure Maps.

## 3. Posicionamento vs. Acto

| | Acto (operacional) | DataHub (dados públicos) |
|---|---|---|
| Origem | API proprietária do produto | Fontes públicas nacionais/estaduais |
| Exclusividade | Alta — só nós temos | Nenhuma — commodity; valor na curadoria |
| Sensibilidade | PII, LGPD | Dados abertos/agregados |
| Engenharia | Própria, obrigatória | Terceirizável ([[04_estrategia_terceirizacao_bd]]) |
| Papel no produto | Core da relação com o cliente | Contexto, benchmarking, upsell de domínios |

O hub **não substitui** o trabalho Acto — ele o envolve: um painel de obras ganha camada de contexto demográfico; um painel de SLA ganha comparativo com municípios similares.

## 4. Modelo econômico (cenários de empacotamento)

| Cenário | Quando usar | Posicionamento |
|---|---|---|
| **Insumo comum** | Bases usadas por todos os clientes, processadas 1× no lakehouse central | Incluído no custo base da plataforma; ganho vem de escala (ingere 1×, serve N municípios) |
| **Fonte premium** | Domínios de alto valor com SLA/enriquecimento (Saúde, Educação, Finanças) | Pacotes por domínio, cobrados por município |
| **Fallback/robustez** | Conector próprio + BD como comparação/backup em bases críticas | Argumento de qualidade e continuidade operacional |

Custos novos a monitorar: plano Base dos Dados (Pro R$37/mês → Orgs sob consulta), scan BigQuery (mitigado por replicação batch para OneLake — nunca consulta em tempo real), capacidade Fabric.

## 5. O que precisa ser verdade para virar produto

1. **Entrega deixa de ser artesanal** — hoje cada painel é construído e reconectado manualmente (dependência de pessoas nomeadas: Jorge para reconexão PBI, Yuri para CAGED/DATASUS). Precisa virar template + configuração.
2. **Onboarding de município repetível** — Aparecida e SJRP estão com pastas vazias há meses porque não existe "kit de implantação". O kit *é* o produto.
3. **Confiabilidade contratual** — SLA por produto de dado, monitoramento de frescor, ambientes dev/prod (hoje tudo roda em produção — 7 workspaces solicitados ao cliente, sem resposta).
4. **Governança perante prefeituras** — segredos fora dos notebooks, LGPD, contrato corporativo de IA (`proposta_claude_business.md`).

## 6. Stakeholders e decisões pendentes de negócio

- **Yuri** — valida fase 2 DATASUS/INEP e transição CAGED; gargalo de várias frentes.
- **Jorge** — reconexão de painéis Santos ao schema `gold.santos_*`.
- **Kelly (SEMAM/Santos)** — decisões de escopo dos painéis de obras.
- **Decisão pendente:** expandir clusters para novos municípios (ex. Aparecida) é decisão de negócio explícita, não técnica.
- **Decisão pendente:** modo do semantic model unificado de dados públicos — Direct Lake (guia mestre) vs Import (pendências) — precisa ser fechada. Ver [[03_arquitetura_alvo]].

---
Fontes: `roadmap_acto_fabric.md`, `insights_decisoes_dados_publicos.md`, `pendencias_projeto_dados_publicos.md`, `GUIA_MESTRE_DADOS_PUBLICOS.md`, `spec_drive_semana_29_06_2026.md`, `spec_drive_dados_publicos.md`, `proposta_claude_business.md`.
