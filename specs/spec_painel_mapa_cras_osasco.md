---
title: "Mapa de área de abrangência dos CRAS — bi_osasco_rma_cras"
owner: "Victor Silva"
projeto: "Painel RMA CRAS (Osasco) — nova visual de mapa"
status: "ativo"
created: 2026-07-23
updated: 2026-07-23
tags:
  - spec
  - osasco
  - cras
  - geo
  - power-bi
  - assistencia-social
---

# Mapa de área de abrangência dos CRAS — bi_osasco_rma_cras

## 1. Objetivo

Adicionar uma visual de mapa ao painel `bi_osasco_rma_cras` (Relatório Mensal de
Atendimentos — CRAS, Osasco), usando a tabela `gold_rma_cras_bairros` e o
shapefile oficial `geo_div_bairro_assistencia_cras` — pedido registrado em
23/07/2026 (ver [[spec_drive_semana_20_07_2026]], P1.2).

## 2. Achados técnicos (23/07/2026)

Levantamento feito com `geo_osasco/analise_mapa_cras_osasco.py` (lê o Fabric
ao vivo) + geojson locais em `Mapas_SSP_Osasco/geojson/`:

- **Nomes batem bem**: 59/59 bairros de `gold_rma_cras_bairros` casam com
  `assistencia_cras_osasco.json` (3 aliases resolvidos: `Indl. *` ↔
  `Industrial *`, `Vila Campesina` ↔ `Campesina`, `Munhoz Jr.` ↔ `Munhoz
  Junior`). Só "IAPI" sobra no shapefile sem dado no RMA.
- **10 CRAS no Gold, 9 no shapefile**: `CRAS - Jardim D'Abril` existe como
  unidade própria no Gold/PBI mas não tem território dissolvido em
  `territorios_cras_osasco.json` — ver decisão na seção 3.
- **`gold_cad_unico_indicadores_bairros` não existe** na lakehouse
  `lh_cidade_inteligente_osasco` (confirmado por query direta e pela visão do
  Gerenciador Fabric). O notebook `nb_gold_cad_unico_pg.ipynb` grava 12
  tabelas no código-fonte, mas só `gold_cad_unico_cod_familiar_fam` e
  `gold_cad_unico_pruc` foram materializadas em produção.
- **CRÍTICO — R1 novo (risco de arquivo auxiliar, mesmo padrão do CLAUDE.md
  para Santos, aqui em Osasco):** o painel `bi_osasco_rma_cras` **já tem**
  uma tabela `indicadores_bairros` carregada (schema idêntico ao
  `gold_cad_unico_indicadores_bairros` do notebook — `bairro`,
  `cod_familiar_fam`, `vlr_renda_per_capita_fam`, etc.), mas ela **não vem do
  Fabric**. A etapa "Origem" no Power Query mostra:
  `Csv.Document(File.Contents("C:\Users\yuri.taba\OneDrive - Eicon Controles
  Inteligentes de Negocios Ltda\BI\osasco\rma\data\indicadores_bairros.csv"))`
  — um CSV local, na pasta pessoal do OneDrive de outra pessoa (Yuri), não
  uma pasta compartilhada. **Confirmado quebrado** em 23/07/2026: o caminho
  não existe na máquina do Victor ("Windows não pode localizar..."). Ou seja,
  alguém já contornou a ausência da tabela Gold com um CSV local congelado,
  em vez de materializar a tabela de verdade no Fabric — e essa dependência
  já está inacessível para qualquer atualização fora da máquina do Yuri
  (refresh manual de outra pessoa ou agendado no serviço Power BI/Fabric vai
  falhar nessa consulta especificamente). Existe também um arquivo
  `bi_osasco_cad_unico.pbix` separado (visto na pasta de relatórios,
  ícone de nuvem "não sincronizado") que pode ter a conexão correta —
  não investigado ainda.
- **`gold_rma_cras_bairros`** é uma métrica fixa (famílias novas por bairro de
  moradia, ligada ao indicador A.2), sem dimensão "indicador" própria — não
  interage com o slicer "Indicador" do painel (mesma limitação já documentada
  no PDF exportado do painel).
- **110 indicadores distintos** em `gold_rma_cras_indicadores`, com
  duplicação de rótulo por variação de texto (ex.: `C.5.1.` com
  "Convivêrncia"/"Convivência", `B.9.` singular/plural) — não bloqueia o
  mapa, mas relevante se um indicador específico for usado pra colorir o
  mapa no futuro.

## 3. Decisões (23/07/2026)

### 3.1 — Geometria do CRAS Jardim D'Abril: Opção A (aproximado por dissolve)

Levantamento no Gold (`gold_rma_cras_bairros`, ano 2026) de quais bairros
reportam o maior valor sob `CRAS - Jardim D'Abril` (não o atributo `CRAS` do
shapefile, que não conhece essa unidade):

| Bairro | Valor (2026) | Território no shapefile |
|---|---|---|
| Bussocaba | 17 | Santo Antonio |
| Jardim D'Abril | 12 | Santo Antonio |
| Vila Yara | 2 | Santo Antonio |
| City Bussocaba | 1 | **Veloso** (anomalia) |

Dissolve real (shapely, `unary_union`) de Bussocaba + Jardim D'Abril + Vila
Yara: resultado é um **MultiPolygon de 2 partes** — Bussocaba e Jardim
D'Abril são contíguos, mas Vila Yara não encosta nos outros dois (fica
separada por Umuarama/Adalgisa, que não fazem parte do CRAS). Isso já é a
geometria real, não um artefato — o contorno aproximado tem mesmo 2 pedaços.

`City Bussocaba` (1 família, 3% do total) ficou **fora do dissolve**: no
shapefile pertence ao território de Veloso, não de Santo Antonio, e juntar
um polígono não-adjacente criaria uma forma multi-parte artificial pra
representar um valor marginal. Documentado como anomalia a verificar
depois, não escondido — pode ser erro de cadastro do endereço da família ou
proximidade real que faz a família ser atendida por Jardim D'Abril mesmo
morando tecnicamente no bairro do território de Veloso.

Tratamento visual no protótipo: contorno tracejado (cor `warning`, não a
cor sólida dos outros 9 territórios oficiais) + rótulo com asterisco
("Jardim D'Abril*") — deixa explícito que não é geometria oficial da
Prefeitura.

### 3.2 — Fase 3 (cruzamento CadÚnico) fica fora do escopo desta semana

Decidido não priorizar rodar `nb_gold_cad_unico_pg.ipynb` completo no Fabric
nesta semana (20-25/07) — a Fase 1 (choropleth por bairro) já entrega valor
sozinha, e o CadÚnico não estava no plano original da semana. Revisitar
quando a Fase 1/2 estiverem em produção.

**Atualização 23/07 (mais tarde, durante a implementação):** o quadro é pior
do que "falta rodar o notebook" — já existe um contorno via CSV local
quebrado (ver seção 2, achado R1 novo). Isso não muda a decisão de não
priorizar esta semana, mas muda o que precisa ser feito quando a Fase 3 for
retomada: não é só "rodar o notebook uma vez", é **substituir uma
dependência de arquivo pessoal já em uso por uma tabela Fabric de
verdade** — risco ativo, não só funcionalidade pendente.

### 3.3 — Mapa definitivo deve seguir os filtros existentes do painel

O mapa no PBI final deve reagir dinamicamente aos filtros já existentes
(Ano, Mês da solicitação, Sigla da unidade) — não um recorte fixo próprio.
Mantém consistência com o resto do painel (ex.: os cards de indicador já
mudam com esses filtros).

## 4. Plano de construção — 3 fases

1. **Fase 1 — pronto para iniciar.** Choropleth por bairro usando
   `gold_rma_cras_bairros` + `assistencia_cras_osasco.json` (59/59 batendo).
   Substitui a lista ordenada "Distritos de moradia" (pág. 2 do PDF atual)
   por leitura geográfica.
2. **Fase 2 — decidido, aproximado.** Contorno dos 9 territórios oficiais +
   contorno tracejado aproximado de Jardim D'Abril (ver 3.1). Revisitar se/quando
   a Prefeitura disponibilizar shapefile atualizado com as 10 unidades.
3. **Fase 3 — concluída (23/07, mesmo dia).** Tooltip cruzado com renda per
   capita e perfil socioeconômico por bairro — resolvida mais rápido do que
   o previsto: achada a tabela Fabric real (`gold.osasco_cad_unico_
   indicadores_bairros` em `lh_dados_publicos`), substituindo o CSV local
   frágil que o painel usava (ver seção 6/2). Não foi necessário rodar
   `nb_gold_cad_unico_pg.ipynb` — a tabela já existia, só em lakehouse
   diferente da esperada.

## 5. Protótipo

Protótipo funcional (HTML, dado real de 2026, ~209 registros) publicado em
23/07/2026 demonstrando as 3 fases — mapa interativo com tooltip por bairro,
toggle de contorno de território, painel lateral com totais reais por CRAS
(fonte: `sigla_da_unidade` do Gold, não o atributo do shapefile — evita
inflar Santo Antonio com a demanda real de Jardim D'Abril) e tabela de dados
como fallback de acessibilidade.

Scripts geradores (não fazem parte do pipeline Fabric, são só para montar o
protótipo local): `build_cras_map_data.py`, `build_jardim_dabril_dissolve.py`,
`build_artifact.py` — ficaram no scratchpad da sessão, não commitados no
repo. Reaproveitar a lógica de normalização de nome e o dissolve do
`build_jardim_dabril_dissolve.py` (shapely `unary_union`) se a Fase 2 for
implementada de fato (ex.: gerando um geojson próprio para o Power BI Icon
Map / Azure Maps consumir).

## 6. Implementação no PBI (23/07/2026, mesmo dia — Fase 1 em andamento)

O painel `bi_osasco_rma_cras` já tinha uma página "Mapas" com visual **Azure
Maps** (não Shape Map nativo), camada de referência (polígonos) carregando
`bairros_osasco.json`, `Local = gold_rma_cras_bairros[bairro]`, `Tamanho =
[Valor]`. Trabalho feito nesta sessão:

- **Geometria corrigida**: gerado `Mapas_SSP_Osasco/geojson/
  bairros_osasco_rma_cras.json` — mesma geometria/propriedade `NOME` de
  `bairros_osasco.json` (drop-in, zero reconfiguração de campo), mas com os
  60 valores de `NOME` reescritos para bater **string a string** com
  `gold_rma_cras_bairros[bairro]` (inclui os 8 aliases já conhecidos —
  `Indl.*`/`Industrial *`, `Vila Campesina`/`Campesina`, `Munhoz
  Jr.`/`Munhoz Junior` — e mais 5 que só apareceram ao comparar literal:
  `Jardim D'Abril`→`Jardim D Abril`, `Cidade de Deus`→`Cidade De Deus`,
  `Portal D'Oeste`→`Portal D Oeste`, `Cidade das Flores`→`Cidade Das
  Flores`, `Jardim das Flores`→`Jardim Das Flores` — o `.str.title()` do
  notebook de origem capitaliza `de`/`das`/`d` e derruba o apóstrofo).
  Também embute o atributo `CRAS` (do shapefile) como bônus. Antes da
  correção, até 13 dos 60 bairros provavelmente ficavam sem preencher no
  mapa por falha silenciosa de join.
- **Cor corrigida**: a "Camada de referência" estava com gradiente
  verde→amarelo→vermelho (estilo "diverging"/semáforo) aplicado a uma
  métrica sem polaridade (contagem de família). Trocado pra sequencial azul
  claro→escuro (`#CDE2FB` → `#3987E5` → `#0D366B`), mesma família de cor do
  protótipo (seção 5) e da paleta validada do skill de dataviz do projeto.
  Campo-base (`Soma de valor`, mín/máx dinâmicos = menor/maior valor do
  contexto filtrado) já estava certo e faz o mapa reagir a filtro de graça —
  fecha a decisão 3.3 sem trabalho extra.
- **Filtros confirmados reativos**: testado com filtro de Mês e de Sigla da
  unidade — o gradiente recalcula corretamente. Nota: como mín/máx são
  relativos ao contexto filtrado, comparar visualmente entre CRAS diferentes
  (ex.: 2 CRAS pequenos lado a lado) pode enganar, porque a escala não é
  fixa — anotado como ajuste fino futuro, não bloqueante.
- **Tabela `dim_bairro_cras` criada** (60 linhas, `bairro` + `cras`,
  colada manualmente via "Inserir dados") — usa o **CRAS real de origem no
  Gold** (não o território do shapefile) para os 4 bairros de Jardim
  D'Abril (Bussocaba, Jardim D'Abril, Vila Yara, City Bussocaba), evitando
  que o tooltip mostre "Santo Antonio" pra demanda que na verdade é de
  Jardim D'Abril.
- **Correção de modelo**: existia uma relação direta
  `gold_rma_cras_bairros[bairro] ↔ indicadores_bairros[bairro]`
  (autodetectada antes desta sessão) que virou ambígua ao adicionar
  `dim_bairro_cras` — Power BI desativou uma perna sozinho, causando tooltip
  errado ("Primeiro cras" mostrando valor de outro bairro). Corrigido:
  excluída a relação direta redundante, e mais uma relação errada
  autodetectada (`gold_rma_cras_bairros[sigla_da_unidade] ↔
  dim_bairro_cras[cras]`, muitos-para-muitos) também removida. Modelo final:
  `dim_bairro_cras` como ponte única (lado 1) para `gold_rma_cras_bairros` e
  `indicadores_bairros` (lado *, ambas ativas, `OneDirection`).
- **R1 (CSV local) RESOLVIDO no mesmo dia**: existe tabela Fabric de verdade
  — `gold.osasco_cad_unico_indicadores_bairros`, na lakehouse
  **`lh_dados_publicos`** (não `lh_cidade_inteligente_osasco`, por isso a
  varredura inicial não achou). Mesmo schema/padrão `gold.<municipio>_*` já
  documentado em [[feedback_table_naming]]. Colunas idênticas ao CSV antigo
  (`bairro`, `vlr_renda_per_capita_fam`, `qtd_pessoas_domic_fam`, etc.) —
  zero mudança na medida DAX, só troca de fonte + reconexão da relação com
  `dim_bairro_cras`. CSV local do Yuri excluído do modelo. Ver
  [[project_risco_csv_local_indicadores_bairros_osasco]] (atualizado como
  resolvido).
- **Página de tooltip customizada criada** — visual "HTML Content"
  (CloudScope) + medida DAX `Tooltip HTML` (usa `LOOKUPVALUE` em vez de
  depender de propagação de relação, porque o Azure Maps filtra a página de
  tooltip diretamente em `gold_rma_cras_bairros[bairro]`, e a relação
  `dim_bairro_cras → gold_rma_cras_bairros` é `OneDirection`, não volta pra
  `dim_bairro_cras`/`indicadores_bairros`). Layout: CRAS (eyebrow) + bairro
  (título) + famílias inseridas no PAIF (número grande) + renda per
  capita/pessoas por domicílio do CadÚnico (rodapé). Testado e validado em
  Bussocaba, Rochdale, Cidade Das Flores. Texto do número grande ajustado
  para **"família(s) inserida(s) no PAIF"** (não só "no PAIF") — o painel
  mostra especificamente novas inclusões por CRAS (indicador A.2), não o
  total em acompanhamento (A.1), e o rótulo original era ambíguo entre os
  dois.
- **Achado — bairro "IAPI" aparece cinza no mapa, não azul**: é o único dos
  60 bairros sem nenhuma linha em `gold_rma_cras_bairros` (nem zero — nunca
  esteve na lista de colunas do CSV de origem do RMA). Os outros 59 têm pelo
  menos 1 linha com `valor=0` e caem no azul mais claro do gradiente; IAPI
  não tem linha nenhuma, então o Azure Maps usa cinza padrão de "sem dado".
  **Não é bug** — é uma distinção real e útil (cinza = bairro que não é
  categoria de relatório do RMA; azul claro = bairro rastreado com zero
  registros no período). Decisão: manter como está. CRAS de IAPI é
  `CRAS - Piratininga` (via `dim_bairro_cras`), pra quando alguém questionar
  esse bairro específico.

## 7. Referências

- [[spec_drive_semana_20_07_2026]] — pedido original, seção P1.2
- `geo_osasco/analise_mapa_cras_osasco.py` — script de levantamento
  nome×geometria×tabela, primeira rodada desta investigação
- [[project_obras_seont_decisao_usuario_sistema]] — mesmo padrão de
  documentar decisão de negócio + anomalia sem esconder, aplicado noutra
  frente (Obras) na mesma semana
- [[project_risco_csv_local_indicadores_bairros_osasco]] — detalhe completo
  do achado R1 (CSV local quebrado) encontrado durante a implementação
- `Mapas_SSP_Osasco/geojson/bairros_osasco_rma_cras.json` — geometria
  corrigida carregada no visual Azure Maps (substituiu `bairros_osasco.json`)
