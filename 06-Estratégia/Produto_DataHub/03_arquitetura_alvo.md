---
tags: [produto, datahub, fabric, arquitetura]
criado: 2026-07-03
status: proposta
---

# 03 · Arquitetura Alvo

⬅️ [[02_diagnostico_fabric_atual]] · Próximo: [[04_estrategia_terceirizacao_bd]]

> [!info] Princípio
> **Fabric continua sendo o runtime do produto** (Lakehouse, SQL Endpoint, Direct Lake, Power BI — combina com prefeituras). A Base dos Dados entra como fornecedor de supply chain de dados públicos e como **benchmark de disciplina de produto de dados** (contratos, testes, diretórios, onboarding) — não como stack a copiar.

## 1. Topologia de lakehouses

```
┌─ lh_dados_publicos (CENTRAL — ingere 1×, serve N municípios)
│    bronze.*  ← snapshots fiéis (BigQuery/BD, SIDRA, FTP)
│    silver.*  ← schema canônico municipalizado
│    gold.*    ← produtos por domínio (prefixo por município ou multi-município)
│
├─ lh_solicitacoes_acto (CENTRAL — modelo EAV, dados operacionais Acto)
│
└─ lakehouses municipais (dados sensíveis/específicos do cliente)
     lh_cidade_inteligente_{municipio} → consumo via shortcut do central
```

- **Dados públicos: processar uma vez para todos.** O dict `CLUSTERS` vira tabela de configuração Delta (ver §4).
- **Shortcuts OneLake** para expor Gold central aos lakehouses/workspaces municipais sem duplicar dados.
- **Legado descontinuado com plano formal** — cada tabela do LH legado ganha destino (migrar / dropar / congelar), como já feito na migração `gold.santos_*`.

## 2. Camadas e contratos

| Camada | Regra | Contrato |
|---|---|---|
| **Bronze** | Snapshot fiel da fonte (query BD, JSON API), sem reescrever semântica; metadados de carga (`dt_ingestao`, origem, versão) | Rastreabilidade até a fonte |
| **Silver** | Municipalização, tipagem, chaves canônicas (`id_municipio` int, `ano` int), junção com diretórios | Schema canônico: `id_municipio · nome_municipio · ano · indicador · valor` |
| **Gold** | Produto por painel/indicador; nomenclatura `gold.{municipio}_{dominio}_*`; lógica de negócio aqui, DAX mínimo | **Contrato de produto de dados** (ver abaixo) |

### Contrato de produto de dados (inspirado no schema.yml do dbt/BD)
Um arquivo de metadados versionado por produto Gold: colunas, tipos, descrições, chaves/grão, frequência, cobertura temporal, owner, sensibilidade, SLA e formas de consumo. É a fonte para gerar documentação, catálogo e testes — substitui o inventário Markdown manual.

## 3. Qualidade e observabilidade

- **Checks mínimos por produto** (espírito dos testes dbt): not-null em chaves, unicidade por grão, relacionamento com diretórios, recência (freshness), variação de volume vs. carga anterior. Resultado gravado em tabela `monitor.execucoes`.
- **Monitoramento independente da fonte:** mesmo com a BD monitorando a origem, o hub monitora a dependência (o R5 ficou 60 dias invisível — isso não pode se repetir).
- **Pipelines com retry > 0** e alerta em falha (hoje `pl_ingest_acto` tem `retry: 0`).

## 4. Configuração metadata-driven (mata R9 e habilita onboarding)

Duas tabelas Delta de configuração:

- **`config.tenants`** — município, código IBGE, cluster, tokens/segredos (referência Key Vault), mapeamento de bairros, regionais, prazos. Elimina Excel auxiliares (R1) e hardcodes (R9).
- **`config.fontes_externas`** — dataset, tabela BD/BigQuery, periodicidade, owner, criticidade, licença, SLA, última carga, custo estimado, fallback documentado. É o catálogo de dependências externas exigido pela estratégia de terceirização ([[04_estrategia_terceirizacao_bd]]).

## 5. Segurança e identidade

- **Azure Key Vault** (ou Fabric credentials) para todos os segredos; rotacionar credenciais já expostas (tokens Acto, service account GCP); scan de segredos no CI (gitleaks).
- **Service Principal** para conexões dos semantic models (substituir OAuth pessoal — causa raiz dos erros `DMTS_EntityNotFoundOrUnauthorized`): App Registration + conexão de nuvem compartilhada + remapeamento modelo a modelo. Guia completo já produzido (`autenticacao-service-principal-fabric.html`).
- **Isolamento por cliente:** workspace por município (ou no mínimo RLS/schema por tenant) para acesso e custo.

## 6. Ambientes e ALM

- **Dev/Prod separados** — 7 workspaces já solicitados ao cliente; enquanto não vêm, ao menos branch de lakehouse/notebooks com sufixo `_dev`.
- **Git integrado ao workspace Fabric** + deployment pipelines; CI mínimo: gitleaks + validação de notebooks + ruff/pytest em funções puras.
- **Promoção com validação:** nada chega a Prod sem os checks do §3 passarem.

## 7. Camada de distribuição (Power BI)

- **Direct Lake como padrão** para dados públicos, com dimensões compartilhadas (`dim_municipio`, `dim_calendario`) num semantic model unificado.
  > [!warning] Decisão pendente
  > Há divergência entre docs: Direct Lake (guia mestre/spec) × Import (pendências). Fechar essa decisão antes do semantic model unificado — atenção às limitações de Direct Lake (autenticação: só OAuth2/Service Principal/Workspace Identity).
- Padrão de pipeline mantido: `Gold → RefreshSqlEndpoint → Refresh semantic model`.
- **Template de painel por domínio** (como o padrão geo SSP): notebook Gold copiável + tema PBI + medidas padrão → replicação entre municípios vira configuração.

## 8. Diretórios canônicos

Promover a Delta Tables oficiais do hub (internalizando os `br_bd_diretorios_brasil` da BD, hoje usados via CSV no Gold RAIS): município, UF, tempo, CNAE, CBO, escola (INEP), estabelecimento (CNES), bairros harmonizados. Reduz divergência entre domínios e é pré-requisito para IA/catálogo.

---
Fontes: diagnóstico [[02_diagnostico_fabric_atual]], `analise_basedosdados_lakehouse_eicon.html`, `estrategia_terceirizacao_dados_basedosdados.html`, `autenticacao-service-principal-fabric.html`, `GUIA_MESTRE_DADOS_PUBLICOS.md`, `ARQUITETURA_E_PADROES.md`.
