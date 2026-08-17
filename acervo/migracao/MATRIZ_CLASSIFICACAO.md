# Matriz de Classificacao (Origem -> Destino)

| Origem | Tipo | Destino principal | Acao | Prioridade |
| --- | --- | --- | --- | --- |
| Documentacao_Fabric/Osasco/geo_osasco_ssp_dados_criminais.md | fonte/projeto | fontes/ssp-sp.md + projetos/projeto-geo-osasco.md | dividir e destilar | alta |
| Documentacao_Fabric/Osasco/planejamento_semanal_W27.md | planejamento semanal | manter local (nao acervo oficial) | usar apenas para extrair fatos consolidados quando necessario | baixa |
| Documentacao_Fabric/specs/spec_drive_semana_13_07_2026.md | spec semanal | manter local (nao acervo oficial) | usar apenas para extrair decisao estrutural | baixa |
| Documentacao_Fabric/Osasco/status_diario_geo_osasco.md | status diario | manter local (nao acervo oficial) | nao migrar checklist diario | baixa |
| Documentacao_Fabric/Santos/operacao_acto_santos_e_riscos.md | operacao local | manter local (fora acervo oficial) | usar apenas como apoio para extracao de contexto tecnico | baixa |
| GUIA_MESTRE_COPILOT.md | arquitetura transversal | visao-geral-plataforma.md + workspaces-fabric.md | destilar | alta |
| doc/00_MAPA.md | arquitetura/navegacao | visao-geral-plataforma.md | destilar lookup e hierarquia | media |
| _DADOS_LOCAIS_HISTORICO/Santos/Referencia_Tecnica_Fabric_Santos_v2_0.md | engenharia/projeto | engenharia-dados/* + projetos/projeto-acto-santos.md | extrair somente parte ativa | alta |
| _DADOS_LOCAIS_HISTORICO/Santos/Mapeamento Tecnico de Notebooks - Municipio de Santos.md | engenharia/projeto | engenharia-dados/padrao-medallion-acto.md + projetos/projeto-acto-santos.md | resumir por dominio | alta |
| _DADOS_LOCAIS_HISTORICO/Osasco/Mapeamento Tecnico de Notebooks - Osasco.md | engenharia/projeto | engenharia-dados/catalogo-notebooks-osasco.md | resumir por dominio e gaps de Gold | alta |
| _DADOS_LOCAIS_HISTORICO/Santos/mapeamento_fabric/mapeamento_paineis_powerbi.md | bi/catalogo | bi/catalogo-paineis-santos.md | consolidar familias, filtros e tabelas Gold | alta |
| _DADOS_LOCAIS_HISTORICO/Santos/pipelines_santos_tecnicos.md | engenharia/orquestracao | engenharia-dados/catalogo-pipelines-santos.md | consolidar dependencias e padrao de refresh | alta |
| _DADOS_LOCAIS_HISTORICO/Santos/doc/fabric_santos_nbs_analise.md | engenharia/lineage | engenharia-dados/catalogo-notebooks-santos.md + engenharia-dados/catalogo-pipelines-santos.md | consolidar dependencias e lineage operacional | alta |
| _DADOS_LOCAIS_HISTORICO/Santos/mapeamento_fabric/diagnostico_padronizacao_paineis_pbi.md | bi/governanca | bi/design-system-powerbi.md | incorporar desvios recorrentes e mitigacoes | media |
| _DADOS_LOCAIS_HISTORICO/Santos/DOCUMENTACAO_CONSOLIDADA_FABRIC.md | referencia consolidada | usar como fonte de verificacao cruzada | nao migrar integralmente | media |
| Acto Cidade Inteligente/ANALISE_PRODUTO_ACTO_CIDADE_INTELIGENTE.md | decisao/arquitetura | decisoes/ + visao-geral-plataforma.md | destilar riscos e escolhas | media |
| pbi_design_system_test/estrategia_padronizacao_paineis.md | bi | bi/design-system-powerbi.md | consolidar diretrizes | media |
| .github/AGENTS.md | decisao/processo | decisoes/2026-07-21-arquitetura-agentes-orchestrator.md | registrar decisao | media |
| Documentacao_Fabric/README.md | rascunho de navegacao | descartar como fonte tecnica | manter somente como guia de uso | baixa |

## Segunda leva (varredura 22/07/2026)

| Origem | Tipo | Destino principal | Acao | Prioridade |
| --- | --- | --- | --- | --- |
| Produto_DataHub/01 a 05 (serie completa) | visao de produto/plataforma | decisoes/produto-datahub/ (pasta nova) | destilar serie inteira — visao, diagnostico com matriz de risco R1-R9, arquitetura alvo, terceirizacao, roadmap | alta |
| Acto/SCHEMA_LAKEHOUSE_ACTO.md | catalogo de schema | catalogo-dados/acto/ (pasta nova) | migrar integralmente — referencia autoritativa de 60 tabelas | alta |
| Acto/EAV_BRONZE_INVENTARIO.md + EAV_SILVER_INVENTARIO.md | qualidade/volumetria | catalogo-dados/acto/ | consolidar em uma ficha de qualidade EAV | alta |
| Acto/INVESTIGACAO_BUG_SANTOS_OBRAS_PAYLOAD_API.md | postmortem | decisoes/riscos-conhecidos/ | migrar como postmortem de referencia | alta |
| specs/spec_drive_paridade_gold_obras.md | postmortem/decisao | decisoes/riscos-conhecidos/ | destilar bugs de case-sensitivity e divergencias de design (nao o checklist de progresso) | alta |
| specs/esp_drive_os_multiplas_etapas.md | decisao de design | decisoes/riscos-conhecidos/ | migrar diagnostico e decisao, referenciado por paridade_gold_obras | alta |
| Dados Públicos/Saude_Educacao/*.md (7 arquivos) | ficha de fonte | catalogo-dados/fontes/ | migrar como novo conjunto de fontes (DATASUS/INEP), mesmo padrao de CAGED/SSP | alta |
| Acto/DOCUMENTACAO_TECNICA_ACTO.md | arquitetura tecnica | engenharia-dados/acto/ | destilar arquitetura EAV do modulo novo | alta |
| doc/GOVERNANCA_E_MANUTENCAO.md | governanca/risco | decisoes/governanca/ | migrar matriz de risco operacional (checar sobreposicao com orquestracao-e-observabilidade.md) | media |
| specs/spec_drive_documentacao.md | governanca | decisoes/governanca/ | migrar politica de documentacao (util para o proprio processo de curadoria) | media |
| Dados Públicos/Mapeamento_Tecnico_Dados_Publicos.md | catalogo notebooks | catalogo-dados/notebooks/ | migrar — gap real, acervo ainda nao cobre dados publicos | media |
| Dados Públicos/GUIA_MESTRE_DADOS_PUBLICOS.md | arquitetura | arquitetura/dados-publicos/ | destilar framework "fonte unica de verdade" | media |
| Dados Públicos/GUIA_GEOJSON_POWERBI.md | padrao tecnico | engenharia-dados/padroes/ | migrar guia GeoJSON -> Shape Map | media |
| Mauá/PAINEL_PBI_MAUA_MEIO_AMBIENTE.md | catalogo painel | catalogo-dados/paineis/ | migrar — gap real, sem catalogo Maua hoje | media |
| Osasco/Demografico_RAIS — Documentação Técnica.md | ficha de fonte | catalogo-dados/fontes/ | migrar dominio Censo+RAIS Osasco | media |
| Osasco/analise_incompatibilidade_ssp_criminais_geo_bi_seguranca.md | decisao tecnica | decisoes/ | migrar como exemplo de decisao bem justificada | media |
| doc/avaliacao_servicos_ia_santos.md | padrao de engenharia | engenharia-dados/ia/ (pasta nova) | migrar pipeline IA/sentimento | media |
| Santos/nbs_analise/process_mining_obras_santos.md | metodo/analise | engenharia-dados/ | migrar metodo de process mining aplicado | media |
| Santos/obras/melhorias-pipelines-obras-santos.md | proposta de engenharia | engenharia-dados/padroes/ | migrar propostas de otimizacao concretas | media |
| doc/DETALHAMENTO_SANTOS.md, doc/DETALHAMENTO_OSASCO_MAUA.md | inventario superado | descartar | sobreposto pelos catalogos de notebooks ja migrados | baixa |
| GUIA_COMPLETO_FABRIC_MEGA.md, doc/DOCUMENTACAO_CONSOLIDADA_FABRIC.md, doc/documentacao-arquitetura-fabric.md, doc/roadmap_acto_fabric.md | versoes superadas | nao migrar integralmente | minerar so secoes unicas (ex.: riscos R1-R9 §9 do MEGA) se necessario | baixa |
| Osasco/mapas-ssp-osasco.md | provavel duplicata | descartar | checar contra pipeline-geoespacial-normalizacao-bairros ja migrado antes de qualquer acao | baixa |
