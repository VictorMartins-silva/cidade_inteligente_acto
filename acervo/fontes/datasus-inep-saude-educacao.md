---
status: rascunho
atualizado: "2026-07-22"
dono: engenharia-dados
---

# Fonte - DATASUS (CNES, SIM, SINASC, SIH) + INEP (Censo Escolar, IDEB)

## Origem

Seis bases publicas nacionais de saude e educacao, mapeadas para expandir `lh_dados_publicos` com novos dominios de benchmarking municipal: CNES (cadastro de estabelecimentos de saude), SIM (mortalidade), SINASC (nascidos vivos), SIH (internacoes hospitalares do SUS) - todas do Ministerio da Saude/DATASUS; Censo Escolar e IDEB - ambas do INEP/Ministerio da Educacao.

## Rota recomendada

BigQuery via provedor de dados publicos tratados (mesmo provedor e mesma infraestrutura ja usada para a fonte de emprego formal/RAIS do projeto) para as 6 bases. Validacao feita diretamente nos portais oficiais confirma que a cobertura do provedor esta atualizada (uma das bases de saude chega a poucos meses do presente, e a de internacoes a poucos meses tambem) - risco de defasagem que motivou a checagem foi descartado.

Fallback documentado por base, caso o provedor atrase: download direto do FTP oficial (bases de saude, formato proprietario que exige parser) ou download direto do portal do INEP (bases de educacao, arquivos CSV/planilha).

## Formato

| Base | Formato bruto na origem | Formato no provedor recomendado |
|---|---|---|
| CNES | Arquivo mensal por UF/grupo em formato proprietario (13 grupos: estabelecimento, profissional, leitos, equipamentos, equipes, habilitacao, etc.) | Tabelas BigQuery, uma por grupo |
| SIM | Arquivo anual por UF em formato proprietario; CSV no portal de dados abertos | Tabelas BigQuery (microdados + agregados por municipio) |
| SINASC | Arquivo anual por UF em formato proprietario; CSV no portal de dados abertos | Tabelas BigQuery (microdados + agregados) |
| SIH | Arquivo mensal por UF em formato proprietario (AIH reduzida e satelites) | Tabelas BigQuery (dado ja enriquecido por metodologia de terceiro academico) |
| Censo Escolar | CSV delimitado por pipe em pacote anual, 4 dimensoes (escola, turma, matricula, docente) | Tabelas BigQuery, uma por dimensao |
| IDEB | Planilha por edicao (escola, municipio/rede, UF, Brasil) | Tabelas BigQuery por nivel de agregacao |

## Periodicidade

| Base | Periodicidade na origem | Observacao critica |
|---|---|---|
| CNES | Mensal (cadastro vivo, sem conceito de preliminar/fechado) | Estabelecimentos sao obrigados a atualizar cadastro mensalmente |
| SIM | Anual, com versoes preliminar e final | Nunca tratar o ano mais recente como definitivo - fechamento leva 12 a 24 meses |
| SINASC | Anual, com versoes preliminar e final | Mesma regra do SIM - dado preliminar pode ganhar registros ate o fechamento |
| SIH | Mensal, defasagem tipica de ~2 meses | Ultimos ~6 meses sao retificaveis - tratar como janela aberta |
| Censo Escolar | Anual (referencia ultima quarta-feira de maio) | Divulgacao entre fim do ano de coleta e inicio do seguinte |
| IDEB | Bienal (anos impares) - unica base nao anual/mensal do conjunto | Divulgado cerca de 1 ano apos o ano de referencia |

## Lakehouse alvo

`lh_dados_publicos` (mesmo padrao de schema canonico `id_municipio · nome_municipio · ano · indicador · valor` ja usado nas demais fontes publicas do lakehouse).

## Camadas

- Bronze: replica das tabelas do provedor (ou snapshot do FTP/download oficial no caminho de fallback), sem reescrever semantica.
- Silver: municipalizacao e tipagem, com chave de municipio por codigo IBGE.
- Gold: agregacoes por dominio para consumo em painel, seguindo o mesmo padrao das demais fontes publicas do hub.

## Dependencias entre as bases (ordem de ingestao obrigatoria)

- CNES deve ser ingerido antes de SIM, SINASC e SIH - as tres referenciam o codigo do estabelecimento de saude para enriquecimento/lookup.
- Censo Escolar deve ser ingerido antes ou em paralelo ao IDEB - o IDEB usa taxa de aprovacao vinda do Censo Escolar como um dos dois componentes do indice.

## Contrato minimo de qualidade

- SIM/SINASC: carga incremental por ano de competencia, nunca overwrite total (o ano corrente sera republicado como fechado no futuro); registrar explicitamente no Gold se o dado da edicao mais recente e preliminar ou fechado.
- SIH: carga incremental por competencia mensal, comparando a competencia mais recente carregada contra a mais recente disponivel na fonte a cada execucao.
- CNES: considerar carga incremental por competencia (nao overwrite total) para preservar historico de mudanca de estabelecimento, relevante para as bases que o referenciam por competencia.
- Censo Escolar/IDEB: carga anual/bienal disparada por checagem manual de nova edicao publicada (nao ha endpoint de metadados formal para verificacao automatica) - monitoramento deve ser calendarizado, nao por polling.
- Municipio de residencia vs. municipio de ocorrencia/atendimento: SIM, SINASC e SIH tem os dois conceitos (ex.: um municipio-polo pode concentrar internacoes de pacientes de cidades vizinhas) - decidir explicitamente qual usar por indicador antes de comparar entre municipios do cluster, para nao distorcer o benchmarking.

## Restricoes LGPD

Microdados individuais (1 linha por obito, nascimento, internacao ou matricula) exigem tratamento agregado nas camadas de consumo, sem exposicao de identificador pessoal - mesmo padrao ja aplicado as demais fontes sensiveis do hub de dados publicos.

## Referencia tecnica

- Documentação_Fabric/Dados Públicos/Saude_Educacao/00_INDEX_SAUDE_EDUCACAO.md + MAPEAMENTO_FONTES_COMPLETO.md (fonte pessoal, não versionada)
- Documentação_Fabric/Dados Públicos/Saude_Educacao/DATASUS_CNES_Referencia.md, DATASUS_SIM_SINASC_Referencia.md, DATASUS_SIH_Referencia.md, Censo_Escolar_Referencia.md, IDEB_Referencia.md (fonte pessoal, não versionada)
- acervo/fontes/rais-bigquery.md (padrao de ingestao via BigQuery ja validado, mesma infraestrutura reaproveitada)
- acervo/projetos/projeto-produto-datahub.md (estrategia de terceirizacao que embasa a rota recomendada)
