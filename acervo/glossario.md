---
status: validado
atualizado: "2026-07-22"
dono: coordenador
---

# Glossário

Termos usados nas notas do acervo. Definições objetivas para membros novos do time.

---

**Medallion / Bronze–Silver–Gold**
Arquitetura de camadas do lakehouse. Bronze = dado bruto conforme chegou da fonte (sem transformação). Silver = dado limpo, tipado e unificado entre fontes. Gold = dado agregado e pivotado pronto para consumo analítico. Dados nunca retrocedem de camada sem reprocessamento intencional.

**EAV (Entity-Attribute-Value)**
Modelo de dado usado no módulo Acto (`lh_solicitacoes_acto`). Em vez de colunas fixas por tabela, cada campo de formulário vira uma linha com três colunas: entidade (id_os), atributo (nome do campo) e valor. O pivot de EAV para colunas horizontais acontece no notebook Gold de cada domínio.

**SCD Type 2 (Slowly Changing Dimension Type 2)**
Técnica de versionamento de dimensões que mantém o histórico de alterações. Usada na Carta de Serviços e SLA: cada versão de um serviço ou meta de atendimento é uma linha nova com datas de vigência, em vez de sobrescrever a linha anterior. Permite análises históricas sem perda de rastreabilidade.

**Direct Lake**
Modo de conexão do semantic model do Power BI ao Fabric que lê diretamente os arquivos Delta do lakehouse, sem importar dados para o modelo. Combina a performance de Import com a atualidade do DirectQuery. Requer que as tabelas Gold estejam no formato Delta no OneLake.

**SQL Endpoint**
Ponto de acesso de leitura SQL ao lakehouse do Fabric, gerado automaticamente para cada lakehouse. Permite consultar tabelas Gold via T-SQL sem precisar de notebook. É o canal padrão para front-end, integrações e consumo analítico ad hoc.

**Gold+IA**
Extensão analítica sobre tabelas Gold que adiciona campos derivados por modelos de linguagem ou ML (ex.: classificação de sentimento de manifestações, categorização de bairros). Fica em tabelas separadas com sufixo `_ia` ou `_sentimento` para não contaminar a rastreabilidade das tabelas Gold base.

**Família de painel**
Agrupamento de painéis de Santos por secretaria ou tema operacional (ex.: família "Acompanhamento de Serviços" cobre SEGOV, SEINFRA, CET e SEPREF). Define qual conjunto de tabelas Gold alimenta quais painéis e quem é o dono técnico do domínio.

**Eixo temático**
Agrupamento de painéis de Osasco por tema (ex.: Assistência Social, Desenvolvimento Econômico, Segurança Pública). Equivalente à família de painel de Santos, mas com nomenclatura própria do município.

**Cluster municipal**
Grupo de municípios agrupados para benchmarking em `lh_dados_publicos`. Permite comparar indicadores de um município com pares de porte ou perfil socioeconômico semelhante sem precisar carregar todos os municípios do Brasil.

**Contrato de produto de dados**
Metadado versionado de uma tabela Gold descrevendo: colunas e tipos esperados, grão da tabela (o que uma linha representa), SLA de atualização, dono técnico e consumidores conhecidos. Qualquer alteração de schema que quebre um contrato existente deve ser registrada como decisão.

**SLA (neste contexto)**
Prazo máximo de atualização de uma tabela Gold após a atualização da fonte de origem — por exemplo, "1 dia útil". Não se refere ao tempo de atendimento ao usuário final do serviço municipal. Violação de SLA de dados é tratada como incidente de qualidade.

**Shortcut (OneLake)**
Referência virtual a um dado que reside em outro lakehouse, sem duplicar fisicamente os arquivos. Permite que um workspace consuma tabelas Gold de outro workspace sem reprocessamento, mantendo uma única fonte de verdade.

**Payload JSON (Acto)**
Arquivo de configuração que define quais campos extrair de uma fonte da API Acto: lista de catálogos (serviços) e, para cada um, os campos de formulário desejados com seu identificador técnico (`col`) e rótulo (`tit`). Um payload mal mantido (com campos órfãos) pode quebrar silenciosamente a ingestão de todos os catálogos da fonte.

**`lh_cidade_inteligente_santos` / `lh_dados_publicos` / `lh_solicitacoes_acto`**
Os três workspaces/lakehouses ativos da plataforma. `lh_cidade_inteligente_santos`: operação principal de Santos, maior volume de notebooks e base de consumo dos painéis. `lh_dados_publicos`: dados públicos, IBGE, CAGED, geoespacial e benchmarking municipal. `lh_solicitacoes_acto`: módulo EAV parametrizado cobrindo Santos, Osasco e Maúa.

---

> Termos específicos de um domínio (ex.: campos de uma tabela Gold) ficam nas notas de `engenharia-dados/` e `fontes/`.
