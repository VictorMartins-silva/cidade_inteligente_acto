# Inventario Bruto (Obsidian/Local)

Lista inicial sem encaixe final.

## Notas de indice e navegacao

- Documentacao_Fabric/00_INDEX_PRINCIPAL.md
- Documentacao_Fabric/Osasco/00_INDEX_OSASCO.md
- Documentacao_Fabric/Santos/00_INDEX_SANTOS.md
- Documentacao_Fabric/specs/00_INDEX_SPECS.md

## Notas essenciais candidatas ao acervo oficial

- Documentacao_Fabric/Osasco/geo_osasco_ssp_dados_criminais.md
- Documentacao_Fabric/Santos/operacao_acto_santos_e_riscos.md
- GUIA_MESTRE_COPILOT.md
- doc/00_MAPA.md
- _DADOS_LOCAIS_HISTORICO/Santos/Referencia_Tecnica_Fabric_Santos_v2_0.md
- _DADOS_LOCAIS_HISTORICO/Santos/Mapeamento Tecnico de Notebooks - Municipio de Santos.md
- _DADOS_LOCAIS_HISTORICO/Osasco/Mapeamento Tecnico de Notebooks - Osasco.md
- _DADOS_LOCAIS_HISTORICO/Santos/pipelines_santos_tecnicos.md
- _DADOS_LOCAIS_HISTORICO/Santos/mapeamento_fabric/mapeamento_paineis_powerbi.md
- _DADOS_LOCAIS_HISTORICO/Santos/doc/fabric_santos_nbs_analise.md
- _DADOS_LOCAIS_HISTORICO/Santos/mapeamento_fabric/diagnostico_padronizacao_paineis_pbi.md

## Notas de ciclo (nao entram direto no acervo oficial)

- Documentacao_Fabric/Osasco/planejamento_semanal_W27.md
- Documentacao_Fabric/Osasco/status_diario_geo_osasco.md
- Documentacao_Fabric/specs/spec_drive_semana_13_07_2026.md
- Documentacao_Fabric/specs/00_INDEX_SPECS.md

## Notas complementares de apoio

- geo_osasco/OBSIDIAN_CONEXAO.md
- Acto Cidade Inteligente/ANALISE_PRODUTO_ACTO_CIDADE_INTELIGENTE.md

## Rascunhos/apoio

- Documentacao_Fabric/README.md (deve ser destilado, nao fonte canonica tecnica)
- Documentacao_Fabric/MIGRACAO_BASE_CONHECIMENTO.md

## Segunda leva — varredura de 22/07/2026 (110 arquivos remanescentes do vault revisados)

Notas essenciais candidatas ao acervo oficial, identificadas na varredura completa do vault ainda nao triado. Ordenadas por valor (ver detalhamento em MATRIZ_CLASSIFICACAO.md).

### Alta prioridade

- Produto_DataHub/00_INDEX_PRODUTO.md + 01_visao_produto_modelo_negocio.md + 02_diagnostico_fabric_atual.md + 03_arquitetura_alvo.md + 04_estrategia_terceirizacao_bd.md + 05_roadmap_fases.md (serie completa — visao de produto/plataforma, sem equivalente no acervo)
- Acto/SCHEMA_LAKEHOUSE_ACTO.md (catalogo de schema Bronze/Silver/Gold do modulo Acto, 60 tabelas)
- Acto/EAV_BRONZE_INVENTARIO.md + Acto/EAV_SILVER_INVENTARIO.md (volumetria/qualidade do modelo EAV novo)
- Acto/INVESTIGACAO_BUG_SANTOS_OBRAS_PAYLOAD_API.md (postmortem tecnico de alta qualidade)
- specs/spec_drive_paridade_gold_obras.md (postmortem: bugs de case-sensitivity + divergencias de design Gold legado x EAV)
- specs/esp_drive_os_multiplas_etapas.md (decisao de design para OS com etapas multiplas simultaneas)
- Dados Publicos/Saude_Educacao/00_INDEX_SAUDE_EDUCACAO.md + DATASUS_CNES_Referencia.md + DATASUS_SIM_SINASC_Referencia.md + DATASUS_SIH_Referencia.md + Censo_Escolar_Referencia.md + IDEB_Referencia.md + MAPEAMENTO_FONTES_COMPLETO.md (7 arquivos — novo conjunto de fontes DATASUS/INEP, mesmo padrao de fonte ja usado para CAGED/SSP)
- Acto/DOCUMENTACAO_TECNICA_ACTO.md (arquitetura tecnica do modulo Acto novo)

### Media prioridade

- doc/GOVERNANCA_E_MANUTENCAO.md (matriz de riscos R1/R5/R6/R9 + runbook operacional)
- specs/spec_drive_documentacao.md (politica de governanca de documentacao)
- Dados Publicos/Mapeamento_Tecnico_Dados_Publicos.md (catalogo de notebooks IBGE/SIDRA/RAIS/CAGED — gap real, acervo nao tem dados publicos ainda)
- Dados Publicos/GUIA_MESTRE_DADOS_PUBLICOS.md (framework "fonte unica de verdade" de dados publicos)
- Dados Publicos/GUIA_GEOJSON_POWERBI.md (guia tecnico GeoJSON -> Power BI Shape Map)
- Mauá/PAINEL_PBI_MAUA_MEIO_AMBIENTE.md (protótipo PBI Mauá — gap real, acervo so tem catalogo Santos/Osasco)
- Osasco/Demografico_RAIS — Documentação Técnica.md (dominio Censo+RAIS Osasco, distinto de CAGED)
- Osasco/analise_incompatibilidade_ssp_criminais_geo_bi_seguranca.md (decisao tecnica bem justificada — bom exemplo de "por que nao trocar de fonte")
- doc/avaliacao_servicos_ia_santos.md (pipeline de IA/sentimento aplicado a avaliacao de servicos)
- doc/codigos_catalogos_etapas_santos.md (catalogo de codigos de contrato de API)
- Santos/nbs_analise/process_mining_obras_santos.md (metodo de process mining aplicado a obras)
- Santos/obras/melhorias-pipelines-obras-santos.md (propostas concretas de otimizacao de pipeline)
- specs/spec_painel_osasco_visita_domiciliar.md + spec_painel_semam_analista_tecnico.md + spec_painel_seont_analista_tecnico.md (paineis novos de 2026, gap vs. catalogos ja migrados)

### Descartar / nao propor (superados ou duplicados dentro do proprio vault)

- doc/DETALHAMENTO_SANTOS.md, doc/DETALHAMENTO_OSASCO_MAUA.md (sobrepostos pelos catalogos de notebooks ja migrados)
- doc/documentacao-arquitetura-fabric.md, doc/roadmap_acto_fabric.md, GUIA_COMPLETO_FABRIC_MEGA.md, doc/DOCUMENTACAO_CONSOLIDADA_FABRIC.md (versoes superadas/sobrepostas — minerar so secoes unicas se necessario)
- Osasco/mapas-ssp-osasco.md (provavel origem/duplicata de pipeline-geoespacial-normalizacao-bairros ja no acervo)
- Osasco/MAPEAMENTO_PAINEIS_PBI_OSASCO.md, Osasco/Mapeamento Técnico de Notebooks — Osasco.md (checar sobreposicao com catalogos ja migrados antes de propor)
- Acto/DIAGRAMAS_ACTO.md = doc/DIAGRAMAS_ACTO.md e Acto/MAPEAMENTO_WORKSPACE_FABRIC.md = doc/MAPEAMENTO_WORKSPACE_FABRIC.md (duplicatas identicas dentro do vault — propor so uma copia)
- Notas com `[!todo]` sem conclusao (paineis_negocio/f1-f4, f6, documentacao_negocio_paineis_pbi.md), status/pendencias pontuais, indices navegacionais e notas de `_obsoleto/` — nao entram no acervo oficial

Detalhamento completo (110 arquivos classificados) em [[MATRIZ_CLASSIFICACAO]].

**Proximo passo (Passada 3 do plano de publicacao — ver PLANO_PUBLICACAO_INCREMENTAL.md):** os itens de "Alta prioridade" acima ainda sao notas brutas do vault, nao conteudo destilado no acervo/. Diferente da leva anterior (ja destilada e proposta em PROPOSTA_ENVIO_LAKEHOUSE_INMOV_2026-07-21.md), estes precisam primeiro virar arquivo real dentro de acervo/ (destilacao por formato) antes de qualquer proposta de envio ao lakehouse-inmov — nao pular etapa.
