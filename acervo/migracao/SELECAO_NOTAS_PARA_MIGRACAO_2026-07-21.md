# Selecao de notas para migracao - 2026-07-21

Objetivo: definir quais notas do vault Obsidian atual valem migracao para o Acervo unico da equipe.

## Criterio aplicado

- Alto valor para onboarding, operacao, risco tecnico ou entrega
- Reuso por mais de uma frente
- Atualizacao frequente com sinal claro de versao
- Facilidade de destilar em formato padrao do Acervo

## Migrar agora (prioridade alta)

| Origem | Destino no Acervo | Acao |
| --- | --- | --- |
| Documentação_Fabric/Osasco/geo_osasco_ssp_dados_criminais.md | fontes/ssp-sp.md e projetos/projeto-geo-osasco.md | separar partes estaveis (fonte/contrato) e partes vivas (projeto) |
| Documentação_Fabric/00_INDEX_PRINCIPAL.md | visao-geral-plataforma.md e workspaces-fabric.md | manter apenas navegacao e contexto transversal |
| _DADOS_LOCAIS_HISTORICO/Santos/Mapeamento Técnico de Notebooks — Município de Santos.md | engenharia-dados/catalogo-notebooks-santos.md | destilar inventario por dominio, entradas, saidas e riscos |
| _DADOS_LOCAIS_HISTORICO/Osasco/Mapeamento Técnico de Notebooks — Osasco.md | engenharia-dados/catalogo-notebooks-osasco.md | destilar inventario por dominio e itens de migracao para Gold |
| _DADOS_LOCAIS_HISTORICO/Santos/mapeamento_fabric/mapeamento_paineis_powerbi.md | bi/catalogo-paineis-santos.md | resumir familias, tabelas Gold, filtros e padroes |
| _DADOS_LOCAIS_HISTORICO/Santos/pipelines_santos_tecnicos.md | engenharia-dados/catalogo-pipelines-santos.md | consolidar padroes de orquestracao e dependencias |
| _DADOS_LOCAIS_HISTORICO/Santos/doc/fabric_santos_nbs_analise.md | engenharia-dados/catalogo-notebooks-santos.md e engenharia-dados/catalogo-pipelines-santos.md | consolidar grafo de dependencias e lineage operacional |
| _DADOS_LOCAIS_HISTORICO/Santos/Referencia_Tecnica_Fabric_Santos_v2_0.md | visao-geral-plataforma.md e workspaces-fabric.md | extrair coordenadas oficiais, escopo e riscos estruturais |

## Migrar parcialmente (prioridade media)

| Origem | Destino no Acervo | Acao |
| --- | --- | --- |
| _DADOS_LOCAIS_HISTORICO/Santos/mapeamento_fabric/diagnostico_padronizacao_paineis_pbi.md | bi/design-system-powerbi.md | migrar desvios recorrentes e padroes de correcoes |
| _DADOS_LOCAIS_HISTORICO/Santos/DOCUMENTACAO_CONSOLIDADA_FABRIC.md | visao-geral-plataforma.md + engenharia-dados/ + bi/ | usar como fonte de validacao cruzada, sem copia integral |
| _DADOS_LOCAIS_HISTORICO/Santos/doc/roadmap_acto_fabric.md | engenharia-dados/sla-carta-servicos.md | extrair somente arquitetura alvo e regras SCD2 |
| Documentação_Fabric/README.md | acervo/README.md | manter apenas instrucoes de uso do vault |

## Nao migrar direto (ficar local ou apenas como fonte)

| Origem | Motivo |
| --- | --- |
| Notas de status diario sem sintese | baixa reutilizacao para equipe inteira |
| Checklists operacionais diarios com granularidade alta | ruido no acervo unico |
| Specs semanais e planejamento semanal | sao artefatos de ciclo, nao base oficial estruturante |
| Rascunhos sem decisao ou sem acao | nao sao base de conhecimento consolidada |

## Backlog recomendado da proxima semana

1. Revisar catalogos criados com owners de cada frente (Dados e BI).
2. Incluir catalogos de Maua e Osasco no mesmo formato oficial.
3. Definir responsavel semanal por atualizacao dos catalogos essenciais.
4. Fechar checklist de qualidade editorial para cada nova migracao.

## Entregas concluidas nesta primeira leva

- [x] catalogo-notebooks-santos.md criado em acervo/engenharia-dados/
- [x] catalogo-pipelines-santos.md criado em acervo/engenharia-dados/
- [x] catalogo-paineis-santos.md criado em acervo/bi/

## Entregas concluidas na rodada seguinte

- [x] atualizacao de fonte SSP-SP em acervo/fontes/ssp-sp.md
- [x] atualizacao de contexto operacional em acervo/projetos/projeto-geo-osasco.md
- [x] incorporacao do diagnostico de padronizacao Santos em acervo/bi/design-system-powerbi.md
- [x] catalogo-notebooks-osasco.md criado em acervo/engenharia-dados/

## Entregas concluidas na rodada atual

- [x] atualizacao de visao-geral-plataforma.md com arquitetura e padroes transversais
- [x] atualizacao de workspaces-fabric.md com escopo e checklist de release
- [x] atualizacao de fontes/acto-api.md com contrato operacional e validacoes
- [x] atualizacao de engenharia-dados/orquestracao-e-observabilidade.md com regras de operacao
- [x] atualizacao de projetos/projeto-acto-santos.md com escopo e plano de estabilizacao
- [x] atualizacao de bi/design-system-powerbi.md com criterios de qualidade de publicacao
- [x] criacao de fontes/caged.md
- [x] criacao de engenharia-dados/monitoramento-fontes-dados.md
- [x] criacao de decisao 2026-07-21-scd2-carta-credenciais-consistencia-escrita.md

## Entregas concluidas na consolidacao fina

- [x] contratos de consumo por familia de painel adicionados em acervo/consumo-sql-endpoint.md
- [x] referencia cruzada de contrato de consumo adicionada em acervo/projetos/projeto-acto-santos.md

## Entregas concluidas na leva Osasco

- [x] catalogo-paineis-osasco.md criado em acervo/bi/
- [x] contratos de consumo por eixo tematico de Osasco adicionados em acervo/consumo-sql-endpoint.md
- [x] alerta de dado sensivel (PII) registrado em acervo/front-end/README.md

## Entregas concluidas na leva Maua

- [x] catalogo-notebooks-maua.md criado em acervo/engenharia-dados/ (fonte: Acto Cidade Inteligente/Maua/CLAUDE.md)
- [x] registrado que Maua ainda nao possui pipeline de orquestracao nem painel Power BI publicado (pastas pipelines/ e bis_producao/ vazias) - nao criar catalogo de pipelines/paineis especulativo

## Regra de manutencao semanal da equipe

- Segunda: triagem das notas novas em migracao/INVENTARIO_BRUTO.md.
- Quarta: destilacao de projetos ativos e decisoes novas.
- Sexta: fechamento da semana em projetos/ e atualizacao de historico quando aplicavel.

Owner sugerido: responsavel da frente ativa + revisao do owner tecnico do acervo.
