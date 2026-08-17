---
status: validado
atualizado: "2026-07-22"
dono: engenharia-dados-santos
---

# Padrao Tecnico - Paridade Obras Santos (Legado x Novo Acto)

## Fonte canonica

- Acto Cidade Inteligente/exploracao_obras_sql/README.md (e notebooks 01, 02, 03, 09 da mesma pasta) (fonte pessoal, não versionada)

## Objetivo

Registrar as divergencias conhecidas entre a cadeia Gold de Obras do legado (`lh_cidade_inteligente_santos`) e a do modulo novo Acto (`lh_solicitacoes_acto`), para qualquer investigacao futura de discrepancia numerica entre os dois e para decidir a aposentadoria do legado com seguranca.

## Contexto

- Legado: `gold_pdr_acompanhamentos_os`, `gold_obras_tempo_etapa`, `gold_obras_seont_os`, gerados a partir de parquets Silver + `PMS_AuxiliarPDR.xlsx`. **Parado desde 11/03/2025 por HTTP 401** — os dados legados estao congelados nessa data e nao recebem carga nova.
- Novo: `gold.santos_obras_acompanhamento`, `gold.santos_obras_tempo_etapa`, alimentados pelo pipeline `pl_ingest_acto` com token renovado automaticamente.

## Diferencas de logica (design pre-paridade, ver nota de estado abaixo)

1. **Selecao da etapa atual**: legado preserva todas as etapas abertas por OS (pode gerar N linhas por OS, `flag_multiplas_etapas`); novo escolhe 1 etapa por OS por prioridade de setor (operador nao-SEONT > SEONT > chefia > NULL > Usuario/Sistema), excluindo etapas de sistema (`ETAPA RESUMO`, `FINALIZAR FLUXO`).
2. **Flags SEONT**: legado usa tabela dedicada `gold_obras_seont_os` com filtro `flag_seont=1`; novo calcula `flag_seont`/`flag_chefia` sobre todas as etapas abertas, sem tabela separada.
3. **`flag_etapa_aprov`**: legado usa lista fixa de ~28 variantes de nome de etapa (replica do PROCV do Excel); novo usa padrao simples `etapa_atual LIKE '%ANALISADA POR%'` — **criterio diferente, comparar com cautela** antes de usar os dois como equivalentes.
4. **Auxiliares**: legado le `PMS_AuxiliarPDR.xlsx` direto; novo materializou como dims Delta (`nb_ingest_obras_aux`).
5. **Bairro/zona**: legado usa mapeamento hardcoded + bfill horizontal de ~375 colunas da API; novo usa coalesce de 3 variantes EAV + `bairro_norm`.
6. **Colunas so no novo**: `numero_licenca`, `deliberacao`, `flag_tem_etapa_mais_avancada`.
7. **Fonte de dados**: legado usa `TOKEN_SANTOS_OBRAS` estatico (hoje quebrado, HTTP 401); novo usa `nb_get_token_api` com renovacao automatica.

## Estado da paridade (mais recente conhecido)

- Em 07-08/07/2026 os notebooks Gold de Obras do modulo novo foram reescritos para bater com o grao e as flags do legado.
- Pos-correcao (03_verificar_seont_pos_pipeline.ipynb, 08/07/2026): de 159 OS que so apareciam no legado, 154 (97%) existem no Silver novo mas sao excluidas pelo filtro `os_alem_seont` — sob investigacao se e por linhas Usuario/Sistema tratadas indevidamente como "avanco alem do SEONT". So 5 OS eram lacuna de ingestao real.
- Auditoria de 21/07/2026 (09_auditar_gap_seont_9os.ipynb): das 9 OS que saíram da intersecao real SEONT desde 17/07 (gap subiu de 71 para 80), a maioria e crescimento normal do legado ficando defasado (esperado, pois o legado esta congelado); poucas sao saida real por avanco legitimo de setor vs. sinal de que o fix `os_alem_seont` ainda nao foi publicado em producao.
- Validacao geral de 22/07/2026 (08_validacao_geral_obras.ipynb): `PDR gap=0`, `Acompanhamento gap=0`, `SEONT so no legado = 78` (era 126 em 16/07). O item SEONT melhorou, mas nao fechou totalmente; segue como monitoramento tecnico e nao impede a decisao de negocio sobre a unidade de contagem.

## Decisao de negocio registrada em 22/07/2026

- Em Obras, a unidade operacional relevante e a **passagem da OS pela etapa**, e nao a OS deduplicada ao longo de todo o fluxo.
- Se a OS ja saiu da etapa, ela **nao conta mais** no estoque atual daquele setor, inclusive no recorte SEONT.
- Se a mesma OS retorna para a mesma etapa em outro momento, a nova passagem **conta como novo atendimento**, porque houve novo esforco operacional para avancar o fluxo.
- Se a OS tramita em paralelo por departamentos diferentes, cada departamento pode contabilizar sua propria etapa ativa ou sua propria passagem historica, conforme o indicador analisado.

## Implicacoes praticas para comparacao e consumo

- Indicadores de fila/estoque atual por setor devem considerar apenas etapas ativas naquele setor no momento da foto.
- Indicadores de produtividade, PDR e tempo operacional devem considerar ocorrencias de etapa, inclusive reentradas da mesma OS na mesma etapa.
- Comparacoes com o legado devem evitar assumir equivalencia estrita por `id_os` quando o objetivo de negocio for medir trabalho executado por etapa.
- Se algum painel ou tabela expuser o rotulo "quantidade de OS" para uma medida baseada em passagens de etapa, o nome da medida ou do visual deve ser revisado para evitar ambiguidade.

## Pontos de atencao para qualquer evolucao futura

- Nao tratar `gold_obras_seont_os` (legado) e a logica SEONT do novo como equivalentes sem revalidar — os criterios de exclusao mudaram.
- `flag_etapa_aprov` tem regra diferente entre as duas geracoes; nao usar para comparar contagem sem normalizar primeiro.
- Antes de aposentar o legado de Obras, validar paridade final com os notebooks desta pasta (parte do plano geral de aposentadoria do legado, ver `arquitetura/visao-geral-plataforma.md` §4.2/§5 no lakehouse-inmov).

## Referencias

- Acto Cidade Inteligente/exploracao_obras_sql/ (notebooks 01, 02, 03, 09) (fonte pessoal, não versionada)
- lakehouse-inmov/arquitetura/visao-geral-plataforma.md (secao "Duplicacao de fontes entre geracoes") (fonte pessoal, não versionada)
