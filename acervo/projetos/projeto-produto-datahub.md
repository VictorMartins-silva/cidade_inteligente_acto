---
status: rascunho
atualizado: "2026-07-22"
dono: coordenador
valido-ate: "2026-08-31"
---

# Projeto - Produto DataHub Municipal

## Objetivo

Transformar o trabalho de Fabric + Power BI da Eicon em um produto interno replicavel: um hub de dados publicos e operacionais municipais (DataHub Municipal), combinando dados operacionais do Acto (proprietarios) com dados publicos municipalizados (IBGE, RAIS, CAGED, SSP, DATASUS, Censo Escolar/IDEB) numa camada de consumo unica em Power BI.

## Tese central

O produto nao vende "tabelas" - vende decisao municipal informada. Dados publicos nacionais sao commodity; o valor esta em municipalizar, cruzar com o operacional do Acto e entregar no formato que o gestor ja usa (Power BI, Excel via SQL Endpoint). O hub nao substitui o trabalho Acto - ele o envolve com camada de contexto e benchmarking.

## Cliente e posicionamento

- Cliente: prefeituras (B2G). Clientes core: Santos, Osasco, Maua. Em desenvolvimento: Aparecida de Goiania, SJRP.
- Modelo de cluster ja embrionario em `lh_dados_publicos`: 15 municipios em 3 clusters (3 core + 12 benchmark); adicionar cidade = adicionar codigo IBGE em tabela de configuracao.
- Valor analitico ja demonstrado: disparidade de 59 p.p. na formalizacao de emprego entre dois municipios do cluster (RAIS / Populacao); recuperacao pos-pandemia do CAGED confirmada nos 3 clusters; geo de seguranca publica com dezenas de milhares de registros alimentando mapas.

## Diagnostico do estado atual (fotografia)

- Fundacao tecnica (medallion, modulo Acto EAV parametrizado, schema Silver canonico de dados publicos, Direct Lake) ja e considerada adequada para produto.
- O gap esta em engenharia de plataforma: gestao de segredos, ambientes dev/prod, contratos de qualidade, catalogo/lineage, multi-tenancy, kit de onboarding de municipio - e na divida operacional do legado que consome capacidade do time.
- Riscos ativos identificados no diagnostico (nomenclatura R1-R9 usada no restante da documentacao do produto): HTTP 401 parado em obras de um municipio ha dezenas de dias; codigo de municipio hardcoded incorreto em uma fonte; Excel/CSV como fonte auxiliar critica (SPOF); utilitarios de ingestao sem tratamento de erro; funcoes duplicadas; overwrite/append dessincronizando IDs; escrita sem assert de qualidade; payloads conflitantes; credenciais pessoais em texto claro.
- Credenciais hardcoded (tokens de API, credencial de service account GCP em arquivo e em repositorio local, credencial pessoal em texto claro no orquestrador) sao tratadas como bloqueio absoluto para onboarding de cliente novo enquanto nao houver Key Vault.
- O que ja funciona bem e serve de base ao produto: modulo Acto EAV parametrizado (adicionar fonte = 1 JSON, sem codigo novo), schema Silver padrao de dados publicos (`id_municipio · nome_municipio · ano · indicador · valor`), clusters centralizados em utilitario unico, Direct Lake + SQL Endpoint como padrao de consumo, token OAuth2 automatizado no modulo novo, SCD Type 2 de vigencia de prazos (carta de servicos/SLA).

## Arquitetura alvo (proposta)

- Fabric continua como runtime do produto (Lakehouse, SQL Endpoint, Direct Lake, Power BI). Fornecedores de dados publicos (ex.: Base dos Dados/BigQuery) entram como supply chain e benchmark de disciplina de produto de dados, nao como stack a copiar.
- Topologia proposta: um lakehouse central de dados publicos (ingere uma vez, serve N municipios) + um lakehouse central do modulo operacional Acto + lakehouses municipais para dados sensiveis/especificos, conectados por shortcuts (sem duplicar dado).
- Camadas com contrato: Bronze como snapshot fiel e rastreavel; Silver com chaves canonicas e schema padrao; Gold como produto por painel/indicador com um "contrato de produto de dados" versionado (colunas, tipos, grao, frequencia, cobertura, owner, sensibilidade, SLA) - inspirado no padrao de schema/testes usado por fornecedores de dados publicos, substituindo o inventario manual em Markdown.
- Qualidade: checks minimos por produto (not-null em chaves, unicidade por grao, relacionamento com diretorios, recencia/freshness, variacao de volume) com resultado registrado em tabela de monitoramento; pipelines com retry configurado e alerta em falha.
- Configuracao metadata-driven: tabelas Delta de configuracao por tenant (municipio, codigo IBGE, cluster, referencia de segredo, mapeamento de bairros/regionais/prazos) e por fonte externa (dataset, origem, periodicidade, owner, criticidade, SLA, ultima carga, fallback) - elimina Excel auxiliar e codigo hardcoded, habilita onboarding repetivel.
- Seguranca: cofre de segredos para todas as credenciais (rotacionar as ja expostas), Service Principal para conexao dos semantic models (substitui autenticacao pessoal, causa raiz de erros de autorizacao recorrentes), isolamento por cliente (workspace ou RLS/schema por tenant).
- Ambientes/ALM: dev/prod separados, controle de versao integrado ao workspace, pipeline de deploy com validacao antes de promover a producao.
- Distribuicao: Direct Lake como padrao para dados publicos com dimensoes compartilhadas num semantic model unificado (decisao pendente: Direct Lake vs Import - documentos divergem, precisa ser fechada antes do semantic model unificado); template de painel por dominio replicavel entre municipios.
- Diretorios canonicos (municipio, UF, tempo, CNAE, CBO, escola, estabelecimento de saude, bairros harmonizados) promovidos a Delta Tables oficiais do hub, reduzindo divergencia entre dominios.

## Estrategia de terceirizacao (dados publicos nacionais)

- Recomendacao: terceirizacao hibrida via fornecedor especializado em dados publicos nacionais (ex.: Base dos Dados/BigQuery) como acelerador e fornecedor de supply chain - nao como substituto da engenharia propria. Caminho: terceirizar, aprender o metodo do fornecedor, internalizar quando fizer sentido.
- Justificativa: ganho de time-to-market (serie historica completa via uma unica query, contra semanas de engenharia de parser de arquivo bruto), menos engenharia repetitiva de parsers de formato proprietario, padronizacao nacional pronta (chaves de municipio/UF/ano, diretorios).
- Limites explicitos: terceirizar engenharia nao elimina responsabilidade perante a prefeitura - continua havendo dependencia operacional, SLA incerto do fornecedor, custo variavel de consulta, menor controle de schema, debug mais longo (cadeia origem -> fornecedor -> data warehouse -> Fabric -> produto).
- Matriz de decisao por tipo de base: publico nacional commodity -> consumir do fornecedor por padrao; publico nacional critico para produto pago -> comecar via fornecedor exigindo SLA ou construir fallback gradual; fonte estadual/local variavel -> avaliar caso a caso; municipal/sistema interno -> engenharia propria (e o diferencial, tem LGPD); dado sensivel/sigiloso -> nunca terceirizar, lakehouse municipal controlado.
- Regra de controle: nenhuma base externa vira dependencia critica sem dono interno, teste de frescor, teste de schema, politica de fallback e clareza de licenca - tudo registrado em tabela de configuracao de fontes externas.
- Padrao tecnico ja validado numa prova de conceito (RAIS via BigQuery): validacao local com query pequena antes da completa, atencao a diferenca de tipo de chave (string vs int) entre o data warehouse e o Fabric, autenticacao via service account (mover para cofre de segredos), query com pushdown de filtros explicitos antes de agregar, escrita em Delta na Bronze. Mesmo desenho ja aprovado para replicar em outras fontes de saude/educacao (ver [fontes/datasus-inep-saude-educacao.md](fontes/datasus-inep-saude-educacao.md)).
- Gatilhos para internalizar uma base que hoje e terceirizada: atraso recorrente acima da tolerancia contratada; coluna/granularidade que o fornecedor nao replica; custo de consulta superando pipeline proprio; exigencia contratual/compliance sobre cadeia de custodia.

## Roadmap por fases

- Fase 0 (0-30 dias) - estancar e organizar: remover segredos de notebooks/repos e rotacionar credenciais expostas; CI minimo de seguranca; resolver as duas dividas criticas mais urgentes (fonte de obras parada por erro de autenticacao, codigo de municipio hardcoded incorreto); migrar semantic models para Service Principal; plano de descomissionamento do legado tabela a tabela; padronizar nomenclatura Gold; definir template de contrato de produto de dados; assinar plano pago do fornecedor de dados publicos para operacao imediata; agendar negociacao estruturada visando plano corporativo.
- Fase 1 (30-60 dias) - fundacoes de plataforma: criar tabelas de configuracao de tenants e fontes externas (elimina Excel auxiliar e hardcode); implantar checks de qualidade minimos por produto; internalizar diretorios canonicos como Delta Tables; cobrar ambientes dev/prod; fechar decisao Direct Lake vs Import; destravar validacao de fase 2 de dados de saude/educacao com o responsavel tecnico externo.
- Fase 2 (60-90 dias) - piloto de produto: pilotar 3 dominios de saude/educacao como produtos com contrato completo (metadados, testes, catalogo, painel); publicar catalogo inicial com status de qualidade por produto; semantic model unificado de dados publicos; avaliar resultado do piloto e decidir sobre contrato comercial ampliado com o fornecedor; definir empacotamento comercial (insumo comum vs fonte premium).
- Fase 3 (90+ dias) - industrializacao: kit de onboarding de municipio por configuracao (workspace, shortcuts, payloads, pipelines, semantic model, paineis-template), validado com um dos municipios em implantacao; shortcuts OneLake para dados publicos compartilhados; pipelines de deploy dev->prod com validacao; monitorar gatilhos de internalizacao por base; camada de IA/servicos analiticos somente sobre produtos ja documentados.
- Anti-padrao explicito a evitar: nao iniciar pilotos de produto novo (Fase 2) antes de concluir a Fase 0 - pilotar sobre credenciais expostas e sem monitoramento repete o padrao que já gerou uma falha silenciosa de dezenas de dias sem deteccao no passado.

## Próxima ação

_pendente de atualização_

## Decisoes locais / pendentes de negocio (nao tecnicas)

- Expandir clusters de dados publicos para novos municipios e decisao de negocio explicita, nao tecnica.
- Modo do semantic model unificado de dados publicos (Direct Lake vs Import) precisa ser fechado antes de seguir com a Fase 1.
- Empacotamento comercial (o que e insumo comum incluido na plataforma vs. o que e fonte premium cobrada por dominio) ainda em aberto.

## Pendencias externas

- Validacao de fase 2 de dados de saude/educacao e transicao de uma fonte de emprego formal dependem de um responsavel tecnico externo ao time, hoje gargalo de varias frentes.
- Reconexao de paineis de um dos municipios ao novo schema depende de outra pessoa fora do time direto de dados.
- Ambientes dev/prod dependem da liberacao de workspaces adicionais pelo cliente/parceiro de infraestrutura, sem resposta ate o diagnostico.
- Decisoes de escopo de paineis de obras dependem do stakeholder de negocio do municipio principal.

## Referencias

- Documentação_Fabric/Produto_DataHub/00_INDEX_PRODUTO.md + 01 a 05 (fonte pessoal, não versionada)
- acervo/fontes/datasus-inep-saude-educacao.md (padrao tecnico de terceirizacao ja aplicado a saude/educacao)
- acervo/fontes/rais-bigquery.md (prova de conceito que validou o padrao de terceirizacao)
- acervo/engenharia-dados/catalogo-schema-lakehouse-acto.md (schema do modulo Acto citado como fundacao tecnica)
